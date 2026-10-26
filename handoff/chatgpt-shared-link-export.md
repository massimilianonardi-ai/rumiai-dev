# ChatGPT shared-link export — PoC 068

Status: Active
Updated: 2026-10-26

## Goal

Produce a readable offline archive of ChatGPT public shared conversations, preserving rich text, mathematical formulas, diagrams, images and linked references where the observed page evidence permits. Distinguish source completeness from visual acceptance.

## Current repository revisions

- `rumiai-dev`: `40e9fa18012e3871c3d0fdb0ffcc9e94ef20301b` at this checkpoint.
- `rumiai-dev-PoCs`: `9d84c8f51641ef6486773745fe96a7871c001c6f`.

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
- Grouped OpenAI sources remain retrievable from working links and the compact +1 group can be expanded without the original React runtime. Long user messages can be fully read from the archive.
- The earlier accepted math on share 1 and rich reading on share 3 remain unaffected.

## Working design

- CSS insertion order and document ancestor/theme context were not preserved in the current static-body capture; evaluate actual rendering before deciding whether another targeted capture is required.
- Original CSS may not reproduce React-dependent popovers. If needed, design a safe standalone interaction limited to captured source links.

## Completed

- Share 2 regained DOM readiness and capture sweep. Physical vmdev evidence: 12 selected turns and a later full source capture at `/home/admino/chatgpt-share2-full-2MGSvdpK` with 51 turn snapshots, 46 CSS bodies, 1 font body, no recorded static-body failures, sweep finished.
- Commit `d5672b8` adds `render-same-session-styled.mjs`, reusing the already existing DOM assembler and static-resource localizer, with integrity checks, opt-in HTML creation and three fixture tests. Commit `c85de05` permits CSS hover on buttons without enabling scripts.
- Local Node syntax check and three orchestration tests with stubbed assembly/localization passed; they are not proof that the existing real assembler/localizer integration passes or that the physical site renders correctly.

- Commit `9d84c8f` removes the generic table-cell borders from the original-CSS preview and adds a private-safe interaction-structure inspector plus focused tests. No claim of visual acceptance of the corrected table or functional source controls. 

## Current state

Operator physically inspected the original-CSS offline view and **accepted the diagram** following “2. La soluzione che adotterei”. Cost-per-token table styling, OpenAI +1 source controls and long-message “Mostra di più” are not yet accepted. The earlier accepted semantic outputs remain unchanged.

## Next action

On vmdev, pull current PoC, run targeted fixture tests, re-render the **existing** private capture into a fresh output, and inspect the cost table after removing generic fallback borders. Run `inspect-styled-interactions.mjs /home/admino/chatgpt-share2-full-2MGSvdpK` and use the sanitized structural report to choose a safe mechanism for OpenAI +1 and long-message expansion. Do not disturb the accepted diagram or accepted semantic outputs.

## Blockers / open questions

- New cost-table regression and structural inspector require real vmdev test; the diagram is visually accepted.
- CSS order and missing source DOM ancestors may cause layout mismatches.
- Original source-link expansion and long-message controls depend on React; determine whether exact link targets and unclipped message content exist in captured DOM before implementing a standalone interaction.
- RAW source conversation completeness not proven by contiguous turn ordinals.
