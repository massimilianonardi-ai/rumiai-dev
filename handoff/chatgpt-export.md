# ChatGPT conversation exporter — Electron snapshot and public-share hydration

Status: Active
Updated: 2026-10-19

## Goal
Provide a direct JavaScript invocation that launches Chromium with native TCP CDP, navigates to a user-supplied URL and exports ChatGPT conversation data without DOM scrolling. Preserve the original Python/Electron snapshot breakpoint and forensic export behavior as the alternate existing API.

## Current repository revisions
- rumiai-dev: 90f4193cf6c78f4309e497de763c8dcd4d51cbb5 (before this checkpoint)
- rumiai-os: 17077e469469f11dddb66a530a1692a663ba9fcb
- rumiai-tests: a0a33d2c49d27f32446574977c51c1bab16f15b0

## Validated Markdown baseline (2026-10-19)
- **Baseline identity:** massimilianonardi-ai/rumiai-os commit `17077e469469f11dddb66a530a1692a663ba9fcb` (the existing main HEAD at the user's confirmation).
- **Permanent remote checkpoint:** branch `baseline/chatgpt-export-markdown-2026-10-19` points to exactly this commit. Do not advance or repurpose the baseline branch. Continue future implementation on main/new forward commits.
- **Validation source:** the user reports a real execution of the latest direct Chromium+CDP exporter on their vmdev host for `https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835`, and explicitly confirms that the resulting Markdown export is correct and complete. This is user-reported physical functional validation, not independent assistant-side byte/content inspection.
- **Validated scope:** complete Markdown transcript for the supplied public share. Do not infer parity for images, attachments, richer interactive blocks, ZIP fidelity beyond earlier synthetic tests, other share versions, or broad browser/platform coverage.
- **Preservation rule:** retain the exact baseline code/commit. No commit message amend, no history rewrite, no in-place baseline changes. Any richer export work happens in additional forward commits with direct comparison to this baseline. The branch is a remote named anchor, not a Git tag; an annotated tag remains optional if an authorized tag-writing tool becomes available.

## Applicable canonical sources
README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md, specifications/README.md, specifications/rumiai-os/CURRENT-MODEL.md, FILESYSTEM-NAMING.md, LIBRARY-INTERFACES.md, DOCUMENTATION-MODEL.md, DIAGNOSTICS.md, WEB-CONTROL.md, COMMAND-ENTRYPOINTS.md, handoff/README.md.

## Fixed task-local choices
- Direct invocation: node <path-to-lib> <url> <analisys-dir>. Creates the requested directory, launches PATH-resolved Chromium in a temporary private profile, discovers the ephemeral loopback TCP CDP port, navigates, runs extraction and deletes owned browser/profile.
- For /share/ URLs: recognize mapping/current_node in supported page-loader globals or linear_conversation in Remix/React Router loader data and encoded React Router stream chunks. The Electron mergeActiveBranch breakpoint is NOT used on share pages; the user's observed snapshot-hook-not-found confirms that the original Electron-specific path does not apply.
- For a linear share, preserve the decoded linear source in conversation.raw.json.gz. Build only an in-memory active-branch projection for the unchanged output file families; audit source.projection and README declare that mapping/inactive branches were not captured as original source.
- Original chatgptExport(host, port, options) remains available for the Electron renderer; exportChatgptSnapshot remains the shared deterministic converter. No Python or Playwright; no TLS/sandbox bypass.

## Acceptance scenarios
1. Running the direct command launches Chromium and reads data exposed by an accessible public share without relying on mergeActiveBranch or DOM scrolling.
2. A mapping-based share yields the original forensic layout. A linear share yields the same artifact file set, but RAW, audit and README accurately distinguish linear-source provenance from an original conversation mapping.
3. Unknown share page formats fail explicitly with share-snapshot-not-found and diagnostic counts; redirects/error pages are rejected as navigation-unexpected-document; no partial or invented complete export.
4. The original Electron CDP API and snapshot converter continue to work without behavioral regression.

## Completed
- User initially ran the direct invocation against https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835: Chromium CDP startup/navigation worked, while the old Electron-hook discovery failed. That was negative evidence for the previous path, before the share-data correction.
- **New positive real-host result (2026-10-19):** user ran the latest published share-data implementation and confirmed that the Markdown export is complete and correct; pinned its exact current repository commit using a dedicated remote baseline branch.
- Added shared-page hydration extraction in rumiai-os commit 1f1fc5bfaa1dc6088ab00fe5bebd33a5907ce92a, final-document URL validation in 34a1634ef5a96bfa0309fa050a3814e0aedc8d2b, and matching manual in 17077e469469f11dddb66a530a1692a663ba9fcb.
- Updated permanent contract test in rumiai-tests commits 352d9bc1ae05866ab0363d124837416b10af48d4 and a0a33d2c49d27f32446574977c51c1bab16f15b0 for simulated loader, React Router stream and redirect-detection CDP flows. Published test not yet run with the official runner.
- Local Node v22 syntax and structural tests passed on the final-equivalent source. Synthetic loader and encoded stream parsing tests passed, and the native Node WebSocket/TCP CDP integration test exercised Page.navigate, share extraction, export and transcript. RAW gzip extraction and linear projection tests passed. This is simulated page evidence, not live ChatGPT page validation.
- This assistant environment still cannot access chatgpt.com (DNS/network/browser policy); it cannot independently inspect or reproduce the user's export bytes. However the user has now successfully executed the current revision on the real target and explicitly verified Markdown completeness. That positive user-side evidence supersedes the previous unverified live-page status **for this tested Markdown scenario only**.

## Current state
The real-share Markdown export is a user-confirmed successful baseline pinned at the above SHA and dedicated remote branch. Source, manual and focused permanent test remain on main; the original Electron API remains available. The output files and browser profile are private and are not committed. Further full-fidelity features have not been verified.

## PoC 068 actual-page evidence review (2026-10-19)

Current source: `rumiai-dev-PoCs@a2e4cb7df97814b56ec36457f828271e41208af4`, `pocs/068-chatgpt-shared-link-export/analysis-chromium/` and `analysis-pw/run-d7aGlC/`. Reviewed JSONL and summaries from real user-supplied target share; this is a read-only analysis, not a new live run.

- Native CDP session: 4,843 recorded events over 89,175 ms; 1,157 DOM mutation batches (2,490 added nodes, 1,219 removed nodes, 1,827 attribute changes, 12 text changes); 1,182 interaction events (303 scroll, 848 keydowns of which 844 ArrowDown, 9 wheel); 647 performance, 1,786 network events. No dropped records reported. During the scroll-event time span (11,203–75,353 ms), 1,098 DOM mutation batches reported 1,929 additions and 1,185 removals, consistent with mounting/unmounting but not proof of individual message virtualization.
- In `web-analyze.lib.js`, scroll events record `shape(event.target)` plus **window.scrollX/Y**, not the scroll target's own `scrollTop`; captured scroll target is a `div` (second sibling by tag), with window Y zero. A nested scroll container is likely and must be identified from its own scrollTop/scrollHeight/clientHeight and stable locator before replay. The logged `shape` deliberately lacks `id`, `data-message-id`, `data-turn-id`, `data-testid`, React key and message UUID. It cannot prove mapping from a DOM div ID to `linear_conversation[i].message.id`.
- Playwright run summary: HTTP 200 / target title `chat mlp evo`, one initial HTML/screenshot checkpoint with `readyState=interactive`, 726 elements, body text length 325 and extent zero. Importantly, a subsequent mutation batch (+160 elements) and two in-page scroll events (reported top 13,775 then 13,225) occurred *after* that snapshot, so the one checkpoint is premature, not proof that content was absent. There were also console-reported errors on anonymous conversation preparation; no source error bodies were captured to establish impact.
- Correlating scroll and DOM mutation on one timeline is useful for identifying triggers, but correlation alone cannot identify React state transitions or prove complete DOM reconstruction. Follow-up instrumentation should preserve original message and DOM IDs, capture true event-target scroll coordinates, content/identity hashes and mount/unmount sequences, and checkpoint only after application-specific hydration. Compare source message IDs from the preserved Markdown baseline RAW and rendered DOM IDs. Do not touch the verified Markdown baseline.
- **Security caveat:** the PoC tree currently tracks an entire `analysis-chromium/profile/` with files named `Cookies`, `Login Data`, `History` and browser cache, plus session HTML/trace data. We have not inspected secret values. These artifacts can contain authentication/private browsing material and need a privacy review and explicit remediation plan; deleting files in a new commit does not erase old Git history. Do not put credentials or captured private data into handoff.

## PoC 068 captured ChatGPT renderer logic (2026-10-19)

- Real user-operated Chromium+CDP archive at `rumiai-dev-PoCs@cfc4533627382bb0e339ea1c424eb96d1f88b123`, `pocs/068-chatgpt-shared-link-export/analysis-chromium-resources-02`, supplies 530 compiled script records (525 distinct files) and 614 response bodies, enabling static inspection of genuine ChatGPT client code; see `handoff/web-analyze.md` for detailed acquisition and privacy status.
- Distinct rendered attribute ↔ data mappings are established by client JSX: in compiled asset `8b34dbc2-i6mnaw2f0obqfl0x.js` the message wrapper sets `data-message-id` from message `.id`; the turn wrapper sets `data-turn-id-container`/`data-turn-id` from turn `.id`, with `data-testid="conversation-turn-N"` from turn ordinal. This is concrete source evidence that stable application IDs are used in rendered DOM; exact equivalence to our saved RAW message IDs remains to be tested directly on the same sample.
- Main conversation turn rendering path, in that same compiled asset, creates one wrapper per turn. Its rendering state is driven by an intersection observer: when not intersecting or otherwise forced, children can be null and the wrapper carries an estimated/last-known height, explaining DOM virtualization and structural continuity. Certain groups are always rendered, explicit forced turns are rendered, last five turns stay enabled, and ±5 turns around a reference index stay enabled. These counts are constants in this observed minified build, not normative stable ChatGPT APIs.
- The same component observes visibility changes via `intersectionObserver.observe`, transitions local React state and notifies `onIntersectingChange`; a coordinating component retains an anchor turn/offset and adjusts the actual scroll-root `scrollTop` to compensate re-layout. In `conversation-small-fcu1fuggk1duh76x.js`, browser-side code installs a `scroll` listener that toggles `data-scroll-from-top` using `element.scrollTop` (not `window.scrollY`) and searches DOM by original `data-message-id` or `data-turn-id-container`.
- Implication: DOM mutation replay requires **real intersection/geometry and React state callbacks**, not merely synthetic `scroll` events, and must preserve original wrapper/message IDs and snapshot DOM subtrees before unmounting. Next experimental step should instrument the real scroll target (`data-scroll-root`), observer creation/notifications and per-turn mount/unmount with exact IDs; test controlled scrollTop changes then only consider more direct forcing of observer/state transitions based on observed behavior. Do not modify the pinned Markdown baseline.
- Evidentiary boundary: static compiled JavaScript establishes code paths but does not itself prove each was triggered on the user's live run. Existing DOM mutation logs omit individual IDs and callback identity, and there has not yet been a physically validated deterministic DOM reconstruction. Assets and browser profile were committed by the user and may contain private or session material; do not expose or re-commit raw contents without review.

## Next action
Resume from the immutable commit identity / baseline branch and expand capture fidelity (formatted content, images, attachments, tables and interactive artifacts) **without regressing the verified Markdown path**. For any modification, compare the output to this baseline on the same public share and apply the normal consistency gate. Run focused permanent tests under the official runner when available. Do not require the user to repeat the already successful Markdown validation without a concrete new reason.

## Blockers / open questions
The complete Markdown scenario is no longer blocked: user has confirmed it. The fidelity and provenance of non-Markdown artifacts, automatic asset retrieval, and reproducibility across share versions remain open. The official permanent runner was not executed by this assistant in this checkpoint.
