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
realpath -e physical canonicalization
    ↓
validate bootstrap regular file
    ↓
derive + validate RumiAI_ROOT
    ↓
export + readonly fundamental state
    ↓
remove phase-0 internal state
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

The implementation intentionally remains small:

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

There is no custom symlink resolver, generic path library or output-capture helper in phase 0.

## Controlled naming simplifies phase 0

RumiAI-controlled filesystem names follow:

```text
specifications/rumiai-os/FILESYSTEM-NAMING.md
```

The real entrypoint final component is fixed as:

```text
rumiai-os
```

and RumiAI-controlled names do not contain whitespace/control characters such as newline.

Therefore phase 0 does not preserve arbitrary trailing-newline filename data with a sentinel protocol. Ordinary command substitution is sufficient for the two utility outputs it captures.

This does **not** mean RumiAI assumes all external filenames are simple. User/external path components remain opaque data and may contain spaces or newlines. Newlines in parent components are embedded inside the complete canonical executable pathname and are preserved; an externally named direct symlink is preserved in `$0` before canonicalization.

## PATH resolution

When `$0` contains no slash, phase 0 uses the caller's current `PATH`:

```sh
command -v -- "$0"
```

The result is not required to be absolute. Relative `PATH` components are valid input to the subsequent canonicalization step.

## Canonicalization

Phase 0 uses:

```sh
command -p -- realpath -e -- "$RumiAI_BOOTSTRAP_BIN"
```

`realpath -e` is the single physical canonicalization boundary.

## Root derivation

The canonical executable pathname is the source of truth:

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
