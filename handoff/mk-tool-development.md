# mk tool development

Status: Active
Updated: 2026-09-22

## Goal

Define and develop `mk` as the `m` subsystem responsible for project development-lifecycle management and orchestration, with modular, standardized and flexible orchestration while keeping project configuration declarative and non-executable.

## Current repository revisions

```text
rumiai-dev   e9235f673a9b035eef34380099693279af34403b  (pre-checkpoint HEAD before vocabulary working-design update)
rumiai-os    0a45bddce0318e111a72b052f7bc8366d2911b0b  (current main; unchanged by this design checkpoint)
rumiai-tests 1062ffcd51d3c66e16a4a07a1aa9d84a46a56f83  (current main; unchanged by this design checkpoint)
pkg-catalog  94f58995cbd487b17f3b82bc2724c70540927b88  (refresh before pkg-catalog work)
```

Fresh remote HEAD retrieval remains mandatory before later writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/CURRENT-MODEL.md
specifications/rumiai-os/MK.md
specifications/rumiai-os/MK-SOURCE-MATERIALIZATION.md
handoff/README.md
```

`specifications/rumiai-os/DOCUMENTATION-MODEL.md` is additionally relevant when designing the documentation-build capability owned by `mk`.

## Fixed task-local choices

No additional task-local choice is currently fixed outside the promoted canonical `MK.md` contract.

## Working design

The items in this section are **active design state, not current specification**. They must not be treated as architectural decisions or implementation requirements until an individual choice passes the specification promotion gate.

### Implementation runtime / language

No implementation runtime has been selected for the broader `mk` subsystem.

Current candidate directions that remain worth evaluating are:

```text
Python
JavaScript-capable runtime
```

Python must not be selected on the assumption that a suitable host Python is universally available. If Python is to be provided through `pkg`, the relevant package/runtime portability and relocatability behavior must be good enough to support the resulting bootstrap/dependency model before selection is promoted.

For a JavaScript direction, Node.js, Deno, GraalVM or another JavaScript-capable runtime must not be treated as interchangeable. The actual runtime contract and package consequences must be evaluated before selection.

The existing shell implementation of `mk materialize` is evidence about that capability only and does not select the runtime of the broader subsystem.

### Structured project configuration

The promoted contract requires structured declarative non-executable project configuration, but no concrete serialization format has been selected.

Current candidates retained for comparison are:

```text
JSON
TOML
```

The comparison should consider at least:

```text
structured-data expressiveness
unambiguous/deterministic parsing semantics
schema and validation support
human authoring ergonomics
comment and embedded-documentation needs
tooling and interoperability
parser/runtime availability
dependency footprint
coupling or bias toward a particular implementation runtime
long-term portability and stability
```

No configuration filename, extension, project-discovery pathname or physical project layout is selected by this candidate set.

### Lifecycle design still to resolve

The promoted contract now requires one general lifecycle model that can cover both delegation to an upstream build/lifecycle engine and direct fine-grained orchestration. The exact internal abstractions remain unresolved.

A current candidate minimal model is:

```text
named lifecycle goal/request
    -> one or more root operations
    -> operation dependency graph
    -> executable leaf operations
```

Under this model, the simple delegated case and the fine-grained native case differ only in graph visibility/granularity. A delegated Maven/CMake/etc. invocation can be represented as one opaque leaf operation with the required tool, arguments, working directory and environment, while a native builder exposes the finer operation graph directly. A goal is therefore better treated as an externally addressable entrypoint/root selection over operations than as a hard-coded lifecycle primitive.

This remains working design rather than promoted terminology. In particular, the final names and the exact boundary between an operation, an executable action and a produced result/target remain to be resolved.

### Candidate vocabulary

The following terminology is proposed only as a working vocabulary for reasoning and stress-testing the model:

```text
project
    logical development unit managed by mk

profile
    named selection/variation of project configuration

goal
    externally addressable requested outcome; selects one or more root operations

operation
    orchestratable unit of work in the lifecycle graph

prerequisite
    relation in which one operation must be satisfied before another operation can proceed

requirement
    external capability, tool, runtime, package or environment condition needed by an operation/project

dependency
    dependency relation between projects; kept distinct from operation prerequisites and external requirements

input
    data/resource/state consumed by an operation

output
    data/resource/state produced by an operation

artifact
    identifiable persistent output such as a file, tree, executable, archive or documentation set

result
    execution outcome/status/metadata, distinct from produced artifacts

action
    concrete executable realization of an operation after resolution

invocation
    process-oriented action: executable/tool + arguments + cwd + environment

tool
    executable or technical facility used by an action

environment
    resolved execution context in which an action runs

adapter
    integration boundary translating mk's abstract model to/from an external tool or engine

builder
    candidate reusable higher-level component that derives or provides operations for a class of projects; whether this deserves a first-class contract remains open

operation graph
    graph of operations and their prerequisite relationships

execution plan
    resolved subset/instance of the operation graph required for a requested goal and profile

executor
    mechanism that performs actions

scheduler
    mechanism deciding which ready actions may run and when, subject to prerequisites/resources

state
    persisted knowledge used by mk across executions when needed

fingerprint
    identity of the relevant inputs/configuration/tool/action state for incremental validity

cache
    reusable stored result/output indexed by an identity such as a fingerprint

invalidation
    determination that prior state/output can no longer satisfy the current request

