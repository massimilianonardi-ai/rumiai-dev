# GraalVM repository adapter

Status: Active — adapter/manual/workflow implemented locally; fixture validation passes; live API and public installation pending
Updated: 2026-11-08

## Goal

Implement the missing `graalvm` repository adapter for the four catalog-declared platform streams and validate exact/latest resolution plus a genuine public installation.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
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

The upstream stable tag families observed are `graal-<version>`, `jdk-<version>`, and historical `vm-<version>`. Map each by stripping exactly one recognized prefix; fail closed on unknown tags and duplicate mapped versions. Latest currently uses `graal-25.5.5.0.3`; exact catalog anchor `25.3.4.1` maps to `graal-25.3.4.1`.

## Completed

- Read-only audit confirmed the exact pinned catalog contains four GraalVM streams, each anchored at `25.3.4.1`, and current master has no `pkg-repository-graalvm.lib.sh`.
- Official API evidence confirms exact and latest release tags, per-platform binary assets, positive sizes and SHA-256 digests. The exact Linux ARM64 anchor asset is `graalvm-community-jdk-25i3-25.0.4.1_linux-aarch64_bin.tar.gz`, size 326,402,344, digest `sha256:7e8a3fbc2e4c28566107039a298cef690d86a37599a8e50536fc5a65b7f1bd56`.
- The latest stable upstream release observed in the research is `graal-25.5.5.0.3` (published 2026-11-03). Release tags and asset filenames use different embedded version strings.
- Implemented the adapter, operational manual, and a focused pinned-catalog CI workflow on the local branch. A fixture-backed managed-shell check passes tag mapping (`vm-`, `jdk-`, `graal-`), chronology, exact/latest resolution, and exact asset size/digest/URL selection. Shell syntax, `git diff --check`, and all embedded workflow shell blocks pass.
- Independent read-only source review found no concrete defect in the current adapter implementation. The workflow was corrected to install latest first and capture its concrete before installing the exact anchor, avoiding installed-current reuse.

## Current state

The adapter, manual and workflow are in the dedicated local branch `codex/graalvm-repository-adapter` based on exact `m-os/master@a78a24bd`; no commit or PR has been published yet. This work is separate from GeoServer PR #12. All local writes are under `/m/src/git/chatgpt`; frozen `rumiai-os` and `rumiai-tests` were not accessed.

## Next action

After the unauthenticated GitHub API rate limit resets, run live exact/latest resolution and artifact metadata checks against the actual API. Then perform public exact/latest dependency planning and genuine Linux ARM64 installs of the pinned anchor and stable latest; verify Java provider selection, inspect the focused workflow, commit/push a dedicated PR branch, and record hosted/platform gates.

## Blockers / open questions

- Old `vm-` release tags must be mapped consistently with newer `graal-` tags before listing/comparison can claim completeness.
- Only Linux ARM64 can be exercised in the current local environment. The other three declared streams require matching hosted-platform validation.
- The other missing catalog repository types (`chrome-for-testing`, `gpgtools`, and `podman`) remain separate TODO work.
