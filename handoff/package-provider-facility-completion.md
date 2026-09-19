# Package provider/facility completion

Status: Active
Updated: 2026-09-19 14:50 +02:00

## Goal

Finish the RumiAI package provider/facility model as one coherent task across rumiai-dev, rumiai-os, rumiai-tests, pkg-catalog and the relevant PoCs.

This task owns the remaining work around package identity, facilities, multiple providers, facility defaults, consumer bindings, provider selectors, dependency behavior, runtime projections, global facility publication, Temurin/GraalVM, all Java consumers, GitHub-backed package reliability and final semantic/live validation.

Services remain out of scope and stay owned by handoff/service-model.md.

## Current repository revisions

Latest reconciled design baseline:

rumiai-dev      0ab04f0b921477e161d467dc86249a279c56c8cf
rumiai-os       34671a5a1e9917fa39e3bbbd4b155590202c9b22
rumiai-tests    88b4e48f170da883889c2f418a34e8ad24066e9d
pkg-catalog     bd06488d3c67160e820c04d13067f852c8861c32
rumiai-dev-PoCs cb8c5d636ce65e6cb00626ed08947fe25a25988e

The library-subsystem grouping task was explicitly closed by the user and its completed handoff was removed forward-only before this checkpoint. Fresh HEAD retrieval remains mandatory before every later write.

## Applicable canonical sources

Read through the normal mandatory order:

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/README.md
- specifications/rumiai-os/CURRENT-MODEL.md
- specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- specifications/rumiai-os/STATE-MODEL.md
- specifications/rumiai-os/PACKAGE-MODEL.md

Separate active work that may touch shared files but is not absorbed:

- handoff/rumiai-tests-suite-realignment.md
- handoff/service-model.md

The deferred item todo/github-package-repository-rate-limits.md is activated into this task by the same commit that creates this handoff and must no longer exist as a duplicate TODO.

## Fixed task-local choices

The durable facility semantics fixed by the user have now been promoted to `PACKAGE-MODEL.md`; do not duplicate them here as a shadow specification.

Task-local choices that still matter for completion are:

1. Eclipse Temurin remains the concrete package `temurin`; GraalVM remains a distinct package. Both may provide the `java` facility at compatible levels.
2. Java consumers must remain provider-independent. Maven, Keycloak, NetBeans and later consumers must not contain Temurin/GraalVM-specific selection or environment logic.
3. The already implemented facility-default command/environment behavior remains part of the migration baseline, but `facility-cmd` and `facility-env` are no longer treated as the complete general definition of a facility.
4. Before adding more Java- or GraalVM-specific facility surface, the generalized facility-contract model must be designed against at least two deliberately different cases: Java and a service-style facility such as GeoServer.
5. Services remain implemented by the separate `service-model` workstream. This task owns the common `pkg` facility-contract substrate that the service model will consume.
6. The exact storage location and physical schema of provider-independent facility definitions are still open. A same-revision location inside `pkg-catalog` is the leading candidate, but it is not yet a promoted contract.
7. The exact deeper physical grouping under `lib/sys/sh/pkg/` is still open. The previous `pkg/` and `mk/` grouping task is complete; this task may introduce a further package-internal grouping only after responsibilities are settled.

## Working design

The canonical package model now defines the semantic core: a facility is a provider-independent substitutable capability contract owned by `pkg`; provider realization, facility contract and mutable provider-selection configuration are distinct authorities; ordinary command publication does not automatically create a facility; and specialized subsystems may interpret typed facility parts without acquiring a second provider graph.

The remaining design work is the concrete meta-model, catalog ownership and implementation structure.

### 1. Four information planes

The model must keep four kinds of information separate.

#### 1.1 Facility contract

Provider-independent definition of the capability.

It answers questions such as:

- what semantic capability does the facility identity represent;
- what compatibility level a consumer may request;
- which typed contract parts are required at that compatibility level;
- what members/operations within each part are mandatory;
- what a consumer is allowed to rely on regardless of selected provider.

The contract must not contain a provider package path, a selected provider, mutable user/system preference or runtime instance state.

A key unresolved point is the exact relation between the existing facility compatibility value and contract evolution. The design must determine whether one exact compatibility level identifies one exact contract surface, whether levels inherit prior requirements, and how range dependencies such as `java >=17` are validated against provider conformance.

