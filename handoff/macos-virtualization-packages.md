# Apple Silicon virtualization packages

Status: Active
Updated: 2026-10-26

## Goal

Add reusable `utm` and `tart` package definitions to `pkg-catalog` for `macos-arm64`. Validate as much as possible without macOS, then complete real installation and operational tests on the user's MacBook Air M4.

## Current repository revisions

- `rumiai-dev`: `6c0cf0bbef14166eb629ddfed9aa1577616e5a97` (pre-task)
- `pkg-catalog`: `6a324426f11d151bb43945579d8dd018674dee48` (current main HEAD, with unrelated independent `mk` package); UTM/Tart validated at ancestor `202dbf9de5381bd08951aa4853b7229518a9e870` (command source modes corrected from `e8679ece70b523c7798bc4cc10bfd450810fcf64`)
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
- Physical evidence from user terminal (2026-10-26): isolated checkout `/var/folders/j3/7n86j9ld6w379sxlpfc2k1g80000gn/T/rumiai-utm-tart.39szGU/m`; bootstrap `osarch update/show` -> `macos-arm64`, UTM and Tart install statuses `PASS`, `utmctl help version` displayed expected help, `tart --version` printed `2.41.1`. Repo HEAD `cf3660ca0e206f94d0c8292b2b2cabeb096703ef`. No code signing, GUI control, guest VM start, package cleanup or filesystem state persistence was tested on this host yet.

- Physical follow-up on the same user-owned MacBook Air M4 (macOS 27.0.1 ARM64, 2026-10-26): the isolated `m` checkout HEAD was confirmed as `cf3660ca0e206f94d0c8292b2b2cabeb096703ef` and the actual cached `pkg-catalog` HEAD as `8a346e9c1b30fa40706213cf9798720d7ffd39ff`. `m pkg default utm` selected `utm@v5.0.8!macos-arm64`; `m pkg default tart` selected `tart@2.41.1!macos-arm64`. Physical `codesign --verify --deep --strict` returned 0 for both bundles, and Tart's `Contents/embedded.provisionprofile` existed. `m tart list` returned 0 with no VM records; `open "$utm_app"` returned 0 and the user explicitly confirmed the UTM GUI opened. `m utmctl version` returned `5.0.8` and `m utmctl list` returned a table header with no VM records, demonstrating successful CLI-to-application communication from the managed bundle outside `/Applications`. No guest VM was created, started, stopped or destroyed. Physical `df -h "$HOME"` showed the root Data volume at 97% occupancy, with only 7.3 GiB available, making new full macOS guest images impractical without additional storage. This checkpoint is installation/GUI/CLI/signing validation, **not** VM lifecycle validation.

## Current state

The autonomous `m` installation and integration of both UTM and Tart on physical MacBook Air M4 / macOS 27.0.1 ARM64 is now validated at `m` HEAD `cf3660ca0e206f94d0c8292b2b2cabeb096703ef` and actual cached catalog `8a346e9c1b30fa40706213cf9798720d7ffd39ff`. Both bundle signatures, both selected defaults, Tart provisioning, Tart CLI version/list, and UTM GUI opening, `utmctl version` and `utmctl list` passed. This resolves the UTM out-of-`/Applications` GUI/AppleScript-CLI integration concern for the tested host/revision. The outstanding physical acceptance is real guest VM create/start/control/stop plus appropriate lifecycle/state preservation; **only 7.3 GiB of disk remains free**, so avoid heavy VM disk/image downloads until external storage or adequate safe free space is available. The isolated package roots and any existing user VM data must be preserved. Prior GitHub Actions runs remain separate, revision-specific evidence. No product code was changed.

## Next action

Before attempting any guest VM test, obtain sufficient safe disk capacity or use a suitable external SSD and confirm where the hypervisor stores guest images. Current host availability is only 7.3 GiB (97% full). Do not blindly delete files or download a macOS image to the system volume. When storage is available, create an explicitly named disposable test guest, run isolated start/stop/control tests in Tart and UTM, and inspect any app-specific permissions or VM-state effects. Do not delete, modify, or start the user's pre-existing VM data; use a unique test identity and verify its ownership before cleanup. Then assess install/uninstall and durable VM-state preservation, record exact host/product/catalog/test revisions, and perform proportional final validation. Close handoff only after the required physical lifecycle evidence and final consistency gate. A later macOS 15 GitHub Actions retry is optional and must not override physical Mac evidence.

## Blockers / open questions

- The physical macOS ARM64 host has now confirmed UTM GUI and managed `utmctl` integration plus Tart non-destructive CLI behavior. VM guest boot/lifecycle remains untested, and macOS system volume has only 7.3 GiB free (97% occupied). Adequate storage is required before full VM image/guest testing.
- Upstream UTM location sensitivity remains a general portability concern on other hosts, but it did not prevent physical UTM GUI and `utmctl version/list` from working in this exact managed installation on macOS 27.0.1.
- Upstream release bytes were downloaded, integrity-checked and extracted via actual `m pkg` on both macOS 15 and macOS 26, with complete latest package workflows proven on macOS 26 run `40311244938` attempt 2. Subsequent macOS 15 retry hit anonymous GitHub API rate limits again.
