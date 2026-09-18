# Package provider/facility realignment

Status: Active
Updated: 2026-09-18

## Goal

Realign package/provider/facility semantics and their catalog/test representation. Package identity and facility separation are implemented; multiple-provider installation/indexing coexistence is implemented and validated. Consumer resolution among multiple eligible providers remains coupled to the still-open provider selection/binding design.

## Current repository revisions

```text
rumiai-dev    0e5c1db12bbfada4731f40177045f99a688cf950
rumiai-os     25ab0e5a5b8267af715f320bd9ee17405a2b41f6
rumiai-tests  9c0d7e7c51c179e3cac72475bcbed8017f7ebe65
pkg-catalog   63140dcbbf89d93a924a4ac61ec967a4fe1b6d08
```

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`

## Fixed task-local choices

None. The settled identity/facility/coexistence rules were promoted to `PACKAGE-MODEL.md`.

## Working design

The following points remain unresolved and are not current contract yet:

- provider/default selection may govern public command exposure, but environment such as `JAVA_HOME` makes the problem broader than command links alone;
- a consumer package can bind to a specific provider independently of a global/default provider (for example Maven could bind Temurin while NetBeans binds GraalVM);
- users may select/change defaults at install time or later, bind a specific provider to a specific consumer package, and/or configure ordered or compatibility-aware provider preferences;
- package command exposure for Temurin/GraalVM and the broader GraalVM facility set still require design;
- dependency auto-install behavior is not established; current `pkg install` does not install missing providers automatically;
- semantic package tests need a broader redesign after provider selection/binding behavior is specified.

## Completed

- `PACKAGE-MODEL.md` now separates concrete package identity from facility identity and defines multiple installed providers of the same facility/compatibility as valid.
- `pkg-catalog` renamed the Eclipse Temurin package from `java` to `temurin` on all declared platforms without changing its `java 25` facility declaration.
- GraalVM continues to declare `java 25`; Temurin and GraalVM therefore represent distinct packages providing the same facility.
- Permanent tests were realigned:
  - `external/java/install-live.test` became `external/temurin/install-live.test`;
  - Maven and Keycloak setup now explicitly install/query `temurin`;
  - `external/graalvm/temurin-coexistence-live.test` installs both providers in one real target and verifies both package identities remain installed/queryable.
- Static scans found no remaining current `pkg install java` or `external/java` references in `rumiai-dev` or `rumiai-tests`.
- Live GitHub Actions run `35372329744` succeeded on Ubuntu 24.04 using:
  - `rumiai-os@25ab0e5a5b8267af715f320bd9ee17405a2b41f6`;
  - `rumiai-tests@9c0d7e7c51c179e3cac72475bcbed8017f7ebe65`;
  - observed `pkg-catalog@63140dcbbf89d93a924a4ac61ec967a4fe1b6d08`.
- That run executed, without SKIP:
  - Temurin install: `temurin@25.0.4.1+1!linux-x86_64`;
  - Temurin + GraalVM coexistence: `temurin@25.0.4.1+1!linux-x86_64` and `graalvm@25.3.4.1!linux-x86_64`;
  - Maven with Temurin provider;
  - Keycloak with Temurin provider.
- Earlier temporary validation run `35372232189` is not evidence because all selected tests SKIPPED; the final run deliberately made SKIP fail the validation.

## Current state

Points 1 and 2 are implemented and validated. For point 3, installation/indexing coexistence is implemented and validated: current facility indexing accepts multiple provider markers. Point 3 is not closed end-to-end because current dependency resolution still requires exactly one best provider (`pkg_dependency_best_count == 1`); resolving that ambiguity without arbitrary provider choice requires the provider selection/binding contract from the next design step.

A validation-only branch `validation/provider-facility-20260918` remains in `rumiai-tests`; its workflow is not on main and is not product/test-suite content.

## Next action

Resume with provider selection/binding semantics before changing Temurin/GraalVM command exposure. Define how global/default choice, per-consumer binding, compatibility constraints/preferences and environment projection such as `JAVA_HOME` interact, then remove the resolver's single-provider assumption according to that contract.

## Blockers / open questions

- provider selection/default semantics and replacement of the current `pkg_dependency_best_count == 1` uniqueness gate;
- per-consumer provider binding;
- command and environment projection for selected providers;
- exact GraalVM facility/command surface;
- dependency installation policy;
- semantic test redesign for the completed provider model.
