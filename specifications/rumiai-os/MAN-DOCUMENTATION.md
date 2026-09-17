# RumiAI OS — Operational manual documentation

Status: **Current / normative**  
Updated: 2026-09-17

This specification defines the operational manual-reference surface distributed with `rumiai-os`.

The purpose is to let users and developers inspect the usage and current operational behavior of the installed/current product without requiring `rumiai-dev`, Git history or conversation context.

## 1. Authority boundary

`rumiai-dev` remains authoritative for development rules, architecture and semantic subsystem contracts.

Manual pages distributed with `rumiai-os` are **revision-coupled operational reference**. They describe how the corresponding product revision is used and what its public operational interface does; they are not a second development-specification authority and do not override current `rumiai-dev` contracts.

A conflict between a current specification, implementation, manual page and permanent test is a consistency defect. Apply the normal authority hierarchy and realign the affected surfaces in the same work unit when possible.

Operational examples, invocation guidance and user-oriented explanation should prefer the manual once a page exists. Normative invariants, ownership boundaries, architectural rationale required for development and forward constraints remain in current specifications.

## 2. Resource ownership and layout

Operational manual pages are distributed static resources under the existing global resource model.

The concrete resource class is:

```text
man
```

The layout is:

```text
$m_RES_DIR/<owner>/man/<topic>
```

with the current global owners defined by `RESOURCE-MODEL.md`.

Examples:

```text
res/sys/man/m
res/sys/man/man
res/ai/man/rumiai-os
```

A manual page belongs to the owner whose public operational surface it documents. `m` technical topics therefore belong under `sys`; branded RumiAI topics belong under `ai`.

The `man` resource class does not create a new top-level filesystem root, mutable state area, universal resource resolver or package-resource projection.

Package-owned documentation remains package-local unless a future explicit contract defines package-manual integration.

## 3. Topic identifiers and source format

`<owner>` and `<topic>` are RumiAI-controlled pathname components and follow `FILESYSTEM-NAMING.md`.

A manual source is a regular readable UTF-8 plain-text file with no implementation-language or renderer suffix. The file itself is the distributed renderable representation: the baseline does not require roff, `nroff`, `groff`, a host `man` database, a pager or terminal-formatting library.

Pages use conventional uppercase section headings where useful. Command pages should normally contain at least:

```text
NAME
SYNOPSIS
DESCRIPTION
EXIT STATUS
SEE ALSO
```

Additional sections such as `OPTIONS`, `OPERANDS`, `ENVIRONMENT`, `FILES`, `EXAMPLES` or `NOTES` are included only when they add operational value.

These headings are a documentation convention, not a parser grammar. The `man` command treats page content as data and emits it unchanged.

## 4. Public `man` command

The technical public command is:

```text
man
```

It belongs to `m` and is a bootstrap-integrated command under:

```text
bin/sys/man
```

It uses the current integrated-command contract from `COMMAND-ENTRYPOINTS.md`.

Within the `m` runtime PATH, this command intentionally provides the RumiAI operational-manual interface. It does not proxy or merge a host operating system's manual database.

## 5. Command interface

The public forms are:

```text
man
man <topic>
man <owner>/<topic>
```

No other operand count is valid.

### 5.1 Listing

With no operands, `man` lists every readable valid page found under materialized global trees of the form:

```text
$m_RES_DIR/*/man/<topic>
```

Each output line is qualified as:

```text
<owner>/<topic>
```

The list is sorted in bytewise (`C` locale) order and followed by normal newline termination.

The implementation discovers owners from the general resource-tree shape and must not encode a semantic dependency on the branded owner name `ai`.

### 5.2 Unqualified lookup

With one unqualified `<topic>` operand, `man` searches every materialized global manual tree.

- exactly one readable matching page: emit that page unchanged and succeed;
- no readable matching page: fail with exit status `1`;
- more than one readable matching page: fail with exit status `2` because the topic is ambiguous.

An ambiguous topic is resolved by using the qualified form.

### 5.3 Qualified lookup

With `<owner>/<topic>`, both components must be valid controlled names and the operand must contain exactly one `/` separator.

The command reads exactly:

```text
$m_RES_DIR/<owner>/man/<topic>
```

when it is a regular readable file. A missing or unreadable page fails with exit status `1`.

The command never evaluates page content as shell code.

## 6. Exit status

The public exit-status classes are:

```text
0  requested operation completed successfully
1  requested page was not available/readable or page output failed
2  invalid arguments, invalid identifier or ambiguous unqualified topic
```

An underlying bootstrap failure remains governed by the normal `m` runtime contract.

## 7. Localization baseline

The initial operational manual language is English.

Manual selection is **not** coupled to `lang-set`, `res/*/lang/current` or `m_LANGUAGE_FALLBACK`. The `man` tree has no locale selector in this baseline.

This is deliberate: product/user-facing manual localization is a separate requirement from technical message localization. A future localization design must update this contract explicitly rather than inferring a locale hierarchy from the `lang` resource class.

## 8. Relationship with command-level help

This contract does not introduce `--help`, `-h` or command-specific help flags for existing commands.

Long-form operational reference is provided by `man`. If short command help is introduced later, its source/maintenance model must avoid creating a second independently maintained copy of the same usage contract.

## 9. Maintenance and consistency

A public-interface change that makes an existing manual page inaccurate requires the page to be updated in the same authorized work unit whenever practical.

Permanent tests should protect the mechanical contract of the manual surface, including as applicable:

- the real `man` entrypoint and its exit statuses;
- owner-qualified discovery without a hardcoded `ai` dependency;
- qualified and unqualified lookup;
- ambiguity handling;
- exact data output of selected page files;
- controlled page/resource layout and file modes when those are part of the contract.

Tests do not make manual prose normative. They establish that the product exposes the documented manual mechanism and that revision-coupled pages remain mechanically reachable.

Manual coverage may be introduced incrementally while this task is active. A page must not be advertised as current coverage before it exists in the corresponding product revision.

## 10. Specification migration rule

The existence of operational manual pages does not justify deleting semantic contracts from `rumiai-dev`.

When a specification contains user-oriented examples or invocation explanation that no longer contributes to the normative development contract, that material may be reduced after equivalent operational coverage exists in the manual. The change must leave the specification independently sufficient for development and must follow the normal documentation consistency gate.

Do not move architectural ownership, invariants, security/portability constraints or other forward requirements into product manual prose merely to shorten specifications.

## 11. Invariants

```text
MAN-01  operational manual pages are revision-coupled product resources, not a second development-specification authority
MAN-02  global manual resources use res/<owner>/man/<topic>
MAN-03  man belongs to the technical m layer and lives at bin/sys/man
MAN-04  man discovers global manual owner trees generically and does not encode a semantic dependency on ai
MAN-05  manual sources are regular readable UTF-8 plain-text data and require no host man/roff/pager baseline
MAN-06  zero-argument man lists qualified owner/topic identifiers in bytewise sorted order
MAN-07  unqualified lookup succeeds only when exactly one global owner provides the topic
MAN-08  qualified lookup uses exactly owner/topic and validates both controlled-name components
MAN-09  unavailable pages fail with 1; invalid or ambiguous requests fail with 2
MAN-10  the initial manual language is English and is independent of lang-set
MAN-11  this contract does not introduce command-level --help/-h behavior
MAN-12  package documentation is not projected into the global man resource class
MAN-13  manual content is emitted as data and is never evaluated as shell code
```