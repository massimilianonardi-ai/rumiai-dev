# RumiAI OS — SSH authentication invocation

Status: **Current / normative**
Updated: 2026-09-29

## Scope

The m SSH facility provides controlled OpenSSH invocation modes that can supply
caller-owned authentication secrets without consuming ordinary SSH standard
input.

The public interfaces are:

```text
ssh_auth secret ssh-argument...
ssh_password password ssh-argument...
```

Both secret operands are required, must be non-empty and must not contain a
newline.

After the secret operand, caller SSH arguments are passed to OpenSSH unchanged
and in the same order. The facility does not reinterpret destination syntax,
remote commands, terminal allocation, forwarding or ordinary SSH stream
semantics.

## General authentication with ssh_auth

`ssh_auth` leaves OpenSSH authentication-method selection and ordering to
OpenSSH and its normal configuration.

The facility forces these settings before caller arguments:

```text
BatchMode=no
StrictHostKeyChecking=yes
```

`BatchMode=no` permits OpenSSH authentication mechanisms that require
secret-entry input to ask through the facility-owned askpass path.

`StrictHostKeyChecking=yes` prevents a normal `ssh_auth` invocation from
performing interactive host enrollment or accepting an unknown/changed host key.
Host trust preparation is outside `ssh_auth` and remains an explicit caller
operation.

Whenever OpenSSH invokes askpass for secret-entry input during one
`ssh_auth` invocation, the facility returns the same caller-supplied
`secret`. The value may therefore be tried more than once, including for:

```text
an encrypted private-key passphrase
password authentication
another OpenSSH secret-entry request
```

The facility does not infer the authentication mechanism from human-readable
prompt text.

OpenSSH confirmation requests are refused and are never answered with
`secret`.

`ssh_auth` does not otherwise force:

```text
PreferredAuthentications
PasswordAuthentication
PubkeyAuthentication
KbdInteractiveAuthentication
IdentitiesOnly
IdentityFile
AddKeysToAgent
ControlMaster / ControlPath
```

Those remain governed by OpenSSH and caller configuration unless another
facility-owned invariant above constrains them.

## Password-only authentication with ssh_password

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

Authentication secrets are not obtained from SSH standard input.

Standard input, standard output and standard error retain their ordinary
OpenSSH meanings. This permits callers to pipe data through SSH or attach SSH to
a terminal without authentication transport consuming or rewriting those
streams.

## Authentication transport

Authentication values are made available to OpenSSH through the m-owned
`ssh-askpass` helper.

`ssh_password` uses one invocation-owned one-shot IPC value because its
contract permits one password prompt.

`ssh_auth` uses one invocation-owned repeatable secret channel because OpenSSH
may ask for secret-entry input multiple times while trying configured
authentication mechanisms.

The authentication value must not be inserted into ordinary SSH command
arguments or emitted as ordinary command output. Invocation-owned
authentication transport state must be cleaned up after use.

## Host verification

OpenSSH retains responsibility for host-key verification and known-host state.

Neither facility weakens host-key verification or uses an authentication secret
as host-key confirmation input.

`ssh_auth` requires already-established host trust through
`StrictHostKeyChecking=yes`. `ssh_password` retains the password-only
contract's existing host-verification behavior and refuses askpass requests
classified by OpenSSH as confirmation requests.

Interactive host enrollment or other trust preparation is performed outside
these non-interactive secret-supply facilities.

## ssh-askpass

`ssh-askpass` is the bootstrap-integrated companion command used by both SSH
functions.

OpenSSH invokes it with one prompt operand.

For `ssh_password`, the helper consumes the invocation-owned one-shot value.

For `ssh_auth`, the helper reads one record from the invocation-owned
repeatable secret channel for each secret-entry request.

A request marked by OpenSSH as `SSH_ASKPASS_PROMPT=confirm` is rejected without
consuming authentication data.

The helper defines no independent connection semantics.

## Status

When local setup and cleanup succeed, each facility returns the OpenSSH
invocation status.

Invalid local invocation or local authentication-transport setup/cleanup
failure is non-zero.

## Invariants

```text
SSH-01  ssh_password requires a non-empty newline-free remote-account password
SSH-02  ssh_password constrains OpenSSH authentication to password
SSH-03  ssh_password permits exactly one OpenSSH password prompt
SSH-04  configured SSH connection sharing is disabled for ssh_password
SSH-05  caller SSH arguments remain unchanged and ordered after facility options
SSH-06  authentication data is not consumed from SSH standard input
SSH-07  SSH stdin/stdout/stderr retain their OpenSSH meanings
SSH-08  authentication data is not placed in ordinary SSH command arguments
SSH-09  invocation-owned authentication transport state is cleared after use
SSH-10  OpenSSH retains ownership of host-key verification and known-host state
SSH-11  ssh-askpass refuses classified confirmation prompts
SSH-12  ssh-askpass is the m-owned companion for SSH authentication secret delivery
SSH-13  ssh_auth requires a non-empty newline-free candidate authentication secret
SSH-14  ssh_auth leaves OpenSSH authentication-method selection and order unchanged
SSH-15  ssh_auth supplies the same secret for repeated OpenSSH secret-entry requests
SSH-16  ssh_auth does not classify authentication mechanisms by prompt text
SSH-17  ssh_auth requires pre-established host trust and does not perform host enrollment
SSH-18  ssh_auth does not consume or modify ordinary SSH streams while supplying secrets
```
