# rsudo Keycloak official CLI proxy

Status: Active
Updated: 2026-11-06

## Goal

Implement an agentless `rsudo keycloak discovery` and `rsudo keycloak kcadm` interface that locates the official remote Keycloak `kcadm.sh`, persists the selected per-remote-sudo-user executable path, and delegates CLI arguments through the existing rsudo SSH/sudo boundary. Login may use the operator's `KC_CLI_PASSWORD` without placing it in process arguments or logs.

## Current repository revisions

- rumiai-dev: bb10f51eed0482cb7eb47186644156fef0b9c779
- rumiai-os: e8504ab4652af626f1f72fe769bde742e6af4786
- rumiai-tests: 0d88b06c8c3d3e5c9f61a698528a914e19db6816

## Applicable canonical sources

- README.md, RULES.md, CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/RSUDO.md
- specifications/rumiai-os/RSUDO-KEYCLOAK.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DIAGNOSTICS.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- TESTING.md and TEST-PATTERNS.md

## Fixed task-local choices

- Reuse the existing `rsudo-mod-keycloak.lib.sh` facade, preserving legacy and auth functions.
- Delegate to the official remote `kcadm.sh`; do not implement a second client or require client secret provisioning.
- Prefer operator-owned `KC_CLI_PASSWORD`; never add a password argument to `ssh`, `sudo`, `sh -c`, or `kcadm.sh`.
- An interactive source injection in existing rsudo becomes a `sh -c` argument, so sensitive shell source must instead use rsudo's non-interactive `sh -s` stdin path.
- A remote process cannot export an environment variable into a future remote SSH/sudo process; discovery persistence is scoped to the effective target account and loaded as a shell variable on subsequent calls.

## Acceptance scenarios

1. An operator selects an explicit executable with `rsudo keycloak discovery --path /remote/bin/kcadm.sh`; a later `rsudo keycloak kcadm get realms` invokes that exact executable in the same remote sudo account.
2. Without an explicit path, discovery searches configured/known places and can require an operator choice if multiple candidates exist.
3. `KC_CLI_PASSWORD` reaches the remote kcadm process via its environment, not command-line arguments or logging; arbitrary non-secret CLI arguments retain their values.
4. Missing or invalid executable selection fails without executing anything. Transport and remote command statuses are observable.
5. Previously exposed `rsudo keycloak` operations remain callable.

## Working design

- External standard-input payloads for `kcadm` may require an independent channel; report the limitation if current rsudo script injection consumes caller stdin.
- Real network and sudo integration need explicit host validation; tests may isolate only the external SSH/sudo boundary.

## Completed

- Retrieved current repository authority and inspected rsudo non-interactive/interactive source transport and existing Keycloak module.

## Current state

Implementation not yet committed.

## Next action

Implement and test source/proxy and discovery, align specifications/manual, record validation evidence.

## Blockers / open questions

- None for implementation; physical target validation remains dependent on operator infrastructure.
