# rsudo injection menu

Status: Active
Updated: 2026-09-27

## Goal

Run the existing `menu` filesystem browser remotely under privileged `rsudo` by streaming the required m-owned shell code and libraries in memory, without requiring a remote RumiAI/m installation.

## Current repository revisions

```text
rumiai-dev   e18c78e2b385f197ac674367e883cfcfc2ab4c52
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
- Physical composed execution reached the injected privileged `menu -d /` successfully using a pipeline whose first record is consumed by `--askpass` and whose remaining records are the generated source stream.
- The post-menu source dump has been traced to `rsudo_core`'s final info log: after source injection rewrites the operation to `sh -c '<generated source>'`, the final `log info rsudo end ... command "$*"` serializes that internal rewritten command to stderr.

## Current state

The composed remote menu path is operational. The remaining immediate defect is output hygiene: injected source is exposed by rsudo's final informational command log after the interactive target exits. This is not terminal echo and is independent of menu rendering.

## Next action

Realign rsudo logging so the final log does not serialize the internal source-injection `sh -c` payload. Preserve useful start/end operation logging without emitting generated source. Then add proportional regression coverage and rerun the composed physical menu path.

## Blockers / open questions

None.
