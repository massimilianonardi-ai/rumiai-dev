# rsudo injection menu

Status: Active
Updated: 2026-09-27

## Goal

Run the existing `menu` filesystem browser remotely under privileged `rsudo` by streaming the required m-owned shell code and libraries in memory, without requiring a remote RumiAI/m installation.

## Current repository revisions

```text
rumiai-dev   a0f8e388825b58e90169bb42a5804cf21ea018ec
rumiai-os    52068dcfc01409231c673c48291ff18147fc1056
rumiai-tests 3c89e92c2a3455dc3c1e68a383d1a73ed421dc73
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

- Explicit user architecture correction: the root `m` bootstrap is deliberately minimal. Its only approved helper functions are `readpathce` for the root-resolution chicken/egg boundary and `export_readonly` for fundamental variable definition. The bootstrap responsibilities are limited to root resolution, fundamental system-variable definition, loading `core.lib.sh`, and execution. No additional function or responsibility may be added to `m` without explicit user approval.
- `loadlib` and `loadsyslib` belong to `core.lib.sh`, not to the root bootstrap. The bootstrap must load core through the minimal bootstrap path required before those functions exist.
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

A more fundamental architecture regression has been identified and takes precedence over the injection-local diagnosis.

Current `rumiai-os/m` defines `loadlib` and `loadsyslib` itself and also performs package-provider/global-environment work. This violates the explicit bootstrap-minimality correction above. Current `BOOTSTRAP-ENVIRONMENT.md`, `LIBRARY-INTERFACES.md`, and package-model statements encode the same drift, so the problem is not limited to implementation.

Repository history shows the regression path. `loadlib`/`loadsyslib` were originally implemented in `core.lib.sh`. The active injection work initially recorded final loader ownership as an open question. Commit `rumiai-os@7fa382d29f9c725bc098eda301c872e450fea663` then moved the loader from core into `m` while migrating callers to `loadsyslib`. Subsequent documentation commits promoted that implementation convenience into canonical contract instead of requiring explicit architectural approval.

The physical `dash` symptom therefore must not be treated as an isolated stale-shell issue until the bootstrap/core regression is repaired and the normal RumiAI shell path is restored.

## Next action

First realign the canonical bootstrap/library/package contracts with the explicit bootstrap-minimality rule and add mechanical protection for that structural boundary. Then, under explicit product authorization, restore `loadlib`/`loadsyslib` ownership to `core.lib.sh`, remove non-approved bootstrap responsibilities from `m`, and validate the normal RumiAI shell before resuming rsudo/menu injection work.

## Blockers / open questions

Canonical sources and current implementation are presently inconsistent with the explicit user architecture correction. Product repair must not proceed silently; the next product modification requires explicit authorization for the repair work unit.
