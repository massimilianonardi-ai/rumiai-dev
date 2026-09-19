# Service model

Status: Active
Updated: 2026-09-19 20:38 +02:00

## Goal

Define the service model that connects the portable `srv` lifecycle, package-provided facilities and explicit host supervision integration without introducing a duplicate package/service registry or a second dependency graph.

The task must converge on the semantic model and public contract before implementation work is started.

## Current repository revisions

Revisions relied upon for this checkpoint:

```text
rumiai-dev@163403bb609d08f682b5d2a4db7dca60f6ae75b6  facility compatibility semantics reconciled
rumiai-os@50b760bd3cfe08922068ceb7d973d7edee12251c
rumiai-tests@899ac4df79429db1d28602ae08ded1f9f8a72f64
pkg-catalog@4c67eb5c7cf27fbc48c222fd8196f0127409be00
```

The `rumiai-dev` SHA above is the canonical-source baseline re-read before the cross-task reconciliation; handoff synchronization commits advance it forward without replacing fresh-HEAD retrieval on resume.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
handoff/README.md
specifications/README.md
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/PACKAGE-MODEL.md
```

Current implementation/test evidence inspected for this checkpoint:

```text
rumiai-os/bin/sys/srv
rumiai-os/lib/sys/sh/pkg/facility/pkg-facility.lib.sh
rumiai-os/lib/sys/sh/pkg/pkg-provider.lib.sh
rumiai-tests/tests/rumiai-os/srv/lifecycle.test
rumiai-tests/tests/rumiai-os/pkg/provider.test
```

## Fixed task-local choices

The following choices are fixed for this task unless the user explicitly corrects them or a current canonical contract makes one impossible:

1. The portable, host-independent lifecycle remains:

   ```text
   srv start <service>
   srv stop [-f] <service>
   ```

2. Explicit host integration uses the public shape:

   ```text
   srv host user <action> <service>
   srv host system <action> <service>
   ```

   `user` and `system` identify the host-supervision integration scope. They do not redefine the existing `m` state-scope semantics.

3. Host runtime/policy actions such as:

   ```text
   start
   stop
   restart
   status
   activate
   deactivate
   ```

   are normalized `m` operations translated by host adapters onto the corresponding systemd/launchd semantics. They are not required to be literal textual aliases because the host interfaces are not perfectly isomorphic.

4. `srv host system install <service>` and `srv host system uninstall <service>` are higher-level `m` integration operations, not simple supervisor dispatch. They may need to manage host-specific unit/plist generation, registration, paths, account/ownership boundaries and other installation/removal mechanics under the explicit administrative boundary required by the canonical service contract.

5. Service integration remains opt-in and separate from the portable lifecycle. The portable `srv start/stop` contract must remain usable without systemd/launchd and must not be replaced by host supervision.

6. A service is conceptually related to a package facility, but `service` and `facility` are not synonyms. A facility is an abstract function/interface supplied by a package; a service adds an operational lifecycle contract. Not every facility is a service.

7. A package may expose zero, one or multiple services. Do not impose a package-to-service 1:1 restriction merely for convenience. The existing facility implementation already supports one package declaring multiple facilities, so the service model should preserve the natural 0..N cardinality unless a concrete contradiction is found.

8. Reuse the package facility declaration/provider-index responsibility for service registration/identity as far as its contract permits. Do not introduce a second service inventory/registry or a parallel provider lifecycle unless a concrete requirement proves the existing responsibility insufficient.

9. Facility/dependency semantics must not be reinterpreted as a service dependency graph. `srv` owns service lifecycle; `pkg` continues to own package facility/provider/dependency semantics.

10. Service-operability must be expressed through the generalized `pkg` facility contract rather than inferred semantically only from the presence of a conventional command. Do not introduce a separate service declaration/registry unless the generalized facility contract proves insufficient.

11. The current `<service>-start` foreground target remains the implemented portable launch convention during this design task. Its future role may become an implementation mapping or compatibility surface once lifecycle is represented explicitly in the facility contract. Package-integrated targets must continue to use the normal package launcher for package HOME/environment/dependency preparation.

12. Host-managed system services must preserve the canonical administrative/security boundary: system-wide integration is an explicit admin operation, and any dedicated OS service account must not gain ownership/write access over executable product roots merely because it runs the service. Detailed host adapter mechanics remain to be designed and validated separately.
13. The provider-independent facility contract belongs to `pkg`. `srv` must not own a parallel provider contract/registry; it interprets the service/lifecycle portion of the selected facility provider when the generalized package facility model defines such an aspect.

## Working design

The shared semantic base is no longer open: `PACKAGE-MODEL.md` now defines a facility as a provider-independent substitutable capability contract owned by `pkg`, distinguishes provider realization from facility definition and mutable selection conf, and establishes typed declarative extensibility with delegation to existing subsystem owners.

The package task still owns the exact contract meta-model and storage representation. For service work, the implications are now:

```text
pkg
    selects provider and validates provider realization
        ↓
