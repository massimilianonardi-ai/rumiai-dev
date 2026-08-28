# Handoff — Phase 1 regression suite ready for physical execution

Date: 2026-08-28
Status: **automated regression harness constructed; reference-host execution pending**

## Source of truth

`rumiai-dev` remains authoritative over chat memory.

## Product baseline

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Current physically validated commit remains unchanged:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

No product changes were made during this work.

## New regression PoC

Repository:

```text
massimilianonardi-ai/rumiai-dev-PoCs
```

PoC:

```text
pocs/004-phase-1-regression/
```

Committed as:

```text
a48d9685459397a5301febdcf237b89b03555236
```

The PoC contains:

```text
tests/run
tests/core
tests/status-map
tests/common.lib
fixtures/
sessions/
```

The three test runners are stored with Git mode `100755`.

## Coverage

`tests/core` automates the non-interactive Phase 1 matrix already physically validated manually, including syntax, source/shebang execution, logger, runtime/source canonicalization, PATH/symlinks/spaces, i18n/config and source lifecycle.

Interactive shell prompt/session behavior remains a real-TTY physical gate and is reported as `SKIP` by the automated core suite.

`tests/status-map` forces all bootstrap/CLI statuses `1..10` against unchanged product code. Destructive cases use disposable product copies. Status `4` uses isolated `cd` fault injection and status `10` uses narrowly scoped `command` fault injection while preserving real `realpath`, `awk` and `date` execution.

Important construction finding:

```text
GNU realpath -- /existing-parent/missing-final
```

may succeed. Therefore status `8` is forced using a pathname with a missing intermediate component, which is deterministic for the intended resolution-failure branch.

## Construction validation

The harness and fixtures passed syntax parsing with:

```text
dash -n
bash --posix -n
```

A branch-compatible local dry-run of the status forcing produced:

```text
SUMMARY pass=10 fail=0 skip=0
```

This is harness-construction evidence only, not new physical product validation. The execution runtime used while constructing the suite could not materialize the GitHub product checkout through shell networking.

Detailed design/status:

```text
drafts/rumiai-os/phase-1-command-interpreter/REGRESSION.md
```

## Next action

Run the suite against the physically validated product commit on the two reference hosts and store full session evidence:

```sh
sh pocs/004-phase-1-regression/tests/run /path/to/rumiai-os
```

Required first hosts:

1. macOS;
2. Ubuntu 26.04 LTS/aarch64.

Do not claim the automated regression gate PASS until both executions have been observed and recorded.

After both pass, update the consolidated validation state and then choose between broader host coverage and Phase 2 functionality.

On resume, read `RULES.md` and dynamically identify the newest file in `handoff/`; do not assume this filename remains the newest.
