# Rename independent m GitHub repository to m-os

Status: Active
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

Refresh every involved HEAD before modifications.

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
- Confirmed concurrent unrelated TextEdit commits on `rumiai-dev`; no rollback.

## Current state

Relaignment of current checkout workflow references and documentation pending.

## Next action

Update affected current workflow checkouts and repository-role documentation;
scan the changes for stale old URLs, run proportional CI, synchronize
active handoff pointers, finish the consistency gate.

## Blockers / open questions

None requiring an operator decision.
