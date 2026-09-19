# Package provider/facility completion

Status: Active
Updated: 2026-09-19 16:04 +02:00

## Goal

Finish the RumiAI package provider/facility model as one coherent task across rumiai-dev, rumiai-os, rumiai-tests, pkg-catalog and the relevant PoCs.

This task owns the remaining work around package identity, facilities, multiple providers, facility defaults, consumer bindings, provider selectors, dependency behavior, runtime projections, global facility publication, Temurin/GraalVM, all Java consumers, GitHub-backed package reliability and final semantic/live validation.

Services remain out of scope and stay owned by handoff/service-model.md.

## Current repository revisions

Latest reconciled checkpoint:

```text
rumiai-dev      908f1064d54e283514a1ce0a6f25911e32a053f7  pre-handoff-sync HEAD
rumiai-os       a8e45d327b218f19cee82c3813bfc75fb5ea64b6
rumiai-tests    2629d606913828a45f96acaef4bbc14dd443f1f7
pkg-catalog     4c67eb5c7cf27fbc48c222fd8196f0127409be00
rumiai-dev-PoCs cb8c5d636ce65e6cb00626ed08947fe25a25988e
```

The package/catalog/library work in this checkpoint was written forward-only on top of concurrent gitman activity. The later rumiai-dev, rumiai-os and rumiai-tests movement was inspected and affected only the separate gitman workstream; the package changes remain ancestors of the current HEADs. Fresh HEAD retrieval remains mandatory before every later write.

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

The durable semantic rules already promoted to `PACKAGE-MODEL.md` are not duplicated here. The following task state is fixed by explicit user direction or by the completed authorized Phase 2/3 work:

1. Eclipse Temurin is the concrete package `temurin`; GraalVM is a distinct package. Both may provide the provider-independent `java` facility.
2. Java consumers remain provider-independent. Maven, Keycloak, NetBeans and later consumers must not contain Temurin/GraalVM-specific provider selection or hardcoded Java-provider environment construction.
3. Existing provider selector/default/binding semantics remain the baseline while the generalized facility contract is designed.
4. `facility-cmd` and `facility-env` are current provider-realization mechanisms, not the complete semantic definition of a facility.
5. The generalized meta-model must be demonstrated against both Java and a service-style facility such as GeoServer before implementation continues into the later phases.
6. Concrete facility definitions and package definitions live in the **same `pkg-catalog` revision**. The catalog namespace is now fixed as:

   ```text
   pkg-catalog/
       pkg/<package>/...
       facility/<facility>/...
   ```

   All existing package definitions have already been moved beneath `pkg/`. The `facility/` pathname is the fixed home for provider-independent facility definitions; because Git does not materialize empty directories, it will first appear in the repository when the first accepted facility contract is added.
7. Package-library physical organization is fixed and implemented as:

   ```text
   lib/sys/sh/pkg/
       <public subcommand entrypoints and cross-cutting package libraries>

       facility/
           pkg-facility.lib.sh
           pkg-dependency.lib.sh
           <future internal facility-contract libraries only when responsibilities require them>

       repository/
           pkg-repository-*.lib.sh
   ```

   `pkg-provider.lib.sh` intentionally remains directly under `lib/sys/sh/pkg/`: it is the public `pkg provider` subcommand entrypoint and the shared provider-selection API. Physical grouping must not force dispatcher exceptions or conflate public provider configuration with future internal contract-validation responsibilities.
8. No additional library subdivision is authorized by aesthetics alone. New facility libraries are introduced only after the meta-model establishes a real responsibility not already owned by an existing library.
9. Phases 4 through 8 are blocked on Phase 1. Do not implement generalized conformance, Java contract migration, the service bridge, policy changes or additional GraalVM facilities until the facility contract meta-model is accepted and promoted.

## Working design

The catalog ownership and implementation grouping questions are now resolved. The only active architecture question before implementation continues is the **facility contract meta-model**.

The proposal below is intentionally working design, not current specification. It is detailed enough to be challenged point by point before promotion.

