# GeoServer repository adapter

Status: Active — adapter implementation and local public-path acceptance complete; corrected PR workflow is published, hosted validation and review remain open
Updated: 2026-11-09

## Goal

Implement the catalog-declared GeoServer package repository type and validate exact/latest dependency resolution, real installation, and a responsive local service through public `m` commands.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/geoserver-repository-adapter@6595bb10722d596d656327c5ee3d72a13cb106c9` (draft [PR #12](https://github.com/massimilianonardi-ai/m-os/pull/12))
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/main@084642281a282247c904c5b611e5af23833d2ac0` and active C2 task branch `rumiai-dev/codex/c2-account-defaults@7cbc8a1e48cfe335782a0044f6bc37bf39f8bfa7`

Refresh all remote heads before the next write or validation.

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
- Added a focused CI workflow, corrected at PR head `6595bb10722d596d656327c5ee3d72a13cb106c9`. The checkout is pinned to catalog commit `0b69223a...`; the workflow now creates a local branch at that detached checkout so repeated `pkg` invocations can refresh their cache, and it verifies the facility provider default through `pkg provider default` rather than the unrelated package-default command.
- Local Ubuntu ARM64 validation against exact `m-os/master@a78a24bd` and `pkg-catalog@0b69223a`: public exact/latest dependency planning selected `temurin@21+35!linux-arm64`; the adapter listed 69 stable versions and resolved latest 3.0.2; exact 3.0.1 artifact metadata matched its SourceForge RSS record; real exact 3.0.1 and latest 3.0.2 installs passed.
- GeoServer 3.0.1 served local HTTP 302 and stopped cleanly. On a fresh exact-PR-head 3.0.2 run, missing GeoServer default correctly failed closed (`provider-resolution-failed`); after explicitly selecting Java 21 and GeoServer 3.0.2, six WFS requests returned HTTP 200 and stop succeeded.
- Independent adapter review found no remaining concrete code defect. The follow-up CI workflow review concern about the single 3.0.1 range anchor was withdrawn after inspection of request/range resolution plus successful public latest install; the workflow asserts installed 3.0.2 explicitly.
- The task-specific checkpoint and M10/M12 evidence are recorded in `handoff/m-autonomous-validation.md`.
- Exact local reproduction showed the prior workflow failed on its second `pkg depend`: cloning the pinned catalog from a detached checkout left the cache without a pull branch. After adding the local pinned branch, repeated exact/latest dependency planning passed on a clean profile. The updated provider-default getter returned `geoserver@3.0.2`; that selected concrete served WFS 2.0 capabilities over HTTP and `srv stop` succeeded. Both genuine releases were installed and listed in the same disposable runtime.
- A later clean replay of the external release-resolution path received HTTP 403 from `api.github.com` before installation. This is an upstream acquisition failure, not a product PASS. GitHub reports no workflow run or commit status for the latest PR head; no hosted result is claimed.

## Current state

PR #12 is draft and unmerged at `6595bb10`. GitHub currently reports `mergeable=true`, with no hosted workflow run, commit status or formal review recorded. The focused workflow exists only on the PR branch and is not available through the connected workflow-dispatch interface. Test profiles/artifacts are confined to `/m/src/git/chatgpt/tmp/geoserver-e2e-ee58d783`; unrelated checkout state was preserved.

## Next action

Obtain hosted exact-head evidence for `.github/workflows/m-geoserver-repository.yml` when GitHub exposes the workflow on an authorized runner, then validate supported additional platforms and reconcile any findings forward. Keep PR #12 draft/unmerged until its required review and hosted gates are resolved. Do not report a local profile replay as hosted acceptance.

## Blockers / open questions

- Hosted workflow visibility/run is pending because the workflow file is new to the default branch; the PR remains draft and is not merged.
- Only Ubuntu ARM64 has local install/service evidence. Hosted macOS and other supported stream behavior remain unvalidated.
- This adapter does not close GeoServer mutable runtime-state migration or the overall M01–M15/I1 acceptance matrix.
