# RumiAI OS — `read-key`

Status: **Normative specification**  
Date: 2026-09-09  
Updated: 2026-09-09

## 1. Purpose

`read-key` provides a small standalone terminal-input utility for shell scripts and command-line programs that need to read one keyboard key and obtain either:

- the original printable UTF-8 character; or
- a stable logical name for a non-printable/special key.

It is intentionally independent from the RumiAI bootstrap.

---

## 2. Command and location

Canonical command:

```text
read-key
```

Canonical product pathname:

```text
bin/sys/read-key
```

The file is a regular executable with exact shebang:

```sh
#!/bin/sh
```

This standalone shebang is explicitly authorized by `decisions/rumiai-os/2026-09-09-command-shebang-and-read-key.md`.

The command accepts no options, arguments or operands.

---

## 3. Bootstrap independence

`read-key` MUST NOT require the RumiAI bootstrap for normal execution.

In particular its runtime contract MUST NOT depend on:

```text
m_*
log
lang
m_COMMAND_BIN
RumiAI shell libraries/functions sourced by the bootstrap
bootstrap-derived root/configuration/state
```

If such a dependency becomes necessary in the future, the command shebang/classification MUST be reconsidered before implementation according to `COMMAND-ENTRYPOINTS.md`.

---

## 4. Runtime dependencies

The implementation is POSIX `sh` and uses the standard utilities:

```text
stty
dd
od
tr
```

The command additionally requires an available `tput` implementation with the X/Open Curses / terminfo capability semantics consumed by this specification.

`tput`/terminfo is an explicit capability dependency and MUST NOT be represented as a dependency-free POSIX-core guarantee.

Required capability names used when available:

```text
smkx
rmkx
kbs
kent
kcbt
kcuu1
kcud1
kcub1
kcuf1
khome
kend
kich1
kdch1
kpp
knp
kf1 ... kf20
```

An unavailable optional key capability means that particular logical key sequence is not added to the current keymap. Failure to obtain a usable terminfo entry for the terminal is an operational failure.

---

## 5. Terminal source

Keyboard input MUST be read from the controlling terminal:

```text
/dev/tty
```

rather than from standard input.

This preserves standard input for the calling program and permits forms such as:

```sh
key="$(read-key)"
```

while `read-key` continues to receive the user's keyboard event from the controlling terminal.

Terminal-control output such as `smkx`/`rmkx` MUST also be directed to `/dev/tty`, never to stdout.

---

## 6. stdout and stderr

On successful key recognition, stdout contains exactly:

```text
<result>\n
```

No diagnostic, terminfo control sequence or presentation message may be mixed into stdout.

`read-key` emits no application-level diagnostic messages. For managed failures described by this specification, stdout and stderr remain empty and the failure is communicated only through the exit status. Expected diagnostics from internal utilities used to implement the operation are suppressed.

This silence is intentional: `read-key` is a low-level standalone input primitive. The consumer that requested the key owns user-facing diagnostics and, when it runs inside the RumiAI bootstrap runtime, may use the established `fatal`/`log` facilities without making `read-key` depend on them.

`printf` with constant formats is used for successful data output; `echo` is not used as a serializer.

---

## 7. Terminal state

Before reading input the command MUST:

1. obtain and save the current terminal state with `stty -g`;
2. disable echo;
3. disable canonical input processing;
4. start with blocking one-byte input semantics (`MIN=1`, `TIME=0`).

The command intentionally does **not** select a complete raw mode. Normal terminal signal handling remains enabled unless a future explicit contract changes it.

When supported by the active terminfo entry, the command enables keypad/application transmission with `smkx` and records that activation for cleanup.

On exit it MUST attempt to:

1. send `rmkx` if `smkx` was successfully enabled;
2. restore the exact terminal state saved by `stty -g`.

Cleanup applies to normal exit and the explicitly handled signals in section 14.

---

## 8. Logical key mapping

The initial stable output vocabulary is:

```text
NUL                         nul
Backspace                   backspace
Tab                         tab
Enter                       enter
Escape                      escape
Back Tab                    backtab
Up                          up
Down                        down
Left                        left
Right                       right
Home                        home
End                         end
Insert                      insert
Delete                      delete
Page Up                     pageup
Page Down                   pagedown
F1 ... F20                  f1 ... f20
```

Printable ASCII and valid printable UTF-8 characters are returned unchanged.

The ASCII space character therefore produces a literal space, not the token `space`.

Generic control-byte fallbacks are initially:

```text
08    backspace
09    tab
0a    enter
0d    enter
1b    escape
7f    backspace
```

A terminal-specific terminfo definition inserted earlier in the keymap takes precedence over a generic fallback with the same exact byte sequence.

---

## 9. Terminal-specific sequences

Special-key escape sequences MUST NOT be hardcoded as xterm, VT or host-specific tables.

