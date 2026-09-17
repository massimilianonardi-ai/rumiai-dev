# mk tool development

Status: Active
Updated: 2026-09-17

## Goal

Define and develop `mk` as the `m` subsystem responsible for project development-lifecycle management and orchestration, with modular, standardized and flexible orchestration while keeping project configuration declarative and non-executable.

## Current repository revisions

```text
rumiai-dev   83e5d5b04bcbf99463d3391fd5f894c4cc616981  (pre-checkpoint HEAD)
rumiai-os    36c29d8412a523f722fd90004b78a07fdf0b06c8  (last inspected)
rumiai-tests 298931c1dca03d44755893d64b9b3a7c0058b7ea  (last inspected)
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

The following design areas remain active and unresolved:

```text
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
- Projects/profiles and build/test/run/clean/output production are represented by the promoted current lifecycle contract.
- The already implemented source-materialization capability remains separately specified by `MK-SOURCE-MATERIALIZATION.md`.
- Documentation-build orchestration is represented as an `mk` lifecycle responsibility while renderer/tool selection remains outside the promoted contract.
- A workflow correction on 2026-09-17 introduced the specification promotion gate and `Working design` handoff state.
- Provisional runtime/language choices, JSON/TOML comparison material, deferred lifecycle choices and documentation-tool candidates were removed from `specifications/rumiai-os/MK.md` and preserved here as non-authoritative active design state.
- `specifications/README.md` no longer describes `MK.md` as a source of open design choices.

## Current state

The current `MK.md` is now limited to promoted contract. The unresolved design space needed to continue the task is preserved in `Working design` instead of being mixed into specifications.

The product still implements only the current materialization capability. No product or permanent-test change was made by this documentation/workflow correction.

Future `mk` work must evaluate and resolve working-design items incrementally. A choice moves from this section to a canonical specification only after it is sufficiently settled to constrain current implementation and future work.

## Next action

Continue the functional design of the `mk` project lifecycle from the promoted boundaries in `MK.md`, using the working-design items above as non-authoritative design state.

The next concrete design area should be project/configuration discovery and the minimum project/profile lifecycle model, without selecting serialization format or implementation runtime merely for convenience.

## Blockers / open questions

- Which minimum project/profile semantics are required before a public lifecycle CLI can be fixed?
- What evidence is required to choose the broader `mk` implementation runtime?
- What concrete authoring/validation requirements are needed to choose a project-configuration serialization format?
- How should documentation build declarations fit the general project lifecycle without creating a documentation-specific parallel build API?
