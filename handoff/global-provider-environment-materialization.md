# Global provider environment materialization

Status: Active
Updated: 2026-10-04

## Goal

Move system facility-default environment resolution out of the high-frequency m execution path and into package/default mutation time, while keeping bootstrap responsible only for sourcing already-materialized environment state.

## Current repository revisions

- rumiai-dev: 12d7994e4e08415140aaebb3f7adb9a391227312 (pre-activation HEAD)
- rumiai-os: ea2eb22917edca77a44566ee415301f69ca61ad8
- rumiai-tests: 95f2a8568433fa88b7da4e627842b2f3d426d08d

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/STATE-MODEL.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- handoff/pkg-integration-optimization.md

## Fixed task-local choices

- Global facility environment is resolved/materialized when authoritative provider/package default state changes, not recomputed for each m invocation.
- The m bootstrap remains ignorant of provider selectors, facilities and package-resolution mechanics. It only sources generated environment state as part of the execution phase.
- Bootstrap has two environment source points: one osarch-independent environment file and one osarch selector symlink whose target is the environment file for the currently selected osarch.
- Platform-specific target environment files are materialized ahead of selection; changing osarch changes the selector symlink rather than resolving package/provider state.
- The osarch command owns and maintains the environment-osarch selector together with the existing sys/ext/ai osarch selectors.
- Global provider environment materialization includes PATH contributions as well as ordinary exported variables. A Java provider therefore may set JAVA_HOME and contribute its selected root/bin to PATH.
- Consumer-specific provider bindings do not affect global environment materialization.
- Existing functions such as pkg_provider_global_environment_apply remain in place during development and may be reused. Removal or API retirement is deferred until the new mechanism is complete and their future usefulness has been explicitly reassessed.

## Acceptance scenarios

1. Setting a generic facility default materializes its global variables/PATH contributions. The already-running process is unchanged; a new m invocation sees the materialized environment.
2. Changing the provider package default updates the materialized environment for every affected generic/platform class while preserving selector intent, including pinned versus unversioned behavior.
3. Changing osarch updates the environment-osarch selector along with the existing osarch selectors. A subsequent m invocation sees the already-materialized environment for the newly selected platform without provider resolution.
4. A failed provider/default transition leaves both global command publication and global environment materialization at the previous coherent state.
5. Removing a facility default or making a provider class unavailable removes its contributions from subsequently sourced global environment state.
6. PATH contributions are deterministic and preserve the technical m command-path contract while making selected provider runtime directories reachable.

## Working design

The current provider code already owns selector resolution, concrete facility-env validation, deterministic facility ordering, global command reconciliation and rollback. The new environment materialization should reuse these responsibilities rather than introduce a second resolver.

The intended shape is:

```text
provider/package default mutation
    -> resolve effective facility environments
    -> build generic + per-osarch environment snapshots
    -> safely serialize ordinary variables and PATH contributions
    -> atomically publish generated snapshots
    -> commit authoritative selector/default transition

osarch mutation
    -> update sys/ext/ai selectors
    -> update environment-osarch selector to the precomputed target

m execution phase
    -> source osarch-independent environment
    -> source selected environment-osarch target
    -> execute requested command
```

The two bootstrap source points imply one generic regular file plus an osarch selector symlink. The selector necessarily targets a precomputed per-osarch regular file; those target files are generated artifacts but are not additional bootstrap source identities.

Generated environment is derived/regenerable state under `state-path system sys environment cache`, physically `$m_STATE_SYS_DIR/sys/environment/cache`. The source identities are `env` and selector `env-osarch`; generated targets are `env-<osarch>`.

`PATH` is a special `facility-env` variable. It accepts only `root` and `root-path` descriptors, may repeat, and each record contributes one provider directory rather than replacing PATH. Later records/facilities have higher precedence. Final bootstrap order is technical m roots, selected-osarch provider PATH, osarch-independent provider PATH, inherited host PATH.

Materialization computes the normalized final environment for every supported osarch. Ordinary assignments identical in all supported osarch contexts are emitted in `env`; the rest are emitted only in platform snapshots. PATH is treated as one complete ordered sequence: it is generic only when the whole sequence is identical across all supported osarchs, otherwise each platform snapshot carries its full sequence.

The environment snapshots and global command projections represent two derived views of the same facility-default/package-default transition and should participate in one rollback boundary.

## Completed

- Verified current bootstrap performs no package/provider initialization.
- Verified current pkg-provider global environment implementation resolves facility defaults dynamically and exports a validated environment plan.
- Verified current package-default transitions already call pkg_provider_package_default_reconcile for affected global command projections.
- Verified current osarch command atomically replaces individual sys/ext/ai selector links but does not yet own an environment selector.
- Verified permanent facility-default-global coverage already exercises most required observable behavior: new-process visibility, running-process stability, pinned/unversioned selectors, package-default following, unset and rollback.

## Current state

The pathname and PATH semantics are now promoted into BOOTSTRAP-ENVIRONMENT.md, PACKAGE-MODEL.md and STATE-MODEL.md. Product behavior has not yet been changed; implementation is the next step.

## Next action

Implement the promoted materialization/bootstrap/osarch contract, including transactional reconciliation and permanent coverage.

## Blockers / open questions

- Exact multi-selector rollback strategy for osarch when adding the environment selector.