#### 1.2 Provider realization

Concrete, version/osarch-specific package metadata that states how one package realizes a declared facility contract.

Examples already implemented for Java are:

- facility command names mapped to paths inside the provider useful root;
- environment variables mapped to provider root, root-relative path or literal values.

A provider realization must not redefine the meaning of the facility. It maps the provider's artifacts onto the provider-independent contract.

Provider conformance therefore requires two classes of validation:

```text
facility contract is internally valid
+
provider realization satisfies the required contract surface
```

A provider may contain additional package-specific functionality. Consumers of the facility must not silently rely on those extras unless the facility contract explicitly defines optional-member semantics or another facility represents that capability. Whether optional contract members exist at all is still open and must be decided deliberately; the safe baseline is a minimum interoperable required surface.

#### 1.3 Selection/policy configuration

Mutable system configuration chooses among valid installed realizations. Existing examples are:

- facility default;
- consumer binding.

Possible future preference or assisted/automatic-resolution policy belongs here if adopted.

This plane changes **which** realization is selected. It never changes **what** the facility means.

#### 1.4 Runtime/instance state

Derived/transient state records what actually happened after selection and execution.

For service-style facilities this includes facts such as a running concrete provider instance, PID/lifecycle state and the actual bound endpoint. Such state is not facility definition and is not provider-selection configuration.

This distinction is essential for network services: a provider may declare that it can expose an HTTP endpoint and may describe defaults/configuration, but the actual current address/port is runtime state.

### 2. Typed and extensible contract parts

A facility contract may contain one or many typed parts. The number of parts is not what makes something a facility.

Each part must have:

- a provider-independent semantic contract;
- generic validation rules;
- a defined owner/interpreter in `m`;
- declarative provider realization data;
- explicit projection/execution semantics where applicable.

A new type is not accepted merely because a provider wants to store an extra key. The facility model must not become an arbitrary property bag.

Currently implemented realization types are command and environment projection. They are the first supported types, not the complete abstraction.

Candidate future types motivated by the service case include lifecycle and endpoint/network exposure. Those names and schemas are not yet fixed. If adopted, lifecycle execution remains owned by `srv`; static endpoint capability/default metadata remains distinct from actual runtime endpoint state.

### 3. Ordinary commands versus command-only facilities

The existing package command mechanism and a facility command part should share lower-level projection mechanics where that avoids duplication, but their semantics remain different.

An ordinary package such as `jq` may simply install/expose `jq` through the package/default command mechanism. That fact alone must not create:

- a facility identity;
- a facility default;
- a provider binding;
- an artificial second selection layer.

A facility whose complete contract consists of a single command is nevertheless valid when there is a real provider-independent capability and consumer substitution requirement. The discriminant is therefore abstraction/substitutability, not cardinality.

Do not introduce a generic facility named `command` merely to normalize all executables. That would collapse unrelated command capabilities into one meaningless provider domain and duplicate the existing package/default mechanism.

Implementation should instead look for a common internal command-projection primitive that can serve both ordinary package command publication and the command part of a facility while preserving the semantic distinction.

### 4. Service-style facilities

The service case is the main non-Java stress test.

The intended responsibility split is:

```text
pkg
    owns facility contract, provider conformance and provider selection

selected provider realization
    describes the lifecycle/network capability mapping

srv
    interprets the lifecycle portion and owns PID/locking/logging/termination mechanics

runtime state
    records the concrete running instance and actual endpoint state
```

A global operation such as `srv start <facility>` has no consumer package binding context; the leading direction is therefore to use the facility default/global provider selection rather than create a service-specific provider resolver.

Changing a facility default must not retarget an already-running service instance. The running instance must remain tied to the concrete provider realization selected when it was started; a later stop/start may observe the new default.

The previous convention `<service>-start` may remain an implementation mapping or compatibility surface, but it should not be the semantic definition of service-operability if the generalized contract contains an explicit lifecycle part.

The design must also make a deliberate distinction between provider-specific lifecycle operations and lifecycle behavior supplied generically by `srv`. For example, a provider may need a concrete start target while normal stop may be satisfiable by the generic SIGTERM lifecycle. Exact representation remains open.

