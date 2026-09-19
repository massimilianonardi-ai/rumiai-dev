# menu incremental rendering

Status: Complete
Updated: 2026-09-19

## Goal

Eliminate visible menu flicker by minimizing terminal repaint work while preserving the current `menu` contract, provider architecture and terminal abstraction.

## Canonical outcome

Durable behavior is defined by `specifications/rumiai-os/MENU.md`.

The renderer now combines queued-input coalescing with dirty-region rendering:

- unchanged-viewport navigation repaints only old/new selection rows;
- multi-selection toggle repaints only the current row;
- navigation-driven viewport shifts repaint only the list viewport;
- whole-screen clear remains for initial or broader layout invalidation;
- terminal line clearing is delegated to `term.lib.sh` through `term_line_clear`, with a space-padding fallback when that capability is unavailable.

## Completed

- Historical `massimilianonardi-ai/m` menu work reviewed as comparative evidence rather than copied.
- Existing partial incremental implementation reconciled with the accepted design.
- `term_line_clear` added and documented.
- Viewport-only repaint implemented for navigation-driven scrolling.
- Header/footer/bottom-footer geometry invalidation checks retained before incremental repaint.
- Existing queued-input coalescing retained.
- Permanent PTY coverage verifies no full-screen clear for in-viewport movement, multiselect toggle and viewport-shifting navigation.
- Development run on exact `rumiai-os 97abcece0dbb9a4ae15fadf452c198e3c57a6037`: menu PASS 2/2.
- Formal validation on Linux/x86_64 using `rumiai-tests f6590b2f8da99c897fa15d254acdbbe89a7a87fa` and exact disposable `rumiai-os 97abcece0dbb9a4ae15fadf452c198e3c57a6037`: PASS 2, FAIL 0, SKIP 0, ERROR 0; environment CLEAN; scope VALIDATED.
- Final consistency gate completed after validation.
- Temporary development/validation workflows removed after evidence publication.

## Current repository revisions

```text
rumiai-dev   39b699308d9ad7aa3361d1c75375ccf47a982777
rumiai-os    97abcece0dbb9a4ae15fadf452c198e3c57a6037
rumiai-tests 5f5c0a14d313634bc00d52d1d05f32a0c3b1e85d
```

Formal validation suite revision:

```text
rumiai-tests f6590b2f8da99c897fa15d254acdbbe89a7a87fa
```

## Next action

None. Durable task state has been promoted to canonical specification and permanent tests.

## Blockers / open questions

None.
