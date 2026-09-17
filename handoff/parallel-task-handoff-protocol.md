# Parallel task handoff protocol

Status: Complete
Updated: 2026-09-17

## Goal

Formalize automatic persistent handoffs for substantial, parallel or multi-chat RumiAI tasks so each task can be resumed safely from a clean chat and the handoff is synchronized before a response that materially advances the task.

## Current repository revisions

```text
rumiai-dev  339f6de62df50990f2773cc345de1baf25e59e5d  (completed protocol implementation before final handoff snapshot)
```

Only `rumiai-dev` was involved in this documentation work unit.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
handoff/README.md
```

`specifications/README.md` was checked; no subsystem specification applies.

## Fixed task-local choices

All durable choices have been propagated to the canonical current documentation. No task-local choice remains authoritative only in this handoff.

## Completed

- mandatory preflight completed against the then-current remote HEAD;
- an active handoff was created before the first material protocol change;
- `README.md` now defines when parallel/substantial/multi-chat tasks acquire handoffs, automatic meaningful checkpoints, pre-response synchronization and Git-history archival;
- `handoff/README.md` now defines creation, stable identity, required shape, resume protocol, checkpoint triggers, synchronization ordering, parallel concurrency, minimality and completion lifecycle;
- `CONSISTENCY-GATE.md` now requires checkpoint synchronization and verifies active/final handoff lifecycle in the completion checklist;
- the resulting documentation diff was reread against current RULES and the specification router;
- no product/runtime/test repositories were modified;
- no runtime or physical tests were required because this work unit changes documentation/process only;
- Git history remained forward-only.

## Current state

The protocol is fully implemented in canonical current documentation and the task is complete.

Validation status: documentation consistency review completed; no runtime/physical validation applicable.

## Next action

None. Remove this completed handoff from the current tree in the next forward commit so Git history becomes its archive.

## Blockers / open questions

None.
