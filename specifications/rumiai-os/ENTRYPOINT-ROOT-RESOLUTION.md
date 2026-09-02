# RumiAI OS — Entrypoint and Root Resolution

Status: **Normative specification**  
Date: 2026-08-29  
Updated: 2026-09-02

## 1. Scope

This specification defines root resolution for the physical `rumiai-os` bootstrap.

The resulting RumiAI-owned environment variables are:

```text
m_BOOTSTRAP_BIN
m_ROOT
```

Normative baseline:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**, plus the explicitly validated host profile used by the bootstrap.

## 2. Fundamental state

### `m_BOOTSTRAP_BIN`

After successful resolution, `m_BOOTSTRAP_BIN` MUST be the absolute physical/canonical pathname of the actual `rumiai-os` regular file.

It MUST identify the final physical target even when invocation occurred through one or more symbolic links.

### `m_ROOT`

`m_ROOT` MUST be the physical/canonical directory containing `m_BOOTSTRAP_BIN` and MUST be accessible to the bootstrap execution context.

The root is derived from the canonical bootstrap pathname rather than the caller CWD or an external symlink location.

### Export and immutability

After successful validation:

```sh
export -- m_BOOTSTRAP_BIN m_ROOT
readonly -- m_BOOTSTRAP_BIN m_ROOT
```

The variables MUST NOT be exported before their invariants succeed.

## 3. Invocation pathname

If `$0` contains `/`, it is treated as the invocation pathname.

If `$0` contains no `/`, the current bootstrap first accepts an existing or symbolic-link pathname in the caller CWD as `./$0`; otherwise it resolves `$0` through the caller's `PATH` with `command -v`.

This behavior is part of the stabilized bootstrap baseline.

## 4. Existing-path canonicalization

The canonical rule is:

```text
VALIDATE EXISTENCE
→ CANONICALIZE EXISTING PATH
→ VALIDATE REQUIRED TYPE
```

Before canonicalization, the selected pathname MUST resolve to an existing object.

Canonicalization uses the standard utility path and optionless `realpath` on that existing pathname:

```sh
command -p -- realpath -- "$pathname"
```

The canonical result MUST itself resolve to an existing object.

RumiAI does not depend on `realpath -e`, GNU `readlink -f`, parsing `ls -l`, or optionless `realpath` behavior for a missing final component.

The current implementation may encapsulate this contract in a reusable helper; the helper's spelling is not itself a public API.

## 5. Bootstrap type and root validation

After canonicalization:

```sh
[ -f "$m_BOOTSTRAP_BIN" ]
```

MUST succeed.

Root derivation is conceptually:

```sh
m_ROOT=${m_BOOTSTRAP_BIN%/*}
[ -n "$m_ROOT" ] || m_ROOT=/
```

and the bootstrap MUST verify that the root can be entered without changing the main process CWD, for example through a subshell.

## 6. Pathname data preservation

POSIX command substitution removes trailing newline bytes. Pathname-producing utility output captured by the bootstrap MUST therefore use a protocol that preserves the shell-representable pathname domain required by the bootstrap.

The current product baseline uses a non-newline sentinel around command-substitution capture. A future simplification is allowed only if it preserves the same accepted pathname behavior.

## 7. Reuse for command entry

The same existing-path canonicalization contract is reused when resolving the first command/source operand.

After canonicalization, command entry separately validates that the result is a readable regular file and is not the bootstrap itself.

The successful canonical command pathname is exposed as:

```text
m_COMMAND_BIN
```

## 8. Diagnostics

Success of root resolution produces no normal diagnostic output.

A controlled failure before the normal logger is active terminates non-zero through the bootstrap-safe diagnostic path. The previous draft's fixed `RumiAI_BOOTSTRAP_FATAL_*` environment-style identifiers/status mapping is not a current naming or status invariant.

## 9. Required behavioral coverage

Permanent validation of this contract should cover at least:

```text
relative invocation
absolute invocation
PATH invocation
caller-CWD independence
relative/absolute symlink invocation
symlink chains and intermediate symlinks
canonical regular-file result
accessible canonical root
missing/unresolvable invocation failure
command/source reuse of the same canonicalization contract
```

Tests written against superseded `RumiAI_*` variable names must be updated before being considered guards for the current contract.