### 5. Where concrete facility contracts should live

Three placements are being evaluated.

#### 5.1 Same `pkg-catalog` repository — leading candidate

This keeps provider-independent facility definitions and package/provider definitions inside the **same immutable catalog snapshot** already acquired by `pkg install`.

Advantages:

- provider declaration and referenced facility contract can be validated against one Git revision;
- a change that adds/changes a contract and updates its providers can be atomic in one commit/PR;
- no second remote, cache, lock, refresh policy, rate-limit surface or offline dependency is introduced;
- permanent/live tests can bind one catalog revision instead of coordinating two moving repositories;
- the current install snapshot mechanism can potentially expose both package definitions and facility contracts without a second acquisition pipeline;
- local-first/offline behavior remains simpler because one cached catalog snapshot contains the semantic data required to interpret packages.

Costs/risks:

- `pkg-catalog` broadens from package definitions to the complete package ecosystem catalog, so the logical namespace must clearly distinguish package definitions from provider-independent facility definitions;
- the current catalog root is package-oriented, so a reserved logical area/schema must be introduced without accidentally treating facility-definition directories as installable packages;
- contract validation and catalog layout tests become part of the same repository surface.

This is presently the preferred direction because it minimizes revision skew and testing asymmetry.

The exact directory names/layout are deliberately **not** fixed yet. They must be chosen after inspecting the current catalog resolver and proving that the new logical namespace does not create ambiguous package identities or special-case parsing.

#### 5.2 Separate facility-contract repository

Conceptually clean, but operationally more expensive.

It would require at least:

- a second remote and local cache/snapshot lifecycle;
- an explicit rule binding one `pkg-catalog` revision to one facility-contract revision;
- behavior for partial refresh/failure/offline availability of one repository but not the other;
- cross-repository compatibility validation;
- tests that reproduce exact pairs of revisions;
- coordinated changes when a new contract and its first provider must land together;
- another rate-limit/network failure surface.

Without an exact revision-binding mechanism, provider and contract HEADs could drift independently and produce nondeterministic installs/tests. Adding such a binding mechanism largely recreates complexity that a single repository avoids.

A separate repository becomes compelling only if facility contracts acquire an independent lifecycle/governance or are consumed materially outside the `pkg` ecosystem. No such requirement is established today.

#### 5.3 Embed concrete facility definitions in `rumiai-os`

This minimizes catalog acquisition work but couples every new/changed facility to a runtime/product revision.

That would weaken the intended data-driven package model and make adding a facility more like adding product code. It is therefore not the leading direction for **concrete facility definitions**.

A useful hybrid boundary does emerge:

```text
rumiai-os / pkg runtime
    knows the supported contract-part types and how to validate/interpret them

pkg-catalog
    likely owns concrete provider-independent facility definitions
    and package-specific provider realizations
```

This hybrid keeps the runtime vocabulary controlled while allowing concrete facilities to evolve as catalog data.

### 6. Package library structure

The completed earlier restructuring established `lib/sys/sh/pkg/` as the package library grouping directory while preserving leaf library identity.

Current package libraries now mix several substantial responsibilities in one physical directory, including core install/integration/launch/state code, provider/facility/dependency code and many repository adapters.

A deeper grouping is therefore justified if it follows the settled responsibility boundaries.

Leading physical organization to evaluate:

```text
lib/sys/sh/pkg/
    <cross-cutting package libraries remain here>

    facility/
        pkg-facility.lib.sh
        pkg-provider.lib.sh
        pkg-dependency.lib.sh
        <future contract/conformance/projection libraries only when responsibilities require them>

    repository/
        pkg-repository-*.lib.sh
```

This is physical organization only. Existing leaf names and manual identities should remain stable under the current library contracts unless a genuine API/identity change is separately justified.

Do not pre-create deeper trees such as `facility/contract/`, `facility/provider/` or one directory per contract type merely for symmetry. First define real responsibilities and library interfaces, then introduce the shallowest grouping that reduces coupling/retrieval cost.

Likely responsibility boundaries to isolate during design are:

- facility contract loading/validation;
- provider declaration/conformance indexing;
- provider selector/default/binding resolution;
- provider realization application/projection;
- dependency satisfaction;
- catalog access;
- repository-specific upstream adapters.

