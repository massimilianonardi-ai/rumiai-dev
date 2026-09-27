# rsudo injection menu

Status: Active
Updated: 2026-09-27

## Goal

Run the existing `menu` filesystem browser remotely under privileged `rsudo` by streaming the required m-owned shell code and libraries in memory, without requiring a remote RumiAI/m installation.

## Current repository revisions

```text
rumiai-dev   ac9b9229ab30be6749c564f452f14f9eb12bf24a
rumiai-os    52068dcfc01409231c673c48291ff18147fc1056
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
- The generated stream owns its in-memory `loadlib` implementation directly. There is no separate `loadlib-inject.lib.sh` backend or `_loadlib_inject_dispatch` layer.
- The menu stream explicitly embeds `core`, `array`, `map`, `term`, and `menu`.
- Transport the generated source through the current `rsudo --interactive` source-injection path.
- The immediate physical target is a Linux host with sshd already present; the end-to-end target remains the privileged remote filesystem browser.

## Completed

- RumiAI-owned system-shell-library consumers have been migrated to `loadsyslib`; permanent coverage scans for remaining direct m-owned system-library dot-sourcing.
- `loadlib-inject-stream.lib.sh` generates an explicit embedded-library stream and is covered by the existing permanent behavioral loader test.
- The former `loadlib-inject.lib.sh` backend and its operational manual were removed as redundant. The stream generator now emits `loadlib()` directly, with its `case` dispatching to the generated embedded-library wrappers.
- `LIBRARY-INTERFACES.md` and the `loadlib-inject-stream.lib.sh` operational manual were realigned to the direct generated-`loadlib` model.
- A local POSIX-sh harness validated the modified generator: library syntax, generated-stream syntax, direct embedded loading, argument preservation, execution with an unavailable remote `m_LIB_DIR`, and status 2 for an omitted library all passed.
- The existing permanent `library-loading.test` requires no implementation-specific change because it already protects the observable injection contract rather than the removed backend structure. It was inspected but could not be executed in the assistant environment because the GitHub checkout is unavailable there and outbound GitHub network resolution is blocked.
- `rsudo --interactive` consumes non-TTY stdin as source injection and is covered by permanent source-only and source-plus-command tests.
- Current `menu` dependency chain needed for injection has been verified from implementation: `menu -> array, map, term`, with `core` supplied explicitly by the stream generator contract.
- Physical composed execution reached the injected privileged `menu -d /` successfully before the loader simplification, using a pipeline whose first record is consumed by `--askpass` and whose remaining records are the generated source stream.
- The source dump observed after leaving the menu was caused by the final rsudo command log. Current rsudo keeps a concise info-level end log and emits the full effective command only at trace level.

## Current state

The injection model is simplified and current implementation/spec/manual agree: one generator emits `loadsyslib`, embedded library wrappers, and the direct in-memory `loadlib` dispatcher. No separate injection-backend library remains.

The composed remote menu path was physically successful before this loader-internal simplification. The first post-simplification physical rerun produced an interactive `dash` prompt instead of the menu. Current code inspection and a direct POSIX-sh generator probe show the new generator emits a valid non-empty stream. The failure shape matches a stale already-sourced pre-simplification `loadlib_inject_stream` function: that old in-memory function still requires the now-removed `loadlib-inject.lib.sh`, returns status 2 before emitting source, and leaves `rsudo --askpass` with only the password record; rsudo then falls back to its empty-source `sh -s` behavior.

## Next action

Reload the current `loadlib-inject-stream` library in the active m shell (or start a fresh m shell), verify that standalone stream generation returns status 0 and emits non-zero bytes, then rerun the physical composed `menu -d /` path against current `rumiai-os`. If that succeeds, run the permanent loader test and add proportional permanent coverage for the composed rsudo+injected-menu path.

## Blockers / open questions

The physical rerun is waiting for confirmation after reloading the current library definition in the active shell. The assistant execution environment cannot currently reach GitHub to materialize the real checkout for the permanent suite.
