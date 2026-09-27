# rsudo injection menu

Status: Active
Updated: 2026-09-27

## Goal

Run the existing `menu` filesystem browser remotely under privileged `rsudo` by streaming the required m-owned shell code and libraries in memory, without requiring a remote RumiAI/m installation.

## Current repository revisions

```text
rumiai-dev   3e6296e231e9e83e1cf895fe1b8b6d294cf32ae3
rumiai-os    c1aa711645b39f36850d35abc02c31d8db916120
rumiai-tests a005991b9694eac988ce116e38b6e1a02c47feee
```

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/RSUDO.md
specifications/rumiai-os/MENU.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
```

## Fixed task-local choices

- Use the existing explicit `loadlib_inject_stream` generator; dependency discovery is not added.
- The menu stream explicitly embeds `core`, `array`, `map`, `term`, and `menu`.
- Transport the generated source through the current `rsudo --interactive` source-injection path.
- The immediate physical target is a Linux host with sshd already present; the first end-to-end check is the privileged remote filesystem browser.

## Completed

- RumiAI-owned system-shell-library consumers have been migrated to `loadsyslib`; permanent coverage scans for remaining direct m-owned system-library dot-sourcing.
- `loadlib-inject.lib.sh` provides the in-memory load backend.
- `loadlib-inject-stream.lib.sh` generates an explicit embedded-library stream and is covered by permanent tests.
- `rsudo --interactive` consumes non-TTY stdin as source injection and is covered by permanent source-only and source-plus-command tests.
- Current `menu` dependency chain needed for injection has been verified from implementation: `menu -> array, map, term`, with `core` supplied explicitly by the stream generator contract.

## Current state

The implementation pieces required for the first real rsudo+menu composition are present. No permanent end-to-end test yet demonstrates the composed remote filesystem browser itself.

## Next action

Run the composed stream on the physical Linux host against a real SSH/sudo target, starting with `menu -d /`. Capture the complete terminal result and final status. If the real composed path succeeds, add proportional permanent composed coverage; if it fails, fix the first real boundary exposed by that run before broadening the task.

## Blockers / open questions

None before the first physical composed execution.
