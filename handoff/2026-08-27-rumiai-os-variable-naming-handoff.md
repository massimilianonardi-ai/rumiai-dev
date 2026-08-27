# Handoff — RumiAI OS bootstrap variable naming

Date: 2026-08-27  
Status: **active design handoff — supersedes older handoff state where newer**

## 1. Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

No content in this handoff authorizes modifications to `rumiai-os` without explicit user consent.

---

## 2. Current POSIX baseline

The initial baseline remains:

> **POSIX.1-2024 / The Open Group Base Specifications Issue 8**

The baseline evolves only when a concrete validated RumiAI requirement justifies evaluating a later standard.

---

## 3. Canonical bootstrap variable names

The fundamental exported bootstrap variables are now fixed exactly as:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

Capitalization is normative.

### `RumiAI_BOOTSTRAP_BIN`

Absolute physical/canonical pathname of the actual `rumiai-os` executable after all symbolic links and pathname indirections have been resolved.

### `RumiAI_ROOT`

Absolute physical/canonical pathname of the directory containing `RumiAI_BOOTSTRAP_BIN`.

Required runtime invariant:

```sh
cd -- "$RumiAI_ROOT"
```

must succeed. Bootstrap validates it without changing the main current working directory using:

```sh
(cd -- "$RumiAI_ROOT")
```

The former contract names:

```text
RUMIAI_ENTRY
RUMIAI_ROOT
```

are superseded. They may remain in archived analyses or PoC sessions created before the naming decision and must be interpreted as historical evidence, not current API names.

Canonical sources now updated:

```text
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
architecture/rumiai-os/INITIAL-BOOTSTRAP.md
decisions/rumiai-os/2026-08-27-entrypoint-root-resolution.md
```

---

## 4. Accepted resolution algorithm

1. If `$0` contains `/`, use it as the invocation pathname.
2. Otherwise resolve through `PATH` with `command -v -- "$0"`.
3. Canonicalize with POSIX Issue 8 `realpath -- "$RumiAI_BOOTSTRAP_BIN"`.
4. Require `[ -f "$RumiAI_BOOTSTRAP_BIN" ]`.
5. Derive:

```sh
RumiAI_ROOT=${RumiAI_BOOTSTRAP_BIN%/*}
[ -n "$RumiAI_ROOT" ] || RumiAI_ROOT=/
```

6. Require `(cd -- "$RumiAI_ROOT")`.
7. Export only after all invariants succeed:

```sh
export RumiAI_BOOTSTRAP_BIN RumiAI_ROOT
```

`dirname` is not used in this constrained post-`realpath` path. If a basename is needed in the same domain, prefer `${RumiAI_BOOTSTRAP_BIN##*/}`.

---

## 5. Failure semantics

There is no POSIX command named `fail` in the accepted design.

Earlier occurrences of `fail` were pseudocode meaning "terminate bootstrap with failure".

Top-level bootstrap errors use a non-zero process exit status, normally:

```sh
exit 1
```

A diagnostic may be written to stderr first.

Reusable library functions should normally `return` a status rather than terminate their caller unless termination is explicitly their contract.

---

## 6. PoC state

Current PoC:

```text
rumiai-dev-PoCs/pocs/003-entrypoint-symlink-resolution/
```

The current PoC subject and test harness have been updated to use:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

The archived session:

```text
sessions/2026-08-27-linux-local-002/
```

predates this naming decision and remains untouched as historical evidence. It recorded 42 pass / 0 fail across `dash`, `bash --posix`, and BusyBox `sh` for the resolver behavior under the former variable names.

No new physical/reference-host test session has been run yet after the naming change.

---

## 7. Immediate next work

Before any product implementation, discuss and execute the physical/reference-host validation strategy for the current PoC on the selected Ubuntu LTS and macOS environments.

If a real host divergence appears, analyze only that concrete divergence under the established POSIX baseline rule.

`rumiai-os` remains untouched until explicit user authorization.
