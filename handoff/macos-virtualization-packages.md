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
- On macOS 26.6.2 ARM64 the run `40311244938`, job `121534675747` (attempt 2, suite `89641269b80fc740dfce03b0764ee9e6e49c84e4`, catalog `202dbf9de5381bd08951aa4853b7229518a9e870`, runtime `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`) passed both real tests: UTM install/default/bundle/ARM64/codesign/local `utmctl help version`/uninstall and Tart install/default/bundle/ARM64/codesign/entitlements/`m tart --version`/uninstall. UTM `utmctl version` was recorded as **UNVERIFIED** because it relies on the GUI/AppleScript session. `rumiai-tests` evidence artifact: `utm-tart-macos-26-40311244938-2` (ID `12644958731`), with per-test logs. No VM was created.
- macOS 15.7.9 ARM64 run `40310600488` demonstrated successful UTM installation/signature and full Tart PASS on previous test revision. A later retry of `40311244938`, job `121535679420`, failed before artifact resolution for both products because the shared GitHub runner IP `13.105.117.75` again had `x-ratelimit-remaining: 0` and HTTP 403. This is an external API quota blocker, not a product regression. The latest `utmctl help version` test revision did not complete on macOS 15.
- The latest test revision `89641269b80fc740dfce03b0764ee9e6e49c84e4` separates local UTM CLI help (asserted PASS on macOS 26) from `utmctl version` (observed as UNVERIFIED under headless runner). No result asserts GUI or guest VM behavior.

## Current state

Both package definitions are published with corrected command-source modes. Latest complete macOS 26 ARM64 CI PASS for both packaged command workflows, UTM `utmctl version` not verified, and guest VM execution excluded (nested virtualization unavailable). Previous macOS 15 validates Tart end-to-end and UTM installation/signature but recent run is blocked by shared anonymous GitHub API quota. No `rumiai-os` product code changed. Physical MacBook Air M4 GUI/VM validation remains pending.

## Next action

When feasible, re-run macOS 15 ARM64 with sufficient GitHub API quota to verify latest UTM local CLI help; avoid confusing anonymous HTTP 403 with package defects. On MacBook Air M4 validate UTM GUI/AppleScript (`utmctl version` outside `/Applications`), notarization/Gatekeeper behavior, Tart virtualization entitlements with a real guest, headless/SSH, and minimal VM create/launch, then update/uninstall state preservation. Close handoff only after applicable physical validation and final consistency gate.

## Blockers / open questions

- No user-owned physical `macos-arm64` test host is available today; GitHub Actions provided genuine macOS ARM64 execution but not nested virtualization or physical host confirmation.
- UTM upstream describes location-sensitive behavior for `utmctl` outside the standard `/Applications` install. The generic managed-root executable target has not been verified in an actual GUI session.
- Upstream release bytes were downloaded, integrity-checked and extracted via actual `m pkg` on both macOS 15 and macOS 26, with complete latest package workflows proven on macOS 26 run `40311244938` attempt 2. Subsequent macOS 15 retry hit anonymous GitHub API rate limits again.
