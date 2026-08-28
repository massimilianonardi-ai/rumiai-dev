# Handoff — Phase 1 physical reference-host cycle complete

Date: 2026-08-28
Status: **first physical Phase 1 reference-host cycle complete — PASS**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Physically validated product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

No product changes are pending from the completed Ubuntu test cycle.

## Physical reference hosts completed

### macOS

The first physical macOS Phase 1 cycle is complete and passing.

Important host-specific finding during the cycle:

```text
native macOS realpath -e -> unsupported
native macOS realpath -- -> supported
```

This caused the product correction:

```text
c245cff5d1bec949f72be9f8b41c77789978342b
```

The Apple Bash deprecation banner found during interactive-shell testing caused the later UX correction:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

After that commit, the complete macOS matrix passed.

Detailed report:

```text
drafts/rumiai-os/phase-1-command-interpreter/PHYSICAL-MACOS.md
```

### Ubuntu 26.04 LTS / aarch64

Reference host:

```text
Ubuntu 26.04 LTS (Resolute Raccoon)
Linux 7.0.0-30-generic
aarch64
/bin/sh -> /usr/bin/dash
```

The complete corresponding Phase 1 matrix passed without requiring any further product change.

Detailed report:

```text
drafts/rumiai-os/phase-1-command-interpreter/PHYSICAL-UBUNTU-26.04.md
```

## Cross-host passes

The following principal behaviors now have physical evidence on both macOS and Ubuntu 26.04/aarch64:

- runtime/root canonical discovery;
- product relocation under temporary roots;
- explicit source execution without shebang/executable bit;
- direct `#!/usr/bin/env rumiai-os` host execution;
- structural `bin/rumiai-os -> ../rumiai-os` exposure;
- exact argument and source-status propagation;
- public logger and statuses `12..16`;
- localized logger output and threshold filtering;
- Bash Rumi shell;
- POSIX `sh` Rumi shell;
- relative and absolute runtime invocation;
- PATH invocation;
- relative and absolute symbolic links;
- symbolic-link chains;
- symbolic link in intermediate pathname component;
- pathnames containing spaces;
- relative PATH component from arbitrary caller CWD;
- explicit source with spaces and source symlink chains;
- language precedence and locale fallback;
- bootstrap language config precedence and malformed-config behavior;
- text-encoding normalization/fallback and malformed-config behavior;
- sourced-command `return`, natural fall-through failure, `exit` and SIGTERM;
- clean worktree after tests.

## Ubuntu final i18n/config result

Observed language behavior matched macOS:

```text
config > LC_ALL > LC_MESSAGES > LANG > en_US fallback
C -> en_US
utf8 -> UTF-8
```

Unsupported language and encoding values produced the expected fallback warnings in the selected catalog language.

Malformed multi-line bootstrap config files were rejected and fallback continued correctly.

All diagnostic i18n/config invocations returned `0`.

## Ubuntu final source lifecycle result

Observed:

```text
return 41       -> 41
final false     -> 1
exit 42         -> 42
SIGTERM         -> 143
```

No command after `return`, `exit` or SIGTERM executed.

The host shell message:

```text
Terminato
```

was the normal localized signal diagnostic from the Ubuntu caller shell, not RumiAI output.

Final Ubuntu worktree:

```text
git status --short -> empty
```

## Consolidated validation state

The general validation document has been rewritten to reflect completion of this first host cycle:

```text
drafts/rumiai-os/phase-1-command-interpreter/VALIDATION.md
```

Current conclusion:

- Phase 1 first physical reference-host cycle: **PASS**;
- macOS: **PASS**;
- Ubuntu 26.04/aarch64 with dash: **PASS**;
- current product commit: `4f311d1fb5b35a722cf9575d890a9fa616040199`;
- no currently known product defect from these matrices.

## Validation boundary

This is not universal portability certification.

Not every designed bootstrap/CLI failure status `1..10` has yet been physically forced on both hosts. Broader host coverage also remains possible.

## Recommended next work

Before adding Phase 2 functionality, the highest-value next validation step is to turn the now-stable physical matrix into a repeatable regression suite and add deliberate negative-path forcing for bootstrap/CLI statuses `1..10` where practical.

After that, the project can either:

1. continue reference-host expansion (additional Linux/macOS architectures and later Cygwin), or
2. begin the next functional phase while keeping the Phase 1 regression suite as a portability gate.

The repository remains the source of truth; on resume, read the newest file in `handoff/` rather than assuming this filename is still current.
