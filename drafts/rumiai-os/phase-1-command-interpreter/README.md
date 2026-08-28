# Phase 1 command-interpreter proposal

Status: **consolidated near-code / promoted candidate**  
Date: 2026-08-28

This directory contains the code proposal derived from the accepted command-entry decision:

```text
#!/usr/bin/env rumiai-os
```

The previous multicall/symlink + `cmd/` proposal remains preserved under:

```text
drafts/rumiai-os/phase-1-multicall/
```

but is superseded.

## CLI

```text
rumiai-os
    bootstrap RumiAI and enter the configured interactive Rumi shell

rumiai-os file [args...]
    bootstrap RumiAI and source the explicitly supplied readable file
```

A source supplied explicitly to `rumiai-os` does not need a shebang or executable permission.

A file intended for direct host execution through RumiAI uses:

```text
#!/usr/bin/env rumiai-os
```

The shebang is a host execution mechanism, not part of source validity.

## Core model

The command/source file is its own implementation body. There is no mandatory launcher/implementation split and no `cmd/` shadow tree.

Direct execution conceptually becomes:

```text
command file
    ↓ kernel #! support
/usr/bin/env rumiai-os <command-file> <user args...>
    ↓ PATH
active rumiai-os
    ↓
phase 0
    ↓
phase 1 + i18n + logger
    ↓
realpath(command-file)
    ↓
shift command-file operand
    ↓
source command-file
```

The sourced body sees the original user arguments in `$@`.

## No-argument shell

After bootstrap, `rumiai-os` with no operands loads:

```text
$RumiAI_LIB_DIR/shell.lib
```

and calls:

```text
RumiAI_shell
```

Current shell policy:

```text
preferred: bash
fallback:  POSIX sh
```

Shell configuration lives under:

```text
conf/shell/
```

with a recognizable/customizable RumiAI prompt.

## Current source files

```text
rumiai-os.draft
    integrated bootstrap + CLI proposal

shell.lib
    Rumi shell launcher

bin/log.draft
    minimal direct command using the already-loaded log() function

examples/foo.draft
    sample command/source
```

The i18n/logger libraries are maintained in:

```text
drafts/rumiai-os/phase-1-i18n-log/
```

## Removed concepts

The current proposal deliberately contains none of the following:

```text
cmd/
RumiAI_COMMAND_DIR
bin/<command> -> rumiai-os multicall command links
RumiAI_INVOKED_AS
RumiAI_INVOKED_BIN
basename-based registration
multicall alias validation
command-path shadow mapping
mandatory shebang validation for rumiai-os file
```

## Source and library loading

Bootstrap libraries are checked for regular/readable status before sourcing and are loaded through the compact POSIX form:

```sh
if ! . "$library"
then
    ...
fi
```

No temporary load-status variable is retained when only success/failure matters.

## Status allocation currently used by the candidate

Shared runtime:

```text
1  bootstrap PATH resolution failure
2  bootstrap realpath failure
3  invalid bootstrap binary
4  invalid/inaccessible RumiAI root
5  i18n library load failure
6  log library load failure
7  shell library load failure
8  explicit source resolution failure
9  invalid explicit source entry
10 shell launch failure
```

Public `log()` / `bin/log`:

```text
11 invalid argument count
12 invalid severity
13 invalid domain
14 invalid message-id
15 invalid structured fields
16 invalid log level
```

Logger fields are fully validated before any line is emitted, preventing partial log records on validation failure.

## Active runtime

`/usr/bin/env` chooses `rumiai-os` from the inherited `PATH`. The active runtime is therefore an environment choice rather than a property derived from the command-file location.

The portable Rumi shell exposes the runtime through the RumiAI `bin/` directory; optional host integration can expose it globally through a separate symlink policy.

## Portability boundary

POSIX.1-2024 remains the shell/utility baseline, but general `#!` execution and the fixed `/usr/bin/env` pathname are explicit RumiAI host-profile requirements.

Physical validation on the selected macOS and Linux hosts is the next gate after product promotion.
