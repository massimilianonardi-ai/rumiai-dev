# Portable MacGPG package

Status: Active
Updated: 2026-09-23

## Goal

Add a macOS Apple Silicon package definition that installs the MacGPG engine from the official GPG Suite distribution as a relocatable managed package and exposes the `gpg` command without installing GPG Suite system-wide.

## Current repository revisions

```text
rumiai-dev   6e3cd138a654a4800f4da77525cff51a3534486c
rumiai-os    a15ef6171e614a4862df0e2da4d40a5375eefc45
rumiai-tests 78c4c770150ce6ef70677b8895c2ab0588395c0f
pkg-catalog  da7507439b71737cf4a40d85cac059824e4b9a63
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
- Provider-specific component identity remains catalog data; generic package code does not hardcode `MacGPG2.pkg`.
- The catalog pins GPG Suite 2026.1 build 3633n with its official SHA-256 rather than scraping mutable release HTML at install time.

## Completed

- Mandatory preflight and forward-concurrency reconciliation completed.
- Promoted generic `dmg-pkg` compound materialization to `specifications/rumiai-os/PACKAGE-MODEL.md`.
- Implemented `DMG -> flat pkg -> named component -> Payload` materialization in the package extraction path.
- Added `component` package-range validation and install orchestration.
- Added the GPGTools repository adapter and mandatory operational manuals.
- Added `pkg/macgpg/macos-arm64` catalog data for GPG Suite 2026.1 (3633n), SHA-256 `16fa6c1dfa6b440e900632618a6ebaac7d974c3faed3a0e14ce3d1ee6826c9c5`, component `MacGPG2.pkg`, and command target `bin/gpg`.
- Added permanent adapter coverage, a real macOS synthetic `dmg-pkg` materialization test, and a live external `pkg install macgpg` / `gpg --version` validation test.
- Final static consistency reread corrected the artifact regex and collision-safe private extraction staging.
- A physical macOS ARM64 install attempt on 2026-09-23 reached the real GPG Suite DMG download but failed in generic `extract dmg`: `hdiutil attach ... -mountpoint <RumiAI state path>` returned `Permission denied`. The failure occurred before package integration, so no `gpg` command was published.
- Corrected generic macOS DMG extraction in `rumiai-os` to avoid a custom mount point. Modern macOS now uses `diskutil image ... -plist`, resolves exactly one mounted entity from structured plist output, copies with `ditto`, and ejects the image device. Older macOS retains an `hdiutil -plist` fallback without a forced mount point.
- Static shell syntax validation of the modified DMG block passed; the existing real macOS `dmg-pkg` and live MacGPG tests remain the required physical regression validation.

## Current state

The original package/catalog design remains unchanged. The physical failure identified a generic macOS DMG backend defect rather than a MacGPG-specific defect. The defect is corrected at `rumiai-os` revision `a15ef6171e614a4862df0e2da4d40a5375eefc45`.

The operational `extract` manual remains accurate because the public command contract and supported formats did not change; only the host-specific native DMG backend changed. The existing permanent `dmg-pkg` test exercises this real path on macOS and should now protect the regression.

Physical validation of the corrected revision is still pending.

## Next action

Update the physical macOS ARM64 checkout to the corrected `rumiai-os` revision and retry the real composed path:

```text
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

- Physical macOS ARM64 validation of the corrected DMG backend remains pending.
