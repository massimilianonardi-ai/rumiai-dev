# Deferred work TODOs

Status: **Current**  
Updated: 2026-09-17

This directory contains **known RumiAI work that is intentionally deferred and has not yet been activated as a task**.

A TODO is current planning state. It is not a normative specification, active task state, implementation evidence or historical archive.

## 1. Purpose

`todo/` fills the lifecycle gap between discovering concrete unfinished work and deciding to activate a dedicated task for it.

Use it for work that is known to require future attention but is deliberately not being executed in the current work unit.

The lifecycle is:

```text
known deferred work
    ↓
todo/<topic>.md
    ↓ activate
handoff/<task>.md
    ↓ complete
Git history
```

Specifications continue to define what must be true. Handoffs continue to represent active/resumable tasks. Git history remains the archive for past state.

## 2. Qualification rule

Create a TODO only when all of these are true:

1. there is a concrete reason to believe work remains to be done;
2. the work is not being completed in the current work unit;
3. the topic is sufficiently defined to become one or more future tasks;
4. keeping it visible prevents a material risk of losing known unfinished work.

Typical qualifying cases include:

- a concrete implementation/specification mismatch intentionally deferred;
- a known test or subsystem realignment that requires a separate work unit;
- a missing capability already recognized as required;
- a substantial refactor deliberately postponed;
- a sufficiently defined design topic that should be activated later.

Do not create TODOs for vague ideas, speculative possibilities, generic aspirations or notes that have no concrete future work attached.

## 3. One small file per topic

Use a stable semantic filename:

```text
todo/<topic>.md
```

Prefer one file per independently activatable topic rather than a monolithic backlog document. This reduces merge contention between parallel chats and gives each deferred work item a stable identity.

Do not create dated chains for the same topic.

## 4. Minimal shape

A TODO should normally contain only:

```text
# <topic>

## Intent

## Why pending

## Scope

## Evidence
```

### Intent

State the future outcome in one or two sentences.

### Why pending

State why the work is known to remain open and why it is not being completed now.

### Scope

List the repositories/subsystems materially involved when known.

### Evidence

Point to current specifications, implementation, tests or other current evidence that establishes the need. Historical references may be included only when the TODO originated from an explicitly historical recovery and the current state has independently confirmed that the work remains open.

## 5. What does not belong in a TODO

Do not put detailed execution state in `todo/`:

- no chronological narrative;
- no implementation plan beyond the concise intent;
- no task-local design decisions;
- no `Next action` state machine;
- no test logs;
- no progress percentages;
- no conversation transcript;
- no copied specification text;
- no priority/ranking scheme unless a future explicit workflow need establishes one.

If the work needs these things, it is no longer merely deferred work and should be activated as a task/handoff.

## 6. Activation

When work on a TODO is intentionally started, transition ownership from `todo/` to `handoff/`.

The normal activation is:

```text
delete todo/<topic>.md
create handoff/<task>.md
```

Perform both changes in the same authorized work unit and, when practical, in the same commit so the current tree does not contain duplicate planning/task state or a visibility gap.

The new handoff must follow `handoff/README.md` and must be built from fresh repository preflight plus current sources. The TODO is a pointer to deferred work, not sufficient context by itself to begin implementation.

Once activated, the handoff is the current source for task state. Do not retain a duplicate TODO entry.

## 7. Completion and removal

A TODO can leave the current tree in two ways:

1. **activation**: it is replaced by an active handoff as described above;
2. **invalidated/no longer needed**: current authoritative state proves that the work is no longer required, so the TODO is removed in a normal forward commit with the reason captured by commit context or the work unit that established it.

Do not create `todo/completed/`, `todo/archive/` or equivalent history directories.

Git history preserves previous TODO files and their removal forward-only.

## 8. Discovery and retrieval

`todo/` is **not part of the mandatory read order for every RumiAI task**. Loading the entire deferred-work inventory during unrelated work would add noise.

Read `todo/README.md` and relevant TODO items when:

- choosing or reviewing work to activate;
- checking whether a newly discovered deferred issue is already known;
- activating a TODO into a task;
- maintaining or auditing the pending-work inventory.

A normal subsystem task does not need to read unrelated TODOs.

## 9. Relationship to active work

A topic must not simultaneously exist as both current TODO state and active handoff state for the same work.

If a currently active task discovers additional work that is outside its authorized/sensible scope and intentionally defers it, that task may create a separate TODO before closing or continuing.

If a TODO is broad and activation reveals multiple independently resumable workstreams, activation may split it into multiple handoffs or into one active handoff plus narrower remaining TODOs, provided the resulting current tree has no duplicated responsibility.

## 10. Historical recovery

Git history is not searched during ordinary TODO maintenance.

A deliberate historical-recovery task may inspect historical commits, removed handoffs and superseded documents to discover candidates that were known before this TODO mechanism existed. Historical text is discovery evidence only.

For every candidate:

```text
historical candidate
        +
current specifications / implementation / tests
        ↓
current verification
        ↓
still open → create todo/<topic>.md
resolved/superseded → do not restore it
```

Never repopulate `todo/` by blindly copying old TODOs, handoffs or decision documents. The current project state determines whether a recovered candidate still deserves a current TODO.

## 11. Minimality rule

`todo/` should answer only:

```text
what known work is intentionally deferred?
why do we know it remains open?
where is the current evidence?
```

Everything needed to execute and resume the work belongs to the future active handoff, current specifications, implementation and tests.