# Native interpreter command migration

Status: Active
Updated: 2026-10-23

## Goal

Migrate m-dependent commands and package launchers from the sourced `#!/usr/bin/env m` model to native interpreter entrypoints. Keep `m` as the environment bootstrap and dispatch point, preserve native argument/status semantics and canonical command identity, and preserve coordinated repository publication while leaving deployed-host package reintegration as a separately controlled maintenance operation.

## Current revisions (2026-10-23 publication)

| Repository | Published `main` before this handoff commit | Staged branch | Staged checkpoint |
| --- | --- | --- | --- |
| rumiai-dev | `73b07e4cfe5dff8404076e63dbb7ad41c2acac50` | `m-native-command-contract` | `9d1ccaef3a11cc368fdbe8971b1d50691e400003` |
| rumiai-os | `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195` | `m-native-command-dispatch` | `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195` |
| rumiai-tests | `1e45b0e893216a3ef4ea8469a3462610f30b8de0` | `m-native-command-tests` | `13b5690db43a314b107deefab8eef1ab8f59cf17` |
| pkg-catalog | `893120694670ac91e67353797ca3602d8f2b330b` | `m-native-command-launchers` | `893120694670ac91e67353797ca3602d8f2b330b` |

Refresh every remote HEAD before further work. Do not assume these SHAs remain branch HEADs.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `RUNNER.md` and `PHYSICAL-TESTING.md`.
- The current specification router, then the relevant bootstrap, command-entrypoint, root-resolution, package, library, diagnostic, portability and documentation specifications.
- `rumiai-dev/main` now contains the published native-entrypoint contract. The feature branches are prior implementation evidence only, not canonical.

## Fixed task-local decisions

- Environment-dependent commands use their native interpreter (POSIX shell `#!/bin/sh`, Node.js when applicable), require nonempty `m_ROOT`, and may run as `m <command>` or directly in an inherited initialized m environment. An interactive m shell is not a prerequisite.
- Shell commands load needed libraries in their own process. Shell functions are not inherited across native process boundaries.
- The bootstrap does not inspect special shebangs or source command files. `m_COMMAND_BIN` no longer supplies an inherited command identity; the native command resolves its own invocation identity.
- Native runtime and package catalog are now published together across their repositories; deployed installations still require a dependency-aware, planned concrete reinstall. Git history remains forward-only.
- This task is separate from `javascript-build-and-runtime-loading`.

## Published implementation

- `rumiai-os`: native external dispatch in root `m`; 26 `bin/sys` commands and their manuals converted; `pkg-launch.lib.sh` and `srv` identify the invoking native command using canonical resolution of `$0`; root `m` manual updated. Intentional standalone utilities remain standalone.
- `pkg-catalog`: all 114 executable package launchers converted across 25 distinct source bodies; macgpg's remaining `m_COMMAND_BIN` use removed. Facility marker files were not changed.
- `rumiai-dev/main`: `RULES.md` and eight relevant specifications, including `COMMAND-ENTRYPOINTS.md`, `BOOTSTRAP-ENVIRONMENT.md`, `CURRENT-MODEL.md`, `MK.md` and `JSC.md`, were merged from the staged branch, preserving concurrent TODOs and handoffs.
- `rumiai-tests/main`: native command probes, package integration/launch fixtures, bootstrap checks, srv lifecycle/provider assertions, and other migrated suite cases. `lib/rumiai-os-target.lib` no longer creates an `env m` wrapper. Staged-only temporary GitHub workflows were excluded from the main merge.

## Revision-specific validation evidence

Prepublication GitHub-hosted execution paired the exact staged `rumiai-os` and `pkg-catalog` revisions with their triggering test suite. These are genuine revision-specific prepublication results; after publication, main workflows provide separate revision-specific evidence.

