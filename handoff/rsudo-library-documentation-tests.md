# rsudo library documentation and tests

Status: Active
Updated: 2026-09-26

## Goal

Align the current rsudo contract, command/library operational documentation and permanent tests with the user-authored runtime implementation, without modifying rsudo runtime logic in this work unit.

## Current repository revisions

- rumiai-dev: fd834b5d9e67834c1d112751fab7aa625865a2eb (pre-checkpoint HEAD)
- rumiai-os: e31d930534e6536c62d7953fca9398f9006eee28
- rumiai-tests: 12a22021fadf49250464f053700e48bcec9ad012
- rumiai-dev-PoCs: 04b17182392c323f13a53b9fffa6917ff9823cec

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
- `RSUDO_HOST`, `RSUDO_USER`, `RSUDO_PASSWORD` and loaded credential groups are reusable connection/credential state.
- Target-user, interactive, askpass and no-preserve-quotes modes are invocation-local. Every `rsudo` call resets them before parsing its own options, so recursive calls do not inherit those modes.
- The current public rsudo option surface uses the documented long spellings; `-n`, `-i` and `-A` are not rsudo aliases.

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
- The user advanced runtime behavior in `rumiai-os@571e0df39a103349eae78ba2d4d8161660f084e4`: rsudo now resets `RSUDO_NO_PRESERVE_QUOTES`, `RSUDO_INTERACTIVE`, `RSUDO_ASKPASS` and `RSUDO_AS_USER` on every invocation and removes the temporary short aliases.
- `specifications/rumiai-os/RSUDO.md` now promotes the reusable-connection-state versus invocation-local-mode distinction and the resulting recursive-call rule.
- `rumiai-os@4f429c811f9c19889d0d8f6fa42b0423356beecd` realigned `res/sys/manual/rsudo.lib.sh`, added the then-current command topics `res/sys/manual/rsudo` and `res/sys/manual/rsudo-askpass`, and removed the stale `rsudo-env.lib.sh` cross-reference. A later cleanup removed the obsolete `rsudo-askpass` command and its manual topic.
- `rumiai-tests@e30ef19cabe1d2c1511fe49db23c8d7b89feff11` adds invocation-state regression coverage: ambient askpass/target-user/quote state is ignored, a real recursive `fs delete` call reuses credentials without inheriting outer modes, and ambient `RSUDO_INTERACTIVE=true` does not force a new invocation into interactive mode.
- Added `validation/rsudo.conf` selecting the complete `rumiai-os/rsudo` permanent-test group for focused formal validation.
- Final diff review caught a malformed temporary-directory identity introduced while editing `contract.test`. The first forward correction still serialized one dollar because JavaScript replacement-string `$` semantics collapsed it; the verified correction in `rumiai-tests@e30ef19cabe1d2c1511fe49db23c8d7b89feff11` uses a replacement callback and the remote file now contains the required PID suffix `$`. No validation evidence from the intermediate revisions is accepted.

- The user advanced `rumiai-os@c33b39ded5020d85943ca826cedbe3ff6d2a4492` with `--ssh-command` / `RSUDO_SSH_COMMAND`, replacing the three direct SSH invocations through the configured command string and defaulting to `ssh` when empty.
- PoC 050 (`rumiai-dev-PoCs/pocs/050-rsudo-ssh-command`) exercised that exact product revision against a real Podman Ubuntu 26.04 SSH/sudo target. Non-interactive use, ambient `RSUDO_SSH_COMMAND`, recursive `fs delete` reuse and interactive PTY execution all passed.
- The same PoC observed a representation limit: when an SSH argument pathname contains spaces, both an unquoted pathname embedded in `RSUDO_SSH_COMMAND` and shell-quote characters embedded in the variable fail with SSH status 255. The current unquoted parameter expansion performs shell field splitting/pathname expansion but does not reparse quote characters as shell syntax.
- The existing permanent `contract.test`, `interactive.test` and `load.test` pass against `c33b39d` on the auxiliary Ubuntu runner. `fs.test` fails independently at `set -o pipefail` in `rsudo-mod-fs.lib.sh` because Ubuntu `/bin/sh` is dash; that code path was not changed by `c33b39d` and is not evidence against the SSH-command change.
- Current rsudo specification and operational manuals do not yet describe `--ssh-command` / `RSUDO_SSH_COMMAND`, and permanent tests do not yet protect the new surface. The user intends to extend credential groups with the SSH setting optionally; that realignment remains pending until the final SSH-command semantics are fixed.
- The current implementation's missing-`--ssh-command` operand diagnostic still reports operand `user` and returns the same local status currently used for missing `--user`; this is an implementation/manual detail to realign when the option contract is finalized.

- The `--ssh-command` experiment was explicitly abandoned after evaluating shell-command-string semantics. The user restored direct `ssh` invocation in `rumiai-os@9832b46080d66c3001bbace2ee82bede560981c0`.
- Revision comparison confirms `9832b46` is the exact inverse of the earlier `c33b39d` SSH-command patch: it removes the default `RSUDO_SSH_COMMAND`, restores all three direct `ssh` calls, and removes the `--ssh-command` parser branch.
- Current merged product HEAD `c1aa711645b39f36850d35abc02c31d8db916120` preserves that revert. The file is not byte-identical to the older pre-experiment revision because the independent interactive source-injection correction is also present; no SSH-command residue remains.
- Current rsudo specification, command manual, library manual and permanent rsudo tests contain no `--ssh-command` / `RSUDO_SSH_COMMAND` surface.
- PoC 050 remains evidence about the rejected experiment only. It is not current product behavior and does not create a pending rsudo contract.
- SSH client configuration is left to SSH/the calling environment. Scenario-specific development/test environments may interpose a real-SSH wrapper through `PATH` without adding an rsudo option.

## Current state

The rsudo SSH-command experiment is fully reverted. Current rsudo again invokes `ssh` directly and exposes no `--ssh-command` / `RSUDO_SSH_COMMAND` contract. The canonical specification and operational manuals already matched this state, so no canonical contract change was required for the revert.

The current product also contains the later, independent interactive source-injection fix; therefore "restored as before" is true specifically for the SSH-command experiment, not as a byte-for-byte rollback of every later rsudo improvement.

The unrelated `fs.test` failure previously observed on the auxiliary Ubuntu runner was later resolved in the active pipefail workstream by replacing the transfer pipeline dependency with explicit producer/consumer status collection. It is no longer a blocker for this documentation/test workstream.

The obsolete `rsudo-askpass` command, its orphan manual topic and the corresponding permanent-test existence checks have been removed; current rsudo SSH authentication uses `ssh_auth` / `ssh-askpass`.

## Next action

Continue rsudo validation/documentation work from the direct-SSH implementation. No SSH-command or credential-group SSH field is pending. Focused formal validation remains appropriate once the independent filesystem-shell issue and any other current-suite changes are in a valid state.

## Blockers / open questions

- Formal validation evidence for the current product/suite pair remains revision-specific and must not be inferred from older runs.
