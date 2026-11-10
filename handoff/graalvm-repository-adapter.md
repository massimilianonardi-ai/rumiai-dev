# GraalVM repository adapter

Status: Active — adapter + GraalVM P4 history index have exact local Linux ARM64 public exact/latest install PASS; hosted cross-platform evidence pending
Updated: 2026-11-10

## Goal

Implement the missing `graalvm` repository adapter for the four catalog-declared platform streams and validate exact/latest resolution plus a genuine public installation.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `m-os/codex/graalvm-repository-adapter@2b26a461dc673c9e4c1990b62aaa8a41ab47a03f` (PR #13)
- `m-os/codex/p4-graalvm-local-order@d4b4e387c0748599b7389daa7cf75a18b64b42c3` (PR #20, exact validation head)
- `pkg-catalog/codex/p4-graalvm-version-index@50faddb36f9c3e7c12fa53d46b94dd8098fa857b` (PR #4, exact validation catalog)
- `rumiai-dev/codex/c2-account-defaults@be4f0fc4f8bc2b92de9485be8d3c6bfc756b86d6`

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
- The work is now published in draft PR #13; PR #20 adds the pinned GraalVM history index needed for installed facility ordering, and catalog PR #4 supplies that index. Fresh `git ls-remote` confirmed all three exact heads before validation.
- At exact `m-os@d4b4e387c0748599b7389daa7cf75a18b64b42c3` plus `pkg-catalog@50faddb36f9c3e7c12fa53d46b94dd8098fa857b`, the Linux ARM64 isolated clone passed the upstream diagnostic fixture, offline P4 facility-map fixture, exact and unversioned `pkg depend`, public exact-anchor install `graalvm@25.3.4.1` (status 0), and public unversioned stable-latest install (status 0). `pkg versions` showed both `graalvm@25.3.4.1!linux-arm64` and `graalvm@25.5.5.0.3!linux-arm64`; selecting the latter as Java provider made public `./m java -version` report GraalVM CE 25.5.5.0.3. Captured install logs and Java output are under `/m/src/git/chatgpt/tmp/graalvm-public-validation/`.
- Catalog history synchronization hosted run [42500901707](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42500901707) passed its sync job; this validates the catalog reconciler only, not the m-os public install workflow. GitHub reports no workflow run or status for m-os validation head `d4b4e387...`.

## Current state

The adapter, manual and workflow are in draft PR #13; the P4 ordering integration is stacked in draft PR #20, with its catalog history source in draft `pkg-catalog` PR #4. No PR was merged. All local writes for this validation are under `/m/src/git/chatgpt`; frozen `rumiai-os` and `rumiai-tests` were not accessed.

## Next action

Keep PRs #13, #20 and catalog #4 draft until the exact-current workflow and cross-platform obligations are reviewed. The local Linux ARM64 public exact/latest path is now complete. Determine an authorized hosted runner for the m-os install workflow (native m-os currently returns no Actions run); do not treat the catalog sync run as product acceptance. Validate declared x86_64/macOS/Windows streams only on matching real hosted targets; do not infer those from ARM64. Then update this handoff and the PR evidence without merging.

## Blockers / open questions

- Old `vm-` release tags must be mapped consistently with newer `graal-` tags before listing/comparison can claim completeness; fixtures cover the mapping, but per-stream historical API coverage remains bounded.
- Only Linux ARM64 was exercised locally. Linux x86_64, macOS ARM64 and Windows x86_64 still require matching hosted-platform validation; no hosted m-os install run is available at this checkpoint.
- The other missing catalog repository types (`chrome-for-testing`, `gpgtools`, and `podman`) have separate draft m-os PRs #16, #14 and #15; those adapter tasks and their acceptance remain independent.
