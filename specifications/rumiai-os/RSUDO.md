# RumiAI OS — rsudo remote privilege execution

Status: **Current / normative**  
Updated: 2026-09-26

This specification defines the observable contract of the `rsudo` subsystem implemented by `lib/sys/sh/rsudo/rsudo.lib.sh`.

Implementation choices used to satisfy this contract are not part of the contract unless another current specification explicitly makes them normative.

## Scope

`rsudo` executes a command on a remote host through SSH and requests remote privilege elevation through `sudo`.

The operational public API is documented in:

```text
res/sys/manual/rsudo.lib.sh
```

Permanent tests protect the observable properties below through the real RumiAI entrypoint. External SSH/sudo behavior may be represented by scenario-specific external-boundary fixtures when allowed by `TESTING.md`.

## Connection and credentials

A resolved rsudo operation requires:

```text
remote host
remote login user
non-empty password value
```

The password is available to rsudo for the remote authentication steps that actually require it.

If the remote SSH/sudo environment does not require the password for a particular step, rsudo must still complete the operation correctly.

The password must not become ordinary target-command input or ordinary command output merely because an authentication step did not consume it.

## Non-interactive execution

Given a reachable remote system, valid connection data and a target command, non-interactive rsudo must:

```text
execute the requested target under remote sudo
preserve the target's intended stdin
propagate target stdout/stderr
return the resulting remote execution status
```

The same functional behavior must hold for at least these remote privilege configurations:

```text
sudo authentication requires the supplied password
the remote user may execute sudo without a password
the remote login is already privileged
```

Authentication transport data must not be delivered to the target as stdin data.

## Interactive execution

Interactive mode must execute the requested remote target under sudo with an interactive terminal path suitable for commands that require a TTY.

When valid credentials and a suitable remote system are supplied, rsudo must propagate the interactive target's observable output and final status.

Authentication data must not be exposed as ordinary terminal output.

## Target user

When `--user sudo_as_user` is supplied, the remote target must execute as the requested sudo target user, subject to the remote sudo policy.

## Invocation-local mode state

`rsudo` distinguishes reusable connection/credential state from modes that belong only to one invocation.

Connection state may remain in the current shell and be reused by a submodule and by recursive `rsudo` calls. This includes the current `RSUDO_HOST`, `RSUDO_USER`, `RSUDO_PASSWORD` values and credential groups loaded into shell memory.

At the start of every `rsudo` invocation, these invocation modes are inactive regardless of values left by an outer call or supplied as ambient shell variables:

```text
sudo target user
interactive mode
askpass mode
no-preserve-quotes mode
```

Only options parsed from the current invocation may enable those modes.

Therefore, when a submodule calls `rsudo` recursively, the nested call reuses connection/credential state but does not implicitly inherit `--user`, `--interactive`, `--askpass` or `--no-preserve-quotes` from the outer call.

The lower-level public `rsudo_core` function has a separate caller-state boundary: direct callers may provide `RSUDO_AS_USER`, `RSUDO_INTERACTIVE` and `RSUDO_NO_PRESERVE_QUOTES` as documented operational caller state. `RSUDO_ASKPASS` is not an `rsudo_core` input; password acquisition is performed by `rsudo` before delegation.

## Argument and command handling

A literal `--` ends rsudo option/submodule interpretation and sends the remaining operands to normal remote execution.

The normal command-preservation mode must preserve the caller-visible command/argument meaning across the remote execution boundary.

`--no-preserve-quotes` selects the documented alternate command-passing behavior for the current invocation.

The current `rsudo` option surface uses the documented long option spellings. The former short aliases `-n`, `-i` and `-A` are not `rsudo` options.

## Filesystem submodule

The `fs` submodule provides privileged remote filesystem operations through the same rsudo connection and privilege boundary.

`rsudo fs get remote_path local_path` transfers one remote filesystem object to the local system. Regular files, directories and symbolic links retain their object kind; a symbolic link is transferred as the link rather than by copying the object it references.

Before transferring, `get` estimates the remote source allocated size, free space on the local destination filesystem and reclaimable allocated size of an existing local destination.

If current local free space is sufficient for the incoming object while an existing destination remains present, `get` may proceed with sibling staging on the destination parent filesystem.

If current local free space is insufficient for staged replacement but the estimate would fit after deleting the existing local destination, `get` fails and reports that destructive replacement requires explicit prior local deletion. It must not delete the existing local destination implicitly.

If the estimate would still not fit after reclaiming the existing local destination, `get` fails as insufficient space.

When the local destination already exists, `get` completes the incoming transfer in sibling staging on the destination parent filesystem before replacing the existing destination. Failure before promotion leaves the existing destination in place. If promotion fails after the existing destination has been renamed aside, rollback is attempted.

