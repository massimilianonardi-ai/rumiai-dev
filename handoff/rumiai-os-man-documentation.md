# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Design and, once the contract is fixed, implement a man-style operational reference distributed directly with `rumiai-os` so users and developers can inspect the behavior and usage of the installed/current software without relying on development specifications or conversation history.

A central design objective is to reduce pressure on `rumiai-dev/specifications/` by separating **normative development contracts** from **runtime/user operational reference** without duplicating the same fact into two independently maintained authorities.

## Current repository revisions

```text
rumiai-dev  e5210d04c38ba2fb8ca76108b8c3cabd40510e7f  (last retrieved before this checkpoint)
rumiai-os   36c29d8412a523f722fd90004b78a07fdf0b06c8  (current remote HEAD inspected during activation)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/CURRENT-MODEL.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/RESOURCE-MODEL.md
handoff/README.md
```

Additional subsystem specifications must be retrieved only when the concrete design reaches those responsibilities.

## Fixed task-local choices

- The task concerns an operational/man-style documentation surface inside or distributed with `rumiai-os`.
- The new surface must not become a second copy of the normative RumiAI development specifications.
- `rumiai-dev` remains authoritative for development rules and semantic specifications unless a future explicit contract changes ownership of a specific class of facts.
- Runtime/user documentation should describe the software interface that actually exists for the relevant revision and should be useful independently of the development repository.
- Current canonical development documentation in `rumiai-dev` is English; runtime/user documentation localization remains an open design question for this task.
- No directory name, resource class, command, file format, section numbering scheme, generator or localization mechanism is fixed yet.
- Do not assume that man pages belong under `res/`: the current resource contract defines only `lang` as a concrete global resource class, so a new resource class requires an explicit requirement and contract.
- No existing `man` or `help` mechanism was found in the current `rumiai-os` code search during task activation.

## Completed

- `rumiai-os` current remote HEAD was retrieved and its current tree/README inspected.
- The current product exposes many public technical commands under `bin/sys/` but does not currently expose a discovered man/help documentation mechanism.
- The current architecture/resource/naming contracts were consulted sufficiently to establish that documentation placement must be designed rather than inferred from filesystem symmetry.
- The documentation-language normalization task completed; relevant current development contracts, including `RESOURCE-MODEL.md`, are now maintained in English.
- The root workflow documentation now canonically defines event-driven documentation maintenance and dedicated tasks for substantial documentation refactors.

## Current state

The task is active at design stage. The main open problem is ownership and single-source-of-truth design: determine which facts belong in normative `rumiai-dev` specifications, which belong in runtime operational reference, and whether any content can be generated or mechanically checked so the two surfaces cannot silently drift.

The task should also use the design to test whether the current flat `specifications/rumiai-os/` topic organization remains appropriate or whether operational reference can remove enough interface detail that a larger taxonomy change is unnecessary.

## Next action

Define the documentation model before product modification, including at least:

1. audience and scope of the man-style reference;
2. source-of-truth boundaries versus `rumiai-dev/specifications/`;
3. repository/runtime location and packaging/install behavior;
4. source format and rendering/access mechanism;
5. relationship with command-level `--help` if introduced or already relevant;
6. localization policy, if any;
7. consistency/testing mechanism that prevents documentation drift;
8. migration plan for facts currently better suited to operational reference than normative specifications.

Once these are fixed, update the canonical specification(s) before implementing the product surface.

## Blockers / open questions

- Whether the operational reference should use traditional roff/man sources, another canonical source compiled/rendered to man, or a different internal representation with a man-compatible presentation.
- Whether command usage text and man-style reference should share one source.
- Which current `specifications/` content is normative architecture/design and which content could be reduced after a runtime reference exists.
- Whether localization is required for runtime documentation and how that interacts with the existing `lang` resource model.
