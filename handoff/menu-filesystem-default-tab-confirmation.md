# menu filesystem default Tab confirmation

Status: Active
Updated: 2026-09-19

## Goal

Make Tab the default filesystem confirmation action whenever no explicit `-K` is supplied, for both single-selection and multi-selection.

## Current repository revisions

```text
rumiai-dev   2350e9e8a653b16f25ce307a60f035d6dd32dc00
rumiai-os    4e6de5ec0ace036262bb6016424e235c7bd9bdc0
rumiai-tests 1333c0467c1bd789b8eaadcf9a07044c19fbf64b
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
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

- In filesystem mode, no explicit `-K` means Tab is the fallback confirmation action regardless of selection mode.
- Any explicit `-K` suppresses the implicit Tab fallback.
- Enter remains directory browsing, Backspace remains parent navigation, Escape remains cancellation, and Space remains the default multiselect toggle only when multiselect is enabled.
- If Tab is already configured as an enabled multiselect toggle or filesystem parent key, an explicit `-K` is required.
- No `menu.lib.sh` API change is required.

## Completed

- Mandatory preflight completed.
- Current canonical menu contract, key vocabulary, command implementation, manual, permanent tests and validation scope inspected.

## Current state

No specification/product/test modification for this work unit has been written yet.

## Next action

Update the canonical menu contract, command implementation, manual and permanent tests; run development tests; retarget and run formal validation; complete the consistency gate.

## Blockers / open questions

None.
