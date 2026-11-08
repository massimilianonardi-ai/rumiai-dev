# Podman repository adapter

Status: Active — implementation authorized by the m-os completion request; fresh source review and branch work in progress
Updated: 2026-11-08

## Goal

Implement and validate the Podman repository type for the catalog's single macOS ARM64 package stream.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/main@b0368f787273c3c246be0757929f3e22d5115e79`

Refresh all remote heads before the next repository write or validation.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`
- `TESTING.md`, `handoff/README.md`
- Exact pinned catalog `v1/pkg/podman/macos-arm64` and current m-os GitHub adapter/manual/extractor

## Fixed task-local choices

- Limit support to the catalog-declared Podman v6.1.2 macOS ARM64 installer and its declared SHA-256, flat-package extraction and `podman` command link.
- Do not imply Linux/Windows support or broaden the catalog stream.
- Preserve package-integrity and failed-install cleanup behavior of the existing public `pkg install` pipeline.

## Acceptance scenarios

- On macOS ARM64, public exact/latest dependency resolution for the catalog stream and `pkg install podman@v6.1.2!macos-arm64` install the genuine official artifact, verify integrity and expose the declared `podman` command.
- Corrupt/mismatched metadata or an unavailable exact asset fails closed without a partial installed concrete.

## Completed

- Activated the deferred TODO into this handoff after confirming the gap against current exact master/catalog and current source inventory.

## Current state

No implementation branch or PR has been published yet. Current local host is Linux ARM64; genuine flat-package extraction and command execution acceptance requires macOS ARM64 hosted or physical validation. Do not install a system Podman runtime or alter host services.

## Next action

Inspect the exact catalog package/range and current flat-package extractor support, then implement the smallest adapter/manual/workflow on an isolated `m-os` branch; publish a draft PR with local and hosted evidence clearly scoped.

## Blockers / open questions

- Confirm whether the current public extractor accepts the exact catalog flat-package format on macOS ARM64 without changing shared extraction semantics; escalate to A3/P2 ownership if not.
- Genuine macOS ARM64 package install evidence remains required.
