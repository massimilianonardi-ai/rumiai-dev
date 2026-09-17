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
library purpose and public callable functions
examples
cross-references to related operational topics
```

It must not become a second independently maintained copy of architectural ownership, development workflow, historical rationale or other normative material that belongs to `rumiai-dev`.

Git history remains the archive for superseded development documentation and rationale; operational documentation is not a historical archive.

## 2. Authority and consistency

Operational documentation is revision-coupled product content, not an authority above current development specifications.

A conflict between a current specification, implementation, permanent test and operational documentation is a consistency defect. Apply the normal authority hierarchy, determine which surface is stale, and realign the affected current surfaces in the same work unit.

The same statement should not be maintained as two independently editable normative contracts merely because it is useful in both development and operational contexts.

Where overlap is unavoidable, each surface keeps its own responsibility:

```text
rumiai-dev
    invariant / semantic contract / forward constraint

operational reference
    user/developer-facing explanation of the interface implemented by that revision
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

Typical library-reference sections may include:

```text
NAME
DESCRIPTION
FUNCTIONS
DEPENDENCIES
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

Each `<topic>` leaf is the operational topic identifier for that owner and is a human-readable UTF-8 text file. The file has **no documentation-format filename extension**. Controlled topic names follow the current filesystem-naming contract; this specification does not create a second topic-name grammar.

The topic identifier may itself contain semantic dot components when those components are part of the documented identity. In particular, a library topic uses the runtime-qualified library leaf `<library-name>.lib.<runtime>`; `.lib.<runtime>` is part of the library identity, not a documentation-format suffix.

The absence of a documentation-format extension is intentional: topic identity is not coupled to the current plain-text representation or to a future renderer format.

### 4.1 Mandatory command coverage

Every RumiAI-owned directly executable command identity defined by `COMMAND-ENTRYPOINTS.md` MUST have a corresponding operational manual topic in the `manual` resource tree of the command's semantic owner.

This requirement is independent of intended audience. It applies to commands used primarily by end users, developers, maintenance flows or internal technical workflows.

The requirement follows semantic command identity rather than executable pathname count. Multiple paths or symlink exposures of the same command identity require one manual topic, not duplicate pages. In particular, `$m_ROOT/m` and its `bin/sys/m` exposure are the same command identity.

RumiAI-owned libraries are not command identities; their separate mandatory coverage is defined in section 4.2. Package-owned external executables are not RumiAI-owned command identities and are outside this coverage requirement.

Command lifecycle and manual lifecycle are coupled:

```text
create command
    create its manual topic in the same work unit

rename command
    rename/realign its manual topic in the same work unit

remove command
    remove/realign its manual topic in the same work unit

modify command
    always perform a manual-consistency check
```

If a command modification changes purpose, invocation syntax, operands, options, output, exit statuses, relevant environment/files, side effects or any other behavior described by its operational reference, the manual topic MUST be updated in the same work unit.

A purely internal implementation change does not require a textual manual edit when the existing topic remains fully accurate, but the consistency check is still mandatory.

A command-development work unit is incomplete while the command and its operational manual disagree or while the command lacks its required manual topic.

### 4.2 Mandatory library coverage

Every RumiAI-owned library identity defined by `LIBRARY-INTERFACES.md` MUST have exactly one corresponding operational manual topic in the `manual` resource tree of the library's semantic owner.

The topic identity is exactly the runtime-qualified library leaf:

```text
<library-name>.lib.<runtime>
```

Therefore:

```text
lib/sys/sh/array.lib.sh
    ↓
res/sys/manual/array.lib.sh
```

and an `ai`-owned library would map analogously under `res/ai/manual/`.

This mapping is deterministic and avoids command/library topic collisions without inventing a second library alias.

A library manual documents the library as one unit. It MUST expose every public function defined by the library and MUST NOT expose internal functions as callable API.

For each public function, the page records the operationally relevant function contract, including as applicable invocation shape, arguments, output, return status, side effects, environment/dependencies and caller obligations.

Internal function identifiers MUST NOT be listed or documented as part of the callable interface. The public/internal naming contract itself is owned by `LIBRARY-INTERFACES.md`.

Library lifecycle and manual lifecycle are coupled:

```text
create library
    create its manual topic in the same work unit

rename/remove library
    realign/remove its manual topic in the same work unit

modify library
    always perform a library/manual consistency check

add/change/remove public function
    update the library manual in the same work unit
