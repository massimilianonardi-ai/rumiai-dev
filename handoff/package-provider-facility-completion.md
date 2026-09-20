# Package provider/facility completion

Status: Complete
Updated: 2026-09-20

## Goal

Finish the remaining package-provider/facility work after promotion and implementation of the canonical provider-independent facility model.

This handoff owns package/facility work only. Portable/service lifecycle work remains owned by `handoff/service-model.md`.

## Current repository revisions

Final closure checkpoint:

```text
rumiai-dev      128901b65da3b77c41df6240d1aae1e7efc4c010  pre-completion HEAD
rumiai-os       6940b3304f8da5b559d0bf91aa37cd5e3ffa2454
rumiai-tests    6a62e876652fa3fc9a9f8e04c50d600407c49232
pkg-catalog     12ea704ee4e25e62ab3ed0125133660b4e0c42cb
rumiai-dev-PoCs cb8c5d636ce65e6cb00626ed08947fe25a25988e
```

The exact final package-task validation target is:

```text
rumiai-os@ffcc9d047ae467b6acb5c6013ea5705d102a6621
rumiai-tests@6a62e876652fa3fc9a9f8e04c50d600407c49232
```

Current `rumiai-os@6940b33...` is a descendant of that target and differs only in `lib/sys/sh/enc.lib.sh`, outside this task's package/provider/facility surface.

## Applicable canonical sources

Use the normal mandatory read order and, for this task, the smallest complete current set includes:

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
handoff/service-model.md
```

Current implementation and permanent tests are authoritative only as mechanical evidence beneath those contracts.

## Fixed task-local state

Durable semantics are canonical in `PACKAGE-MODEL.md`; this handoff records only active task state that matters for resumption.

- Eclipse Temurin is concrete package `temurin`; GraalVM is a distinct concrete package. Both currently provide facility `java 25`.
- Maven, Keycloak and NetBeans are provider-independent Java consumers. They must not hardcode Temurin/GraalVM selection or construct provider-specific `JAVA_HOME` from concrete package identities.
- Provider selection remains explicit: consumer binding overrides facility default; absent both, dependency resolution fails.
- Package installation and provider selection remain separate. The baseline does not auto-install or silently choose a missing dependency provider.
- Facility/provider declarations and conformance are inert with respect to defaults/bindings.
- Current trusted facility parts are `cmd`, `env` and `service`; service operation remains owned by `srv`.
- Package definitions and facility contracts come from the same immutable `pkg-catalog` snapshot for install-time conformance.
- `pkg-provider.lib.sh` remains the provider configuration/selection API directly under `lib/sys/sh/pkg/`; trusted facility handlers remain under `lib/sys/sh/pkg/facility/`.
- No new facility or provider abstraction is introduced merely for symmetry.

## Implemented state

### Facility/provider core

The generalized facility model is implemented:

```text
lib/sys/sh/pkg/facility/
    pkg-facility.lib.sh
    pkg-facility-cmd.lib.sh
    pkg-facility-env.lib.sh
    pkg-facility-service.lib.sh
    pkg-dependency.lib.sh
```

The generic layer validates the exact facility contract, dispatches only trusted part handlers, validates provider realization against the same catalog snapshot and rejects unknown contract parts/provider realization surfaces.

Normal `pkg install` performs provider conformance after extraction and before package-store mutation. Runtime does not reread `pkg-catalog`.

The older cmd/env checks inside package integration still coexist with the generalized conformance boundary. Removing that duplication is cleanup only if it can be done without changing current validation/materialization semantics.

### Provider selection and runtime projection

Current provider semantics are implemented and protected:

- facility defaults and consumer bindings use the same provider-selector grammar;
- unversioned selectors late-bind through package default; versioned selectors remain pinned;
- there is no implicit fallback to a sole installed provider;
- consumer launch re-resolves dependencies and applies selected provider command/environment projections;
- global facility command publication follows facility-default selector intent;
- global publication protects unrelated command-path collisions and rolls back rejected mutations;
- every new `m` bootstrap derives global facility environment from currently resolvable facility defaults;
- consumer bindings do not alter global command/environment publication;
- a configured but currently unresolved facility default preserves selector intent and contributes no global environment.

The permanent `facility-default-global.test` exercises unversioned following, pinning, command-set reconciliation, collision rollback, binding independence, package-class disappearance/reappearance and bootstrap environment projection.

### Java contract/providers

The provider-independent `java 25` contract exists under:

```text
facility/java/25/
```

Temurin and GraalVM both declare and realize `java 25` with the required command/environment surface.

Real live validation now proves:

- Temurin installs and realizes `java 25`;
- GraalVM installs and realizes `java 25`;
- Temurin and GraalVM coexist as independent providers of the same facility;
- Maven consumes `java >=17` through the generic provider mechanism;
- Keycloak consumes `java =25` through the generic provider mechanism;
- NetBeans consumes `java =25` through the generic provider mechanism.

NetBeans has been realigned completely away from the superseded concrete-provider mechanism:

- all package-range `env` scripts that read `binding/java` and manually constructed `JAVA_HOME` were removed from `pkg-catalog`;
- the live test now installs Temurin, configures the `java` facility default, installs NetBeans and verifies no installed concrete binding or provider-specific package env exists;
- the installed dependency remains provider-independent `java =25`.

### Service bridge

The generic `service` typed part and provider-backed `srv` bridge are implemented but owned by `handoff/service-model.md`.

Package work must not recreate a separate service/provider graph.

## Formal validation evidence

All evidence below is revision-specific.

### Provider/facility/service baseline

GitHub Actions run:

```text
35495425634
```

Formal `rumiai-validate package-provider-facility` result:

```text
rumiai-tests@aa7ff12a0ecb63ef2b83f26576df19eff424da27
rumiai-os@b18d0fc804814c7b99e841df6f5d1fc22d2e5a90
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