selector
    declarative mechanism yielding a dynamic set of inputs/resources, useful for automatic source discovery

trigger
    event/request causing reevaluation or execution, useful for watch/hot-update flows

workspace
    managed area for intermediate/generated development data
```

The likely minimal semantic nucleus is currently `project + profile + goal + operation + prerequisite + requirement + dependency + input/output`. Terms such as action, invocation, artifact, executor, scheduler, fingerprint, cache, selector and trigger appear useful as specializations or later execution/incrementality concepts but are not yet candidates for mandatory core primitives.

The following design areas remain active and unresolved:

```text
minimum relationship among lifecycle operations, targets/results, project dependencies, prerequisites, requirements and executable actions
representation of delegated external-engine operations versus directly orchestrated fine-grained actions
support for long-running/watch/hot-update development flows without special-casing a language
automatic source/input discovery and invalidation when files are added, removed or renamed
project discovery and exact configuration location
profile schema and composition rules
public lifecycle CLI and profile-selection syntax
lifecycle ordering / graph representation
incremental execution and cache model
parallel execution model
adapter or plugin interface
build-environment requirement representation
project dependency representation
workspace/state/output layout
local package-install bridge
source-only pkg orchestration
```

These are not a checklist of implicit future requirements. Each choice must be derived from concrete lifecycle needs and promoted individually when sufficiently settled.

### Documentation-build design

The promoted contract currently assigns RumiAI documentation-build orchestration to `mk` as a lifecycle/build-output responsibility. The following remain working design:

```text
documentation source representation
documentation renderer/toolchain
how selected documentation tooling is declared/resolved
public documentation-build CLI/configuration shape
relationship between general project build declarations and documentation-specific needs
```

Sphinx, Asciidoctor and Pandoc are examples previously considered as possible external tooling classes; none is selected by current contract.

## Completed

- The active `mk-tool-development` workstream was created.
- The high-level promoted `mk` lifecycle responsibility is represented by `specifications/rumiai-os/MK.md`.
- Structured declarative non-executable project configuration is a promoted `mk` boundary.
- Projects and profiles are represented by the promoted current lifecycle contract; lifecycle operation names are now explicitly extensible rather than a mandatory hard-coded `build`/`test`/`run`/`clean` set.
- The already implemented source-materialization capability remains separately specified by `MK-SOURCE-MATERIALIZATION.md`.
- Documentation-build orchestration is represented as an `mk` lifecycle responsibility while renderer/tool selection remains outside the promoted contract.
- A workflow correction on 2026-09-17 introduced the specification promotion gate and `Working design` handoff state.
- Provisional runtime/language choices, JSON/TOML comparison material, deferred lifecycle choices and documentation-tool candidates were removed from `specifications/rumiai-os/MK.md` and preserved here as non-authoritative active design state.
- `specifications/README.md` no longer describes `MK.md` as a source of open design choices.
- `CURRENT-MODEL.md` was realigned so it states only promoted `mk` architecture and no longer carries undecided runtime/serialization planning.
- `MK-SOURCE-MATERIALIZATION.md` was reduced to current capability contract and stable scope boundaries; future package/runtime/dependency design was removed from the specification.
- Final documentation consistency review confirmed that the current `MK.md` contains no Python/JavaScript or JSON/TOML candidate material and that the removed design state remains recoverable here.
- The promoted `mk` contract now explicitly supports both delegation to suitable external lifecycle/build engines and direct finer-grained orchestration when delegation is insufficient.
- The promoted contract now requires minimizing tool-, language- and lifecycle-specific hard-coding while keeping common configurations concise and advanced orchestration explicit.
- `CURRENT-MODEL.md` was realigned with the same lifecycle-operation and delegation/direct-orchestration boundary.
- No `rumiai-os`, `rumiai-tests` or `pkg-catalog` product/test change was made by this design checkpoint; runtime tests were therefore not applicable.

## Current state

The current `MK.md` now defines a general extensible lifecycle boundary: lifecycle operation names are project/model data rather than a mandatory fixed set, and `mk` must support both delegation to suitable upstream engines and direct finer-grained orchestration.

The product still implements only the current materialization capability. No product or permanent-test change was made by this design checkpoint.

Future `mk` work must now derive the minimum general orchestration model needed to satisfy both ends of that spectrum without encoding language- or tool-specific assumptions in the core. A choice moves from working design to a canonical specification only after it is sufficiently settled to constrain current implementation and future work.

## Next action

Continue the functional design of the `mk` project lifecycle from the promoted boundaries in `MK.md`, using the working-design items above as non-authoritative design state.

The next concrete design area is to stress-test the candidate goal/root-operation graph model against delegated engines, native C/C++-style fine-grained builds, generated sources, automatic source discovery, incremental rebuilds and long-running/hot-update flows. From that evidence, determine whether operation/action/result need distinct promoted concepts. Do not select serialization format or implementation runtime merely for convenience.

## Blockers / open questions

- What is the minimum general model of lifecycle operations, results/targets, project dependencies, prerequisites, requirements and executable actions that supports both delegation and fine-grained orchestration without hard-coded goal names?
- Which minimum project/profile semantics are required before a public lifecycle CLI can be fixed?
- What evidence is required to choose the broader `mk` implementation runtime?
- What concrete authoring/validation requirements are needed to choose a project-configuration serialization format?
- How should documentation build declarations fit the general project lifecycle without creating a documentation-specific parallel build API?
