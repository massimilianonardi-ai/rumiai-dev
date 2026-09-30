# Workflow operability review

Status: Complete
Updated: 2026-09-30

## Goal

Strengthen the RumiAI development workflow so internally coherent implementations cannot be treated as complete when they miss the normal user intent, impose avoidable implementation knowledge on users, or make the primary public workflow unnatural.

## Current repository revisions

```text
rumiai-dev  1344df44405dc483acc53966759b8ee0cb882888
```

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
handoff/README.md
```

## Fixed task-local choices

Keep the correction compact and canonical rather than creating a second large process document.

## Completed

- Added the project-wide product-intent and operability principle to `RULES.md`.
- Added a mandatory intent/operability pre-implementation and post-change gate to `CONSISTENCY-GATE.md`, including the caller/system knowledge boundary and semantic-delta checks.
- Required representative normal user-path coverage for materially user-facing public workflows in `TESTING.md`.
- Added concise acceptance scenarios to the active-handoff model for tasks that materially change user-visible behavior.
- Re-read the resulting canonical sections and compared the complete change set against the pre-task revision.

## Current state

The workflow now rejects technically coherent designs that make a primary user goal unnatural or require avoidable provider/revision/internal knowledge. Normal-path behavior must be stated before implementation, exercised through the public interface when applicable, and protected by representative permanent coverage when deterministic and maintainable.

## Next action

None. Apply the new gate to subsequent product work, beginning with the pkg review.

## Blockers / open questions

None.

## Validation

Documentation-only work unit. No executable product tests were applicable. The final consistency review checked the touched canonical sections, completion checklist integration, handoff lifecycle integration, cross-document ownership and the forward-only diff from `90ec5068aa2be8e8d99c3b77f2aaaeb31a667506` through `1344df44405dc483acc53966759b8ee0cb882888`.
