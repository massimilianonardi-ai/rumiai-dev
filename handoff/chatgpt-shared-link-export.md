# ChatGPT shared-link export — PoC 068

Status: Active
Updated: 2026-10-26

## Goal

Produce a readable offline archive of ChatGPT public shared conversations, preserving rich text, mathematical formulas, diagrams, images and linked references where the observed page evidence permits. Distinguish source completeness from visual acceptance.

## Current repository revisions

- `rumiai-dev`: `d63346e55abac94b56684a9da863825fc1689587` at this checkpoint.
- `rumiai-dev-PoCs`: `f2ecce3f1145156dfeeec3351df5029d574a490b`.

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

- Physical vmdev execution of four focused tests passed (0 failures); regenerated styled share 2 with 12 turns, no missing ordinals, 43 localized stylesheets and 77 unresolved references. Private-safe control inspection: `Mostra di più` on 1/5/9 (aria-expanded false), grouped +N labels on 2/4/6, with immediate label ancestry lacking link anchors. 
- Commit `cb763ddd` introduces **opt-in live interaction observation** during the existing sweep, for original-page show-more activation and source +N hover. It saves any newly observed links only in private event evidence; the sanitized inspector reports counts. This is not yet validated on physical vmdev and does not itself implement the offline controls.

- Physical vmdev interaction run: two tests passed, 59 turn snapshots, 8 hover attempts, 2 hovers revealing 4 distinct HTTPS URLs, no show-more clicks or reported errors. Source ownership remains unverified. Capture at `/home/admino/chatgpt-share2-interactive-QelaT13q`.
- Commit `f2ecce3` fixes show-more selection to match leaf-span label when the entire button contains extra hidden text. Adds candidate/label-match telemetry, a fake-DOM regression and a counts-only attribution inspector for the existing four URLs. These changes require vmdev tests and the fixed live capture has not yet been run.

## Current state

Operator physically inspected the original-CSS offline view and **accepted the diagram** following “2. La soluzione che adotterei”. Cost-per-token table styling, OpenAI +1 source controls and long-message “Mostra di più” are not yet accepted. The earlier accepted semantic outputs remain unchanged.

## Next action

On vmdev, pull current PoC and run the two focused interaction tests. First audit the **existing** `/home/admino/chatgpt-share2-interactive-QelaT13q` archive with `inspect-source-hover-attribution.mjs` (no new page visit). Next repeat one opt-in private CDP sweep with the corrected nested-label show-more detector to obtain expanded snapshots, examine candidate/click counts and compare capture completeness. Before building standalone source popovers, verify link-to-pill provenance; before displaying expanded messages, verify full text was actually captured. The corrected table still needs operator visual acceptance.

## Blockers / open questions

- Cost-table test and control-structure inspector passed physically on vmdev; **visual** acceptance of the corrected table is still pending.
- CSS order and missing source DOM ancestors may cause layout mismatches.
- Corrected nested-label expansion selector needs a new physical Chromium run; synthetic tests alone are insufficient. Link count consistency is only weak evidence, not source-to-pill provenance.
- RAW source conversation completeness not proven by contiguous turn ordinals.
