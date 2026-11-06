# rsudo Keycloak official CLI proxy

Status: Complete
Updated: 2026-11-06

## Goal

Implement an agentless `rsudo keycloak discovery` and `rsudo keycloak kcadm` interface that locates the official remote Keycloak `kcadm.sh`, persists the selected per-remote-sudo-user executable path, and delegates CLI arguments through the existing rsudo SSH/sudo boundary. Login may use the operator's `KC_CLI_PASSWORD` without placing it in process arguments or logs.

## Current repository revisions

- rumiai-dev: c2e252680bb2ec79978f605fcd76d1c064d02db1 (pre-completion checkpoint)
- rumiai-os: 679cd66fd8329f077c0223972d4c5bee14629f05
- rumiai-tests: 43e198a6c9321f7a075f69232ef2adabf1d479c8 (current HEAD; unrelated work preserved)

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

## Completed

- Retrieved current repository authority and inspected rsudo non-interactive/interactive source transport and existing Keycloak module.
- Added discovery/kcadm operations to the existing facade, synchronized operational manual and canonical specification index/contract.
- Added source-level proxy test and real SSH/sudo test with executable entrypoints and validation scope selections.
- Focused Linux ARM64 and macOS validation passed at rumiai-tests 5aedb9b5e84d87d0ec00ea815b12695120dd504d and rumiai-os 679cd66fd8329f077c0223972d4c5bee14629f05.

## Current state

Completed and published. Existing Keycloak rsudo legacy and direct Keycloak CLI interfaces remain separate. 
Validation evidence:
- rsudo-keycloak: https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/42305858296
  frozen rumiai-os 679cd66fd8329f077c0223972d4c5bee14629f05;
  frozen rumiai-tests 5aedb9b5e84d87d0ec00ea815b12695120dd504d.
  macOS ARM64 and Linux ARM64: 3/3 selected tests PASS per host.
- rsudo-keycloak-ssh: https://github.com/massimilianonardi-ai/rumiai-tests/actions/runs/42306095159
  frozen rumiai-os 679cd66fd8329f077c0223972d4c5bee14629f05;
  frozen rumiai-tests 017613ca32053c99507b3b32b1a6d16d891eb1a9.
  Real SSH/sudo to disposable Linux container: 2/2 selected tests PASS.

No actual Keycloak server credential exchange or physical enterprise host was tested as part of this new CLI proxy; the SSH integration fixture uses an external kcadm.sh stand-in.
The current source-over-stdin proxy intentionally does not forward an independent caller stdin payload to kcadm.sh, as explicitly recorded in the canonical specification/manual.

## Next action

None. The task is complete. 

## Blockers / open questions

None. This completed snapshot is retained only until its separate forward removal commit.
