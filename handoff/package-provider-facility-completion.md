# Package provider/facility completion

Status: Active
Updated: 2026-09-19 21:15 +02:00

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

## Active implementation scope

The user accepted the typed-part proposal with one explicit correction: this phase must stay focused on **facility contracts and provider realizations**. Binding/default configuration, bootstrap environment application and other runtime selection/application behavior are separate later work.

The accepted core is now canonical in `PACKAGE-MODEL.md`:

```text
facility contract
    exact provider-independent required surface

provider realization
    concrete declarative mapping supplied by one package

facility/provider conformance
    trusted RumiAI validation of contract + realization
```

Definitions and validation are inert. They do not create defaults or bindings and do not apply environment or commands.

The current implementation work unit is therefore limited to:

- generic facility contract envelope validation;
- trusted built-in dispatch for supported part types;
- `cmd` contract/provider validation;
- `env` contract/provider validation;
- whole-provider conformance against exact facility contracts;
- the first real `java 25` facility contract in `pkg-catalog`;
- permanent tests for those properties;
- library/manual consistency for the facility libraries.

The following are **not** part of this work unit:

- changing `pkg_integrate` or deciding when package installation invokes conformance;
- creating or changing facility defaults;
- creating or changing consumer bindings;
- applying provider environment in bootstrap/launcher;
- global command publication;
- lifecycle/service implementation;
- endpoint metadata.

Existing behavior for those areas remains unchanged until its own explicitly resumed phase.

### Implementation boundary

The generic facility library should own facility identity/compatibility parsing, exact contract lookup/envelope validation, supported-part enumeration/dispatch and whole-provider conformance.

Type-specific trusted handlers should live directly under the existing facility responsibility group:

```text
lib/sys/sh/pkg/facility/
    pkg-facility.lib.sh
    pkg-dependency.lib.sh
    pkg-facility-cmd.lib.sh
    pkg-facility-env.lib.sh
```

No deeper grouping is introduced.

The generic contract envelope is:

```text
facility/<facility>/<compatibility>/<part>/...
```

Current supported parts are `cmd` and `env`. Unknown parts fail validation. Catalog data cannot provide executable handler code.

Provider realization remains in the existing shapes:

```text
facility-cmd/<facility>/...
facility-env/<facility>
```

The current work should expose one coherent facility/provider conformance responsibility without introducing a generic runtime `apply` abstraction.

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

The typed-part architecture gate is resolved and promoted. Implementation is now active only for facility/provider contract and conformance primitives; selection/default/binding/bootstrap composition remains deliberately untouched.

## Next action

Implement and validate the accepted facility/provider core: trusted `cmd`/`env` handlers, generic exact-contract/provider conformance, the real `java 25` contract and permanent tests.

Do not wire the new conformance API into installation, defaults, bindings, bootstrap or launcher in this work unit.

## Blockers / open questions

There is no remaining Phase-1 semantic blocker for the facility/provider core.

Explicitly deferred by current user direction:

- when/how package installation invokes facility/provider conformance;
- how facility defaults and consumer bindings are created or assisted from catalog/provider definitions;
- any changes to bootstrap/global environment or command publication;
- lifecycle and endpoint typed-part schemas;
- missing-provider/install-time configuration policy;
- GraalVM additional facility boundaries after artifact inventory.

The existing installation/default/binding/bootstrap behavior is not redefined by this work unit. Any mismatch exposed while implementing the isolated facility/provider core must be recorded rather than silently resolved by expanding scope.
