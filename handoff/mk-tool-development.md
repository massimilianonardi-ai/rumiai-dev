# mk tool development

Status: Active
Updated: 2026-09-17

## Goal

Define and develop `mk` as the `m` subsystem responsible for the complete development lifecycle of a project, with modular, standardized and flexible orchestration while keeping project configuration declarative and non-executable.

## Current repository revisions

```text
rumiai-dev   9375ac9f160fd3970e93cf1fb0b4ad4e14df0187  (canonical mk contract checkpoint before this handoff update)
rumiai-os    36c29d8412a523f722fd90004b78a07fdf0b06c8
rumiai-tests 298931c1dca03d44755893d64b9b3a7c0058b7ea
pkg-catalog  94f58995cbd487b17f3b82bc2724c70540927b88
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

## Fixed task-local choices

No additional task-local architecture choice is currently fixed outside the canonical `MK.md` contract.

## Completed

- The active `mk-tool-development` workstream was created.
- `specifications/rumiai-os/MK.md` now defines `mk` as the `m` subsystem responsible for complete project development-lifecycle management and orchestration.
- Structured declarative non-executable project configuration is now a canonical `mk` boundary.
- Projects/profiles and build/test/run/clean/output production are established lifecycle concepts/responsibilities without prematurely fixing their detailed schema or CLI.
- Runtime/language selection remains explicitly undecided; Python and JavaScript runtime implications are documented without assuming host Python or treating JavaScript runtimes as interchangeable.
- JSON versus TOML remains explicitly undecided and must be compared before adoption, including parser/runtime coupling, ergonomics, semantics, dependencies and portability.
- `specifications/README.md` now routes the general `mk` lifecycle contract to `MK.md` and materialization separately to `MK-SOURCE-MATERIALIZATION.md`.
- `CURRENT-MODEL.md` now reflects the broader lifecycle responsibility of `mk`.
- `MK-SOURCE-MATERIALIZATION.md` is explicitly subordinate to `MK.md`; its existing materialization behavior remains current and its shell implementation no longer implies the runtime of the future broader core.
- The current `rumiai-os` implementation and permanent materialization test were rechecked; no product/test change was required for this documentation-only contract checkpoint.
- Consistency review found only the intended four canonical documentation changes from the pre-write HEAD; stale phrases describing `mk` as not a generic build graph or routing it only as source materialization were not found in the current tree.

## Current state

The architectural identity of `mk` is now fixed independently from its initial materialization implementation. The current product still implements only the `materialize` capability, which is a valid partial implementation of the broader lifecycle subsystem.

The implementation runtime and project configuration format remain deliberately open. Further lifecycle design should not choose Python/JavaScript or JSON/TOML by convenience before the relevant package/runtime and configuration requirements are sufficiently understood.

## Next action

Define the functional model of the `mk` project lifecycle before extending product code: project discovery/configuration, profiles, lifecycle operations, dependency/requirement categories, workspace/state and outputs. Use the behavior of the historical `mk` as design input where useful, without inheriting its shell-sourced configuration or implementation mechanics.

## Blockers / open questions

- Exact implementation runtime/language, pending sufficient package/runtime portability and relocatability evidence.
- Exact structured configuration format, especially JSON versus TOML.
- Detailed project/profile/lifecycle/dependency/workspace contracts.
