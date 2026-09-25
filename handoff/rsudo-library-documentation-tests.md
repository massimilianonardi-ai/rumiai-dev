# rsudo library documentation and tests

Status: Active
Updated: 2026-09-25

## Goal

Align the operational documentation and permanent tests for `lib/sys/sh/rsudo/rsudo.lib.sh` without modifying the runtime implementation in this work unit.

## Current repository revisions

- rumiai-dev: 3e8083f0e09a1ab8b5589e5633daa36abbd4a82a
- rumiai-os: b411b8c2388d8a3377b1e2911cbc50e231aeab02
- rumiai-tests: 330e60a5b41c5450c6f84dd4a55bf77fd0cf5926

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

- Scope remains documentation and permanent tests; `rsudo.lib.sh` runtime implementation is not modified.
- The user's correction is authoritative: permanent product tests verify observable rsudo behavior for defined inputs and remote-system characteristics; they do not require a specific SSH/sudo sequence or other implementation mechanism.
- Scenario-specific SSH/sudo fixtures are external-boundary infrastructure only. Unsupported fixture interactions are test ERROR, not product FAIL.

## Completed

- Mandatory preflight and current implementation/test inspection completed.
- Added and then corrected `specifications/rumiai-os/RSUDO.md` so it defines only observable rsudo behavior and explicitly excludes internal SSH/sudo mechanics from the contract.
- Added `res/sys/manual/rsudo.lib.sh` and corrected it to document public API and observable behavior rather than prescribing an authentication implementation.
- Reworked `tests/rumiai-os/rsudo/contract.test` as a behavioral test through the real rsudo entrypoint. It exercises password-required sudo, passwordless sudo, root login, target stdin/stdout/stderr, status propagation, `--user`, and `--askpass` without asserting the internal authentication sequence.
- Reworked `tests/rumiai-os/rsudo/interactive.test` to assert only interactive target output/status and absence of password exposure; it no longer asserts number of SSH sessions, sudo flags, IPC identities or internal call order.
- Removed the erroneous `todo/rsudo-runtime-authentication-realignment.md`; it was created from the assistant's incorrect interpretation, not from a real current contract mismatch.
- The current runtime implementation in `rumiai-os` remains unchanged.
- GitHub Actions full-product validation has been triggered for the corrected suite revision.

## Current state

Documentation and tests now follow the observable-contract rules in `TESTING.md` and `TEST-PATTERNS.md`.

The latest corrected suite revision is `330e60a5b41c5450c6f84dd4a55bf77fd0cf5926`. Full-product validation run `36137492561` is in progress against the current product revision.

No product implementation mismatch is asserted by this task.

## Next action

Inspect run `36137492561` when complete, correct only genuine test/harness defects if any, then perform the final consistency gate and close the documentation/test work unit.

## Blockers / open questions

- Formal validation is still in progress.
