# pkg integration optimization

Status: Active
Updated: 2026-10-02

## Goal

Review and optimize the current `pkg_integrate` implementation while preserving the promoted package-integration contract unless a semantic change is explicitly justified and propagated.

## Current repository revisions

- rumiai-dev: a4d90711126ff98f01fa52b27bbfef9231c56bd0 (pre-handoff HEAD)
- rumiai-os: f2c3c0ae02258cc80d81f6e1be1ad2cee338d702
- rumiai-tests: b0715c677c428af68ea507983db5443a89428f8f

## Stable reference

The user selected the current rumiai-os revision:

```text
f2c3c0ae02258cc80d81f6e1be1ad2cee338d702
```

as version `2.0.1` and as the stable reference before optimization.

The available GitHub connector does not expose tag creation and the execution environment cannot reach github.com directly, so the requested Git tag `2.0.1` has not yet been created. Do not modify the stable reference commit itself; preserve it as the comparison baseline.

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md

## Scope

- inspect `lib/sys/sh/pkg/pkg-integration.lib.sh`, its public manual, callers and permanent tests;
- identify duplication, unnecessary coupling and rollback complexity inside `pkg_integrate`;
- preserve public behavior and package-store semantics unless a contract change is explicitly promoted;
- realign manual/tests if the public function contract or observable behavior changes;
- validate proportionally with the strongest execution environment actually available.

## Current state

Preflight is in progress. No rumiai-os or rumiai-tests source modification has been made for this task.

## Next action

Complete implementation/test review and derive a behavior-preserving simplification plan before modifying product code.

## Blockers / open questions

- Git tag `2.0.1` cannot currently be created through the available connector. The exact stable commit is recorded above.
