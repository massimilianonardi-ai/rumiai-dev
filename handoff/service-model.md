# Service model

Status: Active
Updated: 2026-09-19 22:44 +02:00

## Goal

Define the service model that connects the portable `srv` lifecycle, package-provided facilities and explicit host supervision integration without introducing a duplicate package/service registry or a second dependency graph.

The task must converge on the semantic model and public contract before implementation work is started.

## Current repository revisions

Revisions relied upon for this checkpoint:

```text
rumiai-dev@3018ee79047c2aa9f27c47ff37e7c3a8ce7affd0
rumiai-os@d39ad30b4788cb642ff242b59b8144914305376e
rumiai-tests@3536bda91a51fa87bd5bb8fb5393a55eb6220149
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

11. The current `<service>-start` foreground target remains the implemented portable launch convention during this design task. Its future role may become an implementation mapping or compatibility surface once lifecycle is represented explicitly in the facility contract. Package-integrated targets must continue to use the normal package launcher for package HOME/environment/dependency preparation.

12. Host-managed system services must preserve the canonical administrative/security boundary: system-wide integration is an explicit admin operation, and any dedicated OS service account must not gain ownership/write access over executable product roots merely because it runs the service. Detailed host adapter mechanics remain to be designed and validated separately.
13. The provider-independent facility contract belongs to `pkg`. `srv` must not own a parallel provider contract/registry; it interprets the service/lifecycle portion of the selected facility provider when the generalized package facility model defines such an aspect.

## Active implementation scope

The user accepted the proposed baseline service/facility model and authorized proceeding.

The durable semantic portion has been promoted into `PACKAGE-MODEL.md` and `SERVICE-LIFECYCLE.md`:

```text
service typed part
    marks a facility as srv-manageable

service identity
    equals facility identity in the baseline

contract
    start   = package-command
    process = foreground
    stop    = sigterm

provider realization
    facility-service/<facility>/start
        -> one ordinary command of that provider package

ownership
    pkg = contract/provider conformance + provider selection
    srv = process lifecycle/runtime state
```

The service start command is implementation mapping, not automatically a consumer-visible `cmd` facility guarantee. Endpoint/readiness/health remain outside the service part.

The current implementation work unit is deliberately narrower than the eventual runtime bridge:

- add the trusted `service` facility-part handler;
- integrate it into generic facility/provider conformance;
- add permanent tests for service contract/provider realization semantics;
- add required library/manual consistency;
- do **not** yet change package installation/materialization, facility-default semantics or `srv` runtime selection until the inert service part itself is validated.

This preserves the previously accepted separation between declarative facility/provider semantics and later selection/application composition.

## Completed

- Fresh preflight completed against current remote HEADs of `rumiai-dev`, `rumiai-os`, `rumiai-tests` and `pkg-catalog`.
- Current documentation router, rules, consistency gate, service lifecycle specification, package model and handoff lifecycle were read.
- Current `srv` implementation and permanent lifecycle test were inspected.
- Current package facility implementation and permanent facility test were inspected.
- No existing `handoff/service-model.md` or deferred `service-model` TODO existed before activation.
- Concurrent changes to `CONSISTENCY-GATE.md` and `handoff/README.md` were detected during the write, re-read and reconciled before this checkpoint.
- The initial service-model choices agreed in the design discussion are captured above as resumable task-local state.

## Current state

The service/facility semantic model is now canonical. Runtime still uses the historical PATH-resolved `<service>-start` mechanism and therefore does not yet satisfy the provider-backed exact-concrete service contract.

The next implementation checkpoint is the inert `service` typed-part conformance layer. No installation/default/binding/bootstrap/runtime composition change is included in that checkpoint.

## Next action

Implement `pkg-facility-service.lib.sh`, wire trusted service-part validation into `pkg-facility.lib.sh`, add its manual and permanent conformance cases, then run the consistency gate.

After that checkpoint, inspect the remaining runtime bridge concretely: materialization of `facility-service`, exact facility-default provider resolution for global `srv start`, exact-concrete package-command launch and provider identity persistence. Do not silently fold those composition decisions into the conformance implementation.

## Blockers / open questions

No semantic blocker remains for the inert service typed-part conformance implementation.

Remaining later composition questions:

- exact package-install/materialization hookup for `facility-service`;
- exact library surface used by global `srv start <facility>` to query the facility default without introducing consumer-binding semantics;
- migration/removal of legacy PATH-based `<service>-start` discovery;
- exact provider-concrete runtime metadata field/layout inside private `srv` state;
- host user/system supervision implementation and host installation/account/environment mechanics.

Endpoint/readiness/health remain outside the baseline service part unless a later concrete requirement activates them.
