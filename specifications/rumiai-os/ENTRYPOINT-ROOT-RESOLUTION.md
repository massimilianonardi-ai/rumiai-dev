# RumiAI OS — Entrypoint and Root Resolution

Status: **Normative specification**  
Date: 2026-08-27

## 1. Scope

This specification defines the bootstrap contract for resolving the physical entrypoint pathname and `RUMIAI_ROOT`.

It refines the path requirements in `POSIX-PORTABILITY-LAYER.md` for the `rumiai-os` primary entrypoint.

Normative baseline:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

Normative keywords **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** express requirement strength.

---

## 2. Fundamental state

### ENTRY-ROOT-001 — `RUMIAI_ENTRY`

After successful bootstrap, `RUMIAI_ENTRY` MUST be the absolute physical/canonical pathname of the actual `rumiai-os` executable file.

It MUST:

- be absolute;
- contain no unresolved symbolic-link component;
- contain no effective `.` or `..` component;
- refer to an existing regular file;
- identify the final target when invocation occurred through one or more symbolic links.

### ENTRY-ROOT-002 — `RUMIAI_ROOT`

After successful bootstrap, `RUMIAI_ROOT` MUST be the absolute physical/canonical pathname of the directory containing `RUMIAI_ENTRY`.

It MUST:

- be absolute;
- contain no unresolved symbolic-link component;
- exist;
- be an accessible directory in the bootstrap execution context;
- satisfy a successful:

```sh
cd -- "$RUMIAI_ROOT"
```

### ENTRY-ROOT-003 — no caller-CWD dependency

The resolved values MUST NOT depend on the caller's current working directory except where the caller has intentionally supplied a relative invocation pathname whose meaning is defined relative to that current directory.

Changing to another unrelated current working directory MUST NOT alter the resolved root for equivalent absolute, `PATH`, or symbolic-link invocation.

---

## 3. Supported invocation forms

The bootstrap MUST support at least:

```text
./rumiai-os
relative/path/rumiai-os
/absolute/path/rumiai-os
rumiai-os resolved through PATH
absolute symbolic link
relative symbolic link
symbolic-link chain
symbolic link in an intermediate pathname component
```

### ENTRY-ROOT-004 — `PATH` invocation

When `$0` contains no `/`, the bootstrap MUST resolve the command name through `PATH` using the POSIX `command -v` facility.

Required conceptual operation:

```sh
command -v -- "$0"
```

Failure to resolve the command MUST fail bootstrap.

### ENTRY-ROOT-005 — pathname invocation

When `$0` contains `/`, the bootstrap MUST treat `$0` as the invocation pathname and MUST NOT perform a redundant `PATH` search.

---

## 4. Physical canonicalization

### ENTRY-ROOT-006 — use POSIX `realpath`

The bootstrap MUST delegate physical pathname canonicalization to the POSIX Issue 8 `realpath` utility rather than implementing a custom symbolic-link resolver while that utility satisfies the contract.

Required conceptual operation:

```sh
realpath -- "$RUMIAI_ENTRY"
```

The implementation MUST NOT parse `ls -l` output to discover symbolic-link targets.

The implementation MUST NOT depend on GNU `readlink -f` or GNU-specific `realpath` options.

### ENTRY-ROOT-007 — no mandatory `realpath -e` dependency

The bootstrap MUST NOT require `realpath -e` solely to enforce existence of the entrypoint.

Rationale:

- the entrypoint domain requires the invoked executable to exist already;
- Issue 8 canonicalization is sufficient when the underlying pathname resolution succeeds;
- current reference hosts may expose different subsets of the new Issue 8 CLI options;
- existence is explicitly verified after canonicalization.

A future decision MAY use `-e` if reference-host verification establishes a reason and uniform support relevant to RumiAI.

### ENTRY-ROOT-008 — final regular-file check

After canonicalization, the resolved entrypoint MUST satisfy:

```sh
[ -f "$RUMIAI_ENTRY" ]
```

A dangling link, missing final target, non-regular target, or otherwise invalid entrypoint MUST fail bootstrap.

### ENTRY-ROOT-009 — symbolic-link cycles

A symbolic-link loop/cycle MUST cause bootstrap failure.

The bootstrap SHOULD rely on POSIX pathname resolution / `realpath` to detect the cycle rather than duplicating cycle-detection logic in shell.

---

## 5. Root derivation

### ENTRY-ROOT-010 — parameter expansion is the bootstrap primitive

After `RUMIAI_ENTRY` has been canonicalized and verified as an absolute regular-file pathname, its parent directory MUST be derived with shell parameter expansion:

```sh
RUMIAI_ROOT=${RUMIAI_ENTRY%/*}
[ -n "$RUMIAI_ROOT" ] || RUMIAI_ROOT=/
```

