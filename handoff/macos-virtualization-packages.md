# Apple Silicon virtualization packages

Status: Active
Updated: 2026-10-26

## Goal

Add reusable `utm` and `tart` package definitions to `pkg-catalog` for `macos-arm64`. Validate as much as possible without macOS, then complete real installation and operational tests on the user's MacBook Air M4.

## Current repository revisions

- `rumiai-dev`: `6c0cf0bbef14166eb629ddfed9aa1577616e5a97` (pre-task)
- `pkg-catalog`: `202dbf9de5381bd08951aa4853b7229518a9e870` (source command modes corrected from initial `e8679ece70b523c7798bc4cc10bfd450810fcf64`)
- `rumiai-os`: `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195` (inspected; no modification planned)
- `rumiai-tests`: `89641269b80fc740dfce03b0764ee9e6e49c84e4` (new macOS live tests and Actions workflow; initial test revision `039e8114497e0a9651d231678716f96b9f447358`)

Always recheck HEADs before resuming.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `handoff/README.md`
- `specifications/README.md`, `specifications/rumiai-os/CURRENT-MODEL.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`, `specifications/rumiai-os/STATE-MODEL.md`.
- Current `rumiai-os` GitHub repository adapter, extraction, integration and launch implementation; existing `pkg-catalog` macOS examples.

## Fixed task-local choices

- Apple Silicon only: `macos-arm64`; do not add `macos-x86_64`.
- Define distinct `utm` and `tart` packages using the existing `github` adapter and built-in `dmg` / `tar.gz` materialization. No Homebrew or independent installation model.
- Initial verified upstream stable tags (2026-10-26): `utm@v5.0.8` (`UTM.dmg`, GitHub SHA-256 `7b2d7b2e2a02b3de1757ef19a8f36573e6d9cceae8c8cca0abcbcaa4a852019a`) and `tart@2.41.1` (`tart.tar.gz`, GitHub SHA-256 `e680a734febccfce7d4e910c1f7f13fc3b00f19a181c945e2d746de3214c32c2`).
- Preserve upstream app bundles; do not patch upstream binaries/signatures or store user VM data in immutable package roots.

## Acceptance scenarios

1. An initialized Apple Silicon `m` host installs `utm` through `m pkg install utm`, selects a package default with `m pkg default`, validates UTM.app code signing and local `m utmctl` help; real version/XPC/GUI operation remains a distinct host-session check.
2. `m pkg install tart` materializes `tart.app`; after selecting the installed package default, `m tart --version` works with its embedded provisioning profile intact.
3. Neither installation creates guest VMs or deletes pre-existing user VM state. VM start/control can subsequently be tested via each upstream CLI.

## Working design / risk

- UTM documentation warns that `utmctl` has different launch behavior when its bundle is outside `/Applications`. Validate the packaged direct bundle path under the actual `m` launcher before claiming full CLI support.
- Physical macOS checks are necessary for `hdiutil` DMG contents, signature/notarization, bundle registration, GUI/CLI startup, permissions, headless/SSH and guest VM lifecycle.
- No product-contract change or additional package-manager abstraction is authorized/required by this task.

## Completed

- Verified release assets and SHA-256 metadata through official upstream GitHub APIs.
- Inspected current catalog conventions and core package adapter/launcher.
- Committed 20 files to `pkg-catalog` as `e8679ece70b523c7798bc4cc10bfd450810fcf64`: GitHub repository descriptors, two platform-specific range anchors, SHA-256 verification settings, source-format selectors and standard native `m` launchers/links (`utm`, `utmctl`, `tart`).
- Original source command file modes `100755` proved invalid in real macOS installation. Corrected all three `cmd/` source blobs to `100644` (commit `202dbf9de5381bd08951aa4853b7229518a9e870`), matching the existing `pkg` integration contract; integration materializes executable commands after validating non-executable sources.
- On the available Linux container, POSIX `/bin/sh -n` passed for the standard UTM/Tart wrapper templates; their exact generated text was separately matched against the committed catalog command blobs. This validates syntax only, not actual `m` package launch.
- Real GitHub Actions Apple Silicon macOS validation was added under `rumiai-tests/tests/external/{utm,tart}/install-live.test` and `.github/workflows/utm-tart-packages.yml`, invoking real `m pkg` and uploading test artifacts. The first runs were blocked by runner checkout-origin normalization; subsequent runs diagnosed and corrected source command modes.
- In Actions run `40310600488`, macOS 15.7.9 ARM64: UTM `v5.0.8` real install/default/Info.plist/Mach-O ARM64/codesign PASS; GUI/AppleScript-dependent `utmctl version` failed under headless hosted runner, and complete UTM test did not pass. Tart `2.41.1` real install/default/Info.plist/Mach-O ARM64/codesign/entitlements/`m tart --version`/uninstall PASS.
- macOS 26.6.2 ARM64 run was blocked at upstream GitHub Release API with HTTP 403 and `x-ratelimit-remaining: 0`; this is an actual anonymous API quota exhaustion for shared runner IPs, not a proved package defect. Actions run `40311244938` confirmed this with raw `x-ratelimit-*` headers. Job re-execution after reset has been requested and must be checked before making new claims.
- The latest test revision `89641269b80fc740dfce03b0764ee9e6e49c84e4` separates local UTM CLI help (asserted) from `utmctl version` (observed but not claimed to work on headless runners). These specific changes have not yet been verified past the API-rate-limit blocker.

## Current state

Both package definitions are published with corrected command-source modes. Real GitHub macOS 15 tests validated Tart end-to-end and UTM through signing but not AppleScript-dependent CLI operation. macOS 26 is blocked by the transient GitHub API rate limit. No `rumiai-os` production code was changed. Physical MacBook Air M4 VM lifecycle validation remains pending.

## Next action

First reconcile any newly finished GitHub Actions retry (run `40311244938` attempt 2), identify precise macOS 26 result and UTM CLI help outcome, and refine proportionally if needed. On MacBook Air M4 validate UTM GUI/AppleScript (`utmctl version` outside `/Applications`), notarization/Gatekeeper interactions, Tart entitlements with a real guest, headless/SSH, and minimal VM create/launch, then update/uninstall state preservation.

## Blockers / open questions

- No user-owned physical `macos-arm64` test host is available today; GitHub Actions provided genuine macOS ARM64 execution but not nested virtualization or physical host confirmation.
- UTM upstream describes location-sensitive behavior for `utmctl` outside the standard `/Applications` install. The generic managed-root executable target has not been verified in an actual GUI session.
- Upstream release bytes were downloaded, integrity-checked and extracted via actual `m pkg` on macOS 15, as evidenced by Actions run `40310600488` (Tart full PASS; UTM up to code signing PASS). Further hosted runner attempts hit anonymous GitHub API rate limits.
