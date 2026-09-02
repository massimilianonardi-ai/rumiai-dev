# RumiAI OS — Phase 0 bootstrap architecture

Status: **Accepted architecture**  
Date: 2026-08-28  
Updated: 2026-09-02

## Purpose

Phase 0 is the smallest code path that runs before RumiAI knows its own physical runtime root.

It establishes exactly the fundamental exported environment state:

```text
m_BOOTSTRAP_BIN
m_ROOT
```

The `m_*` prefix is the canonical namespace for RumiAI-owned environment variables. It does not define a general function namespace.

No language selection, logger implementation, package manager or application logic belongs to root discovery.

## Entrypoint

The physical product bootstrap remains:

```text
<rumiai-root>/rumiai-os
```

with:

```sh
#!/bin/sh
```

The root repository contract remains relocatable; no installation pathname is hardcoded.

## Resolution flow

Conceptual flow:

```text
process starts
    ↓
interpret $0
    ↓
if $0 has no slash:
    prefer an existing ./<name> invocation object,
    otherwise resolve through caller PATH
    ↓
validate that the invocation pathname exists
    ↓
physical canonicalization with standard realpath
    ↓
validate canonical pathname exists
    ↓
validate bootstrap is a regular file
    ↓
derive m_ROOT from m_BOOTSTRAP_BIN
    ↓
validate m_ROOT is accessible
    ↓
export + readonly m_BOOTSTRAP_BIN and m_ROOT
    ↓
PHASE 1
```

The stable path rule remains:

```text
VALIDATE EXISTENCE
→ CANONICALIZE EXISTING PATH
→ VALIDATE REQUIRED TYPE
```

`realpath` is used as a canonicalizer of an already-existing pathname, not as the existence classifier.

## Invocation support

The bootstrap supports:

```text
relative pathname
absolute pathname
PATH invocation
symbolic-link invocation
symbolic-link chains/intermediate symlinks supported by realpath
arbitrary caller CWD
```

The physical canonical target of `rumiai-os` defines `m_ROOT`; the location of an external invocation symlink does not.

## Pathname capture

Where command substitution captures pathname-producing utility output, the implementation must preserve shell-representable pathname data against trailing-newline stripping. The current baseline uses a sentinel technique for the critical path resolution helper.

This is an implementation detail of exact data capture, not a second path-resolution model.

## Diagnostics boundary

Before the normal logger is active, bootstrap failures use the minimal bootstrap diagnostic path and terminate non-zero. The previously drafted multi-code Phase-0 mapping is not retained as a current invariant unless separately re-established.

Success remains silent until normal runtime behavior requires output.

## Phase boundary

Phase 0 is complete when:

```text
m_BOOTSTRAP_BIN is absolute, physical/canonical and a regular file
m_ROOT is the physical/canonical containing directory and is accessible
both are exported
both are readonly in the bootstrap shell
```

Phase 1 then establishes the runtime directories, `PATH`, `lang`, logger and command/shell execution environment.
