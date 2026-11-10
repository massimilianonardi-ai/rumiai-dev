# GraalVM repository adapter

Status: Active — exact local Linux ARM64 and hosted Ubuntu x86_64/macOS ARM64/Windows x86_64 public exact/latest install/provider checks pass; forward integration remains pending
Updated: 2026-11-10

## Goal

Implement the missing `graalvm` repository adapter for the four catalog-declared platform streams and validate exact/latest resolution plus a genuine public installation.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `m-os/codex/graalvm-repository-adapter@2b26a461dc673c9e4c1990b62aaa8a41ab47a03f` (PR #13)
- `m-os/codex/p4-graalvm-local-order@d4b4e387c0748599b7389daa7cf75a18b64b42c3` (PR #20, exact validation head)
- `pkg-catalog/codex/p4-graalvm-version-index@50faddb36f9c3e7c12fa53d46b94dd8098fa857b` (PR #4, exact validation catalog)
- `pkg-catalog/codex/gpgtools-arm64-validation@da3588cbb8e1722a4d033468539d84c21f16c55d` (isolated hosted matrix runner; run 42786725669 attempt 2 PASS 2/2)
- `pkg-catalog/codex/gpgtools-arm64-validation@a72673b7d7efb9db8c26a47127df63ec12ea8e99` (isolated Windows runner; run 42809456571 PASS 1/1)
- `rumiai-dev/codex/c2-account-defaults@e9839589d237684241c12381636fd75277715405`

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
- Catalog history synchronization hosted run [42500901707](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42500901707) passed its sync job; separately, isolated product-path run [42786725669](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42786725669) attempt 2 passed on Ubuntu x86_64 and macOS ARM64 for exact `m-os@d4b4e387...` plus exact catalog `pkg-catalog@50faddb3...`. Both hosts passed diagnostics, P4 facility-map regression, exact/latest dependency planning, installs, version listings, Java-provider selection and `java -version` output for GraalVM CE 25.5.5.0.3. The first macOS attempt received HTTP 403 from the public latest-release API before install; rerun attempt 2 succeeded. This runner lives in pkg-catalog because m-os fork Actions is disabled; it is not a PR check.
- Exact-source Windows x86_64 public-path acceptance passed in isolated run [42809456571](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42809456571), runner commit `pkg-catalog@a72673b7d7efb9db8c26a47127df63ec12ea8e99`, pinning `m-os@d4b4e387c0748599b7389daa7cf75a18b64b42c3` and catalog `pkg-catalog@50faddb36f9c3e7c12fa53d46b94dd8098fa857b`. The job passed exact/latest dependency planning, installed `graalvm@25.3.4.1!windows-x86_64` and stable latest `graalvm@25.5.5.0.3!windows-x86_64`, verified the selected `java` provider and facility map, and executed `root/bin/java.exe`, which reported GraalVM CE 25.5.5.0.3. The runner also pins `core.autocrlf=false` so Git preserves the catalog's canonical LF data; an earlier failure exposed the archive's actual `root/bin/java.exe` path. This is hosted exact-source acceptance, not a check on PR #13/#20 or a merge.

## Current state

Fresh GitHub reads on 2026-11-10 confirmed `m-os` PR #13 is open/draft at `2b26a461...` over `master@a78a24bd...`; stacked PR #20 is open/draft at `d4b4e387...` over PR #13; and `pkg-catalog` PR #4 is open/draft at `50faddb3...` over `main@0b69223a...`. All three report clean/mergeable. Current `pkg-catalog/main@164b0644...` still lacks the GraalVM `repository/versions` history files, so catalog PR #4 remains needed for P4 offline facility ordering.

The adapter, manual and workflow are in draft PR #13; the P4 ordering integration is stacked in draft PR #20, with its catalog history source in draft `pkg-catalog` PR #4. Linux ARM64, hosted Ubuntu x86_64, macOS ARM64 and Windows x86_64 exact/latest acceptance now pass on the recorded revisions. No PR was merged and no integrated `m-os/master` acceptance is claimed. All local writes for this validation are under `/m/src/git/chatgpt`; frozen `rumiai-os` and `rumiai-tests` were not accessed.

## Next action

Keep PRs #13, #20 and catalog #4 draft. The exact-source public-path matrix now covers Linux ARM64 local plus hosted Ubuntu x86_64, macOS ARM64 and Windows x86_64. Continue the forward integration/review plan with the current composed P2/P3/P4/V2 source and catalog, preserving related `pkg-install.lib.sh`/manual changes; do not merge or claim integrated acceptance until all applicable gates and exact-head reviews are satisfied.

## Blockers / open questions

- Old `vm-` release tags must be mapped consistently with newer `graal-` tags before listing/comparison can claim completeness; fixtures cover the mapping, but per-stream historical API coverage remains bounded.
- The hosted runs are isolated exact-source acceptance in pkg-catalog, not checks attached to PR #13 because Actions is disabled on m-os. Integrated mainline acceptance remains open.
- The other missing catalog repository types (`chrome-for-testing`, `gpgtools`, and `podman`) have separate draft m-os PRs #16, #14 and #15; those adapter tasks and their acceptance remain independent.
