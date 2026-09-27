# rsudo library documentation and tests

Status: Active
Updated: 2026-09-26

## Goal

Align the current rsudo contract, command/library operational documentation and permanent tests with the user-authored runtime implementation, without modifying rsudo runtime logic in this work unit.

## Current repository revisions

- rumiai-dev: ff38e84441567626368097d1cd31e188f1a7051d (pre-checkpoint HEAD)
- rumiai-os: c33b39ded5020d85943ca826cedbe3ff6d2a4492
- rumiai-tests: 287577204412cef46cae83157547dbe9ac28d2f8
- rumiai-dev-PoCs: 6b9d193273c801657a1f873eef042156ccb617c0

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
- `rumiai-os@4f429c811f9c19889d0d8f6fa42b0423356beecd` realigns `res/sys/manual/rsudo.lib.sh`, adds the previously missing command topics `res/sys/manual/rsudo` and `res/sys/manual/rsudo-askpass`, and removes the stale `rsudo-env.lib.sh` cross-reference.
- `rumiai-tests@e30ef19cabe1d2c1511fe49db23c8d7b89feff11` adds invocation-state regression coverage: ambient askpass/target-user/quote state is ignored, a real recursive `fs delete` call reuses credentials without inheriting outer modes, and ambient `RSUDO_INTERACTIVE=true` does not force a new invocation into interactive mode.
- Added `validation/rsudo.conf` selecting the complete `rumiai-os/rsudo` permanent-test group for focused formal validation.
- Final diff review caught a malformed temporary-directory identity introduced while editing `contract.test`. The first forward correction still serialized one dollar because JavaScript replacement-string `$` semantics collapsed it; the verified correction in `rumiai-tests@e30ef19cabe1d2c1511fe49db23c8d7b89feff11` uses a replacement callback and the remote file now contains the required PID suffix `$`. No validation evidence from the intermediate revisions is accepted.

- The user advanced `rumiai-os@c33b39ded5020d85943ca826cedbe3ff6d2a4492` with `--ssh-command` / `RSUDO_SSH_COMMAND`, replacing the three direct SSH invocations through the configured command string and defaulting to `ssh` when empty.
- PoC 050 (`rumiai-dev-PoCs/pocs/050-rsudo-ssh-command`) exercised that exact product revision against a real Podman Ubuntu 26.04 SSH/sudo target. Non-interactive use, ambient `RSUDO_SSH_COMMAND`, recursive `fs delete` reuse and interactive PTY execution all passed.
- The same PoC observed a representation limit: when an SSH argument pathname contains spaces, both an unquoted pathname embedded in `RSUDO_SSH_COMMAND` and shell-quote characters embedded in the variable fail with SSH status 255. The current unquoted parameter expansion performs shell field splitting/pathname expansion but does not reparse quote characters as shell syntax.
- The existing permanent `contract.test`, `interactive.test` and `load.test` pass against `c33b39d` on the auxiliary Ubuntu runner. `fs.test` fails independently at `set -o pipefail` in `rsudo-mod-fs.lib.sh` because Ubuntu `/bin/sh` is dash; that code path was not changed by `c33b39d` and is not evidence against the SSH-command change.
- Current rsudo specification and operational manuals do not yet describe `--ssh-command` / `RSUDO_SSH_COMMAND`, and permanent tests do not yet protect the new surface. The user intends to extend credential groups with the SSH setting optionally; that realignment remains pending until the final SSH-command semantics are fixed.
- The current implementation's missing-`--ssh-command` operand diagnostic still reports operand `user` and returns the same local status currently used for missing `--user`; this is an implementation/manual detail to realign when the option contract is finalized.

## Current state

The prior invocation-state contract remains intact. The new `--ssh-command` mechanism is mechanically proven on real SSH/sudo paths for ordinary, ambient-state, recursive and interactive use, but its final public semantics are not yet promoted because command-string quoting for arguments containing whitespace is unresolved. Specification/manual/permanent-test realignment and optional credential-group integration remain pending.

The unrelated `fs.test` failure on the auxiliary Ubuntu runner exposes an existing POSIX mismatch in `rsudo-mod-fs.lib.sh` (`set -o pipefail` under dash) and must not be attributed to the SSH-command commit.

## Next action

1. Decide the final `--ssh-command` representation semantics, in particular whether it intentionally supports only whitespace-separated command words or needs a representation that preserves arbitrary SSH argument boundaries.
2. Apply the user's planned optional SSH setting to credential groups without clearing an existing SSH command when a group omits it.
3. Realign `RSUDO.md`, command/library manuals and permanent tests to the accepted behavior, including recursive reuse and interactive execution.
4. Track/fix the independent POSIX `pipefail` problem in the rsudo filesystem module through the appropriate active/deferred work owner.

## Blockers / open questions

- Final semantics/representation of `RSUDO_SSH_COMMAND` when SSH command arguments contain whitespace or shell metacharacters.
- Exact optional credential-group field name/selection semantics for the SSH command.
- Documentation/permanent-test realignment for the new public option.
- Formal validation remains pending after the SSH-command surface and the independent filesystem-shell issue are resolved/aligned.
