# RumiAI OS — `mk` development lifecycle

Status: **Current / normative**  
Updated: 2026-09-17

## 1. Role

`mk` is the technical subsystem of `m` responsible for the complete management and orchestration of the development lifecycle of a project.

It interprets structured declarative configuration, manages projects and profiles, resolves and orchestrates development requirements and dependencies, coordinates external tools, manages development workspace/state/output, and performs lifecycle operations such as build, test, run, clean and production of outputs required by later consumers.

`mk` does not replace compilers, interpreters, external build engines or `pkg`; it orchestrates them through modular boundaries.

Complete lifecycle ownership means that `mk` owns development orchestration. It does not mean that `mk` internally reimplements every tool used by a project.

## 2. Ownership and subsystem boundary

`mk` belongs to the general-purpose technical substrate `m`.

It MUST NOT semantically depend on the branded RumiAI layer.

`pkg` remains a distinct `m` subsystem. `mk` owns development-lifecycle orchestration; `pkg` owns package management and package integration.

A project lifecycle may consume software provided through `pkg`, and an output produced by `mk` may later be handed to package integration. Neither subsystem becomes a synonym for the other.

## 3. Declarative configuration boundary

Project configuration consumed by `mk` MUST be structured declarative data.

Configuration MUST NOT be shell-sourced, `eval`ed or otherwise interpreted as executable configuration merely in order to describe a project.

Parsing project configuration is therefore distinct from executing project tools or project-defined lifecycle actions.

The exact configuration pathname, serialization format, schema, composition/overlay rules and validation model are not fixed yet.

## 4. Modularity, standardization and flexibility

`mk` is designed to maximize modularity, standardization and flexibility without collapsing configuration into executable code.

General lifecycle orchestration responsibilities SHOULD remain separate from tool-specific integration. Compilers, interpreters, external build engines and other development tools SHOULD be integrated through stable modular boundaries rather than accumulated as unrelated hard-coded special cases in one monolithic core.

Existing standard formats, protocols and tool interfaces SHOULD be preferred when they satisfy the required contract.

No plugin API, adapter API or extension serialization is fixed yet. Those boundaries must be derived from concrete lifecycle requirements before becoming normative.

## 5. Projects, profiles and lifecycle

Projects and profiles are first-class concepts in the intended `mk` model.

A profile represents a selected development configuration of the same project, such as configurations analogous to debug or release. The exact profile schema, composition rules and command-line selection model remain to be specified.

The lifecycle must be capable of representing at least:

```text
project configuration
→ selected profile/configuration
→ requirements and dependencies
→ development environment
→ lifecycle operations
→ development outputs
```

Build, test, run, clean and production of development outputs are established `mk` lifecycle responsibilities.

Their exact public CLI, ordering semantics, graph model, incremental behavior, parallelism and extension points remain to be specified.

## 6. Workspace, state and outputs

`mk` may require persistent and transient development state for lifecycle operations.

Any managed RumiAI state introduced by `mk` MUST use the current `state-path` contract and semantic state selectors rather than reconstructing the physical state tree.

The exact `mk` state identity/layout, build directory model, cache model, run/test workspace and output layout are not fixed yet.

Development output is distinct from package installation. Building or testing a project does not by itself publish that project as an installed package.

## 7. Implementation runtime is intentionally undecided

No implementation language or runtime is fixed for the future `mk` core.

Python and JavaScript are current candidate directions, but the decision is deliberately deferred until relevant runtime packages and package portability/relocatability behavior are sufficiently stable to evaluate bootstrap and dependency consequences.

A future Python implementation MUST NOT assume that an appropriate host Python is universally available. If Python is to be supplied through `pkg`, that package must first satisfy the required RumiAI portability and relocatability contracts; the existence of such a package is not assumed.

A future JavaScript implementation likewise requires an explicit concrete runtime decision. Node.js, Deno, GraalVM or another JavaScript-capable runtime MUST NOT be treated as interchangeable merely because each can execute JavaScript; runtime-specific behavior and package/runtime contracts must be evaluated before selection.

The current shell implementation of the source-materialization capability does not settle the future core runtime.

## 8. Structured configuration format is intentionally undecided

The project-configuration serialization format is not fixed yet.

JSON and TOML are current candidates and MUST be compared explicitly before either is adopted.

The comparison must include at least:

```text
structured-data expressiveness
unambiguous and deterministic parsing semantics
schema and validation support
human authoring ergonomics
comment and embedded-documentation needs
tooling and interoperability
parser/runtime availability
dependency footprint
coupling or bias toward a particular implementation runtime
long-term portability and stability
```

JSON is broadly neutral across the current Python and JavaScript directions and therefore provides a useful comparison baseline. TOML may provide different human-authoring advantages, but its parser/tooling consequences must be considered together with the eventual runtime choice rather than adopted implicitly.

No configuration filename, extension or physical project layout is established by this comparison yet.

## 9. Current source-materialization capability

The already implemented source-materialization capability remains current and is specified by:

```text
MK-SOURCE-MATERIALIZATION.md
```

That specification is subordinate to this broader `mk` contract. It defines the exact behavior of the currently implemented `mk materialize` capability; it does not define the complete responsibility of `mk`.

The current product implementation is therefore a partial implementation of the broader lifecycle subsystem.

## 10. Current non-decisions

This specification does not yet fix:

```text
implementation runtime or language
project configuration filename or physical location
JSON versus TOML
configuration schema
profile composition rules
public lifecycle CLI
lifecycle graph representation
adapter or plugin API
build-environment requirement serialization
project dependency serialization
workspace/state physical layout
incremental-build and cache model
parallel execution model
local package-install bridge
source-only pkg orchestration
```

These choices must be developed incrementally from concrete project lifecycle requirements rather than inferred from the historical implementation or from the current materialization baseline.

## 11. Invariants

```text
MK-01  mk belongs to the m technical layer
MK-02  mk owns complete development-lifecycle management and orchestration for projects
MK-03  mk consumes structured declarative project configuration and does not shell-source/eval configuration as code
MK-04  projects and profiles are first-class lifecycle concepts
MK-05  mk orchestrates external compilers, interpreters, build engines and pkg rather than replacing them
MK-06  build, test, run, clean and production of development outputs are mk lifecycle responsibilities
MK-07  mk-managed RumiAI state must resolve through state-path
MK-08  implementation runtime is currently undecided
MK-09  JSON versus TOML is currently undecided and requires explicit comparison
MK-10  MK-SOURCE-MATERIALIZATION.md defines a subordinate implemented capability, not the complete mk subsystem
```
