# SSH library extraction

Status: Active
Updated: 2026-09-29

## Goal

Develop and stabilize a reusable m SSH password-authentication library and askpass helper before considering any rsudo migration.

## Current repository revisions

- rumiai-dev: 7eb5458b6ce3da364956d537abc5684c766f84b8 plus this checkpoint
- rumiai-os: 94cb0620f62a481c8300432bb642367e81c11432
- rumiai-tests: 46567974b8cedd00f2d558f44398a468a9c1bdba

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

A physical Linux development run on `PRTL-GS-01` passed `rumiai-os/ssh/contract.test` with PASS 1 / FAIL 0 / SKIP 0 / ERROR 0 after the OpenSSH 9.6p1 ControlPath representation assertion was corrected. This is a real development-run result, not formal validation evidence under current TESTING.md.

A physical Linux development run on host `PRTL-GS-01` initially produced `ERROR` because the SSH fixture could not complete the askpass call against the older local target. After the user fast-forwarded the local rumiai-os checkout to the current SSH implementation, the same test progressed to `FAIL` with no test `ERROR`. The latest physical assertion failure was isolated to the test's representation check for disabled ControlPath. OpenSSH 9.6p1 normalizes `ControlPath none` to an unset internal `control_path`, so `ssh -G` legitimately omits the `controlpath` line while connection sharing remains disabled. The permanent test was corrected to accept either omission or literal `controlpath none`, while still rejecting any real path.

OpenSSH option/askpass semantics were cross-checked against current OpenSSH documentation/source, including the upstream password regression pattern.


- Physical Linux run returned fixture status 86 at the ssh-askpass invocation. Verify local rumiai-os and rumiai-tests revisions before attributing this to product behavior; the current suite now prints captured fixture stderr for this case.

- The latest physical rerun exposed a syntax error in the permanent test itself: the temporary ControlPath diagnostic edit had split the final assertion and caused `/bin/sh` status 2, which the runner classified as SKIP. The test was corrected forward-only at rumiai-tests commit `fe5d6fd0320c71e9e20bfeb429033f423f60beab`; no product source changed for this correction.

## Next action

Run formal task validation through `./rumiai-validate ssh`. The new `validation/ssh.conf` scope selects only `rumiai-os/ssh/contract.test` and intentionally uses the current committed rumiai-os revision rather than a historical pin. If the required test passes in the disposable validation environment, complete the final task handoff lifecycle and only then move on to the rsudo_core migration discussion.

## Blockers / open questions

- Caller use of direct OpenSSH -S remains outside the supported password-only contract because it can replace the facility-owned ControlPath setting.
