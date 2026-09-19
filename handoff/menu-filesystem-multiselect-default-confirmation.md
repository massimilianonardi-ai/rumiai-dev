# menu filesystem multiselect default confirmation

Status: Active
Updated: 2026-09-19

## Goal

Allow filesystem multi-selection to work without an explicit `-K` by using Tab as a fallback confirmation key, while preserving existing natural Enter/Space/Backspace roles.

## Current repository revisions

```text
rumiai-dev   aa3ef30161abb9295690db078b29bbe595aba6db
rumiai-os    a21a4cdf31453d896e5af24eb2081061d180ff34
rumiai-tests 5270842426c2316887076a4d77d7d0860654f1d4
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`
- `specifications/README.md`
- `specifications/rumiai-os/MENU.md`
- `specifications/rumiai-os/READ-KEY.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

- Filesystem single-selection continues to require at least one explicit `-K`.
- Filesystem multi-selection with no explicit `-K` gets one implicit fallback action key: Tab.
- If any explicit `-K` is present in filesystem multi-selection, no implicit Tab action is added.
- If Tab is already unavailable because it is configured as the multi-selection toggle (for example `-S tab`) or another reserved role, filesystem multi-selection without explicit `-K` is invalid and requires an explicit action key.
- Enter remains directory browsing, Space remains the default multi-selection toggle, Backspace remains parent navigation, and Escape remains cancellation.
- This behavior belongs to the filesystem command policy in `bin/sys/menu`; no `menu.lib.sh` API change is required.

## Completed

- Mandatory preflight completed.
- Current menu specification, implementation, manual, permanent tests and validation scope inspected.
- Current key vocabulary and Tab mapping confirmed through `READ-KEY.md`.

## Current state

No product/specification/test changes for this work unit have been written yet.

## Next action

Update the canonical menu contract and operational manual, implement the command fallback, extend permanent tests, retarget the validation scope to the revised product commit, run proportional validation, and complete the final consistency gate.

## Blockers / open questions

None.