### 1. Model boundary: four different information planes

The facility model must keep four authorities separate.

```text
facility contract
    provider-independent meaning and guarantees

provider realization
    how one package concrete satisfies those guarantees

selection configuration
    which valid provider selector is chosen

runtime / instance state
    what a selected provider instance is doing now
```

The facility contract belongs to the catalog and says what every conforming provider guarantees. It never contains a selected provider, mutable preference, concrete package path, PID, actual listening port or other runtime state.

The provider realization belongs to a package definition and maps that package's concrete artifact onto the facility contract. It may contain paths, descriptors and other provider-specific implementation data, but it cannot redefine the facility.

Selection configuration remains the existing system-scoped facility default / consumer binding model.

Runtime state remains owned by the subsystem performing the operation. For a service this includes the concrete provider selected at start time, PID/log/lock state and any actual endpoint. Changing a facility default later must never mutate an already-running instance.

### 2. Proposal: compatibility values are ordered **contract levels**

The existing facility compatibility value should not be interpreted as a package version or merely as a number that happens to compare higher or lower. It should mean:

> the exact provider-independent contract level that the provider guarantees.

For one facility identity, compatibility levels form one **monotonic substitutability lineage**.

A provider declaring:

```text
java 25
```

claims conformance to the complete `java` contract at level `25`. A consumer declaring:

```text
java >=17
```

may accept that provider only because the `java` contract itself guarantees that every higher level in the same lineage preserves all guarantees of lower levels.

This gives the existing numeric constraint language a real semantic basis instead of treating numerical ordering as a proxy for compatibility.

The proposed evolution rules are:

```text
same facility identity + higher compatibility
    = backward-compatible additive evolution

removal or semantic change of an existing guarantee
    = NOT a higher compatibility level of the same lineage

breaking contract
    = new facility identity
```

A higher level may add new required members/parts, but it may not remove an inherited guarantee or change its meaning incompatibly.

An exact dependency such as `java =25` keeps its current exact semantics. A range such as `>=17` relies on the monotonic lineage. A provider declares one compatibility level for one facility; a higher declared level is sufficient for lower range requirements because the lineage is cumulative.

This is the most consequential proposal in Phase 1. If Java 17 and Java 25 cannot be represented honestly as one monotonic facility lineage once their required interoperable surface is inventoried, that is evidence against this rule or against using upstream Java release numbers directly as RumiAI facility contract levels. We must not hide that contradiction.

### 3. Proposal: each published level is complete and semantically immutable

Each `<facility, compatibility>` pair should contain a **complete, self-contained contract**, not a delta that must be merged with predecessor levels.

Conceptually:

```text
facility/java/17
    complete Java level-17 contract

facility/java/25
    complete Java level-25 contract
```

The level-25 definition repeats the inherited required surface and adds only compatible guarantees. This duplicates a small amount of declarative data but avoids inheritance chains, merge rules and hidden state when validating a provider.

Once a compatibility level has been published and used by provider definitions, its consumer-visible semantics are immutable. Adding a new mandatory member, removing one or changing its meaning requires a new compatibility level; an incompatible change requires a new facility identity.

This immutability is important because installed providers outlive the catalog snapshot from which they were installed. Runtime must be able to trust the stored declaration `<facility, compatibility>` without fetching a current catalog and wondering whether the old meaning changed underneath it.

### 4. Proposal: first contract model is **required-surface only**

The first facility-contract model should not contain optional members.

A contract level defines exactly the provider-independent surface that every provider at that level must supply. A consumer depending only on that facility may rely on that entire surface and on nothing else.

Provider-specific extras are intentionally outside the facility realization:

```text
common interoperable capability
    -> facility contract

provider-specific extra command/capability
    -> ordinary package surface
       or a separate facility when it deserves provider-independent substitution
```

For example, if `native-image` is not part of the Java contract shared by accepted Java providers, GraalVM must not smuggle it into the `java` facility merely because it is present in the artifact. It remains a GraalVM/package capability or becomes a separate facility after its own boundary is accepted.

