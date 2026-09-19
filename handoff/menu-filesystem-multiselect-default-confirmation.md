# menu filesystem multiselect default confirmation

Status: Complete
Updated: 2026-09-19

## Goal

Allow filesystem multi-selection to work without an explicit `-K` by using Tab as a fallback confirmation key, while preserving existing natural Enter/Space/Backspace roles.

## Current repository revisions

```text
rumiai-dev   ec563924f6f79609eb4a9d556e94698189d0d2af  (before this final handoff snapshot)
rumiai-os    4e6de5ec0ace036262bb6016424e235c7bd9bdc0
rumiai-tests 1333c0467c1bd789b8eaadcf9a07044c19fbf64b
```

Formal validation ran with `rumiai-tests` revision `0cb364fadc9b0267dbd997913ce1180ecff07460` and `rumiai-os` revision `4e6de5ec0ace036262bb6016424e235c7bd9bdc0`. The current `rumiai-tests` revision differs from that validated suite revision only by removal of the temporary `.github/workflows/menu-tab-fallback.yml`; permanent tests and `validation/menu.conf` are unchanged.

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

All durable behavior has been promoted to `specifications/rumiai-os/MENU.md`. No unpromoted current-behavior design remains in this handoff.

## Completed

- Mandatory preflight completed against the current remote HEADs before material changes.
- Filesystem single-selection continues to require at least one explicit `-K`.
- Filesystem multi-selection with no explicit `-K` now installs Tab as the fallback confirmation action.
- Any explicit `-K` suppresses the implicit Tab fallback; only the explicit action keys remain active.
- `-S tab` or `-P tab` without an explicit action key is invalid because Tab cannot simultaneously be fallback confirmation and another reserved role.
- Enter remains directory browsing, Space remains the default multi-selection toggle, Backspace remains parent navigation and Escape remains cancellation.
- The fallback was implemented only in `bin/sys/menu`; `menu.lib.sh` and its public API were intentionally unchanged.
- The `menu` operational manual was realigned with the revised synopsis and default-key behavior.
- Permanent contract tests protect the Tab collision cases and the continuing single-selection `-K` requirement.
- Permanent interactive tests protect both implicit Tab confirmation and suppression of Tab when an explicit `-K` exists.
- Development run on exact `rumiai-tests` `7f3100edee2fc3b0bef77314f8a9898f97d73314` against exact `rumiai-os` `4e6de5ec0ace036262bb6016424e235c7bd9bdc0`: 2 PASS, 0 FAIL, 0 SKIP, 0 ERROR.
- `validation/menu.conf` was retargeted to exact product revision `4e6de5ec0ace036262bb6016424e235c7bd9bdc0`.
- Formal `rumiai-validate menu` on Linux/x86_64 with session isolation, `rumiai-tests` `0cb364fadc9b0267dbd997913ce1180ecff07460` and exact product `4e6de5ec0ace036262bb6016424e235c7bd9bdc0`: 2 PASS, 0 FAIL, 0 SKIP, 0 ERROR; validation environment CLEAN; scope result VALIDATED.
- Formal validation evidence was published as `validation/20260919T104057+0000-3649` and `validation/20260919T104057+0000-2348`.
- Temporary GitHub Actions validation infrastructure was removed from the current `rumiai-tests` tree after successful validation.
- Final consistency review confirmed specification/implementation/manual alignment, unchanged library API, absence of command-local `-h/--help`, correct executable/manual/test structure, exact validation target and no remaining temporary workflow.

## Current state

The requested behavior is complete and formally validated.

The earlier failed workflow attempts were infrastructure-only: one checkout origin spelling was not accepted by target discovery, one validation attempt lacked a target checkout, one malformed temporary workflow was corrected before useful execution, and one target checkout was placed inside the suite working tree. None represented a product-behavior failure. The exact development run and final formal validation both passed the permanent menu test scope.

No physical-host validation was performed or required for this work unit.

## Next action

None.

## Blockers / open questions

None.
