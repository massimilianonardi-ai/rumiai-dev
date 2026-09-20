# gitman sync and push shortcut

Status: Complete
Updated: 2026-09-20

## Goal

Add one high-frequency gitman shortcut that stages and commits local changes when present, integrates the configured upstream through merge semantics, and pushes the resulting branch.

## Current repository revisions

- `rumiai-dev`: `b7abe17a370b42cf4452226745e23543545c0d16`
- `rumiai-os`: `3a5691f46a2538dad00657d47334d1d1eb0329f0`
- `rumiai-tests`: `69c97f0d7f84bde4d57e8c3b0adc0144e9591b0a`

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

- Added the root shortcut `Sync + Push: git add --all → git commit -m <commit-message> → git pull --no-rebase --no-edit → git push`.
- The workflow checks for local changes before mutating the index.
- A dirty working tree acquires the commit message before staging, then runs `git add --all` and `git commit -m`.
- A clean working tree skips message acquisition, add and commit and continues directly with pull/push.
- An empty commit message cancels before staging.
- `git pull --no-rebase --no-edit` owns fetch plus merge integration; no redundant separate fetch/merge is executed.
- Every failed step gates the remaining workflow; a failed add/commit or pull/merge prevents push.
- Refactored the Git execution path into a no-acknowledgement executor plus the existing acknowledged runner so composite workflows can execute several Git commands with one terminal acknowledgement while existing leaf behavior remains unchanged.
- Updated the canonical gitman specification and operational manual.
- Updated permanent contract coverage.
- Added real interactive coverage for dirty local + remote divergence, clean-tree shortcut behavior, and a real merge conflict that proves push is not attempted.
- Validation run `35495658548` exercised `rumiai-os` `3a5691f46a2538dad00657d47334d1d1eb0329f0` with the gitman tests from `rumiai-tests` revision `c4d40dd27d63daf6d9251bd22f70a6e25e119bfb`; the `rumiai-os/gitman` scope passed on both Ubuntu and macOS.
- The temporary validation workflow was removed. Current permanent gitman test blobs and validation pin remain unchanged from the validated task changes despite unrelated concurrent `rumiai-tests` advances.
- Final consistency review confirmed specification, runtime, manual, contract coverage and interactive tests agree on the shortcut sequence and that no redundant fetch step is present inside the composite handler.
- Concurrent unrelated repository changes were preserved forward-only.

## Current state

The shortcut is implemented, documented and protected by permanent tests. The root menu now has five quick actions before the grouped submenus.

Physical validation was not performed. Validation evidence is GitHub-hosted Ubuntu/macOS evidence for the revisions recorded above.

## Next action

None for this task.

## Blockers / open questions

None.
