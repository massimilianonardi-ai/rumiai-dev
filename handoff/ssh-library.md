# SSH library extraction

Status: Complete
Updated: 2026-09-29

## Goal

Develop and stabilize the reusable m SSH password-authentication library and
askpass helper before any rsudo migration.

## Final repository revisions

- rumiai-dev: final snapshot commit plus subsequent handoff-removal commit
- rumiai-os: `94cb0620f62a481c8300432bb642367e81c11432`
- rumiai-tests: `e109ab4749a482a9e6e9675e4fa94c1efeaa39d9`

## Canonical outcome

The durable contract is owned by:

- `specifications/rumiai-os/SSH.md`
- `lib/sys/sh/ssh.lib.sh`
- `bin/sys/ssh-askpass`
- their operational manuals
- `tests/rumiai-os/ssh/contract.test`

`ssh_password` is the stabilized active API. General authentication through
a future `ssh_auth` API remains intentionally deferred in
`todo/ssh-auth.md`.

The stable rsudo baseline was not modified during this task.

## Validation

Development execution on Linux/x86_64 passed:

```text
PASS 1
FAIL 0
SKIP 0
ERROR 0
```

Formal task validation then passed in the disposable validation environment:

```text
scope: ssh
selection: rumiai-os/ssh/contract.test
rumiai-tests: e109ab4749a482a9e6e9675e4fa94c1efeaa39d9
rumiai-os:    94cb0620f62a481c8300432bb642367e81c11432
result:       PASS
environment:  CLEAN
session:      20260929T102402+0200-51585
published:    validation/20260929T102402+0200-51585
```

The published validation branch records the selected test as PASS with runner
exit status 0.

## Current state

The SSH password facility is complete for the current contract and has formal
revision-specific validation evidence.

## Next action

None for this task.

## Blockers / open questions

None.
