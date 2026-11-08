# GraalVM repository adapter

Status: Active — adapter/manual/workflow implemented; exact/latest public install and provider paths pass on Linux ARM64 and Linux x86_64; macOS/Windows scope remains in validation
Updated: 2026-11-08

## Goal

Implement the missing `graalvm` repository adapter for the four catalog-declared platform streams and validate exact/latest resolution plus a genuine public installation.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/graalvm-repository-adapter@73b238d42966c0da1d2aebb48b50bfba59b484cf` (draft [PR #13](https://github.com/massimilianonardi-ai/m-os/pull/13))
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `pkg-catalog/codex/m-os-adapter-runner@8e0e7d9d0ed274540b1ad1b2a68fb8ce455b1806` (test-only four-stream runner candidate)
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
- Final diff review caught and corrected the library manual's former statement that duplicate mapped versions fail closed; the manual now matches newest-chronology deduplication at `73b238d4`.
- On the isolated Ubuntu ARM64 checkout, the public CLI `./m pkg uninstall graalvm@25.3.4.1!linux-arm64` followed by `./m pkg install graalvm@25.3.4.1!linux-arm64` completed successfully. `pkg versions` and `pkg default` reported that concrete, and `./m java -version` ran the installed GraalVM 25.0.4.1 runtime. The run exercised the public package pipeline and genuine catalog artifact.
- Exact and latest public Linux ARM64 installation both pass. After the rate-limit endpoint recovered, `./m pkg install graalvm` installed the current `graalvm@25.5.5.0.3!linux-arm64`; `pkg default` and `pkg versions` agreed, and selecting that Java provider made `./m java -version` report GraalVM CE 25.5.5.0.3. The exact anchor 25.3.4.1 was also installed and ran earlier. The full releases endpoint is 5,477,123 bytes and public resolution took about 100 seconds locally; avoid unnecessary repeated API probes.
- Independent read-only source review found no concrete defect in the current adapter implementation. The workflow was corrected to install latest first and capture its concrete before installing the exact anchor, avoiding installed-current reuse.

## Current state

The adapter, manual and workflow are committed to `codex/graalvm-repository-adapter@73b238d4` and published as draft PR #13, based on exact `m-os/master@a78a24bd`. Exact and latest install/provider execution pass locally on Linux ARM64. Runner attempts [42487123865](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42487123865), [42487495004](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42487495004), and [42487697015](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42487697015) exposed harness issues: `pkg depend` does not print its root; exact Java execution must explicitly select the exact provider; direct use of the checkout's detached catalog caused `git pull` to fail; and cross-installing a Windows package through Linux reaches provider validation, so it cannot claim a Windows installation. Runner commit `8e0e7d9d0ed274540b1ad1b2a68fb8ce455b1806` also initializes core/json libraries before direct GraalVM metadata functions, fixing the evidenced harness failure in x86_64 artifact-only checks. Run [42488382382](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42488382382) on prior runner `843c478` had S1 and Chrome for Testing PASS, GraalVM Linux ARM64 PASS, GeoServer Ubuntu ARM64 PASS; GraalVM Linux x86_64 failed because the test shell had not loaded core/json functions, not because of an adapter assertion. ARM64/macos and other jobs had not all completed when the follow-up was started. New run [42488509763](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42488509763) on `8e0e7d9` passes Linux x86_64/ARM64 exact/latest install/provider, S1 composition, Chrome for Testing, GeoServer Ubuntu ARM64, Podman macOS ARM64, GPGTools macOS ARM64, and Windows artifact metadata. GraalVM and GeoServer macOS jobs remain in progress. Formal PR review remains open. This work is separate from GeoServer PR #12. All local writes are under `/m/src/git/chatgpt`; frozen `rumiai-os` and `rumiai-tests` were not accessed.

## Next action

Refresh run 42488509763 for GraalVM macOS and Windows metadata; inspect exact platform logs. Fix only evidenced issues; keep PR #13 draft and unmerged until latest, exact, supported-stream artifact and provider acceptance plus formal review are addressed.

## Blockers / open questions

- Native Windows execution/install is not established by the current `m-os` checkout; the Windows stream is limited to public target resolution and exact/latest asset metadata on Linux. Linux ARM64, Linux x86_64, and macOS ARM64 use native runners.
- The other missing catalog repository types (`chrome-for-testing`, `gpgtools`, and `podman`) remain separate TODO work.
- The other missing catalog repository types (`chrome-for-testing`, `gpgtools`, and `podman`) remain separate TODO work.
