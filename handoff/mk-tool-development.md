# mk tool development

Status: Active
Updated: 2026-09-17

## Goal

Define and develop `mk` as the `m` subsystem responsible for the complete development lifecycle of a project, with modular, standardized and flexible orchestration while keeping project configuration declarative and non-executable.

## Current repository revisions

```text
rumiai-dev   d69e72e4866d1f56eddf017d8ab490bcdf60bcc6
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
specifications/rumiai-os/MK-SOURCE-MATERIALIZATION.md
handoff/README.md
```

## Fixed task-local choices

- The implementation runtime for the future `mk` core is intentionally undecided.
- Python and JavaScript remain candidate implementation languages/runtime families; the choice is deferred until relevant `pkg` runtime/package portability and relocatability work is sufficiently stable to evaluate the bootstrap and dependency consequences.
- No design may assume that a suitable host Python is always available.
- A future JavaScript choice must evaluate the concrete runtime contract rather than treating Node.js, Deno, GraalVM or other runtimes as interchangeable.
- The structured project-configuration serialization format is intentionally undecided. JSON and TOML must be compared explicitly before adoption; the evaluation must include runtime/tooling coupling as well as ergonomics and semantics.

## Completed

- Current repository HEADs were retrieved.
- The current `mk` specification, high-level model, implementation and permanent materialization test were inspected.
- A mismatch was confirmed: the current canonical model still presents `mk` primarily as a source materializer, while the current user direction establishes a broader development-lifecycle responsibility.

## Current state

The existing source-materialization contract remains a valid implemented capability, but it must no longer serve as the complete definition of `mk`. The broader `mk` responsibility must be promoted to a current canonical specification before further lifecycle design or implementation proceeds.

## Next action

Create the canonical high-level `mk` specification, route it from `specifications/README.md`, realign `CURRENT-MODEL.md`, and make `MK-SOURCE-MATERIALIZATION.md` explicitly subordinate to that broader contract without changing its implemented materialization behavior.

## Blockers / open questions

- Exact implementation runtime/language.
- Exact structured configuration format, including JSON versus TOML.
- Detailed project/profile/lifecycle/dependency/workspace contracts, to be defined incrementally after the high-level role is fixed.
