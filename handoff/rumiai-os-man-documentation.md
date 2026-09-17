# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and use the same task to establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design is a separate architecture problem and must not be accidentally fixed by the first utility implementation.

## Current repository revisions

```text
rumiai-dev  d6e89c800685c536ebf7340f30b04f0bb170525a  (current remote HEAD inspected before this checkpoint)
rumiai-os   36c29d8412a523f722fd90004b78a07fdf0b06c8  (current remote HEAD inspected; no product change made by this task)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/CURRENT-MODEL.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/RESOURCE-MODEL.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
handoff/README.md
```

Additional subsystem specifications must be retrieved only when the concrete access/storage design reaches those responsibilities.

## Fixed task-local choices

- `rumiai-dev` remains authoritative for normative development rules and semantic specifications.
- Operational documentation is revision-coupled product reference and must not become a second development-specification authority.
- The first implementation uses a simple terminal-first model: one human-readable UTF-8 text source per operational topic, directly consumable without a rendering pipeline.
- Initial content avoids ANSI/control formatting, fixed-width-dependent layout and other choices that would unnecessarily obstruct later migration.
- The first-delivery work is intentionally separable into two implementation blocks: distributed documentation files/storage, then access/viewing utility or utilities.
- The public utility name, invocation syntax, discovery behavior, filesystem location, resource-class classification, page filename convention and paging/search behavior are **not fixed yet**.
- Command-level `--help`/`-h` is not part of the intended first-delivery direction. The user is strongly opposed to adding per-command `--help`; reopen that only for a concrete future requirement rather than treating it as a default documentation surface.
- A long-term documentation architecture must separate informational content from channel-specific rendering so the same canonical information can feed terminal, HTML, PDF and other consumers.
- No long-term source schema, AST, renderer, generator or localization design is fixed yet.

## Completed

- Current `rumiai-os` architecture, resource, naming and command-entrypoint context was inspected.
- No existing RumiAI `man`/help mechanism was found in the inspected current product revision.
- A premature contract that fixed the utility name `man`, a `man` resource class and concrete lookup behavior was corrected forward after the user clarified that the documentation model must be decided first.
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md` now defines the current ownership split, simple terminal-first initial model, unresolved first-delivery details, migration discipline and long-term multi-channel target.
- `specifications/README.md` now routes documentation-model questions directly to that canonical source.
- No `rumiai-os` product modification has been committed by this task.
- Existing open-source documentation toolchains were checked as possible accelerators for the long-term track.
- Sphinx current stable packaging is Python-based and currently requires Python >= 3.12. It provides built-in HTML, plain-text, groff-man, gettext and LaTeX builders; practical PDF production adds a TeX/LaTeX toolchain unless another PDF builder is selected.
- Asciidoctor core is Ruby-based (with JVM and JavaScript variants also available). Built-in converters include HTML5, DocBook5 and manpage; PDF requires the `asciidoctor-pdf` Ruby gem, which produces PDF directly without requiring LaTeX.
- Pandoc is a Haskell-based converter with an explicit intermediate AST and writers including plain text, HTML, roff man and many other formats. Official Linux binaries can be statically linked/self-contained; PDF output still requires a selected external PDF engine such as LaTeX, Typst, WeasyPrint, groff or another supported engine.
- The dependency profile therefore matters independently from source-model quality: the future toolchain should preferably be a documentation **build-time** dependency, while generated operational artifacts remain runtime-consumable without Python, Ruby or another documentation runtime.

## Current state

The documentation model is fixed sufficiently to proceed to the **next design layer** without implementing product code yet.

The immediate design problem is now narrow: choose the first terminal access surface and storage/discovery contract for simple plain-text operational topics. That design must remain compatible with later migration to a content/rendering architecture but must not pretend to solve that larger problem now.

The current implementation context supports treating operational pages as distributed static content, which makes the existing global resource model a strong storage candidate; introducing a new resource class still requires an explicit documentation contract rather than filesystem symmetry.

In parallel, the long-term track should compare Sphinx, Asciidoctor and Pandoc against RumiAI requirements for semantic source, terminal/HTML/PDF outputs, localization, offline operation, build-time dependencies, determinism and migration from the initial pages. The build-time-versus-runtime dependency boundary is now a primary evaluation criterion.

## Next action

Design the first-delivery operational-reference interface, in this order:

1. select the utility name and semantic responsibility from a small explicit candidate set;
2. fix topic identity and lookup/discovery behavior;
3. fix physical storage and ownership/resource classification;
4. fix output/paging behavior and exit statuses;
5. keep command-level `--help` out of the first delivery unless a new explicit requirement changes that direction;
6. define the proportional permanent-test contract.

Only after these choices are fixed should `rumiai-os` implementation begin.

In parallel, perform a small dependency-oriented comparison/PoC of Sphinx, Asciidoctor and Pandoc before inventing a RumiAI-specific semantic format.

## Blockers / open questions

- Name and exact semantic scope of the first terminal documentation utility. Current conversational candidates include `manny`, `mman`, `manu`, `docs` and `dokky`; none is adopted merely by being proposed.
- Whether the strongest storage candidate should be formalized as a new global resource class under `res/<owner>/...`, and what that resource class should be called.
- Whether the first utility should only display exact topics or also list/search topics.
- Whether paging belongs to the utility baseline or should be delegated/omitted initially.
- Whether Sphinx, Asciidoctor, Pandoc or another existing toolchain best balances semantic structure against dependency cost.
- Whether a Markdown-based bridge adds useful migration value or merely creates an intermediate format to remove later.
- Which concrete future channels beyond terminal, HTML and PDF create requirements that should shape the long-term content model.
