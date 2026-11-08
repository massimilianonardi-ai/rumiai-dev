# GPGTools repository adapter

Status: Active — implementation authorized by the m-os completion request; fresh source review and branch work in progress
Updated: 2026-11-08

## Goal

Implement and validate the `gpgtools` repository type for the one catalog-declared `macgpg/macos-arm64` stream.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/main@b0368f787273c3c246be0757929f3e22d5115e79`

Refresh all remote heads before the next repository write or validation.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`
- `TESTING.md`, `handoff/README.md`
- Exact pinned catalog `v1/pkg/macgpg/macos-arm64` and current m-os GitHub adapter/manual

## Fixed task-local choices

- Limit support to `macgpg/macos-arm64` at catalog anchor `2026.1+3633n`; broader versions/platforms need new evidence.
- Use the official GPGTools nightlies index and its exact artifact/hash metadata. Fail closed if the pinned stream's artifact/hash is missing or ambiguous; do not invent a historical ordering source.
- Do not modify catalog definitions or install host trust/key material.

## Acceptance scenarios

- On macOS ARM64, public exact dependency/install of `macgpg@2026.1+3633n!macos-arm64` obtains the exact official DMG with validated SHA-256 and runs the catalog-declared command path.
- A changed or missing upstream artifact/hash fails closed without publishing a partial package concrete.

## Completed

- Activated the deferred TODO into this handoff after confirming the gap against current exact master/catalog and current source inventory.

## Current state

No implementation branch or PR has been published yet. Current local host is Linux ARM64, so source/fixture work can proceed here but genuine install acceptance requires a macOS ARM64 hosted or physical environment. No host keychain or trust store should be changed.

## Next action

Inspect current GitHub adapter/manual, exact catalog entry and official index semantics; implement a bounded adapter/manual and macOS ARM64 workflow on an isolated `m-os` branch, then publish a draft PR and report hosted execution requirements.

## Blockers / open questions

- The official index is not a version history; confirm that the adapter contract and catalog's exact version behavior can be implemented without claiming unsupported listing/ordering semantics.
- Genuine macOS ARM64 install evidence is required before claiming acceptance.
