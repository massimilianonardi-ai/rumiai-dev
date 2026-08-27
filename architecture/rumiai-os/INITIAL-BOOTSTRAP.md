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

`rumiai-os` is the unique primary entrypoint.

`README.md` is the root-level human documentation entrypoint.

No additional regular file is introduced at repository root without a new architectural decision.

---

## 3. Entrypoint responsibility

The root `rumiai-os` command is a **front controller**, not the implementation of the system.

Its responsibilities are limited to:

1. execute using the interpreter required by its current implementation;
2. determine the real physical/canonical RumiAI OS entrypoint and root according to the accepted bootstrap contract;
3. verify the root invariant;
4. export the fundamental semantic state;
5. load/delegate to the internal bootstrap implementation;
6. propagate the resulting process exit status.

The initial implementation is expected to be POSIX shell with:

```sh
#!/bin/sh
```

but the filename remains `rumiai-os` and does not encode the implementation language. A future reimplementation using another approved runtime must not require renaming the public command.

The entrypoint must not accumulate package-manager, deployment, application, AI, or host-specific logic.

---

## 4. Naming contract

Executable commands use semantic names without extensions that expose the interpreter or implementation language.

Examples:

```text
rumiai-os
pkg
path
install
```

not:

```text
rumiai-os.sh
pkg.sh
path.py
install.js
```

Files sourced by shell code use semantic extensions. Initial conventions include:

```text
*.lib   sourced libraries
*.conf  configuration
```

Language extensions remain valid for source artifacts whose identity is genuinely tied to the source language, such as `.c`, `.cpp`, `.java`, or pure-source `.js` files.

---

## 5. Fundamental root state

The bootstrap exposes at least:

```text
RUMIAI_ENTRY
RUMIAI_ROOT
```

### `RUMIAI_ENTRY`

`RUMIAI_ENTRY` is the absolute physical/canonical pathname of the actual `rumiai-os` regular file after all symbolic links and pathname indirections have been resolved.

It must:

- be absolute;
- have all symlinks resolved, including intermediate components;
- contain no effective `.` or `..` components;
- refer to an existing regular file.

### `RUMIAI_ROOT`

`RUMIAI_ROOT` is the absolute physical/canonical directory containing `RUMIAI_ENTRY`.

It must:

- exist;
- be a directory that can be entered in the bootstrap execution context;
- satisfy:

```sh
cd -- "$RUMIAI_ROOT"
```

The validation is executed in a subshell so it does not mutate the main process current working directory.

All RumiAI-managed paths must ultimately derive from this root or from semantic roots explicitly configured by the system.

---

## 6. Invocation contract

The bootstrap supports:

```text
./rumiai-os
relative/path/rumiai-os
/absolute/path/rumiai-os
PATH=/some/location:$PATH rumiai-os
invocation through one or more symbolic links
```

Equivalent invocations must resolve to the same physical RumiAI root regardless of the caller's unrelated current working directory.

When invoked through symbolic links, the location of the final real executable defines the root, not the directory containing the externally visible link.

Symbolic-link cycles and dangling links are errors and must fail bootstrap rather than producing guessed or partial state.

---

## 7. Accepted root-resolution algorithm

The bootstrap algorithm is now consolidated.

### Step 1 — resolve command-name invocation only when needed

If `$0` contains `/`, it is used as the invocation pathname.

If `$0` contains no `/`, resolve it through `PATH` with:

```sh
command -v -- "$0"
```

A failure is fatal.

### Step 2 — physical canonicalization

Canonicalize the invocation pathname with the POSIX.1-2024 Issue 8 utility:

```sh
realpath -- "$RUMIAI_ENTRY"
```

This delegates to the platform pathname-resolution machinery:

- conversion to an absolute pathname;
- symbolic-link resolution;
- relative symbolic-link target handling;
- symbolic-link chains;
- intermediate symbolic links;
- `.` / `..` normalization;
- loop detection/failure.

