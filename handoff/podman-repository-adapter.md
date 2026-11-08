# Podman repository adapter

Status: Active — adapter/manual/workflow committed locally; live metadata and hosted macOS ARM64 validation pending
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

Local branch `m-os/codex/podman-repository-adapter@b1ca4d2266cc5b44dbf3331655878441c41833ef` contains the adapter, manual and macOS 15 ARM64 public-path workflow; it is not pushed and has no PR. `sh -n`, workflow YAML parsing, `git diff --check` and validation of the pinned catalog repository descriptor pass. Live GitHub API lookup returned HTTP 403, so latest and exact asset metadata are **pending**, not PASS. No package installer or host service was run. Genuine flat-package extraction and command execution require the hosted macOS workflow.

Boundary incident: an executor accidentally created `/tmp/podman-sh.out` outside the user's allowed `/m/src/git/chatgpt` root. The executor was instructed not to access or modify that file again; no cleanup was attempted because it would itself write outside the authorized root. All subsequent work stayed in the isolated checkout under the allowed root.

## Next action

Publish a draft PR and run the macOS ARM64 workflow after an upstream retry window; keep HTTP 403 classified as acquisition pending and record the actual artifact/install outcome.

## Blockers / open questions

- The live GitHub API returned 403 during local evidence collection; no latest or exact artifact PASS is claimed.
- Genuine macOS ARM64 package install evidence remains required.
