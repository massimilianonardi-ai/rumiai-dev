# Phase 1 command-interpreter proposal

Status: **draft / non-normative / not product code**  
Date: 2026-08-28

This directory contains the current near-code proposal for the RumiAI runtime CLI and command/source interpreter.

The previous multicall/symlink + `cmd/` proposal remains preserved under:

```text
drafts/rumiai-os/phase-1-multicall/
```

but is superseded.

## CLI currently defined

```text
rumiai-os
    bootstrap RumiAI and enter the interactive Rumi shell

rumiai-os file [args...]
    bootstrap RumiAI and source file with args as its positional parameters
```

A source file that should also be directly executable by the host can use:

```text
#!/usr/bin/env rumiai-os
```

The shebang is required only for direct host execution. It is not part of the validity contract for:

```text
rumiai-os file
```

An explicitly supplied source therefore needs to resolve to a readable regular file; it does not need an executable permission bit and does not need a shebang.

## Directly executable RumiAI commands

A directly executable RumiAI command can contain both the interpreter declaration and its implementation body:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

Host execution conceptually becomes:

```text
command file
    ↓ kernel #! support
/usr/bin/env rumiai-os <command-file> <user args...>
    ↓ PATH
active rumiai-os
    ↓
bootstrap
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
    integrated bootstrap + defined CLI proposal

shell.lib
    proposed sourced shell-launch module; intended product role lib/shell.lib

rumi-shell.draft
    earlier standalone shell-launch draft retained for history; shell.lib is the integrated form

bin/log.draft
    minimal directly executable example using the already-loaded log() function

examples/foo.draft
    sample source/command containing its implementation directly
```

## No-argument path

After phase 0, environment setup, i18n and logger initialization, the no-argument branch lazily loads:

```text
$RumiAI_LIB_DIR/shell.lib
```

and calls:

```text
RumiAI_shell
```

The current shell proposal prefers Bash and falls back to POSIX `sh`, using Rumi-specific shell configuration and prompt state.

## Explicit source path

For:

```text
rumiai-os file arg1 arg2
```

`rumiai-os`:

1. canonicalizes `file` with `realpath -e`;
2. requires a readable regular file;
3. rejects sourcing the runtime file itself;
4. records the canonical pathname in `RumiAI_COMMAND_BIN`;
5. removes the source pathname from `$@`;
6. sources the file in the initialized RumiAI shell;
7. propagates its status.

No shebang validation is performed in this path.

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

## Why the command/source is sourced

The body is sourced into the initialized `rumiai-os` shell so it immediately has access to:

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

and avoids recursively invoking the public `log` command.

## Alias behavior

A renamed external alias can point to a directly executable command file itself:

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

`/usr/bin/env` chooses `rumiai-os` from the inherited `PATH` for directly executable command files.

Therefore the active runtime is an environment choice, not a property derived from the command-file location.

## Deliberate portability exception

POSIX.1-2024 does not normatively define general `#!` execution semantics and does not guarantee `/usr/bin/env` as a pathname.

The accepted direct-execution model therefore adds a small explicit RumiAI host-profile requirement. Explicit invocation through:

```text
rumiai-os file
```

does not depend on the file containing a shebang.

Before product promotion a cross-host PoC must verify at least Linux, macOS and Cygwin/reference Windows environment behavior for direct shebang execution.

## Still open

This proposal intentionally does not yet freeze:

1. compatibility/version metadata between source files and the runtime selected from PATH;
2. final shell configuration filenames and all shell lifecycle details;
3. command/source error-status numbers beyond the current draft assignments;
4. policy for third-party/untrusted source files;
5. lifecycle rules for sourced bodies (`return`, `exit`, traps/signals);
6. future non-shell command/source formats or runtime adapters.
