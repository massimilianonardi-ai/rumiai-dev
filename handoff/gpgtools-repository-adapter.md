# GPGTools repository adapter

Status: Active — adapter diagnostics and malformed-index fixture fix pushed to PR #14; hosted macOS ARM64 validation pending
Updated: 2026-11-08

## Goal

Implement and validate the `gpgtools` repository type for the one catalog-declared `macgpg/macos-arm64` stream.

## Current repository revisions

- `m-os/codex/gpgtools-repository-adapter@eb4e45eb6df167b6ad3780ca641f5a6d4d3abf7f` (PR #14)
- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `pkg-catalog/codex/m-os-adapter-runner@fe2e865fdd0333c9199c25b7463c2fd3947f1d34` (pins updated GPGTools PR head)
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/main@b0368f787273c3c246be0757929f3e22d5115e79`

Refresh all remote heads before the next repository write or validation.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`
- `TESTING.md`, `handoff/README.md`
- Exact pinned catalog `v1/pkg/macgpg/macos-arm64` and current m-os GitHub adapter/manual

## Fixed task-local choices

- Limit support to `macgpg/macos-arm64` at catalog anchor `2026.1+3633n`; broader versions/platforms need new evidence.
- Use the official GPGTools nightlies index and its exact artifact/hash metadata. Fail closed if the pinned stream's artifact/hash is missing or ambiguous; do not invent a historical ordering source.
- Do not modify catalog definitions or install host trust/key material.

## Acceptance scenarios

- On macOS ARM64, public exact dependency/install of `macgpg@2026.1+3633n!macos-arm64` obtains the exact official DMG with validated SHA-256 and runs the catalog-declared command path.
- A changed or missing upstream artifact/hash fails closed without publishing a partial package concrete.

## Completed

- Activated the deferred TODO into this handoff after confirming the gap against current exact master/catalog and current source inventory.

## Current state

Draft PR [#14](https://github.com/massimilianonardi-ai/m-os/pull/14) is open and unmerged at `620cf9f7a301d93a44d5702988c7bf59a8481292`. The fixture passes under `./m shell` with a fake `http-fetch` executable: the exact pin makes zero transport calls; latest/list/artifact resolution yields `2026.1+3633n`, catalog range `n0001=2026.1+3633n`, size `67104027` and SHA-256 `16fa6c1dfa6b440e900632618a6ebaac7d974c3faed3a0e14ce3d1ee6826c9c5`; malformed index rejects. `sh -n`, workflow YAML parsing and `git diff --check` pass. No hosted workflow run was visible at checkpoint; genuine macOS install/command evidence has not run.

Exact-pinned local rerun (2026-11-08): on adapter head `620cf9f7a301d93a44d5702988c7bf59a8481292` with `pkg-catalog@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`, the documented public-shell fixture command passed with its temporary directory explicitly rooted under `/m/src/git/chatgpt/tmp/gpgtools-adapter`; the fixture cleanup left no matching temp directory. This rechecked deterministic adapter logic only, not the macOS artifact/install acceptance.

Diagnostics fix (2026-11-08): the private latest-index helper now returns distinct local status 1 for transport failure and 3 for malformed index, with diagnostics `latest-index-fetch-failed` and `latest-index-invalid`; the fixture now asserts both statuses and diagnostic identities while preserving fail-closed parsing. Operational manual and fixture updated. Focused fixture and `git diff --check` passed. Commit `eb4e45eb6df167b6ad3780ca641f5a6d4d3abf7f` is pushed to PR #14; remote branch head confirmed exact. This does not close public macOS install/command acceptance or formal review.

## Next action

The updated external runner pins GPGTools head `eb4e45eb6df167b6ad3780ca641f5a6d4d3abf7f`; hosted run [42489959582](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42489959582) is active and GPGTools macOS ARM64 job `128759975222` passed at the diagnostics-fix head. This closes the scoped hosted acceptance for the new head; formal PR review remains open.

## Blockers / open questions

- Genuine macOS ARM64 install evidence is required before claiming acceptance.
