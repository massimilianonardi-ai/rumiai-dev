# Active task handoffs

Status: **Current**  
Updated: 2026-09-17

This directory contains only handoffs for **currently active work that must survive chat/session boundaries**.

A handoff is task state, not project-wide authority.

## When to create one

Create one handoff when a task is substantial enough that losing the current chat would materially lose:

- exact progress;
- repository revisions last inspected;
- already-fixed task-local choices;
- partially completed work;
- blockers or the next concrete step.

Do not create handoffs for short self-contained tasks.

## Naming

Use a stable task name rather than a timestamp as the primary identity:

```text
<task-name>.md
```

The task may span many sessions; the same file is updated forward-only while active.

Do not create a chain of dated handoffs for successive moments of the same task.

## Required shape

An active handoff should stay concise and contain:

```text
# <task title>
Status: Active
Updated: <date/time if useful>

## Goal
## Current repository revisions
## Applicable canonical sources
## Fixed task-local choices
## Completed
## Current state
## Next action
## Blockers / open questions
```

Only include facts needed to resume the task.

## What must not be duplicated

Do not copy project-wide rules, full specifications, test policy or large source excerpts into a handoff.

Reference their canonical paths instead.

If a task-local decision becomes a durable subsystem contract, propagate it to the applicable current specification; the handoff may then record only that the propagation occurred.

## Lifecycle

While active:

- update the same handoff at meaningful checkpoints;
- keep repository SHAs current enough to detect external movement;
- do not treat the handoff as a substitute for fresh preflight retrieval.

When complete:

1. propagate every durable rule/contract to the canonical current source;
2. ensure implementation/tests/evidence state is recorded in the proper repository;
3. remove the handoff from the current tree in a normal forward commit.

Git history preserves the completed handoff. Completed handoffs do not remain in the current branch and therefore cannot compete with current specifications during ordinary retrieval.

## Background updates

A chat cannot autonomously keep a handoff updated after the chat/task stops unless an explicit scheduled/triggered mechanism exists. During active repository work, however, the handoff may be updated as part of normal task checkpoints without requiring a separate user instruction each time when the task authorization already covers it.