The exact leaf split is not fixed yet; existing libraries must be reused/refactored before introducing synonymous responsibilities.

### 7. Design proof cases

No schema should be promoted until it can model at least these two cases without provider-specific exceptions.

#### Java

The model must express:

- facility identity and compatibility (for example Java compatibility levels);
- a contractually defined interoperable command surface;
- required environment such as `JAVA_HOME` where the contract establishes it;
- Temurin and GraalVM as distinct conforming providers;
- consumer dependencies such as Maven/Keycloak/NetBeans without provider knowledge;
- provider-specific extra commands without accidentally expanding the facility contract.

#### GeoServer/service-style facility

The model must express:

- provider-independent service identity/compatibility;
- lifecycle semantics delegated to `srv`;
- provider-specific start realization where required;
- generic stop behavior when no provider-specific stop operation is needed, if that semantic is accepted;
- network protocol/endpoint capability without confusing static/default metadata with actual running endpoint state;
- facility default selection for global service operations;
- concrete-provider stability for a running instance across later default changes.

If these two cases require unrelated special-case mechanisms, the abstraction is not yet general enough.

## Canonical model already settled

Do not reopen these points unless a current contradiction is found. PACKAGE-MODEL.md now defines:

- package identity versus facility identity;
- a facility as a provider-independent substitutable capability contract owned by pkg;
- consumer dependence on facility identity/compatibility rather than provider identity;
- provider conformance/realization as distinct from the provider-independent contract;
- distinction between facility contract, provider realization and mutable selection conf;
- ordinary package command publication does not automatically create a facility, while a real command-only abstract capability may be one;
- extensibility through typed declarative contract parts with generic semantics;
- delegation to existing subsystems such as srv/mk without a second provider/dependency graph;
- facility-cmd and facility-env as current realization parts rather than the exhaustive facility definition;
- multiple installed providers;
- consumer selection order: explicit binding, otherwise facility default, otherwise failure;
- no implicit use of the only installed provider;
- separate package default and facility default;
- package-spec-shaped provider selectors;
- late-bound unversioned selectors and pinned versioned selectors;
- baseline no automatic installation of a missing dependency provider;
- runtime re-resolution and compatibility checking;
- binding storage under conf/binding/<facility>;
- declarative facility-cmd and facility-env metadata;
- generic launcher application;
- global facility command publication;
- generic versus pinned global command links;
- collision protection and package-default-triggered reconciliation.

The former commands-only global environment rule has been superseded by the Phase 1 canonical bootstrap contract:

- every new m bootstrap derives environment from currently resolvable facility defaults;
- active osarch comes from a valid ext-osarch selector without implicit platform selection; otherwise only generic provider classes apply;
- facilities are applied in LC_ALL=C name order and later facilities win duplicate ordinary variables;
- PATH remains owned by facility command publication and is invalid in facility-env;
- provider/facility default changes are observed by later bootstraps, not retroactively by already-running processes.

## Current implementation state

### rumiai-os

Current grouped package libraries contain the provider model:

- lib/sys/sh/pkg/pkg-provider.lib.sh
- lib/sys/sh/pkg/pkg-dependency.lib.sh
- lib/sys/sh/pkg/pkg-facility.lib.sh
- lib/sys/sh/pkg/pkg-integration.lib.sh
- lib/sys/sh/pkg/pkg-launch.lib.sh
- lib/sys/sh/pkg/pkg-default.lib.sh
- lib/sys/sh/pkg/pkg-install.lib.sh
- bin/sys/pkg

Current mechanics verified at activation:

- pkg provider default and pkg provider bind exist.
- pkg-provider.lib.sh resolves selectors, effective consumer selection and provider references.
- pkg-dependency.lib.sh resolves through consumer binding or facility default instead of choosing a unique installed provider.
- integration materializes dependency declarations but no longer writes an install-time concrete provider binding.
- integration validates/materializes facility-cmd and facility-env.
- pkg-launch.lib.sh re-resolves dependencies at launch and generically applies provider command/environment projections.
- pkg-provider.lib.sh contains current global command reconciliation helpers and pkg_provider_package_default_reconcile.
- pkg_default_apply invokes provider reconciliation on package-default transitions.
- current manuals describe the provider/global-command surface.

