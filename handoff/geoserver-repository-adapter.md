# GeoServer repository adapter

Status: Latest/exact Linux ARM64 and live WFS pass on current workflow; macOS current-latest acquisition is blocked by upstream HTTP 403; PR review and mutable runtime-state work remain open
Updated: 2026-11-08

## Goal

Implement the catalog-declared GeoServer package repository type and validate exact/latest dependency resolution, real installation, and a responsive local service through public `m` commands.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/geoserver-repository-adapter@ff90b05d231c122c8db07659d92e32f3316709f0` (draft [PR #12](https://github.com/massimilianonardi-ai/m-os/pull/12))
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `pkg-catalog/codex/m-os-adapter-runner@108eb1ef3ab3008c6d3b00599cfcb43f80a91faa` (hosted runner configuration)
- `rumiai-dev/codex/rumiai-dev-remote-sync@339e0f6d` at this checkpoint

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
- Added a focused CI workflow, now updated in PR head `ff90b05d231c122c8db07659d92e32f3316709f0`. It pins the catalog, checks exact/latest public dependency selection, installs latest first and records the selected concrete, installs exact 3.0.1 only when distinct (including concrete identities without `!osarch`), then explicitly selects latest and probes/stops WFS. `git diff --check` and extracted shell syntax validation passed locally.
- Local Ubuntu ARM64 validation against exact `m-os/master@a78a24bd` and `pkg-catalog@0b69223a`: public exact/latest dependency planning selected `temurin@21+35!linux-arm64`; the adapter listed 69 stable versions and resolved latest 3.0.2; exact 3.0.1 artifact metadata matched its SourceForge RSS record; real exact 3.0.1 and latest 3.0.2 installs passed.
- GeoServer 3.0.1 served local HTTP 302 and stopped cleanly. On a fresh exact-PR-head 3.0.2 run, missing GeoServer default correctly failed closed (`provider-resolution-failed`); after explicitly selecting Java 21 and GeoServer 3.0.2, six WFS requests returned HTTP 200 and stop succeeded.
- Independent adapter review found no remaining concrete code defect. The follow-up CI workflow review concern about the single 3.0.1 range anchor was withdrawn after inspection of request/range resolution plus successful public latest install; the workflow asserts installed 3.0.2 explicitly.
- Hosted run [42483023923](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42483023923), runner head `7556c8dd85b308474e02e5c54b8c89728d52c44f`, checked out adapter `b1e4f040506592f0433e26005741f887266f4462` and catalog `0b69223a5ebe7bc042aad50012ee8bc7e4a00442`. GeoServer jobs passed on `ubuntu-24.04-arm` and `macos-15`: exact/latest planning selected Temurin 21, exact 3.0.1 installed, latest resolved to already-installed 3.0.1, explicit defaults allowed live WFS, and stop completed. This remains valid two-platform evidence for the then-current release set; it does not test current latest 3.0.2.
- The same aggregate run is red because the unrelated Podman job `128738863351` received HTTP 403 from the upstream GitHub Releases API. GPGTools, Chrome for Testing and both GeoServer jobs passed. This does not change GeoServer job results.
- Current workflow candidate `3a451002...` was tested through external runner `e9d2661...` in completed run [42484994689](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42484994689). Ubuntu ARM64 installed exact 3.0.1 and latest 3.0.2, selected latest for the real service, obtained WFS GetCapabilities, and stopped cleanly (**PASS**, job `128744823666`). macOS ARM64 passed planning but failed before artifact extraction/startup when the GeoServer Releases API returned HTTP 403 resolving the 3.0.2 release asset. This is an upstream acquisition failure, not a service/runtime failure. The same run passed the S1 composition, GPGTools, CfT and Podman jobs; aggregate 5/6 because of macOS acquisition. Earlier new-run attempts also encountered 403s before startup; details and exact refs are in `m-autonomous-validation.md`.
- The task-specific checkpoint and M10/M12 evidence are recorded in `handoff/m-autonomous-validation.md`.

## Current state

PR #12 is draft and unmerged. Current workflow acceptance is PASS on Ubuntu ARM64; current macOS latest artifact acquisition remains pending an available upstream API response. The prior macOS PASS covers latest 3.0.1 at its exact recorded revision/release set. The PR's native workflow has no run because Actions are disabled on the `m-os` fork; no external status is represented as a native PR check. All local writes for this continuation stayed under `/m/src/git/chatgpt`.

## Next action

Continue review of the current PR #12 diff against its adapter/manual contract and retry only the macOS artifact acquisition when upstream API access is available. Keep the PR draft/unmerged; no merge or release is authorized by this validation. GeoServer Linux current-latest service acceptance is complete, macOS current-latest acceptance is not. Continue the separate mutable runtime-state task and overall M01–M15/I1 matrix.

## Blockers / open questions

- Native PR workflow visibility remains unavailable while `m-os` Actions are disabled. External-runner evidence covers current latest/exact on Ubuntu and the older 3.0.1 latest set on macOS; current macOS 3.0.2 artifact acquisition returned upstream HTTP 403.
- Other supported stream architectures and operating systems remain unvalidated.
- This adapter does not close GeoServer mutable runtime-state migration or the overall M01–M15/I1 acceptance matrix.

### Latest hosted retry (2026-11-08)

- Exact refs: GeoServer PR #12 `ff90b05d231c122c8db07659d92e32f3316709f0`; catalog `0b69223a5ebe7bc042aad50012ee8bc7e4a00442`; external runner `108eb1ef3ab3008c6d3b00599cfcb43f80a91faa`; run [42485712210](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42485712210).
- GeoServer macOS ARM64 again failed before artifact installation because the upstream Releases API returned HTTP 403. No runtime/service assertion ran on that host. Podman macOS independently hit HTTP 403 from its upstream GitHub Releases API. GPGTools, Chrome for Testing, and the S1 current-master composition job passed.
- At the time of this update, GeoServer Ubuntu ARM64 job `128746995307` was still running; do not count it as a result until refreshed. Prior exact-current-latest Ubuntu service acceptance is PASS in run `42484994689`, job `128744823666`.
- PR #12 remains draft/unmerged. Adapter review and mutable runtime-state migration remain open; cross-platform/other architecture coverage is not established.
