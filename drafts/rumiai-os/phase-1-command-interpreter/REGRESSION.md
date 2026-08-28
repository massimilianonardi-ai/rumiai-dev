# Phase 1 automated regression

Date: 2026-08-28  
Status: **regression harness constructed — physical execution pending**

## Authoritative product baseline

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Physically validated product commit remains:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

No product file was changed while constructing this regression harness.

## Experimental implementation

Repository:

```text
massimilianonardi-ai/rumiai-dev-PoCs
```

PoC:

```text
pocs/004-phase-1-regression/
```

PoC commit:

```text
a48d9685459397a5301febdcf237b89b03555236
```

The suite takes an explicit `rumiai-os` checkout path as input and treats that checkout as read-only. Tests requiring destructive conditions operate only on disposable copies under `${TMPDIR:-/tmp}`.

## Automated core matrix

`tests/core` covers the non-interactive part of the physical Phase 1 matrix:

- POSIX `sh` syntax and Bash POSIX-mode syntax when Bash is available;
- executable runtime/public logger and structural `bin/rumiai-os -> ../rumiai-os` exposure;
- explicit readable non-executable source without shebang;
- direct `#!/usr/bin/env rumiai-os` source execution;
- logger statuses `12..16` and filtered-event success;
- runtime canonicalization through relative/absolute invocation, PATH, relative/absolute symlink, symlink chain, intermediate symlink and spaces;
- relative PATH component from an arbitrary caller CWD;
- source canonicalization through spaces and source symlink aliases/chains;
- language precedence, language fallback, bootstrap configuration and text-encoding normalization/fallback;
- source lifecycle for `return`, fall-through failure, `exit` and SIGTERM.

A real interactive TTY prompt/session check is deliberately not synthesized. The runner reports it as `SKIP`; Bash and POSIX `sh` interactive behavior remains a physical reference-host gate.

## Negative status map `1..10`

`tests/status-map` deliberately forces all designed bootstrap/CLI statuses without patching the product source:

| Status | Failure contract | Forcing method |
|---:|---|---|
| 1 | bootstrap PATH resolution | source unchanged entrypoint with slashless `$0` and empty `PATH` |
| 2 | runtime `realpath` | source unchanged entrypoint with nonexistent pathname in `$0` |
| 3 | bootstrap bin validation | `$0` canonicalizes to a directory |
| 4 | root validation | isolated test-process `cd` fault injection |
| 5 | i18n load | remove `lib/i18n.lib` from disposable product copy |
| 6 | logger load | remove `lib/log.lib` from disposable product copy |
| 7 | shell load | remove `lib/shell.lib` from disposable product copy |
| 8 | command-entry resolution | source path contains a nonexistent intermediate component |
| 9 | invalid command entry | runtime itself supplied as source command |
| 10 | shell launch | select `sh` and inject failure only for `command -p -v sh`, while real host `realpath`, `awk` and `date` remain available |

The forcing for status `8` intentionally uses a missing intermediate pathname component. During harness construction, GNU `realpath --` was observed to accept a missing final component, which would reach status `9` instead. The revised forcing avoids that host-dependent ambiguity.

Statuses `4` and `10` are difficult to trigger deterministically on a healthy POSIX host by filesystem mutation alone. Their fault injection is scoped to the isolated shell process executing the unchanged product code.

## Construction evidence

Before publication:

- the runner, tests, helper library and fixtures passed syntax parsing with `dash -n` and `bash --posix -n` in the available development runtime;
- a branch-compatible local subject was used to dry-run the forcing mechanics;
- the corrected status-map dry-run produced `10/10 PASS`.

This construction evidence is **not** new physical product evidence because the development runtime could not fetch/materialize the GitHub product checkout through its shell network environment.

## Physical execution gate

The next reference-host action is to execute:

```sh
sh pocs/004-phase-1-regression/tests/run /path/to/rumiai-os
```

against product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

first on macOS and then on Ubuntu 26.04 LTS/aarch64, recording complete session evidence in the PoC repository.

A passing construction dry-run does not advance the validated product baseline. Only actual reference-host execution can close this regression gate.
