# menu incremental rendering

Status: Active
Updated: 2026-09-19

## Goal

Reduce visible menu flicker by avoiding full-screen redraws when navigation or selection changes can be represented by repainting only affected rows, while preserving current menu semantics and terminal lifecycle.

## Current repository revisions

```text
rumiai-dev   01dfe1630c3136617e6241f3dc34d41c7b358505
rumiai-os    50b760bd3cfe08922068ceb7d973d7edee12251c
rumiai-tests 5b39aeefc6af2198aacd014df31d4c03a4d24b66
reference m  2a57a29880c2d7a32e18782122062c695fcb1a3a (master)
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `RUNNER.md`
- `specifications/README.md`
- `specifications/rumiai-os/MENU.md`
- `specifications/rumiai-os/READ-KEY.md`

## Fixed task-local choices

- The old `massimilianonardi-ai/m` repository is historical/reference evidence only.
- Its `cmd/menu` implementation confirms the desired rendering strategy: simple cursor movement inside an unchanged viewport does not clear/redraw the screen; scrolling redraws the viewport; a multiselect toggle repaints only the affected row.
- The current RumiAI `menu` must preserve its existing `>` selection marker, provider model, multi-selection semantics, alternate-screen lifecycle and public API.
- Full-screen repaint remains valid for initial render and true whole-layout invalidation. Ordinary viewport shifts caused only by navigation should repaint the list viewport without issuing a whole-screen clear; provider reset/reload or geometry/layout changes may require broader repaint according to what actually changed.
- Ordinary movement within the same viewport should repaint only the old and new selection rows.
- A multi-selection toggle in an otherwise unchanged viewport should repaint only the current row.
- Existing queued-input coalescing is retained: multiple already-buffered navigation keys are applied before one final incremental repaint.

## Completed

- Mandatory preflight completed.
- Current `MENU.md`, `menu.lib.sh`, permanent menu tests and terminal primitives inspected.
- Historical/reference `m/cmd/menu` implementation inspected at current master as explicitly requested by the user.
- Root cause identified in the pre-change implementation: every effective movement scheduled a full `term_clear` redraw.
- Concurrent work has since added row-level repaint for unchanged-viewport movement/toggle plus permanent PTY coverage and promoted `MENU-19`/`MENU-20`.
- Current review found one remaining gap relative to the accepted design: a navigation-driven viewport shift still falls back to `_menu_render`, which performs `term_clear` and repaints the whole screen.

## Current state

Current `rumiai-os` already contains partial incremental rendering. In-view movement repaints two rows and multi-select toggle repaints one row. Navigation that changes `_menu_top` still triggers whole-screen clear/repaint. Current permanent tests cover only the in-view movement/toggle case.

## Next action

Complete the accepted renderer by adding viewport-only repaint for navigation-driven viewport shifts, extend PTY coverage to assert no whole-screen clear during such scrolling, then run development and formal validation.

## Blockers / open questions

None.
