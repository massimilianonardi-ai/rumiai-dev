# ChatGPT shared-link export — PoC 068

Status: Active
Updated: 2026-10-26

## Goal

Produce a readable offline archive of ChatGPT public shared conversations, preserving rich text, mathematical formulas, diagrams, images and linked references where the observed page evidence permits. Distinguish source completeness from visual acceptance.

## Current repository revisions

- `rumiai-dev`: `ac4b86af68cde1802513f336dc048e6aafdd077e` as checked before this handoff was created.
- `rumiai-dev-PoCs`: `d5672b8bbc8c638712e74b42d401e57f99337619`.

Fresh remote HEAD retrieval remains mandatory on resumption.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`.
- `specifications/README.md`, `specifications/rumiai-os/WEB-CONTROL.md`.
- PoC code and tests under `rumiai-dev-PoCs/pocs/068-chatgpt-shared-link-export/`.

## Fixed task-local choices

- Preserve the accepted standalone semantic renderer; original CSS/DOM replay is a separate experimental mode.
- Prefer exact captured static CSS/font bodies instead of hand-reconstructing each source layout.
- Keep raw captures and HTML outputs outside Git, protected as private data.
- No replay of source React/JavaScript/network; avoid overwriting prior artifacts.

## Acceptance scenarios

- The operator gives a shared ChatGPT URL and obtains a private, offline-readable HTML result with the observed messages in sequence.
- The diagram after “2. La soluzione che adotterei” retains its actual structure, not just stacked text.
- Grouped OpenAI sources remain retrievable from working links; interactive “+1” hover requires its own verification.
- The earlier accepted math on share 1 and rich reading on share 3 remain unaffected.

## Working design

- CSS insertion order and document ancestor/theme context were not preserved in the current static-body capture; evaluate actual rendering before deciding whether another targeted capture is required.
- Original CSS may not reproduce React-dependent popovers. If needed, design a safe standalone interaction limited to captured source links.

## Completed

- Share 2 regained DOM readiness and capture sweep. Physical vmdev evidence: 12 selected turns and a later full source capture at `/home/admino/chatgpt-share2-full-2MGSvdpK` with 51 turn snapshots, 46 CSS bodies, 1 font body, no recorded static-body failures, sweep finished.
- Commit `d5672b8` adds `render-same-session-styled.mjs`, reusing the already existing DOM assembler and static-resource localizer, with integrity checks, opt-in HTML creation and three fixture tests.
- Local Node syntax check and three orchestration tests with stubbed assembly/localization passed; they are not proof that the existing real assembler/localizer integration passes or that the physical site renders correctly.

## Current state

Original-CSS offline mode published, awaiting vmdev test on the existing private capture. Earlier accepted semantic outputs remain unchanged.

## Next action

Run the new fixture test and CLI on vmdev using fresh output directory, read sanitized counts and visually check diagram and OpenAI grouped links. If the output still misrenders, inspect CSS order/original page context and link structure from private evidence; do not assume missing resources or change all CSS indiscriminately.

## Blockers / open questions

- Real fixture and actual private capture validation pending.
- CSS order and missing source DOM ancestors may cause layout mismatches.
- Original source-link expansion interaction may be unavailable without JS.
- RAW source conversation completeness not proven by contiguous turn ordinals.
