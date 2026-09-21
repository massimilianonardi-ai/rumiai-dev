# RumiAI OS — Visual stream editor

Status: **Current / normative**  
Updated: 2026-09-21

This specification defines the initial `vsed` terminal text editor provided by the technical `m` layer.

## 1. Ownership and entrypoint

The public command is:

```text
vsed
```

It belongs to `m` and is located at:

```text
bin/sys/vsed
```

The command depends on the `m` runtime and RumiAI-owned shell libraries and therefore uses:

```sh
#!/usr/bin/env m
```

The first implementation uses `term.lib.sh` for terminal/TTY/terminfo mechanics and `array.lib.sh` for in-process line storage. `menu.lib.sh` does not own editable-buffer semantics and is not part of the initial implementation.

## 2. Invocation and I/O modes

The supported forms are:

```text
vsed
vsed <file>
```

No options are defined by the first delivery.

With no operand, `vsed` reads the complete initial document from standard input before entering the interactive editor. The interactive user interface uses the selected TTY rather than standard input/output. Saving writes the complete edited document to standard output and then exits successfully.

With one file operand, `vsed` loads that existing readable/writable regular file, edits it in memory, and on save writes the complete edited document directly back to the same pathname. Successful file-mode save does not write document content to standard output.

More than one operand is invalid invocation.

## 3. Initial text domain

The first delivery is intentionally narrow and accepts only NUL-free text composed of:

```text
printable 7-bit ASCII bytes 0x20..0x7e
TAB                       0x09
LF line separators        0x0a
```

Other input is outside the first-delivery text contract. NUL-free input is a caller precondition rather than a reliably detectable runtime condition: portable POSIX shell variables cannot represent NUL, and supported shells can discard NUL bytes while reading into variables. `vsed` therefore MUST NOT claim deterministic NUL rejection in this shell implementation. Detectable non-TAB/non-LF control bytes and non-ASCII input are rejected.

This restriction is deliberate. Byte-wise POSIX-shell parameter operations are not a sufficient UTF-8 cursor/edit primitive across the supported shell implementations. UTF-8 editing must not be claimed until a current primitive preserves complete scalar-value boundaries portably.

TAB is preserved in the document and displayed using a safe one-column placeholder in the initial UI.

## 4. Editing model

The initial editor supports:

```text
printable ASCII insertion
TAB insertion
Enter
Backspace
Delete
Left / Right
Up / Down
Home / End
PageUp / PageDown
```

The initial cursor begins at the start of the first logical line.

The save-and-exit action is:

```text
Ctrl-X
```

Escape cancels the editing session and exits without writing stdout in stream mode and without modifying the target file in file mode.

Unsupported keys are ignored.

The UI is visual and terminal-oriented. It uses an alternate screen when the terminal provides that capability, keeps UI output on the TTY, and reserves standard output for stream-mode saved content.

## 5. Memory-only editing guarantee

For document content, the command-level security guarantee is:

```text
vsed does not create plaintext temporary files
vsed does not create swap files
vsed does not create backup files
vsed does not create undo/journal files
vsed does not invoke an external editor
vsed keeps the editable document in non-exported process-local shell state
vsed disables shell xtrace/verbose tracing before document content is loaded
file mode writes plaintext only to the explicitly selected file when saving
stream mode writes plaintext only to stdout when saving
cancel writes neither destination
```

The first implementation writes file-mode saves directly to the selected file rather than through a plaintext staging file. This deliberately favors the memory-only security property over atomic replacement: a runtime failure during the direct save can therefore leave a partially written target.

The command clears its alternate screen and unsets document variables during normal/trapped cleanup where the shell permits, but portable POSIX shell cannot provide cryptographic memory zeroization.

## 6. Security boundary

The memory-only guarantee is a command-side storage/handling guarantee. It does not claim control over facilities outside the command's portable authority, including:

```text
operating-system virtual-memory paging or swap
hibernation
core-dump policy imposed outside the process
ptrace/debugger/process-memory inspection
terminal-emulator scrollback, capture, recording or accessibility history
kernel/device buffers
opaque implementation details of the host shell/runtime
physical memory remanence
```

The terminal presentation layer must never emit input control bytes directly as terminal commands. The initial restricted text domain and TAB placeholder prevent document content from becoming terminal escape/control sequences.

Sensitive document state must not be exported through environment variables.

## 7. Terminal lifecycle

The editor uses the current terminal abstraction rather than reimplementing `stty`, terminfo or key decoding.

It must:

```text
save the prior TTY state before interactive editing
restore that exact state on normal exit and handled signals
use /dev/tty through term.lib.sh for UI/input
keep stdout free of UI text
clear/leave the alternate screen during cleanup
```

Signal-derived exits restore terminal state where execution is still possible. SIGKILL and equivalent uncatchable termination remain outside the cleanup guarantee.

## 8. Save fidelity

Within the supported initial text domain, an unchanged save preserves document bytes exactly, including:

```text
empty input
empty lines
TAB bytes
presence or absence of the final LF
```

Editing operations change only the corresponding logical text.

## 9. Exit status

```text
0  saved successfully
1  user cancellation
2  invalid invocation, unsupported input, terminal/runtime failure or save failure
```

Diagnostics must not include document content.

## 10. Initial non-goals

The first delivery does not provide:

```text
UTF-8 editing
binary/NUL editing
search/replace
syntax highlighting
undo/redo
clipboard integration
mouse support
configuration files
external editor delegation
atomic file replacement
persistent recovery
```

These are future capabilities only when a concrete requirement justifies them.

## 11. Invariants

```text
VSED-01  vsed belongs to m and is exposed as bin/sys/vsed
VSED-02  vsed is a bootstrap-integrated POSIX-sh command
VSED-03  zero operands means stdin -> in-memory edit -> stdout on save
VSED-04  one file operand means file -> in-memory edit -> same file on save
VSED-05  UI traffic uses the TTY and never contaminates stream-mode stdout
VSED-06  cancel produces no saved output and does not modify file mode
VSED-07  initial text domain is caller-guaranteed NUL-free printable 7-bit ASCII plus TAB/LF; deterministic NUL rejection is not claimed
VSED-08  vsed creates no plaintext temporary/swap/backup/undo/journal file
VSED-09  document state is non-exported and xtrace/verbose tracing is disabled before load
VSED-10  file save is direct/non-atomic in order to avoid a plaintext staging file
VSED-11  terminal mechanics are delegated to term.lib.sh
VSED-12  unchanged save is byte-faithful within the supported text domain
VSED-13  Ctrl-X saves/exits and Escape cancels
VSED-14  exit statuses are 0 save, 1 cancel, 2 invalid/runtime/save failure
```
