# GraalVM repository adapter

Status: Active - PR #20 implements offline compatible-latest ordering and passes focused/local Linux checks; hosted m-os and cross-platform validation remain open
Updated: 2026-11-10

## Goal

Implement the missing `graalvm` repository adapter for the four catalog-declared platform streams and validate exact/latest resolution plus a genuine public installation.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- Adapter PR #13 `m-os/codex/graalvm-repository-adapter@2b26a461dc673c9e4c1990b62aaa8a41ab47a03f`
- Offline-order PR #20 `m-os/codex/p4-graalvm-local-order@d4b4e387c0748599b7389daa7cf75a18b64b42c3`, stacked on PR #13
- `pkg-catalog/main@164b06441bef655eca2ac3f44ddee7e5b2c6cf3d`
- Catalog history PR #4 `pkg-catalog/codex/p4-graalvm-version-index@50faddb36f9c3e7c12fa53d46b94dd8098fa857b`
- `rumiai-dev/main@a0fd46ff70ed75cc56d246159cb0ff110278e990`; SRV-11 documentation correction is task-branch commit `3dfbd23d`

Refresh all remote heads before the next write or validation. All three PRs remain drafts and unmerged.

## Applicable canonical sources

- `rumiai-dev/README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `DEVPLAN.md`, `TESTING.md`, `handoff/README.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `pkg-catalog/v1/pkg/graalvm` at the pinned catalog revision
- Current `m-os` GitHub repository-adapter interface and manuals

## Fixed choices

- Upstream authority is the official `graalvm/graalvm-ce-builds` GitHub Releases API; use stable release chronology, not numeric/semver sorting.
- Catalog package versions and upstream release tags differ: current package `25.3.4.1` maps to release tag `graal-25.3.4.1`; asset filenames have a distinct embedded JDK version such as `25i3-25.0.4.1`.
- Resolve only the one binary asset matching the catalog archive regex for the current OS/architecture; require positive API asset size and SHA-256 digest, and exclude sidecar assets.
- Initial platform scope is only catalog-declared `linux-arm64`, `linux-x86_64`, `macos-arm64`, and `windows-x86_64` streams. Do not claim other platform support.

## Acceptance scenarios

- Public exact and unversioned dependency resolution return a compatible GraalVM Java provider for supported targets.
- Public exact install of the catalog anchor and unversioned install of current stable resolve genuine release artifacts with verified archive metadata.
- Installed package reports the selected GraalVM release and exposes the declared Java commands through the package/provider path.

## Working design

The upstream stable tag families observed are `graal-<version>`, `jdk-<version>`, and historical `vm-<version>`. Map each by stripping exactly one recognized prefix; fail closed on unknown tags and duplicate mapped versions. Latest currently uses `graal-25.5.5.0.3`; exact catalog anchor `25.3.4.1` maps to `graal-25.3.4.1`.

## Completed

- Read-only audit confirmed the exact pinned catalog contains four GraalVM streams, each anchored at `25.3.4.1`, and current master has no `pkg-repository-graalvm.lib.sh`.
- Official API evidence confirms exact and latest release tags, per-platform binary assets, positive sizes and SHA-256 digests. The exact Linux ARM64 anchor asset is `graalvm-community-jdk-25i3-25.0.4.1_linux-aarch64_bin.tar.gz`, size 326,402,344, digest `sha256:7e8a3fbc2e4c28566107039a298cef690d86a37599a8e50536fc5a65b7f1bd56`.
- The latest stable upstream release observed in the research is `graal-25.5.5.0.3` (published 2026-11-03). Release tags and asset filenames use different embedded version strings.
- Implemented the adapter, operational manual, and a focused pinned-catalog CI workflow on the local branch. A fixture-backed managed-shell check passes tag mapping (`vm-`, `jdk-`, `graal-`), chronology, exact/latest resolution, and exact asset size/digest/URL selection. Shell syntax, `git diff --check`, and all embedded workflow shell blocks pass.
- Independent read-only source review found no concrete defect in the current adapter implementation. The workflow installs latest first and captures its concrete before installing the exact anchor, avoiding installed-current reuse.
- On 2026-11-10, the exact local adapter branch was exercised through public `m pkg install` in a disposable checkout under `/m/src/git/chatgpt`. Unversioned install selected the then-current stable `graalvm@25.5.5.0.3!linux-arm64`; exact `graalvm@25.3.4.1` also installed. `pkg versions graalvm` listed both, `pkg default graalvm` returned the exact anchor after that install, and selecting the latest as the Java provider made public `m java -version` report GraalVM CE 25.5.5.0.3 / OpenJDK 25.0.5.0.3. This is local Ubuntu ARM64 evidence. A facility-map version-order warning appeared after both versions were installed. The current map leaves its provider-local `@latest` alias unavailable when offline ordering cannot be established. The public package install and explicit Java provider selection still passed, but this means the facility-map acceptance is not closed. The disposable package/catalog state was removed after recording results.
- PR #20 adds immutable `repository/versions` validation and local GraalVM ordering for facility-map reconciliation. The exact branch's P4 facility-map regression passed locally on Ubuntu auxiliary at `m-os@d4b4e387`, exercising indexed compatible-latest selection and fail-closed missing/corrupt index cases. Its PR description records exact and unversioned public dependency/install, `pkg versions`, and Java-provider execution PASS on that exact product revision with `pkg-catalog@50faddb3`. No GitHub Actions run is available for the m-os head.
- Catalog PR #4 supplies the normalized 59-release chronology for all four declared streams; its sync workflow passed [run 42500901707](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42500901707). This validates the catalog synchronizer only, not the m-os facility-map behavior.

## Current state

The adapter, manual and workflow are in `m-os/codex/graalvm-repository-adapter@2b26a461`, based on exact `m-os/master@a78a24bd`, and are tracked by draft PR #13. PR #20 `d4b4e387` adds the offline ordering change on top of PR #13; its exact local facility-map unit and public-install evidence pass on Linux ARM64. Catalog PR #4 `50faddb3` provides 59 normalized release versions, with catalog sync run 42500901707 PASS. Neither implementation PR has hosted m-os workflow evidence; Linux x86_64, macOS ARM64 and Windows x86_64 remain pending. These are separate from GeoServer PR #12. All local writes are under `/m/src/git/chatgpt`; frozen `rumiai-os` and `rumiai-tests` were not accessed.

## Next action

Refresh involved remote refs and obtain a hosted m-os run for exact PR #20 head `d4b4e387` against catalog PR #4 `50faddb3`; collect declared-platform evidence, and update the PR bodies with exact-head results. Keep PR #13, #20 and catalog #4 as drafts; do not merge.

## Blockers / open questions

- Offline GraalVM ordering is implemented in draft PR #20 and its exact local P4 fixture passes, but `master` still lacks the change and no hosted m-os run has been retrieved. The public compatible-latest projection remains unaccepted until exact hosted evidence and normal repository review are complete.
- Only Linux ARM64 has local live public-install evidence. The other three declared streams require matching hosted-platform validation.
- The other missing catalog repository types (`chrome-for-testing`, `gpgtools`, and `podman`) remain separate TODO work.
