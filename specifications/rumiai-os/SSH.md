# RumiAI OS — SSH password invocation

Status: **Current / normative**
Updated: 2026-09-29

## Scope

The m SSH facility is a thin password-delivery layer around the system OpenSSH client. It does not replace or reinterpret the OpenSSH command-line interface.

The public library interface is:

```text
ssh_password password ssh-argument...
```

After the non-empty password operand, every operand is passed to `ssh` unchanged and in the same order.

## Stream contract

Authentication data is not obtained from SSH standard input. Standard input, standard output and standard error retain their ordinary OpenSSH meanings.

This permits callers to use ordinary SSH pipes, terminal attachment and remote commands without the password transport consuming or rewriting those streams.

## Authentication transport

The password is made available to OpenSSH through the m-owned `ssh-askpass` helper backed by an invocation-owned one-shot IPC value.

The password must not be inserted into ordinary SSH command arguments or emitted as ordinary command output. Invocation-owned IPC state must be cleared after use.

## OpenSSH ownership

OpenSSH retains responsibility for host-key verification and known-host state, SSH configuration, authentication-method selection, connection establishment, terminal allocation requested by SSH arguments, remote-command execution and SSH exit status.

The m facility must not weaken host-key verification.

## ssh-askpass

`ssh-askpass` is the bootstrap-integrated companion command used by `ssh_password`. It consumes the invocation-owned IPC identity supplied by the library and defines no independent connection semantics.

## Status

When local setup and cleanup succeed, `ssh_password` returns the OpenSSH invocation status. Local authentication-transport setup or cleanup failure is non-zero.

## Invariants

```text
SSH-01  ssh_password passes every SSH argument unchanged after its password operand
SSH-02  authentication data is not consumed from SSH standard input
SSH-03  SSH stdin/stdout/stderr retain their OpenSSH meanings
SSH-04  authentication data is not placed in ordinary SSH command arguments
SSH-05  invocation-owned authentication IPC state is cleared after use
SSH-06  OpenSSH retains ownership of host-key verification and known-host state
SSH-07  the facility does not weaken OpenSSH host-key verification
SSH-08  ssh-askpass is the m-owned askpass companion for ssh_password
```
