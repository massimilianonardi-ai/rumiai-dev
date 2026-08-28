# Handoff — Ubuntu 26.04 initial physical pass

Date: 2026-08-28
Status: **physical Ubuntu/Linux validation in progress**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Current tested product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

## Reference host

```text
Ubuntu 26.04 LTS (Resolute Raccoon)
Linux 7.0.0-30-generic
aarch64
/bin/sh -> /usr/bin/dash
```

Host tools observed:

```text
sh       /usr/bin/sh
bash     /usr/bin/bash
realpath /usr/bin/realpath
readlink /usr/bin/readlink
env      /usr/bin/env
```

## Initial matrix — PASS

The fresh clone was at the expected product commit and clean.

Native utility behavior:

```text
realpath -e pathname -> 0
realpath -- pathname -> 0
readlink -e pathname -> 0
```

Therefore Ubuntu supports both the Issue-8-style `-e` capability and the smaller cross-host `realpath -- pathname` form currently used by RumiAI.

Syntax passed under both:

```text
sh -n             (dash on this host)
bash --posix -n
```

for:

```text
rumiai-os
lib/i18n.lib
lib/log.lib
lib/shell.lib
bin/log
```

Explicit source execution also passed:

```text
SOURCE_OK
ROOT=/tmp/rumiai-os-ubuntu-test
COMMAND=/tmp/rumiai-source-test
ARG1=hello world
ARG2=second
STATUS=23
```

No product change is required from this test.

## macOS status

The first physical macOS Phase-1 cycle was completed successfully before this Ubuntu pass. Product compatibility fixes already promoted during macOS testing remain:

```text
c245cff5d1bec949f72be9f8b41c77789978342b  Fix realpath portability on macOS
4f311d1fb5b35a722cf9575d890a9fa616040199  Silence macOS Bash deprecation banner
```

## Immediate next Ubuntu work

Run direct shebang execution and the public logger against the same clean checkout. Then validate the Bash and POSIX sh interactive branches before repeating the broader pathname/i18n/lifecycle matrix.
