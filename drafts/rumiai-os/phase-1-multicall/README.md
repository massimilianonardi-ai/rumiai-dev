# Phase 1 multicall bootstrap proposal

Status: **draft / non-normative / not product code**  
Date: 2026-08-28

This directory contains a near-code proposal for making every public `bin/<command>` entrypoint pass through the canonical `rumiai-os` bootstrap without duplicating bootstrap logic inside each command.

Nothing here changes the accepted product code in `rumiai-os`.

## Proposed public/private shape

`cmd/` is used in this draft only as a placeholder name for a directory outside `PATH`. Its final name is explicitly undecided.

```text
RumiAI_ROOT/
├── rumiai-os
├── bin/
│   ├── log -> ../rumiai-os
│   ├── foo -> ../rumiai-os
│   └── ...
├── cmd/                 # placeholder name, NOT accepted yet
│   ├── foo
│   └── ...
├── lib/
│   ├── i18n.lib
│   └── log.lib
├── conf/
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

## Critical distinction exposed by the draft

The front controller must preserve two different facts before phase 0 canonicalizes the physical entrypoint:

```text
RumiAI_INVOKED_AS
    basename used by the caller, e.g. log

RumiAI_INVOKED_BIN
    pathname used to reach that basename before final realpath,
    e.g. /opt/rumiai/bin/log
```

After phase 0:

```text
RumiAI_BOOTSTRAP_BIN
    physical canonical entrypoint, e.g. /opt/rumiai/rumiai-os
```

The pre-realpath pathname is necessary to distinguish an official `bin/log` invocation from an arbitrary external symlink that eventually resolves to the same `rumiai-os` file.

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

For multicall invocation, the draft accepts the command only when:

1. the invocation directory resolves to the physical `RumiAI_BIN_DIR`;
2. `$RumiAI_BIN_DIR/$RumiAI_INVOKED_AS` exists;
3. that official public entry resolves to `RumiAI_BOOTSTRAP_BIN`.

This intentionally rejects arbitrary external aliases in the first proposal. Whether external aliases should later be accepted is still open.

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

The private command directory name and the final in-process/external dispatch policy remain open.

## Error status issue surfaced by multicall

The accepted direction is:

- one exact status per error condition;
- assignments are append-only;
- never renumber or reuse a published status;
- success is `0`;
- application-defined statuses stay within `1..125`.

The existing accepted phase-0 code already assigns:

```text
10 PATH resolution failure
11 realpath failure
12 bootstrap binary failure
13 root failure
```

This predates the new sequential/append-only rule.

Because every multicall command shares the bootstrap, these statuses are visible through every public command. Therefore a command such as `log` cannot independently reuse `10..13` without making its external CLI status ambiguous.

The code proposal preserves phase 0 unchanged and allocates new front-controller draft errors starting at `14`. This is NOT yet a normative numbering decision; it exposes a real design question:

```text
A. preserve accepted 10..13 forever and treat them as globally reserved bootstrap statuses;

or

B. before product/public API stabilization, perform a one-time renumbering of phase-0 errors to fit the new global convention.
```

This should be decided before finalizing public command error tables.

## Files

```text
rumiai-os.draft
    integrated front-controller proposal

foo.draft
    tiny example of a private external command receiving the initialized environment

FLOW.md
    invocation examples and state transitions
```
