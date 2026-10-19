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

## Next action
Resume from the immutable commit identity / baseline branch and expand capture fidelity (formatted content, images, attachments, tables and interactive artifacts) **without regressing the verified Markdown path**. For any modification, compare the output to this baseline on the same public share and apply the normal consistency gate. Run focused permanent tests under the official runner when available. Do not require the user to repeat the already successful Markdown validation without a concrete new reason.

## Blockers / open questions
The complete Markdown scenario is no longer blocked: user has confirmed it. The fidelity and provenance of non-Markdown artifacts, automatic asset retrieval, and reproducibility across share versions remain open. The official permanent runner was not executed by this assistant in this checkpoint.
