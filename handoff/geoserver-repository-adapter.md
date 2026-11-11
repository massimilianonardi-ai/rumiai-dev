# GeoServer repository adapter

Status: Active — Linux ARM64 hosted acceptance passes on current PR #12 head; macOS artifact acquisition remains blocked upstream, PR review is open
Updated: 2026-11-11

## Goal

Implement the catalog-declared GeoServer package repository type and validate exact/latest dependency resolution, real installation, and a responsive local service through public `m` commands.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/geoserver-repository-adapter@6595bb10722d596d656327c5ee3d72a13cb106c9` (draft [PR #12](https://github.com/massimilianonardi-ai/m-os/pull/12); latest commit updates its workflow catalog setup only)
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/codex/m-os-validation-20261110@87e5d36510c9a2efe65e7ef617cff0f83988e9ab` at this checkpoint

Refresh all remote heads before any later write or validation.

## Applicable canonical sources

- `rumiai-dev/README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `DEVPLAN.md`, `TESTING.md`, `handoff/README.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `m-os` package repository adapter sources/manuals and `.github/workflows/m-geoserver-repository.yml`
- `pkg-catalog` GeoServer v1 package/range/repository and service entries

## Fixed choices

- Stable release identity, listing and chronology come from the official `geoserver/geoserver` GitHub Releases API. SourceForge RSS is used only for exact-version artifact size and MD5 metadata.
- For the catalog’s `geoserver` repository type, the artifact is only `geoserver-<version>-bin.zip` from the exact `/GeoServer/<version>/` directory. Windows, WAR, docs and extension files are not candidates.
- GeoServer 3.0.1’s catalog range is the anchor for newer release resolution when the package stream permits it; exact/latest behavior must be observed through public commands.
- GeoServer service startup requires an explicit system provider default. Installing a package alone does not configure that selector.
- GeoServer mutable runtime data migration remains owned by `todo/geoserver-mutable-runtime-state.md`.

## Acceptance scenarios

- `pkg depend geoserver@3.0.1` and `pkg depend geoserver` resolve the real Java dependency through the adapter.
- `pkg install geoserver@3.0.1` and unversioned `pkg install geoserver` install genuine selected artifacts with verified size/digest metadata.
- After explicitly setting Java and GeoServer provider defaults, `srv start geoserver` serves WFS GetCapabilities over local HTTP and `srv stop geoserver` cleans up.

## Completed

- Added `pkg-repository-geoserver.lib.sh` and its operational manual in adapter commit `c2a21cc2cbe0ca5760c16b254f355fa7949b17b4`.
- Added a focused CI workflow in current PR head `b1e4f040506592f0433e26005741f887266f4462`. It pins the catalog, checks exact/latest public dependency selection, installs 3.0.1 and 3.0.2, asserts both installed concretes, and probes/stops the latest WFS service in one shell session. All three embedded shell blocks pass `sh -n`.
- Local Ubuntu ARM64 validation against exact `m-os/master@a78a24bd` and `pkg-catalog@0b69223a`: public exact/latest dependency planning selected `temurin@21+35!linux-arm64`; the adapter listed 69 stable versions and resolved latest 3.0.2; exact 3.0.1 artifact metadata matched its SourceForge RSS record; real exact 3.0.1 and latest 3.0.2 installs passed.
- GeoServer 3.0.1 served local HTTP 302 and stopped cleanly. On a fresh exact-PR-head 3.0.2 run, missing GeoServer default correctly failed closed (`provider-resolution-failed`); after explicitly selecting Java 21 and GeoServer 3.0.2, six WFS requests returned HTTP 200 and stop succeeded.
- Independent adapter review found no remaining concrete code defect. The follow-up CI workflow review concern about the single 3.0.1 range anchor was withdrawn after inspection of request/range resolution plus successful public latest install; the workflow asserts installed 3.0.2 explicitly.
- The task-specific checkpoint and M10/M12 evidence are recorded in `handoff/m-autonomous-validation.md`.
- **Hosted exact-head acceptance (2026-11-11):** focused runner [run 43035041027](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/43035041027), `pkg-catalog/codex/m-os-adapter-runner@d84c61809f2c3370cecede83e0cc8b8fc8e3a9ea`, checked out exact PR #12 head `6595bb10722d596d656327c5ee3d72a13cb106c9` and catalog `0b69223a5ebe7bc042aad50012ee8bc7e4a00442`. Ubuntu 24.04 ARM64 passed exact/latest dependency resolution, genuine GeoServer 3.0.1 and 3.0.2 installs, and a live WFS GetCapabilities request followed by clean stop. macOS 15 reached exact-version resolution but GitHub API returned HTTP 403 for `geoserver/geoserver` release 3.0.1 before install/service assertions; classify as upstream acquisition block, not product failure or PASS.
- **Corrected adapter composition runner (2026-11-11):** [run 43035328845](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/43035328845) at `pkg-catalog/codex/m-os-adapter-runner@c22e8b1bb62227a922cc30ce89e2104f2aa979b2` passes exact composition of adapter PRs #12–#16, all five shell syntax checks, and byte-for-byte public manual discovery (job `130572523219`). The exact PR #12 GeoServer lane again passes on Ubuntu ARM64 (`130572523917`); macOS 15 again stops before product installation because the GitHub Releases API returns HTTP 403 for GeoServer 3.0.1 (`130572523610`). The runner fix removes the stale PR #14 SHA failure; it does not close the macOS acquisition gate.

## Current state

PR #12 is draft and unmerged. Exact-head hosted Linux ARM64 install/service acceptance now passes through the independent adapter runner; the macOS lane is blocked before product assertions by upstream GitHub API HTTP 403. The all-adapter composition/manual/syntax smoke passes with the current PR #12–#16 heads. The PR-owned workflow remains present only on the PR branch, so no formal check attached to PR #12 is recorded. Final PR review and a successful macOS artifact lane remain open. All created test worktrees, mirrors, artifacts and logs remain confined to `/m/src/git/chatgpt/tmp`; unrelated pre-existing files were preserved.

## Next action

Retry macOS exact-head install/service acceptance when the upstream GitHub API is available; then complete final PR review. The Linux ARM64 hosted run closes that platform’s public-path scenario only. Keep PR #12 unmerged until review and required platform gates are resolved.

## Blockers / open questions

- The PR-owned workflow is not listed on the default branch; hosted evidence currently comes from the independent exact-head `pkg-catalog` runner.
- Ubuntu ARM64 has local and hosted install/service evidence. macOS remains acquisition-blocked; other supported stream behavior remains unvalidated.
- This adapter does not close GeoServer mutable runtime-state migration or the overall M01–M15/I1 acceptance matrix.
