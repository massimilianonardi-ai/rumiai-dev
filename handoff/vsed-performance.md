# vsed performance optimization

Status: Complete
Updated: 2026-09-21

## Goal

Make `vsed` practically usable during interactive typing by removing per-character latency and visible flicker without weakening its memory-only/security contract or POSIX portability.

## Current repository revisions

```text
rumiai-dev   1ea6e83f6d8e92255b23b91486c9df53fb3f09f5  (before final handoff snapshot)
rumiai-os    c681a028dbcbd219186a8973b39489a59df04d24
rumiai-tests a8a722fac83c049a6a98a483e850245ee57406bb
```

Fresh HEAD retrieval remains mandatory before future work.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/VSED.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/READ-KEY.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
```

## Completed

- Replaced per-key full-screen rendering with incremental rendering.
- Printable append at the visible end of the current line writes only the new display character and performs no cursor/clear/geometry `tput` calls.
- Insertions inside a line redraw only the affected line unless horizontal scrolling changes.
- Cursor-only navigation moves only the cursor unless the viewport or horizontal scroll changes.
- Structural edits such as line split/join redraw the viewport without global screen clear.
- Terminal dimensions are no longer re-read for each ordinary keypress; they are refreshed on full redraw.
- The status line was simplified to static controls so it does not require per-key repaint.
- `term_read_byte` removes the per-byte `tr` process and, during an established saved TTY session, avoids the previous repeated availability probe. The retained `dd | od` path is portable on both validated hosts.
- A one-process `od -N 1` input experiment passed Linux but blocked in the Darwin PTY and was therefore rejected rather than promoted.
- Permanent PTY coverage now traces the real external `tput` boundary and asserts that a 20-character printable burst uses exactly two `clear` calls (session entry/cleanup) and one `lines` plus one `cols` geometry query.
- Final formal validation for `rumiai-os@c681a028dbcbd219186a8973b39489a59df04d24` and `rumiai-tests@a8a722fac83c049a6a98a483e850245ee57406bb`:
  - Linux/x86_64: 2 PASS, 0 FAIL/SKIP/ERROR, environment CLEAN, scope VALIDATED.
  - Darwin/arm64: 2 PASS, 0 FAIL/SKIP/ERROR, environment CLEAN, scope VALIDATED.
- The canonical `VSED.md` behavioral/security contract remains unchanged; the optimization is implementation-level.
- `term.lib.sh` operational documentation remains aligned with its actual external dependencies.

## Current state

The performance optimization work unit is complete and revision-specific multi-host validation is stored in `rumiai-tests`.

## Next action

None for this completed work unit. Further performance tuning should begin from current HEADs and be driven by observed remaining latency.

## Blockers / open questions

None.
