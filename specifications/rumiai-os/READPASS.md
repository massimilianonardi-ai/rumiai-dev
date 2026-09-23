# RumiAI OS — secret-line terminal input

Status: **Current / normative**  
Updated: 2026-09-22

## 1. Purpose

The current secret-line input surface consists of two commands:

```text
readpass
readpassv
```

`readpass` is the low-level standalone primitive that reads one line from the controlling terminal with echo disabled.

`readpassv` is the bootstrap-integrated verification wrapper that invokes `readpass` twice, compares the two values exactly and emits the secret only when they match.

## 2. Command identities and runtime classes

Canonical product paths:

```text
bin/sys/readpass
bin/sys/readpassv
```

`readpass` is intentionally independent from the `m` bootstrap and uses exactly:

```sh
#!/bin/sh
```

It MUST NOT depend on `m_*` variables, `m_COMMAND_BIN`, `log`, `lang`, `m` shell libraries or bootstrap-created PATH semantics.

`readpassv` depends on the `m` runtime to resolve the `m`-owned `readpass` command and uses exactly:

```sh
#!/usr/bin/env m
```

It resolves `readpass` from the bootstrap-provided system command directory rather than accepting an inherited host-PATH substitute.

## 3. readpass interface

Invocation:

```text
readpass [<prompt>]
```

Zero or one argument is valid. More than one argument is invalid invocation.

The optional prompt is one string. It is written directly to the controlling terminal and is not part of standard output.

## 4. Terminal and input contract

`readpass` reads from:

```text
/dev/tty
```

rather than from standard input.

This keeps stdin available to the caller and permits use inside command substitutions and pipelines while interactive secret input continues to use the controlling terminal.

Before reading the secret, `readpass` MUST:

1. obtain the current terminal state with `stty -g`;
2. retain that representation for exact restoration;
3. arrange cleanup for normal exit and the handled signals;
4. disable terminal echo.

If echo cannot be disabled, the command MUST fail without reading a secret.

The secret is read as one shell line with semantics equivalent to:

```sh
IFS= read -r
```

so leading/trailing IFS whitespace and backslashes are preserved.

The shell-line interface does not represent embedded newline or NUL bytes.

## 5. Restoration and output ordering

After the input attempt, `readpass` MUST restore the exact saved terminal state before writing the captured secret to standard output.

Restoration uses the `stty -g` representation as arguments to a later `stty` invocation. The implementation must preserve the argument semantics required by the POSIX `stty -g` contract without evaluating the saved data as shell source.

If terminal restoration fails, `readpass` MUST fail and MUST NOT emit the secret on standard output.

After successful restoration, the command writes a newline to the controlling terminal and, if input succeeded, writes exactly:

```text
<secret>\n
```

to standard output.

No prompt or terminal-control output is mixed into standard output.

## 6. readpass exit status

```text
0  secret read, terminal restored and result emitted successfully
1  terminal/input/restoration/output failure or handled signal
2  invalid invocation
```

Handled signals are:

```text
HUP
INT
QUIT
TERM
PIPE
ABRT
TSTP
```

They cause cleanup and failure rather than leaving the terminal in the modified state.

`SIGKILL` and other non-catchable termination cannot be covered by a shell cleanup contract.

## 7. readpassv interface

Invocation:

```text
readpassv <prompt> <verify-prompt> [<mismatch-message>]
```

Exactly two or three arguments are valid.

`readpassv` invokes the `m`-owned `readpass` command once with `prompt` and once with `verify-prompt`.

A non-zero `readpass` result is propagated as failure and verification stops.

The two captured values are compared exactly as shell strings.

If they match, `readpassv` writes exactly:

```text
<secret>\n
```

to standard output.

If they do not match:

- standard output remains empty;
- `mismatch-message`, when non-empty, is written directly to `/dev/tty`;
- status `3` is returned;
- no retry is performed automatically.

Temporary shell variables holding the captured values are unset when they are no longer needed.

## 8. readpassv exit status

```text
0  the two values match and the secret was emitted successfully
1  operational failure, including a readpass failure
2  invalid invocation
3  the two values do not match
```

## 9. Security boundary

Both commands deliberately use standard output as the data channel for the secret.

Callers are responsible for connecting that output only to the intended consumer, normally through command substitution or a controlled pipe. The interface does not claim that exported environment variables, logs or terminal output are safe secret-storage channels.

The commands minimize the interval during which terminal echo is disabled and do not emit the secret before successful restoration.

## 10. Permanent testing

Permanent tests SHOULD protect at least:

```text
readpass executable mode and exact #!/bin/sh shebang
readpass bootstrap independence and POSIX-shell syntax
readpassv executable mode and exact #!/usr/bin/env m shebang
mandatory operational-manual presence for both commands
invalid-invocation status behavior
readpass input from /dev/tty with stdin unavailable or unrelated
prompt isolation from stdout
echo suppression while the secret is entered
preservation of leading/trailing whitespace and backslashes
exact stdout serialization including values such as -n
terminal-state restoration after success
terminal-state restoration after a handled signal
readpassv exact match success
readpassv mismatch status 3 with no secret on stdout
optional mismatch message directed to /dev/tty
```

A PTY may be used as test infrastructure for deterministic terminal interaction. Such a test driver is not a runtime dependency of either command.

## 11. Invariants

```text
READPASS-01  readpass is bin/sys/readpass with exact #!/bin/sh
READPASS-02  readpass is intentionally standalone and bootstrap-independent
READPASS-03  readpass reads secret input from /dev/tty and leaves stdin available to the caller
READPASS-04  readpass saves the exact terminal state and disables echo before reading
READPASS-05  readpass fails closed if echo cannot be disabled or terminal restoration fails
READPASS-06  readpass restores the saved terminal state before emitting the secret
READPASS-07  readpass stdout contains only the successful secret record
READPASS-08  readpass preserves shell-line whitespace and backslashes through IFS= read -r semantics
READPASS-09  readpass uses statuses 0 success, 1 operational/signal failure, 2 invalid invocation
READPASS-10  readpassv is bootstrap-integrated through #!/usr/bin/env m
READPASS-11  readpassv resolves the `m`-owned readpass command from the m system command directory
READPASS-12  readpassv emits the secret only when the two captured values match exactly
READPASS-13  readpassv uses status 3 for mismatch and writes an optional mismatch message only to /dev/tty
READPASS-14  both command identities have owner-local operational manual topics
```
