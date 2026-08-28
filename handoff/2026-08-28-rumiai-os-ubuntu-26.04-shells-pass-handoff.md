# Handoff — Ubuntu 26.04 Bash and sh shell passes

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
/usr/bin/sh -> dash
```

## Bash Rumi shell — PASS

Default `./rumiai-os` entered Bash with the configured RumiAI prompt.

Observed:

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
exit status           -> 0
```

## POSIX sh / dash Rumi shell — PASS

`conf/shell/default` was temporarily changed from `bash` to `sh`.

Observed:

```text
[RumiAI] $
$0=/usr/bin/sh
RumiAI_ROOT=/tmp/rumiai-os-ubuntu-test
RumiAI_BIN_DIR=/tmp/rumiai-os-ubuntu-test/bin
command -v rumiai-os -> /tmp/rumiai-os-ubuntu-test/bin/rumiai-os
command -v log       -> /tmp/rumiai-os-ubuntu-test/bin/log
log status            -> 0
exit status           -> 0
```

The host had already physically established that `/usr/bin/sh` resolves to dash, so the POSIX branch is validated under dash.

One interactive paste joined `exit` and a following `printf`, yielding:

```text
/usr/bin/sh: 8: exitprintf: not found
```

This was a paste/input artifact and not a RumiAI defect. All RumiAI checks had already passed, and the shell subsequently exited normally.

After the test:

```text
git status --short -> empty
conf/shell/default -> bash
```

## Ubuntu validation passed so far

- clean clone at product commit;
- Git modes and structural symlink;
- dash and Bash POSIX syntax;
- `realpath -e`, `realpath --`, `readlink -e` host capabilities;
- explicit source status `23`;
- direct `#!/usr/bin/env rumiai-os` status `24`;
- logger statuses `12..16` and filtering;
- interactive Bash Rumi shell;
- interactive POSIX sh/dash Rumi shell.

## Immediate next work

Run the pathname/symlink/space canonicalization matrix already validated on macOS, followed by the relative-PATH/source-alias matrix, then i18n/configuration and source lifecycle.
