# GPGTools repository adapter

Status: Active — deterministic fixture and public exact/latest dependency resolution pass; macOS ARM64 installation and hosted validation remain pending
Updated: 2026-11-10

## Goal

Complete bounded `gpgtools` support for the existing `macgpg/macos-arm64` catalog stream and validate it through public `m` commands on macOS ARM64.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/gpgtools-repository-adapter@eb4e45eb6df167b6ad3780ca641f5a6d4d3abf7f` (draft PR #14)
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/codex/c2-account-defaults@8acd9889015995857905176677e5cb3e230bfd1a` (pre-update checkpoint; refresh before next write)

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
- On Linux ARM64, the exact adapter checkout's public `./m pkg depend 'macgpg@2026.1+3633n!macos-arm64'` exited 0 against catalog main `0b69223a`. Public latest request `./m pkg depend 'macgpg!macos-arm64'` also exited 0 after the disposable test clone's catalog cache was placed on tracking branch `main`; the package has no declared dependencies, so both plans emitted no dependency rows. An initial latest attempt failed in the isolated harness because its detached catalog cache had no upstream branch; no product change was made. This demonstrates public exact/latest planning on this host and catalog revision, not artifact download, installation, or CLI execution.
- No product source was changed during this validation.

## Current state

- The fixture is deterministic and uses a fake `http-fetch`; it does not validate network availability or install the package. Public dependency planning succeeded for exact and latest requests, but does not prove artifact download or installation.
- Local exact PR refs are confirmed. The read-only GitHub audit found no PR-triggered workflow run for exact head `eb4e45e`; do not infer hosted PASS from workflow configuration.
- The adapter is absent from `m-os/master` and remains unsupported on the product mainline.

## Next action

Complete exact public package installation, default/version listing, and `m gpg --version` on macOS ARM64 through a nonprivileged path, then inspect exact PR #14 checks again. Do not claim adapter support on `m-os/master` until the feature is reviewed and integrated through the authorized path.

## Blockers / open questions

- Public macOS ARM64 installation has not been validated on this Linux host.
- Hosted PR status and exact workflow completion remain unverified.
