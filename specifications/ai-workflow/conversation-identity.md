# AI-Workflow — Conversation Identity and Continuity

**Intended repository path:** `doc/conversation-identity.md` in `ai-workflow`  
**Status:** approved design specification; publication does not activate the workflow  
**Date:** 2026-11-09  
**Scope:** Chat, Work, and Codex, subject to actually available access and execution capabilities

## 1. Purpose and boundaries

Define how to recover or generate the AI-Workflow identity of a conversation, maintain sequential checkpoints, detect branches, synchronize state, and reconcile identifiers created in error. This specification describes an application-level protocol: it does not assume that the host platform exposes a native conversation identifier or branching signals, or that a model always has access to the complete conversation history.

Rules reside in the `ai-workflow` repository; mutable data resides in `ai-work-state`. This document is referenced by the second instruction of bootstrap section 1. Universal finalization (section 3) applies its persistence operations and emits the marker. Host-environment rules and actual permissions take precedence over the operational possibilities described here.

## 2. Identifiers

| Identifier | Rule |
| --- | --- |
| `chat-id` | Immutable; format `YYYY-MM-DD_HH-MM_UUID`, using a UUID v4 and the timestamp when the **AI-Workflow identity is generated**, not necessarily when the platform conversation is opened. |
| `branch-id` | Nonnegative integer, starting at 0 for the first path; subsequent values are assigned monotonically and never reused within a `chat-id`. |
| `message-id` | Integer, first response = 1, incremented for **each assistant response** along a path; a branch continues numbering from its originating checkpoint. |

The readable timestamp in `chat-id` uses the `Europe/Rome` time zone; the full timestamp, including its offset, is stored in the initial branch. The pair `(branch-id, message-id)` is meaningful only within a given `chat-id`. These identifiers do not automatically identify native messages on the host platform.

The final marker of every response uses this ordinary format:

```text
ai-work-state: chat-id = <chat-id>; branch-id = <n>; message-id = <n>
```

Only when persistence of the checkpoint has not been confirmed, append:

```text
ai-work-state: chat-id = <chat-id>; branch-id = <n>; message-id = <n>; sync = pending
```

The marker is the **last line of the response**, separated from the content by a blank line and displayed in monospace. It identifies the **response that was produced**, not necessarily the checkpoint already stored in the repository. Report any errors before the marker. Never fabricate identifiers or confirmations of writes.

## 3. Persistence and file model

Minimum structure in `ai-work-state`:

```text
conversations/
  2026-11-09_14-11_<uuid>/
    branch-0.yaml
    branch-1.yaml
    ...
```

There are no branch subdirectories. The directory supplies the `chat-id`; the filename supplies the `branch-id`. Neither is repeated in the file contents.

### 3.1 Initial branch

```yaml
created_at: '2026-11-09T14:11:00+01:00'
message_id: 3
tasks:
  - task-A
  - task-B
```

For branch 0, `created_at` is the time the identity was generated. `message_id` denotes the latest assistant-response checkpoint **persisted** for that branch. `tasks` contains only the active associations at that persisted checkpoint.

### 3.2 Derived branch

```yaml
created_at: '2026-11-09T15:20:00+01:00'
parent_branch: 0
fork_message: 3
message_id: 4
tasks:
  - task-A
  - task-C
```

`created_at` indicates when the branch was created/detected by AI-Workflow. Include `parent_branch` and `fork_message` **only when verifiable**. If provenance is known solely through reconciliation, use the recovery reference described in section 9 without inventing an ancestral checkpoint.

`tasks: []` means **no associated tasks**; `tasks: null` means task associations cannot be reconstructed with sufficient confidence. Do not silently turn uncertainty into an empty list.

### 3.3 Request index

Request history preserves the relationship among prompts, branches, checkpoints, and one or more tasks, including **changes to task associations**. It must allow reconstruction of the tasks associated at an earlier checkpoint. The request index's exact paths and format will be established by the persistence specification; this document defines an interface requirement, not a newly approved file schema. The complete chat archive remains independent for now.

## 4. Initialization and identity recovery

Before analyzing a request:

1. Find the **latest complete marker** accessible in the history of the same conversation. Read the `chat-id`, `branch-id`, `message-id` triple and any `sync = pending` flag. Do not treat markers quoted in prose, examples, or other chats as the current state.
2. If a marker is available, resolve any aliases, retrieve the corresponding branch file, and verify consistency. If an alias also remaps the branch, update both components of the current identity.
3. If no marker can be recovered, try only identity signals that are genuinely available and verifiable in the context or host environment. Absence of a marker **does not prove** that a conversation is new.
4. If no identity is recoverable **and** recovery failure is not merely a temporary access failure affecting an identity already known, generate a new `chat-id`, create its directory, and initialize `branch-0.yaml` with `message_id: 0` and task associations yet to be determined. Use conditional creation that cannot overwrite existing files.
5. If persistence of the newly created identity fails, retain the identity in the local response marker with `sync = pending` and explicitly disclose that it was not saved.

