# Package provider/facility completion

Status: Active
Updated: 2026-09-19 20:55 +02:00

## Goal

Finish the RumiAI package provider/facility model as one coherent task across rumiai-dev, rumiai-os, rumiai-tests, pkg-catalog and the relevant PoCs.

This task owns the remaining work around package identity, facilities, multiple providers, facility defaults, consumer bindings, provider selectors, dependency behavior, runtime projections, global facility publication, Temurin/GraalVM, all Java consumers, GitHub-backed package reliability and final semantic/live validation.

Services remain out of scope and stay owned by handoff/service-model.md.

## Current repository revisions

Latest reconciled checkpoint before this handoff sync:

```text
rumiai-dev      30ce4aa6b86b332c4724a1418831cbfe2b45a2c9
rumiai-os       50b760bd3cfe08922068ceb7d973d7edee12251c
rumiai-tests    4faab7053c02fb954cad6b995b31b8d89774a6ff
pkg-catalog     4c67eb5c7cf27fbc48c222fd8196f0127409be00
rumiai-dev-PoCs cb8c5d636ce65e6cb00626ed08947fe25a25988e
```

Fresh remote HEAD retrieval remains mandatory before every later write.

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

The compatibility/contract evolution question is resolved and canonical. The remaining Phase-1 design question is the implementation boundary for typed facility parts.

The current product already proves that different part types need different runtime semantics:

- command projection is materialized under `facility-cmd`, consumed by launcher PATH projection and by global facility publication;
- environment projection is materialized under `facility-env`, interpreted into concrete values and applied by provider/bootstrap logic;
- service lifecycle is currently owned by `srv` and cannot be reduced to either PATH or environment projection.

The proposal is therefore to standardize the **integration lifecycle of a part**, not to force one generic runtime `apply` interface onto all part types.

### 1. Generic facility-part lifecycle

Every supported part type participates in exactly three integration operations:

```text
contract_validate
realization_validate
realization_materialize
```

Semantics:

1. `contract_validate`
   - validates the provider-independent contract subtree for that part type;
   - owns the grammar and semantic constraints of that type's contract data;
   - performs no provider selection and no runtime action.

2. `realization_validate`
   - validates one provider's declarative realization of that contract part;
   - receives the exact facility contract part, provider definition data and extracted useful root;
   - proves only mechanically checkable conformance;
   - rejects missing required members, unexpected facility members and invalid provider mappings.

3. `realization_materialize`
   - runs only after the whole package/facility definition has passed validation;
   - materializes the validated runtime representation needed by the eventual type owner;
   - may incorporate contract semantics into the materialized representation so runtime never needs to refetch the catalog;
   - does not execute the capability.

There is deliberately **no required generic runtime operation** such as `part_apply`. Runtime consumption remains type-specific.

This gives one common integration contract while preserving different operational owners.

### 2. Generic dispatcher versus type handlers

The generic facility engine should know only:

- facility identity and exact compatibility;
- the selected contract directory;
- which part types are supported by the current runtime;
- how to dispatch the three integration operations above;
- that unknown part types are fatal.

It must not know command names, environment descriptors, lifecycle operations or provider-specific data formats.

The simplest implementation is an explicit RumiAI-owned dispatch table/case in the facility subsystem, not dynamic code loading from the catalog. Conceptually:

```text
part=cmd
    -> built-in cmd handler

part=env
    -> built-in env handler

part=lifecycle
    -> built-in lifecycle handler
```

Adding a new supported type therefore requires adding RumiAI runtime code and registering that type in the trusted dispatcher. Catalog data alone can never install executable validation/runtime logic.

This is intentionally stricter than a plugin loader and avoids treating provider metadata as code.

### 3. Proposed library responsibilities

Prefer reusing `pkg-facility.lib.sh` as the generic facility-contract orchestrator rather than creating a synonymous second generic library.

The shallow package grouping can then grow only when a real type exists:

