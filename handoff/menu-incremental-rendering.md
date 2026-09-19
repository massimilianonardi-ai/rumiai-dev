# menu incremental rendering

Status: Active
Updated: 2026-09-19

## Goal

Reduce visible menu flicker by avoiding full-screen redraws when navigation or selection changes can be represented by repainting only affected rows, while preserving current menu semantics and terminal lifecycle.

## Current repository revisions

```text
rumiai-dev   f0bd91e0a9810dcf2fdbd42722e954590c805335
rumiai-os    a8e45d327b218f19cee82c3813bfc75fb5ea64b6
rumiai-tests 5065eab424302002693783d2bfd15ec77f04f8be
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
- Full repaint remains valid for initial render, viewport shifts, provider reset/reload, geometry changes or other changes that invalidate broader layout.
- Ordinary movement within the same viewport should repaint only the old and new selection rows.
- A multi-selection toggle in an otherwise unchanged viewport should repaint only the current row.

## Completed

- Mandatory preflight completed.
- Current `MENU.md`, `menu.lib.sh`, permanent menu tests and terminal primitives inspected.
- Historical/reference `m/cmd/menu` implementation inspected at current master as explicitly requested by the user.
- Root cause identified: current `menu.lib.sh` schedules a full `term_clear` redraw after every effective movement.

## Current state

No menu product/test modification for this workstream has been written yet.

## Next action

Promote the incremental-rendering behavior to `MENU.md`, implement row-level repaint in `menu.lib.sh`, extend permanent PTY coverage to assert that simple in-viewport movement/toggle emits no full-screen clear, then run development and formal validation.

## Blockers / open questions

None.
