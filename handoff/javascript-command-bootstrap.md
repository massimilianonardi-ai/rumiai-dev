# JavaScript command bootstrap and Node.js shebang

Status: Active
Updated: 2026-10-23

## Goal

Migrate `m` command execution to native interpreter shebangs (`sh`, `node`, etc.) with one authoritative `m` bootstrap. Commands requiring `m` must run through `m <command>` or an already initialized `m` environment, and must check for nonempty `m_ROOT` on entry. Preserve relocatability and native runtime behavior; do not require an interactive `m` shell.

## Current repository revisions

- `rumiai-dev/main`: `c699edfb178193606e5059631f3131c1fa69d3c0` at activation preflight.
- `rumiai-os/main`: `8dac32252f2ea9a0acb57adfadaca189f27018f9`.
- `rumiai-tests/main`: `e851c02343554a9e4c1cc72b574be9943f54760b`.
- `pkg-catalog/main`: `6e4c26232c20a6cca6a4e02d5b2df3ae03553751` (context only, no catalog change).

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`
- `specifications/rumiai-os/{COMMAND-ENTRYPOINTS,BOOTSTRAP-ENVIRONMENT,ENTRYPOINT-ROOT-RESOLUTION,DIAGNOSTICS,MK,JSC}.md`
- Runtime: `rumiai-os/m`, `bin/sys/{mk,jsc,jsc.js}`
- Tests: `rumiai-tests/tests/rumiai-os/{bootstrap,command,mk,jsc}`

## Fixed task-local choices

- Current explicit user decision (2026-10-23): retire `#!/usr/bin/env m` as a command interpreter; use native shebangs, require `m_ROOT` at command startup for environment-dependent commands, load needed shell libraries inside each shell command, and expose selected shell facilities through CLI commands when useful.
- An initialized `m` environment is the prerequisite, not a dedicated interactive `m` shell. `m <command>` is the supported explicit bootstrap entry from an uninitialized host environment.
- Migrate stepwise without breaking the current `main`; new native-only `m` dispatch is staged in a feature branch until dependent commands, package launchers, tests, manuals and specifications can be realigned coherently.

- This is independent of the ongoing `javascript-build-and-runtime-loading` work, which does not own bootstrap/shebang changes.
- Evaluate first; do not change product bootstrap or command semantics before validation and a deliberate design decision.
- Do not add new runtime registries, invented namespaces or host-specific shebang assumptions.

## Acceptance scenarios

- From a fresh POSIX shell, invoke `m mk` or `m jsc` through the real bootstrap and managed Node resolution; invoking the native command directly without initialized `m_ROOT` must fail.
- Invoke commands either through `m <command>` or directly from an already initialized `m` environment, preserving argument vector, effective PATH, exit status and relocatable root semantics.
- Resolve command identities in their native process, including symlink/PATH cases; no `m_COMMAND_BIN` inheritance is supplied.
- Report missing Node/provider failures without implicit installs; do not expose inherited shell functions as JavaScript API.

## Working design

- Current integrated `#!/usr/bin/env m` shell commands are sourced; the resolved `m_COMMAND_BIN` is readonly/exported.
- The existing external fallback can run a `#!/usr/bin/env node` program after bootstrap when explicitly invoked as `m <command>`; external fallback currently unsets `m_COMMAND_BIN`.
- A directly invoked `#!/usr/bin/env node` program bypasses `m`, so it cannot acquire `m` initialization from its shebang alone.
- Distinct approaches to compare: preserve thin POSIX shell launchers; accept explicit `m <node-command>` as different user workflow; or design an explicit `m`-aware runtime dispatch mechanism (not yet approved). Do not treat these approaches as equivalent.

## Completed