```

A purely internal implementation change does not require a textual manual edit when the public interface and existing page remain fully accurate, but the consistency check is still mandatory.

A library-development work unit is incomplete while the library and its operational manual disagree, while the required topic is missing, or while public/internal function visibility naming is inconsistent with `LIBRARY-INTERFACES.md`.

The public documentation-access utility is named:

```text
manual
```

The command name identifies the operational manual as a semantic surface; it does not imply Unix `man`, roff input, a host man database, or one presentation renderer.

The first-delivery executable belongs to the technical `m` layer and is located at:

```text
bin/sys/manual
```

Because it consumes bootstrap facilities such as `m_RES_DIR`, it is a bootstrap-integrated command and uses:

```sh
#!/usr/bin/env m
```

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

Discovery output is sorted in ascending lexical order by `<owner>` and then by `<topic>`, using the controlled identifier spelling rather than locale-specific collation.

For example, a discovery result may contain:

```text
ai pkg
sys array.lib.sh
sys pkg
sys srv
```

Zero-argument discovery lists topic identities; it does not select or present a topic, and it does not invoke the topic pager.

If no manual topics are materialized, discovery succeeds with exit status `0` and writes no topic entries.

Discovery follows the general `res/*/manual/` shape and must not contain an explicit semantic dependency on the owner name `ai`.

### 5.2 Unqualified lookup and substring fallback

For:

```text
manual <topic>
```

`manual` first searches the materialized global manual trees for exact matches of:

```text
res/*/manual/<topic>
```

Exact results are resolved by cardinality, not by owner precedence:

```text
exactly one exact match
    select and present that topic

more than one exact match
    fail as ambiguous and present the owner-qualified alternatives

no exact matches
    perform substring fallback
```

An ambiguous exact lookup must not silently prefer `sys`, `ai` or any other owner. Its diagnostic is written to standard error, identifies the ambiguous topic and includes each matching owner-qualified invocation needed to select a specific result. Alternatives are emitted one per line in ascending lexical owner order, for example:

```text
manual ai pkg
manual sys pkg
```

Substring fallback runs only when the exact-match count is zero. It compares the requested `<topic>` literally against each materialized topic leaf and selects topic names matching the conceptual pattern:

```text
*<topic>*
```

The fallback searches topic names, not owner names. Every fallback result is written to standard output in the same qualified identity form used by discovery:

```text
<owner> <topic>
```

Fallback results are sorted in ascending lexical order by owner and then topic. A non-empty fallback result is successful and exits with status `0`. It is a result listing rather than a selected topic, so it is written directly and never invokes `pager`.

If both exact lookup and substring fallback produce no results, the request fails as topic not found.

### 5.3 Owner-qualified lookup

For:

```text
manual <owner> <topic>
```

`manual` resolves exactly:

```text
res/<owner>/manual/<topic>
```

If that owner-local topic exists, it is selected and presented. If it does not exist, the lookup fails; owner-qualified lookup does not perform substring fallback and does not fall back to another owner.

The current global owners remain those defined by `RESOURCE-MODEL.md`; this syntax does not create new owners or a universal resource resolver.

### 5.4 Paging option and output destination

The same exact/fallback lookup semantics apply with `--no-pager`:

```text
manual --no-pager <topic>
manual --no-pager <owner> <topic>
```

For an exactly selected topic, `--no-pager` changes only presentation. It does not change exact lookup, ambiguity or owner qualification.

For a substring-fallback result list, output is direct regardless of `--no-pager`, because no single topic is selected for presentation.

`manual --no-pager` without a topic operand is an invalid invocation.

For a successfully selected exact topic, presentation is:

```text
--no-pager specified
    write the topic directly to standard output

--no-pager absent
    delegate presentation to the technical pager command