The active mapping is derived at runtime from the current terminfo entry through `tput` capability lookup.

The parser therefore normalizes terminal-specific byte sequences into the logical names defined in section 8 without claiming that any one escape sequence is universal.

---

## 10. Prefix parser

Key-sequence recognition is prefix based.

After a byte sequence that is a prefix of one or more longer known key sequences, subsequent bytes are read using non-canonical timeout semantics:

```text
MIN=0
TIME=1
```

where `TIME=1` is one decisecond.

The command MUST continue reading only while the accumulated byte string is a prefix of at least one known longer sequence.

It MUST NOT unconditionally consume a fixed maximum number of bytes after `Escape`.

If the timeout occurs and the accumulated sequence is itself an exact known key, that exact key is returned. Otherwise an incomplete sequence is an error.

If the accumulated bytes are neither an exact known key nor a prefix of a longer known key, the sequence is unknown and is an error.

Because portable POSIX shell provides no input-unread facility for the TTY, bytes already consumed while resolving an ambiguous escape sequence cannot be pushed back. This limitation is explicit.

---

## 11. UTF-8

A non-ASCII byte that is not part of a recognized terminal key sequence is interpreted as the beginning of a UTF-8 character.

The implementation MUST accept valid UTF-8 sequences of two, three or four bytes and preserve their bytes unchanged in the result.

It MUST reject at least:

```text
invalid leading byte
invalid continuation byte
incomplete sequence
overlong encoding
UTF-16 surrogate range
code points greater than U+10FFFF
```

The shell variable domain cannot represent a NUL byte. A blocking first-byte read that resolves to shell-empty data is therefore represented by the logical token:

```text
nul
```

---

## 12. Command substitution semantics

The command intentionally emits one trailing newline on successful stdout.

POSIX command substitution removes trailing newline characters, therefore the normal script usage:

```sh
key="$(read-key)"
```

produces the logical value/character without the record-terminating newline.

A newline key itself is not returned as a literal newline; it is normalized to `enter`, avoiding ambiguity with the output record delimiter.

---

## 13. Exit status

```text
0  one key was read and represented successfully
1  operational failure: TTY/state/capability/required utility unavailable or failed
2  invalid invocation, invalid/unsupported input, unknown or incomplete key sequence
```

Supplying any argument or operand is invalid invocation and returns `2` without waiting for terminal input.

Managed failures produce no command output; consumers use the exit status to detect failure and decide whether and how to report it.

---

## 14. Signals

The initial signal-exit contract is:

```text
HUP   129
INT   130
QUIT  131
PIPE  141
TERM  143
TSTP  148
```

The exit path invokes terminal cleanup.

`TSTP` intentionally causes cleanup and process termination with status `148` rather than suspension while the terminal may be in modified non-canonical mode.

---

## 15. Requirements

```text
READ-KEY-01  canonical executable is bin/sys/read-key with #!/bin/sh
READ-KEY-02  command accepts zero arguments only
READ-KEY-03  no RumiAI bootstrap dependency is part of the runtime contract
READ-KEY-04  keyboard input and terminal control use /dev/tty
READ-KEY-05  stdout contains only the success result; managed failures emit no stdout/stderr diagnostics and use exit status only
READ-KEY-06  terminal state is saved and restored
READ-KEY-07  special-key sequences are sourced from terminfo/tput rather than hardcoded terminal tables
READ-KEY-08  prefix parsing uses bounded inter-byte timeout and no fixed-length over-read
READ-KEY-09  printable ASCII/UTF-8 is preserved; special keys use the logical vocabulary
READ-KEY-10  UTF-8 validity excludes overlong, surrogate and >U+10FFFF sequences
READ-KEY-11  NUL is represented as nul
READ-KEY-12  tput/X/Open Curses/terminfo is an explicit external capability
READ-KEY-13  exit status is 0 success, 1 operational failure, 2 invocation/input/sequence failure
```

---

## 16. Permanent testing

Permanent tests SHOULD protect at least:

```text
file existence, executable mode and exact #!/bin/sh shebang
absence of bootstrap facility dependencies
absence of application-level stderr diagnostics in the implementation
POSIX shell syntax
invalid non-zero-argument invocation and silent failure output
ASCII and space output
valid UTF-8 2/3/4-byte output
Escape, Enter and Tab mapping
actual terminfo-derived arrow-key mapping
optional terminfo key mapping where capabilities exist
terminal state restoration
no smkx/rmkx leakage into stdout
missing tput status and silent failure output
invalid UTF-8 status and silent failure output
unknown escape sequence status and silent failure output
```

A PTY may be used by the test implementation to supply deterministic terminal input. A test-only PTY helper runtime is not a runtime dependency of `read-key`.

Physical validation evidence applies only to the exact committed revisions exercised according to `TESTING.md`.