The global facility command implementation is newer than the last fully green provider validation described below and still lacks sufficient permanent regression coverage.

### pkg-catalog

Current catalog facts:

- Temurin package identity is temurin.
- Temurin declares java 25.
- GraalVM declares java 25.
- Temurin and GraalVM have declarative Java facility command/environment projections.
- the common JDK command set was inventoried from real artifacts; the current Java facility projection contains that common surface.
- macOS Java projection uses the Home layout; Linux uses provider root.
- Maven and Keycloak no longer contain their former provider-specific Java env scripts.
- package command wrappers were updated to the grouped pkg-launch library path.

Known catalog defect:

NetBeans is still on the superseded model. Its current env files still read a concrete-local binding/java, build JAVA_HOME themselves and alter PATH provider-specifically. This conflicts with the current generic launcher model and with removal of install-time concrete bindings.

Known catalog incompleteness:

GraalVM currently exposes only java 25 as a facility. Additional real capabilities, including native-image where actually present, have not yet been mapped to RumiAI facilities. Do not infer capabilities merely from GraalVM branding; inventory the exact artifacts first.

### rumiai-tests

Relevant permanent tests currently include:

- tests/rumiai-os/pkg/provider.test
- tests/rumiai-os/pkg/dependency.test
- tests/rumiai-os/pkg-launch/contract.test
- tests/external/temurin/install-live.test
- tests/external/graalvm/install-live.test
- tests/external/graalvm/temurin-coexistence-live.test
- tests/external/maven/install-live.test
- tests/external/keycloak/install-live.test
- tests/external/netbeans/install-live.test

Current structural tests cover provider configuration, binding/default precedence, late binding, no install-time concrete binding, runtime rebind and declarative provider projection.

Known test gaps:

- global facility-default command publication does not yet have complete permanent regression coverage;
- NetBeans live test is stale: it still refers to a package named java and follows the former provider mechanism;
- current HEADs have advanced after the last package-specific green validation;
- broader suite health stays owned by handoff/rumiai-tests-suite-realignment.md.

Current Java dependency consumers in pkg-catalog:

- Maven: java >=17
- Keycloak: java =25
- NetBeans: java =25

All three belong in the final Java-provider regression matrix.

### rumiai-dev-PoCs

Relevant experiments:

- pocs/009-package-provider-selector-resolution
- pocs/010-declarative-facility-runtime-projection
- pocs/011-facility-default-global-command-projection

PoC 011 demonstrated the mechanics now represented in the command-projection contract: unversioned links follow package defaults, pinned links remain pinned, osarch classes are independent, existing external roots are reused and unrelated collisions are rejected.

PoCs are evidence only, never authority.

## Revision-specific validation evidence

These runs are valid only for the exact revisions they exercised.

Structural provider model:

- GitHub Actions run 35390272397
- conclusion: success
- rumiai-os@384677c6acc9424fd4ce4eca7aa9aed104bded5d
- rumiai-tests@322cee67192e38c828145325131c9fe6d0574c40

It exercised provider configuration, provider selection, late binding, no install-time binding, runtime rebind and provider projection.

Live provider/consumer matrix:

- GitHub Actions run 35390278291
- conclusion: success
- rumiai-os@384677c6acc9424fd4ce4eca7aa9aed104bded5d
- rumiai-tests@322cee67192e38c828145325131c9fe6d0574c40
- pkg-catalog@bd06488d3c67160e820c04d13067f852c8861c32

It validated Temurin, GraalVM, coexistence, Maven, Keycloak and the involved macOS provider projections.

These runs predate the later global facility command implementation and do not validate current HEADs or that implementation. NetBeans was not in the final realigned matrix.

## Activated GitHub rate-limit work

The former TODO about GitHub package repository rate limits is now part of this task.

Known evidence:

- the GraalVM adapter uses GitHub-backed upstream API/download paths;
- repeated hosted validation produced real HTTP 403 responses while other runs against the same package succeeded;
- this is a repository/upstream reliability concern, not evidence that provider semantics are wrong.

The task must make rate-limit behavior predictable without weakening package integrity. Do not add mandatory credentials merely to make CI green. If an optional authentication/configuration surface becomes necessary, treat that as a user-visible design decision.

## Open work and known mismatches

### 0. Generalized facility-contract model

