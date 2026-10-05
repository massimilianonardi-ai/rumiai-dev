# Global provider environment materialization

Status: Complete
Updated: 2026-10-05

## Goal

Move system facility-default environment resolution out of the high-frequency m execution path and into package/default mutation time, while keeping bootstrap responsible only for sourcing already-materialized environment state.

## Current repository revisions

- rumiai-dev: c955783c85d73f1547271b39442c2e8fc5bfbdba (pre-completion HEAD)
- rumiai-os: f39d986e5d4269f742d138eb3ebf9092d1e3345c
- rumiai-tests: 4a7a6af5a42a68070873e736994897142dcc051a

Revision-specific hosted validation for the global-environment implementation exercised `rumiai-os@2693e5695e7b75c45b1cda0a490435480960534d`. Current `rumiai-os/main` is six forward commits ahead; the comparison changes only pkg dependency/install diagnostics and their manuals, not m, osarch, pkg-provider, facility-env or the global-environment manuals.

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
- `pkg_provider_environment_apply` and `pkg_provider_global_environment_apply` are retained deliberately as explicit live-application APIs for the current process. The bootstrap does not use them; it consumes only materialized snapshots.

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

The materialized global provider environment design is implemented and validated for the task scope.

The generic fixture defect was test-only: a malformed temporary package suffix produced an invalid package identity before the materializer was reached. `rumiai-tests@4a7a6af5a42a68070873e736994897142dcc051a` corrects the fixture to use the process PID.

Hosted validation with that test revision records PASS on both Ubuntu and macOS for the directly relevant surfaces:

- `rumiai-os/osarch/update.test`
- `rumiai-os/pkg/provider.test`
- `rumiai-os/pkg/facility-contract.test`
- `rumiai-os/pkg/facility-default-global.test`
- `rumiai-os/pkg/facility-default-osarch-env.test`

The generic global test confirms unversioned package-default following, command-set reconciliation, pinned selectors, collision rollback, binding independence, class-presence reconciliation, global facility environment, provider PATH publication and unchanged already-running processes. The osarch-specific test confirms selector switching, use of precomputed environment and provider PATH.

The broader package-provider-facility workflow remains red because of separate dependency/install/external-test failures outside this task. Those failures do not occur in the global-environment acceptance tests and are not attributed as validation of this work.

The final API decision is to retain `pkg_provider_global_environment_apply` (and the concrete-provider apply API) as explicit live current-process facilities. The canonical PACKAGE-MODEL now states that the bootstrap does not call them.

## Next action

None.

## Blockers / open questions

None.
