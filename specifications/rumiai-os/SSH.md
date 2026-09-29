# RumiAI OS — SSH password invocation

Status: **Current / normative**
Updated: 2026-09-29

## Scope

The m SSH facility provides a thin, deterministic remote-account password
authentication layer around the system OpenSSH client.

The public interface is:

```text
ssh_password password ssh-argument...
```

`password` is required, must be non-empty and must not contain a newline. The newline restriction follows the current one-record `ipc_once` transport.

After the password operand, caller SSH arguments are passed to OpenSSH unchanged
and in the same order. The facility does not reinterpret destination syntax,
remote commands, terminal allocation, forwarding or ordinary SSH stream
semantics.

## Password-authentication contract

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

The password is not obtained from SSH standard input.

Standard input, standard output and standard error retain their ordinary
OpenSSH meanings. This permits callers to pipe data through SSH or attach SSH to
a terminal without authentication transport consuming or rewriting those
streams.

## Authentication transport

The password is made available to OpenSSH through the m-owned
`ssh-askpass` helper backed by one invocation-owned `ipc_once` value.

The one-shot transport matches the one-password-prompt contract.

The password must not be inserted into ordinary SSH command arguments or
emitted as ordinary command output. Invocation-owned IPC state must be cleared
after use.

## Host verification

OpenSSH retains responsibility for host-key verification and known-host state.

The facility does not weaken host-key verification and does not use the supplied
password as confirmation input. When OpenSSH classifies an askpass request as a
confirmation request, `ssh-askpass` refuses it.

Host enrollment or other interactive trust decisions are outside the
`ssh_password` contract.

## ssh-askpass

`ssh-askpass` is the bootstrap-integrated companion command used by
`ssh_password`.

OpenSSH invokes it with the prompt text as one operand. For a normal secret
prompt, the helper consumes the invocation-owned one-shot IPC value and returns
the password to OpenSSH. A request marked by OpenSSH as
`SSH_ASKPASS_PROMPT=confirm` is rejected without consuming the password.

The helper defines no independent connection semantics.

## Status

When local setup and cleanup succeed, `ssh_password` returns the OpenSSH
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
SSH-09  invocation-owned authentication IPC state is cleared after use
SSH-10  OpenSSH retains ownership of host-key verification and known-host state
SSH-11  ssh-askpass refuses confirmation prompts and never answers them with the password
SSH-12  ssh-askpass is the m-owned one-shot password companion for ssh_password
```
