# Service model

Status: Active
Updated: 2026-09-19 23:03 +02:00

## Goal

Define the service model that connects the portable `srv` lifecycle, package-provided facilities and explicit host supervision integration without introducing a duplicate package/service registry or a second dependency graph.

The task must converge on the semantic model and public contract before implementation work is started.

## Current repository revisions

Revisions relied upon for this checkpoint:

```text
rumiai-dev@9b1b5b44fea8ec57ce3768e2b3cf0c9c44a73a75
rumiai-os@7f6ced69baef8484d96e7db1572686d67c6bdaaf
rumiai-tests@1c3d2d7c0d9731118cf6d946de02662e001cf374
pkg-catalog@5372c160441b0346b976db7f7a022196784c9425
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

11. The current runtime still uses PATH-resolved `<service>-start` as a legacy implementation mechanism, but it is no longer the semantic definition of a provider-backed service. The canonical provider model uses `facility-service/<facility>/start` and exact-concrete package-command launch; package-integrated targets continue to use the normal package launcher for package HOME/environment/dependency preparation.

12. Host-managed system services must preserve the canonical administrative/security boundary: system-wide integration is an explicit admin operation, and any dedicated OS service account must not gain ownership/write access over executable product roots merely because it runs the service. Detailed host adapter mechanics remain to be designed and validated separately.
13. The provider-independent facility contract belongs to `pkg`. `srv` must not own a parallel provider contract/registry; it interprets the service/lifecycle portion of the selected facility provider when the generalized package facility model defines such an aspect.

## Active implementation scope

The inert service typed-part checkpoint is implemented.

Current product changes:

```text
lib/sys/sh/pkg/facility/pkg-facility-service.lib.sh
    validates exact service contract schema
    validates facility-service/<facility>/start
    validates the mapped ordinary provider package command and executable target

pkg-facility.lib.sh
    trusts service as a third typed part beside cmd/env
    rejects undeclared/unknown facility-service surfaces

manuals
    document the internal service handler and updated generic conformance surface
```

Current permanent-test coverage extends `tests/rumiai-os/pkg/facility-contract.test` with:

- valid service contract/provider realization;
- service start command deliberately absent from the facility `cmd` contract;
- invalid process semantic token;
- missing start realization;
- forbidden provider-specific stop realization;
- mapping to a missing provider package command;
- service realization without a service contract;
- proof that conformance does not execute the service start target.

No package installation/materialization, facility-default/binding behavior or `srv` runtime behavior changed in this checkpoint.

### Bridge exposed by the implementation

The next bridge is now concrete rather than hypothetical:

1. current `pkg-integration.lib.sh` rejects `facility-service` as an unknown package-definition entry and does not materialize it into an installed concrete;
2. therefore no normally installed provider can yet expose the canonical service realization to runtime;
3. runtime must not solve this by re-reading `pkg-catalog`, because runtime provider use must rely on installed validated realization data;
4. `pkg install` already owns the exact immutable catalog snapshot and selected package range, so a later composition step can invoke `pkg_facility_provider_validate <catalog-root> <selected-range> <extracted-root>` before integration without deriving catalog paths inside `pkg_integrate`;
5. integration can then materialize validated `facility-service` data alongside the other provider realization surfaces;
6. only after that exists should `srv` resolve a configured facility provider and launch the exact concrete package command.

This is the preferred direction because it preserves the inert facility/provider core and avoids both hidden catalog context inside `pkg_integrate` and runtime catalog refetch.

## Completed

- Fresh preflight completed against current remote HEADs of `rumiai-dev`, `rumiai-os`, `rumiai-tests` and `pkg-catalog`.
- Current documentation router, rules, consistency gate, service lifecycle specification, package model and handoff lifecycle were read.
- Current `srv` implementation and permanent lifecycle test were inspected.
- Current package facility implementation and permanent facility test were inspected.
- No existing `handoff/service-model.md` or deferred `service-model` TODO existed before activation.
- Concurrent changes to `CONSISTENCY-GATE.md` and `handoff/README.md` were detected during the write, re-read and reconciled before this checkpoint.
- The initial service-model choices agreed in the design discussion are captured above as resumable task-local state.

## Current state

The service/facility semantic model is canonical and its inert conformance layer is implemented.

Exact checkpoint:

```text
rumiai-os@7f6ced69baef8484d96e7db1572686d67c6bdaaf
rumiai-tests@1c3d2d7c0d9731118cf6d946de02662e001cf374
pkg-catalog@5372c160441b0346b976db7f7a022196784c9425
```

Current runtime still uses the legacy PATH-resolved `<service>-start` mechanism. The product therefore has an intentional, explicit pending realignment: service contract/provider conformance exists, but package installation does not yet accept/materialize `facility-service` and `srv` cannot yet consume it.

Formal exact-revision test execution is not available in the current ChatGPT auxiliary environment because github.com DNS resolution fails, and no CI workflow has automatically run these commits. No formal PASS is claimed.

## Next action

Design and implement the composition bridge as a separate checkpoint:

1. invoke facility/provider conformance from package-install orchestration while the exact catalog snapshot, selected range and extracted root are all available;
2. permit and materialize already-validated `facility-service` metadata in package integration;
3. expose the smallest existing-provider API needed by `srv` to query the system facility default without introducing consumer-binding semantics;
4. resolve that selector to one exact installed concrete for the active package class;
5. read the installed service realization and launch exactly `$m_PKG_DIR/<concrete>/cmd/<start-command>`;
6. persist the concrete provider identity in `srv` runtime state before removing the legacy PATH inference.

Do not make runtime read the catalog and do not create a service-specific provider registry.

## Blockers / open questions

No blocker remains in the service typed-part conformance layer.

The remaining blocker to a real provider-backed service is composition: current package integration rejects and does not materialize `facility-service`.

The preferred implementation direction is now narrowed:

- validate from `pkg install`, which already has the exact catalog snapshot;
- keep `pkg_integrate` free from implicit catalog-path derivation;
- materialize only validated service realization data;
- let global `srv` use system facility-default intent, not a consumer binding;
- persist selected concrete provider identity in runtime state;
- stop an existing instance from recorded state without provider re-resolution.

Still deferred:

- exact public/internal name for a library-level facility-default query used by `srv`;
- migration timing for removal of legacy PATH-based `<service>-start`;
- host user/system supervision implementation and host account/environment mechanics.

Endpoint/readiness/health remain outside the baseline service part.
