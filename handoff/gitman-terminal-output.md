# gitman quick-action ordering and terminal headers

Status: Active
Updated: 2026-09-22

## Goal

Move the existing Sync + Push quick action to the first position in the root Git action menu and make terminal/no-pager execution print one three-line header per menu-selected command sequence: 50 hyphens, the selected menu label, then 50 hyphens.

## Current repository revisions

```text
rumiai-dev    48b910c6182835cb0e2f3fbdaf62dc29dbeda447
rumiai-os     cbcf6467838eda79c1afedd22061299d5c1a40ff
rumiai-tests  ed173d66480579e1eb869d80beb43cfb9fccdf5d
```

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/README.md
specifications/rumiai-os/GITMAN.md
specifications/rumiai-os/PAGER.md
specifications/rumiai-os/MENU.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
```

## Fixed task-local choices

- Preserve the existing public action name `Sync + Push`; only its root-menu position changes.
- The terminal-mode header is emitted once for the whole command sequence selected from a menu, not once for every internal Git subprocess of a composite action.
- The header text is the concrete selected menu label. For branch switching this is the concrete branch item such as `Switch: git switch feature/example`.

## Completed

- Mandatory preflight completed for the involved repositories.
- Current gitman implementation, operational manual and dedicated permanent tests inspected.

## Current state

No product/spec/test modification has been made yet.

## Next action

Realign the canonical gitman contract, product implementation/manual and permanent tests, then execute proportional validation and the final consistency gate.

## Blockers / open questions

None.
