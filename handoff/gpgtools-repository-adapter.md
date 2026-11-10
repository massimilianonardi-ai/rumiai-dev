# GPGTools repository adapter

Status: Active — deterministic adapter fixture passes; public macOS ARM64 installation and hosted validation remain pending
Updated: 2026-11-10

## Goal

Complete bounded `gpgtools` support for the existing `macgpg/macos-arm64` catalog stream and validate it through public `m` commands on macOS ARM64.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/gpgtools-repository-adapter@eb4e45eb6df167b6ad3780ca641f5a6d4d3abf7f` (draft PR #14)
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/codex/c2-account-defaults@d18a40f99602f3153830c1b3564c0d4a397f594e`

Refresh remote heads before further work.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `handoff/README.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- The current `m-os` repository-adapter interface and operational manual
- `pkg-catalog/v1/pkg/macgpg/macos-arm64` at the pinned catalog revision

## Fixed scope

- Support only the catalog-declared `gpgtools` type for `macgpg/macos-arm64`.
- Preserve the current pinned artifact contract and fail closed when live metadata changes unexpectedly.
- Keep all local writes under `/m/src/git/chatgpt`.
- No privileged install or workflow execution unless the separate operator-privileged TODO is explicitly reactivated.

## Acceptance scenarios

- Public exact dependency/install resolves the catalog pin and verifies artifact metadata on macOS ARM64.
- Public latest resolution reads the live listing and preserves the catalog's version-range meaning.
- Malformed listing and upstream fetch failure produce distinct expected statuses and diagnostics.

## Completed

- PR #14 contains the adapter, manual, deterministic fixture and macOS workflow; remote head matches local audited commit `eb4e45e`.
- `sh -n` for the adapter and fixture and `git diff --check` passed at the exact PR head.
- The first fixture invocation failed because the m-os clone has no embedded `catalog/` checkout. Rerunning at the same exact source with `GPGTOOLS_FIXTURE_CATALOG` pointed to the fresh `pkg-catalog/main@0b69223a` checkout passed: `PASS: GPGTools fixture parsing, exact anchor, live latest, artifact metadata and distinct upstream failure diagnostics`.
- No product source was changed during this validation.

## Current state

- The fixture is deterministic and uses a fake `http-fetch`; it does not validate network availability or install the package.
- Local exact PR refs are confirmed. Hosted workflow status could not be confirmed by the prior audit because repository lookups returned 404; do not infer PASS from workflow configuration.
- The adapter is absent from `m-os/master` and remains unsupported on the product mainline.

## Next action

Locate exact PR #14 workflow status through the canonical repository, then run only nonprivileged public resolution checks. The configured real install step must remain excluded because it invokes package installation and may perform privileged materialization. Complete the required public macOS ARM64 installation only under the separate authorized operator path.

## Blockers / open questions

- Public macOS ARM64 installation has not been validated on this Linux host.
- Hosted PR status and exact workflow completion remain unverified.
