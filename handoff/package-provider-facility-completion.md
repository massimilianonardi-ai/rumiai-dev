# Package provider/facility completion

Status: Active
Updated: 2026-09-19 10:40 +02:00

## Goal

Finish the RumiAI package provider/facility model as one coherent task across rumiai-dev, rumiai-os, rumiai-tests, pkg-catalog and the relevant PoCs.

This task owns the remaining work around package identity, facilities, multiple providers, facility defaults, consumer bindings, provider selectors, dependency behavior, runtime projections, global facility publication, Temurin/GraalVM, all Java consumers, GitHub-backed package reliability and final semantic/live validation.

Services remain out of scope and stay owned by handoff/service-model.md.

## Current repository revisions

Fresh activation preflight used:

rumiai-dev      322902bfaa570760b31e959c54fcc886d97ca8f7
rumiai-os       1f4a4a8b62ed41042e4178b11f74f54ad291aadb
rumiai-tests    9960eafb4d803211620f2975ffaef703c3fb8625
pkg-catalog     bd06488d3c67160e820c04d13067f852c8861c32
rumiai-dev-PoCs cb8c5d636ce65e6cb00626ed08947fe25a25988e

The rumiai-dev revision above is the baseline read before this activation commit. Fresh HEAD retrieval remains mandatory before every later write.

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

- handoff/library-subsystem-subdirectories.md
- handoff/rumiai-tests-suite-realignment.md
- handoff/service-model.md

The deferred item todo/github-package-repository-rate-limits.md is activated into this task by the same commit that creates this handoff and must no longer exist as a duplicate TODO.

## Fixed task-local choices

These come from explicit user direction and must survive deletion of the chat.

1. Eclipse Temurin is a concrete package named temurin. java is a facility, not the package identity for Temurin.
2. GraalVM is a separate package and may provide the same java facility.
3. Multiple providers of one facility are a normal installed state.
4. Consumer binding is configuration under the consumer system conf area at binding/<facility>.
5. If that binding file does not exist, the consumer inherits the system facility default.
6. A consumer binding can change at any time without reinstalling the consumer.
7. A selector such as temurin is late-bound through the package default; a versioned selector such as temurin@<version> is pinned.
8. Runtime provider application is generic launcher behavior. Maven, NetBeans, Keycloak and other consumers must not contain provider-specific provider lookup or hardcoded Java-provider environment logic.
9. A provider exposes facility commands and facility environment.
10. The user explicitly stated that the provider selected as a facility default should expose its commands through the appropriate bin roots and its environment in the bootstrap.
11. Services stay out of this task.

Important authority mismatch: current PACKAGE-MODEL.md now says facility-default global publication exposes commands but does not inject facility-env into ambient m/bootstrap state. That conflicts with item 10 above. The user instruction has higher authority. The next task must realign the canonical specification and implementation unless the user explicitly changes that requirement.

## Canonical model already settled

Do not reopen these points unless a current contradiction is found. PACKAGE-MODEL.md already defines:

- package identity versus facility identity;
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

The commands-only global environment rule is the known mismatch described above.

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

### A. Global facility environment

User direction requires the facility-default provider environment in bootstrap/global environment. Current spec and implementation are commands-only globally.

This is the highest-priority semantic mismatch.

Before implementation, define deterministic rules for:

- when global facility environment is computed;
- how PATH contributions are ordered;
- collision/precedence when multiple facility defaults export the same variable;
- what changes when a facility default or provider package default changes;
- behavior of already-running versus newly bootstrapped processes;
- generic versus osarch provider classes.

If repository analysis leaves more than one materially different semantic model, ask the user only that specific unresolved choice.

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

### Phase 0: resume and reconcile

- fetch fresh HEADs for all involved repositories;
- read mandatory sources and this handoff;
- reconcile concurrent movement forward;
- check overlapping active handoffs only where they touched the same files/tests.

Exit: one coherent current baseline.

### Phase 1: bootstrap environment realignment

- treat the user requirement for global default-provider environment as the pending authoritative correction;
- analyze BOOTSTRAP-ENVIRONMENT and current m bootstrap;
- settle deterministic variable/PATH precedence and lifecycle;
- update canonical specification before dependent runtime changes;
- implement and add permanent tests.

