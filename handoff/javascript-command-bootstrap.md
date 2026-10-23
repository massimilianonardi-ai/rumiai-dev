# Native interpreter command migration

Status: Active
Updated: 2026-10-23

## Goal

Migrate m-dependent commands and package launchers from the sourced `#!/usr/bin/env m` model to native interpreter entrypoints. Keep `m` as the environment bootstrap and dispatch point, preserve native argument/status semantics and canonical command identity, and publish the migration only when runtime, catalog, specifications, tests and installed-package rollout are coherent.

## Current revisions (verified 2026-10-23)

| Repository | Current main | Staged branch | Staged HEAD |
| --- | --- | --- | --- |
| rumiai-dev | `0c06a1670e385f0c931f54b7e5621ab0d00b7c0f` before this handoff update | `m-native-command-contract` | `6775d5c156ea39f7da05d9012ade56880fd19e7c` |
| rumiai-os | `5ca07aeb26dbc04c0b38998bb05edacd8587a977` | `m-native-command-dispatch` | `3b5d6019db0cf1b4c419792aef36b4bee12037cb` |
| rumiai-tests | `02eb2c25221f6d399e6ed22c6d668824fa2a8b9d` | `m-native-command-tests` | `a0048a8680ffe02736e0305ffbae3e5406504811` |
| pkg-catalog | `b08023f378dc4d773a539b1910e7fc20313cd976` | `m-native-command-launchers` | `893120694670ac91e67353797ca3602d8f2b330b` |

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

Real GitHub-hosted execution paired the exact staged `rumiai-os` and `pkg-catalog` revisions above with the exact triggering test suite revision. All staged workflows are confined to the feature branch and have not modified the compatible public `main` runtime/catalog.

- **Latest full targeted native regression:** [GitHub Actions run 39948858625](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39948858625), test-suite commit `a0048a8680ffe02736e0305ffbae3e5406504811`. Ubuntu 26.04 ARM64: **37 PASS, 0 FAIL, 1 SKIP**; macOS ARM64: **37 PASS, 0 FAIL, 1 SKIP**. Both jobs succeeded. The SKIP is `mk/lifecycle.test` without the managed Node execution requirement in this general-purpose runner. Tests exercised dispatcher/identity, bootstrap, pkg-launch, pkg-integration, log, lang, jsc, srv lifecycle/provider. Both hosts also ran `sh -n` over all staged catalog `cmd/` entrypoints and all `env` sources.
- **Latest managed Node installed/runtime validation:** [GitHub Actions run 39948480452](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39948480452), test-suite commit `9fde6fa9dc409cbdcd4edbe7feb23ee7fd53de89`. Real `m pkg install nodejs@v26.8.2` from a Git repository checkout pinned to `pkg-catalog` `893120694670ac91e67353797ca3602d8f2b330b`, then `m pkg default nodejs@v26.8.2` and `m node --version`, succeeded on **both Ubuntu ARM64 and macOS ARM64**. The permanent tests `pkg-launch/managed-node.test`, `mk/lifecycle.test` and `jsc/compiler-loader.test` each returned PASS on each host (**6 PASS, 0 FAIL, 0 SKIP**). `managed-node.test` checks that `process.execPath` resolves beneath the selected managed concrete root, `m_ROOT` is correct and no `m_COMMAND_BIN` is inherited. No host Node replacement was used.
- The live-install validation exposed a genuine catalog incompatibility: 12 package `env` sources (Node.js on six osarch streams plus chromium, geoserver, macgpg, playwright and podman) were still deriving the concrete location from obsolete `m_COMMAND_BIN`. They were migrated in `pkg-catalog` commit `893120694670ac91e67353797ca3602d8f2b330b` to the existing validated launcher-local `pkg_launch_root`; the ownership contract was added to staged `PACKAGE-MODEL.md` and the `pkg-launch.lib.sh` operational manual. The permanent pkg-launch contract test also verifies canonical root availability and absence of `m_COMMAND_BIN`.
- Earlier failed runs remain historical evidence, not PASS: initial failure was `package-env-invalid` on both hosts; a later macOS run failed with an HTTP 403 from the public GitHub releases endpoint while Linux passed. A subsequent unchanged artifact request succeeded in the final macOS run. The newly created managed Node regression test initially failed due to non-executable GitHub file mode; it was corrected forward with mode `100755` before the successful run.
- **Evidence limits:** These are authentic GitHub-hosted runner tests of the exercised behavior, not formal full-product validation or validation on project-owned physical hosts. They do not prove service installation through real host supervisors, all package types or reinstall/rollout safety of existing concretes.

## Next action

1. Conduct proportionate formal/revision-pinned and physical validation on applicable project-owned hosts, especially native entrypoints, service host registrations and existing concrete package migrations.
2. Define and test coordinated upgrade/rollout of the currently installed package concretes. Existing installed copies retain their old `#!/usr/bin/env m` launchers and obsolete `env` sources, so they must be removed and reinstalled using the canonical package model; do not overwrite immutable concrete package content in place.
3. Re-scan other permanent tests for any old shebang or identity assumptions not exercised by the targeted runs, and reconcile current manual/specification mismatches if found.
4. After all compatibility gates, reconcile the four branches forward before any integration into `main`. Do not merge dependent runtime/catalog stages independently.

## Open constraints

- `rumiai-dev/main` remains the canonical contract for the currently published runtime; the approved replacement is staged, not yet published.
- `pkg-catalog/main` and `rumiai-os/main` retain mutually compatible old behavior; independently merging either migration branch would break consumers.
- Real catalog-backed managed Node install and native launch have passed on both GitHub-hosted reference OS/architecture environments. Physical validation on project-owned hosts and installed-concrete rollout remain pending.
