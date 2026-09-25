# rsudo library documentation and tests

Status: Active
Updated: 2026-09-25

## Goal

Align the operational manual and permanent tests for `lib/sys/sh/rsudo/rsudo.lib.sh` without modifying the runtime implementation in this work unit.

## Current repository revisions

- rumiai-dev: eaa9cf99528af373af978018ed5032c177787748
- rumiai-os: 8579cf1d8e3ebb0f47598e7d650ece90a6dfc922
- rumiai-tests: 9cea0e6a5232371d020d6c576919157779778e47

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- TESTING.md
- TEST-PATTERNS.md
- RUNNER.md

## Fixed task-local choices

- Scope is documentation and permanent tests for `rsudo.lib.sh`; runtime implementation is not modified.
- The accepted non-interactive authentication model is: consume the transferred sudo password separately from target stdin, validate credentials with `sudo -S --prompt='' -v`, then execute the target with `sudo -n`.
- After pre-authentication, both interactive and non-interactive target execution must not request or consume a password from target stdin/TTY.
- Tests must protect observable behavior through the real RumiAI target and may replace only external SSH/sudo boundaries where needed.

## Completed

- Mandatory preflight and current implementation/test inspection completed.
- Confirmed `rsudo.lib.sh` currently exposes public functions `rsudo_core` and `rsudo`.
- Confirmed no current permanent rsudo tests and no `res/sys/manual/rsudo.lib.sh` topic exist.

## Current state

The current runtime still uses the older non-interactive `sudo -n true` probe followed by `sudo -S` target execution, and interactive target execution does not yet force `sudo -n`. Documentation/tests will encode the accepted model and therefore may expose this pending runtime mismatch.

## Next action

Create the library manual and permanent rsudo contract test, then run proportional validation and record the implementation mismatch explicitly if the current runtime does not satisfy the new test.

## Blockers / open questions

None.
