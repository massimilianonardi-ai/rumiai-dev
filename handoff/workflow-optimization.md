# workflow-optimization

Status: Active
Updated: 2026-09-17

## Goal

Maintain a long-lived meta-workstream for continuously evaluating and improving the RumiAI development workflow: retrieval, documentation organization, Project Instructions, handoffs, deferred-work visibility, specification promotion, command/manual consistency, parallel work, repository coordination, testing/validation workflow and other mechanisms that affect how work is performed and resumed.

## Current repository revisions

```text
rumiai-dev    e4f80a4ccf41c75fa971c54c41e8d95f5778ceee  (pre-checkpoint HEAD after manual-task synchronization)
rumiai-os     b18ae4439519bfe4081035a7d6d0a29423a81709  (current command/manual inventory inspected)
rumiai-tests  d59a05417e91a97a10424f6dbc25047f9bfee383  (current remote HEAD inspected for manual-task state)
pkg-catalog   94f58995cbd487b17f3b82bc2724c70540927b88  (last recorded; not involved in this correction)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
todo/README.md
handoff/README.md
```

Subsystem specifications are added only when a concrete workflow question reaches their responsibility.

## Fixed task-local choices

- Stable task identity: `workflow-optimization` / `handoff/workflow-optimization.md`.
- This task is intentionally long-lived across chats while the workflow continues to be evaluated.
- Its handoff is synchronized automatically at meaningful checkpoints according to `handoff/README.md`.
- It governs workflow health and reusable lessons; it must not become a second copy of canonical rules/specifications or a catch-all implementation task.
- Durable workflow rules are propagated to canonical current documentation.
- Documentation maintenance uses the accepted hybrid/event-driven model now canonical in `README.md`.
- Current canonical development documentation in `rumiai-dev` is maintained in English; product/user-facing localization is separate.
- Known work that is concrete but intentionally deferred is represented under `todo/`; active resumable work is represented under `handoff/`; completed/past state is preserved by Git history.
- A TODO is minimal planning state, not a specification or active task state.
- Activation transfers ownership from `todo/<topic>.md` to `handoff/<task>.md` in the same work unit, ideally the same commit, without keeping duplicate current representations.
- `todo/` is not part of the mandatory read order for unrelated tasks.
- `specifications/` contains promoted current contract only; unresolved active design belongs in handoff `Working design` until promotion.
- Every RumiAI-owned directly executable command identity requires operational manual coverage regardless of whether the command is end-user-facing or primarily technical/internal.
- Command creation/rename/removal and behavior-affecting modification are coupled to manual realignment in the same work unit; every command modification requires an explicit manual-consistency check.

## Completed

### Current-only documentation and retrieval model

The documentation was reorganized around:

```text
current branch = present
Git history = past
```

The root `README.md` is the deterministic retrieval router. Current contracts live in one canonical location; historical patch composition is not used to reconstruct current meaning.

### Project Instructions optimization

ChatGPT Project Instructions were reduced to a bootstrap into the current repository knowledge base rather than a second RumiAI knowledge base.

### Parallel task handoff protocol

Substantial, parallel and multi-chat tasks use one stable active handoff each. Meaningful checkpoints are synchronized before the final user-visible response. Completed handoffs receive a final `Status: Complete` snapshot and are then removed from the active tree; Git history is the archive.

### Documentation maintenance and language

The hybrid/event-driven documentation-maintenance model was made canonical. A dedicated normalization task translated remaining current Italian/mixed-language documents to English and removed stale current-tree material discovered during that work.

### Deferred-work TODO lifecycle

The missing lifecycle layer for known but not-yet-active work was implemented:

```text
specifications/      promoted current contracts
todo/                concrete known work intentionally deferred
handoff/             active/resumable task state
Git history          past/completed state
implementation/tests current mechanical state and evidence
```

Two historical pending workstreams were deliberately recovered after current-state verification:

```text
todo/pkg-install-real-validation.md
todo/rumiai-tests-suite-realignment.md
```