This required-only rule makes two providers of the same facility level structurally interchangeable and removes a large source of asymmetric test behavior.

Optional contract members can be introduced later only if a real consumer requirement proves that capability discovery inside one facility is preferable to a separate facility. The baseline should not pay that complexity cost now.

### 5. Proposal: a typed part defines a complete mini-contract

A facility contract is a composition of typed declarative parts. The generic facility engine must not know provider-specific keys.

Each supported part type defines four things:

```text
1. contract schema
   what provider-independent members/guarantees the facility may declare

2. provider-realization schema
   what concrete data a provider must supply for those members

3. conformance validator
   what pkg can prove mechanically at install/integration time

4. application semantics + owner
   when/how the selected realization is consumed and which subsystem owns execution
```

Unknown part types are errors; they are never ignored. This keeps extensibility controlled rather than turning the catalog into an arbitrary property bag.

One provider is selected for the **whole facility**. There is no part-level provider mixing: Java commands cannot come from Temurin while `JAVA_HOME` comes from GraalVM under one selected `java` facility.

Facility contracts also do not declare implementation dependencies on other facilities. If a GeoServer provider requires Java, that remains a dependency of the provider package. This avoids creating a second dependency graph inside facility definitions.

### 6. Initial part semantics

The current command and environment mechanisms map naturally onto the typed-part model.

#### command

Contract side:

```text
set of required public command names
```

Provider side:

```text
required command name -> executable path inside provider useful root
```

Mechanical conformance can prove that every required name is realized exactly once, the target remains inside the useful root and is executable. Under the required-only proposal, a provider realization for that facility level contains no extra facility commands.

Application semantics are already known:

```text
consumer-specific selected provider
    -> selected facility command projection precedes inherited/package PATH

facility default
    -> facility commands are published through the existing global external-command roots
```

An ordinary package command continues to use the normal package/default mechanism and does not become a facility merely because the same low-level command-projection machinery may eventually be reused internally.

#### environment

Contract side:

```text
set of required exported variable names
```

Provider side:

```text
variable -> existing typed provider descriptor
            root | root-path | literal
```

The facility contract guarantees that the variable is available when the facility is applied. The provider realization chooses its concrete value. The contract does not need to know that Temurin and GraalVM derive `JAVA_HOME` from different internal paths.

Application semantics remain the current consumer-launch projection and facility-default bootstrap environment.

#### lifecycle — proposed future type, not yet accepted

The lifecycle part should define semantic operations/capabilities, while its provider realization supplies only the concrete operations that actually require provider-specific implementation.

This allows a service contract to require `start` and `stop` while one provider realization supplies a concrete start target and `srv` supplies normal stop generically through its PID/SIGTERM lifecycle.

The exact descriptor grammar remains open until the generic meta-model is accepted; the important architectural rule is that lifecycle semantics are declared by the facility contract, provider mapping is data, and process mechanics remain owned by `srv`.

#### endpoint — proposed future type, not yet accepted

The endpoint part should describe a provider-independent **network capability**, not a current socket.

A contract could state that a running provider exposes a logical HTTP endpoint. Provider realization may eventually describe defaults or how the endpoint is discovered/configured. The actual address/port of a running instance remains runtime state.

The endpoint type is useful as a stress test for the meta-model, but its first concrete schema should not be designed before lifecycle is understood.

### 7. Proposed catalog representation

The fixed catalog namespace is:

```text
facility/<facility>/...
```

The simplest candidate representation for Phase 1 is:

```text
facility/<facility>/<compatibility>/<part>/<member>
```

For example, conceptually:

```text
facility/java/25/
    command/
        java
        javac
        ...
    environment/
        JAVA_HOME
```

Each compatibility directory is a complete contract. Part directories are strict and known to the runtime. Each member is a declarative descriptor whose contents are owned by the part type; for a part where the member name alone is sufficient, an empty marker file is enough.

No generic free-form metadata bag, inheritance file, provider selector, package path or runtime configuration belongs here.