No custom recursive symbolic-link resolver is part of the accepted bootstrap.

No parsing of `ls -l` is used.

No GNU `readlink -f` or GNU-specific `realpath` option is required.

### Step 3 — verify the final executable

The canonical result must be an existing regular file:

```sh
[ -f "$RUMIAI_ENTRY" ]
```

A failed check is fatal.

### Step 4 — derive the root

Because the input is now an absolute canonical regular-file pathname:

```sh
RUMIAI_ROOT=${RUMIAI_ENTRY%/*}
[ -n "$RUMIAI_ROOT" ] || RUMIAI_ROOT=/
```

The second statement handles the root-level entrypoint case.

### Step 5 — validate the root

Before export:

```sh
(cd -- "$RUMIAI_ROOT")
```

must succeed.

### Step 6 — export fundamental state

Only after successful validation:

```sh
export RUMIAI_ENTRY RUMIAI_ROOT
```

---

## 8. Why `dirname` is not used here

`dirname` remains a valid POSIX utility, but the accepted bootstrap does not need its general pathname semantics.

After `realpath`, `RUMIAI_ENTRY` has a deliberately constrained domain: absolute, canonical, regular file, no trailing slash.

For this domain:

```sh
${RUMIAI_ENTRY%/*}
```

is preferred because it:

- expresses exactly the required operation;
- requires no subprocess;
- produces no additional utility output that must be recaptured;
- avoids unnecessary edge semantics from the more general `dirname` contract.

If the basename is later needed in the same constrained domain, prefer:

```sh
${RUMIAI_ENTRY##*/}
```

This is a local bootstrap design decision, not a project-wide prohibition of `dirname` or `basename`.

---

## 9. POSIX baseline and host behavior

The normative baseline is:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

Issue 8 provides the standard `realpath` facility needed by this design.

The bootstrap intentionally does not require `realpath -e` merely to establish entrypoint existence. The entrypoint is required to exist by the RumiAI contract and is checked explicitly after canonicalization. This also avoids needlessly depending on newer CLI options that may not yet be exposed uniformly by all reference hosts.

Any real divergence discovered on a reference host is handled under the canonical POSIX baseline-evolution rule; the algorithm is not pre-emptively expanded with host-specific branches.

---

## 10. Pathname capture

When pathname output is captured through shell command substitution, the implementation must account for removal of trailing newlines.

The validated PoC uses a small sentinel protocol to preserve pathname newline data while removing the utility's line terminator.

This remains a bootstrap-local mechanism unless a broader serialization requirement later justifies a reusable primitive.

---

## 11. PoC evidence

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

Consolidation session:

```text
sessions/2026-08-27-linux-local-002/
```

Local result:

```text
dash          14 pass / 0 fail
bash --posix  14 pass / 0 fail
busybox sh    14 pass / 0 fail
TOTAL         42 pass / 0 fail
```

The matrix includes direct/absolute/`PATH` invocation, relative and absolute symbolic links, chains, intermediate links, loops, dangling links, spaces, leading-dash path components, newline-containing pathnames and explicit root `cd` validation.

Runtime certification on the current reference macOS and Ubuntu LTS remains a separate validation step.

---

## 12. Internal delegation boundary

After validated root discovery, the entrypoint delegates to code located below the repository root.

Conceptually:

```text
rumiai-os
   │
   ├─ resolve physical RUMIAI_ENTRY
   ├─ derive + verify RUMIAI_ROOT
   │
   └─ delegate
          │
          ▼
   internal bootstrap
          │
          ├─ environment initialization
          ├─ command dispatch
          └─ future subsystems
```

The exact internal directory names remain intentionally unfrozen.

Only directories justified by concrete subsystem boundaries should be introduced.

---

## 13. Authorization boundary

An accepted architecture or successful PoC does not authorize writes to the `rumiai-os` repository during the current initial phase.

Promotion from `rumiai-dev-PoCs` into `rumiai-os` requires explicit user approval.
