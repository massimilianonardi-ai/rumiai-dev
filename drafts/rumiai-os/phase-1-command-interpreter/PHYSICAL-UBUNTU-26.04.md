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

Git index modes were physically confirmed as:

```text
100755 bin/log
120000 bin/rumiai-os
100755 rumiai-os
```

The host checkout permissions showed group-write bits (`775`) because working-tree permissions are affected by the host umask; Git tracks the executable bit rather than the full POSIX mode. No repository modification was reported.

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

## Direct `#!/usr/bin/env rumiai-os` execution — PASS

The RumiAI `bin/` directory was prepended to PATH. Observed:

```text
RUNTIME_IN_PATH=/tmp/rumiai-os-ubuntu-test/bin/rumiai-os
RUNTIME_REAL=/tmp/rumiai-os-ubuntu-test/rumiai-os
```

An executable source beginning with:

```text
#!/usr/bin/env rumiai-os
```

was executed directly with two arguments.

Observed:

```text
DIRECT_OK
ROOT=/tmp/rumiai-os-ubuntu-test
COMMAND=/tmp/rumiai-direct-test
ARG1=hello direct
ARG2=second
DIRECT_STATUS=24
```

This physically confirms on Ubuntu 26.04/aarch64 that:

- `/usr/bin/env` resolves `rumiai-os` through inherited PATH;
- the structural `bin/rumiai-os -> ../rumiai-os` exposure works;
- direct host shebang execution forwards the source pathname correctly;
- runtime and source canonicalization are correct;
- original arguments are preserved;
- source status `24` propagates unchanged.

## Public logger — PASS

`command -v log` and `realpath` both resolved to:

```text
/tmp/rumiai-os-ubuntu-test/bin/log
```

Observed logger statuses:

```text
valid log           -> 0
invalid severity    -> 12
invalid domain      -> 13
invalid message-id  -> 14
invalid fields      -> 15
invalid log level   -> 16
filtered debug      -> 0
```

The valid log record was localized through the Italian catalog. A debug record filtered by the default `info` threshold emitted no record and returned success.

This reproduces the macOS logger contract on Ubuntu 26.04/aarch64.

## Interactive Bash Rumi shell — PASS

Running:

```text
./rumiai-os
```

with the default shell configuration entered Bash with the configured prompt:

```text
[RumiAI] admino@vmdev:/tmp/rumiai-os-ubuntu-test $
```

Observed state:

```text
$0=bash
RumiAI_ROOT=/tmp/rumiai-os-ubuntu-test
RumiAI_BIN_DIR=/tmp/rumiai-os-ubuntu-test/bin
RumiAI_LANGUAGE=it_IT
RumiAI_TEXT_ENCODING=UTF-8
command -v rumiai-os -> /tmp/rumiai-os-ubuntu-test/bin/rumiai-os
command -v log       -> /tmp/rumiai-os-ubuntu-test/bin/log
realpath rumiai-os    -> /tmp/rumiai-os-ubuntu-test/rumiai-os
realpath log          -> /tmp/rumiai-os-ubuntu-test/bin/log
log status            -> 0
shell exit status     -> 0
```

No host-specific banner or unexpected startup output was emitted.

## Interactive POSIX sh / dash Rumi shell — PASS

The tracked shell selection was temporarily changed:

```text
conf/shell/default: bash -> sh
```

Running `./rumiai-os` entered the POSIX shell branch with:

```text
[RumiAI] $
```

Observed state:

```text
$0=/usr/bin/sh
RumiAI_ROOT=/tmp/rumiai-os-ubuntu-test
RumiAI_BIN_DIR=/tmp/rumiai-os-ubuntu-test/bin
command -v rumiai-os -> /tmp/rumiai-os-ubuntu-test/bin/rumiai-os
command -v log       -> /tmp/rumiai-os-ubuntu-test/bin/log
log status            -> 0
```

The host had already established:

```text
/usr/bin/sh -> dash
```

so this physically validates the `sh` branch under dash on Ubuntu 26.04/aarch64.

During interactive paste, one input boundary joined `exit` and the following `printf`, producing:

```text
/usr/bin/sh: 8: exitprintf: not found
```

This was a terminal paste/input artifact, not a RumiAI failure. All RumiAI state and logger checks had already passed, and the shell subsequently exited with status `0`.

After the test:

```text
SH_RUMI_EXIT_STATUS=0
git status --short -> empty
conf/shell/default -> bash
```

Therefore both interactive shell branches are physically validated on Ubuntu 26.04/aarch64.

## Next validation

Continue with:

1. pathname/symlink/space canonicalization matrix;
2. relative PATH invocation from arbitrary CWD and source symlink/space matrix;
3. i18n/configuration matrix;
4. source lifecycle matrix.