`rsudo fs put local_path remote_path [owner_group] [permissions]` streams one local filesystem object directly into the privileged destination filesystem. It must not require a second complete copy through an unprivileged remote staging filesystem.

Before replacing an existing remote destination, `put` estimates the incoming allocated size, destination-filesystem free space and reclaimable allocated size of the existing destination.

If current free space is sufficient for the incoming object while the existing destination remains present, `put` may proceed with sibling staging on the destination parent filesystem.

If current free space is insufficient for staged replacement but the estimate would fit after deleting the existing destination, `put` fails and reports that destructive replacement would require an explicit prior `rsudo fs delete`. It must not delete the existing destination implicitly.

If the estimate would still not fit after reclaiming the existing destination, `put` fails as insufficient space.

These get/put space checks are preflight estimates, not allocation guarantees. Sparse files, quotas, filesystem allocation behavior and other runtime conditions may still cause a transfer to fail.

When replacing an existing remote destination, the incoming object is promoted only after transfer and requested metadata application succeed. The old destination is renamed aside, the completed stage is promoted, and the old copy is then removed. If promotion fails after the old destination was renamed aside, rollback is attempted.

The replacement sequence is staged and rollback-capable; it is not specified as one indivisible filesystem transaction.

## Credential loading

`--load file:group` separates the operand at its final `:`.

The `file` and `group` components are independent and each may be empty.

The observable cases are:

```text
file:group
    load/evaluate file, then select group credentials

file:
    load/evaluate file, do not select or replace credentials from a group

:group
    do not load a file, select group credentials already present in memory

:
    do not load a file and do not select a group; preserve existing connection state
```

A non-empty group selects credentials from:

```text
RSUDO_CREDENTIALS_GROUP_<group>_HOST
RSUDO_CREDENTIALS_GROUP_<group>_USER
RSUDO_CREDENTIALS_GROUP_<group>_PASS
```

A non-empty file may populate one or more such groups and other authenticated shell state. Loading the file alone does not imply selecting one of those groups.

The operand must contain the separator `:`; omitting the separator is invalid.

## Password acquisition

When `--askpass` is selected and stdin is not a TTY, rsudo consumes the password record designated by that mode before forwarding the operation's remaining input.

When the password is absent and interactive acquisition is applicable, rsudo may acquire it from the terminal.

A failed required password acquisition prevents remote execution.

## Errors and status

Invalid local invocation is rejected before remote execution.

When remote execution is reached, rsudo returns the resulting operation status rather than replacing it with an unrelated success status.

Infrastructure/setup failure that prevents the remote operation produces a non-zero result.

## Cleanup and termination

Resources owned only by one rsudo invocation must not remain live after that invocation has completed or been terminated.

Termination handling must preserve termination semantics rather than cleaning up and then continuing the interrupted operation.

## Security boundary

The supplied password is authentication data.

It must not be:

```text
printed as ordinary command output
delivered to the target as ordinary stdin data
embedded in an ordinary target argument merely as a side effect of authentication
left in per-invocation temporary resources after cleanup
```

This contract does not require one specific internal SSH/sudo authentication sequence, process topology, FIFO layout, IPC primitive, command probe or call order.

## Invariants

```text
RSUDO-01  valid connection data executes the requested remote target under sudo
RSUDO-02  target stdin is preserved and does not receive authentication data
RSUDO-03  target stdout/stderr remain observable to the caller
RSUDO-04  resulting remote target status is propagated
RSUDO-05  password-required sudo is supported
RSUDO-06  passwordless sudo/root operation is supported without contaminating target stdin
RSUDO-07  interactive mode executes the target through a terminal-capable remote path
RSUDO-08  --user selects the requested sudo target user
RSUDO-09  required password acquisition failure prevents remote execution
RSUDO-10  per-invocation resources are cleaned up on completion/termination
RSUDO-11  password data is not exposed as ordinary target input/output
RSUDO-12  internal SSH/sudo mechanics are not part of the observable contract
RSUDO-13  --load file:group treats file and group as independently optional components
RSUDO-14  fs get/put preserve regular-file, directory and symbolic-link object kind
RSUDO-15  fs put streams directly into the privileged destination filesystem without requiring an intermediate unprivileged full copy
RSUDO-16  fs get/put never perform an implicit destructive fallback when staged replacement lacks free space
RSUDO-17  fs get/put report when explicit deletion would make the estimated transfer fit, and fail until that deletion is explicitly requested
RSUDO-18  fs put promotes an existing-destination replacement only after transfer and requested metadata application succeed
RSUDO-19  fs get/put attempt rollback when staged replacement promotion fails after moving the previous destination aside
RSUDO-20  each rsudo invocation resets invocation-local target-user, interactive, askpass and no-preserve-quotes mode state before parsing its own options
RSUDO-21  recursive rsudo calls may reuse connection/credential state but do not inherit invocation modes from the outer call
```
