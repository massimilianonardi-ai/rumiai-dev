# SSH library extraction

Status: Active
Updated: 2026-09-29

## Goal

Develop and stabilize a reusable m SSH password-authentication library and askpass helper before considering any rsudo migration.

## Current repository revisions

- rumiai-dev: 0263f4d6704d930ce5d4f7d7ef647301a391312e plus this checkpoint
- rumiai-os: b37d3b17fcb95183b6ceac12e946a7878a81b6bb
- rumiai-tests: a96776f871f3717758268a19b74023e20d921582

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/SSH.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md

## Fixed task-local choices

- Existing rsudo.lib.sh, rsudo command, and rsudo-askpass are stable baselines and must not be modified.
- Implement and stabilize ssh.lib.sh and ssh-askpass independently first.
- Any rsudo_core migration remains discussion-only until the SSH facility is stable.
- ssh_password is the only active public API in this task.
- ssh_password requires a non-empty newline-free remote-account password.
- ssh_password constrains OpenSSH to password authentication, one password prompt, and no configured connection sharing.
- General OpenSSH authentication through a future ssh_auth API is deferred to todo/ssh-auth.md.

## Completed

- Added lib/sys/sh/ssh.lib.sh.
- Added executable bin/sys/ssh-askpass.
- Added and aligned both required operational manuals.
- Promoted and routed specifications/rumiai-os/SSH.md.
- Corrected ssh-askpass to accept the OpenSSH prompt operand and reject confirmation prompts without consuming the password.
- Updated ssh_password to force BatchMode=no, PasswordAuthentication=yes, PreferredAuthentications=password, NumberOfPasswordPrompts=1, and ControlPath=none.
- Added executable permanent coverage at tests/rumiai-os/ssh/contract.test.
- Added explicit coverage for empty/newline passwords, forced OpenSSH settings, askpass confirmation refusal, stream transparency, argv secrecy and status propagation.
- Verified task diffs contain no change to rsudo.lib.sh, rsudo or rsudo-askpass.
- POSIX shell syntax for the current ssh.lib.sh and ssh-askpass source was checked successfully in the auxiliary shell.

## Current state

Implementation, canonical specification, manuals and permanent test are aligned for the password-only API.

A physical Linux development run was attempted on host `PRTL-GS-01` with `./rumiai-test rumiai-os/ssh/contract.test`. The runner classified the test as `ERROR` (status 3); the persisted test log has not yet been inspected, so this is currently an infrastructure/test-execution error, not evidence of a product failure. The preceding `cd rumiai-tests` shell error was incidental because the shell was already inside the rumiai-tests repository.

OpenSSH option/askpass semantics were cross-checked against current OpenSSH documentation/source, including the upstream password regression pattern.

## Next action

Inspect the persisted `.runs/<latest>/logs/rumiai-os/ssh/contract.test.log` from the failed Linux development run, correct the test or target only according to that evidence, then rerun the same test. If it passes, perform the final validation checkpoint and then evaluate the proposed rsudo_core migration in chat without modifying rsudo.

## Blockers / open questions

- Behavioral validation is pending solely because the available auxiliary execution environment cannot provide the required real target/OpenSSH environment.
- Caller use of direct OpenSSH -S remains outside the supported password-only contract because it can replace the facility-owned ControlPath setting.