Before further Java-specific expansion, complete the meta-model described in Working design:

- settle compatibility/contract-evolution semantics;
- settle required versus optional/extra provider surface;
- define the minimal typed-part schema and conformance rules;
- decide the concrete facility-definition location, with same-revision `pkg-catalog` storage as the leading candidate;
- prove the model against Java and GeoServer/service-style cases;
- map implementation responsibilities before adding new libraries or deeper package-library grouping;
- promote only settled rules to PACKAGE-MODEL before runtime/catalog implementation.

### A. Global facility environment

Canonical semantics are now settled in PACKAGE-MODEL.md and BOOTSTRAP-ENVIRONMENT.md:

- compute from authoritative facility-default selector intent on every new m bootstrap;
- keep PATH owned by facility-cmd/global command publication and reject PATH in facility-env;
- process facility defaults in LC_ALL=C facility-name order, with the later facility assignment winning duplicate ordinary variables;
- re-resolve on each new bootstrap so facility-default/package-default changes are observed without generated environment state;
- do not mutate already-running processes;
- use the valid active ext-osarch class when available, otherwise only generic provider classes;
- unresolved valid selectors contribute no environment;
- invalid/corrupt global environment projection is reported without making m unavailable and without partial provider-environment application.

Implementation and permanent tests are still pending.

### B. Global command projection proof

Permanent tests must prove at least:

- set facility default publishes all selected facility commands;
- unset removes only commands owned by that facility;
- provider switch reconciles added/removed commands;
- consumer binding does not change global publication;
- unversioned selector follows package-default transition;
- pinned selector does not follow package-default transition;
- osarch-qualified selector publishes only in that class;
- unqualified selector handles each currently resolvable class;
- unrelated command collision fails safely;
- failed transition rolls back config and links;
- changed command sets across provider concretes are reconciled;
- package-default rollback keeps package and facility publication consistent.

### C. NetBeans realignment

Realign both catalog and live test:

- remove NetBeans provider-specific env code;
- use generic Java facility projection;
- replace the removed package identity java with temurin plus an explicit java facility default or binding;
- validate enough of the real public NetBeans command to prove provider projection without inventing GUI requirements;
- include NetBeans in the final Java matrix.

Then scan current catalog/tests for every remaining use of the former package identity java, concrete binding/java reads or consumer-specific JAVA_HOME logic.

### D. GraalVM facility completion

Required order:

1. inventory exact commands/components in every supported base artifact;
2. distinguish base-artifact capabilities from separately distributed language components;
3. map concrete capabilities to existing facility concepts where possible;
4. introduce no new facility name before searching current project responsibility/naming;
5. ask the user only where a semantic facility boundary/name is genuinely open;
6. add declarative projection and tests for accepted facilities.

native-image is a known concrete capability to evaluate but is not automatically part of the java facility.

### E. Dependency/install policy

Current baseline is explicit-only: missing provider means dependency resolution fails.

Whether to add assisted or automatic provider discovery/install remains a user decision.

### F. Install-time provider UX

Current pkg install does not have an accepted atomic surface for choosing a facility default or creating a consumer binding.

Whether install and provider configuration stay orthogonal or gain explicit install-time options remains a user decision.

### G. GitHub-backed repository reliability

Resolve the activated rate-limit work after core provider semantics are stable enough for repeated validation to be meaningful.

### H. Current exact revisions

No completion claim exists for the exact activation HEADs. Final validation must use exact post-change revisions.

## User decision gates

Do not ask the user to repeat already-settled binding/provider choices.

### Decision 1: missing dependency provider behavior

Ask whether the final intended model for this task is:

A. Explicit-only.
Missing provider causes failure; user installs/selects provider separately.

B. Assisted/manual resolution.
pkg discovers compatible catalog providers and returns or presents a resolution plan, but does not silently install one.

C. Automatic resolution/install.
pkg selects and installs a provider according to an explicit policy.

If B or C is selected, a second decision is required about the policy source: facility default only, ordered preferences, compatibility-aware rules or another explicitly approved model.

### Decision 2: install-time configuration UX

Ask whether:

A. pkg install remains installation-only and pkg provider default/bind remains the separate configuration surface;

or

B. pkg install gains explicit atomic syntax to set a facility default and/or a consumer binding in the same operation.

