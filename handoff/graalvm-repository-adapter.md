# GraalVM repository adapter

Status: Active — exact-stack Linux x86_64 and macOS ARM64 acceptance pass against the current catalog candidate; Windows catalog data is verified but its hosted POSIX runtime gate remains blocked; forward integration remains pending
Updated: 2026-11-13

## Goal

Implement the missing `graalvm` repository adapter for the four catalog-declared platform streams and validate exact/latest resolution plus genuine public installation.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/graalvm-repository-adapter@2b26a461dc673c9e4c1990b62aaa8a41ab47a03f` (PR #13, open/draft)
- `m-os/codex/p4-graalvm-local-order@d4b4e387c0748599b7389daa7cf75a18b64b42c3` (PR #20, open/draft, stacked on #13)
- `pkg-catalog/main@1559223f4e3e6d1764ebbf0b7f136a2dfbefdf3b`
- `pkg-catalog/codex/graalvm-version-index-current-main@0ad85c3a133534b8637611ddbea15ff5609a1bde` (PR #5, open/draft, based on current main)
- `pkg-catalog/codex/graalvm-m-os-current-catalog-validation@afcb7b73bce7bc0cc02252dd2dc80da33f7b6148` (PR #9, open/draft, read-only validation runner)
- `rumiai-dev/codex/m-os-completion-progress@2f275b7f2b86c150d092131cd9434374515311cc`

## Applicable canonical sources

- `rumiai-dev/README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `handoff/README.md`
- `rumiai-dev/specifications/rumiai-os/PACKAGE-MODEL.md`
- `pkg-catalog/v1/pkg/graalvm` at the pinned catalog candidate
- Current `m-os` repository-adapter interface and manuals

## Fixed choices

- Upstream authority is the official `graalvm/graalvm-ce-builds` GitHub Releases API; ordering uses stable release chronology, not numeric/semver sorting.
- Catalog package versions and upstream release tags differ: package `25.3.4.1` maps to `graal-25.3.4.1`; archive filenames use a separate embedded JDK version.
- Select exactly one binary matching the catalog archive regex for the current OS/architecture; require positive size and SHA-256 metadata; exclude sidecars.
- Supported catalog streams are `linux-arm64`, `linux-x86_64`, `macos-arm64`, and `windows-x86_64` only.
- Normalize exactly one `graal-`, `jdk-`, or `vm-` prefix. For aliases mapping to one package version, choose the newest `(created_at, published_at)` chronology and fail closed on equal chronology. The selected release must still provide one exact catalog-matching binary per supported target with size and SHA-256.

## Acceptance scenarios

- Public exact and unversioned dependency requests resolve a compatible GraalVM Java provider on supported targets.
- Installing the catalog anchor and current stable latest obtains genuine artifacts with verified metadata.
- Installed packages report the selected release and expose Java commands through the provider path.

## Completed

- Implemented the adapter and manual in draft m-os PR #13; PR #20 adds catalog history-index validation and offline facility-map ordering. Catalog PR #5 ports the four version indexes and history synchronizer onto current catalog main.
- Pinned fixtures cover tag normalization, chronology and ties, exact asset matching, all four streams, and offline P4 facility ordering.
- Current-catalog exact-stack hosted run [43393384097](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/43393384097), runner PR #9 head `afcb7b73bce7bc0cc02252dd2dc80da33f7b6148`, pins product PR #20 `d4b4e387c0748599b7389daa7cf75a18b64b42c3` (contains exact PR #13 head `2b26a461dc673c9e4c1990b62aaa8a41ab47a03f`) and catalog PR #5 `0ad85c3a133534b8637611ddbea15ff5609a1bde`, based on current main `1559223f4e3e6d1764ebbf0b7f136a2dfbefdf3b`.
- Linux x86_64 and macOS ARM64 passed current-catalog exact pin/base checks, four-stream index equality, adapter diagnostics and P4 offline-order fixtures, exact/latest planning, exact anchor `25.3.4.1` and live latest `25.5.5.0.3` installs, version listing, provider selection, and `m java -version`.
- A preceding macOS attempt in [run 43393068094](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/43393068094) received HTTP 403 from the live latest API; its single bounded rerun passed the complete path. The final full matrix run 43393384097 also passed.
- Windows x86_64 passed exact pin/base and four-stream index-equality checks. GitHub `windows-2025` Git Bash did not retain POSIX selector symlinks after `m osarch update`; the subsequent `m osarch` failed `filesystem.path-invalid` at `bin/sys-osarch`. The runner now warns and skips adapter fixtures, planning, installation and CLI on this host. Windows runtime acceptance is not claimed against the current catalog candidate. Earlier Windows public install evidence [42809456571](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42809456571) used the prior catalog candidate and is not current-candidate evidence.
- Runner PR #9 has `contents:read`, no publish step and no product/catalog main changes. No PR was merged.

## Current state

PRs #13, #20, #5 and validation-only #9 remain open/draft. The local history-comparison contract is covered only by the composed #13/#20 stack plus catalog history candidate #5; PR #13 alone queries upstream for comparisons that the catalog can answer locally. Exact-stack current-catalog public-path validation passes on Linux x86_64 and macOS ARM64. Windows catalog data is verified, but the hosted Git Bash environment cannot run the POSIX runtime path. No integrated `m-os/master` acceptance is claimed.

## Next action

Find a supported Windows POSIX environment for the exact current-catalog adapter path, or retain the Windows runtime limitation explicitly if no hosted toolchain can provide it. Then complete independent review and forward integration validation across the composed current m-os/catalog stack; keep all product/catalog PRs draft until required gates pass.

## Blockers / open questions

- Current Windows hosted runner lacks working POSIX selector links for `m osarch`; current-candidate adapter/install/CLI acceptance remains open.
- Direct m-os PR checks remain unavailable because Actions are disabled there; isolated pkg-catalog hosted evidence is not a PR check or integrated mainline evidence.
- Catalog history indexes in PR #5 and adapter/order changes in PRs #13/#20 remain unmerged.
- Chrome for Testing, GPGTools and Podman adapters have separate active PRs and acceptance paths.
