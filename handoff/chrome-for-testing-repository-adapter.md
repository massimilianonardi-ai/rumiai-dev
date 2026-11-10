# Chrome for Testing repository adapter

Status: Active — implementation and live exact/latest artifact resolution pass on Linux ARM64; public installation acceptance requiring setuid-root is deferred
Updated: 2026-11-10

## Goal

Complete the bounded `chrome-for-testing` adapter for the existing `chromium/linux-arm64` catalog stream, with exact and Stable-latest resolution and real public package installation evidence.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/chrome-for-testing-adapter@8703b99251c680feaa61a09b1d3109bb5d69c33a` (draft PR #16)
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/codex/c2-account-defaults@eb027766cd47f6f3fabf6b98bd0da9b8659e2b25`

Refresh each remote head before writing or validating.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `TESTING.md`, `handoff/README.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md` (repository adapters, artifact integrity, package installation)
- Current `m-os` repository-adapter interfaces and command/library manuals
- `pkg-catalog/v1/pkg/chromium/linux-arm64` at the pinned catalog revision

## Fixed scope

- Implement only the catalog-declared `chrome-for-testing` type for `chromium/linux-arm64`.
- Preserve the other five Chromium streams and their existing `chromium` adapter.
- Use official Chrome for Testing metadata and Cloud Storage artifact metadata; do not infer versions by numeric or semantic sort.
- Do not install host packages or alter host browser/trust state. Keep all local writes under `/m/src/git/chatgpt`.

## Acceptance scenarios

- Public exact and unversioned dependency resolution select the catalog anchor and current Stable artifact, respectively.
- Public exact and unversioned `pkg install` verify size/digest, integrate the package, and expose the expected Chromium command.
- Existing non-CfT Chromium streams continue to use their existing adapter without regression.

## Completed

- Draft PR #16 contains the adapter, manual, deterministic fake-transport fixture and Ubuntu ARM64 public install workflow.
- At `m-os@8703b992`, exact `153.0.8010.12` and Stable latest `157.0.8103.38` metadata were previously verified; latest Cloud Storage metadata reported positive size `195926016` and MD5 `72f3441dd3fde1ccdb2ef2ddcc8d5de0`.
- The fixture covers exact/latest, checksum conversion, malformed name/size/MD5, archive mismatch and digest type rejection. `sh -n` and `git diff --check` were recorded passing in PR #16.
- On a fresh exact clone of `m-os@8703b99251c680feaa61a09b1d3109bb5d69c33a` with `pkg-catalog@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`, the deterministic fixture, `sh -n`, public manual discovery, and public exact/unversioned `pkg depend` requests passed. The live adapter resolved exact `153.0.8010.12` and Stable latest `157.0.8103.50`; exact artifact metadata was size `195926016`, MD5 `72f3441dd3fde1ccdb2ef2ddcc8d5de0`; latest was size `203292807`, MD5 `3959697c82ed88bf331124fa986a48f8`.
- A public exact `./m pkg install 'chromium@153.0.8010.12!linux-arm64'` stopped during integration at `setuid-materialization-failed` (status 18), because catalog `setuid_root` handling required `sudo chown 0:0` and `chmod 4755`. Sudo rejected authentication before applying either operation; the isolated package store has no integrated concrete. The unversioned install was not attempted because it reaches the same privileged materialization. No workaround or hosted privileged workflow was run.

## Current state

- PR #16 is open/draft, based on exact master `a78a24bd...`; no hosted result is available for its head.
- The host is Linux ARM64, matching the only catalog stream in this task. Live exact/latest planning and artifact metadata are verified; public install/command execution is pending the separately deferred privileged materialization.
- The adapter is not present on master. Do not report the catalog product as supported from this draft branch or its metadata-only PASS.

## Next action

Keep PR #16 draft/unmerged with the exact install limitation stated. The adapter's nonprivileged work is recorded; only continue full install acceptance if the separate privileged TODO is reactivated. Do not retry via a hosted workflow that performs root ownership/setuid changes. Hosted and any platform evidence outside the Linux ARM64 stream remain separate.

## Blockers / open questions

- Exact hosted public-install workflow status is not available; native m-os Actions currently returns no runs for feature heads. That workflow also performs the same privileged setuid-root integration, so it is explicitly deferred.
- No additional catalog platform stream or migration of existing Chromium streams is authorized by this task.
