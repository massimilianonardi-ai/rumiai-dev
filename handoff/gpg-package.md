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
- Physical macOS ARM64 checkpoint on the user's Mac at `rumiai-os` `9f254d470fd238852e63570044127d5559da768a` succeeded for the real public path: `pkg install macgpg` completed, the MacGPG and pinentry Payloads reported `79697` and `1459` cpio blocks respectively, and repeated `gpg --version` invocations reported `gpg (GnuPG/MacGPG2) 2.5.21` with HOME under RumiAI package state. This physically confirms download, DMG/flat-pkg extraction, overlay materialization, integration/publication and basic command launch on the user's host.
- The first physical non-loopback pinentry attempt on the same Mac reached the configured RumiAI pinentry path but failed with `gpg: problem with the agent: No pinentry`; no output file was created. This established that the prior direct `pinentry-program` plus package-level `DYLD_LIBRARY_PATH` did not survive the `gpg-agent -> pinentry` process boundary on the physical host.
- Corrected the package-specific runtime so `gpg` materializes a private pinentry wrapper under the MacGPG package `run` state. The wrapper resolves the stable MacGPG selector, sets `DYLD_LIBRARY_PATH` immediately before execing `pinentry-mac`, and the agent config points to this wrapper rather than the Mach-O directly. The broad package-environment `DYLD_LIBRARY_PATH` export was removed.
- The launcher migrates both the historical GPG Suite `/usr/local/MacGPG2/.../pinentry-mac` line and the previous direct RumiAI selector pinentry line to the managed wrapper while preserving unrelated custom pinentry configuration.
- Permanent live coverage now launches the managed pinentry wrapper without caller-supplied DYLD state and verifies migration from the previous direct RumiAI pinentry path.
- Formal macOS ARM64 validation run 21 completed successfully on 2026-09-24 for `rumiai-tests` `8e5e2344f1885e2a5b9bc50ec8f3e831e003f4ef`, `rumiai-os` `9f254d470fd238852e63570044127d5559da768a` and current MacGPG catalog runtime `d1ceb7b3b095846c67d08a17d3074e60c9e579d9`: all four MacGPG scope tests PASS and the scope result is `VALIDATED`.
- A second physical non-loopback attempt after reinstalling the corrected catalog confirmed migration to `pinentry-program "<RumiAI state>/pkg/macgpg/run/pinentry"`, but the operation still failed with `gpg: problem with the agent: No pinentry`; therefore the direct-Mach-O/DYLD inheritance defect was not the complete physical-host cause.
- Strengthened the macOS hosted validation to place its disposable environment under a `TMPDIR` containing a literal space and strengthened the live MacGPG test to require the managed pinentry wrapper to complete an Assuan startup/`BYE` exchange, not only `--version`.
- Formal macOS ARM64 validation run 23 completed successfully on 2026-09-24 for `rumiai-tests` `b88b8e7abfce3c8802fd7e64d30546fbf60f7f19` and `rumiai-os` `9f254d470fd238852e63570044127d5559da768a`: all MacGPG scope tests PASS and the scope result is `VALIDATED` while the validation temp path contains a space. This rules out spaced-path parsing/quoting and basic Assuan wrapper startup as explanations for the physical-only failure.

## Current state

The portable MacGPG package path is now formally validated on macOS ARM64 through the real public install pipeline and the official pinned GPG Suite DMG.

The generic `dmg-pkg` overlay mechanism, catalog metadata, package integration, pinentry runtime relocation and GnuPG agent configuration are aligned. The live validation installs the package without system-wide GPG Suite installation, observes the relocated `pinentry-mac`, starts and queries the relocated agent, and generates a real test key.

GitHub-hosted macOS ARM64 validation is complete for the corrected agent-safe pinentry wrapper, including a spaced execution path and an Assuan wrapper handshake. The user's physical Mac passes installation and basic `gpg` launch but still fails when `gpg-agent` launches pinentry non-loopback. The remaining work is now physical-host diagnosis of the concrete `assuan_pipe_connect` failure logged by `gpg-agent`; no further speculative package change should be made before that evidence.

## Next action

On the user's physical Mac, use the already-installed current package with a short temporary `GNUPGHOME` to (1) execute the managed pinentry wrapper directly through a non-interactive Assuan `BYE` handshake and (2) enable `gpg-agent` verbose logging, restart the agent, reproduce the non-loopback symmetric-encryption failure, and read the resulting agent log. Use that concrete failure to determine the next package correction. After the interactive physical path passes, perform the final consistency gate, mark this handoff Complete, commit the final snapshot, then remove the handoff in a later forward commit.

## Blockers / open questions

- Physical macOS ARM64 diagnosis of why `gpg-agent` cannot connect to a wrapper that passes hosted Assuan startup remains pending; installation and basic command launch already passed physically.
