# Handoff — RumiAI OS root resolution consolidated

Date: 2026-08-27  
Status: **active design handoff — supersedes previous handoff state where newer**

## 1. Handoff rule

The operational handoff source is the **most recent file in `rumiai-dev/handoff/`**, not a permanently fixed filename.

This file is the current handoff at creation time.

No content in this handoff authorizes modifications to `rumiai-os` without explicit user consent.

---

## 2. Repository authority

### `rumiai-dev`

Canonical source of truth for rules, specifications, decisions, architecture, analyses, terminology, development memory and handoffs.

### `rumiai-dev-PoCs`

Experimental evidence repository containing PoCs, fixtures, harnesses, sessions, environment descriptions and raw/test results.

### `rumiai-os`

Stable product repository.

During the current initial phase it MUST NOT be modified without explicit user consent.

### `massimilianonardi/m`

Historical/reference repository only.

Current audit reference snapshot:

```text
e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

---

## 3. POSIX contract

The initial POSIX baseline is fixed to:

> **POSIX.1-2024 / The Open Group Base Specifications Issue 8**

The baseline is not automatically advanced to newer revisions.

A later revision is evaluated only when a concrete RumiAI requirement needs a later feature, utility, interface or semantic guarantee. The requirement must be validated, the relevant standard verified and real reference-host behavior checked where material, using PoCs when appropriate.

Unused later features do not need proactive verification.

If actual behavior on a reference OS differs from the POSIX contract RumiAI needs, evaluate compatibility, fallback, abstraction, implementation and/or baseline change at that point.

Canonical decision:

```text
decisions/rumiai-os/2026-08-27-posix-baseline-and-cli-delimiter.md
```

---

## 4. Mandatory `--` rule

For every tool, POSIX or non-POSIX, that actually supports `--` as end-of-options delimiter:

- with one or more positional/data operands, `--` is mandatory;
- with zero positional/data operands, `--` must not be present;
- if the tool does not support that delimiter semantic, it must not be forced.

Support is established per tool contract, not by assuming every POSIX utility supports Guideline 10.

`test` / `[` is an example where `--` must not be invented.

This rule is now canonical in `RULES.md` and the POSIX baseline/CLI decision.

---

## 5. Shell and naming

Portable shell implementation uses:

```sh
#!/bin/sh
```

Executable command names do not expose implementation language extensions.

Examples:

```text
rumiai-os
pkg
path
resolve
```

not `*.sh`, `*.py`, `*.js` merely to identify the interpreter.

Sourced/internal files use semantic extensions such as `.lib` and `.conf` where appropriate.

---

## 6. Entrypoint/root contract — now consolidated

The root-resolution problem that was open in the previous handoff is now resolved at design/PoC level.

Fundamental bootstrap state:

```text
RUMIAI_ENTRY
RUMIAI_ROOT
```

### `RUMIAI_ENTRY`

Must be the physical/canonical absolute pathname of the actual `rumiai-os` regular file after all symlinks and pathname indirections are resolved.

### `RUMIAI_ROOT`

Must be the physical/canonical absolute directory containing the real entrypoint.

The following invariant is mandatory:

```sh
cd -- "$RUMIAI_ROOT"
```

must succeed after resolution.

The actual validation is executed in a subshell:

```sh
(cd -- "$RUMIAI_ROOT")
```

so the bootstrap does not alter its main current working directory.

Canonical specification:

```text
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
```

Canonical architecture:

```text
architecture/rumiai-os/INITIAL-BOOTSTRAP.md
```

Canonical decision:

```text
decisions/rumiai-os/2026-08-27-entrypoint-root-resolution.md
```

Analysis:

```text
analysis/rumiai-os/2026-08-27-entrypoint-root-resolution.md
```

---

## 7. Accepted resolution algorithm

### Step 1 — invocation pathname

If `$0` contains `/`, use it directly as the invocation pathname.

If `$0` contains no `/`, resolve command-name invocation through `PATH`:

```sh
command -v -- "$0"
```

Failure is fatal.

### Step 2 — physical canonicalization

Use the POSIX.1-2024 Issue 8 utility:

```sh
realpath -- "$RUMIAI_ENTRY"
```

This replaces any need for:

```text
custom recursive symlink resolver
ls -l parsing
GNU readlink -f
GNU-specific realpath options
```

The algorithm does not first convert relative paths with `pwd -P`; `realpath` already handles relative input and returns the physical absolute canonical result.

### Step 3 — final-target validation

Require:

```sh
[ -f "$RUMIAI_ENTRY" ]
```

Dangling links or invalid/non-regular final targets fail.

### Step 4 — root derivation

Use parameter expansion:

```sh
RUMIAI_ROOT=${RUMIAI_ENTRY%/*}
[ -n "$RUMIAI_ROOT" ] || RUMIAI_ROOT=/
```

### Step 5 — root invariant

Require:

```sh
(cd -- "$RUMIAI_ROOT")
```

### Step 6 — export

Only after all checks succeed:

```sh
export RUMIAI_ENTRY RUMIAI_ROOT
```

---

## 8. `dirname` / `basename` decision

Both POSIX utilities were considered.

For the specific post-`realpath` bootstrap domain, parameter expansion is selected because the input is already absolute, canonical and known to represent a regular file.

Root:

```sh
${RUMIAI_ENTRY%/*}
```

Basename if later needed in the same domain:

```sh
${RUMIAI_ENTRY##*/}
```

This avoids subprocess/output-capture overhead and the broader edge semantics of `dirname`/`basename` that are unnecessary here.

This is not a global ban on `dirname` or `basename`.

---

## 9. Why plain `realpath` rather than `realpath -e`

Issue 8 defines `realpath` and the `-e`/`-E` options.

The current macOS `realpath` documentation exposes physical canonicalization but does not document the full Issue 8 `-e`/`-E` CLI.

RumiAI does not need `-e` for this bootstrap contract:

- the invoked entrypoint must exist;
- normal canonicalization is sufficient when pathname resolution succeeds;
- `[ -f "$RUMIAI_ENTRY" ]` explicitly verifies final-target existence/type;
- symbolic-link loops fail during pathname resolution;
- dangling links fail the contract.

Therefore the algorithm uses only the minimum facility actually needed and avoids an unnecessary compatibility dependency.

---

## 10. Historical `m` audit result for this problem

Relevant historical files include:

```text
cmd/lib/realpaths.lib.sh
var/#_os/m/bin/m.lib
var/#_os/m/bin/m-filesystem.lib
```

Useful ideas retained:

- physical vs logical path distinction;
- parameter expansion such as `${0%/*}` and `${0##*/}`;
- preference for simple shell primitives.

Rejected for the new bootstrap:

- parsing `ls -ld` output to find symlink targets;
- assuming `$0` always contains `/`;
- manual symlink traversal now that Issue 8 standardizes `realpath`;
- GNU-specific path options.

---

## 11. PoC 003 — consolidated result

Location:

```text
rumiai-dev-PoCs/pocs/003-entrypoint-symlink-resolution/
```

Consolidation session:

```text
sessions/2026-08-27-linux-local-002/
```

Local environment:

```text
Debian GNU/Linux 13 (trixie)
GNU coreutils realpath 9.7
dash 0.5.12-12
bash 5.2.37 --posix
BusyBox 1.37.0 sh
```

Result:

```text
dash          14 pass / 0 fail
bash --posix  14 pass / 0 fail
busybox sh    14 pass / 0 fail
TOTAL         42 pass / 0 fail
```

Validated cases include:

```text
relative invocation
absolute invocation
PATH invocation
root cd validation
relative symlink
absolute symlink
symlink chain
symlink in intermediate component
spaces and literal " -> " in pathname
leading-dash pathname component
symlink loop -> expected failure
dangling symlink -> expected failure
trailing-newline pathname
trailing-newline root cd
```

PoC 003 was updated rather than duplicated; its earlier session remains historical evidence.

---

## 12. Pathname output capture

Shell command substitution removes trailing newline characters.

The PoC therefore uses a minimal sentinel capture protocol for pathname-producing utilities so newline bytes belonging to pathname data are not silently discarded.

This remains local to the bootstrap problem and is not generalized into a serialization layer without a future concrete requirement.

---

## 13. Current validation boundary

The algorithm is accepted and consolidated against:

- the Issue 8 normative contract;
- historical-code audit;
- Linux cross-shell PoC evidence.

What is **not yet certified** is runtime behavior on the exact current reference hosts:

```text
current Ubuntu LTS
current macOS
```

Documentation indicates the required base `realpath` facility exists, but the archived PoC session is not a runtime run on those hosts.

Reference-host execution is the next narrow validation step. If it reveals a material divergence, apply the baseline/compatibility rule instead of pre-emptively adding host branches.

---

## 14. Current canonical material

Important current files now include:

```text
RULES.md

analysis/rumiai-os/
└── 2026-08-27-entrypoint-root-resolution.md

architecture/rumiai-os/
└── INITIAL-BOOTSTRAP.md

specifications/rumiai-os/
├── POSIX-PORTABILITY-LAYER.md
└── ENTRYPOINT-ROOT-RESOLUTION.md

decisions/rumiai-os/
├── 2026-08-27-posix-bootstrap-foundation.md
├── 2026-08-27-command-naming-and-symlink-resolution.md
├── 2026-08-27-posix-baseline-and-cli-delimiter.md
└── 2026-08-27-entrypoint-root-resolution.md
```

Older documents remain historical unless explicitly superseded; the newer entrypoint decision completes the previously open algorithm choice.

---

## 15. Immediate next work

The symlink/root-resolution design itself is no longer the open architectural question.

Next sequence:

1. run PoC 003 on the exact reference Ubuntu LTS and macOS environments when execution access is available;
2. if both satisfy the required subset, mark reference-host runtime certification for this bootstrap primitive;
3. if either diverges materially, analyze only the concrete divergence and select the minimal standard-compatible response;
4. only after this evidence, request explicit user authorization before implementing/promoting the bootstrap into `rumiai-os`;
5. do not start package manager, generic array/map abstractions, deployment substrates or AI components as part of this bootstrap task.

---

## 16. Authorization boundary

No file in `rumiai-os` has been modified by this phase.

The accepted design, specification and passing PoC do not themselves authorize product-repository changes.