- Located and activated `todo/javascript-command-bootstrap.md` after fresh remote-HEAD and canonical-source retrieval.
- Inspected current `m`, `mk`, `jsc`, relevant manuals and command/bootstrap permanent tests.
- Independent auxiliary Node 22.16.0 shell experiment: direct Node shebang under clean environment did not have `m_ROOT`/`m_COMMAND_BIN`; Node inherited exported shell variables; shell functions did not cross the process boundary. This does not validate full `m` runtime behavior.
- Existing `rumiai-tests` includes external-fallback and direct m-shebang tests; no direct-Node bootstrap equivalence proof has been obtained.

## Current state

The user approved native shebangs and staged modification of `m`, followed by all `bin/sys` shell entrypoints. In `rumiai-os`, branch `m-native-command-dispatch` at commit `39ce2d70f83864ed849b835358658f8bcf5028e6` contains the root `m` dispatcher conversion plus 26 migrated `bin/sys` scripts and their 26 operational manuals (53 modified files relative to `main`). All migrated scripts use `#!/bin/sh` and check for nonempty `m_ROOT` before using the runtime. The 22 scripts with shell runtime dependencies explicitly source `core.lib.sh`; the four whose current bodies need no base shell facility (`readpassv`, `testlab`, `tls-ca`, `tls-nss-sync`) do not. `vsed` continues to disable tracing before performing the check. Standalone tools (`read-key`, `readpass`, `pager`, `editor`) and root `m` are not converted. `main` remains at `5ca07aeb26dbc04c0b38998bb05edacd8587a977` and the feature branch is **not ready to merge**: package catalog launchers still use `#!/usr/bin/env m`, `pkg-launch`/`srv` command identity has now been realigned on the feature branch, canonical specifications and permanent tests are not yet aligned.

Staged-step validation (2026-10-23): retrieved branch `m` was checked byte-for-byte against GitHub blob `afeba6c209093aa0c180cf9dc5052ea8fb511ad3`; `sh -n` and `dash -n` passed. Isolated smoke checks on that exact `m` source passed POSIX shell and Node native shebang execution, `m_ROOT` propagation, argument and exit-status preservation, and recursive self-call rejection, **using a minimal substituted `core.lib.sh`**. Therefore these checks prove only the exercised dispatch boundary, not full runtime/composed behavior. No permanent tests, package launchers or manual pages were changed, and no physical validation was performed.

Shell-entrypoint migration review (2026-10-23): connector-read of all 26 modified shell entrypoints confirmed native shebang, nonempty `m_ROOT` guard and selective core loading in correct order. The seven migration commit diffs were re-read; for every migrated script the **only deleted source line** is the original shebang, and no original operational code lines were removed. Each modified command's existing `res/sys/manual/<command>` topic was updated with an explicit environment prerequisite. `rumiai-os/main` remains unchanged. This is static repository review, **not** syntax, composed behavior, host execution or physical validation of the migrated commands. The prior isolated dispatcher checks covered only the previous `m` step.
Command-identity checkpoint (2026-10-23): `rumiai-os/m-native-command-dispatch` advanced to commit `72677548ecffee15f6eefb1adaeb942d39bde425` (parent `39ce2d70f83864ed849b835358658f8bcf5028e6`). `pkg-launch.lib.sh` now calls existing `readpathce pkg_launch_command_bin "$0"` inside `launcher()`, keeping the established canonical-concrete and target checks. `srv` resolves `srv_host_command_bin` from its own `$0` for host install and serializes that path in all four systemd/launchd user/system registration paths. Corresponding `res/sys/manual/{srv,pkg-launch.lib.sh}` pages were updated. The exact commit diff was re-read; connector verification confirms both source files have no remaining `m_COMMAND_BIN` references and all four supervisor registrations use the newly resolved identity. These are static repository checks only: no composed runtime, host-supervisor, permanent suite or physical validation has yet been performed for this step.