```text
lib/sys/sh/pkg/facility/
    pkg-facility.lib.sh
        facility identity/compatibility parsing
        provider declaration/index
        exact contract lookup
        part enumeration
        trusted type dispatch
        whole-facility conformance orchestration

    pkg-dependency.lib.sh
        consumer compatibility constraints and provider satisfaction

    pkg-facility-cmd.lib.sh
        cmd contract validation
        cmd provider-realization validation
        cmd materialization helpers

    pkg-facility-env.lib.sh
        env contract validation
        env provider-realization validation
        env materialization/descriptor helpers

    pkg-facility-lifecycle.lib.sh
        future only after lifecycle semantics are accepted
```

Do not create `part/`, `contract/`, `handler/` or other deeper grouping solely for symmetry.

Existing provider-selection/public command ownership remains in `pkg-provider.lib.sh`. Existing launcher orchestration remains in `pkg-launch.lib.sh`. Type handlers may expose internal helpers to those owners, but moving selection or lifecycle ownership into the generic facility engine is not part of this proposal.

### 4. Physical contract envelope

The generic filesystem contract should stop one level earlier than the previous `<part>/<member>` proposal:

```text
facility/<facility>/<compatibility>/<part>/...
```

The generic engine owns only the envelope through `<part>/`. Everything below that directory is the schema of the specific part handler.

This is more general than forcing every type into the same member-file model.

For the first two types the candidate schemas are naturally simple:

```text
facility/java/25/
    cmd/
        java
        javac
        jar

    env/
        JAVA_HOME
```

For `cmd` and `env`, the leaf entries can be empty regular marker files because the provider-independent contract only needs to identify required names. Provider-specific paths/values remain in the provider realization.

A later lifecycle contract may need richer leaf contents. That does not require changing the generic envelope.

Part names should be a small validated runtime-controlled token space. The exact grammar can be fixed with the implementation, but catalog part names must never be converted into arbitrary source paths or executable function names without trusted dispatch validation.

### 5. Provider realization envelope

Do **not** replace the existing working provider representation merely to make it visually symmetrical.

The current catalog/runtime already uses:

```text
facility-cmd/<facility>/...
facility-env/<facility>
```

The generic convention can treat the provider realization for part `<part>` as the existing type-owned `facility-<part>` surface:

```text
facility-cmd/<facility>/...
facility-env/<facility>
facility-lifecycle/<facility>/...   # future candidate only
```

The part handler owns the shape below that point. In particular, `cmd` may use a directory while `env` may remain a descriptor file.

This avoids a large migration that adds no semantic value and follows the existing Phase-4 rule to adapt `facility-cmd` / `facility-env` rather than replace them gratuitously.

The generic facility validator must nevertheless enforce a closed world:

- a provider realization may exist only for a facility declared by that package;
- a `facility-<part>` realization may exist only when that exact facility contract contains the corresponding supported part;
- unknown `facility-<part>` types are invalid;
- missing realization data is invalid when the type handler says the contract requires provider-specific data;
- provider-specific extras must not appear as undeclared members of the facility realization.

### 6. Whole-facility validation algorithm

For each exact provider declaration:

```text
<facility> <compatibility>
```

integration should perform:

```text
resolve:
    <catalog>/facility/<facility>/<compatibility>

validate generic contract envelope
    ↓
enumerate part directories
    ↓
for every part:
    dispatch contract_validate

then
    ↓
for every part:
    locate provider realization
    dispatch realization_validate

then
    ↓
scan provider facility-* data
and reject undeclared/unknown extra part realizations
```

Only after **all** package/facility validation succeeds may materialization begin.

Materialization then dispatches `realization_materialize` for every validated part. This preserves the current validate-before-mutate discipline and keeps rollback limited to filesystem/I/O failures rather than semantic discovery during partial integration.

### 7. Catalog snapshot must become explicit integration context

