# JavaScript command bootstrap and Node.js shebang

Status: Active
Updated: 2026-10-12

## Goal

Evaluate whether first-party JavaScript-backed `m` commands can use direct JavaScript source/Node shebangs without losing the integrated `m` environment and command identity. Preserve POSIX relocatability and normal direct command invocation unless a user-visible change is explicitly approved.

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

Evaluation active. Current normative contract still requires `#!/usr/bin/env m` for bootstrap-integrated commands; no `rumiai-os` or permanent test changes made.

## Next action

Build an isolated authentic test on the current `m` execution path for a Node-shebang command via direct invocation vs `m <command>`, including PATH/identity/status and managed Node availability; compare with thin launchers. Recommend a concrete design based on test evidence, then request a choice only if the normal-path/interface contract must change.

## Blockers / open questions

A native Node shebang alone cannot initialize `m`. Decide whether keeping direct `mk`/`jsc` invocation with transparent bootstrap is mandatory before considering a bootstrap redesign.
