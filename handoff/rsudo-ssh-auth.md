# rsudo SSH authentication

Status: Active
Updated: 2026-09-29

## Goal

Provide the general SSH authentication mode required by rsudo, then migrate
rsudo to it and add the explicit interactive authentication-check path.

## Current repository revisions

- rumiai-dev: `7bd754c91c4b5bd20388cd8bdfc05e0d208ed65f` before this checkpoint
- rumiai-os: `249c91cad0e3dd8d5ecb4af712fd4db78b8c6ab9`
- rumiai-tests: `26dca8f1aca780722ccb5e2ad9bd83991edc674d`

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

- The rsudo runtime migration to `ssh_auth` is present in
  `rumiai-os@6e46247a2f8c095fddeabe00d943763e6f1ac174` and remains unchanged by
  the documentation/test work.
- `RSUDO.md` now defines normal ssh_auth-backed transport and the terminal
  two-phase `--ssh-auth-check` contract, including invocation-local state.
- The rsudo command/library manuals are aligned; the existing
  `rsudo-askpass` manual now identifies that helper as legacy and outside the
  current rsudo authentication path.
- Existing rsudo SSH external-boundary fixtures were updated to accept normal
  OpenSSH option ordering introduced by ssh_auth without prescribing internal
  authentication mechanics.
- New executable permanent coverage
  `tests/rumiai-os/rsudo/auth-check.test` protects interactive preparation,
  fresh ssh_auth verification, disabled multiplexed reuse, no sudo execution,
  local rejection paths and invocation-local reset after an early return.
- `validation/rsudo.conf` already selects the complete `rumiai-os/rsudo`
  group, so the new test is automatically part of formal rsudo validation.
- Final consistency review found no remaining `--ssh-auth-test` terminology or
  direct ipc dependency in current rsudo runtime/manual surfaces.
- Formal validation of the current rsudo product/test revisions is still
  pending.

## Next action

Run formal task validation:

```text
./rumiai-validate rsudo
```

against the current committed product/test revisions. If the complete scope is
VALIDATED with a CLEAN environment, record the revision-specific evidence and
then evaluate removal of the now-unused legacy `rsudo-askpass` command/manual
as a separate cleanup step.

## Blockers / open questions

None before formal validation.
