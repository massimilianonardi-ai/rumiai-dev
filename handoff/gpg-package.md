# Portable MacGPG package

Status: Complete
Updated: 2026-09-24

## Goal

Add a macOS Apple Silicon package definition that installs the MacGPG engine from the official GPG Suite distribution as a relocatable managed package and exposes the `gpg` command without installing GPG Suite system-wide.

## Current repository revisions

```text
rumiai-dev   8bba59b678147f9e8ce8915277f12d6a5b0418a6 (parent of final Complete snapshot)
rumiai-os    352d48a0c85d8496dbaca2d5f00806de455999ab
rumiai-tests a24135dd28513f37c3165f90d62f1e1edabc420c
pkg-catalog  da9b8989088c8b3f2d8201ad09e5f7180f334a16
```

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/STATE-MODEL.md
PHYSICAL-TESTING.md
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
- The live package test exposed that upstream `pinentry-mac` carries MacGPG-local Mach-O dependencies rooted at `/usr/local/MacGPG2`. An initial `DYLD_LIBRARY_PATH` relocation attempt passed hosted validation but was later disproved by physical-host evidence and is no longer part of the current package.
- The public `gpg` launcher ensures the active GNUPGHOME has a managed relocatable `pinentry-program`. Existing unrelated custom pinentry configuration is preserved, while known superseded GPG Suite/RumiAI-managed pinentry paths are migrated forward.
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
- Physical diagnosis on the user's Mac then executed the managed wrapper directly and reproduced the real loader failure: dyld ignored the wrapper-supplied `DYLD_LIBRARY_PATH` for the signed/hardened `pinentry-mac` and aborted while loading `/usr/local/MacGPG2/lib/libassuan.9.dylib`. The corresponding agent log showed `assuan_pipe_connect` ending with EOF and GnuPG mapping that failure to `No pinentry`.
- Replaced the DYLD-based wrapper with a regenerable package-cache copy of `pinentry-mac.app`. The launcher copies the upstream app and MacGPG dylib closure into the package `cache` state, rewrites MacGPG-local absolute and `@rpath` dependencies to `@loader_path/<basename>`, removes stale `/usr/local/MacGPG2` runpaths, rewrites dylib IDs, and ad-hoc signs/verifies the resulting bundle. The immutable concrete root is never modified and no system-wide path is created.
- The cached app is stamped with the selected concrete root and is reused only when its stamp, signature and Mach-O load/runpath checks remain valid. Superseded run-state wrapper/app artifacts are removed. Known previous managed pinentry configurations are migrated to the cached executable.
- Permanent live coverage now checks the complete cached Mach-O closure: no copied executable/dylib may retain a `/usr/local/MacGPG2` load command or runpath; copied libraries must exist; the main executable must use loader-relative package libraries; deep code-sign verification, `--version`, Assuan startup/`BYE`, managed-config migration, relocated agent startup/query, and real key generation all remain covered.
- Intermediate hosted runs intentionally caught and corrected four portability defects before another physical attempt: oversized absolute install-name replacement, non-portable macOS `chmod --`, transitive `@rpath` dependency resolution, and duplicate universal-binary `LC_RPATH` deletion.
- Formal macOS ARM64 validation run 27 attempt 4 completed successfully on 2026-09-24 for `rumiai-tests` `a24135dd28513f37c3165f90d62f1e1edabc420c`, `rumiai-os` `4938f6f4e60e0053f30b4ab31092fc0537401ec1`, and catalog `da9b8989088c8b3f2d8201ad09e5f7180f334a16`: repository-adapter PASS, `pkg-extract/dmg-pkg.test` PASS, `pkg-integration/contract.test` PASS, `external/macgpg/install-live.test` PASS, scope result `VALIDATED`. The workflow also executes with a temp path containing a literal space.

- Final physical macOS ARM64 confirmation on the user's Mac at `rumiai-os` `c1059a76449409d0b059fac4b521da8b161cb76c` passed the final cached Mach-O pinentry path: the cached pinentry executable reported only loader-relative MacGPG library dependencies, deep code-sign verification succeeded, a direct Assuan `BYE` exchange returned `OK`, the graphical non-loopback symmetric-encryption operation completed, and `test.gpg` was created. This is the physical evidence for the interactive pinentry property.
- The current `rumiai-os` HEAD `352d48a0c85d8496dbaca2d5f00806de455999ab` differs from that physically exercised revision only by a one-line `core.lib.sh` exit-code parser correction that does not touch the package, state, launcher, Mach-O or pinentry surfaces. The physical PASS remains attributed to `c1059a76449409d0b059fac4b521da8b161cb76c` rather than relabelled.
- Final hosted macOS ARM64 task validation rerun (workflow run 27 attempt 5) completed successfully on 2026-09-24 for `rumiai-tests` `a24135dd28513f37c3165f90d62f1e1edabc420c` and current `rumiai-os` `352d48a0c85d8496dbaca2d5f00806de455999ab`: repository-adapter PASS, `pkg-extract/dmg-pkg.test` PASS, `pkg-integration/contract.test` PASS, `external/macgpg/install-live.test` PASS, scope result `VALIDATED`.

## Current state

Complete. The portable MacGPG package is implemented and validated for macOS ARM64 through the real GPG Suite artifact and RumiAI package pipeline.

The package installs MacGPG plus the required pinentry component without system-wide GPG Suite installation, relocates the pinentry Mach-O dependency closure into regenerable package cache state, preserves the immutable concrete root, configures package-owned GnuPG state, and exposes `gpg` through the normal package launcher. Hosted validation passes on the current product/test revisions and the final non-loopback graphical pinentry path passed on the user's physical Mac.

No task-local working design or unresolved blocker remains.

## Next action

None. Remove this completed handoff from the current tree in the required later forward commit.

## Blockers / open questions

None.