The current `pkg install` path has the selected catalog snapshot, but the current `pkg_integrate` interface receives only the selected package range and extracted root.

The generalized contract validator cannot safely derive the catalog root by walking parent directories or rely on hidden global state.

The implementation should therefore make the selected catalog snapshot an explicit integration input.

Preferred direction:

```text
pkg_integrate
    receives the catalog snapshot/root explicitly
    together with package/range/root identity
```

Then integration can prove both:

- the package definition belongs to `<catalog>/pkg/<package>/...`;
- the facility contract comes from `<catalog>/facility/<facility>/<compatibility>/...`.

This mechanically enforces the already-canonical same-snapshot rule.

Exact positional syntax is not fixed here because changing `pkg_integrate` is a library-interface change that must be designed with its current manual/tests, but implicit path derivation and hidden environment context are rejected directions.

### 8. Runtime representation

Runtime must not read `pkg-catalog`.

Each type handler materializes enough validated information for its runtime owner.

For current types this already exists:

```text
cmd
    -> installed facility-cmd projection

env
    -> installed facility-env descriptor
```

A future lifecycle handler may materialize a resolved lifecycle descriptor that combines contract semantics and provider realization. That descriptor can tell `srv` whether an operation is provider-specific or supplied generically by `srv`, without requiring `srv` to read the original facility contract.

Therefore runtime ownership becomes:

```text
pkg facility engine
    validates + materializes

pkg-provider / launcher
    consume cmd/env representations where already owned

srv
    consumes lifecycle representation

future owners
    consume their own typed runtime representation
```

No type handler receives independent provider selection. The provider is selected once for the whole facility before runtime consumption.

### 9. Command proof

Candidate contract:

```text
facility/java/25/cmd/
    java
    javac
    jar
```

Provider realization remains:

```text
facility-cmd/java/
    java    -> bin/java
    javac   -> bin/javac
    jar     -> bin/jar
```

The cmd handler validates:

- contract entries are valid command names;
- contract entries are unique regular non-executable markers;
- realization contains exactly the required facility command members;
- every mapping is a valid relative path;
- every resolved target stays inside the provider useful root;
- every target is a regular executable file.

It then reuses the existing facility-cmd materialization rather than introducing a second command projection format.

### 10. Environment proof

Candidate contract:

```text
facility/java/25/env/
    JAVA_HOME
```

Provider realization remains conceptually:

```text
facility-env/java
    JAVA_HOME<TAB>root
```

The env handler validates:

- contract entries are valid environment names;
- `PATH` remains forbidden;
- provider realization contains exactly the required variables;
- descriptors use the existing `root | root-path | literal` grammar;
- root-relative references stay inside the useful root.

It then reuses the current facility-env materialization and provider/bootstrap application semantics.

This is also an opportunity to eliminate the current duplicated env-name/path/descriptor validation logic between integration and provider application by placing the shared parsing/validation primitive in the env handler. Runtime application itself still belongs to the current owner.

### 11. Lifecycle proof

The lifecycle case should use the same generic integration lifecycle without pretending runtime execution is the same as cmd/env.

Conceptually:

```text
facility/geoserver/1/lifecycle/
    start
    stop
```

The lifecycle handler owns the meaning/content of those contract entries.

A provider realization might need to supply a concrete foreground start target while `stop` is satisfied by generic `srv` PID/SIGTERM semantics.

The lifecycle handler therefore validates the contract and provider mapping, then materializes one runtime lifecycle descriptor. `srv` consumes that descriptor; the generic facility engine never invokes start/stop itself.

If lifecycle cannot be expressed through the same three integration operations without special provider branching in the generic engine, this proposal fails its non-Java proof.

Endpoint/network metadata remains intentionally outside this proposal until lifecycle alone is proven. It is not necessary to validate the typed-part mechanism.

### 12. Why this boundary is preferred

This proposal avoids both extremes:

```text
too little abstraction:
    pkg-integration hardcodes cmd, env, lifecycle, endpoint, ...

too much abstraction:
    every part must implement one fake generic runtime apply operation
```

Instead:

```text
generic facility layer
    owns discovery + conformance orchestration + materialization dispatch

typed handler
    owns its schema and mechanical semantics

runtime owner
    owns actual operation
```

This is the smallest common boundary visible in the current implementation and the GeoServer stress case.


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
- lib/sys/sh/pkg/facility/pkg-dependency.lib.sh
- lib/sys/sh/pkg/facility/pkg-facility.lib.sh
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

Phase 1 is now narrowed to the typed-part implementation/representation question.

Already promoted:

- compatibility levels are independent exact contracts; there is no monotonic-lineage rule;
- provider declarations identify one exact contract level;
- consumer constraints alone express exact/range acceptance;
- `pkg` does not infer backward compatibility;
- every level is complete/self-contained and semantically immutable;
- the baseline contract contains required interoperable members only;
- provider conformance uses the same catalog snapshot as the package definition;
- runtime does not refetch the facility contract.

Still open:

- concrete typed-part implementation boundary/API;
- exact physical contract representation and member descriptor formats;
- lifecycle/endpoint proof through the GeoServer case.

Do not begin Phase 4 until the remaining typed-part representation is sufficiently settled and promoted.

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

Phases 2 and 3 remain complete.

Phase 1 has materially advanced. The compatibility and contract-evolution semantics, required-only surface and conformance lifecycle are now canonical in `PACKAGE-MODEL.md`.

The former monotonic-lineage proposal is superseded. A facility level may change radically from another level of the same facility. Backward compatibility is represented only by the acceptance constraints declared by consumers; it is not a property inferred or enforced by `pkg`.

The current product already matches an important part of this direction mechanically: installed providers declare one exact facility compatibility and dependency declarations support exact and ordered constraints that can be combined into bounded ranges. That existing behavior is evidence, not authority, and later implementation must add exact-level contract validation rather than introduce monotonicity checks.

The remaining architecture gate is the typed-part implementation and its catalog representation. No Phase-4 runtime/catalog conformance implementation has begun.

## Next action

Review the concrete typed-part proposal in Working design with the user.

If accepted, promote the stable generic rules into `PACKAGE-MODEL.md`, then design the exact `pkg_integrate` catalog-context interface and only afterward begin Phase 4 refactoring/implementation.

## Blockers / open questions

Phase 1 now has a concrete typed-part proposal recorded in Working design. User review remains required before promotion.

The main decision points are:

- accept the three-operation integration interface: contract validation, realization validation, realization materialization;
- accept trusted built-in type dispatch rather than dynamic catalog/plugin code;
- accept the generic contract envelope `facility/<facility>/<compatibility>/<part>/...`;
- keep current `facility-cmd` and `facility-env` provider/runtime representations instead of renaming them for symmetry;
- make the catalog snapshot/root explicit integration context rather than deriving it from paths;
- use lifecycle as the non-Java proof while postponing endpoint metadata.

Explicitly resolved and no longer blockers:

- no monotonic compatibility lineage;
- no inferred backward compatibility;
- exact provider facility level plus consumer exact/range constraints;
- complete self-contained immutable contracts;
- required-only baseline contract surface;
- install/integration conformance against the same catalog snapshot;
- no runtime catalog refetch.

A later concrete need for non-contiguous consumer acceptance sets or one provider advertising multiple exact contract levels would require separate design. Neither is introduced preemptively by the current baseline.

Later user decisions remain deferred behind Phase 1:

- missing dependency provider behavior;
- install-time provider configuration UX;
- GraalVM additional facility boundaries after artifact inventory.

Known later work remains blocked/pending:

- generalized contract/conformance implementation and tests;
- global provider environment/projection regression completion;
- NetBeans realignment;
- GraalVM capability inventory;
- GitHub rate-limit robustness;
- final exact-revision validation.
