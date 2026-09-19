# Service model

Status: Active
Updated: 2026-09-18 20:50 +02:00

## Goal

Define the service model that connects the portable `srv` lifecycle, package-provided facilities and explicit host supervision integration without introducing a duplicate package/service registry or a second dependency graph.

The task must converge on the semantic model and public contract before implementation work is started.

## Current repository revisions

Revisions relied upon for this checkpoint:

```text
rumiai-dev@a8b08ffa24147bd8f3dad49874679dd9d9e646fb  synchronized package-facility baseline
rumiai-os@34671a5a1e9917fa39e3bbbd4b155590202c9b22
rumiai-tests@88b4e48f170da883889c2f418a34e8ad24066e9d
pkg-catalog@bd06488d3c67160e820c04d13067f852c8861c32
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
rumiai-os/lib/sys/sh/pkg-facility.lib.sh
rumiai-tests/tests/rumiai-os/srv/lifecycle.test
rumiai-tests/tests/rumiai-os/pkg/facility.test
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

10. Before introducing any new package-local `service` declaration or registry, evaluate whether the existing combination:

    ```text
    facility declaration
    +
    conventional <facility>-start command
    ```

    can identify that a facility is also operable as a service while preserving unambiguous package/provider ownership.

11. The current `<service>-start` foreground target convention remains the portable launch convention during this design task. Package-integrated targets must continue to use the normal package launcher for package HOME/environment/dependency preparation.

12. Host-managed system services must preserve the canonical administrative/security boundary: system-wide integration is an explicit admin operation, and any dedicated OS service account must not gain ownership/write access over executable product roots merely because it runs the service. Detailed host adapter mechanics remain to be designed and validated separately.
13. The provider-independent facility contract belongs to `pkg`. `srv` must not own a parallel provider contract/registry; it interprets the service/lifecycle portion of the selected facility provider when the generalized package facility model defines such an aspect.

## Working design

The package task has now promoted provider-selection semantics and has identified a broader facility-contract gap that materially narrows the service-model design:

- package provider installation and provider selection are separate;
- effective package dependency selection is explicit consumer/facility binding first, otherwise facility default, otherwise failure;
- there is no implicit fallback to the only installed provider;
- a facility default owns the global runtime projection of that facility;
- selectors may follow a provider package default or pin an exact provider concrete;
- current `facility-cmd` and `facility-env` mechanics are concrete facility projections, but they are no longer assumed to be the complete general facility abstraction;
- the generalized provider-independent facility contract is owned by `pkg`, with specialized subsystems interpreting only the aspects they own.

For the service model, this weakens the earlier idea that the presence of a conventional `<facility>-start` command should itself define service-operability. That convention may remain an implementation mapping or compatibility mechanism, but it should not be the semantic service declaration if the generalized facility contract can express lifecycle explicitly.

The leading direction is therefore:

```text
pkg selects provider for facility
→ provider facility realization exposes a typed lifecycle/service aspect
→ srv interprets that aspect and owns process lifecycle mechanics
```

A service-style facility may also need runtime endpoint information, but static provider capability/default metadata must remain distinct from the actual endpoint/state of a running instance. Exact lifecycle/endpoint aspect names and schema remain open until the package facility-contract model is settled.

## Completed

- Fresh preflight completed against current remote HEADs of `rumiai-dev`, `rumiai-os`, `rumiai-tests` and `pkg-catalog`.
- Current documentation router, rules, consistency gate, service lifecycle specification, package model and handoff lifecycle were read.
- Current `srv` implementation and permanent lifecycle test were inspected.
- Current package facility implementation and permanent facility test were inspected.
- No existing `handoff/service-model.md` or deferred `service-model` TODO existed before activation.
- Concurrent changes to `CONSISTENCY-GATE.md` and `handoff/README.md` were detected during the write, re-read and reconciled before this checkpoint.
- The initial service-model choices agreed in the design discussion are captured above as resumable task-local state.

## Current state

The canonical service specification still defines only the portable `srv start/stop` lifecycle and explicitly leaves host integration outside that baseline.

The current implementation resolves `srv start <service>` through the conventional `<service>-start` command. The package facility implementation accepts multiple facility declarations/providers, while the current package dependency implementation is still mechanically based on a unique best installed provider.

The canonical `PACKAGE-MODEL.md` has advanced beyond that implementation: it now defines explicit consumer binding, facility default, selector semantics, baseline no-auto-install policy and runtime re-resolution/projection. This removes the need for `service-model` to invent a parallel answer to multi-provider selection.

The shared unresolved boundary is facility-specific runtime projection: the package contract says selected providers may project facility commands/environment, but the exact representation and implementation are still open. Service-operability should be evaluated on top of that mechanism rather than before it.

No product, test or catalog implementation change is part of this checkpoint.

## Next action

First let the package provider/facility task settle the generalized provider-independent facility-contract model owned by `pkg`.

Then define the smallest service/lifecycle aspect on top of that model:

1. keep provider selection in `pkg` and avoid a separate `srv` resolver;
2. define how a selected provider declares the lifecycle operations/data that `srv` needs;
3. preserve the current foreground-process lifecycle mechanics and decide whether `<service>-start` remains only an implementation mapping/compatibility convention;
4. keep runtime endpoint state distinct from static provider capability/default metadata.

After this semantic model is settled, promote the resulting service contract into the applicable canonical specification(s) before implementation.

## Blockers / open questions

- What is the minimal typed lifecycle/service aspect in the generalized package facility contract?
- Does global `srv <operation> <service>` use the facility default/global provider selection directly, as the current package provider-selection model suggests?
- What role, if any, should the current `<facility>-start` convention retain after lifecycle is represented explicitly in the facility contract?
- Should the final service identifier be exactly the facility identifier and therefore adopt the canonical facility-name grammar, or does the current broader `srv` name grammar remain justified?
- What is the exact normalized host action set and the semantic mapping of actions such as `activate/deactivate` across systemd and launchd?
- Does host `user` scope also need explicit install/uninstall operations, or are install/uninstall initially system-only?
- What metadata/configuration, if any, is required to generate systemd units and launchd plists while preserving package launch semantics and the system-account/useful-root ownership boundary?
- Host adapters remain subject to separate host-specific proof/validation before being treated as portable product behavior.
