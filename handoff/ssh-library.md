# SSH library extraction

Status: Active
Updated: 2026-09-29

## Goal

Develop and stabilize a reusable m SSH library and SSH helper before considering any rsudo migration.

## Current repository revisions

- rumiai-os: ace7d8a5269c72fa7814ca290c3c21894aba50ad
- rumiai-tests: 476e0e9737e79282f9e857a093ff3d9cc6ef23c9

## Fixed task-local choices

- Existing rsudo.lib.sh, rsudo command, and rsudo-askpass are stable baselines and must not be modified.
- Implement ssh.lib.sh and ssh-askpass independently first.
- Any rsudo_core migration remains discussion-only until the SSH facility is stable.
- Current candidate API is ssh_password followed by native ssh arguments.

## Completed

- Preflight completed.
- Added ssh.lib.sh, ssh-askpass, and the ssh.lib.sh manual.
- Verified the product diff touches no rsudo path.

## Working design

The public API is being split by authentication semantics:

- `ssh_password` is intended to require a non-empty remote-account password and to force a fresh OpenSSH password-authentication attempt rather than merely making a secret available to OpenSSH.
- a separate `ssh_auth` API is under evaluation for normal OpenSSH authentication selection with an optional/empty generic askpass response.
- the two APIs should use separate askpass helpers because the password-only path can be one-shot and deterministic, while the general path may require repeated and prompt-aware responses.
- OpenSSH current behavior exposes confirmation prompts to askpass using `SSH_ASKPASS_PROMPT=confirm`, which can be used to prevent a generic secret from being mistaken for confirmation input.
- exact reusable-secret transport for the general `ssh_auth` path remains unresolved; current `ipc_once` is deliberately one-shot.

## Current state

The facility is not yet stable. ssh-askpass is executable and its command manual exists. The current implementation/specification still reflect the earlier single `ssh_password` design and must not be treated as final until the split above is resolved and realigned.

## Next action

Finalize the two authentication contracts, then realign SSH.md, ssh.lib.sh and manuals before adding permanent coverage.

## Blockers / open questions

- Define the exact forced OpenSSH options for `ssh_password`, including prevention of connection multiplexing that could bypass fresh authentication.
- Define a secure repeatable secret-provider mechanism for `ssh_auth`; `ipc_once` cannot serve multiple askpass invocations.
