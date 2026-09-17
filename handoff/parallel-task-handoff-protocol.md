# Parallel task handoff protocol

Status: Active
Updated: 2026-09-17

## Goal

Formalize automatic persistent handoffs for substantial, parallel or multi-chat RumiAI tasks so each task can be resumed safely from a clean chat and the handoff is synchronized before a response that materially advances the task.

## Current repository revisions

```text
rumiai-dev  0b990060ff907f0786c4f79235db5ccd55fbf1f6  (pre-implementation HEAD)
```

Only `rumiai-dev` is involved in this documentation work unit.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
handoff/README.md
```

`specifications/README.md` was checked; no subsystem specification applies.

## Fixed task-local choices

- one stable handoff file per active task;
- handoff synchronization occurs inside the same response cycle, before the final user-visible reply, when task state materially changes;
- meaningful checkpoints include fixed decisions, completed modifications, executed tests/validation, discovered problems/blockers, changed next action/scope, and materially changed repository revisions;
- completed handoffs do not remain in the current tree;
- Git history is the archive for completed handoffs, not a separate completed-handoff directory;
- completion uses a final `Status: Complete` snapshot followed by forward deletion after durable state has been propagated.

## Completed

- mandatory preflight completed against `rumiai-dev` HEAD `0b990060ff907f0786c4f79235db5ccd55fbf1f6`;
- current README, RULES, CONSISTENCY-GATE, specification router and handoff contract read.

## Current state

Implementation of the protocol documentation is starting.

## Next action

Update `README.md`, `handoff/README.md` and `CONSISTENCY-GATE.md`, then perform the final consistency scan, synchronize this handoff, mark it complete and remove it from the current tree.

## Blockers / open questions

None.
