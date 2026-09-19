# Service model

Status: Active
Updated: 2026-09-19 22:29 +02:00

## Goal

Define the service model that connects the portable `srv` lifecycle, package-provided facilities and explicit host supervision integration without introducing a duplicate package/service registry or a second dependency graph.

The task must converge on the semantic model and public contract before implementation work is started.

## Current repository revisions

Revisions relied upon for this checkpoint:

```text
rumiai-dev@c70e36cab760ded60b99e9057ef3eba01b9b7033
rumiai-os@2d953fc222b2ec01e5d124d1aaf64d4359a47af2
rumiai-tests@4af4183219ff42f07c9e6f116afc01ee0d3d2113
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

## Working design

The user has explicitly resumed the service-model design and asked for a proposal that introduces services/daemons into the existing facility/provider model.

The proposal below is **working design only**. It is not yet promoted to `PACKAGE-MODEL.md` or `SERVICE-LIFECYCLE.md`.

### 1. Service as a facility typed part

Introduce one additional trusted facility part:

```text
service
```

alongside the current:

```text
cmd
env
```

A facility that contains a `service` part is service-operable through `srv`. A facility without that part is not a service merely because one of its providers happens to expose a long-running command.

This preserves the current architecture:

```text
pkg
    facility identity
    provider declaration / conformance
    provider selection

srv
    process lifecycle
    runtime state
    logging / locking / termination
```

There is no service registry separate from the facility/provider index.

### 2. Service identity

For the baseline model, the service identity should be exactly the facility identity.

Conceptually:

```text
srv start geoserver
          │
          └── facility: geoserver
```

A package that exposes multiple independent services does so by providing multiple service-capable facilities. This preserves package → facility cardinality at 0..N without introducing a second package → service namespace.

A later requirement for multiple independently managed service roles inside one facility would require explicit design; the baseline does not introduce such a sub-identity pre-emptively.

Provider-backed service names therefore use facility-name semantics. The current wider `srv` service-name grammar is implementation compatibility, not a reason to create a distinct service identity grammar in the provider model.

### 3. Provider-independent service contract

The first service-part schema should describe the process/lifecycle guarantees required by portable `srv`, rather than merely listing command names.

Candidate exact contract:

```text
facility/<facility>/<compatibility>/service/
    start
    process
    stop
```

with scalar contents:

```text
start    = package-command
process  = foreground
stop     = sigterm
```

For example:

```text
facility/geoserver/1/service/start
    package-command

facility/geoserver/1/service/process
    foreground

facility/geoserver/1/service/stop
    sigterm
```

These tokens are type-owned schema values, not arbitrary metadata.

Semantics:

- `start = package-command`: each provider supplies one ordinary package command as its concrete start realization;
- `process = foreground`: the provider start command must remain attached to the managed service process; it must not self-daemonize and exit while an unmanaged descendant continues;
- `stop = sigterm`: normal portable stop is supplied generically by `srv` through SIGTERM and does not require a provider-specific stop command.

The exact service contract therefore guarantees the process model required for provider substitutability under the portable `srv` lifecycle.

The generic facility layer knows only that `service` is a trusted part type. The future service-part handler owns these schema tokens and their conformance rules.

### 4. Provider service realization

Use a type-specific provider-realization surface:

```text
facility-service/<facility>/start
```

The `start` file contains exactly one package command name.

Example:

```text
pkg/geoserver/.../
    facility
        geoserver 1

    facility-service/
        geoserver/
            start
                geoserver-start

    cmd/
        geoserver-start

    link/
        geoserver-start
```

The start command is an **implementation mapping**, not automatically a consumer-visible `cmd` facility guarantee. Therefore it does not need to appear in:

```text
facility/geoserver/1/cmd/
```

unless consumers independently need that command as part of the provider-independent facility interface.

This distinction prevents an internal lifecycle entrypoint from leaking into the public capability contract merely because `srv` needs it.

### 5. Service conformance

A future trusted `pkg-facility-service.lib.sh` handler should mechanically validate at least:

- the service contract contains exactly the supported required descriptors for that contract schema;
- descriptor values are recognized trusted tokens;
- the provider supplies `facility-service/<facility>/start` when `start = package-command`;
- the start descriptor contains exactly one valid package command name;
- that package command is actually defined by the same provider package range through the normal `cmd/<name>` + `link/<name>` package-command mechanism;
- no provider-specific stop realization is accepted for the baseline `stop = sigterm` contract;
- no undeclared service realization exists for a facility without the service part.

Mechanical validation cannot prove that the command really remains foreground or behaves correctly on SIGTERM. Those are behavioral provider-conformance claims and require real provider/service tests, just as generic facility validation cannot prove full Java semantic compliance.

The service handler remains inert like the current cmd/env handlers: validation does not start a process and does not create a default or binding.

### 6. Exact concrete start target

Portable service execution must not resolve the provider start command through ordinary PATH.

After a provider concrete has been selected, the service realization identifies a package command name inside **that exact installed concrete**.

Conceptually:

```text
selected provider
    geoserver@2.28.0

