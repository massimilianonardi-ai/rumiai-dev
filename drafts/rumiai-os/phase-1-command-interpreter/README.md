# Phase 1 command-interpreter proposal

Status: **draft / non-normative / not product code**  
Date: 2026-08-28

This directory contains the code proposal derived from the accepted decision:

```text
#!/usr/bin/env rumiai-os
```

The previous multicall/symlink + `cmd/` proposal remains preserved under:

```text
drafts/rumiai-os/phase-1-multicall/
```

but is superseded.

## Core idea

A RumiAI command file is simultaneously:

- the public executable entrypoint;
- the command implementation body;
- the pathname passed to the active RumiAI runtime.

There is no mandatory launcher/implementation split.

Example:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

Execution conceptually becomes:

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

## Files

```text
rumiai-os.draft
    integrated bootstrap + command interpreter proposal

bin/log.draft
    minimal example using the already-loaded log() function

examples/foo.draft
    sample command containing its implementation directly
```

## Removed concepts

The current proposal deliberately contains none of the following:

```text
cmd/
RumiAI_COMMAND_DIR
bin/<command> -> rumiai-os multicall symlinks
RumiAI_INVOKED_AS
RumiAI_INVOKED_BIN
basename-based registration
multicall alias validation
command-path shadow mapping
```

## Why the command is sourced

The command body is sourced into the initialized `rumiai-os` shell so it immediately has access to:

```text
RumiAI_ROOT
RumiAI_BIN_DIR
RumiAI_LIB_DIR
RumiAI_CONF_DIR
RumiAI_LANG_DIR
RumiAI_LANGUAGE
RumiAI_TEXT_ENCODING
log()
i18n()
```

This makes `bin/log` particularly small:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

and avoids recursive invocation of the public `log` command.

## Alias behavior

A renamed external alias can point to the command file itself:

```text
/usr/local/bin/my-log -> /opt/rumiai/bin/log
```

The runtime canonicalizes the command-file pathname before sourcing it. The alias basename has no dispatch meaning.

## Duplicate basenames

No collision exists merely because two command files have the same basename:

```text
package-a/bin/foo
package-b/bin/foo
```

The selected file pathname is passed to `rumiai-os`, so the runtime does not need a global basename namespace.

## Active runtime

`/usr/bin/env` chooses `rumiai-os` from the inherited `PATH`.

Therefore the active runtime is an environment choice, not a property derived from the command-file location.

This is intentional and must be documented for multiple-installation/version scenarios.

## Deliberate portability exception

POSIX.1-2024 does not normatively define general `#!` execution semantics and does not guarantee `/usr/bin/env` as a pathname.

The accepted model therefore adds a small explicit RumiAI host-profile requirement rather than implementing multicall complexity to remain inside the abstract POSIX contract.

Before product promotion a cross-host PoC must verify at least Linux, macOS and Cygwin/reference Windows environment behavior.

## Still open

This proposal intentionally does not yet freeze:

1. direct `rumiai-os` CLI syntax when no command file is supplied;
2. compatibility/version metadata between command files and the runtime selected from PATH;
3. command-entry error/status numbers beyond the current draft assignments;
4. policy for third-party/untrusted command files;
5. whether sourced command bodies should follow additional lifecycle rules (`return` versus `exit`);
6. whether future non-shell command formats need metadata or a thin shell adapter.