Exit: user direction, PACKAGE-MODEL, BOOTSTRAP-ENVIRONMENT and runtime agree.

### Phase 2: global command projection regression coverage

- add property-focused permanent tests for all transitions listed in section B;
- run them against the current implementation before changing that implementation further;
- fix only evidenced failures.

Exit: global command publication has durable regression proof.

### Phase 3: Java consumer completion

- realign NetBeans;
- scan all catalog/tests for old java package identity, concrete binding/java reads and consumer-specific Java provider logic;
- validate Maven, Keycloak and NetBeans through the same generic mechanism;
- exercise coexistence and at least one explicit binding override.

Exit: all current Java consumers use generic provider machinery.

### Phase 4: user policy gate

Ask Decision 1 and Decision 2 if not yet answered.

Then specify and implement only the selected policy. Do not invent provider preference or transaction semantics.

Exit: dependency installation and install-time provider configuration are unambiguous.

### Phase 5: GraalVM facilities

- inventory real artifacts per platform;
- present only genuine facility-boundary choices;
- implement accepted facility metadata/projection/tests.

Exit: GraalVM neither under-reports accepted base capabilities nor claims absent components.

### Phase 6: GitHub rate-limit robustness

- analyze current GitHub-backed adapters starting with GraalVM;
- distinguish metadata API limits from downloads;
- preserve digest/integrity checks;
- add deterministic adapter coverage for rate-limit responses;
- keep live tests classified as upstream-sensitive evidence.

Exit: rate limiting has predictable product/test behavior.

### Phase 7: final validation

At minimum run, against exact final revisions:

- structural provider tests;
- global command projection tests;
- bootstrap/global environment tests;
- Temurin install/projection;
- GraalVM install/projection;
- Temurin plus GraalVM coexistence;
- Maven Java dependency/runtime;
- Keycloak Java dependency/runtime;
- NetBeans Java dependency/runtime;
- package-default/facility-default transitions;
- pinned versus unversioned selectors;
- relevant Linux and macOS layouts;
- Windows where executable infrastructure exists, otherwise state exact unvalidated surface;
- rate-limit adapter tests.

### Phase 8: consistency and closure

- reread all changed diffs;
- reread authoritative specs;
- scan for superseded names/mechanics;
- verify command/library manual completeness and public/internal visibility;
- reconcile concurrent HEAD movement;
- resolve all working design by promotion, deliberate discard or separate deferred ownership;
- write Status: Complete snapshot;
- commit it;
- remove this handoff in a later forward commit.

## Completion criteria

Do not close this task until all applicable conditions hold:

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

The architecture is substantially implemented but not complete.

Green revision-specific provider validation exists for the pre-global-command implementation. Current product contains the later global command projection implementation. Current catalog contains corrected Temurin/GraalVM Java projections and corrected wrappers. Current tests cover most selector/runtime behavior.

The principal remaining blockers are:

1. global facility environment user-direction/spec mismatch;
2. missing permanent proof for current global command projection;
3. stale NetBeans provider integration;
4. unresolved dependency/install policy choices;
5. incomplete GraalVM facility surface;
6. GitHub rate-limit robustness;
7. final exact-current validation.

## Next action

In a clean new chat:

1. perform mandatory fresh preflight;
2. read this handoff;
3. reconcile repository movement;
4. start Phase 1 and Phase 2;
5. realign NetBeans once the provider baseline is green;
6. before Phase 4, ask the user Decision 1 and Decision 2 exactly as above.

Do not ask the user to reconstruct this deleted conversation.

## Blockers / open questions

User decisions still required:

- explicit-only versus assisted versus automatic missing-provider resolution;
- separate provider configuration versus explicit install-time default/binding syntax;
- after GraalVM inventory, only facility naming/boundary choices that remain semantically ambiguous.

Non-user work still required:

- canonical bootstrap environment realignment;
- global projection regression tests;
- NetBeans realignment;
- GraalVM inventory;
- GitHub rate-limit implementation/test work;
- final exact-revision validation.
