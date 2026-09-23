# Portable MacGPG package

Status: Active
Updated: 2026-09-23

## Goal

Add a macOS Apple Silicon package definition that installs the MacGPG engine from the official GPG Suite distribution as a relocatable managed package and exposes the `gpg` command without installing GPG Suite system-wide.

## Current repository revisions

```text
rumiai-dev   887c99819114a328d61e820543106be5e6677667 (parent of this handoff update)
rumiai-os    6db7c00e77c25946c46342900fa21038f2d9f290
rumiai-tests a1138610ca5a7a747e3226c7e45aa5feec2c1c53
pkg-catalog  8e32f2dc3e471c38da087dc69db06050abdd7c4e
```

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
handoff/README.md
```

## Fixed task-local choices

- The concrete package identity is `macgpg`; it exposes the public package command `gpg`.
- The upstream distribution is GPGTools MacGPG carried inside the official GPG Suite DMG.
- Mutable GnuPG state uses the existing package HOME/state model rather than the immutable package root.
- Provider-specific component identity remains catalog data; generic package code does not hardcode a GPGTools component name.
- The catalog pins GPG Suite 2026.1 build 3633n with its official SHA-256 rather than scraping mutable release HTML at install time.

## Completed

- Mandatory preflight and forward-concurrency reconciliation completed.
- Promoted generic `dmg-pkg` compound materialization to `specifications/rumiai-os/PACKAGE-MODEL.md`.
- Implemented `DMG -> flat pkg -> named component -> Payload` materialization in the package extraction path.
- Added `component` package-range validation and install orchestration.
- Added the GPGTools repository adapter and mandatory operational manuals.
- Added `pkg/macgpg/macos-arm64` catalog data for GPG Suite 2026.1 (3633n), SHA-256 `16fa6c1dfa6b440e900632618a6ebaac7d974c3faed3a0e14ce3d1ee6826c9c5`, component `MacGPG2.1_Core.pkg`, and command target `bin/gpg`.
- Added permanent adapter coverage, a real macOS synthetic `dmg-pkg` materialization test, and a live external `pkg install macgpg` / `gpg --version` validation test.
- Final static consistency reread corrected the artifact regex and collision-safe private extraction staging.
- A physical macOS ARM64 install attempt on 2026-09-23 reached the real GPG Suite DMG download but failed in generic `extract dmg`: `hdiutil attach ... -mountpoint <RumiAI state path>` returned `Permission denied`. The failure occurred before package integration, so no `gpg` command was published.
- Corrected generic macOS DMG extraction in `rumiai-os` to avoid a custom mount point. Modern macOS now uses `diskutil image ... -plist`, resolves exactly one mounted entity from structured plist output, copies with `ditto`, and ejects the image device. Older macOS retains an `hdiutil -plist` fallback without a forced mount point.
- Static shell syntax validation of the modified DMG block passed; the existing real macOS `dmg-pkg` and live MacGPG tests remain the required physical regression validation.
- A second physical macOS ARM64 install attempt at `a15ef6171e614a4862df0e2da4d40a5375eefc45` confirmed that native DMG mounting/copying now succeeds; failure moved into `pkg-extract dmg-pkg`.
- Rechecked the real GPG Suite package shape. The outer package is `Install.pkg`; the MacGPG component identity used by GPG Suite is `MacGPG2.1_Core.pkg`, and its flat-package `Payload` is gzip-compressed cpio rather than the raw cpio used by the original synthetic test.
- Corrected the MacGPG catalog component to `MacGPG2.1_Core.pkg`.
- Extended generic `dmg-pkg` extraction to accept both raw cpio and gzip-compressed cpio Payloads while preserving the existing path-safety validation before extraction.
- Updated the `pkg-extract.lib.sh` operational manual for gzip-compressed Payload support.
- Updated the permanent macOS `dmg-pkg` fixture to use `Install.pkg`, `MacGPG2.1_Core.pkg` and a gzip-compressed cpio Payload, so the physical regression is represented mechanically.

## Current state

The first physical defect (forced custom DMG mount point) is fixed and the second physical run demonstrated that the corrected native DMG path reaches the compound flat-package extraction stage.

The second defect was a mismatch between the synthetic fixture and the real GPG Suite installer shape: wrong component metadata plus an uncompressed synthetic Payload. Implementation, catalog, manual and permanent test are now aligned with the real flat-package structure at the revisions above.

No new package-model semantic is required: the canonical `dmg-pkg` contract already requires extraction of the selected component's Payload without constraining the installer-internal compression encoding.

Physical validation of the corrected component/Payload path is still pending.

## Next action

Update the physical macOS ARM64 checkouts to the corrected `rumiai-os` and `pkg-catalog` revisions and retry the real composed path from an `m` shell:

```text
./m
pkg install macgpg
gpg --version
```

Then run, or otherwise use as formal regression evidence, the existing macOS tests:

```text
tests/rumiai-os/pkg-extract/dmg-pkg.test
tests/external/macgpg/install-live.test
```

If the corrected physical path passes, perform the final task consistency checkpoint and complete/remove this handoff according to the handoff lifecycle.

## Blockers / open questions

- Physical macOS ARM64 validation of the corrected component name and compressed Payload handling remains pending.
