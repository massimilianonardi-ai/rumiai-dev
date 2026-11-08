# GraalVM repository adapter

Status: Active — adapter/manual/workflow implemented; duplicate-version API resolution and Linux ARM64 exact public install pass; latest install is pending after upstream API quota exhaustion
Updated: 2026-11-08

## Goal

Implement the missing `graalvm` repository adapter for the four catalog-declared platform streams and validate exact/latest resolution plus a genuine public installation.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/graalvm-repository-adapter@c123f9ffff5b0477551b1627a197b26d35d11679` (draft [PR #13](https://github.com/massimilianonardi-ai/m-os/pull/13))
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/main@75e54c051f7a2893a4898c6b4e1b963fdfa84e94`

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

The upstream stable tag families observed are `graal-<version>`, `jdk-<version>`, and historical `vm-<version>`. Map each by stripping exactly one recognized prefix; fail closed on unknown tags. When multiple stable tags map to one package version, retain the record with the newest upstream creation/publication chronology; this is required for observed duplicates such as `graal-23.0.2` and `jdk-23.0.2`. Latest currently uses `graal-25.5.5.0.3`; exact catalog anchor `25.3.4.1` maps to `graal-25.3.4.1`.

## Completed

- Read-only audit confirmed the exact pinned catalog contains four GraalVM streams, each anchored at `25.3.4.1`, and current master has no `pkg-repository-graalvm.lib.sh`.
- Official API evidence confirms exact and latest release tags, per-platform binary assets, positive sizes and SHA-256 digests. The exact Linux ARM64 anchor asset is `graalvm-community-jdk-25i3-25.0.4.1_linux-aarch64_bin.tar.gz`, size 326,402,344, digest `sha256:7e8a3fbc2e4c28566107039a298cef690d86a37599a8e50536fc5a65b7f1bd56`.
- The latest stable upstream release observed in the research is `graal-25.5.5.0.3` (published 2026-11-03). Release tags and asset filenames use different embedded version strings.
- Implemented the adapter, operational manual, and a focused pinned-catalog CI workflow on the local branch. A fixture-backed managed-shell check passes tag mapping (`vm-`, `jdk-`, `graal-`), chronology, exact/latest resolution, and exact asset size/digest/URL selection. Shell syntax, `git diff --check`, and all embedded workflow shell blocks pass.
- A live stable-release listing initially failed because several distinct stable tags normalize to the same package version. The adapter now keeps the newest record for each normalized version. The fixture includes the observed `graal-23.0.2`/`jdk-23.0.2` duplicate and passes; live version listing, latest resolution and exact `25.3.4.1` resolution then passed.
- On the isolated Ubuntu ARM64 checkout, the public CLI `./m pkg uninstall graalvm@25.3.4.1!linux-arm64` followed by `./m pkg install graalvm@25.3.4.1!linux-arm64` completed successfully. `pkg versions` and `pkg default` reported that concrete, and `./m java -version` ran the installed GraalVM 25.0.4.1 runtime. The run exercised the public package pipeline and genuine catalog artifact.
- A later unversioned install attempt failed before artifact resolution because GitHub returned HTTP 403 and the unauthenticated API quota was exhausted after repeated live diagnostics. This is **PENDING**, not an adapter/latest failure. The full releases endpoint returned 5,477,123 bytes; its POSIX JSON parser is CPU-bound on this response, so allow the hosted workflow its configured 35-minute timeout and avoid repeated live probes.
- Independent read-only source review found no concrete defect in the current adapter implementation. The workflow was corrected to install latest first and capture its concrete before installing the exact anchor, avoiding installed-current reuse.

## Current state

The adapter, manual and workflow are committed to `codex/graalvm-repository-adapter@c123f9ff` and published as draft PR #13, based on exact `m-os/master@a78a24bd`. Exact install and provider execution pass locally. Latest live install, four-platform hosted validation and formal PR review remain open. This work is separate from GeoServer PR #12. All local writes are under `/m/src/git/chatgpt`; frozen `rumiai-os` and `rumiai-tests` were not accessed.

## Next action

After the unauthenticated GitHub API rate limit resets, run one bounded public unversioned latest install, then verify installed versions/default and Java provider selection. Re-run shell syntax, fixture, embedded workflow syntax and diff checks on PR #13; record hosted/platform gates and any formal review. Keep the PR draft and unmerged until the latest/platform/hosted acceptance gates pass.

## Blockers / open questions

- Unauthenticated GitHub API quota is currently exhausted; read-only headers should be checked before retrying. Do not repeatedly poll the releases endpoint while it remains exhausted.
- Only Linux ARM64 can be exercised in the current local environment. The other three declared streams require matching hosted-platform validation.
- The other missing catalog repository types (`chrome-for-testing`, `gpgtools`, and `podman`) remain separate TODO work.
