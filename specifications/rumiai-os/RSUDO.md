# RumiAI OS — rsudo remote privilege execution

Status: **Current / normative**  
Updated: 2026-09-25

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

## Argument and command handling

A literal `--` ends rsudo option/submodule interpretation and sends the remaining operands to normal remote execution.

The normal command-preservation mode must preserve the caller-visible command/argument meaning across the remote execution boundary.

`--no-preserve-quotes` selects the documented alternate command-passing behavior.

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
```