This is a public UX/transaction decision, not a change to selector semantics.

### Decision 3: GraalVM facility boundaries

Do not ask this abstractly. First produce a concrete artifact inventory and minimal proposed mapping. Ask only about facility names/boundaries that cannot be derived from current canonical concepts.

## Development plan

### Phase 0: generalized facility semantic baseline — completed for this checkpoint

- fresh preflight and current repository inspection;
- close/remove the completed library-grouping handoff;
- promote the provider-independent facility definition and authority boundaries into `PACKAGE-MODEL.md`;
- preserve unresolved schema/location choices as working design here.

Exit: semantic ownership is no longer Java-specific, while unresolved representation remains explicitly non-canonical.

### Phase 1: facility contract meta-model

Design, without implementation-first shortcuts:

- facility identity + compatibility-to-contract relationship;
- required contract surface;
- optional/extra capability policy;
- typed-part registration/validation semantics;
- provider conformance rules;
- consumer-visible guarantees;
- distinction between static contract data, provider realization, selection conf and runtime state.

Model Java and GeoServer side by side.

Exit: one provider-independent meta-model describes both cases without special-case provider logic.

### Phase 2: catalog ownership and representation

Evaluate the leading single-repository design against the real `pkg-catalog` resolver/snapshot behavior.

Required proof:

- package namespace and facility-definition namespace are unambiguous;
- one snapshot can validate provider declarations against facility contracts;
- no second mutable authority is introduced;
- offline/cache behavior remains deterministic;
- package install does not accidentally enumerate/interpret contract definitions as packages;
- exact facility-contract revision is inherently bound to the package catalog revision.

If this fails materially, compare a separate repository using an explicit revision-binding design rather than a pair of floating HEADs.

Exit: one storage/ownership design is selected and promoted.

### Phase 3: package library responsibility map

Before moving files:

- classify every current `lib/sys/sh/pkg/` responsibility;
- identify existing functions that already own contract/provider/projection duties;
- decide the shallowest useful physical groups;
- preserve library leaf/manual identities unless a true semantic/API rename is required;
- define any new public/internal library interface before implementation.

Likely groups to test are `facility/` and `repository/`, but names/layout remain provisional until this phase exits.

Exit: no duplicate facility/provider responsibility and one deliberate library topology.

### Phase 4: generalized runtime/catalog implementation

- implement facility contract loading/validation;
- validate provider declarations/realizations against the selected facility contract;
- adapt existing `facility-cmd` and `facility-env` to the generalized contract machinery rather than replacing them gratuitously;
- factor reusable command projection internally where the ordinary package-command and facility-command paths genuinely share mechanics;
- preserve existing provider selector/default/binding behavior;
- add permanent property-focused tests.

Exit: current Java behavior is expressed through the generalized machinery without regression.

### Phase 5: Java contract and consumer completion

- define the actual Java facility contract(s) needed by current compatibility levels;
- validate Temurin and GraalVM conformance;
- decide how provider-extra Java/GraalVM commands are represented without silently becoming consumer guarantees;
- realign NetBeans;
- validate Maven, Keycloak and NetBeans with generic provider machinery;
- exercise coexistence and explicit binding override.

Exit: all current Java consumers rely only on the provider-independent Java contract.

### Phase 6: service bridge

Coordinate with `handoff/service-model.md`:

- define the minimal lifecycle contract part;
- determine whether endpoint/network capability is part of the first service contract or a subsequent typed part;
- define provider-specific start mapping versus generic srv stop semantics;
- make global srv operations consume facility-default selection without a second provider resolver;
- preserve running-instance concrete-provider identity across later default changes;
- decide the compatibility role, if any, of `<service>-start`.

Exit: service lifecycle reuses pkg facility/provider selection without turning srv into a second package manager.

### Phase 7: global projection + policy completion

- complete global facility environment/runtime validation;
- complete global command projection regression proof;
- ask the still-open missing-provider resolution policy decision;
- ask the still-open install-time provider configuration UX decision;
- implement only the selected policy.

### Phase 8: GraalVM additional facilities and repository reliability

- inventory real GraalVM artifact capabilities;
- map only genuine additional facilities;
- resolve GitHub-backed repository rate-limit behavior without weakening integrity.

