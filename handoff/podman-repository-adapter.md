# Podman repository adapter

Status: Active — exact-head deterministic fixture and isolated hosted macOS ARM64 install/default/version/CLI acceptance pass; feature integration remains pending
Updated: 2026-11-10

## Goal

Complete bounded `podman` repository support for the catalog's macOS ARM64 stream and validate the installed CLI through public `m` commands on macOS ARM64.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/podman-repository-adapter@4ac43658096b5e484f218190186c477d63b30153` (draft PR #15)
- `pkg-catalog/codex/gpgtools-arm64-validation@0b5a79f83f78b1818bbd8426f56ef889732e1a48` (isolated hosted macOS runner; run 42785957757 PASS)
- `pkg-catalog@c8a39f8bd099d65ed8520de574800f220d6119e1` (exact Podman catalog anchor commit; parent is `main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`)
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
- Isolated macOS runner `pkg-catalog/codex/gpgtools-arm64-validation@0b5a79f83f78b1818bbd8426f56ef889732e1a48` checks out exact PR #15 source `4ac43658...` and exact catalog anchor `c8a39f8...`, then exercises the public path. Hosted run [42785957757](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42785957757) passed: the fixture passed; `pkg install podman` selected `podman@v6.1.4!macos-arm64`, ran `podman version 6.1.4`; exact `podman@v6.1.3` install/default ran `podman version 6.1.3`; `pkg versions` listed both concretes. No privileged host operation was used.
- No Podman product files were modified during validation; only an isolated `pkg-catalog` acceptance workflow was added.

## Current state

- The fixture covers exact/latest metadata, chronology, unsupported tags, request failures and catalog anchor metadata.
- `m-os` fork Actions is disabled, so the successful result is not attached as a PR check; the isolated runner validates exact source and catalog revisions.
- The adapter is absent from `m-os/master` and remains unsupported on the mainline pending normal forward integration and exact integrated-source validation.

## Next action

Continue forward-integration planning against current `m-os` master and PR #15. Do not claim Podman adapter support on mainline until the feature is integrated and the resulting exact product revision is validated.

## Blockers / open questions

- PR #15 itself has no hosted check because Actions is disabled on the fork; exact-source hosted acceptance was completed via the isolated `pkg-catalog` runner.
