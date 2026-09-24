# Portable MacGPG package

Status: Active
Updated: 2026-09-24

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
- Extended the generic `dmg-pkg` contract implementation end-to-end for declarative component overlays: `pkg install` now passes overlay metadata through to `pkg_extract`, integration validates the same overlay envelope, and the operational manuals describe the current six-argument form.
- Added the MacGPG `pinentry_Core.pkg` as a catalog overlay targeting `libexec`. Real-package validation established that its Payload contains `pinentry-mac.app` at Payload root, so no overlay payload-root is required.
- The live package test then exposed the remaining relocation issue: `pinentry-mac` links against `/usr/local/MacGPG2/lib/libassuan.9.dylib`. The MacGPG package environment now exports the package root `lib` through `DYLD_LIBRARY_PATH`, avoiding Mach-O rewriting or system-wide installation.
- The public `gpg` launcher now ensures the active GNUPGHOME has a relocatable `pinentry-program` pointing through the stable RumiAI package selector to the packaged `pinentry-mac`. An existing custom pinentry is preserved; the historical GPG Suite `/usr/local/MacGPG2/.../pinentry-mac` line is migrated.
- Permanent coverage now validates synthetic overlay materialization, overlay metadata integration, real pinentry dylib resolution, relocatable agent configuration, relocated agent startup/query and real key generation through the live package path.
- Formal macOS ARM64 validation run 20 completed successfully on 2026-09-24 for `rumiai-tests` `280c0af57c84e95c91630983e2fc738354ce4a84` and `rumiai-os` `50cb1a6734f74bc8faa5296189e60c0e9cdc8bc0`: repository-adapter contract PASS, `pkg-extract/dmg-pkg.test` PASS, `pkg-integration/contract.test` PASS, `external/macgpg/install-live.test` PASS, scope result `VALIDATED`. The intervening `rumiai-os` advancement after the package changes only touched `rsudo.lib.sh` and was preserved.

## Current state

The portable MacGPG package path is now formally validated on macOS ARM64 through the real public install pipeline and the official pinned GPG Suite DMG.

The generic `dmg-pkg` overlay mechanism, catalog metadata, package integration, pinentry runtime relocation and GnuPG agent configuration are aligned. The live validation installs the package without system-wide GPG Suite installation, observes the relocated `pinentry-mac`, starts and queries the relocated agent, and generates a real test key.

GitHub-hosted macOS ARM64 validation is not the final physical-host checkpoint. A retry on the user's physical Mac remains pending before this task can be closed under `PHYSICAL-TESTING.md`.

## Next action

Update the physical macOS ARM64 checkout to current committed HEADs and retry the composed user path:

```text
./m
pkg uninstall macgpg   # only if an older failed/superseded concrete is present
pkg install macgpg
gpg --version
```

Then exercise one operation that reaches the normal agent/pinentry path without `--pinentry-mode loopback` so the packaged GUI pinentry is observed on the physical desktop. If that physical checkpoint passes, perform the final consistency gate, mark this handoff Complete, commit the final snapshot, then remove the handoff in a later forward commit.

## Blockers / open questions

- Physical macOS ARM64 validation of the now-formally-validated portable pinentry path remains pending.
