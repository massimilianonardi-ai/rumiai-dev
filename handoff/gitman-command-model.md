# gitman command model

Status: Active
Updated: 2026-09-20

## Goal

Refactor `gitman` so Git actions and nested action menus are simple to extend while preserving explicit, inspectable execution. Remove the former read-only product restriction without yet adding mutating Git actions in this work unit.

## Current repository revisions

- `rumiai-dev`: `dbbbef8ec2032573c4ab2be83801c58f62490d09`
- `rumiai-os`: `b001d3893592ced06106fe268a67862ca7b7b5f8`
- `rumiai-tests`: `d41b2f611a77d35426cee8bcd47ef88438814356`

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/GITMAN.md`
- `specifications/rumiai-os/MENU.md`
- `specifications/rumiai-os/PAGER.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

- The previous `gitman` read-only restriction is removed.
- This work unit refactors the command/action model first; it does not yet add mutating Git actions.
- Leaf menu labels show the concrete Git command or command template that the action executes.
- Menu definitions use action identifiers plus display labels; display text is never interpreted as shell code.
- Action identifiers dispatch to explicit shell handler functions using the `gitman_action_<id>` convention.
- Simple Git handlers delegate to one generic Git runner; complex handlers remain ordinary shell functions.
- Nested menus are ordinary handler calls and use the shell call stack for return context; no generic menu-stack/context framework is introduced.
- No command-string DSL and no `eval`-based Git execution is introduced.

## Completed

- Mandatory preflight completed against the repository revisions above.
- Current specification, implementation, operational manual and permanent gitman tests inspected.

## Current state

The current implementation still maps `status|log|branch|diff` through a central case statement and the current specification/manual still describe the action set as read-only.

## Next action

Update the canonical gitman specification, then refactor implementation/manual/tests to the accepted action-handler model and validate the unchanged existing Git actions.

## Blockers / open questions

None for this work unit.
