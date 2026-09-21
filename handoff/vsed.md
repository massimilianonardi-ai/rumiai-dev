# vsed visual stream editor

Status: Active
Updated: 2026-09-21

## Goal

Add a minimal terminal visual stream editor `vsed` for sensitive text. With no operand it loads stdin into an in-memory editing buffer and writes the saved result to stdout; with one file operand it loads that file and saves directly back to the same file.

## Current repository revisions

```text
rumiai-dev   49af8ce13df8c5b7e9019766318095c5e0b56e2c
rumiai-os    4a673b91dace2c4f131773bf0d41970e92ad2aba
rumiai-tests b911b41a124a4e176352102e7a6710a1fccc7b7e
```

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/README.md
specifications/rumiai-os/CURRENT-MODEL.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/READ-KEY.md
specifications/rumiai-os/MENU.md
```

## Fixed task-local choices

- `vsed` is a bootstrap-integrated technical `m` command and uses `#!/usr/bin/env m`.
- The first implementation uses `term.lib.sh` for TTY/terminfo/key handling and `array.lib.sh` for in-process line storage; `menu.lib.sh` is not used because selection-provider semantics do not match editable-buffer ownership.
- The security objective is no plaintext temporary/swap/backup/undo/journal file created by `vsed`. File mode writes only the explicitly selected destination at save; stdin mode writes only stdout at save.
- This command-level guarantee does not claim control over operating-system paging/hibernation/core-dump policy, process inspection, terminal-emulator capture/history, or opaque implementation internals below the POSIX shell/runtime.
- `vsed` disables shell xtrace/verbose tracing before loading sensitive content and keeps document state in non-exported shell variables.
- The initial editor is text-oriented and deliberately minimal.

## Working design

- Initial editing keys: printable text insertion, Tab, Enter, Backspace/Delete, arrows, Home/End, PageUp/PageDown; Ctrl-X saves and exits; Escape cancels without output/write.
- The document is represented as an array of logical lines. The current line is split into left/right shell strings so character insertion/deletion/navigation can use POSIX parameter expansion without temporary files.
- UI is rendered on `/dev/tty` in the alternate screen. Stdout remains reserved for the saved document in stdin mode.
- File save is deliberately direct/non-atomic so the security contract does not require a plaintext staging file.

## Completed

- Mandatory preflight completed against the revisions above.
- Existing terminal/menu/array facilities and permanent PTY-test patterns were inspected.

## Current state

No `vsed` implementation, specification, manual or permanent test has been added yet.

## Next action

Promote the settled first-delivery contract, implement `bin/sys/vsed` plus `res/sys/manual/vsed`, add proportional PTY/security-oriented permanent coverage, and execute available development validation.

## Blockers / open questions

- Exact byte-for-byte behavior for NUL-containing/binary input is outside the first text-editor contract because POSIX shell variables cannot represent NUL.
- The command can avoid creating plaintext files itself but cannot provide OS-level locked-memory/zeroization guarantees in portable POSIX shell.
