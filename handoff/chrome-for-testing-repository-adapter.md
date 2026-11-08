# Chrome for Testing repository adapter

Status: Active — implementation authorized by the m-os completion request; fresh source review and branch work in progress
Updated: 2026-11-08

## Goal

Implement and validate the catalog-declared `chrome-for-testing` repository type for its existing `chromium/linux-arm64` stream, preserving the other Chromium streams and shared adapter behavior.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/main@b0368f787273c3c246be0757929f3e22d5115e79`

Refresh all remote heads before the next repository write or validation.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`
- `TESTING.md`, `handoff/README.md`
- Exact pinned catalog `v1/pkg/chromium/linux-arm64` and current m-os Chromium adapter/manual

## Fixed task-local choices

- Limit support to the existing CfT `chromium/linux-arm64` stream anchored at `153.0.8010.12`; preserve the other five `chromium` repository streams.
- Use official Chrome for Testing stable metadata for version/channel identity and platform artifact URL; use Cloud Storage response metadata for positive size and validated MD5 according to the catalog contract.
- Do not add a new catalog stream or mutate the catalog.

## Acceptance scenarios

- Public exact dependency/install for `chromium@153.0.8010.12!linux-arm64` resolves the declared CfT artifact and installs it with integrity validation.
- Public unversioned dependency/install resolves the actual current Stable Linux ARM64 artifact through the same declared stream and exposes the catalog's Chromium command.

## Completed

- Activated the deferred TODO into this handoff after confirming the gap against current exact master/catalog and current source inventory.

## Current state

No implementation branch or PR has been published yet. Work is scoped to the adapter, its library manual and focused genuine-public validation. The owning source-composition and overall M10/M01–M15 ledgers need checkpoint updates after evidence changes.

## Next action

Inspect current CfT adapter contracts, catalog anchor and HTTP metadata behavior; implement in an isolated `m-os` branch, validate fixture and public exact/latest Linux ARM64 paths, then publish a draft PR with all evidence and remaining platform/hosted gates stated.

## Blockers / open questions

- Confirm which Cloud Storage metadata are available through the current `http-fetch` API and the exact checksum representation/decoding required by the catalog's MD5 contract.
- Stable latest and exact asset equivalence must be proven against current official metadata; do not assume Chromium project version semantics are identical to CfT build-version semantics.
