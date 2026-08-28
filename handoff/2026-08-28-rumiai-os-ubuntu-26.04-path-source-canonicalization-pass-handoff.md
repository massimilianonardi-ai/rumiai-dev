# Handoff — Ubuntu 26.04 pathname and source canonicalization pass

Date: 2026-08-28
Status: **physical Ubuntu 26.04 validation in progress**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Tested product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

Reference host:

```text
Ubuntu 26.04 LTS (Resolute Raccoon)
Linux 7.0.0-30-generic
aarch64
/bin/sh -> /usr/bin/dash
```

## Runtime pathname/canonicalization matrix — PASS

A diagnostic explicit source printed `RumiAI_BOOTSTRAP_BIN` and `RumiAI_ROOT` and returned `0`.

The runtime was invoked through all of these forms:

```text
relative pathname
absolute pathname
PATH lookup
relative symbolic link
absolute symbolic link
symbolic-link chain
symbolic link in an intermediate pathname component
runtime pathname containing spaces
```

Every case converged to exactly:

```text
BOOTSTRAP=/tmp/rumiai-os-ubuntu-test/rumiai-os
ROOT=/tmp/rumiai-os-ubuntu-test
STATUS=0
```

This reproduces the canonical runtime identity behavior already physically validated on macOS.

## Relative PATH from arbitrary CWD — PASS

From:

```text
/tmp/rumiai-caller
```

PATH contained the relative component:

```text
../rumiai-os-ubuntu-test/bin
```

Observed:

```text
COMMAND_V=../rumiai-os-ubuntu-test/bin/rumiai-os
BOOTSTRAP=/tmp/rumiai-os-ubuntu-test/rumiai-os
ROOT=/tmp/rumiai-os-ubuntu-test
STATUS=0
```

Therefore Phase 0 correctly converts a relative PATH result into the physical absolute runtime identity independently of caller CWD.

## Explicit source path with spaces — PASS

The explicit source lived at:

```text
/tmp/rumiai source space/source file
```

Direct invocation observed:

```text
SOURCE_SPACE_OK
COMMAND=/tmp/rumiai source space/source file
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
COMMAND=/tmp/rumiai source space/source file
```

with the expected argument preserved and:

```text
STATUS=31
```

## Repository state

Final observed:

```text
git status --short -> empty
```

No product modification was required.

## Ubuntu 26.04 validation passed so far

- clean clone at product commit `4f311d1...`;
- `/bin/sh`/`/usr/bin/sh` executing dash;
- native `realpath -e`, `realpath --`, `readlink -e` capability;
- syntax under dash and `bash --posix`;
- explicit non-executable source, status `23`;
- Git modes and structural runtime symlink;
- direct `#!/usr/bin/env rumiai-os`, status `24`;
- public logger and statuses `12..16`;
- Bash and POSIX sh/dash interactive Rumi shells;
- runtime relative/absolute/PATH/symlink/intermediate-link/spaces matrix;
- relative PATH component from arbitrary caller CWD;
- explicit source path with spaces and symlink aliases/chains.

## Immediate next work

Only two major parity groups remain before completing the first Ubuntu Phase 1 physical-validation cycle:

1. i18n/bootstrap configuration precedence, normalization, fallback and malformed configuration;
2. sourced-command lifecycle (`return`, fall-through status, `exit`, and signal termination).
