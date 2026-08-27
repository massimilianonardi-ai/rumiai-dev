# RumiAI OS — POSIX Portability Layer

Status: **Draft normative specification**  
Date: 2026-08-27

## 1. Purpose

This document defines the normative requirements for the POSIX portability layer of `rumiai-os`.

It refines the canonical rules in `RULES.md` into requirements that can be implemented and tested. It does not prescribe one specific implementation unless required for correctness or portability.

The historical repository `massimilianonardi/m` and PoC 001 (`rumiai-dev-PoCs/pocs/001-posix-foundations`) are evidence and design input, not normative sources.

Normative keywords **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** express requirement strength.

---

## 2. Scope

The portability layer exists to provide the small set of abstractions that `rumiai-os` genuinely needs when direct POSIX facilities are insufficient or would otherwise cause non-portable duplication.

It is not intended to recreate Bash, GNU coreutils, or a general-purpose standard library in shell.

A primitive belongs in the portability layer only when:

1. the requirement occurs in multiple parts of the system or in a critical bootstrap path;
2. direct POSIX usage is insufficient, ambiguous, or would be repeatedly reimplemented;
3. the primitive can have a precise, testable contract.

If POSIX already provides a clear and sufficient mechanism, application code SHOULD use that mechanism directly rather than introducing a wrapper without architectural value.

---

# 3. Platform and shell requirements

### POSIX-PLAT-001 — POSIX is the platform contract

`rumiai-os` MUST target the selected POSIX baseline rather than Linux, GNU, Bash, macOS, Windows, or a specific distribution.

A construct MUST NOT be considered portable solely because it works on one or more common Unix-like systems.

### POSIX-PLAT-002 — `/bin/sh`

All shell scripts in the portable core MUST use exactly:

```sh
#!/bin/sh
```

Any exception requires the approval and documentation defined by `RULES.md`.

### POSIX-PLAT-003 — no accidental extensions

Portable-core code MUST NOT depend on unapproved shell or utility extensions, including but not limited to:

- Bash arrays;
- `[[ ... ]]`;
- `BASH_SOURCE`;
- process substitution;
- `$RANDOM`;
- GNU `readlink -f`;
- GNU-only options to otherwise POSIX utilities.

### POSIX-PLAT-004 — external tools are capabilities, not POSIX primitives

A primitive that depends on a tool not guaranteed by the selected POSIX baseline MUST declare that dependency explicitly.

Such a primitive MUST NOT be classified as part of the dependency-free POSIX core.

Examples include `openssl`, `curl`, `wget`, `git`, `python`, `perl`, and vendor-specific utilities unless separately guaranteed by the relevant execution profile.

---

# 4. Data integrity requirements

### POSIX-DATA-001 — data must remain data

Arbitrary input data MUST NOT be reinterpreted as shell syntax unless code execution is the explicit documented purpose of the API.

This requirement applies to command substitution syntax, parameter expansion syntax, quotes, backticks, glob characters, redirections, separators, and other shell metacharacters.

### POSIX-DATA-002 — constant `printf` format for arbitrary data

When arbitrary data is emitted through `printf`, the format operand MUST be constant.

Required pattern:

```sh
printf '%s' "$value"
```

or another constant format appropriate to the operation.

A variable or untrusted value MUST NOT be used as the `printf` format operand unless interpreting it as a format string is the explicit API contract.

### POSIX-DATA-003 — `echo` is not a generic data serializer

Portable primitives MUST use `printf` with constant formats for exact data output.

`echo` MAY be used for human-readable messages where exact byte/string preservation is not part of the contract.

### POSIX-DATA-004 — declared representable domain

Every primitive that stores, transports, serializes, or round-trips arbitrary values MUST document its representable domain.

At minimum, the shell-variable limitation concerning NUL bytes MUST be acknowledged where relevant.

### POSIX-DATA-005 — exact round-trip when claimed

If a primitive claims lossless serialization or argument preservation, its contract MUST satisfy:

```text
decode(encode(value)) == value
```

or, for argv:

```text
decode(encode(argv)) == argv
```

for every value in the declared domain.

### POSIX-DATA-006 — trailing newline semantics must be explicit

Any API using command substitution or text serialization MUST explicitly account for the POSIX shell behavior that strips trailing newlines from command substitution results.

A primitive MUST NOT claim exact round-trip semantics for trailing newlines unless tests demonstrate preservation by its chosen protocol.

---

# 5. `eval` and dynamic indirection requirements

### POSIX-EVAL-001 — `eval` is a dangerous primitive

`eval` is not globally forbidden, because some POSIX-shell indirection patterns may require it, but its use MUST be exceptional and auditable.

### POSIX-EVAL-002 — no direct application-level `eval`

Application code SHOULD NOT use `eval` directly when an approved portability primitive can provide the required operation.

### POSIX-EVAL-003 — code/data boundary

Data values MUST NOT be concatenated into shell source passed to `eval`.

If dynamic variable names require `eval`, the dynamic identifier MUST be validated against a strict grammar before evaluation, and the associated value MUST remain data after the second parse.

### POSIX-EVAL-004 — identifier validation

