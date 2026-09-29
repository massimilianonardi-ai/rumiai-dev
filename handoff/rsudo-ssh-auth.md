# rsudo SSH authentication

Status: Active
Updated: 2026-09-29

## Goal

Provide the general SSH authentication mode required by rsudo, then migrate
rsudo to it and add the explicit interactive authentication-check path.

## Current repository revisions

- rumiai-dev: `2a330af2ba162bc242e54dbc29dcaacb55bfcd2f` before this checkpoint
- rumiai-os: `b900747fa05e8ccc7d9b6d2c65d16ed5fb2b18bc`
- rumiai-tests: `edd273ccd8c4e725d4f67aaf46e8cc22dcc6fe37`

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

- `specifications/rumiai-os/SSH.md`
- `specifications/rumiai-os/RSUDO.md`
- `TESTING.md`
- `TEST-PATTERNS.md`

## Fixed task-local choices

- Normal rsudo will invoke `ssh_auth` with the already-acquired user password.
- `ssh_auth secret ssh-argument...` leaves OpenSSH authentication method
  selection and ordering intact and supplies the same secret whenever OpenSSH
  asks for secret-entry input.
- The candidate secret may therefore be tried for a private-key passphrase,
  account-password authentication or another OpenSSH secret-entry request.
- `ssh_auth` never classifies mechanisms by parsing human-readable prompt text.
- Normal `ssh_auth` does not perform host enrollment; it forces
  `StrictHostKeyChecking=yes`.
- Classified confirmation prompts are refused and never receive the candidate
  secret.
- `rsudo --ssh-auth-check` remains the future explicit interactive preparation
  path for host enrollment and ordinary OpenSSH credential/agent preparation.
- Existing rsudo sudo/stream/interactive semantics must be preserved during the
  later rsudo migration.

## Completed

- Promoted the `ssh_auth` contract in `specifications/rumiai-os/SSH.md` and
  updated specification routing.
- Implemented `ssh_auth` in `lib/sys/sh/ssh.lib.sh`.
- Added a private invocation-owned repeatable FIFO secret broker because OpenSSH
  closes inherited extra file descriptors and may invoke askpass multiple times.
- Extended `ssh-askpass` to support both the new repeatable FIFO transport and
  the existing `ssh_password` one-shot IPC transport.
- Aligned both SSH operational manuals.
- Added executable permanent coverage at
  `tests/rumiai-os/ssh/auth.test`; existing `ssh_password` coverage remains
  in `contract.test`.
- Expanded `validation/ssh.conf` to the complete `rumiai-os/ssh` test group.
- Added a focused multi-host SSH validation workflow and corrected it to freeze
  one exact suite/product pair before host fan-out, per current `TESTING.md`.
- Removed the obsolete deferred `todo/ssh-auth.md` after activation.
- First focused Linux/x86_64 validation passed both SSH tests on
  `rumiai-os@dcc5416c`.
- macOS exposed an internal FIFO-broker teardown diagnostic
  (`Interrupted system call`) leaking to public stderr. The broker's private
  stderr is now isolated; failures remain observable through askpass/SSH status.
- Formal macOS validation passed both SSH tests against
  `rumiai-tests@322e53a2761425ea664d420fcc606792e30c2d5e` and
  `rumiai-os@4e6d33f224bcba77a4e553b1e4bd5299a57d555c`, with a CLEAN validation
  environment.

## Current state

Formal rsudo validation was executed on Linux/x86_64 against:

```text
rumiai-tests  26dca8f1aca780722ccb5e2ad9bd83991edc674d
rumiai-os     b900747fa05e8ccc7d9b6d2c65d16ed5fb2b18bc
session       20260929T154338+0200-198891
aggregate     validation/20260929T154337+0200-197084
```

The environment audit was CLEAN, but the scope result was TEST ERROR:

```text
FAIL   rumiai-os/rsudo/auth-check.test
PASS   rumiai-os/rsudo/contract.test
PASS   rumiai-os/rsudo/exec-inject.test
FAIL   rumiai-os/rsudo/fs.test
PASS   rumiai-os/rsudo/interactive.test
ERROR  rumiai-os/rsudo/load.test
```

The published logs established three independent causes:

1. `auth-check.test` called its intended non-TTY scenario without redirecting
   stdin; the runner stdin could therefore still be a TTY. The test now uses
   `</dev/null`.
2. `load.test` sourced `core.lib.sh` directly outside the m bootstrap, so
   `m_LIB_DIR` was unavailable. Fixture encryption now executes through a
   temporary `#!/usr/bin/env m` helper and the real target bootstrap.
3. `fs.test` exposed an unrelated current product defect in
   `rsudo-mod-fs.lib.sh`: unconditional `set -o pipefail` aborts under
   Ubuntu 24.04 `/bin/sh` (dash). This belongs to the active
   `handoff/pipefail-runtime-policy.md` workstream, whose fixed design already
   requires capability-safe adoption or an explicit status-preserving fallback.

The first two suite defects are fixed in
`rumiai-tests@edd273ccd8c4e725d4f67aaf46e8cc22dcc6fe37`.
No rsudo product behavior was changed in response to this failed validation.

The rsudo SSH migration itself remains aligned across specification, runtime,
manuals and permanent tests. Formal VALIDATED evidence is blocked only by the
current rsudo-fs pipefail defect.

## Next action

Allow the active pipefail task to realign `rsudo-mod-fs.lib.sh` with its
capability-safe contract, then rerun the complete formal scope:

```text
./rumiai-validate rsudo
```

Do not exclude `fs.test`; the complete rsudo scope must pass on one exact
current suite/product pair before this task can complete.

## Blockers / open questions

- Formal rsudo validation is blocked by the current unconditional pipefail use
  in `rsudo-mod-fs.lib.sh` on Ubuntu dash. Ownership remains with the active
  `pipefail-runtime-policy` task.