The exact filesystem tokens `command` and `environment`, and the exact descriptor contents, are still proposal details. They should be fixed only after the semantic rules above are accepted.

### 8. Proposed conformance lifecycle

Provider conformance should be established at package install/integration time against the **same catalog snapshot** that supplied the package definition.

Conceptually:

```text
package range declares provides <facility> <compatibility>
    ↓
pkg loads facility/<facility>/<compatibility> from same snapshot
    ↓
validate facility contract structure and supported part types
    ↓
validate provider realization against every required part/member
    ↓
materialize only a validated provider declaration/realization
    ↓
index provider as installed
```

A missing contract, unknown part type, missing required member, unexpected facility member under the required-only model, invalid target or invalid descriptor fails installation/integration.

Runtime provider selection does not fetch the catalog again. It relies on an installed provider that already passed conformance validation and on the semantic immutability of the published facility level. This preserves local-first/offline operation and avoids a second runtime authority.

Mechanical conformance must not be overstated as behavioral proof. `pkg` can prove that a command exists at the required mapping, not that the executable fully implements the Java specification. Behavioral semantics remain a provider assertion supported by appropriate package/live tests.

### 9. Java proof case under this proposal

A Java facility level would declare only the interoperable surface that every accepted provider at that level must guarantee.

Conceptually:

```text
java <level>
    command
        <required common JDK commands>

    environment
        JAVA_HOME
```

Temurin and GraalVM map those same contract members to their own concrete artifact layouts. Maven, Keycloak and NetBeans depend only on `java` compatibility constraints.

GraalVM-only capabilities are not added as optional Java members. They remain package-specific or become separate facilities.

Before promoting the monotonic-level rule, Java 17 and Java 25 must be checked explicitly: the accepted level-25 required surface must preserve every guarantee in the accepted level-17 surface. If not, either the facility contract must be narrowed to the true stable interoperable surface or the compatibility model must be revised.

### 10. GeoServer/service proof case under this proposal

A service-style facility demonstrates that a facility is not merely PATH + environment.

Conceptually:

```text
geoserver <level>
    lifecycle
        start
        stop

    endpoint
        http
```

A provider realization may map `start` to one concrete package command while `stop` is fulfilled by generic `srv` process termination. The endpoint contract states that the running service exposes the named protocol capability; it does not encode the currently bound socket.

`srv start <facility>` resolves the facility default through `pkg`, records the resolved concrete provider for the running instance and then interprets the lifecycle realization. A later facility-default change affects a future start/restart, not the already-running instance.

If this case cannot be expressed without adding provider-specific exceptions to the facility engine, the meta-model is not ready.

### 11. Main alternatives and why they are not the baseline

Three alternatives remain useful as checks, but are not the proposed baseline.

**Non-monotonic numeric compatibility.** This preserves arbitrary upstream versioning but makes constraints such as `>=17` semantically unsafe unless a separate compatibility matrix/graph is added.

**Explicit compatibility graph/matrix.** This is more expressive but introduces a second relation that every resolver/test must understand. It is not justified while ordered substitutability can describe the required facilities.

**Optional members inside one facility.** This makes provider discovery richer but weakens the statement “a consumer can depend on the facility without knowing the provider” and recreates provider-specific branching. Separate facilities/package extras are simpler until a real use case proves otherwise.

The proposal therefore deliberately chooses a smaller, stricter abstraction first.

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

Phase 2 (catalog ownership/layout) and Phase 3 (package-library responsibility layout) are complete and promoted.

Phase 1 is now the only architecture gate before implementation continues. The proposal in Working design must be reviewed and either accepted or corrected, especially:

- monotonic ordered compatibility levels versus a more complex compatibility relation;
- self-contained immutable contracts per compatibility level;
- required-only facility surface versus optional members;
- the four-part typed-part responsibility model;
- the candidate `facility/<facility>/<compatibility>/<part>/<member>` representation;
- Java 17/25 monotonicity as a concrete proof;
- lifecycle/endpoint expressiveness for the GeoServer proof case.