Any API accepting a variable name, collection name, or other identifier later used in generated shell syntax MUST validate the identifier before use.

The default accepted grammar SHOULD be no broader than a portable shell identifier grammar appropriate to the API.

### POSIX-EVAL-005 — mandatory injection tests

Every primitive using `eval` MUST have tests covering at least:

- `$(...)`-looking text;
- backticks;
- semicolons;
- quotes;
- backslashes;
- `$` expansions;
- whitespace;
- glob characters;
- empty values.

The tests MUST demonstrate that values remain data unless code execution is explicitly intended.

### POSIX-EVAL-006 — explicit executable-code APIs

An API whose purpose is to evaluate or execute shell code MUST make code execution explicit in its name, documentation, trust boundary, and tests.

A decode, import, configuration, or data-loading API MUST NOT silently imply code execution.

---

# 6. Collection abstraction requirements

### POSIX-COLL-001 — collections are requirements, not Bash emulation goals

Arrays, maps, or similar abstractions MUST be introduced only if a concrete `rumiai-os` requirement justifies them.

The goal is not to reproduce Bash syntax or behavior.

### POSIX-COLL-002 — collection values must preserve declared data domain

Any array/map abstraction MUST preserve values exactly within its declared domain and MUST satisfy `POSIX-DATA-*` and `POSIX-EVAL-*` requirements.

### POSIX-COLL-003 — collection metadata isolation

Internal collection representation MUST NOT collide with unrelated shell variables or with another collection created through the same API.

### POSIX-COLL-004 — index/key validation

Array indices and map keys MUST be validated or encoded through a reversible, collision-free mechanism appropriate to the declared key domain.

### POSIX-COLL-005 — generic collections require property tests

A generic collection implementation MUST be validated with round-trip/property tests, not only example-based tests.

At minimum the common data corpus defined in section 11 MUST be exercised.

---

# 7. Environment/state-transfer requirements

### POSIX-ENV-001 — shell state transfer must distinguish data from code

Mechanisms used to transfer state between subshells/processes MUST use an explicit protocol whose data representation is distinguishable from executable shell code.

### POSIX-ENV-002 — no parsing unspecified shell presentation formats

Portable core code MUST NOT depend on parsing implementation-specific human/presentation output from shell builtins or utilities when POSIX does not define that output sufficiently for the intended purpose.

In particular, parsing `set` output as a general environment serialization mechanism requires proof of portability and MUST NOT be assumed portable by default.

### POSIX-ENV-003 — explicit state schema

State-transfer protocols SHOULD define an explicit list/schema of transferable fields rather than implicitly enumerating all shell state.

---

# 8. Path and root-discovery requirements

### POSIX-PATH-001 — root discovery independent of current working directory

The `rumiai-os` entrypoint MUST determine the repository/runtime root independently of the directory from which it is invoked.

### POSIX-PATH-002 — invocation through a path containing `/`

Root discovery MUST work when the entrypoint is invoked through a relative or absolute pathname containing `/`.

### POSIX-PATH-003 — invocation through `PATH`

If invocation of `rumiai-os` through `PATH` is part of the supported contract, root discovery MUST explicitly resolve the command location using portable mechanisms rather than assuming `$0` contains `/`.

If invocation through `PATH` is intentionally unsupported, this MUST be documented and diagnosed clearly.

### POSIX-PATH-004 — symlink semantics must be specified

Before implementing symlink resolution, the system MUST specify whether the root is based on:

- the invoked link location;
- the final target location;
- another explicitly defined rule.

The implementation MUST match that declared semantic.

### POSIX-PATH-005 — relative symlink targets

When a symlink target is relative, it MUST be resolved relative to the directory containing the symlink, not relative to the process current working directory.

### POSIX-PATH-006 — symlink chains and cycles

Any primitive claiming recursive/canonical symlink resolution MUST handle link chains and MUST detect or bound cycles.

### POSIX-PATH-007 — no parsing `ls -l` for symlink targets in the portable core

The portable core SHOULD NOT derive symlink targets by parsing human-readable `ls -l` output.

If no sufficient primitive exists in the chosen POSIX baseline, the exact limitation and selected fallback MUST be specified and tested across certified hosts.

### POSIX-PATH-008 — distinguish path operations

The portability layer SHOULD expose distinct operations with distinct contracts for concepts such as:

- existence;
- absolute path construction;
- lexical normalization;
- physical directory resolution;
- symlink resolution;
- relativization.

It SHOULD NOT expose a single ambiguous `realpath` clone unless its semantics are fully specified.

### POSIX-PATH-009 — relocatability

No path primitive may reintroduce host-specific hardcoded roots. All RumiAI-managed paths MUST ultimately derive from the discovered system root or explicitly configured semantic roots.

---

# 9. Randomness and security-related requirements

### POSIX-RAND-001 — no `$RANDOM` dependency in the POSIX core

Portable-core randomness MUST NOT depend on the non-POSIX `$RANDOM` shell variable.

### POSIX-RAND-002 — distinguish pseudo-randomness from security randomness

Any randomness API MUST state whether it is intended for:

