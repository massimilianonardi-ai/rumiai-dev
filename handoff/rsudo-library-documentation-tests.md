# rsudo library documentation and tests

Status: Active
Updated: 2026-09-25

## Goal

Align the operational documentation and permanent tests for `lib/sys/sh/rsudo/rsudo.lib.sh` without modifying the runtime implementation in this work unit.

## Current repository revisions

- rumiai-dev: a3ab8d41da578578aa2f5167c2109eb7b72a39c4
- rumiai-os: 4e2771d77dc38a398c955b7af49e4662de2af050
- rumiai-tests: 21bf4ed1994c3fff70b7a2859e8f2d04c856d190

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
- Permanent product tests verify observable rsudo behavior for defined inputs and remote-system characteristics. They do not require a specific SSH/sudo sequence, IPC mechanism, process topology, temporary-resource layout or internal call order.
- Scenario-specific SSH/sudo fixtures are external-boundary infrastructure only. Unsupported fixture interactions are test ERROR, not product FAIL.

## Completed

- Mandatory preflight and current implementation/test inspection completed.
- Corrected `specifications/rumiai-os/RSUDO.md` so it defines observable behavior only and explicitly excludes internal SSH/sudo mechanics from the contract.
- Corrected `res/sys/manual/rsudo.lib.sh` to document public API, inputs, outputs, status and supported remote privilege cases without prescribing an authentication implementation.
- Reworked `tests/rumiai-os/rsudo/contract.test` as a behavioral test through the real rsudo entrypoint. It exercises password-required sudo, passwordless sudo, root login, target stdin/stdout/stderr, status propagation, `--user`, successful `--askpass` input and missing `--askpass` input.
- Reworked `tests/rumiai-os/rsudo/interactive.test` to assert only interactive privilege execution, target stdout/stderr, status propagation and absence of password exposure.
- The external sudo fixture accepts multiple legitimate authentication sequences. If a future valid implementation uses an unmodeled sequence, the harness reports ERROR rather than product FAIL.
- Target fixtures now distinguish privileged execution from direct/bypassed execution instead of assuming root.
- Removed the erroneous `todo/rsudo-runtime-authentication-realignment.md`; it was created from the assistant's incorrect interpretation, not from a real current contract mismatch.
- The user advanced `rumiai-os`: `rsudo.lib.sh` no longer sources `rsudo-env.lib.sh`; `--load` uses `encoded_file_eval` directly through the existing `enc.lib.sh` dependency.
- The operational manual dependency list was realigned to the current direct sources: `rand.lib.sh`, `enc.lib.sh`, and `ipc.lib.sh`.
- Permanent rsudo tests were intentionally left unchanged because they assert observable behavior and contain no dependency on the removed internal library path.
- Consistency scan confirms permanent test assertions no longer require `sudo -n`, `sudo -v`, SSH_ASKPASS, IPC identities, FIFO layout, number of SSH sessions or internal call order.
- Diff review confirmed the correction touched only the rsudo specification/manual/tests, task-state correction and specification-index metadata.

## Current state

Documentation and tests now follow the observable-contract rules in `TESTING.md` sections 5-6 and `TEST-PATTERNS.md`.

The latest corrected suite revision is `21bf4ed1994c3fff70b7a2859e8f2d04c856d190`.

The product subsequently advanced to `4e2771d77dc38a398c955b7af49e4662de2af050`. Validation evidence started before that product change does not validate the new product HEAD.

No product implementation mismatch is asserted by this task.

## Next action

Run/inspect full-product validation for the current product HEAD `4e2771d77dc38a398c955b7af49e4662de2af050`, distinguish rsudo results from unrelated suite failures, then perform the final completion gate.

## Blockers / open questions

- Current-product formal validation must cover the new rumiai-os HEAD after the user's rsudo dependency change.
