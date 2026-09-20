# gitman action tree

Status: Complete
Updated: 2026-09-20

## Goal

Build the first extensible Git action tree on the current gitman handler model, keeping a small high-frequency root and moving related operations into nested menus.

## Current repository revisions

- `rumiai-dev`: `990b9add8fd96354305499edbbf6d7e3af14d478`
- `rumiai-os`: `56bfd26e1c59d040fcf2bffe5a823c071e78bda9`
- `rumiai-tests`: `39b4efaee8c12a82be8bc10c2d77f01668610885`

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

## Completed

- Added the small root action set: Status, Diff, Pull and Commit.
- Added Changes, History, Branches, Remote and Stash submenus.
- Added leaf actions for staged diff, add all, log, show HEAD, branch list, remote list/fetch/pull/push and stash list/push/pop.
- Added commit-message acquisition from the restored terminal and `git commit -m <commit-message>`.
- Added local-branch enumeration, branch selection through `menu` and `git switch <branch>`.
- Kept menu labels descriptive only; Git execution still uses explicit shell argument vectors.
- Updated the canonical specification and the operational manual.
- Updated permanent contract and interactive coverage.
- Interactive coverage exercises submenu navigation plus real Add all, Commit, Push, Switch and stash push/pop behavior against local Git repositories/remotes.
- Validation run `35492257989` exercised `rumiai-os` `56bfd26e1c59d040fcf2bffe5a823c071e78bda9` with `rumiai-tests` `0e8949b0b1e7a06eb2b2ff67233c3df229d6c9c9`; the `rumiai-os/gitman` scope passed on both Ubuntu and macOS.
- The temporary validation workflow was removed after the successful run. The current permanent gitman test blobs are unchanged from the successful validation revision.
- Final consistency review reread the task diffs and current specification/runtime/manual/tests, found no residual old flat Branches label or old read-only contract in the affected surfaces, and confirmed the validation target remains pinned to the validated product revision.
- Concurrent unrelated changes in `rumiai-dev` and `rumiai-tests` were preserved forward-only.

## Current state

The action tree is implemented, documented and protected by permanent tests. The currently delivered root and grouped actions match the canonical gitman specification.

Physical validation was not performed. Validation evidence is GitHub-hosted Ubuntu/macOS evidence for the revisions recorded above.

## Next action

None for this task.

## Blockers / open questions

None.
