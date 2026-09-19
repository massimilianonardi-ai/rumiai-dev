# menu single-selection and parent navigation

Status: Active
Updated: 2026-09-19

## Goal

Realign the current `menu` contract so single selection is the default, multi-selection is enabled explicitly, and filesystem mode reserves a configurable parent-navigation key with Backspace as the default.

## Current repository revisions

```text
rumiai-dev   f0fb216d631d11ea7545ca61072d0f31d73afad4
rumiai-os    1f4a4a8b62ed41042e4178b11f74f54ad291aadb
rumiai-tests 9960eafb4d803211620f2975ffaef703c3fb8625
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`
- `todo/README.md`
- `specifications/README.md`
- `specifications/rumiai-os/MENU.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

- Single-selection mode is the default for both list and filesystem modes.
- `-M` explicitly enables multi-selection with Space as the default toggle.
- `-S <key>` explicitly enables multi-selection and selects its toggle key; `-M -S <key>` is also valid.
- When multi-selection is disabled, the toggle key is not reserved and the renderer does not show selection boxes.
- `menu.lib.sh` exposes explicit enable/disable functions for reusable multi-selection state; configuring the toggle key is independent from whether multi-selection is enabled.
- Filesystem mode reserves Backspace as parent navigation by default.
- `-P <key>` changes the filesystem parent-navigation key.
- Parent navigation is semantically equivalent to entering the current directory's `..`: it respects physical resolution and confinement, and is ignored when no parent navigation is allowed.
- The parent-navigation key is filesystem-specific and must not collide with an action key, navigation key, Enter/Escape or an enabled multi-selection toggle.
- The visible `..` entry remains present when parent navigation is allowed.
- Persistent cross-directory multi-selection and richer filesystem entry annotations/metadata are intentionally deferred and will be recorded as separate TODOs rather than promoted into the current specification.

## Completed

- Mandatory preflight completed.
- Current menu specification, implementation, manuals, tests and validation scope inspected.
- Complexity review completed for the requested current and deferred features.

## Current state

No product/specification/test implementation changes for this work unit have been written yet.

## Next action

Update the canonical menu contract, implementation/manuals, permanent tests and validation scope; create the two qualified deferred-work TODOs; then run the proportional validation and final consistency gate.

## Blockers / open questions

None.