### Specification promotion boundary

A workflow defect observed during active `mk` design had placed provisional candidates, postponed decisions and comparison criteria into `specifications/rumiai-os/MK.md`.

The workflow was corrected to:

```text
promoted / binding current contract      → specifications/
active provisional / unresolved design   → handoff/<task>.md / Working design
experimental evidence needed to decide   → rumiai-dev-PoCs, referenced by handoff
concrete work deferred outside task       → todo/
past design state after completion        → Git history
```

`RULES.md`, `CONSISTENCY-GATE.md` and `handoff/README.md` encode the promotion gate, and the concrete `mk` misuse was realigned by moving unresolved language/runtime, serialization and lifecycle design into the active handoff while keeping only promoted contract in current specifications.

### Command/manual completeness

The user identified a lifecycle requirement after the first `manual` mechanism was implemented: operational documentation must not be optional for technical/internal commands.

The workflow now treats command implementation and operational manual consistency as one development obligation.

Canonical changes made in the same correction:

- `RULES.md` requires every RumiAI-owned directly executable command identity to have an operational manual topic and couples command create/rename/remove/change to manual consistency;
- `COMMAND-ENTRYPOINTS.md` defines the covered command-identity classes and clarifies that multiple paths/symlink exposures of one command identity require one topic, while sourced libraries and package-owned external commands are outside the invariant;
- `DOCUMENTATION-MODEL.md` makes command coverage mandatory regardless of audience and requires permanent mechanical coverage from command identity to owner-local manual topic;
- `CONSISTENCY-GATE.md` now requires command tasks to retrieve `COMMAND-ENTRYPOINTS.md` + `DOCUMENTATION-MODEL.md`, inspect the manual topic, run the command/manual gate and refuse completion while code/reference disagree;
- `specifications/README.md` routes command tasks explicitly to both contracts.

The current product was inspected rather than assuming the new invariant was already satisfied. At `rumiai-os@b18ae4439519bfe4081035a7d6d0a29423a81709`, 22 RumiAI-owned command identities were observed: 20 technical `sys` identities including root `m`, plus branded `rumiai-os` and `rumiai-os-sh`. Only four current manual topics exist (`sys manual`, `sys pkg`, `sys srv`, `sys state-path`), leaving 18 command identities uncovered.

Because manual development is already an active workstream, this remediation was not converted into a TODO. `handoff/rumiai-os-man-documentation.md` was expanded so it cannot complete until the missing command topics are created and permanent structural coverage detects missing required topics.

No product files or permanent tests were changed by this workflow correction itself; the active manual task owns that implementation/test realignment.

### Concurrency evidence

Earlier workflow work observed concurrent `rumiai-dev` movement from other chats and reconciled it forward without overwriting unrelated work. This remains the required pattern for all subsequent workflow/documentation writes.

## Current state

`workflow-optimization` remains active.

The current lifecycle now distinguishes:

```text
promoted contract       → specifications/
active working design   → handoff/Working design
deferred future work    → todo/
command operational ref → revision-coupled manual topic in rumiai-os
past state              → Git history
```

The command/manual rule is canonical, while current product coverage is explicitly pending inside the already-active manual task rather than hidden as specification drift.

## Next action

Observe the TODO lifecycle, specification promotion gate and command/manual gate in normal use. In particular:

1. verify that new deferred work is captured only when concrete and intentionally postponed;
2. verify that active design candidates/open questions remain in `Working design` until promotion;
3. verify that every command-development task retrieves and checks its operational manual;
4. verify that technical/internal commands are not incorrectly exempted from manual coverage;
5. verify that the active manual task closes the current 18-topic coverage gap and adds structural permanent coverage;
6. watch for TODO/handoff/specification/manual duplication or taxonomy drift.

## Blockers / open questions

None for the workflow rule itself. Current command-manual backfill and structural test work belong to the active `rumiai-os-man-documentation` task.
