# Handoff — RumiAI OS multicall bootstrap code proposal

Date: 2026-08-28
Status: **active design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product boundary

Phase 0 in `rumiai-os` remains product code and has not been modified by this work.

No phase-1/multicall product implementation has been authorized or performed.

The new material is non-normative draft code in `rumiai-dev` only.

## Previously accepted phase-1/i18n/logger direction

```text
RumiAI_BIN_DIR  = $RumiAI_ROOT/bin
RumiAI_LIB_DIR  = $RumiAI_ROOT/lib
RumiAI_CONF_DIR = $RumiAI_ROOT/conf
RumiAI_LANG_DIR = $RumiAI_ROOT/lang

conf/bootstrap/language
conf/bootstrap/text-encoding

RumiAI_LANGUAGE
RumiAI_TEXT_ENCODING
```

Catalogs and internal RumiAI-controlled text are UTF-8.

Logger public shell API direction:

```sh
log warn domain message-id field value ...
```

`lib/log.lib` is sourced into the bootstrap shell; `bin/log` is intended as the process/language-neutral public interface.

## Multicall proposal

Public `bin/<command>` entries are proposed as symlinks to the canonical front controller:

```text
bin/log -> ../rumiai-os
bin/foo -> ../rumiai-os
```

This guarantees that direct public command invocation passes through the RumiAI bootstrap without embedding a mini-bootstrap in every script.

Two invocation forms converge:

```text
log warn ...
rumiai-os log warn ...
```

Both become:

```text
RumiAI_COMMAND=log
arguments=warn ...
```

## Invocation state

The draft captures before final realpath:

```text
RumiAI_INVOKED_AS=${0##*/}
RumiAI_INVOKED_BIN=<pre-realpath invocation pathname>
```

After phase 0:

```text
RumiAI_BOOTSTRAP_BIN=<physical canonical rumiai-os>
RumiAI_ROOT=<physical canonical root>
```

Preserving `RumiAI_INVOKED_BIN` is necessary to distinguish official `bin/log` from an arbitrary external symlink that resolves to the same `rumiai-os` file.

## First validation policy

A multicall command is accepted only if:

```text
physical invocation directory == physical RumiAI_BIN_DIR
```

and:

```text
realpath(RumiAI_BIN_DIR/RumiAI_INVOKED_AS)
    == RumiAI_BOOTSTRAP_BIN
```

External aliases are therefore rejected in this first proposal. This remains an open policy choice.

## Hybrid dispatch

After logger initialization:

```text
RumiAI_COMMAND=log
    -> call already loaded shell function log "$@"

other RumiAI_COMMAND
    -> invoke private executable outside PATH
```

The draft uses `cmd/` only as a placeholder private-directory name. It is NOT an accepted filesystem decision.

The draft deliberately invokes the private executable as a child and propagates `$?`, rather than using `exec`, so failure/status behavior remains explicit during design review. `exec` can be reconsidered later as an optimization.

## External child processes

A separately executed POSIX script does not inherit sourced shell functions such as `log()`.

It does inherit exported RumiAI environment variables and PATH.

Therefore external/private commands can either:

- explicitly source `RumiAI_LIB_DIR/log.lib` when they are POSIX shell and want the in-process API;
- invoke public `bin/log` as a language-neutral process API.

## Error status design issue exposed by multicall

Accepted direction:

```text
0       success
1..125  application error statuses
one exact number per exact error
append-only assignment
never renumber/reuse a published number
```

Existing phase-0 product code already uses:

```text
10 PATH resolution
11 realpath
12 bootstrap binary
13 root
```

Because every public multicall command can fail during shared bootstrap, these values appear in the external status contract of every command.

Therefore command-local status tables cannot independently reuse bootstrap-reserved values if numeric status alone must identify the exact failure.

The code proposal preserves accepted phase 0 and tentatively continues shared front-controller errors at:

```text
14 i18n library load
15 log library load
16 invalid multicall
17 invalid command
18 private command unavailable
```

These new numbers are draft only.

Before public API stabilization, decide whether:

1. preserve phase-0 `10..13` as permanently globally reserved bootstrap values and build around the gap; or
2. make a one-time pre-stability renumbering so the shared bootstrap status namespace follows the new sequential convention cleanly.

No global general error-catalog subsystem is proposed yet.

## Draft files

```text
drafts/rumiai-os/phase-1-multicall/README.md
drafts/rumiai-os/phase-1-multicall/rumiai-os.draft
drafts/rumiai-os/phase-1-multicall/foo.draft
drafts/rumiai-os/phase-1-multicall/FLOW.md
```

## Immediate review questions

Use the code proposal to decide:

1. whether preserving both `RumiAI_INVOKED_AS` and `RumiAI_INVOKED_BIN` is the desired mechanism;
2. whether only canonical `bin/` invocation should be accepted or external aliases should also work;
3. final name/role of the private implementation directory currently called `cmd/` in the draft;
4. whether generic private commands should be child-invoked or `exec`-replaced;
5. how to reconcile existing phase-0 statuses `10..13` with the newly accepted append-only exact-error convention;
6. after these choices, determine whether the multicall behavior warrants a formal cross-host PoC before product implementation.
