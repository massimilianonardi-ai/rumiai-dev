# rsudo Keycloak official CLI proxy

Status: Active
Updated: 2026-11-06

## Goal

Implement an agentless `rsudo keycloak discovery` and `rsudo keycloak kcadm` interface that locates the official remote Keycloak `kcadm.sh`, persists the selected per-remote-sudo-user executable path, and delegates CLI arguments through the existing rsudo SSH/sudo boundary. Login may use the operator's `KC_CLI_PASSWORD` without placing it in process arguments or logs.

## Current repository revisions

- rumiai-dev: 73410562a44e8e51a4634491b378797731a3bbe2
- rumiai-os: 679cd66fd8329f077c0223972d4c5bee14629f05
- rumiai-tests: 017613ca32053c99507b3b32b1a6d16d891eb1a9

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
- Added discovery/kcadm operations to the existing facade, synchronized operational manual and canonical specification index/contract.
- Added source-level proxy test and real SSH/sudo test with executable entrypoints and validation scope selections.
- Focused Linux ARM64 and macOS validation passed at rumiai-tests 5aedb9b5e84d87d0ec00ea815b12695120dd504d and rumiai-os 679cd66fd8329f077c0223972d4c5bee14629f05.

## Current state

Implemented and committed. Focused rsudo-keycloak workflow passed on Linux ARM64 and macOS after a shell portability fix. A separate real OpenSSH/sudo proxy test has been added to the SSH validation scope; its focused run is in progress.

## Next action

Inspect the real SSH/sudo test result, address any failures, then complete the final consistency audit and close this handoff only after supported validation.

## Blockers / open questions

- None for implementation; physical target validation remains dependent on operator infrastructure.
