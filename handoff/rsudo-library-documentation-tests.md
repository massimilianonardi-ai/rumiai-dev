# rsudo library documentation and tests

Status: Active
Updated: 2026-09-26

## Goal

Align the operational documentation and permanent tests for `lib/sys/sh/rsudo/rsudo.lib.sh` without modifying the runtime implementation in this work unit.

## Current repository revisions

- rumiai-dev: b2e380c2a242777f17f7a57cafb8b83f3e6bc060
- rumiai-os: 3d1f687cc12bac0467d37def42169bd5dbfb9912
- rumiai-tests: e91b0413ce76b2ca2b288afdd8f6537afd56f183

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

## Working design

- The user advanced `rumiai-os` to `3d1f687cc12bac0467d37def42169bd5dbfb9912`. The current implementation adds short aliases `-n`, `-i`, and `-A`, and resets `RSUDO_NO_PRESERVE_QUOTES` at entry to every `rsudo()` invocation.
- The short aliases are not yet accepted as durable contract. The parser remains positionally clear once the first non-option operand or literal `--` is reached, but the spellings are semantically easy to confuse with existing `ssh`/`sudo` short-option meanings. If short options are retained, unknown leading `-x` behavior and short-option grouping should be made explicit rather than left accidental.
- Resetting `RSUDO_NO_PRESERVE_QUOTES` is coherent if quote-preservation mode is intentionally invocation-local: an outer rsudo/submodule call then cannot silently alter the command interpretation of a nested `rsudo` call. This also means the previously documented ambient `RSUDO_NO_PRESERVE_QUOTES=true` input is no longer part of `rsudo` behavior and must be realigned if this design is accepted.
- The broader recursive-state model still needs an explicit classification. `RSUDO_HOST`, `RSUDO_USER`, and `RSUDO_PASSWORD` are connection state that recursive submodule calls are designed to reuse. By contrast, `RSUDO_ASKPASS` and `RSUDO_INTERACTIVE` are invocation modes that currently remain set across recursive calls; in particular, inherited `RSUDO_ASKPASS=true` can cause a nested non-TTY `rsudo` call to consume another stdin record. `RSUDO_AS_USER` also needs an explicit inherited-vs-invocation-local decision.

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

The current product revision is `3d1f687cc12bac0467d37def42169bd5dbfb9912`. It adds the short aliases and invocation-entry reset described in Working design.

The current specification/manual still describe only the long option spellings and still document `RSUDO_NO_PRESERVE_QUOTES` as ambient caller state. Permanent rsudo tests do not yet protect the new short aliases or recursive quote-mode reset. This is an active implementation/documentation/test mismatch pending the user's design decision.

Full-product validation run `36144167133` applies only to the older suite/product pair recorded when that run started; it cannot validate the new product revision.

## Next action

Resolve the invocation-state model and whether short aliases remain part of rsudo. Then realign the canonical rsudo specification, operational manual and proportional permanent tests to the accepted contract before validating the new product revision.

## Blockers / open questions

- Keep or remove the new `-n`, `-i`, and `-A` aliases?
- Which rsudo state is deliberately inherited by recursive calls versus reset per invocation, especially `RSUDO_ASKPASS`, `RSUDO_INTERACTIVE`, and `RSUDO_AS_USER`?
