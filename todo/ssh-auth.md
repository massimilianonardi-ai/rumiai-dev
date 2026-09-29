# General SSH authentication facility

## Intent

Define a future `ssh_auth` API for normal OpenSSH authentication selection with
a generic askpass secret that may be empty and may be requested more than once.

## Why pending

The active SSH work now targets only deterministic remote-account password
authentication through `ssh_password`. General authentication is not required
for the current rsudo migration and would require a distinct repeatable,
prompt-aware credential provider.

## Scope

- rumiai-dev SSH contract
- rumiai-os ssh.lib.sh and a separate askpass helper
- proportional permanent coverage in rumiai-tests

## Evidence

- `specifications/rumiai-os/SSH.md`
- `handoff/ssh-library.md`
- current `lib/sys/sh/ssh.lib.sh`
