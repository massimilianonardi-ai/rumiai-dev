# Rename independent m GitHub repository to m-os

Status: Complete
Updated: 2026-11-03

## Goal

Realign the current RumiAI repository references after the operator renamed
`massimilianonardi-ai/m` to `massimilianonardi-ai/m-os`. The technical
runtime, public command `m`, `m_ROOT`, and semantic layer identity `m`
remain unchanged.

## Current repository revisions

At preflight:
- `m-os/master@ff55fc9f220f8da3f1f90d1bf4aa2e46c55a5d2a`
- `m-os/pkg-schema-v2@8c8397dbcf1df44822553aebd1891ab6db880945`
- `pkg-catalog/main@759127c79c576cacb22ba0c4bb55d4746279e0f3`
- `pkg-catalog/pkg-schema-v2@ece6c076911ee22aa54453611e0832263712e213`
- `m-mk/main@4880b4676ed6d7f46965a41f7e9b3d4d867ddf18`
- `m-jsc/main@952b97dd291cf178362f541129640f3375841b04`
- `rumiai-dev/main@c02b74ecf1ef423da723bcfbfdd72d5bb5a0ef5b` after concurrent unrelated TextEdit commits.
- `rumiai-os/main@9b8df602d7a84d452af1114aa508da5cde2f38c4` and
  `rumiai-tests/main@0c7edbbbf94a3fbea7c9fc3d3021021edba9f758` at initial scan; neither requires a source change on known workflow references.

At completion review (2026-11-03):
- `m-os/master@ff55fc9f220f8da3f1f90d1bf4aa2e46c55a5d2a`
- `m-os/pkg-schema-v2@8c8397dbcf1df44822553aebd1891ab6db880945`
- `pkg-catalog/main@35b230d44d9e45ad2fb1e7473a838f5a485cf81a`
- `pkg-catalog/pkg-schema-v2@56398be0661d395e0fd07af018da0a1bffbf0235`
- `m-mk/main@8c857460213199eeb4c5c070b4df60c885df376f`
- `m-jsc/main@ca1b70d1e0c53e790244f28b67bcf2a2b7528c76`

All named source revisions retain forward-only ancestry. The separate
`rumiai-dev` and frozen-product tasks advanced concurrently without rollback.

## Applicable canonical sources

`README.md`, `RULES.md`, `CONSISTENCY-GATE.md`,
`specifications/README.md`,
`specifications/rumiai-os/{CURRENT-MODEL,PACKAGE-MODEL}.md`,
`DEVELOPMENT.md`, `TESTING.md`, `handoff/README.md`.

## Fixed task-local choices

The operator has already completed the GitHub repository rename.
Only the repository name changed, not technical identifiers or layout.
Preserve branch heads and any unrelated concurrent updates, forward-only.
Pre-rename historical command/validation evidence must not be rewritten
as evidence of a post-rename run.

## Acceptance scenarios

1. `m-os` resolves as the same repository with preserved `master`
   and `pkg-schema-v2` commit identities.
2. Active GitHub Actions checkout declarations referencing the old
   `massimilianonardi-ai/m` repository use `massimilianonardi-ai/m-os`.
3. Current canonical documentation explicitly identifies repository `m-os`
   and preserves the semantic `m` name.
4. Verify revision-specific validation or accurately report which
   workflows remain pending or cannot execute.
5. Audit active task handoff current-state pointers; preserve historical
   validation evidence and avoid touching unrelated workstreams.

## Completed

- Confirmed GitHub repository identity, default branch and both preserved HEADs.
- Inspected canonical rules/specs, active-handoff ownership and checkout consumers.
- Confirmed concurrent unrelated TextEdit and m-boot commits on `rumiai-dev`; no rollback.
- Updated the old `repository: massimilianonardi-ai/m` checkout identity
  to `repository: massimilianonardi-ai/m-os` in one v1 catalog workflow
  and seven v2 catalog checkout sites, plus two mk and three jsc sites.
- Confirmed by reading every changed workflow at final branch revisions:
  13 exact renamed checkouts, zero remaining exact old-repository checkout
  declarations in the changed paths. The distinct `m-mk` and `m-jsc`
  projects were preserved.
- Realigned canonical `rumiai-dev` repository roles and source
  ownership in `README.md`, `RULES.md`,
  `specifications/rumiai-os/CURRENT-MODEL.md` and
  `specifications/rumiai-os/PACKAGE-MODEL.md` without changing technical
  runtime identifiers.
- Added rename routing notes to active autonomous-m validation,
  package-v2, and source-composition handoffs; historical test evidence
  was left revision-specific.
- Confirmed authentic GitHub-hosted checkouts of `m-os` in catalog,
  mk and jsc workflows; the renamed catalog's real Ollama service
  run `41656568773` is **PASS**, v1 Ubuntu catalog run
  `41656476677` is **PASS** on Ubuntu, and v2 matrix
  `41656568757` has six completed PASS plus four queued macOS jobs.
- Classified unrelated post-checkout failures accurately rather than
  claiming a full suite PASS: v2 Node run `41656569243` has an
  incomplete closing `]` in the existing shell workflow assertion;
  mk/jsc hosted Ubuntu jobs fail inside `pkg-depend`/install exact
  dependency resolution using current m-os/master. These findings are
  owned by the respective active validation handoffs; macOS jobs were
  still queued at this checkpoint.
- Reviewed changed-file diffs and current canonical sources, confirmed
  no product code or public command/manual interface was changed, and
  preserved forward-only Git history. No physical-host validation was
  performed for this repository-name-only change.

## Current state

The repository rename and its source-reference realignment are complete.
All observed affected workflow checkouts reach the renamed repository.
The surrounding functional validation remains revision-specific and is
not a prerequisite for adopting the new repository name.

## Next action

None for the repository rename. The separate active v2 package and
autonomous-m validation handoffs own outstanding functionality checks
and the still-queued macOS jobs.

## Blockers / open questions

None requiring an operator decision.
