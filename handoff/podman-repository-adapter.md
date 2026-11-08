# Podman repository adapter

Status: Active — adapter/manual/catalog/runner changes published on draft branches; deterministic fixture PASS; live GitHub API and macOS ARM64 artifact validation blocked by repeated HTTP 504
Updated: 2026-11-08

## Goal

Implement and validate the Podman repository type for the catalog's single macOS ARM64 package stream.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`; PR #15 branch `codex/podman-repository-adapter@35e2d090660ebc940458e78aad9be3fc81ee7c62`
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`; candidate catalog branch `codex/podman-current-catalog@c8a39f8bd099d65ed8520de574800f220d6119e1`
- runner `pkg-catalog/codex/m-os-adapter-runner@37a873b546ff3865bb1364ba77b56fcf69588a14`
- `rumiai-dev/main@d559434c4af661c886bdd7884d9db9348a752f0f`; orchestration work branch is forward-only and includes the concurrent main update.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`
- `TESTING.md`, `handoff/README.md`
- Exact pinned catalog `v1/pkg/podman/macos-arm64` and current m-os GitHub adapter/manual/extractor

## Fixed task-local choices

- Limit support to the catalog-declared Podman macOS ARM64 installer and its declared SHA-256, flat-package extraction and `podman` command link. The catalog candidate advances the stale v6.1.2 anchor to verified official stable v6.1.4; exact v6.1.3 remains in the catalog supported range.
- Do not imply Linux/Windows support or broaden the catalog stream.
- Preserve package-integrity and failed-install cleanup behavior of the existing public `pkg install` pipeline.

## Acceptance scenarios

- On macOS ARM64, public exact/latest dependency resolution for the catalog stream installs the genuine official exact v6.1.3 and latest v6.1.4 artifacts, verifies integrity and exposes the declared `podman` command.
- Corrupt/mismatched metadata or an unavailable exact asset fails closed without a partial installed concrete.

## Completed

- Activated the deferred TODO into this handoff after confirming the gap against current exact master/catalog and current source inventory.

## Current state

Draft PR [#15](https://github.com/massimilianonardi-ai/m-os/pull/15) is open and unmerged at `35e2d090660ebc940458e78aad9be3fc81ee7c62`. It filters only exact `vN.N.N-rcN` tags incorrectly marked stable, keeps unknown malformed stable tags fail-closed, resolves exact versions by tag endpoint, compares two exact releases without enumerating history, and retries transient GitHub API transfer failures three times with backoff. The manual documents these boundaries. The local fixture suite passed against official metadata fixtures for v6.1.3/v6.1.4 and the mislabeled v1.7.0-rc1 tag; shell syntax and `git diff --check` passed.

Catalog candidate branch [`codex/podman-current-catalog`](https://github.com/massimilianonardi-ai/pkg-catalog/tree/codex/podman-current-catalog) is `c8a39f8bd099d65ed8520de574800f220d6119e1`, based on the pinned catalog main. It advances only Podman's repository anchor to official stable v6.1.4, with URL and SHA-256 verified from the official GitHub release metadata; the existing supported range retains v6.1.3. Draft catalog PR [#3](https://github.com/massimilianonardi-ai/pkg-catalog/pull/3) is open and unmerged; the candidate is not promoted.

The isolated runner branch is `pkg-catalog/codex/m-os-adapter-runner@37a873b546ff3865bb1364ba77b56fcf69588a14`. Run [42473174743](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42473174743) passed the Podman fixture step and the GPGTools/CfT jobs, but the Podman public package path failed after four repeated HTTP 504 responses from `api.github.com`; a subsequent detached checkout `git pull` error was fallout during initialization. This is an upstream acquisition failure, not an adapter PASS or product regression. Earlier runner run [42473039971](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42473039971) failed only because checkout was given an abbreviated commit ref; the full SHA is now pinned. Local live API calls also returned HTTP 504. The exact live API response and genuine package installation/command execution therefore remain **PENDING**.

A prior command-validation syntax check created `/tmp/workflow-run-shell-check`, outside the user's permitted local-write root `/m/src/git/chatgpt`; the cleanup attempt was rejected by the execution layer, so that path may remain. No subsequent local filesystem writes were made outside the authorized root. All product/catalog/runner/handoff writes in this continuation were confined to `/m/src/git/chatgpt`.

## Next action

Retry the exact hosted Podman public path after the upstream API recovers; keep the macOS install gate pending until the exact artifact installs, integrity verifies and `podman --version` succeeds. In parallel, continue independent nonprivileged devplan work owned by the orchestration handoff; do not dispatch A1–A4 hosted workflows.

## Blockers / open questions

- Live GitHub API requests returned repeated HTTP 504 in both local and hosted runs; exact/latest live resolution is not established in this environment.
- Genuine macOS ARM64 package install and public command evidence remains required.
