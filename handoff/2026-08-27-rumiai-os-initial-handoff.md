# Handoff — RumiAI OS initial architecture

Date: 2026-08-27
Status: active design handoff

## 1. Purpose

This document is the operational handoff for continuing the initial design of `rumiai-os` without relying on conversational memory.

It summarizes the current architectural direction, the decisions already consolidated in `rumiai-dev`, the evidence stored in `rumiai-dev-PoCs`, the corrections introduced during the latest discussion, and the exact next problem to solve.

No content in this handoff authorizes modifications to the `rumiai-os` repository.

---

## 2. Repository roles

### `rumiai-dev`

Canonical source of truth for:

- rules;
- architecture;
- specifications;
- decisions;
- terminology;
- development memory;
- audit results;
- handoff documents;
- archived chats.

If conversational memory conflicts with `rumiai-dev`, the repository wins.

### `rumiai-dev-PoCs`

Experimental evidence repository.

Contains:

- proof-of-concept source;
- historical fixtures;
- test harnesses;
- test sessions;
- environment descriptions;
- procedures;
- raw output;
- conclusions.

### `rumiai-os`

Stable product/system repository.

**Current rule:** in this initial phase, no file or modification may be written to `rumiai-os` without explicit user consent.

A successful PoC or an accepted architectural direction is not, by itself, authorization to write to `rumiai-os`.

### `massimilianonardi/m`

Historical/reference repository.

Reference snapshot used by the current audit:

```text
e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

It is design input and historical evidence, not a normative source and not a codebase to copy automatically.

---

## 3. Core RumiAI OS platform contract

RumiAI OS targets POSIX rather than individual operating systems.

The design must not be shaped around Windows, Linux, macOS or a specific distribution when POSIX provides the appropriate abstraction.

Host-specific behavior is allowed only where POSIX cannot provide the required functionality and must be isolated behind explicit abstractions/adapters.

Windows is not an architectural target in itself. A POSIX-compatible environment is a requirement; Cygwin may be recommended on Windows.

The user currently prefers adopting the **most recent POSIX standard that is effectively supported by the current reference operating systems**, specifically:

- current Ubuntu LTS;
- current macOS.

This baseline has **not yet been formally verified or frozen**. Verification against the actual standards/features available on those two current OS references is the next required research step before relying on newer POSIX facilities.

---

## 4. Shell and executable naming rules

Portable shell code uses:

```sh
#!/bin/sh
```

However, the implementation language must not leak into the public command name.

### Executable commands

Executable commands must normally have **no language extension**.

Examples:

```text
rumiai-os
pkg
path
resolve
```

A command implemented today with `/bin/sh` may later be reimplemented in Node.js, Python, another POSIX tool, or another runtime without changing its command name or external contract.

Therefore names such as these are not acceptable merely to identify the implementation language:

```text
command.sh
command.py
command.js
```

### Sourced/internal files

Extensions must have semantic meaning rather than merely identifying that a file contains shell code.

Examples:

```text
.lib
.conf
```

The exact extension taxonomy is not fully frozen yet.

### Language source files

Where the file is genuinely source code whose language matters to the build/compile process, the normal language extension remains appropriate.

Examples:

```text
.cpp
.java
.js
```

A pure JavaScript source module can therefore use `.js`; a directly executable Node.js command with a shebang should normally have no extension.

---

## 5. Command-line parsing rule: `--`

New rule requested and pending formal insertion into the canonical rules/specifications:

> Commands that support it should adopt `--` as the explicit delimiter separating options from positional parameters.

Conceptual form:

```text
command [options] -- [parameters]
```

This is intended to remove ambiguity where positional values can begin with `-` or otherwise resemble options.

The exact CLI parsing convention still needs to be formalized, including:

- whether `--` is mandatory or recommended when positional parameters are present;
- behavior when there are no options;
- compatibility with commands/utilities that already have standard POSIX option parsing semantics;
- interaction with subcommands.

No implementation decision has yet been frozen beyond the principle of using `--` where supported to distinguish options from data/parameters.

---

## 6. `rumiai-os` repository root

Current architectural direction:

```text
rumiai-os/
├── rumiai-os
├── README.md
└── <directories>
```

Only two regular files should exist at repository root:

- `rumiai-os`;
- `README.md`.

Additional content belongs in directories justified by real subsystem boundaries.

The directory names are intentionally not yet fully frozen.

---

## 7. Responsibility of the `rumiai-os` entrypoint

The entrypoint must be more than a trivial trampoline but must not become monolithic.

Its expected responsibilities include resolving a small number of fundamental variables required before the rest of the system can be loaded.

Likely fundamental state includes:

```text
RUMIAI_ROOT
host/system identity
fundamental environment paths/variables
entrypoint physical path
entrypoint directory
```

The exact variable set is still to be designed.

After this minimum environment has been resolved, the entrypoint should delegate to other commands and/or source internal libraries/configuration.

The entrypoint must not accumulate package-management, deployment, AI, application or unrelated subsystem logic.

---

## 8. Symlink resolution is the immediate design priority

The current highest-priority technical problem is:

> determine the most reliable, robust and POSIX-compliant way to resolve the real executable path and directory when `rumiai-os` is invoked directly, through `PATH`, or through one or more symlinks.

An earlier PoC temporarily rejected symlink invocation. That decision is now considered superseded as an architectural direction.

The new requirement is to support symlink invocation if it can be implemented robustly under the selected POSIX baseline.

### Historical reference from `m`

Several scripts in `massimilianonardi/m` contain logic such as:

```sh
# resolve caller symlink
if [ -L "$0" ]
then
  THIS_PATH="$(ls -ld -- "$0")"
  THIS_PATH="${THIS_PATH#*" $0 -> "}"