- non-security pseudo-random behavior;
- identifiers with collision-resistance requirements;
- cryptographic/security-sensitive use.

One implementation MUST NOT silently serve all three semantics.

### POSIX-RAND-003 — external entropy providers are explicit dependencies

If secure randomness requires an external provider such as `openssl` or a host-specific facility, that provider MUST be modeled as an explicit capability/dependency rather than disguised as a POSIX guarantee.

---

# 10. Error and side-effect requirements

### POSIX-ERR-001 — library primitives return, entrypoints exit

Reusable library functions SHOULD report failure via return status rather than terminating the entire caller with `exit`, unless termination is the explicit documented contract.

Top-level commands/entrypoints MAY translate returned failures into process exit statuses.

### POSIX-ERR-002 — stdout is data

If a primitive returns data on stdout, diagnostic/log output MUST NOT be mixed into stdout.

Diagnostics SHOULD go to stderr or through the logging subsystem.

### POSIX-ERR-003 — side effects must be explicit

A primitive that modifies filesystem state, environment state, shell options, `PATH`, current directory, traps, or global variables MUST document those side effects.

Unexpected ambient state mutation is not allowed as an implementation detail.

### POSIX-ERR-004 — temporary resources require cleanup

Temporary filesystem resources created by portable primitives/tests MUST use collision-resistant locations appropriate to their purpose and MUST have cleanup behavior for normal exit and relevant signals where feasible.

---

# 11. Required common test corpus

Any primitive claiming to preserve arbitrary shell-representable data MUST be tested against a common corpus containing at least:

```text
empty string
simple ASCII
leading space
trailing space
multiple spaces
tab
embedded newline
trailing newline where the API claims to preserve it
single quote
double quote
backslash
dollar sign
backtick
$(...)-looking text
semicolon
pipe/redirection-looking text
glob characters: * ? [ ]
leading dash
percent sign
UTF-8 text
very long value
```

Additional corpus items MUST be added when a primitive has a broader or more specialized domain.

---

# 12. Minimum shell/host test strategy

### POSIX-TEST-001 — multiple independent shell implementations

Portable primitives MUST be tested on multiple independent `/bin/sh` implementations. Testing only Bash, including Bash POSIX mode, is insufficient.

### POSIX-TEST-002 — baseline matrix

During development, the baseline test matrix SHOULD include where available:

- `dash`;
- BusyBox `ash`/`sh`;
- a `ksh`-family implementation;
- the shell/environment used for macOS certification;
- Cygwin `/bin/sh` for the documented Windows+Cygwin configuration.

The certified-host matrix may evolve independently from this development matrix.

### POSIX-TEST-003 — same API, same corpus

The same test API and input corpus MUST be run across shells. Tests MUST NOT silently weaken assertions for a shell merely because it lacks a non-POSIX extension.

### POSIX-TEST-004 — historical regression cases

The following regressions demonstrated by PoC 001 MUST remain permanent tests for replacement primitives where applicable:

1. absence of `$RANDOM` must not create deterministic behavior in an API claiming randomness;
2. `%s` passed as data must not become a `printf` format directive;
3. `$(...)`-looking array data must not execute.

---

# 13. Static-check requirements

The `rumiai-os` development checks SHOULD detect at least the following patterns in portable-core shell code:

```text
#!/bin/bash
#!/usr/bin/env bash
[[
BASH_SOURCE
process substitution
$RANDOM
readlink -f
host-specific hardcoded paths
```

They SHOULD also flag for review:

```text
eval
variable/non-constant printf format operands
parsing of ls -l for symlink resolution
unquoted expansions in data-sensitive code
```

Static detection is a guardrail and does not replace behavioral tests.

---

# 14. Requirement traceability

Every portability primitive introduced into `rumiai-os` SHOULD document which requirement IDs from this specification it implements.

Every corresponding PoC/test SHOULD document which requirement IDs it verifies.

When a requirement is intentionally violated by an approved exception, the exception record MUST reference the affected requirement ID.

---

# 15. Current conclusions from historical evidence

The following historical concepts remain useful design inputs:

- a reusable POSIX portability layer;
- an array-like abstraction if justified by actual system needs;
- explicit path operations rather than assuming GNU `readlink -f`;
- shell-state transfer as a real problem that may need an abstraction.

The following historical implementations are **not approved for direct migration**:

- `$RANDOM`-based POSIX randomness;
- `printf "$value"` data emission;
- array storage that interpolates arbitrary values into `eval` source;
- generic environment/state transfer implemented by serializing executable shell code without a strict trust boundary;
- root/symlink discovery that assumes `$0` contains `/` or parses `ls -l` without a proven contract.

They may be used as fixtures and regression references while replacement implementations are designed.

---

# 16. Next validation step

The next PoC SHOULD validate a minimal replacement foundation rather than reimplement the entire historical library.

Recommended initial scope:

1. safe data emission/quoting contract;
2. root discovery contract;
3. minimal dynamic-variable/collection strategy only if required by the first `rumiai-os` bootstrap;
4. automated cross-shell test harness and static checks.

Only primitives that pass the relevant requirements and tests become candidates for stable implementation in `rumiai-os`.
