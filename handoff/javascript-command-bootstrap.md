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

- From a fresh POSIX shell, invoke `mk` or `jsc` directly and obtain the same initialized `m` runtime and managed Node resolution as presently specified.
- Invoke the same command through `m <command>`, preserving argument vector, effective PATH, exit status and relocatable root semantics.
- Report missing Node/provider failures without implicit installs; avoid leaking shell-only functions as claimed JavaScript API.

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

The user approved the native-interpreter design and authorized modification of `m` first. In `rumiai-os`, branch `m-native-command-dispatch` at commit `a2b5e8a703e2703bb456919651b0897dadeec0cc` changes only root `m`: drops shebang inspection and source-based integrated dispatch, retains bootstrap and self-recursion guard, and finishes with `exec "$@"`. `main` remains at `5ca07aeb26dbc04c0b38998bb05edacd8587a977`, retaining the current working behavior. The branch is **not ready to merge**: current `bin/sys` commands and `pkg-catalog` launchers still use `#!/usr/bin/env m`; canonical specifications, operational manuals and permanent tests still describe the old contract.

Staged-step validation (2026-10-23): retrieved branch `m` was checked byte-for-byte against GitHub blob `afeba6c209093aa0c180cf9dc5052ea8fb511ad3`; `sh -n` and `dash -n` passed. Isolated smoke checks on that exact `m` source passed POSIX shell and Node native shebang execution, `m_ROOT` propagation, argument and exit-status preservation, and recursive self-call rejection, **using a minimal substituted `core.lib.sh`**. Therefore these checks prove only the exercised dispatch boundary, not full runtime/composed behavior. No permanent tests, package launchers or manual pages were changed, and no physical validation was performed.

## Next action

Validate the staged `m` with native `#!/bin/sh` and `#!/usr/bin/env node` commands in an authentic runtime checkout; test argument/status propagation, PATH and self-recursion guard. Then migrate the dependent shell commands and package launchers with explicit library loading and `m_ROOT` checks, realign command identity users (`pkg-launch` and `srv`), and update the canonical specifications, manuals and permanent tests as a coordinated migration before merging into `main`. Do not turn the staged partial branch into a published incompatible runtime.

## Blockers / open questions

The direct-from-clean-host `mk`/`jsc` behavior currently described as an acceptance scenario has been intentionally superseded by the user's explicit acceptance of `m <command>` or an inherited initialized `m` environment. The staged `m` branch is incompatible with all remaining `env m` commands until the coordinated migration completes. `m_COMMAND_BIN` consumers (`pkg-launch`, `srv`) require explicit realignment. Authentic full-runtime testing and native-command permanent tests have not yet been performed for the staged branch; no physical validation is claimed.
