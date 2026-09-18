# Package provider/facility realignment

Status: Active
Updated: 2026-09-18

## Goal

Realign the package model/catalog/tests for the first three settled corrections:
1. concrete package identity must identify the concrete distribution/provider;
2. facilities are separate from package identity;
3. multiple installed providers of the same facility are a valid state.

## Current repository revisions

```text
rumiai-dev    f80db29d34d1c47c9071c4e87aae5c80db9b7e8b
rumiai-os     25ab0e5a5b8267af715f320bd9ee17405a2b41f6
rumiai-tests  20f04ab2665fdb0c7310226f57a12a39b701f212
pkg-catalog   8407f2308cf0c5e7bdc3abd8aeb9538410e55b90
```

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`

## Fixed task-local choices

- Eclipse Temurin is a concrete package identity and must be named `temurin`, not `java`.
- Temurin and GraalVM may both declare the facility `java 25`.
- Installing multiple providers of the same facility must be allowed; provider multiplicity itself is not a package-install conflict.

## Working design

The following points are intentionally unresolved in this work unit and are not current contract yet:

- provider/default selection may govern public command exposure, but environment such as `JAVA_HOME` makes the problem broader than command links alone;
- a consumer package can bind to a specific provider independently of a global/default provider (for example Maven could bind Temurin while NetBeans binds GraalVM);
- users may select/change defaults at install time or later, bind a specific provider to a specific consumer package, and/or configure ordered or compatibility-aware provider preferences;
- package command exposure for Temurin/GraalVM and the broader GraalVM facility set still require design;
- dependency auto-install behavior is not established; current `pkg install` does not install missing providers automatically;
- semantic package tests need a broader redesign after provider selection/binding behavior is specified.

## Completed

- Fresh preflight completed against the revisions above.
- Current catalog/implementation/tests confirmed:
  - catalog package `java` is actually Eclipse Temurin;
  - `java` and `graalvm` both currently declare `java 25`;
  - provider indexing supports more than one marker, while dependency resolution currently requires exactly one best provider;
  - existing Java/GraalVM live tests do not exercise coexistence or provider choice.

## Current state

No material repository change for this realignment has been made yet beyond this handoff.

## Next action

Rename the catalog package to `temurin`, realign affected permanent tests, then add real coexistence coverage and update the package specification for the settled identity/facility/coexistence contract.

## Blockers / open questions

None for points 1-3. Provider selection/binding and command/environment exposure remain deliberately outside this work unit.