Do not begin Phase 4 until these semantics are promoted to `PACKAGE-MODEL.md`.

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

### Phase 2: catalog ownership and representation — complete

Accepted and implemented:

```text
pkg-catalog/
    pkg/<package>/...
    facility/<facility>/...
```

All existing package definitions are under `pkg/`. `pkg install` resolves package names only from that namespace. Facility definitions share the same immutable catalog snapshot and cannot be misinterpreted as packages.

### Phase 3: package library responsibility map — complete

Accepted and implemented physical groups:

```text
lib/sys/sh/pkg/facility/
    pkg-facility.lib.sh
    pkg-dependency.lib.sh

lib/sys/sh/pkg/repository/
    pkg-repository-*.lib.sh
```

Public subcommand entrypoints remain directly under `lib/sys/sh/pkg/`; specifically, `pkg-provider.lib.sh` remains there. No new facility-contract library has been invented before Phase 1 defines its actual responsibility.

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

Phases 2 and 3 no longer block the task.

Current catalog structure is implemented at `pkg-catalog@4c67eb5c7cf27fbc48c222fd8196f0127409be00`: all 13 current package definition trees live under `pkg/`; `facility/` is the fixed provider-independent contract namespace and will materialize with the first accepted contract.

Current product grouping is present at the current `rumiai-os` HEAD: package installation resolves `<catalog-snapshot>/pkg/<package>`, repository adapters live under `lib/sys/sh/pkg/repository/`, and the existing internal facility/dependency libraries live under `lib/sys/sh/pkg/facility/`. Concurrent gitman commits advanced the product afterward without touching these package changes.

Current permanent test sources have been realigned to the grouped library paths and the Model 2 layout test now requires the two second-level package directories and rejects the superseded flat placements. Concurrent gitman test commits advanced the test HEAD afterward without touching the package changes.

No runtime PASS is claimed for this checkpoint. The local execution environment cannot resolve `github.com`, so the composed live install path against the newly restructured catalog has not been executed here. Structural tree/diff checks confirm the intended current paths and absence of the superseded catalog/package-library locations.

The active architecture gate is now solely Phase 1. The detailed proposal above is intentionally unpromoted working design.

## Next action

Review the Phase 1 proposal with the user, beginning with the compatibility model because it constrains every other choice.

If the monotonic-contract-level rule is accepted, next validate it concretely against the Java 17/25 surface before promoting it. Then settle required-only surface and the typed-part representation, re-run the GeoServer thought experiment, and promote the complete accepted meta-model in one coherent `PACKAGE-MODEL.md` update.

Do not start Phase 4 implementation before that promotion.

## Blockers / open questions

Phase 1 decisions requiring user review:

- Should one facility identity define a monotonic substitutability lineage, so a higher compatibility level must preserve all lower-level guarantees and a breaking change requires a new facility identity?
- Should each compatibility level be a complete/self-contained and semantically immutable contract rather than an inherited delta?
- Should the first contract model expose only mandatory interoperable members, with provider extras kept outside the facility or modeled as separate facilities?
- Is the typed-part model (contract schema + provider schema + validator + application owner) the correct generic extension boundary?
- After those semantic choices, should the physical facility contract use the minimal `facility/<facility>/<compatibility>/<part>/<member>` shape?

Evidence still required before promotion:

- compare actual candidate Java 17 and Java 25 required surfaces to test monotonicity;
- exercise the lifecycle/endpoint model against GeoServer without provider-specific exceptions.

Later user decisions remain deferred behind Phase 1:

- missing dependency provider behavior: explicit-only versus assisted/manual versus automatic;
- install-time provider configuration UX;
- GraalVM additional facility boundaries after artifact inventory.

Known non-Phase-1 work remains blocked or pending:

- generalized contract/conformance implementation and tests;
- global provider environment/projection regression completion;
- NetBeans realignment;
- GraalVM capability inventory;
- GitHub rate-limit robustness;
- final exact-revision validation.
