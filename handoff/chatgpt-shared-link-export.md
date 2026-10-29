# ChatGPT shared-link export — PoC 068

Status: Complete
Updated: 2026-10-29

## Goal

Produce a useful private, script-free offline rendering of an observed
ChatGPT shared conversation, preserving the rendered content, original
styles and independently verified external source links, without claiming
unproven complete RAW conversation coverage.

## Current repository revisions

- `rumiai-dev-PoCs`: `5da8a3f3b444c765950e09de68560f27426b1f7d` — final experimental README and unchanged PoC implementation.
- `rumiai-dev`: `c334ea50426ca424408e3d613f745f024a9dec96` before this final handoff snapshot.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`.
- `specifications/README.md`, `specifications/rumiai-os/WEB-CONTROL.md`.
- Experiment source, tests, limitations and reproducible instructions in
  `rumiai-dev-PoCs/pocs/068-chatgpt-shared-link-export/README.md`.

## Completed outcome and accepted limitations

- Operator accepted the offline original-CSS rendering, diagram, native
  long-user-message controls, and 8 expandable +N citation groups with
  19 functional independently verified HTTPS links.
- Operator verified external icons render correctly after localization
  of 24 referenced images from 11 integrity-verified archived bodies.
- Operator verified all 8 singleton citation links open the intended
  HTTPS destinations using the guarded two-stage evidence and the
  private `restore-singleton-citations.mjs` postprocessor.
- Explicitly accepted final defects: text accompanying singleton icon
  wraps onto the next line; four standalone `Fonti` controls do not
  operate in the offline output. No unsafe or speculative Fonti panel
  association was introduced.
- Other unproven dimensions: original cost table and "Scrittura" block
  visual parity, full RAW conversation completeness and generalization
  beyond observed shared conversation(s). Do not claim full fidelity.
- Existing private offline result and capture directories remain on
  operator's vmdev host only; neither raw content nor any private URL or
  image was committed to Git.
- The operator explicitly requested **conclusion without additional
  rendering fixes**. These limitations are part of the final accepted
  experimental result, not work scheduled for this task.

## Final validation

- Last physical focused Node-test result provided: **12/12 passing** on
  PoC `f585472` for the guarded remaining-control probe.
- Subsequent real Chromium capture verified eight singleton per-card
  HTTPS intents with zero network-guard failures.
- Final user-visible singleton-link navigation and icon/link appearance
  were confirmed by the operator. No physical result of the later
  `tests/restore-singleton-citations.test.mjs` suite was provided; the
  user-accepted behavior must not be described as a passing suite.
- Finalization changed PoC documentation only, not executable code.
  Current README was inspected and the modified diffs compared to
  canonical sources. No new runtime test was needed for documentation.
- Git history preserves the active investigation and this completion snapshot.

## Current state

Closed as an **operator-accepted experimental milestone**; not a
published RumiAI command or production-ready exporter.

## Next action

None. Any future improvement is a separate, explicitly activated task.

## Blockers / open questions

None blocking closure. Known behavioral and validation limits are
documented in the PoC README above.
