# Handoff — RumiAI OS phase 0 implemented

Date: 2026-08-28  
Status: **active design/implementation handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

---

## Current implementation state

The user explicitly authorized implementation of phase 0 in the product repository.

`rumiai-os` is no longer empty.

Current product entrypoint:

```text
massimilianonardi-ai/rumiai-os/rumiai-os
```

Git mode:

```text
100755
```

Shebang:

```sh
#!/bin/sh
```

No other product subsystem has been implemented yet.

---

## POSIX baseline

Current normative baseline:

> **POSIX.1-2024 / The Open Group Base Specifications Issue 8**

A correction was made during phase-0 implementation: Issue 8 explicitly provides `realpath -e` and `-E` and portable applications should choose one rather than depend on implementation-specific default behavior.

Because RumiAI phase 0 requires the complete bootstrap pathname to exist, the accepted form is:

```sh
command -p -- realpath -e -- "$RumiAI_BOOTSTRAP_BIN"
```

The previous decision to avoid requiring `-e` is superseded.

---

## Fundamental state

Exact exported names:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

They are exported only after successful validation and then marked readonly in the bootstrap shell.

`RumiAI_BOOTSTRAP_BIN` is the absolute physical/canonical pathname of the actual product entrypoint.

`RumiAI_ROOT` is its absolute physical/canonical containing directory and must satisfy:

```sh
cd -- "$RumiAI_ROOT"
```

---

## Phase-0 diagnostics

Success produces no output.

Controlled failures after script execution has begun suppress underlying utility diagnostics and emit only one stable language-neutral identifier on stderr plus a reserved numeric exit status.

Current mapping:

```text
RumiAI_BOOTSTRAP_FATAL_PATH_RESOLUTION_ERROR = 10
RumiAI_BOOTSTRAP_FATAL_REALPATH_ERROR        = 11
RumiAI_BOOTSTRAP_FATAL_BIN_ERROR             = 12
RumiAI_BOOTSTRAP_FATAL_ROOT_ERROR            = 13
```

This is not yet the normal RumiAI logger. It is the smallest diagnostic contract available before logger/i18n initialization.

Failures that prevent the script itself from starting are outside phase 0. For example, a symbolic-link loop in the entrypoint pathname may be rejected by the kernel/shell before any RumiAI code runs; such a failure can produce host diagnostics and host-defined status.

---

## Accepted phase-0 flow

```text
$0
 ├─ contains / -> invocation pathname
 └─ no /       -> command -v using current PATH
                         ↓
              require absolute PATH result
                         ↓
       command -p -- realpath -e -- pathname
                         ↓
               require existing regular file
                         ↓
     RumiAI_ROOT=${RumiAI_BOOTSTRAP_BIN%/*}
                         ↓
              (cd -- "$RumiAI_ROOT")
                         ↓
       export + readonly fundamental state
                         ↓
              remove phase-0 helper state
                         ↓
                      PHASE 1
```

`dirname`/`basename` are not used for the constrained post-canonicalization operation.

A sentinel capture mechanism is retained to avoid accidental loss of trailing newline bytes in pathnames when utility output is captured with command substitution.

---

## Canonical files

```text
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
architecture/rumiai-os/PHASE-0.md
decisions/rumiai-os/2026-08-28-phase-0-bootstrap.md
```

Older root-resolution documents remain historical context but the above material supersedes incompatible details, especially plain `realpath` without explicit `-e`/`-E`.

---

## Validation performed during implementation

The exact phase-0 structure was exercised locally with:

```text
dash
bash --posix
busybox sh
```

The normal success path completed with status 0 and no stdout/stderr in those local checks.

PATH and normal symbolic-link invocation were also exercised locally against the same algorithm.

This does **not** replace the planned physical/reference-host certification.

---

## Immediate next work

Do not broaden phase 0 unless a concrete defect emerges.

The next design task is **phase 1 logger initialization**.

Before implementing it:

1. audit the logger concepts in the current/historical `massimilianonardi/m` material;
2. preserve useful concepts such as levels, filtering, trace metadata, staged formatting and language/message resolution;
3. do not migrate unsafe `eval`-based code/data interpretation;
4. define a minimal i18n/message-ID layer sufficient for the logger to be internationalized from its first normal diagnostic;
5. keep logging separate from lifecycle: logging `fatal` must not itself imply `exit` unless an explicit top-level wrapper chooses that behavior.

Reference-host physical tests for phase 0 can be performed after the phase-1 boundary is sufficiently defined, so the tested bootstrap segment is not immediately obsolete.
