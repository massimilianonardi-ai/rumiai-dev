# GraalVM repository adapter

Status: Active — exact/latest live public installs pass locally on Linux ARM64; offline provider-map compatible-latest ordering, hosted cross-platform validation and promotion remain open
Updated: 2026-11-10

## Goal

Implement the missing `graalvm` repository adapter for the four catalog-declared platform streams and validate exact/latest resolution plus a genuine public installation.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/main@a0fd46ff70ed75cc56d246159cb0ff110278e990`

Refresh all remote heads before the next write or validation.

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

## Current state

The adapter, manual and workflow are in `m-os/codex/graalvm-repository-adapter@2b26a461`, based on exact `m-os/master@a78a24bd`, and are tracked by draft PR #13. Current-head local syntax/diff and diagnostic checks pass. The full latest/exact live public install evidence is on ancestor `73b238d4`; the current head adds operation-specific upstream failure diagnostics only, so do not report the install result as an exact-head replay. This work is separate from GeoServer PR #12. All local writes are under `/m/src/git/chatgpt`; frozen `rumiai-os` and `rumiai-tests` were not accessed.

## Next action

Refresh involved remote refs; run/retrieve the focused pinned-catalog workflow for the exact current head and collect hosted Linux/macOS/Windows evidence. Resolve the offline compatible-latest facility-map ordering gap before treating this adapter as fully integrated. Keep draft PR #13 open; do not merge.

## Blockers / open questions

- `pkg_facility_map_reconcile` cannot currently rank two installed GraalVM versions from an immutable offline snapshot; it warns and omits the provider-local `@latest` projection. Preserve the offline map contract and record authoritative release order in a validated installed/catalog snapshot before claiming compatible-latest selection. The current public installs and explicit provider selection do not close this case.
- Only Linux ARM64 has local live public-install evidence. The other three declared streams require matching hosted-platform validation.
- The other missing catalog repository types (`chrome-for-testing`, `gpgtools`, and `podman`) remain separate TODO work.
