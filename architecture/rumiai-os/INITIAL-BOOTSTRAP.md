# RumiAI OS — Initial Bootstrap Architecture

Status: **Initial accepted architecture — amended 2026-08-27**  
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
2. determine the real RumiAI OS root according to the accepted bootstrap contract;
3. export the semantic root variable;
4. load/delegate to the internal bootstrap implementation;
5. propagate the resulting process exit status.

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

## 5. Root variable

The semantic root exposed by the entrypoint is:

```text
RUMIAI_ROOT
```

All paths managed by the system must ultimately derive from this root or from semantic roots explicitly configured by the system.

The initial bootstrap must not infer external resources from host-specific conventional paths.

---

## 6. Invocation and real-path contract

The bootstrap must support at least:

```text
./rumiai-os
/path/to/rumiai-os
PATH=/path/to/repository:$PATH rumiai-os
invocation through a symbolic link
```

The result must not depend on the caller current working directory.

When invoked through a symbolic link, root discovery must resolve the actual executable location rather than treating the directory containing the link as the RumiAI OS root.

The exact resolution algorithm is not yet frozen. Before implementation it must be validated by a dedicated PoC against the selected POSIX baseline and tested for at least:

- direct invocation;
- relative and absolute pathnames;
- invocation through `PATH`;
- absolute symlink targets;
- relative symlink targets;
- chains of symbolic links;
- loop/cycle detection;
- names containing spaces and shell metacharacters;
- independence from current working directory.

Historical implementations in `massimilianonardi/m`, including code that derives `THIS_PATH` and `THIS_DIR` from `$0`, are reference material for this PoC and must be audited rather than copied automatically.

---

## 7. Internal delegation boundary

After root discovery, the entrypoint delegates to code located below the repository root.

Conceptually:

```text
rumiai-os
   │
   ├─ discover RUMIAI_ROOT
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

The exact internal directory names are intentionally not fully frozen by this document.

Only directories justified by concrete subsystem boundaries should be introduced.

---

## 8. POSIX portability layer

Reusable low-level helpers are governed by:

```text
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
```

The portability layer must not expose implementation-language details through public command filenames.

---

## 9. Authorization boundary

An accepted architecture or successful PoC does not authorize writes to the `rumiai-os` repository during the current initial phase.

Promotion from `rumiai-dev-PoCs` into `rumiai-os` requires explicit user approval.
