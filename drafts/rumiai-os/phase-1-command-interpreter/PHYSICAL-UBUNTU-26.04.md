# RumiAI OS — Physical Ubuntu 26.04 validation

Date: 2026-08-28  
Status: **physical validation in progress**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Tested product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

## Reference host

Physical/VM host evidence supplied by the user:

```text
Ubuntu 26.04 LTS (Resolute Raccoon)
Linux 7.0.0-30-generic
aarch64
/bin/sh -> /usr/bin/dash
bash -> /usr/bin/bash
realpath -> /usr/bin/realpath
readlink -> /usr/bin/readlink
env -> /usr/bin/env
```

## Clone and repository state — PASS

The repository cloned successfully at the expected product commit and `git status --short` was empty.

Checkout exposure observed:

```text
bin/rumiai-os -> ../rumiai-os
```

Executable files were executable after checkout. The host checkout permissions showed group-write bits (`775`) because working-tree permissions are affected by the host umask; Git tracks the executable bit rather than the full POSIX mode. No repository modification was reported.

## Native canonicalization utilities — PASS

Observed:

```text
realpath -e pathname -> success, status 0
realpath -- pathname -> success, status 0
readlink -e pathname -> success, status 0
```

This confirms the earlier Ubuntu capability observation and, more importantly for the current RumiAI contract, confirms that the cross-host form used by the product works:

```sh
command -p -- realpath -- "$pathname"
```

## Syntax — PASS

The following files passed syntax checking under the host default `sh` (dash):

```text
rumiai-os
lib/i18n.lib
lib/log.lib
lib/shell.lib
bin/log
```

The same files also passed:

```text
bash --posix -n
```

## Explicit source — PASS

A readable, non-executable source without a shebang was invoked as:

```text
./rumiai-os /tmp/rumiai-source-test 'hello world' second
```

Observed:

```text
SOURCE_OK
ROOT=/tmp/rumiai-os-ubuntu-test
COMMAND=/tmp/rumiai-source-test
ARG1=hello world
ARG2=second
STATUS=23
```

This physically confirms on Ubuntu 26.04/aarch64 that:

- the POSIX `#!/bin/sh` bootstrap executes under dash;
- runtime root discovery is correct;
- explicit source canonicalization is correct;
- positional arguments are preserved;
- source status `23` propagates exactly.

## Next validation

Continue with:

1. direct `#!/usr/bin/env rumiai-os` execution through the structural runtime exposure;
2. public logger and validation statuses;
3. Bash and POSIX sh interactive Rumi shells;
4. pathname/symlink/space canonicalization matrix;
5. i18n/configuration matrix;
6. source lifecycle matrix.
