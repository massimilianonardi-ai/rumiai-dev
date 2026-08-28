# Handoff — Ubuntu 26.04 direct shebang and logger pass

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

## Git modes — PASS

Observed index modes:

```text
100755 bin/log
120000 bin/rumiai-os
100755 rumiai-os
```

## Direct shebang — PASS

With the RumiAI `bin/` directory prepended to PATH:

```text
RUNTIME_IN_PATH=/tmp/rumiai-os-ubuntu-test/bin/rumiai-os
RUNTIME_REAL=/tmp/rumiai-os-ubuntu-test/rumiai-os
```

A directly executable source using:

```text
#!/usr/bin/env rumiai-os
```

produced:

```text
DIRECT_OK
ROOT=/tmp/rumiai-os-ubuntu-test
COMMAND=/tmp/rumiai-direct-test
ARG1=hello direct
ARG2=second
DIRECT_STATUS=24
```

Therefore `/usr/bin/env` PATH resolution, structural runtime exposure, command-path forwarding, canonicalization, argument preservation and exact source status propagation are physically confirmed on Ubuntu 26.04/aarch64.

## Public logger — PASS

`log` resolved to:

```text
/tmp/rumiai-os-ubuntu-test/bin/log
```

Observed statuses:

```text
valid log           -> 0
invalid severity    -> 12
invalid domain      -> 13
invalid message-id  -> 14
invalid fields      -> 15
invalid log level   -> 16
filtered debug      -> 0
```

The valid record was localized in Italian. Filtered debug returned success without output.

The logger behavior therefore matches the physically validated macOS behavior.

## Validation already passed on Ubuntu 26.04/aarch64

- product commit and clean clone;
- `/bin/sh` resolves to dash;
- `realpath -e`, `realpath --`, and `readlink -e` available;
- syntax under dash and `bash --posix`;
- explicit readable/non-executable source without shebang, status `23`;
- Git modes for runtime, logger, and structural symlink;
- direct `#!/usr/bin/env rumiai-os`, status `24`;
- public logger and statuses `12..16`;
- localized catalog output and debug filtering.

## Immediate next work

Test both interactive Rumi shell branches on Ubuntu:

1. default Bash shell, prompt, environment, PATH and logger;
2. temporary `conf/shell/default = sh`, which on this host must execute dash through `/usr/bin/sh`/`/bin/sh`;
3. restore tracked shell configuration and confirm clean worktree.

After shell validation, run the pathname/symlink/space matrix, i18n/configuration matrix, and source lifecycle matrix already validated on macOS.
