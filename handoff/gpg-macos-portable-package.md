# GPG portable package for macOS

Status: Complete
Updated: 2026-09-25

## Goal

Provide a relocatable macOS Apple Silicon GNU GnuPG package through the current RumiAI package model, using the GPGTools distribution without system installation and keeping mutable GnuPG state under the existing package/state model.

## Current repository revisions

Final task-state checkpoint:

```text
rumiai-dev    da58ede73cb5264a7add861a11e68107f463eb45  (pre-final-snapshot HEAD)
rumiai-os     b66891732a99addbacba574aaf53779284319e16  (current HEAD)
rumiai-tests  318500723ee2674d951b9ab5a8df584adcd2db08
pkg-catalog   da9b8989088c8b3f2d8201ad09e5f7180f334a16
```

Formal closure evidence is revision-specific to `rumiai-os@baee6bf1b356d4855ab3eaf390ca8ee64f86508c`. The later product delta to `b668917...` is rsudo-only and is not relabelled as validation evidence.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/STATE-MODEL.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
```

## Completed

- Generic `dmg-pkg` materialization, validated payload-root selection and explicit overlay support are part of the current package model.
- The GPGTools repository adapter is implemented in `rumiai-os` with its operational manual and permanent contract coverage.
- `pkg-catalog` contains the current `macgpg/macos-arm64` definition, GPGTools source metadata, MacGPG payload selection, Pinentry overlay and public `gpg` command.
- The public MacGPG wrapper keeps mutable state under the package state model and relocates/caches Pinentry plus required Mach-O libraries without retaining `/usr/local/MacGPG2` load paths/runpaths.
- Permanent live coverage validates package installation, public `gpg`, relocated agent/helper execution, Pinentry Assuan startup, cache/configuration migration, codesigning and Mach-O relocatability.
- Added the composed `external/macgpg/enc-live.test` consumer check so the package is also exercised by the RumiAI `enc.lib.sh` consumer through the real public `gpg` path.
- Formal validation `20260925T153805+0000-1309` on hosted Darwin 26.6.2 / arm64 used `rumiai-tests@318500723ee2674d951b9ab5a8df584adcd2db08` and `rumiai-os@baee6bf1b356d4855ab3eaf390ca8ee64f86508c`. The selected GPGTools adapter, `dmg-pkg` extraction, package integration, live MacGPG install/runtime and MacGPG-backed enc integration tests all passed; aggregate status was 0.

## Current state

The original package goal is implemented and mechanically covered. MacGPG is a usable current `macos-arm64` package and the original stale handoff statement that no product/catalog/test modification existed is superseded by the current repositories.

## Next action

None.

## Blockers / open questions

None.
