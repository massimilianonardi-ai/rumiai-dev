# workflow-optimization

Status: Active
Updated: 2026-09-17

## Goal

Maintain a long-lived meta-workstream for continuously evaluating and improving the RumiAI development workflow: retrieval, documentation organization, Project Instructions, handoffs, parallel work, repository coordination, testing/validation workflow and other mechanisms that affect how work is performed and resumed.

## Current repository revisions

```text
rumiai-dev    77660f3971e25f07ef67636acf7c085969325b53  (pre-checkpoint HEAD)
rumiai-os     36c29d8412a523f722fd90004b78a07fdf0b06c8  (last inspected)
rumiai-tests  298931c1dca03d44755893d64b9b3a7c0058b7ea  (current remote HEAD inspected for pending-work evidence)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
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

### `rumiai-os` operational documentation task

A dedicated `handoff/rumiai-os-man-documentation.md` task is active to design the boundary between normative development specifications and runtime/user operational reference.

### Pending-work visibility gap discovered

A workflow audit triggered by the user's question found that the current model has no explicit current surface for **known work that remains pending but has not yet been activated as a task**.

Current handoffs cover active tasks only. Current specifications describe contracts, not a project backlog. Git history preserves completed/superseded task state, but ordinary retrieval intentionally does not consult history.

This creates a real visibility gap between:

```text
known pending work
    ↓
not yet an active task/handoff
    ↓
not a normative specification
    ↓
therefore not directly represented in the current retrieval surface
```

Concrete evidence:

- `rumiai-dev` currently has no backlog/open-work document and searches for generic `pending`, `TODO`, `restructure` and the known `pkg install` realignment did not reveal a current pending-work index;
- `handoff/` currently contains only active workstreams;
- `rumiai-tests@298931c1dca03d44755893d64b9b3a7c0058b7ea` still contains `tests/rumiai-os/pkg/install.test`, which constructs fixture roots, a fake `state-path`, a fixture repository adapter/catalog and substituted package-pipeline functions instead of exercising the complete real `pkg install` path required by the current testing contract;
- the previously known need to realign that test and to audit/restructure the broader suite is therefore mechanically observable but no longer represented by a dedicated current planning surface after revision-specific evidence was correctly removed from `TESTING.md`.

This is not a reason to put pending implementation work back into normative specifications. It indicates a missing lifecycle layer between "known/open" and "active task".

## Current state

`workflow-optimization` remains active. The newly discovered workflow question is whether RumiAI needs a small current **pending-work inventory** distinct from:

- specifications (current contracts),
- handoffs (active/resumable task state),
- Git history (past),
- implementation/tests (mechanical state).

No name, file path, schema or lifecycle for that inventory has been fixed yet.

## Next action

Design the smallest pending-work mechanism that makes known unfinished work discoverable without turning `rumiai-dev` into a project-management archive or duplicating active handoffs.

The design should answer at least:

1. what qualifies for the inventory;
2. how an item moves from pending to an active handoff;
3. how completion/removal works;
4. whether the inventory should contain only concise pointers/intent rather than task details;
5. how to reconstruct and backfill currently known pending work such as real `pkg install` validation/debugging and the broader `rumiai-tests` realignment without treating historical memory as current authority.

## Blockers / open questions

- Decide whether to introduce a canonical pending-work inventory.
- Decide its minimal shape and relationship to active handoffs.
- If adopted, perform a deliberate one-time recovery/audit of known pending work from current repositories plus only the historical sources specifically needed to reconstruct items that were lost from the current surface.
- Continue observing whether `specifications/` needs stronger taxonomy as the operational-documentation task progresses.
