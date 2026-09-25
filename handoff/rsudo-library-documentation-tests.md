# rsudo library documentation and tests

Status: Active
Updated: 2026-09-25

## Goal

Align the operational documentation and permanent tests for `lib/sys/sh/rsudo/rsudo.lib.sh` without modifying the runtime implementation in this work unit.

## Current repository revisions

- rumiai-dev: c8bde6dc8ffc3c7a40501155c52a96dd41fda124
- rumiai-os: 323085f1cb6657bf7330ad2370f30968206ff6e7
- rumiai-tests: 11c97f6c08712b0c82e06efbdd3972e217dc1cd4

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
- `--load file:group` has two independently optional components. `file:group`, `file:`, `:group`, and `:` are all valid forms with distinct observable semantics.

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
- The user advanced the `--load` contract: `file` and `group` may each be empty, including both empty.
- `specifications/rumiai-os/RSUDO.md` and `res/sys/manual/rsudo.lib.sh` now define the four `--load` cases and the current `RSUDO_CREDENTIALS_GROUP_<group>_{HOST,USER,PASS}` namespace.
- The manual's public rsudo status table was aligned with the current implementation after removal of the former invalid-group status.
- `tests/rumiai-os/rsudo/contract.test` was aligned to the current public status codes.
- Added `tests/rumiai-os/rsudo/load.test` protecting only the observable `--load` contract. It covers `file:group`, `file:`, `:group`, `:`, and a same-invocation `file:` then `:group` sequence proving that file-only loading actually populates in-memory group state without selecting it.
- Permanent rsudo tests were intentionally left unchanged because they assert observable behavior and contain no dependency on the removed internal library path.
- Consistency scan confirms permanent test assertions no longer require `sudo -n`, `sudo -v`, SSH_ASKPASS, IPC identities, FIFO layout, number of SSH sessions or internal call order.
- Diff review confirmed the correction touched only the rsudo specification/manual/tests, task-state correction and specification-index metadata.

## Current state

Documentation and tests now follow the observable-contract rules in `TESTING.md` sections 5-6 and `TEST-PATTERNS.md`.

The latest corrected suite revision is `11c97f6c08712b0c82e06efbdd3972e217dc1cd4`.

The current product revision is `323085f1cb6657bf7330ad2370f30968206ff6e7`, containing the user's `--load` contract change plus the aligned operational manual.

Full-product validation run `36144167133` is in progress for this suite/product state.

No product implementation mismatch is asserted by this task.

## Next action

Inspect full-product validation run `36144167133`, distinguish rsudo results from unrelated suite failures, correct only genuine test/documentation defects if any, then perform the final completion gate.

## Blockers / open questions

- Formal validation for the current suite/product pair is still in progress.
