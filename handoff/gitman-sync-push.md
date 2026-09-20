# gitman sync and push shortcut

Status: Active
Updated: 2026-09-20

## Goal

Add one high-frequency gitman shortcut that stages local changes, commits them when present, integrates the configured upstream through merge semantics, and pushes the resulting branch.

## Current repository revisions

- `rumiai-dev`: `39713ec50d2775a31690d466120b27f3a487a341`
- `rumiai-os`: `1c68c242a8dd90cb9321dc3eab76a6f0319b6aa0`
- `rumiai-tests`: `aa7ff12a0ecb63ef2b83f26576df19eff424da27`

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

- The new action is a root/high-frequency shortcut.
- The sequence is: `git add --all`; if staged changes exist, acquire one commit message and run `git commit -m <commit-message>`; then `git pull --no-rebase --no-edit`; then `git push`.
- A separate `git fetch` and `git merge` are not executed because `git pull` already fetches and integrates, while `--no-rebase` fixes integration to merge semantics.
- If there are no staged changes after `git add --all`, the commit prompt and commit step are skipped.
- Any failed step stops the sequence; in particular push must not run after a failed commit or pull/conflict.
- The leaf label exposes the sequence rather than hiding it behind an opaque aggregate action name.

## Completed

- Mandatory preflight completed.
- Current gitman specification, runtime, manual and permanent tests inspected.
- Current Git pull semantics verified against current upstream Git documentation.

## Current state

The root action menu currently exposes Status, Diff, Pull and Commit followed by grouped submenus.

## Next action

Promote the shortcut contract, implement it as a complex handler, update manual/tests, and validate on the reference hosts.

## Blockers / open questions

None.
