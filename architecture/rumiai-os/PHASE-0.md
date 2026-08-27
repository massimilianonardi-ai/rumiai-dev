# RumiAI OS — Phase 0 bootstrap architecture

Status: **Accepted**  
Date: 2026-08-28

## Purpose

Phase 0 is the smallest code path that can run before RumiAI knows where its own runtime is located.

It exists only to establish:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

No logger, i18n subsystem, configuration loader, package manager or application logic belongs in this phase.

## Flow

```text
process starts
    ↓
interpret $0
    ↓
PATH lookup only if required
    ↓
physical canonicalization
    ↓
validate bootstrap regular file
    ↓
derive + validate RumiAI_ROOT
    ↓
export + readonly fundamental state
    ↓
remove phase-0 helper state
    ↓
PHASE 1
    ↓
minimal i18n
    ↓
logger
```

## Diagnostics boundary

Success is silent.

Before the logger exists, a controlled phase-0 failure emits only a stable symbolic identifier to stderr and exits with its reserved numeric status.

Host utility diagnostics are suppressed where phase 0 controls their invocation.

Failures that occur before the script itself starts are outside this boundary and cannot be normalized by RumiAI.

## POSIX primitives

The accepted implementation intentionally remains small:

```text
shell parameter expansion
command -v
command -p
realpath -e
[ / test
cd
printf
export
readonly
unset
```

The design does not introduce a custom symlink resolver or a generic path library.

## Root derivation

The canonical executable path is the source of truth.

```sh
RumiAI_ROOT=${RumiAI_BOOTSTRAP_BIN%/*}
[ -n "$RumiAI_ROOT" ] || RumiAI_ROOT=/
```

`dirname` is not needed after canonicalization.

## Phase-1 dependency

The next architectural task is not additional path logic. It is the smallest robust initialization of:

1. message/i18n resolution sufficient for diagnostics;
2. logging infrastructure.

The logger must become the single normal diagnostic path as soon as it is available.
