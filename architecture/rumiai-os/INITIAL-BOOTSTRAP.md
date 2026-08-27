# RumiAI OS — Initial Bootstrap Architecture

Status: **Initial accepted architecture — root resolution consolidated 2026-08-27**  
Date: 2026-08-27

## 1. Scope

This document defines only the first stable bootstrap boundary of `rumiai-os`.

It deliberately excludes package management, software capability resolution, container/image/device deployment and the future complete OS architecture.

The goal is to establish a minimal relocatable system root and a stable entrypoint from which those subsystems can later be loaded.

No implementation may be written into the `rumiai-os` repository during the current initial phase without explicit user approval.

---

## 2. Repository root contract

The root of `rumiai-os` contains only two files plus directories:

```text
rumiai-os/
├── rumiai-os
├── README.md
└── <directories>
```

`rumiai-os` is the unique primary entrypoint and bootstrap executable.

---

## 3. Entrypoint responsibility

The root `rumiai-os` command is a **front controller**, not the implementation of the system.

Its responsibilities are limited to:

1. execute using the interpreter required by its current implementation;
2. determine the real physical/canonical bootstrap executable and RumiAI OS root;
3. verify the root invariant;
4. export the fundamental semantic state;
5. load/delegate to the internal bootstrap implementation;
6. propagate the resulting process exit status.

The initial implementation is expected to be POSIX shell with:

```sh
#!/bin/sh
```

The filename remains `rumiai-os` and does not encode the implementation language.

---

## 4. Fundamental bootstrap state

The canonical exported variables are exactly:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

Their capitalization is part of the contract.

### `RumiAI_BOOTSTRAP_BIN`

`RumiAI_BOOTSTRAP_BIN` is the absolute physical/canonical pathname of the actual `rumiai-os` regular file after all symbolic links and pathname indirections have been resolved.

It must be absolute, contain no unresolved symlink or effective `.`/`..` component, and refer to an existing regular file.

### `RumiAI_ROOT`

`RumiAI_ROOT` is the absolute physical/canonical directory containing `RumiAI_BOOTSTRAP_BIN`.

It must exist and satisfy:

```sh
cd -- "$RumiAI_ROOT"
```

The validation is executed in a subshell so it does not mutate the main process current working directory.

All RumiAI-managed paths must ultimately derive from this root or from semantic roots explicitly configured by the system.

---

## 5. Invocation contract

The bootstrap supports relative invocation, absolute invocation, invocation through `PATH`, and invocation through one or more symbolic links.

Equivalent invocations must resolve to the same physical RumiAI root regardless of the caller's unrelated current working directory.

When invoked through symbolic links, the location of the final real executable defines the root, not the directory containing the externally visible link.

Symbolic-link cycles and dangling links are errors and must fail bootstrap rather than producing guessed or partial state.

---

## 6. Accepted root-resolution algorithm

If `$0` contains `/`, it is used as the invocation pathname. Otherwise the bootstrap resolves it through `PATH` with:

```sh
command -v -- "$0"
```

The resulting pathname is canonicalized with POSIX.1-2024 Issue 8 `realpath`:

```sh
realpath -- "$RumiAI_BOOTSTRAP_BIN"
```

The canonical result must satisfy:

```sh
[ -f "$RumiAI_BOOTSTRAP_BIN" ]
```

The root is derived with:

```sh
RumiAI_ROOT=${RumiAI_BOOTSTRAP_BIN%/*}
[ -n "$RumiAI_ROOT" ] || RumiAI_ROOT=/
```

and validated with:

```sh
(cd -- "$RumiAI_ROOT")
```

Only after successful validation is fundamental state exported:

```sh
export RumiAI_BOOTSTRAP_BIN RumiAI_ROOT
```

Bootstrap errors terminate the top-level command with a non-zero status, normally `exit 1`, optionally after emitting a diagnostic. No `fail` command is part of the architecture.

---

## 7. Why `dirname` is not used here

After `realpath`, `RumiAI_BOOTSTRAP_BIN` has a deliberately constrained domain: absolute, canonical, regular file, no trailing slash.

For this domain:

```sh
${RumiAI_BOOTSTRAP_BIN%/*}
```

is preferred because it expresses exactly the required operation without a subprocess or output recapture.

If the basename is later needed in the same constrained domain, prefer:

```sh
${RumiAI_BOOTSTRAP_BIN##*/}
```

This is a local bootstrap design decision, not a project-wide prohibition of `dirname` or `basename`.

---

## 8. POSIX baseline and host behavior

The normative baseline is:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

Issue 8 provides the standard `realpath` facility needed by this design.

The bootstrap intentionally does not require `realpath -e` merely to establish entrypoint existence. The final target is checked explicitly after canonicalization.

Any real divergence discovered on a reference host is handled under the canonical POSIX baseline-evolution rule; the algorithm is not pre-emptively expanded with host-specific branches.

---

## 9. Pathname capture

When pathname output is captured through shell command substitution, the implementation must account for removal of trailing newlines.

The validated PoC uses a small sentinel protocol to preserve pathname newline data while removing the utility's line terminator.

---

## 10. Evidence

Normative detail:

```text
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
```

Analysis:

```text
analysis/rumiai-os/2026-08-27-entrypoint-root-resolution.md
```

PoC:

```text
rumiai-dev-PoCs/pocs/003-entrypoint-symlink-resolution/
```

The archived `linux-local-002` session predates the final variable-name decision and is retained as historical evidence rather than rewritten.

Runtime certification on the current reference macOS and Ubuntu LTS remains a separate validation step.

---

## 11. Internal delegation boundary

After validated root discovery, the entrypoint delegates to code located below the repository root.

Conceptually:

```text
rumiai-os
   │
   ├─ resolve physical RumiAI_BOOTSTRAP_BIN
   ├─ derive + verify RumiAI_ROOT
   │
   └─ delegate
          │
          ▼
   internal bootstrap
```

The exact internal directory names remain intentionally unfrozen.

---

## 12. Authorization boundary

An accepted architecture or successful PoC does not authorize writes to the `rumiai-os` repository during the current initial phase.

Promotion from `rumiai-dev-PoCs` into `rumiai-os` requires explicit user approval.
