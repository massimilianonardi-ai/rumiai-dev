# menu single-selection and parent navigation

Status: Complete
Updated: 2026-09-19

## Goal

Realign the current `menu` contract so single selection is the default, multi-selection is enabled explicitly, and filesystem mode reserves a configurable parent-navigation key with Backspace as the default.

## Current repository revisions

```text
rumiai-dev   e62be16b7dc27e970d6af222081863cb74e7781c  (before this final handoff snapshot)
rumiai-os    2955d720e47d2400fcd4334237fc5e159d1467cc
rumiai-tests 13e28ee5a0d2adbc3db004b47d335562bd08eda0
```

Formal validation used `rumiai-tests` revision `f72ea6702e4eb2011774fc60eaffaf6bab550f91`. The current `rumiai-tests` revision differs from that validated revision only by removal of the temporary `.github/workflows/menu-bridge.yml`; the permanent tests and `validation/menu.conf` are unchanged.

A concurrent `rumiai-dev` advance from `56d4d4af7ca0e28a49fcf9b14e1c58f1f4c90d30` to `e62be16b7dc27e970d6af222081863cb74e7781c` was detected during validation. Its changes were limited to package/bootstrap documentation and another task handoff. The menu specification, menu handoff and menu TODOs were re-read at the new HEAD and required no conflict resolution.

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

All durable current menu behavior has been promoted to `specifications/rumiai-os/MENU.md`. No unpromoted current-behavior design remains in this handoff.

The two requested possible future developments remain deliberately non-normative and are represented by:

```text
todo/menu-filesystem-persistent-multiselection.md
todo/menu-filesystem-entry-presentation.md
```

## Completed

- Made single selection the default for list and filesystem modes.
- Added `-M` to explicitly enable multi-selection with Space.
- Defined `-S <key>` as explicit multi-selection enablement with a configured toggle key.
- Added reusable `menu_multiselect_enable` and `menu_multiselect_disable` APIs while keeping `menu_toggle_key_set` responsible only for toggle-key configuration.
- Removed multi-selection mark boxes from single-selection rendering and made the inactive toggle key available as an action key.
- Added filesystem parent navigation on Backspace by default.
- Added `-P <key>` to replace the parent-navigation key.
- Kept parent navigation as filesystem-provider policy rather than making Backspace an engine-global navigation key.
- Reused the same physical resolution and confinement path for Enter-directory and parent-key transitions; parent navigation is ignored at `/` and at a confinement root.
- Kept the visible `..` entry whenever parent navigation is allowed.
- Realigned the `menu` and `menu.lib.sh` operational manuals with the revised command/library interfaces.
- Extended permanent contract and interactive tests for single-select defaults, Space as a single-select action, explicit multi-selection, configurable toggle, Backspace parent navigation, configurable parent key and key-collision failures.
- Corrected a test-side terminfo environment bug found during real execution.
- Moved Backspace behavior validation to a direct PTY driver after establishing that the line-oriented interactive helper can let terminal erase processing consume the Backspace byte.
- Recorded persistent cross-directory multi-selection as deferred design work rather than increasing the current engine complexity without a stable identity/order contract.
- Recorded richer filesystem entry presentation/metadata as deferred design work pending type taxonomy and POSIX portability evaluation.
- Used the documented GitHub Actions outbound-network bridge to transfer exact product/test Git snapshots into the isolated Debian environment with SHA-256 verification.
- Final development run on `rumiai-os` `2955d720e47d2400fcd4334237fc5e159d1467cc` and `rumiai-tests` `f72ea6702e4eb2011774fc60eaffaf6bab550f91`: 2 PASS, 0 FAIL, 0 SKIP, 0 ERROR.
- Formal `rumiai-validate menu` on Linux/x86_64 against the same exact revisions: 2 PASS, 0 FAIL, 0 SKIP, 0 ERROR; validation environment audit CLEAN; task scope result VALIDATED.
- Removed the temporary bridge workflow from the current `rumiai-tests` tree after validation.
- Final consistency review confirmed public API/manual/spec alignment, underscore-prefixed internal library helpers, no command-local `-h/--help`, no superseded default-multiselect wording, correct executable modes and exact validation-scope target.

## Current state

The requested current behavior is complete and validated.

Formal evidence was produced by the real `rumiai-validate` launcher in the isolated Debian auxiliary host. Because that host has no outbound GitHub access, Git transport for validation update/clone/publication was redirected through exact local mirrors transferred by the documented bridge. The validation session and record were therefore published to the local redirected mirror rather than GitHub. No physical-host validation was performed or required for this work unit.

## Next action

None for the active work unit. The two deferred TODOs must be independently evaluated before any future promotion or implementation.

## Blockers / open questions

None.