else
  # relative path or absolute depending on call that launched this file
  THIS_PATH="$0"
fi
```

This code demonstrates the intended behavior and is useful reference material, but it must be audited before being adopted.

### Cases the final solution must address

At minimum:

```text
direct relative invocation
absolute invocation
invocation through PATH
absolute symlink target
relative symlink target
multiple symlink levels
symlink loops
spaces in path names
special characters in path names
current-working-directory independence
host portability
```

Potential strategies to compare include:

1. a portable implementation derived from historical `m` logic;
2. standard `readlink`/`realpath` if the selected POSIX baseline and both reference OS families actually guarantee the needed semantics;
3. a hybrid implementation with explicit capability detection only if this does not violate the platform-contract philosophy.

No strategy has yet been selected.

---

## 9. Important POSIX-portability findings from `m`

The audit of `m` confirmed that the repository already contains many attempts to supply Bash/GNU-like functionality using POSIX shell.

Examples include:

- array abstraction;
- map abstraction;
- argument quoting/serialization;
- environment-state transfer;
- path canonicalization;
- alternatives to GNU `readlink -f` behavior.

The architectural idea is valuable, but individual implementations must be independently verified.

### Confirmed issues

The audit and PoC 001 reproduced concrete problems in historical primitives:

#### `$RANDOM`

Historical functions described as POSIX-compatible depend on `$RANDOM`, which cannot be assumed as part of the portable shell contract.

#### `printf` format/data confusion

A historical function uses a pattern equivalent to:

```sh
printf "$value"
```

which interprets input as a format string rather than opaque data.

The safe default pattern is conceptually:

```sh
printf '%s' "$value"
```

#### `eval` and second interpretation

Historical array code can cause shell-looking data to be interpreted again through `eval`.

The test demonstrated that command-substitution-looking input can execute.

This leads to the general rule:

> data must remain data unless code execution is the explicit documented purpose of the API.

---

## 10. PoC status

### PoC 001 — historical POSIX primitives

Location:

```text
rumiai-dev-PoCs/pocs/001-posix-foundations/
```

Purpose:

- reproduce defects identified in historical code;
- preserve literal historical fixtures;
- provide cross-shell evidence.

Tested on:

```text
dash
bash --posix
busybox sh
```

The historical fixtures are literal copies from `m` at the audited commit.

### PoC 002 — bootstrap foundation

Location:

```text
rumiai-dev-PoCs/pocs/002-posix-bootstrap-foundation/
```

It explored:

- safe data output;
- minimal root discovery;
- cross-shell execution;
- static shell checks.

It intentionally did not implement arrays/maps/package management.

Important correction:

The PoC 002 choice to reject symlink invocation is **not the current desired architecture**. The PoC remains useful experimental evidence, but that part must not be promoted into `rumiai-os`.

Some filenames inside the archived PoCs use `.sh`. Those PoCs predate the current naming rule and should be treated as historical experimental artifacts, not current naming examples.

---

## 11. Historical `m` architecture relevant to `rumiai-os`

The audit identified `var/#_os/` as one of the most relevant historical areas.

