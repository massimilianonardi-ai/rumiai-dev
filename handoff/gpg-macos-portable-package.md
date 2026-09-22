# GPG portable package for macOS

Status: Active
Updated: 2026-09-22

## Goal

Add a macOS Apple Silicon `gpg` package to the current RumiAI package model, using the official GPGTools distribution without system installation and keeping package state isolated through the existing package launcher/state model.

## Current repository revisions

- rumiai-dev: 197fca75b9fd52ae4e6e464bdb8ceaf3fe332ac6
- rumiai-os: 78f1ebf6f11d40f2f722ae3f37875118cbda8015
- rumiai-tests: 874c84ab48fc09866a31db94fd293fbff8ef7c8a
- pkg-catalog: 64d67a73f4f9485749e1b47712e42f77afb4773e

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- specifications/README.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
- specifications/rumiai-os/STATE-MODEL.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md

## Fixed task-local choices

- Initial package target is `macos-arm64`.
- Upstream distribution is GPGTools GPG Suite; the installer is extracted, never executed.
- Mutable GnuPG state uses the existing package HOME/state model rather than the immutable package root.
- The package must compensate for MacGPG helper paths compiled under `/usr/local/MacGPG2` where a supported runtime override exists.

## Working design

- Introduce a generic package materialization format for a DMG containing a macOS installer package: expand the package payloads without running installer scripts and merge them into a virtual filesystem root.
- Introduce an optional safe relative extraction-root selector so a catalog range may retain only one subtree of that virtual filesystem root before integration.
- Use the selector `usr/local/MacGPG2` for GPGTools so MacGPG and its separately packaged pinentry payload converge into one useful root.
- Add a GPGTools repository adapter for current-version/artifact resolution.
- Expose wrapper commands that override relocatability-sensitive GnuPG helper paths dynamically.

These are task-local working choices until promoted through the specification consistency gate.

## Completed

- Initial preflight completed.
- Current package/catalog/runtime/test surfaces inspected.
- Current GPGTools/MacGPG build and installer layout investigated.
- Confirmed that merely copying the MacGPG payload is not sufficient for full relocatability because helper paths are compiled under `/usr/local/MacGPG2`.

## Current state

No product/catalog/test modification has been made yet. The task is ready to implement the smallest generic extraction/root-selection support plus the GPG package definition.

## Next action

1. Implement and document the generic package extraction/root-selection support in `rumiai-os`.
2. Add proportional permanent tests in `rumiai-tests`.
3. Add the GPGTools adapter and `gpg/macos-arm64` catalog definition.
4. Run the consistency gate and validate what can be executed on the available host.

## Blockers / open questions

- Full macOS runtime validation of the upstream DMG requires a macOS host with `hdiutil` and `pkgutil`; non-macOS validation can cover syntax, catalog structure and generic behavior but cannot prove the final GPGTools binary execution path.
