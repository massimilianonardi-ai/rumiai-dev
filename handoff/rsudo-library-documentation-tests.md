# rsudo library documentation and tests

Status: Active
Updated: 2026-09-25

## Goal

Align the operational documentation and permanent tests for `lib/sys/sh/rsudo/rsudo.lib.sh` without modifying the runtime implementation in this work unit.

## Current repository revisions

- rumiai-dev: f113f15530cd25d69a859ab185bce90e78746737
- rumiai-os: 518cd309f4264bee707d61746655b781c89bd622
- rumiai-tests: 4055a71f10fd3ff202ae22e1ea3462529c7e0d3b

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- specifications/rumiai-os/RSUDO.md
- TESTING.md
- TEST-PATTERNS.md
- RUNNER.md

## Fixed task-local choices

- Scope is documentation and permanent tests for `rsudo.lib.sh`; runtime implementation is not modified.
- The accepted authentication model is now promoted to `specifications/rumiai-os/RSUDO.md`.
- Tests exercise the real RumiAI rsudo/rsudo-askpass/IPC path and replace only external SSH/sudo boundaries where needed.

## Completed

- Mandatory preflight and current implementation/test inspection completed.
- Promoted `specifications/rumiai-os/RSUDO.md` and routed it from `specifications/README.md`.
- Added `res/sys/manual/rsudo.lib.sh`, documenting public functions `rsudo` and `rsudo_core`.
- Added `tests/rumiai-os/rsudo/contract.test` covering the non-interactive authentication/input contract, selective NOPASSWD behavior, SSH one-shot askpass and target-status propagation.
- Added `tests/rumiai-os/rsudo/interactive.test` covering the two-SSH interactive path, sudo pre-validation, non-interactive target sudo and remote rendezvous cleanup.
- Removed the pre-existing broad `todo/rsudo.md` when rsudo work became active.
- Recorded the intentionally out-of-scope runtime mismatch as `todo/rsudo-runtime-authentication-realignment.md`.
- Diff review confirmed only the intended documentation/test/task-state surfaces were changed.
- Local clone-based execution was attempted but the container cannot resolve github.com.
- GitHub Actions full-product validation was triggered for the new suite revisions.

## Current state

The documentation and permanent tests encode the accepted rsudo contract.

The current runtime remains intentionally unmodified and is known to conflict with that contract: non-interactive mode still uses an unrelated `sudo -n true` probe followed by target `sudo -S`, and the interactive target does not yet force `sudo -n`.

The latest full-product validation for suite revision `4055a71f10fd3ff202ae22e1ea3462529c7e0d3b` is run `36136046947` and is still in progress. Earlier runs for intermediate suite revisions are also in progress. No PASS is claimed.

## Next action

Inspect run `36136046947` when it completes, distinguish expected rsudo contract failures from test-infrastructure defects, fix only the latter if present, then perform the final consistency gate for this documentation/test work unit.

## Blockers / open questions

- Formal validation is still in progress.