facility realization
    contains the service/lifecycle contract part once defined
        ↓
srv
    interprets lifecycle semantics and owns process mechanics
        ↓
runtime state
    records the concrete running provider instance and actual endpoint state
```

The previous hypothesis that `<facility>-start` itself defines service-operability is superseded as the semantic direction. Command presence may remain useful as an implementation mapping, but the facility contract must state lifecycle semantics explicitly enough that two providers can be validated as interchangeable service providers.

The service proof case must preserve these distinctions:

- static facility contract: provider-independent service/lifecycle semantics;
- provider realization: concrete start target and any provider-specific lifecycle mapping;
- provider selection: facility default for global `srv` operations, unless a later explicit context is introduced;
- runtime instance: concrete provider selected at start, PID/logging/lock state and actual runtime endpoint;
- network capability/default metadata: static provider/contract information, never a claim that a process is currently listening.

Changing the facility default after a service starts must not mutate or retarget the running instance. A later restart may resolve the new default.

One design question remains especially important: whether a lifecycle part defines semantic operations such as `start`/`stop` while allowing an operation to be satisfied generically by `srv` rather than requiring a provider command. That would naturally cover a provider with a concrete start target but no provider-specific stop command, with `srv` using its normal SIGTERM contract. Exact representation is still open.

The package task has now fixed supporting decisions that the service model may rely on:

```text
pkg-catalog/pkg/<package>/...
pkg-catalog/facility/<facility>/...
```

Compatibility levels of a facility are independent exact contracts; `pkg` does not infer monotonic or backward-compatible evolution between them. A service provider therefore declares one exact facility level, while a service consumer expresses any accepted exact/range compatibility through normal package dependency constraints.

The runtime package libraries now have explicit `facility/` and `repository/` responsibility groups. The remaining package Phase-1 work is the concrete typed-part implementation/representation. In particular, a lifecycle part still needs to prove that contract schema, provider realization, mechanical validation and `srv` execution ownership fit one generic type boundary without provider-specific branching. Service implementation must continue to wait for that remaining boundary to settle.

## Completed

- Fresh preflight completed against current remote HEADs of `rumiai-dev`, `rumiai-os`, `rumiai-tests` and `pkg-catalog`.
- Current documentation router, rules, consistency gate, service lifecycle specification, package model and handoff lifecycle were read.
- Current `srv` implementation and permanent lifecycle test were inspected.
- Current package facility implementation and permanent facility test were inspected.
- No existing `handoff/service-model.md` or deferred `service-model` TODO existed before activation.
- Concurrent changes to `CONSISTENCY-GATE.md` and `handoff/README.md` were detected during the write, re-read and reconciled before this checkpoint.
- The initial service-model choices agreed in the design discussion are captured above as resumable task-local state.

## Current state

The canonical package model now provides the provider-independent facility abstraction that the service task was waiting for.

The current runtime still implements portable service launch through `<service>-start`, with `srv` owning locking, stale-state cleanup, background launch/logging, runtime metadata and SIGTERM-based stop. Package provider/default/binding resolution is now a separate generic package responsibility and no service-specific provider resolver is needed.

The unresolved service boundary is no longer “how do commands/environment identify a service”; it is the exact lifecycle/service contract part and, separately, any endpoint/network contract part required by the first service implementation.

No service runtime/test/catalog implementation changed in this checkpoint.

## Next action

Wait for the package facility-contract Phase 1/2 work to settle the generic typed-part/meta-model and catalog representation, using GeoServer as one of its mandatory proof cases.

Then this task should:

1. define the minimal lifecycle part against that generic meta-model;
2. decide which lifecycle operations require provider realization and which may be satisfied generically by `srv`;
3. define the facility-default selection path for global `srv` operations;
4. define what concrete provider identity/runtime metadata `srv` persists for a running instance;
5. decide whether endpoint/network metadata is required in the first service contract;
6. realign `SERVICE-LIFECYCLE.md`, runtime, manuals and permanent tests only after those semantics are settled.

## Blockers / open questions

- Exact lifecycle typed-part schema inside the generalized facility contract.
- Which lifecycle operations are provider-specific versus generically supplied by `srv`.
- Final role of the existing `<service>-start` convention after explicit lifecycle metadata exists.
- Whether the first service contract also needs endpoint/network capability metadata.
- Whether service identity is exactly facility identity and therefore uses the facility-name grammar.
- Exact normalized host action set and mapping across systemd/launchd.
- Whether host `user` scope needs install/uninstall operations.
- Host adapter metadata required for unit/plist generation while preserving package launch semantics and security boundaries.
