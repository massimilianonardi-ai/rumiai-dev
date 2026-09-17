# RumiAI OS — `mk` development lifecycle

Status: **Current / normative**  
Updated: 2026-09-17

## 1. Role

`mk` is the technical subsystem of `m` responsible for management and orchestration of the development lifecycle of a project.

It coordinates the project-level flow from declarative project description through development requirements, lifecycle operations and development outputs.

`mk` does not replace compilers, interpreters, external build engines or `pkg`; it orchestrates external tools and technical facilities through modular boundaries.

## 2. Ownership and subsystem boundary

`mk` belongs to the general-purpose technical substrate `m`.

It MUST NOT semantically depend on the branded RumiAI layer.

`pkg` remains a distinct `m` subsystem. `mk` owns development-lifecycle orchestration; `pkg` owns package management and package integration.

A project lifecycle may consume software provided through `pkg`, and development output produced by `mk` may later be consumed by package integration. Neither subsystem becomes a synonym for the other.

## 3. Declarative configuration boundary

Project configuration consumed by `mk` MUST be structured declarative data.

Configuration MUST NOT be shell-sourced, `eval`ed or otherwise interpreted as executable configuration merely in order to describe a project.

Parsing project configuration is therefore distinct from executing project tools or project-defined lifecycle actions.

This specification does not prescribe a concrete serialization syntax or configuration pathname.

## 4. Projects, profiles and lifecycle responsibilities

Projects and profiles are first-class concepts in the current `mk` lifecycle model.

The lifecycle must be capable of representing at least:

```text
project configuration
→ selected profile/configuration
→ requirements and dependencies
→ development environment
→ lifecycle operations
→ development outputs
```

Build, test, run, clean and production of development outputs are `mk` lifecycle responsibilities.

General lifecycle orchestration responsibilities SHOULD remain separate from tool-specific integration. Compilers, interpreters, external build engines and other development tools SHOULD be integrated through stable modular boundaries rather than accumulated as unrelated hard-coded special cases in one monolithic core.

Existing standard formats, protocols and tool interfaces SHOULD be preferred when they satisfy the required contract.

This specification does not define the complete public lifecycle CLI, graph representation, plugin/adapter API, incremental-execution model or parallel-execution model.

## 5. Workspace, state and outputs

When `mk` introduces managed RumiAI state for lifecycle operations, that state MUST use the current `state-path` contract and semantic state selectors rather than reconstructing the physical state tree.

Development output is distinct from package installation. Building or testing a project does not by itself publish that project as an installed package.

Generated documentation artifacts are development outputs under the same principle. Their later distribution location and runtime ownership are defined by the subsystem that consumes them.

## 6. Documentation build ownership

Documentation generation is a build/output responsibility when a project defines source documentation that must be transformed into distributable or publishable artifacts.

For the RumiAI documentation model, `mk` owns orchestration of documentation builds that produce selected channel-specific artifacts.

This ownership does not make a documentation renderer or generator part of the `mk` core. Such tooling remains external build tooling coordinated through the same general lifecycle boundary as other compilers or build engines.

The documentation source model and rendering toolchain are governed by the documentation subsystem contract rather than by this specification unless and until a promoted cross-subsystem contract explicitly assigns additional responsibility to `mk`.

## 7. Current source-materialization capability

The already implemented source-materialization capability remains current and is specified by:

```text
MK-SOURCE-MATERIALIZATION.md
```

That specification defines the exact behavior of the currently implemented `mk materialize` capability. It is one current capability within the broader `mk` lifecycle subsystem and does not define the complete lifecycle model.

The current shell implementation of that capability does not establish the implementation runtime of the broader `mk` subsystem.

## 8. Specification boundary

Only the promoted constraints stated in this document are part of the current `mk` lifecycle contract.

Choices that remain under active evaluation — including implementation-runtime selection, concrete configuration serialization, candidate file formats, detailed CLI shape and other unresolved design decisions — are active task state and MUST NOT be inferred from this specification.

Their persistent working state belongs in the active `mk` handoff until an individual choice passes the specification promotion gate defined by `CONSISTENCY-GATE.md`.

## 9. Invariants

```text
MK-01  mk belongs to the m technical layer
MK-02  mk owns project development-lifecycle management and orchestration
MK-03  mk consumes structured declarative project configuration and does not shell-source/eval configuration as code
MK-04  projects and profiles are first-class lifecycle concepts
MK-05  mk orchestrates external compilers, interpreters, build engines and pkg rather than replacing them
MK-06  build, test, run, clean and production of development outputs are mk lifecycle responsibilities
MK-07  mk-managed RumiAI state resolves through state-path
MK-08  MK-SOURCE-MATERIALIZATION.md defines an implemented mk capability without defining the complete lifecycle subsystem
MK-09  RumiAI documentation build orchestration is an mk lifecycle responsibility while rendering tooling remains externally selectable
```
