# Handoff — macOS pathname and source canonicalization pass

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

## Physical macOS relative PATH test — PASS

From an arbitrary caller directory:

```text
/tmp/rumiai-caller
```

PATH was configured with the relative component:

```text
../rumiai-os-test/bin
```

Observed lookup:

```text
COMMAND_V=../rumiai-os-test/bin/rumiai-os
```

Despite that relative command pathname, Phase 0 resolved:

```text
BOOTSTRAP=/private/tmp/rumiai-os-test/rumiai-os
ROOT=/private/tmp/rumiai-os-test
STATUS=0
```

This confirms physical/canonical runtime resolution is independent of caller CWD and relative PATH entries.

## Explicit source pathname with spaces — PASS

Source:

```text
/tmp/rumiai source space/source file
```

The source was readable, non-executable, had no shebang requirement, received its positional argument, and returned `31`.

Observed canonical source identity:

```text
COMMAND=/private/tmp/rumiai source space/source file
```

Direct pathname invocation produced:

```text
SOURCE_SPACE_OK
ARG1=hello space
STATUS=31
```

## Explicit source symlink canonicalization — PASS

The same source was invoked through:

```text
relative symbolic link
absolute symbolic link
symbolic-link chain
```

Every case converged to:

```text
COMMAND=/private/tmp/rumiai source space/source file
```

Observed arguments:

```text
relative link
absolute link
link chain
```

All cases returned:

```text
STATUS=31
```

## Canonicalization conclusion on macOS

The physical macOS validation now confirms that:

- `RumiAI_BOOTSTRAP_BIN` converges to the physical runtime across relative/absolute/PATH/symlink/space cases;
- `RumiAI_ROOT` remains the physical relocatable product root;
- a relative PATH component works from an arbitrary CWD;
- `RumiAI_COMMAND_BIN` converges independently to the physical explicit source;
- source pathnames containing spaces work;
- source symlink aliases and chains canonicalize correctly;
- positional arguments and exact source status remain preserved after canonicalization.

This closes the main pathname/canonicalization test group on macOS.

## macOS validation passed so far

- native `realpath --` compatibility after removing `-e`;
- explicit source without shebang/executable bit;
- direct `#!/usr/bin/env rumiai-os` execution;
- structural runtime exposure through `bin/rumiai-os`;
- public logger and validation statuses;
- Bash Rumi shell with clean Apple startup;
- POSIX sh Rumi shell;
- Phase 0 relative/absolute/PATH/symlink/intermediate-link/spaces matrix;
- relative PATH entry from arbitrary CWD;
- explicit source with spaces and symlink chains.

## Ubuntu 26.04 evidence

The user physically reported:

```text
realpath -e   supported
readlink -e   supported
```

Full product execution on Ubuntu/Linux remains pending.

## Immediate next macOS work

Before moving the full matrix to Ubuntu, test:

1. language precedence/selection and unsupported-locale fallback;
2. malformed bootstrap language configuration;
3. text-encoding selection/fallback and malformed encoding configuration;
4. sourced-command lifecycle (`return`, `exit`, and basic signal behavior).
