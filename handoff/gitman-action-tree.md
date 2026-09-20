# gitman action tree

Status: Active
Updated: 2026-09-20

## Goal

Build the first extensible Git action tree on the current gitman handler model, keeping a small high-frequency root and moving related operations into nested menus.

## Current repository revisions

- `rumiai-dev`: `c370e84bcf3bc2db0c6750ee00b60a9c32bc04ed`
- `rumiai-os`: `56bfd26e1c59d040fcf2bffe5a823c071e78bda9`
- `rumiai-tests`: `ff093420a279cbd4f418c2f0061b11dd59632f09`

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
- Promoted the root/submenu action tree and parameter-acquisition semantics to the canonical gitman specification.
- Implemented the root actions and Changes, History, Branches, Remote and Stash handlers.
- Implemented terminal commit-message acquisition and local-branch selection for git switch.
- Updated the operational manual.
- Updated permanent contract coverage and added interactive scenarios for submenu navigation plus Add all, Commit, Push, Switch and stash push/pop.
- Updated the gitman validation target to rumiai-os `56bfd26e1c59d040fcf2bffe5a823c071e78bda9`.
- Preserved concurrent unrelated advances in rumiai-dev and rumiai-tests.

## Current state

Specification, runtime, manual and permanent tests now describe/implement the new tree. Validation has not yet been executed against the new revisions.

## Next action

Run the real `rumiai-os/gitman` scope on Linux and macOS, fix any regressions, then run the final consistency gate.

## Blockers / open questions

None.
