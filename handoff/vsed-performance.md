# vsed performance optimization

Status: Active
Updated: 2026-09-21

## Goal

Make `vsed` practically usable during interactive typing by removing per-character latency and visible flicker without weakening its memory-only/security contract or POSIX portability.

## Current repository revisions

```text
rumiai-dev   f83fd30527acfdae96bb085d268c94001154a3e5
rumiai-os    587ccc948c2f9d082c99038f53d61dd36bf3f9d9
rumiai-tests 561923c6374bc2d5e5518c62de25449ccd0199e6
```

Fresh HEAD retrieval remains mandatory before future writes.

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

## Working design

- The current main performance defect is structural: every key invokes a full-screen render; each render calls `term_size_update`, clears the screen, moves to every visible row, clears every row, redraws the status line, and finally repositions the cursor.
- The common printable-typing path should become incremental: keep terminal dimensions cached during the session, avoid full-screen clear/redraw, update only the affected row and cursor, and use a direct fast path when appending printable text at the visible end of the line.
- Structural edits that change line count, viewport or horizontal scroll may still request a full redraw.
- `term_read_byte` also has avoidable per-key external-process cost. POSIX `od -N 1` is available and may allow replacing the current `dd | od | tr` pipeline with one `od` invocation, subject to cross-host validation.
- The canonical `vsed` behavior/security contract should remain unchanged unless a performance optimization exposes a necessary observable contract clarification.

## Completed

- Mandatory preflight completed.
- Current `vsed`, `term.lib.sh`, array implementation and permanent testing contracts inspected.
- Current hot paths identified statically.

## Current state

No performance code has been changed yet.

## Next action

Implement the smallest incremental-rendering and input-cost reductions, add regression/performance-oriented permanent coverage where mechanically meaningful, and validate on Linux and macOS.

## Blockers / open questions

None currently.
