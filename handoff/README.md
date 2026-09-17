# Active task handoffs

Status: **Current**  
Updated: 2026-09-17

This directory contains only handoffs for **currently active work that must survive chat/session boundaries**.

A handoff is durable task state, not project-wide authority.

## 1. Purpose

The handoff is the persistent boundary between volatile chat context and durable task state.

Its purpose is to allow a task to be resumed safely from a new clean chat without reconstructing progress from conversation history.

A handoff records only what is necessary to continue the task. It does not duplicate the project knowledge base.

## 2. When a handoff is required

Create one handoff when a task is substantial, parallel, multi-chat or otherwise likely to lose material state if the current conversation disappears.

Typical triggers include:

- multiple meaningful implementation steps;
- work spanning more than one repository;
- a task expected to continue across chats/sessions;
- substantial investigation with unresolved next actions;
- a parallel workstream that must remain independently resumable.

When the need is known from the start, create the handoff after the mandatory preflight and before the first material task change.

If a task starts small and later crosses this threshold, create the handoff as soon as that becomes clear.

Short, self-contained tasks do not need a handoff merely for bookkeeping.

Known work that is intentionally deferred and not yet active belongs under `todo/`, not `handoff/`. See `todo/README.md`.

## 3. Activation from deferred TODO work

When a current `todo/<topic>.md` item is intentionally activated as a task, task-state ownership moves from `todo/` to `handoff/`.

Use the normal fresh preflight first; the TODO is a concise deferred-work pointer and is not sufficient execution context by itself.

Then perform the transition:

```text
delete todo/<topic>.md
create handoff/<task-name>.md
```

Both changes belong to the same authorized work unit and should be committed together when practical. The same work must not remain represented simultaneously by a current TODO and an active handoff.

The new handoff may use the TODO's intent/evidence as input, but it must be written from current authoritative sources and current repository state. Do not copy historical assumptions or stale revision facts into the handoff without verification.

If activation reveals that one TODO actually contains multiple independently resumable workstreams, split ownership explicitly: create the required active handoff(s) and retain only genuinely deferred residual work as separate minimal TODO item(s).

## 4. One stable identity per task

Use a stable semantic task name rather than a timestamp:

```text
handoff/<task-name>.md
```

The same task updates the same file for its entire active lifetime.

Do not create chains such as:

```text
2026-09-17-task.md
2026-09-18-task.md
2026-09-19-task.md
```

for successive moments of one task.

A task should have exactly one active handoff unless the task itself has been deliberately split into independently resumable workstreams.

## 5. Required shape

Keep the file concise and directly resumable:

```text
# <task title>

Status: Active
Updated: <date/time when useful>

## Goal

## Current repository revisions

## Applicable canonical sources

## Fixed task-local choices

## Working design              # optional; use only when active design is not yet promotable

## Completed

## Current state

## Next action

## Blockers / open questions
```

### Goal

State the task outcome, not a transcript of how it was requested.

### Current repository revisions

Record the exact revisions most recently relied upon for the involved repositories when they materially help detect movement before resumption.

These SHAs are task state, not substitutes for fresh HEAD retrieval.

### Applicable canonical sources

List paths, not copied rule text.

### Fixed task-local choices

Record only choices that are fixed for this workstream but have not become a general canonical contract. If a choice becomes durable project/subsystem policy, propagate it to the canonical current source and remove the duplicated rule from the handoff.

### Working design

Use this optional section for **persistent but non-authoritative design state** that a clean chat needs in order to continue the active task without reconstructing the conversation.

It may contain, when material:

```text
candidate choices still under evaluation
provisional working assumptions
alternatives and the criteria by which they will be compared
questions intentionally postponed within the active task
partial design structures that are not yet accepted contract
evidence still required before promotion
```

Working design is not a specification. Its presence means the corresponding choice has **not** passed the specification promotion gate in `CONSISTENCY-GATE.md`.

Do not copy a promoted subsystem contract into this section. Once a working-design item becomes sufficiently settled to bind current implementation and future work, promote the resulting rule to the canonical specification and remove the duplicated provisional material from the handoff.

If an unresolved design item is intentionally moved outside the active task, create a minimal TODO and remove that item from active working design. If an experiment is needed, place the experiment in `rumiai-dev-PoCs` and reference it here rather than embedding experimental artifacts in the handoff.

### Completed

Record meaningful completed work, not every command executed.

### Current state

Describe the exact state from which a new chat should continue.

### Next action

There should normally be one concrete next action or a very small ordered set.

### Blockers / open questions

Include only blockers or genuinely unresolved choices that affect continuation. When an unresolved choice needs more persistent context than a short question, keep the detail in `Working design` and leave this section as the concise blocker/question index.

## 6. Resume protocol

A new chat that resumes an active task must not read the handoff in isolation.

Use the normal project preflight:

```text
verify current remote HEADs
→ read root README.md
→ read RULES.md
→ read CONSISTENCY-GATE.md
→ read relevant current specifications
→ read the active task handoff
→ inspect implementation/tests as required
```

Then compare the revisions/state recorded by the handoff with current repository state.

If repositories advanced after the handoff checkpoint, reconcile forward before continuing. Do not assume the handoff's stored SHA is still HEAD.

## 7. Automatic checkpoint synchronization

During active work, synchronize the handoff automatically whenever the task state changes materially.

A **meaningful checkpoint** exists when at least one of these occurs:

```text
a task-local decision becomes fixed
working design changes materially
a modification is completed
a test or validation is executed and its result matters to continuation
a problem, mismatch, regression or blocker is discovered
a blocker is resolved
the task scope changes materially
the next action changes materially
relevant repository revisions change in a way a resumed chat must know
```

A response by itself is not a checkpoint.

Routine explanation, unchanged analysis, repeated status reporting or incidental command execution does not require an update when it does not change resumable task state.

If active work discovers concrete additional work that is intentionally deferred outside the current task, create or update the appropriate minimal TODO under `todo/` rather than accumulating that future work inside the active handoff.

## 8. Synchronize before the final response

When the current response materially advances an active handoff task, the handoff synchronization is part of completing that response.

The required order is:

```text
perform the task work
→ run the applicable consistency/validation checks
→ update the active handoff to the resulting state
→ verify the handoff update succeeded
→ send the final user-visible response
```

The final response must therefore describe state that is already persisted when persistence is required.

Do not tell the user that the handoff is synchronized before the write actually succeeds.

If synchronization is required but cannot be completed, report that explicitly in the final response and describe the unsynchronized state. Do not silently rely on chat memory.

## 9. Parallel work and concurrency

Separate parallel tasks use separate handoff files.

Example:

```text
handoff/pkg-install.md
handoff/geoserver-catalog.md
handoff/maven-catalog.md
```

The handoffs isolate **task state**, not repository write access.

Two tasks may still touch the same repository. Therefore every task must obey the normal forward-only concurrency rule:

- verify current remote HEAD before writes;
- preserve user/other-task changes;
- if HEAD moved, retrieve the new state and reconcile forward;
- never use force push or history rewriting to resolve parallel work.

An active handoff may be updated by a different chat than the one that created it, provided the normal preflight and reconciliation are performed first.

## 10. What must not be duplicated

Do not copy into a handoff:

- project-wide rules;
- full subsystem specifications;
- testing policy;
- large source excerpts;
- permanent evidence that belongs in `rumiai-tests`;
- historical narrative already preserved by Git;
- deferred-work inventory that belongs under `todo/`.

Reference canonical paths instead.

Working design is the exception only for **task-local, not-yet-promoted state** needed for resumption. It must not become a shadow specification.

If a task-local decision becomes a durable subsystem contract, propagate it to the applicable current specification in the same work unit whenever possible. The handoff should then record only the task consequence/progress.

## 11. Completion protocol

A completed task must disappear from the active handoff set, but its final resumable snapshot should remain historically reconstructable.

Use this sequence:

1. propagate every durable rule/contract to its canonical current source;
2. resolve all remaining working design by promoting accepted contract, converting still-relevant outside-scope work into minimal TODO items, or discarding candidates/assumptions that are no longer required;
3. ensure implementation, tests and revision-specific evidence are stored in their proper repositories;
4. capture any other concrete out-of-scope work that is intentionally deferred as minimal TODO items when applicable;
5. run the final consistency gate for the task;
6. update the handoff one last time with:

   ```text
   Status: Complete
   ```

   plus final repository revisions, completed outcome, final validation status and no remaining next action/blocker;
7. commit that final snapshot;
8. remove the handoff from the current tree in a **later forward commit**.

A completed handoff must not leave unresolved working design behind merely to preserve memory. If it is still relevant, it must have a current owner before the handoff is removed: promoted specification or deferred TODO.

Git history therefore preserves both the active evolution and final state of the handoff without leaving completed task files in normal retrieval.

Do **not** create `handoff/completed/`, `handoff/archive/` or another historical handoff tree. Git history is the archive.

## 12. Background limitation

A chat cannot continue editing a handoff after the response/task has stopped unless an explicit scheduled or externally triggered mechanism is configured.

"Automatic" in this contract means automatic **inside the active task response cycle**: the assistant performs the handoff checkpoint without requiring a separate user instruction whenever a meaningful checkpoint occurred and existing task authorization permits repository writes.

This is sufficient to make chat replacement safe at response boundaries, provided the required synchronization succeeded before the final response.

## 13. Minimality rule

The handoff must optimize resumption, not completeness of narrative.

Prefer:

```text
what is fixed
what remains provisional
what changed
what is true now
what happens next
```

over chronological transcripts.

If removing a paragraph would not make a clean chat materially less able to resume the task, the paragraph probably does not belong in the handoff.
