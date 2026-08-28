# Handoff — macOS Phase 0 pathname matrix pass

Date: 2026-08-28
Status: **physical macOS validation in progress**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Current tested product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

## Phase 0 pathname/symlink matrix — PASS

A diagnostic source printed:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

and returned status `0`.

The product was physically invoked on macOS through:

1. relative pathname;
2. absolute pathname;
3. PATH command-name lookup;
4. relative symbolic link;
5. absolute symbolic link;
6. symbolic-link chain;
7. symbolic link in an intermediate pathname component;
8. external invocation pathname containing spaces.

Every case converged to:

```text
BOOTSTRAP=/private/tmp/rumiai-os-test/rumiai-os
ROOT=/private/tmp/rumiai-os-test
STATUS=0
```

This physically validates the central Phase 0 invariant on macOS: invocation identity may vary, but `RumiAI_BOOTSTRAP_BIN` and `RumiAI_ROOT` converge on the physical/canonical runtime and relocatable installation root.

## macOS validation passed so far

- native `realpath --` compatibility after removing `-e`;
- explicit source without shebang/executable bit, status `23`;
- direct `#!/usr/bin/env rumiai-os`, status `24`;
- structural `bin/rumiai-os -> ../rumiai-os` exposure;
- public logger/statuses/localization/filtering;
- interactive Bash branch;
- Apple Bash banner suppression;
- interactive POSIX sh branch;
- relative/absolute/PATH Phase 0 invocation;
- relative/absolute/chained/intermediate symlink resolution;
- invocation pathname containing spaces.

## Ubuntu 26.04 capability evidence

User physically reported:

```text
realpath -e   supported
readlink -e   supported
```

Full Linux product execution remains pending.

## Immediate next macOS work

Complete pathname/source coverage with:

1. PATH invocation through a relative PATH component from an arbitrary caller CWD;
2. explicit source whose pathname contains spaces;
3. explicit source invoked through a symlink and symlink chain;
4. canonical `RumiAI_COMMAND_BIN` verification in each case.

After that, test language fallback and sourced-command lifecycle before moving the full matrix to Ubuntu/Linux.
