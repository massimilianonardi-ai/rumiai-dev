# rsudo SSH authentication

Status: Active
Updated: 2026-09-29

## Goal

Provide the general SSH authentication mode required by rsudo, then migrate
rsudo to it and add the explicit interactive authentication-check path.

## Current repository revisions

- rumiai-dev: 6f2aa21ae9bee8f818b374940c97b2c06232616c before this checkpoint
- rumiai-os: `0c56665c5be7b6aac4c097dad1b000ce97bb6ac7`
- rumiai-tests: `238ab53839814579ed0ed49400ae59864028a405`

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

A concurrent-state reconciliation was required during the latest implementation
turn: an assistant replacement temporarily overwrote the already-implemented and
validated ssh_auth files from rumiai-os@4e6d33f. The affected SSH product files,
SSH specification and split permanent tests were restored forward-only. Their
current blobs are byte-identical to the validated 4e6d33f / b1c3fb58 baseline
content; only commit identities advanced. Historical validation remains
revision-specific and is not relabelled as evidence for the new forward commits.


The `ssh_auth` implementation, canonical contract, manuals and permanent tests
are aligned. macOS formal validation is PASS on the current product revision.

A frozen multi-host validation run using the same current product revision has
been launched with macOS and the suite's current Linux ARM runner. The Linux ARM
job is queued at this checkpoint.

No rsudo runtime source has been modified in this implementation work unit.

## Next action

Close `ssh_auth` validation on Linux for the same frozen suite/product pair.
Then migrate rsudo's normal SSH calls to `ssh_auth` and separately design and
implement `--ssh-auth-check`.

## Blockers / open questions

- `--ssh-auth-check` exact `AddKeysToAgent` behavior remains to be fixed
  during the rsudo migration phase.
