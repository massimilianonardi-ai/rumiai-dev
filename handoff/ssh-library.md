# SSH library extraction

Status: Active
Updated: 2026-09-29

## Goal

Develop and stabilize a reusable m SSH password-authentication library and askpass helper before considering any rsudo migration.

## Current repository revisions

- rumiai-dev: 16479b5b4de5ac688db29ad623c8a9ace166ad53 plus this checkpoint
- rumiai-os: bd8a1a2dcdc5035873c9e4c1ae65349e270253d8
- rumiai-tests: f1669c1ba53a90a2c34ddda34d1337907e547211

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
- ssh_password requires a non-empty remote-account password and constrains OpenSSH to password authentication, one password prompt, and no configured connection sharing.
- General OpenSSH authentication through a future ssh_auth API is deferred to todo/ssh-auth.md.

## Completed

- Added lib/sys/sh/ssh.lib.sh.
- Added executable bin/sys/ssh-askpass.
- Added both required operational manuals.
- Promoted and routed specifications/rumiai-os/SSH.md.
- Corrected ssh-askpass to accept the OpenSSH prompt operand and reject confirmation prompts without consuming the password.
- Updated ssh_password to force BatchMode=no, PasswordAuthentication=yes, PreferredAuthentications=password, NumberOfPasswordPrompts=1, and ControlPath=none.
- Verified the task does not modify rsudo.lib.sh, rsudo, or rsudo-askpass.

## Current state

Implementation and contract are aligned for the password-only API. Permanent mechanical/behavioral coverage and real validation are still pending.

## Next action

Add proportional permanent SSH coverage, run targeted validation, perform the final consistency gate, and only then decide whether the SSH facility is stable enough to discuss an rsudo_core migration.

## Blockers / open questions

None for the active ssh_password scope. Caller use of direct OpenSSH -S is explicitly outside the supported password-only contract because it can replace the facility-owned ControlPath setting.
