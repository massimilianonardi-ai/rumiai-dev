# rsudo SSH authentication

Status: Complete
Updated: 2026-09-29

## Goal

Provide the general SSH authentication mode required by rsudo, migrate rsudo to
it, and provide the explicit interactive authentication-check path.

## Current repository revisions

- rumiai-dev: `1975e69657d6d6d30eee049ec4f5e45a68c07565` before this final snapshot
- rumiai-os current HEAD: `e31d930534e6536c62d7953fca9398f9006eee28`
- rumiai-tests current HEAD: `12a22021fadf49250464f053700e48bcec9ad012`

Final dedicated validation exercised:

- rumiai-os: `34c158e95bf5f73525cf42653026431b0c5d5551`
- rumiai-tests: `348a6441991fbd655d7f1559ff64151f808938ca`

Current product/test HEAD advances after that validated pair are unrelated to
the rsudo/SSH surfaces covered by this task.

## Applicable canonical sources

- `specifications/rumiai-os/SSH.md`
- `specifications/rumiai-os/RSUDO.md`
- `TESTING.md`
- `TEST-PATTERNS.md`

## Completed

- Promoted the general `ssh_auth` contract and implemented its repeatable
  invocation-scoped secret transport.
- Migrated normal rsudo SSH authentication to `ssh_auth` with the resolved
  rsudo password as candidate secret.
- Added the TTY-only two-phase `rsudo --ssh-auth-check` preparation and fresh
  non-interactive verification path.
- Preserved rsudo stdin, sudo, interactive, recursion, status and cleanup
  semantics.
- Removed the obsolete `rsudo-askpass` command/manual path after migration.
- Realigned operational manuals and permanent SSH/rsudo tests.
- Removed the rsudo-fs host-shell pipefail dependency by preserving producer and
  consumer status explicitly with private FIFO streaming, including cleanup on
  completion and handled termination.
- Permanent rsudo-fs coverage protects independent producer failure and stream
  resource cleanup.
- Final dedicated validation on Linux/aarch64 passed all six rsudo tests with
  zero failures, skips or errors, a CLEAN validation environment, and
  `Scope result: VALIDATED`.
- Validation session:
  `20260929T164234+0200-38746`.
- Published validation:
  `validation/20260929T164234+0200-38746`.
- Aggregate publication:
  `validation/20260929T164233+0200-36908`.

## Current state

The task outcome is implemented, documented, permanently covered and formally
validated. Durable behavior is owned by the current SSH and RSUDO
specifications; no task-local design state remains.

## Next action

None.

## Blockers / open questions

None.
