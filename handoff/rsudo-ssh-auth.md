# rsudo SSH authentication

Status: Active
Updated: 2026-09-29

## Goal

Provide the general SSH authentication mode required by rsudo, then migrate
rsudo to it and add the explicit interactive authentication-check path.

## Current repository revisions

- rumiai-dev: `381120ffd7a2cad8b3d7eab4a04b00f8fdd5c00a` before this checkpoint
- rumiai-os: `34c158e95bf5f73525cf42653026431b0c5d5551`
- rumiai-tests: `348a6441991fbd655d7f1559ff64151f808938ca`

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

The failed Linux validation from session
`20260929T154338+0200-198891` was fully triaged.

The two suite defects have been corrected:

- `auth-check.test` now forces `/dev/null` for its non-TTY case;
- `load.test` prepares encrypted input through the real m bootstrap and uses a
  unique PID-qualified workspace.

The rsudo-fs blocker has also been removed. `rsudo-mod-fs.lib.sh` no longer
requires host-shell pipefail support for correctness. Its tar transfers use a
private invocation-owned FIFO with explicit producer and consumer status
collection, preserving streaming, staging and rollback behavior on shells such
as Ubuntu dash. du/df producer status is observed before finite parsing.

Permanent fs coverage now forces a local producer failure while making the
modeled remote tar consumer succeed, so producer-status propagation is protected
independently rather than accidentally relying on consumer failure.

A concurrent cleanup removed the obsolete `bin/sys/rsudo-askpass`; its orphan
manual and obsolete contract-test expectations have now also been removed.
Current rsudo SSH authentication uses only `ssh_auth` / `ssh-askpass`.

Repository-triggered health run `36582351794` is running with the exact
current test-suite revision `348a6441991fbd655d7f1559ff64151f808938ca` and froze product revision
`34c158e95bf5f73525cf42653026431b0c5d5551`. The Ubuntu 26.04 ARM job has started and the macOS job is queued.
This is broader supplemental evidence and does not replace the dedicated
revision-specific `rsudo` validation requirement.

## Next action

Inspect the automatic health workflow result. If it exposes no new rsudo
regression, run exactly one final dedicated validation:

```text
./rumiai-validate rsudo
```

The complete scope must pass without exclusions before this task is complete.

## Blockers / open questions

No known rsudo-specific blocker remains before final validation.
