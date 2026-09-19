# menu filesystem default Tab confirmation

Status: Complete
Updated: 2026-09-19

## Goal

Make Tab the default filesystem confirmation action whenever no explicit `-K` is supplied, for both single-selection and multi-selection.

## Current repository revisions

```text
rumiai-dev   13d12fb358855aa83ea85e2fbefa17deef0d20c7  (before this final handoff snapshot)
rumiai-os    34671a5a1e9917fa39e3bbbd4b155590202c9b22
rumiai-tests 88b4e48f170da883889c2f418a34e8ad24066e9d
```

Formal validation ran with `rumiai-tests` revision `ecf402e03deac7e12248e4966d86f9b3929feefe` and `rumiai-os` revision `34671a5a1e9917fa39e3bbbd4b155590202c9b22`. The current `rumiai-tests` revision differs from that validated suite revision only by removal of the temporary `.github/workflows/menu-default-tab.yml`; permanent tests and `validation/menu.conf` are unchanged.

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

All durable behavior has been promoted to `specifications/rumiai-os/MENU.md`. No unpromoted design remains in this handoff.

## Completed

- Mandatory preflight completed against current remote HEADs before material changes.
- Canonical menu contract updated so filesystem mode without explicit `-K` uses Tab as fallback confirmation in both single-selection and multi-selection.
- Any explicit `-K` suppresses the implicit Tab fallback.
- `-S tab` or `-P tab` without an explicit action key remains invalid because Tab cannot simultaneously be fallback confirmation and another reserved role.
- Enter remains filesystem browsing, Backspace remains parent navigation, Escape remains cancellation, and Space remains the default mark toggle only when multi-selection is enabled.
- `bin/sys/menu` was simplified by removing the prior multiselect-only requirement from the existing Tab fallback.
- `menu.lib.sh` and its public API were intentionally unchanged.
- `res/sys/manual/menu` was realigned with the uniform filesystem default.
- Permanent contract coverage no longer treats filesystem single-selection without `-K` as invalid and continues to protect Tab role collisions.
- Permanent interactive coverage now verifies single-selection Tab fallback, multi-selection Tab fallback, and suppression of implicit Tab when an explicit `-K` exists.
- Development run on exact `rumiai-tests` `75a345002e75d53230ca9283c411e4f15a3943f5` against exact `rumiai-os` `34671a5a1e9917fa39e3bbbd4b155590202c9b22`: 2 PASS, 0 FAIL, 0 SKIP, 0 ERROR.
- `validation/menu.conf` retargeted to exact product revision `34671a5a1e9917fa39e3bbbd4b155590202c9b22`.
- Formal `rumiai-validate menu` on Linux/x86_64 with session isolation, `rumiai-tests` `ecf402e03deac7e12248e4966d86f9b3929feefe` and exact product `34671a5a1e9917fa39e3bbbd4b155590202c9b22`: 2 PASS, 0 FAIL, 0 SKIP, 0 ERROR; validation environment CLEAN; scope result VALIDATED.
- Formal validation evidence published as `validation/20260919T122949+0000-3492` and `validation/20260919T122948+0000-2190`.
- Temporary GitHub Actions workflow removed after successful validation.
- Final consistency review confirmed specification/implementation/manual alignment, unchanged library API, correct filesystem key-role exclusivity, no stale single-selection `-K` requirement, exact validation target, and no remaining temporary workflow.

## Current state

The requested behavior is complete and formally validated.

No physical-host validation was performed or required for this work unit.

## Next action

None.

## Blockers / open questions

None.