An infallible preliminary determination of "new chat" versus "existing chat" is not required: first look for an identity, then generate one if necessary. A new identity generated because information was unavailable remains eligible for later reconciliation. Do not merge conversations based solely on textual similarity.

## 5. Checkpoints, continuation, and divergence

Always distinguish three values: the **source checkpoint** from the preceding marker (`m`), the **persisted branch head** (`h`), and the **current response checkpoint** (`m + 1` on the appropriate branch).

| Comparison | Operational interpretation | Action |
| --- | --- | --- |
| `m = h`, no pending flag | Ordinary continuation | Process and save `m + 1` on the same branch. |
| `m < h`, no pending flag | Path resumes from an earlier checkpoint: detectable divergence | Create a new branch from checkpoint `m`. |
| `m > h` | Persisted state is behind, a write was lost, or information is inconsistent | Recover; **do not** assume branching. |
| `sync = pending` | Unconfirmed local checkpoint | Apply section 7 before classifying differences as new branches. |
| Inconsistent state/marker or missing file | Identity or persistence requires verification | Do not overwrite; apply section 8. |

Numerical equality is meaningful only for the same **canonical** identity and branch. Responses regenerated from an earlier checkpoint may be treated as alternative evolutions; there is no need to distinguish an "original" path from a "derived" one.

A derived branch continues numbering after the shared checkpoint: if the fork originates at `0/3`, its first response on `branch-1` is `1/4`. Messages 1–3 remain part of the parent branch's history; do not fabricate them as responses physically emitted on `branch-1`.

## 6. Branch detection and creation

If `m < h` and a pending synchronization that could explain the discrepancy has been ruled out:

1. Reconstruct the task associations **effective at checkpoint `m`** from the history of association changes. Do not automatically copy the parent branch's task list from its current head `h`.
2. Allocate the next available `branch-id` greater than the maximum existing one; reserve it through conditional creation of `branch-N.yaml` without overwriting existing files. On collision, reread and retry.
3. Record `created_at`, `parent_branch`, `fork_message`, reconstructed `tasks`, and the starting point `message_id: m`. This initial write **reserves the branch**; the first confirmed response advances its counter to `m + 1`.
4. **Begin the first response on the new branch with an explicit detection notice**, stating the branch ID and source checkpoint. If the reservation is not confirmed, do not claim the branch was created; describe the assignment as provisional and report `sync = pending`.
5. On finalization, save `m + 1`, the current task associations, and the relevant changes; emit the marker with the branch actually assigned.

Suggested ordinary notification: **"AI-Workflow: conversation divergence detected; created branch 1 from checkpoint 0/3."**

The notification must also make possible false positives caused by message-management errors visible. Do not assert certainty about the cause of divergence: a checkpoint divergence was detected, not necessarily a native "Create branch" action on the platform.

## 7. Synchronization and `sync = pending`

The `message-id` identifies the current response even when persistence fails. A failed write must not move the response identifier backward to the previous persisted checkpoint.

1. Following a failed or indeterminate write, **reread the repository when possible**: a communications error may occur after a successful write.
2. If the checkpoint cannot be verified, disclose the problem in the response and append `sync = pending` to its final marker. Preserve the local identity and any chain of pending checkpoints.
3. At the next prompt, first attempt to recover and synchronize whatever pending updates are available, without fabricating deltas, messages, or decisions that cannot be recovered. A marker alone does not necessarily contain enough data to replay updates to tasks and indexes.
4. An explicitly pending checkpoint **must not automatically be classified as a branch** because its number differs from persisted state.
5. If recovery succeeds and is verified, proceed with the next checkpoint and remove `sync = pending`. Otherwise, continue local numbering where possible, preserve `sync = pending`, and disclose limitations.
6. If another path has meanwhile modified persisted state, do not overwrite it: compare verifiable checkpoint provenance and reconcile, or treat the conflict as an alternative evolution when appropriate.

The availability of conversation context or an event log sufficient to reconstruct deltas is not guaranteed. When information required for recovery is missing, disclose the gap; do not certify an incomplete history as synchronized.

## 8. Concurrency and anomalies

For every modification to an existing branch, use a conditional write against the Git revision previously read. If a concurrent modification occurs, reread the file and **reevaluate** the situation from the original source checkpoint of the current response; never blindly repeat the same write.

- If another response has advanced that same branch in the meantime, the current response may become a divergence and require a new branch. In that case, the notification must appear **at the beginning of the final response**.
- Creating a new `branch-N.yaml` must fail when the file already exists; never overwrite it, and retry with a different ID.
- Do not interpret failed reads as proof of a new conversation or create a new `chat-id` to work around an outage affecting an identity already known.
- If `m > h` without a verifiable explanation, or if aliases are inconsistent, suspend potentially destructive updates and disclose uncertainty.
- An event or historical modification written twice during a retry must be recognizable as a duplicate; exact record idempotency is defined by the request-index specification.

