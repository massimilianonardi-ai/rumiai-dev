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
- topic structure is regular enough to support later migration to a richer semantic representation without rewriting the underlying information from scratch.

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

## 5. First-delivery `manual` interface

The first-delivery invocation forms are:

```text
manual
manual [--no-pager] <topic>
manual [--no-pager] <owner> <topic>
```

`--no-pager` is an option and precedes the operands in the topic-presentation forms.

### 5.1 Qualified discovery

With zero arguments:

```text
manual
```

`manual` discovers every materialized global manual topic of the form:

```text
res/<owner>/manual/<topic>
```

and writes one owner-qualified entry per topic to standard output:

```text
<owner> <topic>
```

Every discovery result is qualified, even when the topic name is unique across all owners. Discovery therefore never collapses a result to `<topic>` merely because that result would be unambiguous for lookup.

For example, a discovery result may contain:

```text
sys pkg
sys srv
ai pkg
```

Zero-argument discovery lists topic identities; it does not select or present a topic, and it does not invoke the topic pager.

Discovery follows the general `res/*/manual/` shape and must not contain an explicit semantic dependency on the owner name `ai`.

### 5.2 Unqualified lookup

For:

```text
manual <topic>
```

`manual` searches the materialized global manual trees of the form:

```text
res/*/manual/<topic>
```

The result is resolved by cardinality, not by owner precedence:

```text
exactly one match
    select and present that topic

no matches
    fail as topic not found

more than one match
    fail as ambiguous and present the owner-qualified alternatives
```

An ambiguous lookup must not silently prefer `sys`, `ai` or any other owner. Its diagnostic is written to standard error, identifies the ambiguous topic and includes each matching owner-qualified invocation needed to select a specific result, for example:

```text
manual sys pkg
manual ai pkg
```

### 5.3 Owner-qualified lookup

For:

```text
manual <owner> <topic>
```

`manual` resolves exactly:

```text
res/<owner>/manual/<topic>
```

If that owner-local topic exists, it is selected and presented. If it does not exist, the lookup fails; owner-qualified lookup does not fall back to another owner.

The current global owners remain those defined by `RESOURCE-MODEL.md`; this syntax does not create new owners or a universal resource resolver.

### 5.4 Paging option

The same lookup semantics apply with `--no-pager`:

```text
manual --no-pager <topic>
manual --no-pager <owner> <topic>
```

The option changes only presentation of a successfully selected topic; it does not change discovery, ambiguity or owner qualification.

This specification does not define the executable location of `manual`, exact diagnostic prose/layout beyond the semantic requirements above, or numeric exit-status mapping.

## 6. Long-term multi-channel design target

A second, more general documentation architecture is a current long-term design target.

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

The future system keeps one canonical informational source capable of producing multiple presentation channels without maintaining separate hand-authored copies for each format.

The long-term contract preserves at least these properties:

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

The broader `mk` lifecycle contract is defined by `MK.md`. Documentation generation that requires transformation is part of that lifecycle rather than an independent documentation-specific build subsystem.

Documentation generators/renderers are build-time tooling coordinated by `mk`, not mandatory runtime dependencies of `manual` or of generated operational pages.

This contract does not fix a documentation source language, semantic schema, AST representation, renderer backend or external documentation toolchain.

## 7. Migration discipline for the initial model

The initial terminal-first content avoids choices that make long-term migration unnecessarily expensive.

Therefore initial operational pages:

- keep information organized in explicit logical sections;
- avoid ANSI/control formatting as part of canonical content;
- avoid layout that depends on a fixed terminal width;
- keep topic references explicit rather than embedding host-specific hyperlinks;
- avoid duplicating large normative development explanations;
- keep technical identifiers, command names, literal paths and protocol tokens exact;
- keep product revision behavior factual and observable.

This discipline does not make the initial pages a hidden semantic schema. It keeps them clean enough to migrate later.

## 8. Relationship with command-level help

The first delivery does **not** introduce `--help`, `-h` or another per-command help interface.

Operational reference is accessed through the dedicated manual surface instead of requiring every public command to maintain a second independently authored help path.

Any later command-level help contract must be introduced explicitly. Overlapping short help and long operational reference should derive from the same canonical informational source whenever practical rather than drifting independently.

## 9. Paging contract

Paging is a property of the access/viewing layer, not of the canonical operational page content.

For the first delivery, normal topic presentation by `manual` delegates the selected topic to the POSIX `more` utility. This deliberately reuses the platform baseline rather than introducing a RumiAI-specific pager abstraction.

The POSIX `more` contract distinguishes terminal and non-terminal standard output: it pages interactively when standard output is a terminal and otherwise copies the input to standard output. `manual` therefore does not require a separate TTY-detection policy merely to preserve pipeline/redirection behavior.

When `--no-pager` is specified, `manual` bypasses `more` and writes the selected topic directly to standard output.

The first delivery does not introduce a generic `pager` command, a `less` dependency, a `PAGER` environment contract, pager-selection configuration or a host-specific pager adapter.

A later pager abstraction or non-POSIX pager requires a concrete reusable requirement that the POSIX baseline does not satisfy and must not silently change the canonical topic-content contract.

## 10. Testing and maintenance

Permanent tests protect mechanical properties of the delivered interface, including resource layout, discovery, lookup, ambiguity handling, owner qualification, output/paging behavior and exit-status behavior once implemented.

Tests do not make prose normative.

A product-interface change that makes existing operational documentation inaccurate requires corresponding documentation realignment in the same work unit whenever practical.

Documentation completeness is not measured by page count. Add an operational topic when it provides real user/developer value for a public or materially observable interface.

## 11. Invariants

```text
DOC-01  rumiai-dev remains the normative development-contract source
DOC-02  operational documentation is revision-coupled product reference, not a second development authority
DOC-03  the first operational model is terminal-first plain UTF-8 text with no required transformation pipeline
DOC-04  the first global operational-documentation resource class is manual under res/<owner>/manual/
DOC-05  each initial operational topic is an extensionless UTF-8 text file whose leaf name is its owner-local topic identity
DOC-06  the public operational-documentation access utility is named manual
DOC-07  bare manual discovers all materialized manual topics and always emits each result as <owner> <topic>
DOC-08  discovery follows the general res/*/manual shape and does not semantically depend on the owner name ai
DOC-09  --no-pager bypasses paging and writes the selected topic directly to standard output
DOC-10  normal first-delivery topic presentation delegates to POSIX more; no generic pager abstraction is introduced
DOC-11  unqualified manual lookup selects a topic only when exactly one owner-local match exists; it never applies implicit owner precedence
DOC-12  ambiguous unqualified lookup fails and identifies each owner-qualified invocation that resolves the ambiguity
DOC-13  manual <owner> <topic> resolves exactly that owner-local topic with no cross-owner fallback
DOC-14  the first model avoids presentation-specific choices that unnecessarily obstruct later migration
DOC-15  the long-term target separates informational content from channel-specific rendering
DOC-16  long-term documentation build orchestration belongs to mk; runtime manual pages do not require the build toolchain
DOC-17  the first delivery does not introduce per-command --help or -h
DOC-18  paging never changes the canonical page content contract
DOC-19  interface changes realign affected operational documentation in the same work unit whenever practical
```
