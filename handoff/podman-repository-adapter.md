# Podman repository adapter

Status: Active — deterministic fixture and hosted exact/latest macOS ARM64 public-path validation PASS; draft product/catalog PRs remain unmerged; adapter integration and wider m-os acceptance remain open
Updated: 2026-11-08

## Goal

Implement and validate the Podman repository type for the catalog's single macOS ARM64 package stream.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`; PR #15 branch `codex/podman-repository-adapter@17188da89999f410740036d399144a008c127417`
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`; candidate catalog branch `codex/podman-current-catalog@c8a39f8bd099d65ed8520de574800f220d6119e1`
- runner `pkg-catalog/codex/m-os-adapter-runner@979a9397b6c7828bf7118edfc78bb364d72206f6`
- `rumiai-dev/main@d005123d7a2d2d1d1f8b65ebf0de2b8ca334b2c1` is the latest fetched main; this forward-only working branch reconciles it before the new handoff checkpoint.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`
- `TESTING.md`, `handoff/README.md`
- Exact pinned catalog `v1/pkg/podman/macos-arm64` and current m-os GitHub adapter/manual/extractor

## Fixed task-local choices

- Limit support to the catalog-declared Podman macOS ARM64 installer and its declared SHA-256, flat-package extraction and `podman` command link. The catalog candidate advances the stale v6.1.2 anchor to verified official stable v6.1.4; exact v6.1.3 remains in the catalog supported range.
- Do not imply Linux/Windows support or broaden the catalog stream.
- Preserve package-integrity and failed-install cleanup behavior of the existing public `pkg install` pipeline.

## Acceptance scenarios

- On macOS ARM64, public exact/latest dependency resolution for the catalog stream installs the genuine official exact v6.1.3 and latest v6.1.4 artifacts, verifies integrity and exposes the declared `podman` command.
- Corrupt/mismatched metadata or an unavailable exact asset fails closed without a partial installed concrete.

## Completed

- Activated the deferred TODO into this handoff after confirming the gap against current exact master/catalog and current source inventory.

## Current state

Draft PR [#15](https://github.com/massimilianonardi-ai/m-os/pull/15) is open and unmerged at `17188da89999f410740036d399144a008c127417`. It filters only exact `vN.N.N-rcN` tags incorrectly marked stable, keeps unknown malformed stable tags fail-closed, resolves exact versions by tag endpoint, compares two exact releases without enumerating history, and makes one request per metadata endpoint. The manual documents this boundary; indiscriminate retries were removed because `http-fetch` does not expose a reliable transient-vs-rate-limit signal. Local metadata fixtures passed against official v6.1.3/v6.1.4 data and the mislabeled v1.7.0-rc1 tag; shell syntax and `git diff --check` passed.

Catalog candidate branch [`codex/podman-current-catalog`](https://github.com/massimilianonardi-ai/pkg-catalog/tree/codex/podman-current-catalog) is `c8a39f8bd099d65ed8520de574800f220d6119e1`, based on the pinned catalog main. It advances only Podman's repository anchor to official stable v6.1.4, with URL and SHA-256 verified from the official GitHub release metadata; the existing supported range retains v6.1.3. Draft catalog PR [#3](https://github.com/massimilianonardi-ai/pkg-catalog/pull/3) is open and unmerged; the candidate is not promoted.

Hosted runner branch [`codex/m-os-adapter-runner`](https://github.com/massimilianonardi-ai/pkg-catalog/tree/codex/m-os-adapter-runner) is `979a9397b6c7828bf7118edfc78bb364d72206f6`; it pins exact product head `17188da89999f410740036d399144a008c127417` and exact catalog candidate `c8a39f8bd099d65ed8520de574800f220d6119e1`. Hosted run [42475899386](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42475899386) completed **3/3 PASS**: the Podman job installed and ran stable latest v6.1.4, then installed and ran exact v6.1.3, and listed both installed concretes; GPGTools exact artifact/public `gpg --version` on macOS ARM64 and Chrome for Testing exact/latest artifact/public `chromium --version` on Linux ARM64 also passed. This supersedes the earlier 403/504 pending checkpoint below; prior runs [42473705949](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42473705949), [42473174743](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42473174743), and [42473039971](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42473039971) document superseded failures/harness corrections. Product PR #15 and catalog PR #3 remain draft and unmerged; the runner is validation infrastructure, not product/catalog promotion. Exact hosted evidence closes the scoped Podman acceptance scenarios in this handoff, but does not close adapter integration, all M01–M15, or I1.
A prior command-validation syntax check created `/tmp/workflow-run-shell-check`, outside the user's permitted local-write root `/m/src/git/chatgpt`; the cleanup attempt was rejected by the execution layer, so that path may remain. No subsequent local filesystem writes were made outside the authorized root. All product/catalog/runner/handoff writes in this continuation were confined to `/m/src/git/chatgpt`.

## Next action

Keep PR #15 and catalog PR #3 unmerged pending integration policy; update the runner/product PR descriptions if a supported edit path becomes available. Continue the independent nonprivileged devplan gates in the orchestration handoff; do not dispatch A1–A4 hosted workflows.

## Blockers / open questions

- Live GitHub API requests returned repeated HTTP 504 in both local and hosted runs; exact/latest live resolution is not established in this environment.
- Genuine macOS ARM64 package install and public command evidence remains required.