The root-level entrypoint edge case MUST normalize an empty result to `/`.

### ENTRY-ROOT-011 — `dirname` is not used in the accepted bootstrap path

The accepted bootstrap algorithm MUST NOT invoke `dirname` to derive `RUMIAI_ROOT` from the already canonicalized `RUMIAI_ENTRY`.

This is not a general prohibition on `dirname`; it is a local design choice because the constrained canonical input makes parameter expansion sufficient and avoids an unnecessary process/output round trip.

### ENTRY-ROOT-012 — basename if needed

If the basename of the already canonicalized entrypoint is needed in this bootstrap domain, the preferred operation is:

```sh
${RUMIAI_ENTRY##*/}
```

This does not prohibit the POSIX `basename` utility in contexts that require its general semantics.

---

## 6. Root accessibility verification

### ENTRY-ROOT-013 — mandatory `cd` validation

Before exporting `RUMIAI_ROOT`, bootstrap MUST verify:

```sh
(cd -- "$RUMIAI_ROOT")
```

The subshell form is REQUIRED so the validation does not alter the main process current working directory.

Failure MUST fail bootstrap.

---

## 7. CLI delimiter policy

### ENTRY-ROOT-014 — mandatory `--` where supported

All utility invocations in this algorithm MUST comply with the canonical RumiAI `--` policy:

- if the specific utility supports `--` as end-of-options delimiter and at least one operand/data argument is present, `--` MUST be used;
- if zero operands/data arguments are present, `--` MUST NOT be added;
- if the utility does not support that delimiter semantic, it MUST NOT be forced.

For the accepted algorithm this includes, where operands are present:

```sh
command -v -- "$0"
realpath -- "$RUMIAI_ENTRY"
cd -- "$RUMIAI_ROOT"
printf -- ...
```

`test` / `[` MUST NOT receive an invented `--` delimiter because its POSIX syntax is an exception to the general Utility Syntax Guidelines.

---

## 8. Text capture and pathname preservation

### ENTRY-ROOT-015 — trailing newline awareness

The implementation MUST NOT accidentally assume that ordinary shell command substitution preserves trailing newline bytes belonging to a pathname.

If utility output is captured through command substitution, the bootstrap SHOULD use a small sentinel protocol or another proven mechanism that distinguishes:

- the utility's line terminator;
- newline bytes that are part of the pathname data.

This requirement MUST remain local/minimal unless a broader RumiAI serialization requirement emerges.

---

## 9. Accepted algorithm

Conceptually:

```sh
case $0 in
  */*)
    RUMIAI_ENTRY=$0
    ;;
  *)
    RUMIAI_ENTRY=$(command -v -- "$0") || fail
    ;;
esac

RUMIAI_ENTRY=$(realpath -- "$RUMIAI_ENTRY") || fail
[ -f "$RUMIAI_ENTRY" ] || fail

RUMIAI_ROOT=${RUMIAI_ENTRY%/*}
[ -n "$RUMIAI_ROOT" ] || RUMIAI_ROOT=/

(cd -- "$RUMIAI_ROOT") || fail

export RUMIAI_ENTRY RUMIAI_ROOT
```

The actual shell implementation MUST incorporate the pathname-output capture rule from `ENTRY-ROOT-015` where needed.

---

## 10. Required validation matrix

A PoC for this specification MUST include at least:

```text
relative invocation
absolute invocation
PATH invocation
relative symbolic link
absolute symbolic link
symbolic-link chain
symbolic link in an intermediate component
symbolic-link loop -> failure
dangling symbolic link -> failure
pathname with spaces
pathname containing text resembling " -> "
leading-dash pathname component
arbitrary caller CWD
successful cd -- "$RUMIAI_ROOT"
```

Newline-containing pathname cases SHOULD be retained as robustness tests on hosts/filesystems that permit them.

The same test contract SHOULD be run on multiple independent `/bin/sh` implementations and on each reference host before host certification.

---

## 11. Current evidence

Reference PoC:

```text
rumiai-dev-PoCs/pocs/003-entrypoint-symlink-resolution/
```

Consolidation session:

```text
sessions/2026-08-27-linux-local-002/
```

Local Linux result:

```text
dash          14 pass / 0 fail
bash --posix  14 pass / 0 fail
busybox sh    14 pass / 0 fail
TOTAL         42 pass / 0 fail
```

Host-specific runtime certification on the current macOS and Ubuntu LTS references remains a separate validation step.

---

## 12. Failure policy

Bootstrap MUST fail clearly and non-zero when any required invariant cannot be established, including:

- failed `PATH` resolution;
- failed canonicalization;
- symlink loop;
- dangling target;
- final target not a regular file;
- root not accessible by `cd`.

Partial or guessed values MUST NOT be exported as valid fundamental state.