- **Latest full targeted native regression:** [GitHub Actions run 39948858625](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39948858625), test-suite commit `a0048a8680ffe02736e0305ffbae3e5406504811`. Ubuntu 26.04 ARM64: **37 PASS, 0 FAIL, 1 SKIP**; macOS ARM64: **37 PASS, 0 FAIL, 1 SKIP**. Both jobs succeeded. The SKIP is `mk/lifecycle.test` without the managed Node execution requirement in this general-purpose runner. Tests exercised dispatcher/identity, bootstrap, pkg-launch, pkg-integration, log, lang, jsc, srv lifecycle/provider. Both hosts also ran `sh -n` over all staged catalog `cmd/` entrypoints and all `env` sources.
- **Latest managed Node installed/runtime validation:** [GitHub Actions run 39948480452](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39948480452), test-suite commit `9fde6fa9dc409cbdcd4edbe7feb23ee7fd53de89`. Real `m pkg install nodejs@v26.8.2` from a Git repository checkout pinned to `pkg-catalog` `893120694670ac91e67353797ca3602d8f2b330b`, then `m pkg default nodejs@v26.8.2` and `m node --version`, succeeded on **both Ubuntu ARM64 and macOS ARM64**. The permanent tests `pkg-launch/managed-node.test`, `mk/lifecycle.test` and `jsc/compiler-loader.test` each returned PASS on each host (**6 PASS, 0 FAIL, 0 SKIP**). `managed-node.test` checks that `process.execPath` resolves beneath the selected managed concrete root, `m_ROOT` is correct and no `m_COMMAND_BIN` is inherited. No host Node replacement was used.
- The live-install validation exposed a genuine catalog incompatibility: 12 package `env` sources (Node.js on six osarch streams plus chromium, geoserver, macgpg, playwright and podman) were still deriving the concrete location from obsolete `m_COMMAND_BIN`. They were migrated in `pkg-catalog` commit `893120694670ac91e67353797ca3602d8f2b330b` to the existing validated launcher-local `pkg_launch_root`; the ownership contract was added to staged `PACKAGE-MODEL.md` and the `pkg-launch.lib.sh` operational manual. The permanent pkg-launch contract test also verifies canonical root availability and absence of `m_COMMAND_BIN`.
- Earlier failed runs remain historical evidence, not PASS: initial failure was `package-env-invalid` on both hosts; a later macOS run failed with an HTTP 403 from the public GitHub releases endpoint while Linux passed. A subsequent unchanged artifact request succeeded in the final macOS run. The newly created managed Node regression test initially failed due to non-executable GitHub file mode; it was corrected forward with mode `100755` before the successful run.
- **Evidence limits:** These are authentic GitHub-hosted runner tests of the exercised behavior, not formal full-product validation or validation on project-owned physical hosts. They do not prove service installation through real host supervisors, all package types or reinstall/rollout safety of existing concretes.

## Installed-concrete migration checkpoint (2026-10-23)

- The contract now published in `rumiai-dev/main` (from staged source `9d1ccaef3a11cc368fdbe8971b1d50691e400003`) defines in `PACKAGE-MODEL.md` an operator-managed maintenance window, a full exact-version/default inventory, provider/service preflight, explicit artifact accessibility/integrity checks, immutable concrete reinstall, preserved managed state and restorable compatible backups. The operational `pkg` manual is published in `rumiai-os/main` (`673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`). No new public `pkg` command was introduced.
- A permanent test, `tests/rumiai-os/pkg/native-launcher-reinstall.test`, integrates an intentionally obsolete `env m`/legacy-env concrete using real integration machinery, confirms same-identity overwrite is denied, invokes real `pkg uninstall`, checks preserved system configuration/data and user HOME/configuration, reintegrates a new native concrete with the same identity, restores its previous default, and launches it to verify that retained state and the validated concrete root are used.
- **Latest targeted regression:** [GitHub Actions run 39957583463](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39957583463), suite SHA `fb56fa796494cb120247e449c8bcd02a0946f328` with runtime SHA `59d5ec2d78494c126d5c2869b5b01076e735a6ab` and catalog SHA `893120694670ac91e67353797ca3602d8f2b330b`: Ubuntu 26.04 ARM64 **41 PASS, 0 FAIL, 1 SKIP**; macOS ARM64 **41 PASS, 0 FAIL, 1 SKIP**. Both jobs succeeded. The additional package lifecycle tests (`native-launcher-reinstall`, `uninstall`, `state`, `default`) passed on both hosts. The remaining SKIP is the general runner's `mk/lifecycle` with no managed Node; the separate managed-Node workflow provides that evidence.
- **Real exact same-concrete reinstall:** [GitHub Actions run 39956381930](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39956381930), suite SHA `b3503b14f63c125352d575a45aedca36fd1b08fe`, installed and selected Node.js `v26.8.2` through the staged catalog on both hosts; after successful managed-node, `mk` and `jsc` tests, it ran real public `pkg uninstall`, `pkg install` with the recorded exact version, restored the default, and verified retained user HOME and user/system configuration sentinels and native Node execution on both hosts. Both jobs succeeded. An earlier Linux attempt was blocked by a workflow fixture assertion and macOS by transient GitHub HTTP 403; neither earlier run is relabelled PASS.
- **Provider-discovery mismatch (resolved separately from interpreter migration):** both published and staged runtimes initially failed `pkg/dependency.test` ([reproduction run 39961543153](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39961543153)). Two fixture identifiers ended in a literal `$` rather than a valid unique PID-based `$$` suffix; with the corrected identifiers, the existing internal scanning-failure status was incorrectly mapped to provider-unavailable. The internal resolver now distinguishes invalid discovery via status 5, reusing the established `provider-discovery-invalid` diagnostic and preserving public API/status semantics. The independent fix is in published `rumiai-os/main` at `21bfd86728829e83bc7fff81f35dda0f8c2f925a` and `rumiai-tests/main` at `cde888bbc67e9c9b930a003f090d32e351287091`, both merged forward into the staged branches. [Comparison run 39963292197](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39963292197) passed on both corrected product/test branches.
- The command/fixture and package migration tests ran on auxiliary GitHub-hosted systems in temporary checkouts, **not** on existing deployed RumiAI installations. No installed user/production package, service, or configuration was modified. A multi-package dependency-aware host migration and physical validation are still unexecuted; reinstalling a concrete is not an atomic transaction with all consumers.

