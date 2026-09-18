# Package provider/facility realignment

Status: Active
Updated: 2026-09-18

## Goal

Realign package/provider/facility semantics and their catalog/test representation. Package identity and facility separation are implemented; multiple-provider installation/indexing coexistence is implemented and validated. Consumer resolution among multiple eligible providers remains coupled to the still-open provider selection/binding design.

## Current repository revisions

```text
rumiai-dev    0b019fbe41881eafa2f11d7b7452804446f94995
rumiai-os     25ab0e5a5b8267af715f320bd9ee17405a2b41f6
rumiai-tests  9c0d7e7c51c179e3cac72475bcbed8017f7ebe65
pkg-catalog   63140dcbbf89d93a924a4ac61ec967a4fe1b6d08
```

The `rumiai-dev` SHA is the canonical-source baseline re-read before this handoff synchronization.

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`

## Fixed task-local choices

None. Package identity/facility coexistence and provider selection/binding/dependency policy are now promoted current contract in `PACKAGE-MODEL.md`.

## Working design

The remaining package-design work is narrower than the previous checkpoint:

- define the exact storage/layout and public configuration surface for facility defaults and per-consumer bindings;
- define the facility-specific runtime projection format that associates provider commands and environment with the facility they implement;
- determine the concrete command/environment projection for Temurin/GraalVM and the broader GraalVM facility surface;
- redesign semantic package tests around mutable selectors and runtime re-resolution after the implementation contract is fixed.

Provider installation vs selection, binding precedence, selector semantics, absence of implicit single-provider fallback, baseline no-auto-install policy, runtime re-resolution and the distinction between package default and facility default are no longer working design; they are current canonical package contract.

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

Provider coexistence is implemented and validated, and `PACKAGE-MODEL.md` now also defines the target provider-selection/binding semantics.

Implementation is not yet aligned with that promoted contract:

- current dependency resolution still scans installed providers, chooses the highest compatible facility compatibility and requires exactly one provider at that compatibility through `pkg_dependency_best_count == 1`;
- integration still materializes `binding/<facility>` as an exact resolved concrete selected during install;
- the current launcher applies package/user environment only and does not re-resolve mutable facility defaults/bindings or apply facility-specific provider projection at runtime.

Therefore the canonical package contract is ahead of `rumiai-os` for provider selection/binding/runtime projection.

A validation-only branch `validation/provider-facility-20260918` remains in `rumiai-tests`; its workflow is not on main and is not product/test-suite content.

## Next action

Define the smallest concrete storage/public-interface and facility-runtime-projection contract needed to implement the already-promoted provider selection semantics. Then realign dependency integration and launch behavior: replace the single-provider scan/uniqueness rule with effective-selector resolution, preserve selector intent rather than install-time exact binding, and apply/validate the selected provider projection at runtime.

## Blockers / open questions

- exact state/configuration layout and public command surface for facility defaults and consumer bindings;
- exact facility-specific command/environment projection format;
- exact Temurin/GraalVM projection and broader GraalVM facility/command surface;
- proportional semantic test redesign for mutable selectors/runtime re-resolution.

The baseline dependency-installation policy is no longer open: `pkg install` does not auto-install or silently choose a missing provider.