```

`pager` owns terminal detection, direct non-terminal output and host-specific interactive backend selection. `manual` does not select `more`, `less` or another host viewer itself.

### 5.5 Exit status and diagnostics

The first-delivery exit-status contract is:

```text
0  success
1  invalid invocation or invalid owner/topic identifier
2  requested topic not found and no substring fallback result exists
3  exact unqualified topic is ambiguous
4  execution/presentation failure
```

Status `0` includes a non-empty substring-fallback result list.

Status `2` applies to an unqualified lookup only after both exact lookup and substring fallback are empty, and to an owner-qualified lookup whose exact owner-local topic does not exist.

Status `4` covers failures after a valid request has been resolved or while discovery/search/presentation is being executed, including inability to emit/read the selected resource and failure of the `pager` command when normal presentation is selected. `manual` maps pager failure to `4`; it does not expose the pager backend's implementation-specific status as its own public contract.

All failure diagnostics are written to standard error. Invalid invocation and ordinary execution failures use the existing structured `m` logging/fatal facilities. An exact ambiguity diagnostic additionally emits the owner-qualified `manual <owner> <topic>` alternatives required to resolve that ambiguity. Failure diagnostics do not write topic content to standard output.

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
- keep technical identifiers, command names, library/function names, literal paths and protocol tokens exact;
- keep product revision behavior factual and observable.

This discipline does not make the initial pages a hidden semantic schema. It keeps them clean enough to migrate later.

## 8. Relationship with command-level help

The first delivery does **not** introduce `--help`, `-h` or another per-command help interface.

Operational reference is accessed through the dedicated manual surface instead of requiring each command to maintain a second independently authored help path.

Any later command-level help contract must be introduced explicitly. Overlapping short help and long operational reference should derive from the same canonical informational source whenever practical rather than drifting independently.

## 9. Paging contract

Paging is a property of the access/viewing layer, not of the canonical operational page content.

For normal presentation, `manual` delegates an exactly selected topic to the technical `pager` command. `pager` is the host-normalizing boundary defined by `PAGER.md`; documentation lookup code therefore does not contain host-specific `more`/`less` policy.

`pager` writes directly when its standard output is not associated with a terminal and selects the appropriate interactive backend when it is associated with a terminal.

When `--no-pager` is specified, `manual` bypasses `pager` for an exactly selected topic and writes that topic directly to standard output.

Discovery and substring-fallback result listings never invoke `pager`.

The first implementation does not expose a `PAGER` environment contract, arbitrary pager command strings or user-selected backend configuration. Backend selection remains owned by `pager`.

A backend change must preserve the canonical topic-content contract and the normal direct-output behavior required for pipelines/redirections.

## 10. Testing and maintenance

Permanent tests protect mechanical properties of the delivered interface, including resource layout, discovery, exact lookup, substring fallback, ambiguity handling, owner qualification, output/paging behavior and exit-status behavior once implemented.

Permanent coverage MUST mechanically detect a RumiAI-owned directly executable command identity that lacks its required owner-local manual topic and a RumiAI-owned library identity that lacks its required owner-local library manual topic. These are one-way completeness checks from command/library identity to manual topic; additional non-command/non-library operational topics remain allowed.

Tests do not make prose normative and cannot prove that a manual page semantically describes behavior accurately. In the initial plain-text model they also cannot prove that every public library function is documented or that no internal helper is presented as API. Those semantic consistency checks remain part of command/library development and the final consistency gate.

Every command modification requires an explicit manual-consistency check. When documented observable behavior changes, the manual topic MUST be updated in the same work unit. A command must not be considered complete while its implementation and operational reference disagree.

Every library modification requires an explicit visibility-naming check and manual-consistency check. Any public-function interface change MUST realign the library manual in the same work unit. A library must not be considered complete while its public/internal naming, implemented public interface and operational reference disagree.

Documentation completeness is not otherwise measured by page count. Additional operational topics may be added when they provide concrete user/developer value.

## 11. Invariants

```text
DOC-01  rumiai-dev remains the normative development-contract source
DOC-02  operational documentation is revision-coupled product reference, not a second development authority
DOC-03  the first operational model is terminal-first plain UTF-8 text with no required transformation pipeline
DOC-04  the first global operational-documentation resource class is manual under res/<owner>/manual/
DOC-05  each initial operational topic is an extensionless content artifact whose leaf is its owner-local topic identity; semantic dot components may belong to that identity
DOC-06  the public operational-documentation access utility is named manual
DOC-07  bare manual discovers all materialized manual topics, always emits each result as <owner> <topic>, and sorts results by owner then topic
DOC-08  discovery follows the general res/*/manual shape and does not semantically depend on the owner name ai
DOC-09  --no-pager bypasses pager for an exactly selected topic; discovery and substring-result listings remain direct output
DOC-10  normal exact-topic presentation delegates to pager; manual does not select host pager backends
DOC-11  unqualified manual lookup gives exact topic matches priority and never applies implicit owner precedence
DOC-12  ambiguous exact unqualified lookup fails and identifies each owner-qualified invocation that resolves the ambiguity
DOC-13  manual <owner> <topic> resolves exactly that owner-local topic with no substring or cross-owner fallback
DOC-14  the first model avoids presentation-specific choices that unnecessarily obstruct later migration
DOC-15  the long-term target separates informational content from channel-specific rendering
DOC-16  long-term documentation build orchestration belongs to mk; runtime manual pages do not require the build toolchain
DOC-17  the first delivery does not introduce per-command --help or -h
DOC-18  paging never changes the canonical page content contract
DOC-19  every command modification includes a manual-consistency check and any resulting documentation realignment occurs in the same work unit
DOC-20  the first-delivery executable is bin/sys/manual, belongs to m, and is bootstrap-integrated through #!/usr/bin/env m
DOC-21  manual uses public exit statuses 0 success, 1 invalid request, 2 not found, 3 exact ambiguity, and 4 execution/presentation failure
DOC-22  every RumiAI-owned directly executable command identity has an owner-local operational manual topic
DOC-23  command creation, rename and removal realign the corresponding manual topic in the same work unit
DOC-24  permanent coverage mechanically detects command identities missing their required manual topic
DOC-25  every RumiAI-owned library identity has exactly one owner-local operational manual topic named <library-name>.lib.<runtime>
DOC-26  a library manual exposes every public function and does not expose internal functions as callable API
DOC-27  library creation, rename, removal and public-interface changes realign the corresponding manual topic in the same work unit
DOC-28  permanent coverage mechanically detects library identities missing their required manual topic
DOC-29  when an unqualified exact lookup has zero matches, manual lists all topic-name substring matches as sorted <owner> <topic> identities; an empty fallback preserves not-found status 2
```
