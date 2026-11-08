# GeoServer repository adapter

Status: Hosted Linux ARM64 and macOS ARM64 acceptance complete on exact adapter head; PR review and mutable runtime-state work remain open
Updated: 2026-11-08

## Goal

Implement the catalog-declared GeoServer package repository type and validate exact/latest dependency resolution, real installation, and a responsive local service through public `m` commands.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/geoserver-repository-adapter@b1e4f040506592f0433e26005741f887266f4462` (draft [PR #12](https://github.com/massimilianonardi-ai/m-os/pull/12))
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `pkg-catalog/codex/m-os-adapter-runner@7556c8dd85b308474e02e5c54b8c89728d52c44f` (hosted runner configuration)
- `rumiai-dev/main@efd2bb7d3ea7c394c5ac4255b504f4d8e1847496` at this checkpoint

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
- Added a focused CI workflow in current PR head `b1e4f040506592f0433e26005741f887266f4462`. It pins the catalog, checks exact/latest public dependency selection, installs 3.0.1 and 3.0.2, asserts both installed concretes, and probes/stops the latest WFS service in one shell session. All three embedded shell blocks pass `sh -n`.
- Local Ubuntu ARM64 validation against exact `m-os/master@a78a24bd` and `pkg-catalog@0b69223a`: public exact/latest dependency planning selected `temurin@21+35!linux-arm64`; the adapter listed 69 stable versions and resolved latest 3.0.2; exact 3.0.1 artifact metadata matched its SourceForge RSS record; real exact 3.0.1 and latest 3.0.2 installs passed.
- GeoServer 3.0.1 served local HTTP 302 and stopped cleanly. On a fresh exact-PR-head 3.0.2 run, missing GeoServer default correctly failed closed (`provider-resolution-failed`); after explicitly selecting Java 21 and GeoServer 3.0.2, six WFS requests returned HTTP 200 and stop succeeded.
- Independent adapter review found no remaining concrete code defect. The follow-up CI workflow review concern about the single 3.0.1 range anchor was withdrawn after inspection of request/range resolution plus successful public latest install; the workflow asserts installed 3.0.2 explicitly.
- Hosted run [42483023923](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42483023923), runner head `7556c8dd85b308474e02e5c54b8c89728d52c44f`, checked out exact adapter `b1e4f040506592f0433e26005741f887266f4462` and catalog `0b69223a5ebe7bc042aad50012ee8bc7e4a00442`. GeoServer jobs passed on `ubuntu-24.04-arm` (job `128738863340`) and `macos-15` (job `128738863297`): exact/latest dependency planning selected Temurin 21, exact 3.0.1 installed, latest request was safely recognized as already-installed 3.0.1, explicit Java/GeoServer defaults allowed service startup, WFS GetCapabilities succeeded, and public stop completed. The live stable release set at this run resolved latest to 3.0.1; the earlier local pinned validation that observed 3.0.2 remains separately recorded and is not substituted for this hosted result.
- The same aggregate run is red because the unrelated Podman job `128738863351` received HTTP 403 from the upstream GitHub Releases API. GPGTools, Chrome for Testing and both GeoServer jobs passed. This does not change GeoServer job results.
- The task-specific checkpoint and M10/M12 evidence are recorded in `handoff/m-autonomous-validation.md`.

## Current state

PR #12 is draft and unmerged. Exact-head hosted validation is recorded through the external runner; the PR's own workflow is still only on its branch and formal GitHub review is not recorded. All new local writes for this continuation were confined to `/m/src/git/chatgpt`; disposable validation artifacts were kept under that directory.

## Next action

Obtain formal PR review for PR #12, then reconcile the external hosted evidence into the PR workflow when its checks are available. GeoServer Linux ARM64 and macOS ARM64 hosted service acceptance is now complete. Keep PR #12 unmerged until required review gates are resolved; continue the separate mutable runtime-state task and overall M01–M15/I1 matrix.

## Blockers / open questions

- The PR's own hosted workflow visibility remains pending because its workflow file is new to the default branch; external-runner hosted evidence now covers Ubuntu ARM64 and macOS ARM64.
- Other supported stream architectures and operating systems remain unvalidated.
- This adapter does not close GeoServer mutable runtime-state migration or the overall M01–M15/I1 acceptance matrix.
