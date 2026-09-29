# SSH library extraction

Status: Active
Updated: 2026-09-29

## Goal

Develop and stabilize a reusable m SSH library and SSH askpass helper before considering any rsudo migration.

## Fixed task-local choices

- Existing rsudo.lib.sh, rsudo command, and rsudo-askpass are stable baselines and must not be modified.
- Implement ssh.lib.sh and ssh-askpass independently first.
- Any rsudo_core migration remains discussion-only until the SSH facility is stable.

## Current state

Preflight completed. No rsudo baseline file has been modified.

## Next action

Implement and validate the SSH facility.