All required selections passed with no required SKIP. Session and aggregate validation records were published through the normal `rumiai-validate` evidence mechanism.

### Java consumers after NetBeans realignment

GitHub Actions run:

```text
35495727155
```

Formal scope:

```text
package-provider-facility
```

Exact suite/target:

```text
rumiai-tests@f4b46a079d81cc15bdc0eb9fa215ba1c1f652444
rumiai-os@b18d0fc804814c7b99e841df6f5d1fc22d2e5a90
```

Results:

```text
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

The scope includes real live installs of Temurin, NetBeans, Keycloak and Maven plus provider/dependency/env/facility/integration/launcher/service regression selections. No required test was skipped.

### GraalVM coexistence

GitHub Actions run:

```text
35495961261
```

Formal scope:

```text
package-provider-facility-graalvm
```

Exact suite/target:

```text
rumiai-tests@e31641259396b6ce503df1283fed4a5b186e5596
rumiai-os@b18d0fc804814c7b99e841df6f5d1fc22d2e5a90
```

Linux/x86_64 result:

```text
external/graalvm/install-live.test                 PASS
external/graalvm/temurin-coexistence-live.test    PASS
Scope result                                      VALIDATED
```

This scope is deliberately Linux-only because the coexistence test is currently defined only for Linux/x86_64; it is not placed in a cross-host task scope where a required SKIP would invalidate the task.

GitHub-hosted formal validation is not physical validation of the stable reference hosts.

### Final deterministic package-task closure

GitHub Actions run:

```text
35498298186
```

Formal scope:

```text
package-provider-facility-final
```

Exact suite/target:

```text
rumiai-tests@6a62e876652fa3fc9a9f8e04c50d600407c49232
rumiai-os@ffcc9d047ae467b6acb5c6013ea5705d102a6621
```

Results:

```text
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

All required selections passed with zero FAIL, zero ERROR and zero required SKIP. The scope covered real Temurin/Maven installation plus provider, dependency, environment, facility-contract/default, integration, launcher, service and current GitHub/GraalVM/NetBeans/Node.js repository-adapter regressions. `rumiai-validate` published revision-specific session and aggregate validation evidence.

GitHub-hosted formal validation is not physical validation of the stable reference hosts.

## Completion state

All package/provider/facility work owned by this handoff is complete.

Durable semantics are already in canonical specifications and current implementation/tests. Remaining non-blocking follow-up work is owned elsewhere:

- optional GitHub repository authentication: `todo/github-package-repository-authentication.md`;
- duplicate legacy cmd/env integration validation cleanup: `todo/pkg-facility-integration-validation-dedup.md`;
- portable/service real-provider and host-supervision work: `handoff/service-model.md`.

No additional GraalVM facility is introduced by this task because no current consumer establishes a provider-independent/substitutable contract for GraalVM-specific extras.

## No longer open

The following items were previously listed as pending but are already settled by current canonical specification and implementation and must not be reopened as decision gates:

- missing-provider baseline: no automatic provider installation or silent provider choice;
- install-time provider-selection UX: install does not create defaults/bindings; selection is a separate explicit operation;
- global facility command publication semantics;
- global bootstrap facility-environment semantics;
- Java consumer provider independence;
- NetBeans provider realignment;
- Temurin/GraalVM provider coexistence;
- generic service bridge mechanics.

## Next action

Remove this completed handoff in the next forward commit. Git history preserves this completion snapshot.

## Blockers / open questions

None for this completed task.

Physical stable-host validation was not performed for this package-task closure; the final formal evidence is GitHub-hosted Linux/x86_64 and Darwin/arm64 validation.