Important concepts already present there include:

```text
relocatable system root
pkg/sys/usr/wrk separation
semantic directories
package definitions
profiles
build/install/run/test lifecycle
root materialization
dependency handling
Cygwin preparation
host integration
```

The historical `mk` system is useful reference material for:

- configuration overlays;
- profile composition;
- project-type dispatch;
- lifecycle actions;
- materialization into alternate roots.

However its term `TARGET` represents lifecycle operations such as build/install/test/run, not the future deployment substrate concept such as hosted/container/image/device. These concepts must not be conflated.

The historical package manager contains useful conceptual separation between package definitions, vendor binaries, installed package state and integration, but its version solver, dependency resolution, transactional behavior and trust model need redesign rather than direct migration.

---

## 12. Current canonical files in `rumiai-dev`

Relevant material includes:

```text
RULES.md

analysis/m-audit/
├── 2026-08-27-architecture-inventory.md
├── 2026-08-27-package-manager-deep-dive.md
├── 2026-08-27-posix-primitives-deep-dive.md
├── 2026-08-27-mk-target-profile-deep-dive.md
└── 2026-08-27-bootstrap-and-deployment-deep-dive.md

specifications/rumiai-os/
└── POSIX-PORTABILITY-LAYER.md

architecture/rumiai-os/
└── INITIAL-BOOTSTRAP.md

decisions/rumiai-os/
├── 2026-08-27-posix-bootstrap-foundation.md
└── 2026-08-27-command-naming-and-symlink-resolution.md
```

Some of these documents were created before the latest corrections. When continuing work, verify that the latest rule/decision documents supersede older assumptions where necessary.

---

## 13. Immediate next work sequence

The next phase should remain narrow.

### Step 1 — formalize the new CLI `--` rule

Add the delimiter rule to the canonical development rules/specification after defining its exact scope.

### Step 2 — determine the practical POSIX baseline

Verify the most recent POSIX version/features that can actually be relied upon on the current:

```text
Ubuntu LTS
macOS
```

Do not assume that the newest published POSIX issue is fully implemented merely because it exists.

The output should distinguish:

```text
standardized by POSIX
available on Ubuntu LTS
available on macOS
safe to use in RumiAI portable core
```

### Step 3 — symlink-resolution design

Audit all relevant symlink/path implementations in `m`, not only the single snippet quoted above.

Compare them against the selected POSIX baseline and define the exact desired semantics of entrypoint resolution.

### Step 4 — dedicated symlink-resolution PoC

Create a PoC in `rumiai-dev-PoCs` covering at least:

```text
direct relative invocation
absolute invocation
PATH invocation
relative symlink
absolute symlink
symlink chain
loop
path containing spaces
CWD independence
cross-shell behavior
```

Do not write the result to `rumiai-os`.

### Step 5 — consolidate the proven algorithm

Only after the PoC succeeds should the symlink/root-resolution algorithm be promoted into the canonical bootstrap architecture.

### Step 6 — request explicit consent

Before writing any resulting implementation into `rumiai-os`, obtain explicit user authorization.

---

## 14. Non-goals for the immediate next step

Do not yet implement:

```text
package manager
array abstraction
map abstraction
container deployment
image/device deployment
software capability registry
AI components
computer-use
```

These remain important future areas, but the bootstrap foundation should first have a proven path/root/environment model.

---

## 15. Current design principle

The strongest current principle for this phase is:

> First make the identity and location of the running RumiAI OS instance deterministic, portable and robust; only then allow higher-level subsystems to depend on it.

And operationally:

> Analyze → specify → PoC → consolidate → ask for explicit consent → write to `rumiai-os`.
