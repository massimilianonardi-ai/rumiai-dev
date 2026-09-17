# RumiAI OS — Documentation model

Status: **Current / normative**  
Updated: 2026-09-17

This specification defines documentation ownership, the first terminal-first operational-reference storage/access model, and the long-term multi-channel documentation target for RumiAI OS.

Its purpose is to keep current development contracts separate from revision-coupled operational documentation, make the first operational reference deliberately simple, and preserve a migration path toward a future documentation system whose informational content is independent from presentation channel.

## 1. Documentation roles

RumiAI documentation has two distinct current responsibilities.

### Development contract

Current development rules, architecture and subsystem semantics belong to `rumiai-dev`.

These sources define what implementations and future changes must preserve. They remain the normative development authority under the project authority model.

### Operational reference

Operational documentation belongs with the product revision it describes and is intended for users and developers who need to understand the installed/current software without retrieving the development knowledge base.

Operational documentation explains observable usage and behavior such as:

```text
command purpose
invocation syntax
operands and options
observable output
exit status
relevant environment/files
examples
cross-references to related operational topics
```

It must not become a second independently maintained copy of architectural ownership, development workflow, historical rationale or other normative material that belongs to `rumiai-dev`.

Git history remains the archive for superseded development documentation and rationale; operational documentation is not a historical archive.

## 2. Authority and consistency

Operational documentation is revision-coupled product content, not an authority above current development specifications.

A conflict between a current specification, implementation, permanent test and operational documentation is a consistency defect. Apply the normal authority hierarchy, determine which surface is stale, and realign the affected current surfaces in the same work unit whenever practical.

The same statement should not be maintained as two independently editable normative contracts merely because it is useful in both development and operational contexts.

Where overlap is unavoidable, each surface keeps its own responsibility:

```text
rumiai-dev
    invariant / semantic contract / forward constraint

operational reference
    user-facing explanation of the interface implemented by that revision
```

## 3. Initial operational-documentation model

The first implementation uses a deliberately simple **terminal-first** model.

Each operational topic is authored as one human-readable UTF-8 text source that can be presented directly in a terminal without requiring a transformation pipeline.

For this initial model:

- source content and terminal representation are intentionally the same artifact;
- the document uses logical textual sections rather than terminal escape sequences or renderer-specific markup;
- no roff, host `man` database, HTML generator, PDF generator or external documentation framework is required by the content baseline;
- the content remains directly readable even when no pager is available;
- topic structure should be regular enough to support later migration to a richer semantic representation without rewriting the underlying information from scratch.

Typical command-reference sections may include:

```text
NAME
SYNOPSIS
DESCRIPTION
OPTIONS
OPERANDS
ENVIRONMENT
FILES
EXIT STATUS
EXAMPLES
SEE ALSO
```

Only sections useful to the specific topic are required. These headings are an authoring convention, not a parser grammar.

## 4. First-delivery storage and identity

Operational pages are distributed global resources in the resource class:

```text
manual
```

The first-delivery layout is:

```text
res/
├── sys/
│   └── manual/
│       └── <topic>
└── ai/
    └── manual/
        └── <topic>
```

`sys` and `ai` keep the ownership semantics defined by `RESOURCE-MODEL.md`.

Each `<topic>` leaf is the operational topic identifier for that owner and is a human-readable UTF-8 text file. The file has **no filename extension**. Controlled topic names follow the current filesystem-naming contract; this specification does not create a second topic-name grammar.

The absence of an extension is intentional: topic identity is not coupled to the current plain-text representation or to a future renderer format.

The public documentation-access utility is named:

```text
manual
```

The command name identifies the operational manual as a semantic surface; it does not imply Unix `man`, roff input, a host man database, or one presentation renderer.

## 5. First-delivery details still unresolved

The following details are not fixed yet:

```text
manual invocation syntax
topic discovery and lookup behavior
owner-qualified lookup syntax
command executable ownership/location
interactive paging behavior and fallback policy
exact spelling of an option that disables paging
search/index behavior
exit-status contract
```

These decisions must be fixed before product implementation of the access utility.

The storage layout and command name fixed above do not by themselves decide lookup precedence, ambiguity handling or paging.

## 6. Long-term multi-channel design target

A second, more general documentation architecture is an explicit long-term design target.

Its defining requirement is separation between:

```text
informational content
    ↓
semantic/document structure
    ↓
build/rendering orchestration
    ↓
channel-specific artifacts
    ↓
terminal / HTML / PDF / other consumers
```

The future system should make one canonical informational source capable of producing multiple presentation channels without maintaining separate hand-authored copies for each format.

The long-term design should preserve at least these properties:

- one canonical content source for the same informational topic;
- deterministic rendering;
- offline/local operation with no mandatory cloud service;
- channel renderers that do not redefine content semantics;
- stable topic identity and cross-references independent of one presentation channel;
- ability to add localization without multiplying independent documentation authorities;
- ability to validate mechanically that generated/rendered surfaces derive from the intended source revision;
- migration from the initial terminal-first pages without discarding their informational content.

