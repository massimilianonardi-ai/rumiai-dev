# GPGTools repository adapter

Status: Active — deterministic fixture, public Linux ARM64 exact/latest dependency resolution, and isolated hosted macOS ARM64 install/CLI acceptance pass; feature integration remains pending
Updated: 2026-11-10

## Goal

Complete bounded `gpgtools` support for the existing `macgpg/macos-arm64` catalog stream and validate it through public `m` commands on macOS ARM64.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `m-os/codex/gpgtools-repository-adapter@cd54a908530e5b53179ed47e849f8a91d771a339` (draft PR #14; exact source passed isolated hosted macOS acceptance)
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `pkg-catalog/codex/gpgtools-arm64-validation@2d832e9ceb67b8cb0521e412b863b2cec2a4e5c1` (isolated hosted macOS runner; run 42785101042 PASS)
- `rumiai-dev/codex/c2-account-defaults@eab46707dc7b6e5ec6fd75e4d88e38931325635b` (pre-update checkpoint; refresh before next write)

Refresh remote heads before further work.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `handoff/README.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- The current `m-os` repository-adapter interface and operational manual
- `pkg-catalog/v1/pkg/macgpg/macos-arm64` at the pinned catalog revision

## Fixed scope

- Support only the catalog-declared `gpgtools` type for `macgpg/macos-arm64`.
- Preserve the current pinned artifact contract and fail closed when live metadata changes unexpectedly.
- Keep all local writes under `/m/src/git/chatgpt`.
- No privileged install or workflow execution unless the separate operator-privileged TODO is explicitly reactivated.

## Acceptance scenarios

- Public exact dependency/install resolves the catalog pin and verifies artifact metadata on macOS ARM64.
- Public latest resolution reads the live listing and preserves the catalog's version-range meaning.
- Malformed listing and upstream fetch failure produce distinct expected statuses and diagnostics.

## Completed

- PR #14 contains the adapter, manual, deterministic fixture and macOS workflow; current remote head is `cd54a908`.
- `sh -n` for the adapter and fixture and `git diff --check` passed at the exact PR head.
- The first fixture invocation failed because the m-os clone has no embedded `catalog/` checkout. Rerunning at the same exact source with `GPGTOOLS_FIXTURE_CATALOG` pointed to the fresh `pkg-catalog/main@0b69223a` checkout passed: `PASS: GPGTools fixture parsing, exact anchor, live latest, artifact metadata and distinct upstream failure diagnostics`.
- On Linux ARM64, the exact adapter checkout's public `./m pkg depend 'macgpg@2026.1+3633n!macos-arm64'` exited 0 against catalog main `0b69223a`. Public latest request `./m pkg depend 'macgpg!macos-arm64'` also exited 0 after the disposable test clone's catalog cache was placed on tracking branch `main`; the package has no declared dependencies, so both plans emitted no dependency rows. An initial latest attempt failed in the isolated harness because its detached catalog cache had no upstream branch; no product change was made. This demonstrates public exact/latest planning on this host and catalog revision, not artifact download, installation, or CLI execution.
- The macOS workflow at `cd54a908` validates that the catalog checkout and `origin/main` both equal pinned `0b69223a`, creates a tracking `main` branch so repeated public `pkg` operations can pull, and runs public latest dependency planning before exact install. YAML parsing and `git diff --check` passed; the detached-checkout/tracking-branch sequence was rehearsed locally against that exact catalog SHA.
- Pushing `cd54a908` did not start Actions. The visible GitHub Actions page states that workflows are not currently run on this fork because of Actions usage scale and that a repository maintainer may re-enable them. No hosted result exists for this head.
- No adapter/runtime source changed in this continuation; the macOS workflow was corrected at `cd54a908` to preserve the exact pinned catalog across repeated public commands.

## Current state

- The fixture is deterministic and uses a fake `http-fetch`; the hosted public macOS workflow complements it with live resolution, verified exact artifact installation and packaged CLI execution.
- The `m-os` fork Actions remains disabled. The successful result belongs to the separate `pkg-catalog` runner branch and validates the exact adapter source, but does not create a check on PR #14 itself.
- The adapter is absent from `m-os/master` and remains unsupported on the product mainline pending normal forward integration and exact integrated-source validation.

## Next action

Continue with integration planning against the current `m-os` master and PR #14 heads. Do not claim adapter support on `m-os/master` until forward integration and validation of the resulting exact product revision are complete.

## Blockers / open questions

- PR #14 itself has no hosted check because Actions is disabled on the fork; hosted exact-source acceptance was completed through the isolated `pkg-catalog` runner.
