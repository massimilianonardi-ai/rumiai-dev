# gitman command

Status: Active
Updated: 2026-09-19

## Goal

Implement the technical `gitman` command as an interactive manager for local non-bare Git working trees, with repository acquisition/management menus and an initial read-only Git action menu.

## Current repository revisions

```text
rumiai-dev   c10167ab80c69d0efea53e7e502f1298bad77552
rumiai-os    34671a5a1e9917fa39e3bbbd4b155590202c9b22
rumiai-tests 88b4e48f170da883889c2f418a34e8ad24066e9d
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`
- `specifications/README.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/MENU.md`
- `specifications/rumiai-os/READ-KEY.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`
- `specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md`

## Fixed task-local choices

- Command identity: `gitman`, technical `m` layer, bootstrap-integrated.
- Positional operands are candidate directories. With zero operands, read initial candidates from user-scoped `sys/gitman/conf`; if no usable configured candidate exists, fall back to `.`.
- Initial configuration format is one literal directory pathname per non-empty line. Relative entries resolve against the invocation working directory; shell expansion is not applied.
- Candidates are accepted only when they belong to a non-bare Git working tree.
- Accepted candidates normalize to the physical Git working-tree top-level; duplicate top-levels are stored once.
- Distinct linked Git worktrees remain distinct entries even when they share the same underlying Git repository.
- The bottom footer contains only the most recent validation/configuration error. Multiple candidate failures from one validation operation are aggregated into one message.
- Zero repositories opens filesystem `menu` multi-selection; confirmed selections are revalidated and added.
- One or more repositories opens a single-select repository menu.
- Repository-menu management actions: `a` add, `r` remove via multi-select, `c` clear all.
- Repository selection with Enter opens the Git action menu.
- Git action menu uses Backspace to return to the repository menu; Escape also cancels the submenu back to its parent.
- Initial Git actions are read-only: status, log, branch, diff.
- A Git action runs only after the menu session has returned and restored the terminal. After the Git command finishes, `gitman` prompts `Press any key to continue...`, waits through `read-key`, then recreates the Git action menu.
- Top-level Escape/cancellation exits `gitman` successfully. Submenu cancellation returns to the parent menu.
- Repository-list mutations are in-memory only; `gitman` never deletes repositories or modifies Git state in this first delivery.

## Working design

None currently required.

## Completed

- Mandatory preflight completed.
- Current command, state, menu, terminal-input, documentation and testing contracts inspected.
- Existing product has no `gitman` command or conflicting Git-manager identity.

## Current state

No task-specific specification, product implementation or permanent tests have been written yet.

## Next action

Promote the accepted `gitman` contract into a current specification and route it, then implement command/manual and permanent tests, followed by development and formal validation.

## Blockers / open questions

None.