service realization
    start = geoserver-start

exact launch command
    $m_PKG_DIR/geoserver@2.28.0/cmd/geoserver-start
```

Invoking that exact package command preserves the normal package launcher semantics:

- concrete useful root;
- package HOME/configuration;
- package environment;
- facility dependencies;
- user package environment.

At the same time it prevents a later package-default change or another provider from changing what process is started between selection and launch.

This is a material improvement over resolving the historical `<service>-start` name through PATH.

### 7. Role of the existing <service>-start convention

The historical convention:

```text
<service>-start
```

should cease to be the semantic test for “is this a service?”.

Under the proposed model:

```text
facility service part
    defines service-operability

provider facility-service/.../start
    identifies the concrete package start command
```

A provider may still choose the familiar command name `<facility>-start`, so existing package layouts can migrate with little mechanical change. But the name itself no longer creates service semantics.

During implementation, the current PATH-based convention may need a compatibility transition so existing non-provider tests/uses are not broken abruptly. The final provider-backed model should not silently fall back to command-name inference when no service contract exists.

### 8. What srv owns

The current portable `srv` mechanics remain generic and should be retained:

```text
serialization / lock
stale-state handling
background launch via nohup
combined managed log
PID publication
caller ownership metadata
idempotent start
idempotent stop
SIGTERM
finite clean-termination wait
-f caller-ownership override
```

The provider supplies no daemon-management script beyond its start command.

In particular:

```text
provider
    does not self-daemonize
    does not publish its own PID contract to RumiAI
    does not need a stop command

srv
    daemonizes/backgrounds the foreground provider process
    owns PID/log/runtime lifecycle
    stops the managed PID generically
```

This keeps “service/daemon support” in RumiAI without turning each provider into its own daemon manager.

### 9. Running-instance identity

When `srv start` eventually consumes a selected facility provider, runtime state should persist the concrete provider identity in addition to the already-recorded PID/owner/command.

Conceptually:

```text
service identity
    geoserver

provider concrete
    geoserver@2.28.0

command
    .../pkg/geoserver@2.28.0/cmd/geoserver-start

pid
    12345
```

The configured selector/default is **not** runtime instance identity.

Therefore changing a facility default after start does not mutate the running service. `srv stop geoserver` stops the recorded instance and does not re-resolve another provider. A future new start/restart may resolve current selection again.

This preserves the already-fixed service handoff rule.

### 10. Selection remains separate

This proposal deliberately does not redesign facility defaults or consumer bindings.

Facility/provider definitions and the service realization remain inert. A later composition step decides how global `srv start <facility>` obtains its selected provider. The current service handoff direction is that global `srv` operations use facility-default selection, but that selection policy is separate from the service typed-part contract itself.

The service handler therefore must not create or mutate:

```text
facility defaults
consumer bindings
package defaults
```

### 11. Endpoint, readiness and health are not service lifecycle

Do not put network endpoint metadata into the first `service` part.

Reasons:

- a service may expose no network endpoint;
- a facility may expose network capability independently of service lifecycle;
- actual bound address/port is runtime state, not a static facility guarantee;
- readiness/health semantics are application-specific and the current portable `srv` contract explicitly does not infer them.

If a provider-independent endpoint contract becomes necessary, model it later as its own typed part rather than making `service` a mixed property bag.

Likewise, application readiness/health should get its own explicit semantics only when a real requirement exists.

### 12. Host supervision

Future:

```text
srv host user ...
srv host system ...
```

must consume the same service-capable facility/provider realization. systemd/launchd adapters must not introduce a second service/provider registry.

The exact host installation, account, environment and activation mechanics remain deferred. Nothing in the baseline service part requires host supervision to exist.

### 13. GeoServer proof shape

The first proof case can be conceptually:

```text
facility/geoserver/1/
    service/
        start       -> "package-command"
        process     -> "foreground"
        stop        -> "sigterm"