### Phase 9: exact-revision validation and closure

Run the final structural/live matrix against exact revisions, including generalized contract validation, provider coexistence, Java consumers, selector transitions, Linux/macOS coverage and the service bridge when that workstream is ready. Then perform the full consistency gate and handoff closure protocol.

## Completion criteria

Do not close this task until all applicable conditions hold:

- the generalized facility contract model is promoted and mechanically validated before Java/service-specific expansion;
- concrete facility definition storage has one unambiguous authority and revision model;
- provider conformance is validated against provider-independent facility contracts;
- ordinary command publication remains distinct from facility identity while command-only facilities remain possible when semantically justified;
- package library grouping reflects real responsibilities without duplicate APIs;
- Temurin is never represented by package identity java;
- Temurin and GraalVM coexist;
- facility default and consumer binding use one coherent selector model;
- late binding and pinning work across later default changes;
- no consumer-specific provider lookup remains in Maven, Keycloak or NetBeans;
- global facility commands satisfy publication/collision/rollback contract;
- bootstrap/global facility environment matches explicit user direction and canonical docs;
- Maven, Keycloak and NetBeans all validate with the generic Java facility model;
- accepted GraalVM base facilities are accurately represented;
- missing-provider/install-time policy is explicitly chosen, documented and tested;
- GitHub rate-limit behavior is defined and tested;
- permanent tests protect semantic properties;
- final live evidence is bound to exact final revisions;
- no active TODO duplicates this task;
- service lifecycle remains separate;
- final consistency gate and handoff lifecycle complete.

## Current state

The semantic gap identified in the previous checkpoint has now been partially closed at the canonical level.

`PACKAGE-MODEL.md` now explicitly defines a facility as a provider-independent substitutable capability contract owned by `pkg`, distinguishes facility contract / provider realization / mutable selection conf, rejects automatic promotion of ordinary commands to facilities, and establishes typed declarative extensibility plus delegation to existing subsystem owners.

The exact facility-contract representation is intentionally not yet canonical. In particular, compatibility evolution, required-vs-optional surface, concrete catalog layout and lifecycle/endpoint schemas remain design work.

The leading architectural placement is now a hybrid:

```text
rumiai-os/pkg
    contract-part type implementations/interpreters

pkg-catalog
    concrete facility definitions + package/provider realizations
```

with both catalog data classes in one Git revision. A separate facility repository remains an evaluated alternative, not the preferred baseline.

The previous library-subsystem grouping task is complete and its handoff has been removed. Any deeper `pkg` grouping is new work owned here and must be driven by the generalized facility responsibility map, not by the old restructuring task.

No runtime, test or catalog behavior has been changed by this design checkpoint. Existing validation evidence therefore remains revision-specific and does not prove the generalized contract model.

## Next action

1. Define the facility contract meta-model on paper using Java and GeoServer as simultaneous proof cases, including compatibility evolution, mandatory surface and provider extras.
2. Inspect the real `pkg-catalog` resolver/snapshot assumptions and draft the smallest same-repository logical namespace that can hold facility definitions without ambiguity.
3. From those two results, produce the package-library responsibility map and only then decide the deeper `lib/sys/sh/pkg/` grouping.
4. Promote the resulting settled storage/schema rules before implementation.

## Blockers / open questions

User/design decisions that remain genuinely open:

- concrete facility-definition placement: same `pkg-catalog` revision is the leading candidate; separate repository remains possible only if a concrete independent-lifecycle requirement justifies its added revision/test complexity;
- exact compatibility-to-contract evolution semantics;
- whether facility contracts support optional members or expose only a mandatory interoperable surface;
- exact first lifecycle/endpoint typed-part semantics for service-style facilities;
- missing dependency provider behavior: explicit-only versus assisted/manual versus automatic;
- install-time provider configuration UX: separate operations versus explicit atomic install options;
- after GraalVM inventory, only facility boundaries that cannot be derived from the generalized contract model.

Non-user work still required:

- catalog namespace/layout proof;
- package-library responsibility mapping;
- generalized contract/conformance implementation and tests;
- global provider environment/projection regression completion;
- NetBeans realignment;
- GraalVM capability inventory;
- GitHub rate-limit robustness;
- final exact-revision validation.