Catalog migration checkpoint (2026-10-23): `pkg-catalog/m-native-command-launchers` was created from unchanged `main` commit `b08023f378dc4d773a539b1910e7fc20313cd976`; five forward commits migrate all 114 `pkg/<package>/<platform>/<range>/cmd/<command>` launchers, ending at `304ab8e4fedbef543f68f9d63e60854f80c9cb7c`. All 25 distinct original command contents were inspected before replacement. Every launcher now uses native `#!/bin/sh`, checks nonempty `m_ROOT`, sources `core.lib.sh`, and explicitly loads `pkg/pkg-launch`. Calls to `launcher`/`launcher_nss` and package-specific arguments remain intact. The `macgpg` launcher additionally resolves its own canonical script path with `readpathce ... "$0"` instead of reading old `m_COMMAND_BIN`. The exact five commit diffs were reviewed: 114 changed files, all under `pkg/.../cmd/`; for 113 files only the old shebang and loadsyslib line are deleted, while `macgpg` also removes two old-identity lines. This is revision-specific **static review** only, not a claim of syntax/real composed package launch success or physical validation. Both repository `main` branches remain unchanged. Package concrete already installed retain their copied immutable launcher scripts and require the canonical reinstall path to obtain the updated launchers. A cross-repository compatibility/rollout gate remains before merging, including specification/manual/permanent-test alignment.


Contract/test staging checkpoint (2026-10-23): `rumiai-dev/m-native-command-contract` at `2f677632586e6ec018c2093f8a04c9af7d6ab00b` stages native-command semantics in `RULES.md`, `COMMAND-ENTRYPOINTS.md`, `BOOTSTRAP-ENVIRONMENT.md`, `ENTRYPOINT-ROOT-RESOLUTION.md`, `POSIX-PORTABILITY-LAYER.md`, `CURRENT-MODEL.md`, `MK.md` and `JSC.md`. Normative `rumiai-dev/main` remains on the old contract until coordinated publication. `rumiai-os/m-native-command-dispatch` now includes the revised `res/sys/manual/m` (commit `f8f8acea460aa9bc024e5fed0ab04a350431b3e7`), clarifying that shell functions are process-local. `rumiai-tests/m-native-command-tests` now stages revisions to 53 test files (at staged HEAD; see fresh branch HEAD on resume): native dispatch/status/canonical-identity probes, 12 bootstrap fixtures, package integration and package fixtures, `srv`, `rsudo`, `jsc`, `log`, and `mk` scenarios were realigned to native interpreters and initialized runtime. Git tree/diff checks establish scope and updated source shape, **not** successful execution. The assistant container could not resolve github.com for a checkout and contains only a previous incomplete mock-backed minimal bootstrap check, so no authentic composed suite or host/supervisor tests were executed. The feature branches remain separate and have not been integrated into the old-contract main branches. A broader native-command fixture scan and revision-pinned composed validation remain part of this active task.

## Next action

Perform authentic revision-pinned paired-runtime validation with `rumiai-os/m-native-command-dispatch` (current staged HEAD) and `pkg-catalog/m-native-command-launchers` (current staged HEAD) plus `rumiai-tests/m-native-command-tests`, then reconcile any remaining test fixtures and other current manuals. Validate command/env/identity, installed package launch, `mk`/`jsc`, and `srv` on applicable host(s). Once evidence supports the change, plan a coordinated forward-only merge/rollout: already installed concrete launchers remain old and must be uninstalled/reinstalled under the current package model; do not merge incompatible runtime/catalog stages independently. `main` in product, catalog, and tests remains on the old compatible contract.

## Blockers / open questions

The former direct-from-clean-host `mk`/`jsc` acceptance expectation is superseded: use `m <command>` or an inherited initialized `m` environment. Current `pkg-catalog/main` launchers still depend on `env m` and are incompatible with staged native-only `m`, while staged `pkg-catalog/m-native-command-launchers` requires the staged `pkg-launch` identity update; the source-level `m_COMMAND_BIN` dependencies in `pkg-launch` and `srv` have now been removed on the feature branch. Staged canonical contract, staged root `m` manual and the initially identified permanent tests have now been realigned on feature branches; public `main` remains deliberately unchanged. Authentic syntax/behavioral tests of the complete runtime, especially package launch and host supervisor integration, still need execution and revision-specific evidence. No physical validation has been performed.