### Build ownership

The documentation build mechanism for this long-term model belongs to:

```text
mk
```

This fixes architectural ownership, not an `mk` CLI, project-configuration key, source language, AST, renderer backend or external toolchain.

Documentation generators such as Sphinx, Asciidoctor, Pandoc or another future choice are therefore candidates for **build-time** tooling coordinated by `mk`, not mandatory runtime dependencies of `manual` or of the generated operational pages.

The current implemented `mk materialize` operation remains unchanged. The broader `mk` lifecycle contract is being defined separately; the documentation build capability must be incorporated there rather than being invented as an independent build subsystem.

## 7. Fast bridge versus final architecture

A structured Markdown source with metadata and separate renderers is a plausible fast bridge because it could feed terminal, HTML and PDF generation with comparatively little initial infrastructure.

However, that approach does not by itself fully separate informational semantics from presentation markup. It is therefore **not adopted as the final architecture by this specification**.

The long-term design task must compare such a bridge with genuinely semantic/structured representations and decide whether the extra architecture is justified by concrete RumiAI requirements.

Sphinx, Asciidoctor and Pandoc remain evaluation candidates. Their implementation-language/runtime dependencies matter primarily at build time; generated operational artifacts should remain usable without requiring those documentation toolchains at runtime.

## 8. Migration discipline for the initial model

The initial terminal-first content should avoid choices that make the long-term migration unnecessarily expensive.

Therefore initial operational pages should:

- keep information organized in explicit logical sections;
- avoid ANSI/control formatting as part of canonical content;
- avoid layout that depends on a fixed terminal width;
- keep topic references explicit rather than embedding host-specific hyperlinks;
- avoid duplicating large normative development explanations;
- keep technical identifiers, command names, literal paths and protocol tokens exact;
- keep product revision behavior factual and observable.

This discipline does not make the initial pages a hidden semantic schema. It only keeps them clean enough to migrate later.

## 9. Relationship with command-level help

The first delivery does **not** introduce `--help`, `-h` or another per-command help interface.

Operational reference is accessed through the dedicated manual surface instead of requiring every public command to maintain a second independently authored help path.

A future requirement may introduce short command help only through an explicit contract. If that happens, overlapping short help and long operational reference should derive from the same canonical informational source whenever practical rather than drifting independently.

## 10. Paging principle

Paging is a property of the access/viewing layer, not of the canonical operational page content.

The canonical page remains directly consumable as text regardless of whether `manual` chooses an interactive pager for terminal output.

The exact first-delivery paging policy remains unresolved. In particular, this specification does not yet make `less`, `more`, another external pager, a bundled pager, or a pager-selection environment variable part of the runtime contract.

## 11. Testing and maintenance

Permanent tests should protect mechanical properties only after the concrete delivery mechanism is defined, for example discovery, lookup, output, paging selection, exit status, file layout or deterministic rendering.

Tests do not make prose normative.

A product-interface change that makes existing operational documentation inaccurate requires corresponding documentation realignment in the same work unit whenever practical.

Documentation completeness is not measured by page count. Add an operational topic when it provides real user/developer value for a public or materially observable interface.

## 12. Current sequencing

The task sequence is:

```text
fix documentation ownership/model
→ fix first-delivery storage and public access identity
→ design lookup, paging and exit-status behavior
→ implement and test that first delivery
→ populate useful operational topics incrementally
→ continue the multi-channel architecture through mk as a separate long-term design track
→ migrate only when that second model is sufficiently specified and justified
```

The simple delivery must not be presented as the final documentation architecture merely because it is implemented first.

## 13. Invariants

```text
DOC-01  rumiai-dev remains the normative development-contract source
DOC-02  operational documentation is revision-coupled product reference, not a second development authority
DOC-03  the first operational model is terminal-first plain UTF-8 text with no required transformation pipeline
DOC-04  the first global operational-documentation resource class is manual under res/<owner>/manual/
DOC-05  each initial operational topic is an extensionless UTF-8 text file whose leaf name is its owner-local topic identity
DOC-06  the public operational-documentation access utility is named manual
DOC-07  manual invocation, lookup, paging and exit-status behavior remain unresolved until their next design step
DOC-08  the first model must avoid presentation-specific choices that unnecessarily obstruct later migration
DOC-09  the long-term target separates informational content from channel-specific rendering
DOC-10  the long-term documentation build mechanism belongs to mk while source schema and renderer/toolchain remain undecided
DOC-11  a Markdown-plus-metadata bridge is an exploration candidate, not the adopted final architecture
DOC-12  the first delivery does not introduce per-command --help or -h
DOC-13  paging never changes the canonical page content contract
DOC-14  interface changes realign affected operational documentation in the same work unit whenever practical
```
