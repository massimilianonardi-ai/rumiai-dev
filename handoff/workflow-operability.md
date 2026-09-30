# Workflow operability review

Status: Active
Updated: 2026-09-30

## Goal

Strengthen the RumiAI development workflow so internally coherent implementations cannot be treated as complete when they miss the normal user intent, impose avoidable implementation knowledge on users, or make the primary public workflow unnatural.

## Current repository revisions

```text
rumiai-dev  90ec5068aa2be8e8d99c3b77f2aaaeb31a667506
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

- Identified the workflow gap: current gates strongly protect internal consistency and authenticity, but do not explicitly protect normal user intent, discoverability, cognitive load or primary user workflows.

## Current state

The workflow needs a project-wide operability/intent gate plus testing guidance for public user paths.

## Next action

Update RULES.md, CONSISTENCY-GATE.md and TESTING.md, then run the documentation consistency gate.

## Blockers / open questions

None.
