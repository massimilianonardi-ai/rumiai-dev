# RumiAI OS — Documentation model

Status: **Current / normative**  
Updated: 2026-09-17

This specification defines the documentation ownership model for RumiAI OS before any concrete documentation-access command, pathname layout or rendering tool is selected.

Its purpose is to keep current development contracts separate from revision-coupled operational documentation while allowing the first operational reference to be implemented simply and leaving a deliberate migration path toward a future multi-channel documentation system.

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
- no roff, host `man` database, pager, HTML generator, PDF generator or external documentation framework is required by the baseline;
- the content should remain understandable as plain text when opened directly;
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

## 4. Deliberately unresolved first-delivery details

This documentation model does **not** yet fix:

```text
public utility name
utility invocation syntax
discovery / lookup behavior
filesystem location
resource-class classification
owner-qualified lookup rules
page filename convention
paging behavior
search/index behavior
integration with command-level --help or -h
```

Those decisions belong to the next design step and must be made against this model before product implementation.

No implementation or pathname symmetry may silently decide them first.

## 5. Long-term multi-channel design target

A second, more general documentation architecture is an explicit long-term design target.

Its defining requirement is separation between:

```text
informational content
    ↓
semantic/document structure
    ↓
channel-specific rendering
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

No source language, schema, AST, generator, renderer, build tool or output format is selected by this specification yet.

## 6. Fast bridge versus final architecture

A structured Markdown source with metadata and separate renderers is a plausible fast bridge because it could feed terminal, HTML and PDF generation with comparatively little initial infrastructure.

However, that approach does not by itself fully separate informational semantics from presentation markup. It is therefore **not adopted as the final architecture by this specification**.

The long-term design task must compare such a bridge with genuinely semantic/structured representations and decide whether the extra architecture is justified by concrete RumiAI requirements.

## 7. Migration discipline for the initial model

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

## 8. Relationship with command-level help

The current documentation model does not introduce `--help`, `-h` or another command-help interface.

When the first access utility is designed, command-level help must be considered explicitly so short help and long operational reference do not become two unrelated sources that drift independently.

A future multi-channel model should ideally allow both surfaces to derive from the same informational source when their content overlaps materially.

## 9. Testing and maintenance

Permanent tests should protect mechanical properties only after the concrete delivery mechanism is defined, for example discovery, lookup, output, exit status, file layout or deterministic rendering.

Tests do not make prose normative.

A product-interface change that makes existing operational documentation inaccurate requires corresponding documentation realignment in the same work unit whenever practical.

Documentation completeness is not measured by page count. Add an operational topic when it provides real user/developer value for a public or materially observable interface.

## 10. Current sequencing

The task sequence is:

```text
fix documentation ownership/model
→ design the simple first-delivery storage and access interface
→ implement and test that first delivery
→ populate useful operational topics incrementally
→ continue the multi-channel architecture as a separate long-term design track
→ migrate only when that second model is sufficiently specified and justified
```

The simple delivery must not be presented as the final documentation architecture merely because it is implemented first.

## 11. Invariants

```text
DOC-01  rumiai-dev remains the normative development-contract source
DOC-02  operational documentation is revision-coupled product reference, not a second development authority
DOC-03  the first operational model is terminal-first plain UTF-8 text with no required transformation pipeline
DOC-04  utility name, access semantics and filesystem/resource placement remain unresolved until the next design step
DOC-05  the first model must avoid presentation-specific choices that unnecessarily obstruct later migration
DOC-06  the long-term target separates informational content from channel-specific rendering
DOC-07  no long-term source schema, renderer or generator is selected yet
DOC-08  a Markdown-plus-metadata bridge is an exploration candidate, not the adopted final architecture
DOC-09  operational documentation and command-level help must not evolve into unrelated drifting authorities
DOC-10  interface changes realign affected operational documentation in the same work unit whenever practical
```
