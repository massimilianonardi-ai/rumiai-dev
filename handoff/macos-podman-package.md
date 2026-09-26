# macOS Podman package

Status: Active
Updated: 2026-09-26

## Goal

Implement a non-invasive RumiAI `pkg podman` for macOS arm64 using the exact official Podman installer payload without installing Podman into the host system.

## Current repository revisions

- rumiai-dev: ff1a9421adf625973cb5ada8ed5f959a234f3435
- rumiai-os: 4f429c811f9c19889d0d8f6fa42b0423356beecd
- pkg-catalog: da9b8989088c8b3f2d8201ad09e5f7180f334a16
- rumiai-tests: e30ef19cabe1d2c1511fe49db23c8d7b89feff11
- rumiai-dev-PoCs: 94e2d6a385236a081815b0a700b7c2b2be0c92bd

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- RUNNER.md
- TEST-PATTERNS.md
- specifications/README.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- handoff/README.md

## Fixed task-local choices

- Scope is macOS arm64 only; do not add a Linux Podman package.
- Use the official Podman macOS release artifact and preserve its shipped binaries unchanged.
- Do not run the installer's preinstall/postinstall scripts and do not modify `/opt`, `/etc/paths.d`, system manpaths or install `podman-mac-helper` into the host.
- Runtime helper discovery must point to the managed package root using a Podman-supported mechanism rather than patching the binaries.
- The package should remain relocatable under the existing `pkg` model and use package-owned HOME/state.
- Product/catalog changes are authorized by the user's current instruction to proceed with the macOS Podman package.

## Working design

The official v6.1.2 arm64 installer is a signed flat product `.pkg` whose component payload contains the `podman` tree normally installed at `/opt/podman`. The current package extractor supports `dmg-pkg` but not a direct flat product package.

The smallest general extension is expected to add a direct macOS flat-package materialization format that reuses the existing validated component/payload extraction semantics without executing installer scripts.

For Podman runtime helper lookup, `CONTAINERS_HELPER_BINARY_DIR` is supported by the upstream containers configuration library and can point directly at the relocated package `bin` directory. This avoids generating or mutating a host-level `containers.conf`.

## Completed

- PoC 037 proved that the exact official Podman v6.1.2 arm64 payload remains signed and can complete `podman machine init` after relocation when helper lookup is redirected.
- Fresh mandatory preflight completed for the implementation task.

## Current state

No product, catalog or permanent-test implementation changes have been made yet for this task.

## Next action

1. Finalize the smallest generic flat-`.pkg` extraction contract and implementation.
2. Add proportional permanent extractor tests and manual/spec updates.
3. Add the macOS arm64 Podman catalog definition using the official GitHub release.
4. Add and run live package validation on macOS.

## Blockers / open questions

- Whether the current GitHub repository adapter can consume the Podman release asset and release digest without any adapter change.
- Whether `podman machine start` can be physically validated in this work unit; hosted macOS CI cannot provide nested virtualization.
