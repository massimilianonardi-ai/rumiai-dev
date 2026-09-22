# Portable MacGPG package

Status: Active
Updated: 2026-09-22

## Goal

Add a macOS Apple Silicon package definition that installs the MacGPG engine from the official GPG Suite distribution as a relocatable managed package and exposes the `gpg` command without installing GPG Suite system-wide.

## Current repository revisions

```text
rumiai-dev   2eb63fab51db6eb943c75167b758fcf071a5e5a8
rumiai-os    364e57d1c0f2eca9ff2578c6b1a0a13fbe83eeb7
rumiai-tests 3088682fd298ee84953c55bc56beb7d207a2cb45
pkg-catalog  6a77995d317f2ec08c98585c4462b92557ccfaea
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

## Current state

Implementation, specification, catalog, manuals and permanent tests are aligned at the revisions above. Upstream release identity/digest was rechecked against the official GPGTools hotfix publication. The current execution environment cannot perform the real macOS DMG mount/install path, and direct artifact download from this environment was unavailable.

## Next action

Run the new macOS ARM64 validation tests against these revisions, especially:

```text
tests/rumiai-os/pkg-extract/dmg-pkg.test
tests/external/macgpg/install-live.test
```

If they pass, perform the final task consistency checkpoint and complete/remove this handoff according to the handoff lifecycle.

## Blockers / open questions

- Physical macOS ARM64 validation remains pending.
