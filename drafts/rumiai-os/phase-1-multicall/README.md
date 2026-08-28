# Phase 1 multicall bootstrap proposal

Status: **draft / non-normative / not product code**  
Date: 2026-08-28

This directory contains a near-code proposal for making every public `bin/<command>` entrypoint pass through the canonical `rumiai-os` bootstrap without duplicating bootstrap logic inside each command.

Nothing here changes the product code in `rumiai-os`.

## Accepted public/private shape

The private command directory is now accepted as:

```text
cmd/
```

It is outside `PATH` and is addressed through:

```text
RumiAI_COMMAND_DIR=$RumiAI_ROOT/cmd
```

Current intended shape:

```text
RumiAI_ROOT/
├── rumiai-os
├── bin/
│   ├── log -> ../rumiai-os
│   ├── foo -> ../rumiai-os
│   └── ...
├── cmd/
│   ├── foo
│   └── ...
├── lib/
│   ├── i18n.lib
│   └── log.lib
├── conf/
│   └── bootstrap/
│       ├── language
│       └── text-encoding
└── lang/
```

Public commands in `bin/` are multicall links to `rumiai-os`.

The canonical bootstrap therefore runs for both:

```text
log warn ...
rumiai-os log warn ...
foo ...
rumiai-os foo ...
```

## Invocation identity

Before phase 0 canonicalizes the physical entrypoint the front controller preserves:

```text
RumiAI_INVOKED_AS
    basename used by the caller, e.g. log

RumiAI_INVOKED_BIN
    pathname used to reach that basename before final realpath
```

After phase 0:

```text
RumiAI_BOOTSTRAP_BIN
    physical canonical entrypoint, e.g. /opt/rumiai/rumiai-os
```

`realpath -e` follows relative or absolute symbolic-link chains to the physical `rumiai-os`; therefore `RumiAI_ROOT` is derived from the actual RumiAI target, not from the directory containing an external alias.

## External aliases

An alias is no longer required to live physically inside `RumiAI_BIN_DIR`.

For a multicall invocation whose basename is `log`, the decisive check is:

```text
realpath($RumiAI_BIN_DIR/log)
    == RumiAI_BOOTSTRAP_BIN
```

Therefore an external alias such as:

```text
/usr/local/bin/log -> /opt/rumiai/rumiai-os
```

or a relative symlink resolving to the same target is accepted when `bin/log` is an official RumiAI public command resolving to that same `rumiai-os`.

An arbitrary alias name is rejected when no corresponding official `bin/<name>` entry exists or when that entry resolves somewhere else.

A symlink named `rumiai-os` is treated as an alias of the front controller itself and uses the normal `rumiai-os <command> ...` form.

## Bootstrap preferences

The integrated draft no longer uses hardcoded `RumiAI_LANGUAGE` / `RumiAI_TEXT_ENCODING` shortcuts.

It now:

1. reads `conf/bootstrap/language` when present;
2. otherwise uses `LC_ALL`, `LC_MESSAGES`, `LANG`, then `en_US`;
3. reads `conf/bootstrap/text-encoding` when present;
4. otherwise requests `UTF-8`;
5. loads `i18n.lib`;
6. normalizes/selects the effective language and text encoding;
7. loads `log.lib`;
8. after logger activation, reports non-fatal configuration/fallback conditions.

Bootstrap preference files are treated as one-line data, not sourced shell code.

## Command selection

Two forms converge to one `RumiAI_COMMAND`:

```text
bin/log warn ...
    $0 -> bin/log
    RumiAI_COMMAND=log
    args=warn ...

rumiai-os log warn ...
    $0 -> rumiai-os
    first operand -> log
    RumiAI_COMMAND=log
    args=warn ...
```

## Dispatch

The draft uses a hybrid dispatch model:

```text
log
    already available in-process from lib/log.lib
    -> call log "$@"

other command
    -> invoke $RumiAI_COMMAND_DIR/$RumiAI_COMMAND "$@"
    -> propagate its status
```

Whether generic private commands should eventually use `exec` instead of child invocation remains open.

## Shared front-controller error statuses

The pre-stability numbering has been reset to follow the accepted sequential rule:

```text
1  PATH resolution failure
2  canonical realpath failure
3  invalid bootstrap binary
4  invalid/inaccessible RumiAI root
5  i18n library load failure
6  log library load failure
7  invalid multicall invocation
8  invalid command name
9  private command unavailable
```

These values describe the shared front controller only.

A separate remaining design point is how command-local/library return codes map to CLI exit statuses without colliding with shared bootstrap/front-controller statuses. That mapping must be fixed before public command contracts are frozen.

## Files

```text
rumiai-os.draft
    integrated front-controller proposal

foo.draft
    tiny example of a private external command receiving the initialized environment

FLOW.md
    invocation examples and state transitions
```
