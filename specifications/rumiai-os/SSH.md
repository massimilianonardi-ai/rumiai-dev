# RumiAI OS — SSH authentication invocation

Status: **Current / normative**
Updated: 2026-09-29

## Scope

The m SSH facility provides controlled OpenSSH invocation with caller-supplied
authentication secret delivery that does not consume SSH standard input.

The public interfaces are:

```text
ssh_auth pass ssh-argument...
ssh_password password ssh-argument...
```

The first secret operand is required, must be non-empty and must not contain a
newline.

After that operand, caller SSH arguments are passed to OpenSSH unchanged and in
the same order. The facility does not reinterpret destination syntax, remote
commands, terminal allocation, forwarding or ordinary SSH stream semantics.

## General authentication

`ssh_auth` leaves OpenSSH authentication-method selection to normal OpenSSH
configuration.

It forces only these connection-local settings before caller arguments:

```text
BatchMode=no
ControlPath=none
```

`BatchMode=no` allows OpenSSH to request authentication secret input.
Connection sharing is disabled so authentication for the invocation is not
silently replaced by reuse of an existing multiplexed connection.

Whenever OpenSSH requests secret-entry input through askpass, `ssh_auth`
returns the same caller-provided `pass`. The value may therefore be tried more
than once during one SSH invocation, including for an encrypted private-key
passphrase and later account-password authentication.

`ssh_auth` does not classify secret prompts by their human-readable text.

A request marked by OpenSSH as `SSH_ASKPASS_PROMPT=confirm` is refused and does
not receive the supplied secret.

## Password-only authentication

`ssh_password` constrains OpenSSH to password authentication and exactly one
password prompt for the invocation.

The facility supplies these effective OpenSSH settings before caller arguments:

```text
BatchMode=no
PasswordAuthentication=yes
PreferredAuthentications=password
NumberOfPasswordPrompts=1
ControlPath=none
```

This prevents ordinary user/system SSH configuration from replacing the
password-only authentication policy or reusing a configured multiplexed
connection.

Callers must not use the direct `-S` control-socket option to replace the
facility-owned `ControlPath=none` setting.

If the server does not permit password authentication or the supplied password
is rejected, OpenSSH fails the authentication attempt.

## Stream contract

Authentication secret input is not obtained from SSH standard input.

Standard input, standard output and standard error retain their ordinary
OpenSSH meanings. This permits callers to pipe data through SSH or attach SSH to
a terminal without authentication transport consuming or rewriting those
streams.

## Authentication transport

The secret is made available to OpenSSH through the m-owned `ssh-askpass`
helper.

`ssh_password` uses an invocation-owned one-shot `ipc_once` value because its
contract permits exactly one password prompt.

`ssh_auth` uses an invocation-owned private repeatable provider. The provider
keeps the secret in the broker process and supplies one copy for each accepted
askpass secret request. Its temporary IPC resource is private to the invocation
and is removed during cleanup.

Authentication secrets must not be inserted into ordinary SSH command arguments
or emitted as ordinary command output. Invocation-owned authentication IPC state
must be cleared after use.

## Host verification

OpenSSH retains responsibility for host-key verification and known-host state.

Neither public function weakens host-key verification and neither uses the
supplied secret as confirmation input. Confirmation requests are refused by
`ssh-askpass`.

Interactive host enrollment or other trust decisions therefore require a
separate ordinary interactive OpenSSH invocation; they are not performed by
`ssh_auth` or `ssh_password`.

## ssh-askpass

`ssh-askpass` is the bootstrap-integrated companion command used by both public
functions.

OpenSSH invokes it with the prompt text as one operand. For a normal
secret-entry prompt, the helper reads from the invocation-owned provider
selected by the calling SSH function.

A request marked by OpenSSH as `SSH_ASKPASS_PROMPT=confirm` is rejected before
any secret is consumed.

The helper defines no independent connection semantics.

## Status

When local setup and cleanup succeed, each public function returns the OpenSSH
invocation status.

Invalid local invocation or local authentication-transport setup/cleanup
failure is non-zero.

## Invariants

```text
SSH-01  both public functions require a non-empty newline-free supplied secret
SSH-02  ssh_password constrains OpenSSH authentication to password
SSH-03  ssh_password permits exactly one OpenSSH password prompt
SSH-04  configured SSH connection sharing is disabled for both public functions
SSH-05  caller SSH arguments remain unchanged and ordered after facility options
SSH-06  authentication data is not consumed from SSH standard input
SSH-07  SSH stdin/stdout/stderr retain their OpenSSH meanings
SSH-08  authentication data is not placed in ordinary SSH command arguments
SSH-09  invocation-owned authentication IPC state is cleared after use
SSH-10  OpenSSH retains ownership of host-key verification and known-host state
SSH-11  ssh-askpass refuses confirmation prompts and never answers them with a secret
SSH-12  ssh-askpass is the m-owned authentication-secret companion
SSH-13  ssh_auth preserves normal OpenSSH authentication-method selection
SSH-14  ssh_auth can supply the same secret for multiple secret-entry prompts
```
