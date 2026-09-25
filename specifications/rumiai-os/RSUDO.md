# RumiAI OS — rsudo remote privilege execution

Status: **Current / normative**  
Updated: 2026-09-25

This specification defines the current authentication, input-separation and execution contract for the `rsudo` subsystem implemented by `lib/sys/sh/rsudo/rsudo.lib.sh`.

## Scope

`rsudo` executes commands on a remote host through SSH and elevates them through remote `sudo`.

The current public library surface is documented operationally in:

```text
res/sys/manual/rsudo.lib.sh
```

This specification defines only the subsystem semantics that permanent tests and future implementation changes must preserve.

## Authentication separation

SSH authentication and sudo authentication are separate credential-consumption events.

SSH password delivery uses the local one-shot IPC facility through `rsudo-askpass` and `SSH_ASKPASS`. Each SSH invocation receives its own one-shot credential identity and the local owner remains responsible for clearing it.

The sudo password must never be passed as part of the remote command line.

## Non-interactive execution

For non-interactive execution, the SSH input stream conceptually contains:

```text
sudo password record
target stdin bytes/records...
```

The remote rsudo prelude MUST consume the sudo password record itself before target execution.

It then validates sudo credentials with:

```sh
printf '%s\n' "$RSUDO_PASSWORD" |
    sudo -S --prompt='' -v
```

After successful validation, the target MUST be executed through non-interactive sudo:

```text
sudo -n ... -- target
```

The target therefore receives only its own stdin. Whether the selected sudoers rule requires a password, is `NOPASSWD`, or the remote login user is already privileged MUST NOT cause the sudo password record to reach target stdin.

A probe against an unrelated command MUST NOT be used to decide whether the target sudo invocation will consume a password.

## Interactive execution

Interactive execution uses separate SSH sessions for remote password staging and the foreground TTY session.

The remote password staging/rendezvous remains private to the remote login user.

Before foreground target execution, the second remote session validates sudo credentials with `sudo -S --prompt='' -v`.

The foreground target MUST then execute through `sudo -n` under the allocated remote TTY.

After validation, sudo MUST NOT fall back to reading a password from the target command's TTY.

## Failure behavior

If credential validation fails, target execution does not begin.

If the later `sudo -n` target invocation cannot proceed without further authentication, it fails rather than requesting or consuming another password.

The final foreground SSH/remote-target status is preserved.

For interactive execution, when the foreground operation succeeds but the asynchronous password-staging helper fails, the helper failure becomes the final result.

## Cleanup and signals

Each `rsudo_core` invocation owns its local one-shot SSH credential state and any asynchronous helper process it starts.

Normal exit clears owned one-shot state.

Termination handling must clean up owned state and preserve the terminating signal semantics rather than absorbing the signal and continuing execution.

Remote temporary password-rendezvous state must be removed after successful use or failure.

## Security boundary

The password may exist transiently in process memory and in the private transport mechanisms required by the current execution mode.

It MUST NOT be:

```text
embedded in the remote command line
left as target stdin data
logged as plaintext
reused through a persistent broker
```

One-shot SSH credential identities are opaque and must be exposed only to the SSH process intended to consume them.

## Invariants

```text
RSUDO-01  SSH authentication uses one-shot local IPC through SSH_ASKPASS
RSUDO-02  sudo authentication data is separated from target stdin/TTY
RSUDO-03  non-interactive remote code consumes the sudo password before target stdin
RSUDO-04  sudo credentials are validated with sudo -S --prompt='' -v before target execution
RSUDO-05  target execution uses sudo -n after validation
RSUDO-06  NOPASSWD/root cases never expose the password record to target stdin
RSUDO-07  unrelated sudo command probes do not decide target password consumption
RSUDO-08  foreground target status is preserved
RSUDO-09  owned local/remote credential state is cleaned up on completion/failure
RSUDO-10  termination cleanup preserves terminating-signal semantics
RSUDO-11  the sudo password is never embedded in the remote command line
```
