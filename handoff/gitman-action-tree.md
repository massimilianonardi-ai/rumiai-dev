# gitman action tree

Status: Active
Updated: 2026-09-20

## Goal

Build the first extensible Git action tree on the current gitman handler model, keeping a small high-frequency root and moving related operations into nested menus.

## Current repository revisions

- `rumiai-dev`: `193d9694cba8329e5ef59fd306f1dbffc269107e`
- `rumiai-os`: `b18d0fc804814c7b99e841df6f5d1fc22d2e5a90`
- `rumiai-tests`: `ce04e33c0c9aef57db1e70b0dfe1616d69e30fa3`

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

- Root actions stay intentionally small and expose common operations directly: Status, Diff, Pull and Commit.
- Nested groups are Changes, History, Branches, Remote and Stash.
- Leaf labels continue to show the exact Git command or a parameter template.
- Commit uses `git commit -m <commit-message>`; the message is read from the restored terminal with POSIX shell `read`, because no current reusable line-input command exists.
- Branch switching is a complex handler: enumerate local branches, select one through `menu`, then execute `git switch <branch>`.
- The first nested tree adds: diff staged, add all, log, show HEAD, branch list/switch, remote list/fetch/pull/push and stash list/push/pop.
- Destructive restore/reset/delete operations are not added in this work unit.

## Completed

- Mandatory preflight completed.
- Current gitman specification, implementation, manual and permanent tests inspected.
- Current command tree inspected; no reusable line-input command exists beyond one-key input.

## Current state

The runtime still exposes the four flat actions Status, Log, Branches and Diff.

## Next action

Promote the action-tree contract, implement the new handlers/submenus, update the manual/tests and validate the real gitman scope on Linux and macOS.

## Blockers / open questions

None.
