# Command-interpreter validation

Date: 2026-08-28
Status: **physical reference-host validation in progress**

## Local pre-promotion validation

The consolidated candidate was checked before promotion to `rumiai-os`.

### Syntax

The candidate sources passed syntax checking under:

```text
dash
bash --posix
busybox sh
```

Checked files:

```text
rumiai-os
lib/i18n.lib
lib/log.lib
lib/shell.lib
```

### Explicit source invocation

For a readable, non-executable source file returning status `23`:

```text
rumiai-os source-test value
```

all three local shell implementations produced:

```text
status = 23
source argument preserved
RumiAI_ROOT correct
RumiAI_COMMAND_BIN canonical and correct
```

This validates the intended distinction between source interpretation and direct host execution: no shebang or executable bit is required for `rumiai-os file`.

### Direct shebang execution

With the runtime exposed in `PATH` through the RumiAI `bin/` directory, an executable file beginning with:

```text
#!/usr/bin/env rumiai-os
```

was executed successfully and observed the expected original user arguments and RumiAI environment.

### Logger status contract

The cleaned logger candidate was exercised for the distinct validation failures:

```text
invalid severity    -> 12
invalid domain      -> 13
invalid message-id  -> 14
invalid fields      -> 15
invalid log level   -> 16
```

Invalid structured fields are detected before any log record is emitted, so validation failure does not leave a partial stderr line.

### Previously validated command-entry properties

Earlier local checks also confirmed:

- renamed symlink aliases to command files;
- duplicate basenames in distinct directories;
- active runtime selection by `PATH`;
- sourcing command files whose first line is `#!/usr/bin/env rumiai-os` under `dash`, `bash --posix` and BusyBox `sh`.

## Physical macOS evidence

Reference host: physical macOS system tested on 2026-08-28.

The native utility behavior was observed as:

```text
/bin/realpath -e pathname    -> unsupported, status 1
/bin/realpath -- pathname    -> success
/bin/realpath pathname       -> success
/bin/realpath -q pathname    -> success
```

This finding caused the product compatibility correction from `realpath -e --` to:

```sh
command -p -- realpath -- "$pathname"
```

followed by explicit RumiAI object validation.

Product compatibility-fix commit:

```text
c245cff5d1bec949f72be9f8b41c77789978342b
```

### Explicit source — PASS

Physical macOS explicit-source execution passed with a non-executable source containing no shebang:

```text
./rumiai-os /tmp/rumiai-source-test 'hello world' second
```

Observed result:

```text
SOURCE_OK
ROOT=/private/tmp/rumiai-os-test
COMMAND=/private/tmp/rumiai-source-test
ARG1=hello world
ARG2=second
STATUS=23
```

The `/tmp` -> `/private/tmp` change is the expected physical canonicalization on this macOS host.

### Direct shebang execution — PASS

The RumiAI `bin/` directory was prepended to the caller PATH:

```text
RUNTIME_IN_PATH=/tmp/rumiai-os-test/bin/rumiai-os
RUNTIME_REAL=/private/tmp/rumiai-os-test/rumiai-os
```

An executable source beginning with:

```text
#!/usr/bin/env rumiai-os
```

was then executed directly as:

```text
/tmp/rumiai-direct-test 'hello direct' second
```

Observed result:

```text
DIRECT_OK
ROOT=/private/tmp/rumiai-os-test
COMMAND=/private/tmp/rumiai-direct-test
ARG1=hello direct
ARG2=second
STATUS=24
```

This physically confirms on macOS that:

- `/usr/bin/env` resolves `rumiai-os` through PATH;
- `bin/rumiai-os -> ../rumiai-os` works as the structural runtime exposure;
- the host passes the executable source pathname to `rumiai-os` in the required form;
- phase 0 canonicalizes the runtime through the structural symlink;
- `RumiAI_COMMAND_BIN` canonicalizes the directly executed source;
- original user arguments are preserved;
- source status `24` propagates unchanged.

### Public logger — PASS

Physical `bin/log` invocation passed on macOS.

Observed public statuses:

```text
valid log           -> 0
invalid severity    -> 12
invalid domain      -> 13
invalid message-id  -> 14
invalid fields      -> 15
invalid log level   -> 16
filtered debug      -> 0
```

The valid record was localized through the Italian catalog, and a debug record filtered by the default `info` threshold produced no output while returning success.

### Interactive Rumi shell — PASS

Running:

```text
./rumiai-os
```

successfully entered Bash and produced the configured RumiAI prompt:

```text
[RumiAI] user@host:/tmp/rumiai-os-test $
```

Observed state inside the shell:

```text
$0=bash
RumiAI_ROOT=/private/tmp/rumiai-os-test
RumiAI_BIN_DIR=/private/tmp/rumiai-os-test/bin
RumiAI_LANGUAGE=it_IT
RumiAI_TEXT_ENCODING=UTF-8
command -v rumiai-os -> /private/tmp/rumiai-os-test/bin/rumiai-os
command -v log       -> /private/tmp/rumiai-os-test/bin/log
```

`log` worked from inside the Rumi shell and the shell exited with status `0`.

Apple's bundled Bash initially emitted its host-specific deprecation banner before the RumiAI prompt:

```text
The default interactive shell is now zsh.
```

Product `lib/shell.lib` was updated to export:

```text
BASH_SILENCE_DEPRECATION_WARNING=1
```

before launching Bash.

Product banner-suppression commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

After pulling that commit, physical macOS re-test produced the RumiAI prompt immediately with no Apple zsh/deprecation banner, and `$0` remained `bash`.

This validates the Bash branch of the interactive Rumi shell on the tested macOS host.

## Physical Ubuntu 26.04 evidence

Reference host evidence supplied from an Ubuntu 26.04 physical test on 2026-08-28:

```text
realpath -e   supported
readlink -e   supported
```

This is recorded as host capability evidence, not as a reason to restore `-e` to the RumiAI runtime contract. The product intentionally uses the smaller cross-host invocation:

```sh
command -p -- realpath -- "$pathname"
```

and performs required existence/type/readability validation itself.

Full `rumiai-os` physical execution on Ubuntu/Linux is still pending.

## Remaining reference-host validation

Physical macOS validation should still cover at minimum:

- POSIX sh shell selection/fallback branch;
- phase-0 relative/absolute/PATH/symlink edge cases;
- spaces and symbolic links in relevant paths;
- language fallback variations;
- basic signal/exit behavior of sourced commands.

Full Linux product validation remains pending.

Cygwin/reference Windows validation remains a later host-profile gate.
