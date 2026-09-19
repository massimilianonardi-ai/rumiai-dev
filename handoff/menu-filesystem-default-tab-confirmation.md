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
- Canonical menu contract updated so filesystem mode without explicit `-K` uses Tab in both selection modes.
- `bin/sys/menu` updated by removing the multiselect-only restriction from the existing Tab fallback.
- `res/sys/manual/menu` realigned with the uniform filesystem default.
- Contract coverage updated so `-d <directory>` is no longer expected to be invalid solely for lacking `-K`; parent-key Tab collision remains invalid.
- Interactive coverage now separately verifies single-select Tab fallback, multi-select Tab fallback, and suppression of implicit Tab by explicit `-K`.

## Current state

```text
rumiai-dev   c59b927582591a273e7287246156e314a99fb25c
rumiai-os    34671a5a1e9917fa39e3bbbd4b155590202c9b22
rumiai-tests 75a345002e75d53230ca9283c411e4f15a3943f5
```

The validation scope still targets the preceding product revision and must be retargeted only after the revised development run passes.

## Next action

Run the permanent menu tests on the exact revised product/test revisions; if clean, retarget `validation/menu.conf`, run formal validation, then complete the final consistency gate.

## Blockers / open questions

None.
