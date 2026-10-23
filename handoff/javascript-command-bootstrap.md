# Native interpreter command migration

Status: Active
Updated: 2026-10-23

## Goal

Migrate m-dependent commands and package launchers from the sourced `#!/usr/bin/env m` model to native interpreter entrypoints. Keep `m` as the environment bootstrap and dispatch point, preserve native argument/status semantics and canonical command identity, and publish the migration only when runtime, catalog, specifications, tests and installed-package rollout are coherent.

## Current revisions (verified 2026-10-23)

| Repository | Current main | Staged branch | Staged HEAD |
| --- | --- | --- | --- |
| rumiai-dev | `0c06a1670e385f0c931f54b7e5621ab0d00b7c0f` before this handoff update | `m-native-command-contract` | `2f677632586e6ec018c2093f8a04c9af7d6ab00b` |
| rumiai-os | `5ca07aeb26dbc04c0b38998bb05edacd8587a977` | `m-native-command-dispatch` | `f8f8acea460aa9bc024e5fed0ab04a350431b3e7` |
| rumiai-tests | `02eb2c25221f6d399e6ed22c6d668824fa2a8b9d` | `m-native-command-tests` | `67fe44ea2e3dd78dc214b2dacf64588ae1749783` |
| pkg-catalog | `b08023f378dc4d773a539b1910e7fc20313cd976` | `m-native-command-launchers` | `304ab8e4fedbef543f68f9d63e60854f80c9cb7c` |

Refresh every remote HEAD before further work. Do not assume these SHAs remain branch HEADs.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `RUNNER.md` and `PHYSICAL-TESTING.md`.
- The current specification router, then the relevant bootstrap, command-entrypoint, root-resolution, package, library, diagnostic, portability and documentation specifications.
- For the approved *new* contract pending coordinated publication, read `rumiai-dev/m-native-command-contract`; `rumiai-dev/main` still describes the old published implementation.

## Fixed task-local decisions

- Environment-dependent commands use their native interpreter (POSIX shell `#!/bin/sh`, Node.js when applicable), require nonempty `m_ROOT`, and may run as `m <command>` or directly in an inherited initialized m environment. An interactive m shell is not a prerequisite.
- Shell commands load needed libraries in their own process. Shell functions are not inherited across native process boundaries.
- The bootstrap does not inspect special shebangs or source command files. `m_COMMAND_BIN` no longer supplies an inherited command identity; the native command resolves its own invocation identity.
- Preserve the current compatible `main` branches while the migration is staged. Git work stays forward-only; do not merge runtime/catalog changes independently.
- This task is separate from `javascript-build-and-runtime-loading`.

## Staged implementation

- `rumiai-os`: native external dispatch in root `m`; 26 `bin/sys` commands and their manuals converted; `pkg-launch.lib.sh` and `srv` identify the invoking native command using canonical resolution of `$0`; root `m` manual updated. Intentional standalone utilities remain standalone.
- `pkg-catalog`: all 114 executable package launchers converted across 25 distinct source bodies; macgpg's remaining `m_COMMAND_BIN` use removed. Facility marker files were not changed.
- `rumiai-dev/m-native-command-contract`: staged changes to `RULES.md` and eight relevant specifications, including `COMMAND-ENTRYPOINTS.md`, `BOOTSTRAP-ENVIRONMENT.md`, `CURRENT-MODEL.md`, `MK.md` and `JSC.md`. These have **not** replaced canonical `main`.
- `rumiai-tests/m-native-command-tests`: native command probes, package integration/launch fixtures, bootstrap checks, srv lifecycle/provider assertions, and other migrated suite cases. `lib/rumiai-os-target.lib` no longer creates an `env m` wrapper to enter m.

## Revision-specific validation evidence

Real GitHub-hosted execution used the exact staged `rumiai-os` and `pkg-catalog` revisions above and the test-suite SHA attached to each workflow run. Dedicated workflow: `rumiai-tests/.github/workflows/native-command-staged.yml` on the staged test branch.

- Final two-host run: `https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39942872301`, suite SHA `67fe44ea2e3dd78dc214b2dacf64588ae1749783`; Ubuntu 26.04 ARM64: **37 PASS, 0 FAIL, 1 SKIP**; macOS latest: **37 PASS, 0 FAIL, 1 SKIP**. Both GitHub Actions jobs concluded success.
- Prior successful two-host run `39942392118` at suite SHA `a29a9150d4922c0be18406bc2d21859a5ecd22c8` obtained the same 37 PASS / 1 SKIP per host.
- Tested groups: 7 command dispatch/identity tests, 16 bootstrap tests, 1 real package-launch test, 1 real package-integration test, 5 log tests, 4 lang tests, 1 jsc/compiler-loader test, 2 srv lifecycle/provider tests, and 1 `mk/lifecycle` test returning SKIP on each host. The latter SKIP was caused by lack of a configured managed Node.js provider.
- Both host jobs also ran `sh -n` over every executable package launcher source under the staged `pkg-catalog/pkg/**/cmd` tree (static syntax check only).
- Failures in earlier runs were investigated and reconciled forward: initial workflow selection paths, product-origin normalization for canonical test discovery, and outdated `bootstrap/library-loading` and `srv` fixtures/identity assertions. Earlier runs are not relabelled as PASS.
- **Scope limit:** package tests used real m/package integration code with synthetic provider/payload inputs. No real catalog-backed installation or already-installed concrete migration has been exercised. `mk` with managed Node was not exercised. GitHub-hosted runs are auxiliary execution evidence, **not** physical validation on project-owned stable hosts, and not full-product validation.

## Next action

1. Validate a real managed Node.js package installation and launch using the exact staged catalog snapshot with the paired staged runtime; run `m mk` and `m jsc` through the real managed Node path and verify no implicit host Node fallback.
2. Reconcile any remaining legacy-shebang fixtures and current manuals/specification mismatches exposed by wider targeted or formal validation; execute proportional revision-pinned suites on all applicable reference hosts.
3. Plan coordinated rollout: existing installed package concretes retain old copied launchers and must use the current supported uninstall/reinstall integration path. Do not in-place overwrite immutable concrete files.
4. Only after that gate, reconcile all four repositories forward and plan compatible merges. No staged branch has been merged into `main`.

## Open constraints

- `rumiai-dev/main` remains the canonical contract for the currently published runtime; the approved replacement is staged, not yet published.
- `pkg-catalog/main` and `rumiai-os/main` retain mutually compatible old behavior; independently merging either migration branch would break consumers.
- Managed Node/catalog real-install evidence, physical validation and installed-concrete rollout are pending.
