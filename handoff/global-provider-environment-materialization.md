# Global provider environment materialization

Status: Active
Updated: 2026-10-05

## Goal

Move system facility-default environment resolution out of the high-frequency m execution path and into package/default mutation time, while keeping bootstrap responsible only for sourcing already-materialized environment state.

## Current repository revisions

- rumiai-dev: 7e8db7a31c5b634bf852615a87bcaf2c50d0779f (pre-checkpoint HEAD)
- rumiai-os: 2693e5695e7b75c45b1cda0a490435480960534d
- rumiai-tests: d50c2ef0f4c3a02dbcfad645ff2900c51ab1655c

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

- Promoted the materialized environment contract into BOOTSTRAP-ENVIRONMENT.md, PACKAGE-MODEL.md and STATE-MODEL.md.
- pkg-provider now builds normalized final environment plans for every supported osarch, extracts assignments common to all platforms into env, emits platform deltas into env-<osarch>, safely serializes them, and publishes the generated snapshot set with rollback.
- pkg-provider default and provider-package-default reconciliation now regenerate the environment snapshots as part of the same logical transition as global command publication. Existing pkg_provider_environment_apply and pkg_provider_global_environment_apply remain available.
- facility-env now accepts PATH as a special repeatable member with root/root-path descriptors only; root-path PATH contributions must resolve to directories inside the provider root.
- m now sources env then env-osarch immediately before command execution and only afterward prepends the technical sys/ext command roots. It performs no provider/package resolution.
- osarch now owns env-osarch in addition to sys/ext/ai selectors, validates consistency across all four and performs best-effort rollback of the whole selector transition. If a materialized env exists, a missing selected platform snapshot is treated as cache corruption rather than silently synthesized.
- Operational manuals for m, osarch, pkg-provider and pkg-facility-env were realigned.
- Permanent coverage now includes PATH facility conformance, env-osarch selection, global provider PATH behavior and a dedicated osarch-specific precomputed-environment scenario.
- Focused validation on Ubuntu against rumiai-os@2693e5695e7b75c45b1cda0a490435480960534d confirms PASS for osarch/update, pkg/provider, pkg/env, pkg/facility-contract, the new pkg/facility-default-osarch-env scenario, pkg-integration/contract, pkg-launch, pkg-download, srv and the selected repository/external paths reached so far.
- Earlier full-health evidence also confirms the bootstrap test surface remains passing on Linux ARM and macOS. Several unrelated/stale package-suite failures remain outside this task.
- The focused provider/facility validation scope was realigned from historical rumiai-os@0966ba9... to current rumiai-os@2693e569... and obsolete install-stream.test was replaced by current selections.

## Current state

The promoted design is implemented. The osarch-specific materialization path is proven by the focused Ubuntu test: switching linux-x86_64 to linux-arm64 changes env-osarch, produces the correct ordinary variable and PATH-selected runtime, and does not rewrite the precomputed platform snapshots.

One directly relevant focused test still fails: pkg/facility-default-global.test returns pkg_integrate status 2 while preparing its generic provider fixture. Since the dedicated osarch-specific fixture integrates equivalent facility-env PATH metadata successfully, the failure is narrowed to the generic fixture/definition path rather than the global environment materializer itself. Extra non-contract diagnostic output is temporarily present in that test to distinguish package-identity versus range-envelope causes on the next focused run.

The latest focused bridge is running against the pinned current product revision.

## Next action

1. Read the next focused facility-default-global diagnostic and repair the generic fixture or product path according to the observed cause.
2. Re-run the focused provider/facility validation on both Ubuntu and macOS.
3. Remove temporary diagnostic-only test output when no longer needed, perform the final consistency gate, then decide explicitly whether pkg_provider_global_environment_apply has any remaining useful role. Do not remove it without that decision.

## Blockers / open questions

- Generic facility-default test fixture still fails integration with status 2; root cause is being diagnosed.
- Explicit end-of-task decision on retention/removal of pkg_provider_global_environment_apply remains pending by user instruction.
