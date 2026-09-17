# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and use the same task to establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design is a separate architecture problem and must not be accidentally fixed by the first utility implementation.

## Current repository revisions

```text
rumiai-dev  d58007e1f26e2c6c6c1228995e0f76a115c9caef  (current checkpoint before this handoff update)
rumiai-os   36c29d8412a523f722fd90004b78a07fdf0b06c8  (last current remote HEAD inspected; no product change made by this task)
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
handoff/README.md
```

Additional subsystem specifications must be retrieved only when the concrete access/storage design reaches those responsibilities.

## Fixed task-local choices

- `rumiai-dev` remains authoritative for normative development rules and semantic specifications.
- Operational documentation is revision-coupled product reference and must not become a second development-specification authority.
- The first implementation uses a simple terminal-first model: one human-readable UTF-8 text source per operational topic, directly consumable without a rendering pipeline.
- Initial content avoids ANSI/control formatting, fixed-width-dependent layout and other choices that would unnecessarily obstruct later migration.
- The public utility name, invocation syntax, discovery behavior, filesystem location, resource-class classification, page filename convention and paging/search behavior are **not fixed yet**.
- Command-level `--help`/`-h` is not introduced implicitly and must be considered explicitly when the access utility is designed.
- A long-term documentation architecture must separate informational content from channel-specific rendering so the same canonical information can feed terminal, HTML, PDF and other consumers.
- No long-term source schema, AST, renderer, generator or localization design is fixed yet.

## Completed

- Current `rumiai-os` architecture, resource, naming and command-entrypoint context was inspected.
- No existing RumiAI `man`/help mechanism was found in the inspected current product revision.
- A premature contract that fixed the utility name `man`, a `man` resource class and concrete lookup behavior was corrected forward after the user clarified that the documentation model must be decided first.
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md` now defines the current ownership split, simple terminal-first initial model, unresolved first-delivery details, migration discipline and long-term multi-channel target.
- `specifications/README.md` now routes documentation-model questions directly to that canonical source.
- No `rumiai-os` product modification has been committed by this task.
- Existing open-source documentation toolchains were checked as possible accelerators for the long-term track:
  - Sphinx already has builders for plain text, Unix man pages, HTML and LaTeX/PDF-oriented output, plus gettext-oriented localization support;
  - Asciidoctor parses AsciiDoc into a structured document and has built-in HTML, DocBook and man-page converters, with PDF available through its add-on converter;
  - Pandoc remains a plausible broad conversion bridge, but PDF generation normally relies on an external PDF engine/toolchain.
- This means the long-term route may be substantially faster if RumiAI adopts an existing semantic/document-processing toolchain instead of defining a custom format first.

## Current state

The documentation model is fixed sufficiently to proceed to the **next design layer** without implementing product code yet.

The immediate design problem is now narrow: choose the first terminal access surface and storage/discovery contract for simple plain-text operational topics. That design must remain compatible with later migration to a content/rendering architecture but must not pretend to solve that larger problem now.

In parallel, the long-term track should evaluate Sphinx and Asciidoctor before inventing a RumiAI-specific semantic format. A lightweight Markdown/Pandoc-style bridge remains possible, but it should be judged against those existing structured toolchains rather than assumed to be the architecture.

## Next action

Design the first-delivery operational-reference interface, in this order:

1. utility name and semantic responsibility;
2. topic identity and lookup/discovery behavior;
3. physical storage and ownership/resource classification;
4. output/paging behavior and exit statuses;
5. relationship with short command help;
6. proportional permanent-test contract.

Only after these choices are fixed should `rumiai-os` implementation begin.

In parallel, compare at least Sphinx and Asciidoctor against RumiAI requirements for semantic source, terminal/HTML/PDF outputs, localization, offline operation, build-time dependencies, determinism and migration from the initial pages.

## Blockers / open questions

- Name and exact semantic scope of the first terminal documentation utility.
- Whether operational pages should be a new global resource class, another distributed product-content location, or a different existing ownership mechanism.
- Whether the first utility should only display exact topics or also list/search topics.
- Whether paging belongs to the utility baseline or should be delegated/omitted initially.
- Whether Sphinx, Asciidoctor or another existing toolchain is sufficient for the long-term semantic/multi-channel model.
- Whether a Markdown-based bridge adds useful migration value or merely creates an intermediate format to remove later.
- Which concrete future channels beyond terminal, HTML and PDF create requirements that should shape the long-term content model.