A conditional write of an individual file does not automatically make updates to tasks, indexes, and handoffs atomic. Universal finalization must prescribe write order, retry behavior, and reference verification.

## 9. Duplicate identities and reconciliation

If `C2` was mistakenly generated as a new conversation even though it belongs to the logical conversation `C1`:

1. Establish the relationship using trustworthy information or explicit approval; semantic similarity alone is insufficient.
2. Select the canonical identity, normally the earliest verified identifier (`C1`).
3. Import each branch of `C2` as a separate `branch-N.yaml` under `C1`, preserving task associations, history, and internal branch relations where reconstructible. Do not automatically combine task lists, baselines, or branch states.
4. Retain an `alias.yaml` inside `C2` pointing to the canonical identity, including a complete mapping from `C2`'s previous branch IDs to their new IDs under `C1`. Historical references remain resolvable.
5. For each imported branch, record its provenance from the recovered conversation; include `parent_branch` and `fork_message` only when supported by sufficient evidence.
6. Future responses use `C1` and the canonical branch, while earlier markers referring to `C2` continue to resolve through the alias.

Example alias (proposed shape, to be validated during implementation):

```yaml
canonical_chat_id: C1
branches:
  0: 2
  1: 3
```

A merge is **identity reconciliation**, not deletion or arbitrary fusion of histories. A provenance reference in an imported branch may help auditing; its exact format is deferred to the persistence schema to avoid unnecessary duplication.

## 10. Universal finalization and operation order

For each response, including responses without persistent tasks:

1. Identify the source checkpoint and any divergence, reserving a branch when necessary.
2. Carry out the requested work within authorizations and verified sources; determine relevant task associations.
3. Record the request reference and association changes; update only task documents actually affected; write the relevant handoffs last among task documents.
4. Conditionally advance the branch checkpoint and verify the outcomes. If any required update fails, do not claim complete persistence and retain `sync = pending`.
5. If a new branch was detected, begin the final response with its notice. Disclose any persistence gap before the final marker.
6. End with the single final state marker, referring to the response actually emitted.

**Invariant:** bootstrap section 3 must run even when section 2 ends in error, blockage, refusal, partial work, or no task. Ending a response is not equivalent to closing a task.

## 11. Invariants

- A logical conversation retains its `chat-id`, including all known branches.
- `chat-id` and `branch-id` are not repeated inside `branch-N.yaml`.
- `message-id` increments by one per response along a path even when persistence is pending.
- `tasks: []` and `tasks: null` are different: confirmed absence versus unrecovered information.
- No branch overwrites another branch's state.
- No new branch inherits the parent's present task list when it differs from the task associations at the source checkpoint.
- No merge invents ancestry or automatically combines objectives and baselines.
- No unverified outcome is reported as verified.
- No detected branch goes without a notification at the start of its corresponding response.
- No operational document can omit the universal finalization prescribed by the bootstrap.

## 12. Minimum verification scenarios

| Scenario | Initial situation | Expected result |
| --- | --- | --- |
| New conversation | No recoverable ID | New `chat-id`, `branch-0.yaml` with initial checkpoint 0; first response = 1. |
| Continuation | Marker `0/3`, branch persisted at `0/3` | Response `0/4`, verified save. |
| Branch | Marker `0/3`, branch persisted at `0/6` | New `branch-1`, first response `1/4`, opening notice. |
| Branch with changed tasks | At checkpoint 3: A,B; at 6: A,C | New branch inherits A,B, not A,C. |
| Concurrency | Two responses start from `0/3` | One may continue branch 0; the other must reread and create another branch without overwriting. |
| Branch ID collision | Two reservations attempt `branch-1` | One succeeds; the other allocates a different ID. |
| Failed save | Response `0/4`, persisted checkpoint `0/3` | Marker `0/4; sync = pending`; never decrement. |
| Pending recovery | Previous response `0/4; pending`, file at `0/3` | Attempt recovery; do not immediately classify as branch. |
| Remote state behind | Marker `0/6`, file at `0/4` without pending | Diagnose inconsistency; do not overwrite or automatically create branch. |
| Duplicate recovery | C2 recognized as part of C1 | Import branches, preserve alias C2→C1, and use the canonical ID in the final marker. |
| Read failure | Known ID, repository unavailable | Preserve the ID; disclose unverified persistence and do not generate a replacement ID. |
| Task associations unavailable | Fork from historical checkpoint without accessible association changes | `tasks: null`, disclose uncertainty; do not copy the current list arbitrarily. |

## 13. Interfaces to specify elsewhere

The following items do not alter approved decisions, but require companion specifications before activation:

- Request-index schema and location, including the reconstruction of historical task associations.
- Multi-file finalization protocol and write idempotency following retry or crash.
- Recoverable representation of pending updates when chat context alone is insufficient.
- Exact format of provenance references in imported branches and how uncertain merges are approved.
- Adaptation to identity signals that are actually exposed by Chat, Work, and Codex.

None of these interfaces may be replaced with unverified assumptions about the host environment.
