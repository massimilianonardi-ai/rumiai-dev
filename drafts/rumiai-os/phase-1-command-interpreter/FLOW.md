# Command-interpreter execution flow

Status: **draft / non-normative**  
Date: 2026-08-28

## Direct command execution

Command file:

```sh
#!/usr/bin/env rumiai-os

log info example started
```

Invocation:

```text
/path/to/foo a b
```

Host/runtime flow:

```text
/path/to/foo a b
    ↓
#! /usr/bin/env rumiai-os
    ↓
/usr/bin/env resolves rumiai-os through PATH
    ↓
rumiai-os /path/to/foo a b
```

Inside `rumiai-os`:

```text
$0 = rumiai-os selected by PATH
$1 = /path/to/foo
$2 = a
$3 = b
```

Then:

```text
phase 0
    ↓
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
    ↓
phase 1
    ↓
semantic roots
bootstrap preferences
i18n
logger
    ↓
realpath($1)
    ↓
RumiAI_COMMAND_BIN=/physical/path/to/foo
    ↓
shift
    ↓
$@ = a b
    ↓
. "$RumiAI_COMMAND_BIN"
```

The command body runs in the initialized shell and can call `log()` directly.

## Minimal `log` command

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

Invocation:

```text
log warn bootstrap language-fallback requested xx_YY selected en_US
```

Flow:

```text
log command file
    ↓
active rumiai-os
    ↓
bootstrap + source lib/log.lib
    ↓
source log command file
    ↓
log "$@"
    ↓
already-loaded log() function
```

There is no recursive command invocation.

## Renamed external alias

```text
/usr/local/bin/my-log -> /opt/rumiai/bin/log
```

Invocation:

```text
my-log warn ...
```

The host starts the command file through its shebang. `rumiai-os` canonicalizes the command operand:

```text
/usr/local/bin/my-log
    ↓ realpath
/opt/rumiai/bin/log
```

and sources the canonical command file.

No basename registration is involved.

## Duplicate basenames

```text
/opt/rumiai/package-a/bin/foo
/opt/rumiai/package-b/bin/foo
```

Whichever pathname the caller executes is passed to `rumiai-os`.

The runtime never has to infer which `foo` was intended from the basename alone.

## Multiple runtimes

If:

```text
PATH selects /opt/rumiai-B/rumiai-os
```

while the user executes:

```text
/opt/rumiai-A/bin/foo
```

then runtime B interprets command file A.

This is the explicit active-environment semantic of the `/usr/bin/env rumiai-os` model.

Future compatibility metadata may reject incompatible combinations, but the bootstrap does not pin a command file to a colocated runtime.

## Direct `rumiai-os`

Invocation:

```text
rumiai-os
```

contains no command-file operand and therefore remains a front-controller invocation.

Its future user-facing CLI behavior is not defined by this command-interpreter proposal.
