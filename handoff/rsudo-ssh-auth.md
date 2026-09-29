# rsudo SSH authentication

Status: Active
Updated: 2026-09-29

## Goal

Define the SSH invocation mode required by rsudo and then migrate rsudo to it.

## Current repository revisions

- rumiai-dev: 28fd52d66741cd9a5f2a8b335154e8372889c0e3 before this checkpoint
- rumiai-os: 36d6b53b461c91db790873625f2f5349972768fb
- rumiai-tests: ce64eab23d03fefc3b93eb2d6baf57d0e5ccd013

## Applicable canonical sources

- specifications/rumiai-os/SSH.md
- specifications/rumiai-os/RSUDO.md

## Fixed task-local choices

- `ssh_auth pass ssh-argument...` lets OpenSSH use its normal configured
  authentication mechanisms.
- Whenever OpenSSH requests secret-entry input during authentication,
  `ssh_auth` supplies the same caller-provided `pass`; it never prompts the
  caller for another secret.
- This includes an encrypted local private key that is not already usable
  through the agent.
- Confirmation/trust prompts are not answered with `pass`.
- The secret provider must support multiple requests during one SSH invocation.
- Normal rsudo uses `ssh_auth`; it does not perform interactive trust setup.
- `rsudo --ssh-auth-check` is the explicit interactive preparation/check path
  for host enrollment and ordinary OpenSSH credential preparation.

## Working design

The current one-shot provider used by `ssh_password` cannot implement
`ssh_auth` because OpenSSH may request more than one secret during a single
authentication attempt. A reusable invocation-scoped secret provider is needed.

The interactive check should use ordinary OpenSSH terminal interaction rather
than the non-interactive `ssh_auth` provider. Whether it should force
`AddKeysToAgent=yes` is still to be finalized.

## Completed

- Current OpenSSH behavior and existing SSH/rsudo contracts inspected.
- Required normal-vs-check interaction split fixed.

## Current state

No runtime implementation has been changed.

## Next action

Finalize exact `ssh_auth` OpenSSH options and the `--ssh-auth-check`
agent-loading behavior, then update the SSH contract before implementation.

## Blockers / open questions

- exact keyboard-interactive handling
- whether `--ssh-auth-check` forces `AddKeysToAgent=yes`
