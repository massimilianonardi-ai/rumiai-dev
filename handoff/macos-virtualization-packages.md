# Apple Silicon virtualization packages

Status: Active
Updated: 2026-10-26

## Goal

Add reusable `utm` and `tart` package definitions to `pkg-catalog` for `macos-arm64`. Validate as much as possible without macOS, then complete real installation and operational tests on the user's MacBook Air M4.

## Current repository revisions

- `rumiai-dev`: `6c0cf0bbef14166eb629ddfed9aa1577616e5a97` (pre-task)
- `pkg-catalog`: `e8679ece70b523c7798bc4cc10bfd450810fcf64` (two package definitions published; pre-task HEAD `73c0cd7003802ce120c693c9427b22f1141a2f8b`)
- `rumiai-os`: `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195` (inspected; no modification planned)
- `rumiai-tests`: `039e8114497e0a9651d231678716f96b9f447358` (no modification planned)

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

1. An initialized Apple Silicon `m` host installs `utm` through `m pkg install utm`, selects a package default with `m pkg default`, and then launches `m utmctl version` / the UTM UI from the managed application bundle.
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
- Post-change review verified that all three `cmd/` blobs have executable Git modes `100755`, metadata blobs `100644`, correct `macos-arm64` placement and canonical launcher script content. Live GitHub release assets were rechecked: names, published upload state, stable tags and expected SHA-256 digests match. The current catalog main HEAD was rechecked at the new commit.
- No native extraction, code-signing, Gatekeeper, launcher or VM test was run; the current execution environment is Linux without a macOS host, and external release downloads were unavailable in the local container.

## Current state

Both package definitions are published. Catalog metadata / file-mode / upstream-release checks passed, but macOS runtime validation is pending. No new `rumiai-os` feature, adapter, package facility or test runner was introduced.

## Next action

When an Apple Silicon macOS host is available, validate `m pkg install` for each package (artifact download, digest, extraction, immutable bundle layout); select defaults explicitly and validate `m utm`, `m utmctl version`, `m tart --version`, notarization/codesign, UTM location-dependent CLI behavior and Tart entitlements. Then test minimal VM creation/launch, update/uninstall state preservation, and add only durable permanent coverage justified by real behavior.

## Blockers / open questions

- No actual `macos-arm64` test host is available today.
- UTM upstream describes location-sensitive behavior for `utmctl` outside the standard `/Applications` install. The generic managed-root executable target has not been verified in an actual GUI session.
- Upstream release archives themselves were not fetched/extracted on Linux: static release-API digest metadata is not a substitute for artifact-byte SHA-256 verification.
