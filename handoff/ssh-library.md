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

## Current state

The facility is not yet stable. The new command still needs its executable Git mode and required command manual. Permanent coverage is also pending.

## Next action

Complete command packaging/documentation, add permanent coverage, and validate the facility.

## Blockers / open questions

Repository write controls blocked the remaining command-mode and documentation operations in this response.