## Provider-discovery validation checkpoint (2026-10-23)

- The independent published fixes were reconciled through forward-only two-parent merge commits: `rumiai-os/m-native-command-dispatch` at `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195` and `rumiai-tests/m-native-command-tests` at `9fbcdeec143146149546d33e9a9375126b3d1ed0`; latest staged test branch HEAD `13b5690db43a314b107deefab8eef1ab8f59cf17` (the exact last green regression run used suite SHA `eec5244cc4ab3b3df7a810056cb0155cc594158b`).
- [Final published-vs-staged comparison 39963793482](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39963793482) passed on both exact revision pairs. The existing `pkg-dependency.lib.sh` manual already required corrupt provider metadata to be reported rather than hidden; its public contract needed no edit. The one-off published-versus-staged comparison workflow was removed from the staged test branch in forward commit `13b5690db43a314b107deefab8eef1ab8f59cf17` after successful execution; its revision-pinned GitHub Actions results remain available.
- [Staged two-host regression 39963793299](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39963793299): Ubuntu 26.04 ARM64 and macOS ARM64 each **42 PASS, 0 FAIL, 1 SKIP**, including `pkg/dependency.test` and native launcher reinstall checks, with staged catalog `893120694670ac91e67353797ca3602d8f2b330b`. The general runner SKIP concerns `mk` without managed Node; [managed Node workflow 39963793251](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39963793251) passed on both hosts with real Node package install, `mk` and `jsc`.
- No deployed RumiAI host, existing concrete or service was changed. Physical validation and coordinated native command/catalog rollout remain open.

## Main publication checkpoint (2026-10-23)

- User authorized publication to `main` across all four repositories. `rumiai-dev/main` was merged forward in `73b07e4cfe5dff8404076e63dbb7ad41c2acac50` by overlaying exactly the nine staged contract files onto current main, keeping concurrent handoff and TODO files; `pkg-catalog/main` fast-forwarded to `893120694670ac91e67353797ca3602d8f2b330b`, and `rumiai-os/main` to `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`. `rumiai-tests/main` merged the 58 permanent changed test and helper files in `5061679205283476fc9cbcb436705327e0231c99`, excluding the two staged-only workflow files. All commits preserve Git history and other work.
- A subsequent main-only test fixture correction in `rumiai-tests/main` `1e45b0e893216a3ef4ea8469a3462610f30b8de0` aligned `testlab/contract.test` with the native `#!/bin/sh` shebang, changed older `pkg/catalog.test` and `pkg/install-dependency-order.test` drivers to source `core.lib.sh` explicitly, and routed `http-fetch/backends.test` invocations through `m`.
- Structural consistency checks confirmed canonical native specs, `m` executable, command manual, Node launcher and package `env` have the same blobs as the staged revisions previously validated. [Published tests testlab workflow 39968009005](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39968009005) succeeded on Ubuntu and macOS after test fix. The full [published main rumiai-os-health 39968009167](https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/39968009167) and other broader workflows were still executing at this checkpoint and cannot be reported as PASS. Some broader workflows already failed on earlier revisions, and those failures are not implicitly assigned to or cleared by this migration.
- **Scope boundary:** publication to GitHub `main` is complete; no physical RumiAI deployment, machine-specific installed package inventory, concrete reinstall or service restart was performed. Existing installed package launchers are not automatically repaired by Git branch publication.

## Next action

1. Before deployment, obtain a real target-host inventory of **all** affected exact installed concretes, selected defaults, active facility provider bindings/defaults and host services. Verify artifact availability and backup/recovery before removing any package. Do not infer actual installed inventory from CI.
2. Evaluate the new published-main GitHub Actions runs, distinguish pre-existing/out-of-scope failures from native-entrypoint regressions, and realign only demonstrated migration-related tests/code.
3. Perform proportionate physical and service-supervisor validation on project-owned hosts. Run a controlled coordinated native-runtime/catalog rollout and exact concrete reinstall only with the required deployment prerequisites and authorization; preserve system/user/service state and reconcile failures forward.
4. Keep publication of the four repository `main` branches as the completed checkpoint. Do not claim host deployment until the concrete reinstall and service-specific physical validation have happened.

## Open constraints

- `rumiai-dev/main` is the canonical native-command contract; main code and catalog are published, but existing deployed concrete launchers may still use the old mechanism.
- `pkg-catalog/main` and `rumiai-os/main` now contain the coordinated native-command source migration. Installed package concretes retain their materialized old launchers until separately reinstalled.
- Real catalog-backed managed Node install, same-identity uninstall/reinstall and native launch have passed on both GitHub-hosted reference OS/architecture environments. Physical validation, real installed-concrete inventory and deployed-host rollout remain pending. Provider discovery has been corrected and tested on both published and staged revisions.
