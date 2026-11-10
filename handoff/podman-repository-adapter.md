# Podman repository adapter

Status: Active — exact-head deterministic fixture passes; public macOS ARM64 installation remains pending
Updated: 2026-11-10

## Goal

Complete bounded `podman` repository support for the catalog's macOS ARM64 stream and validate the installed CLI through public `m` commands on macOS ARM64.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/podman-repository-adapter@4ac43658096b5e484f218190186c477d63b30153` (draft PR #15)
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `rumiai-dev/codex/c2-account-defaults@8f3e3b80` (latest checkpoint at creation)

Refresh remote heads before further work.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `handoff/README.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- The current `m-os` repository-adapter interface and operational manual
- `pkg-catalog/v1/pkg/podman/macos-arm64` at the pinned catalog revision

## Fixed scope

- Support only the declared Podman macOS ARM64 stream and its official installer metadata.
- Do not infer other platform formats or change catalog scope.
- Keep all local writes under `/m/src/git/chatgpt`.
- Do not run a workflow or public install that performs privileged host materialization without the separately required authorization.

## Acceptance scenarios

- Exact and stable latest release metadata resolve through the public package adapter.
- Unsupported/malformed release requests fail closed with distinct diagnostics.
- On macOS ARM64, public `pkg install`, default selection, version listing and `m podman --version` verify the real installed package.

## Completed

- Exact remote head was fetched into an isolated worktree at `4ac43658096b5e484f218190186c477d63b30153`; catalog `main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442` was freshly fetched.
- `sh -n` and `git diff --check` passed for the adapter and fixture.
- The deterministic fake-transport fixture passed at the exact PR head with `PODMAN_FIXTURE_CATALOG` set to the exact catalog checkout: `PASS: Podman release fixtures, stable tag filtering, exact/latest chronology and anchor asset metadata`.
- No product files were modified during validation.

## Current state

- The fixture covers exact/latest metadata, chronology, unsupported tags, request failures and catalog anchor metadata.
- GitHub reports no hosted run/status for this PR head. The configured workflow requires actual macOS ARM64 `pkg install`; Linux fixture success is not install acceptance.
- The adapter is absent from `m-os/master` and remains unsupported on the mainline.

## Next action

Verify exact PR #15 workflow status through the canonical repository. Complete real public installation and CLI checks only on macOS ARM64 through the authorized, nonprivileged path; keep PR #15 draft/unmerged pending that evidence.

## Blockers / open questions

- This host is Linux ARM64, not the catalog's macOS ARM64 target.
- Hosted status and real package installation remain unverified.