pkg/geoserver/.../
    facility
        geoserver 1

    facility-service/
        geoserver/
            start   -> "geoserver-start"

    cmd/
        geoserver-start

    link/
        geoserver-start -> <provider-specific executable/start path>
```

Then a second independent provider of `geoserver 1` could map `start` to a completely different package command while exposing the same service semantics.

That is the actual provider-substitution proof.

### 14. Proposed implementation responsibility map

If this design is accepted:

```text
lib/sys/sh/pkg/facility/
    pkg-facility.lib.sh
        generic trusted-part dispatch / whole-provider conformance

    pkg-facility-service.lib.sh
        service contract schema
        provider service-realization validation
        no runtime execution

bin/sys/srv
    provider-backed service launch/stop mechanics
    runtime instance state

pkg-provider.lib.sh
    provider selection only
```

There should be no `srv` provider index and no `pkg` process manager.

### 15. Alternatives rejected by this proposal

Do not use these as the baseline:

```text
infer service from <service>-start
    -> no provider-independent service contract

put provider start command in facility cmd merely because srv needs it
    -> leaks implementation plumbing into consumer guarantees

provider-specific stop commands by default
    -> duplicates lifecycle policy already owned by srv

separate service registry
    -> duplicates facility/provider identity and selection

resolve start through PATH after provider selection
    -> selected provider and launched concrete can diverge

mix endpoint/readiness/health into service part
    -> conflates orthogonal contracts
```

The smallest coherent baseline is therefore:

```text
facility identity == service identity
service typed part == portable process/lifecycle contract
provider realization == exact package start-command mapping
srv == generic process owner
```


## Completed

- Fresh preflight completed against current remote HEADs of `rumiai-dev`, `rumiai-os`, `rumiai-tests` and `pkg-catalog`.
- Current documentation router, rules, consistency gate, service lifecycle specification, package model and handoff lifecycle were read.
- Current `srv` implementation and permanent lifecycle test were inspected.
- Current package facility implementation and permanent facility test were inspected.
- No existing `handoff/service-model.md` or deferred `service-model` TODO existed before activation.
- Concurrent changes to `CONSISTENCY-GATE.md` and `handoff/README.md` were detected during the write, re-read and reconciled before this checkpoint.
- The initial service-model choices agreed in the design discussion are captured above as resumable task-local state.

## Current state

The generic facility/provider core is implemented for `cmd` and `env`. The service task is active again at design level.

Current `srv` still discovers a launch target by resolving `<service>-start` through PATH and stores PID, caller owner and canonical command. It does not yet resolve a facility provider or persist provider-concrete identity.

The current design proposal introduces a trusted `service` facility part, makes baseline service identity equal facility identity, maps each provider to one exact package start command, leaves normal stop generic in `srv`, and keeps endpoint/readiness/health out of the first service part.

No service runtime, package runtime, catalog or permanent test has been modified for this proposal.

## Next action

Review the proposed `service` typed-part model with the user.

If accepted, promote the stable facility/service semantics into `PACKAGE-MODEL.md` and `SERVICE-LIFECYCLE.md` before implementing `pkg-facility-service.lib.sh`, any GeoServer catalog proof, runtime provider resolution in `srv`, or migration away from PATH-based `<service>-start` discovery.

## Blockers / open questions

Primary decisions for user review:

- accept `service` as the typed-part name rather than a generic `lifecycle` part;
- accept baseline service identity == facility identity;
- accept the first contract schema `start=package-command`, `process=foreground`, `stop=sigterm`;
- accept `facility-service/<facility>/start` as the provider realization pointing to an ordinary package command;
- accept generic `srv` SIGTERM stop with no provider-specific stop mapping in the baseline;
- accept exact-concrete command launch instead of PATH lookup;
- keep endpoint/readiness/health outside the first service part.

Still deferred after those choices:

- exact facility-default/provider-selection composition for global `srv`;
- compatibility transition/removal strategy for legacy PATH-based `<service>-start`;
- host user/system supervision implementation;
- host installation/account/environment mechanics;
- endpoint/readiness/health typed parts if later required.
