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
- Canonical menu contract updated with the filesystem multi-selection Tab fallback and its collision rules.
- `bin/sys/menu` updated so filesystem multi-selection with no explicit action key installs Tab as the fallback action; filesystem single-selection still requires `-K`.
- `res/sys/manual/menu` realigned with the new invocation/default-key behavior.
- Permanent contract coverage extended for Tab collision cases.
- Permanent interactive coverage extended for implicit Tab confirmation and suppression of the fallback when an explicit `-K` exists.

## Current state

Current revisions relied upon after implementation:

```text
rumiai-dev   5fc521e8c96967a9891578e49c3c82e76890900a
rumiai-os    4e6de5ec0ace036262bb6016424e235c7bd9bdc0
rumiai-tests 7f3100edee2fc3b0bef77314f8a9898f97d73314
```

The validation scope still points to the previously validated product revision and must be retargeted only after the revised product passes the development run.

## Next action

Run the menu permanent tests on the exact revised product/test revisions. If they pass, retarget `validation/menu.conf`, run formal task validation, then complete the final consistency gate.

## Blockers / open questions

None.
