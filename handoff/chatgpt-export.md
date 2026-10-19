# ChatGPT conversation exporter — Electron snapshot and public-share hydration

Status: Active
Updated: 2026-10-19

## Goal
Provide a direct JavaScript invocation that launches Chromium with native TCP CDP, navigates to a user-supplied URL and exports ChatGPT conversation data without DOM scrolling. Preserve the original Python/Electron snapshot breakpoint and forensic export behavior as the alternate existing API.

## Current repository revisions
- rumiai-dev: 74eb8373f2caaac6dc71b8ad7984faf9049126b4 (before this checkpoint)
- rumiai-os: 17077e469469f11dddb66a530a1692a663ba9fcb
- rumiai-tests: a0a33d2c49d27f32446574977c51c1bab16f15b0

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
- User physically ran the direct invocation against https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835: Chromium CDP startup and navigation worked; old hook discovery failed with snapshot-hook-not-found. This is negative evidence for the previous Electron-specific share approach, NOT evidence of the revised loader path.
- Added shared-page hydration extraction in rumiai-os commit 1f1fc5bfaa1dc6088ab00fe5bebd33a5907ce92a, final-document URL validation in 34a1634ef5a96bfa0309fa050a3814e0aedc8d2b, and matching manual in 17077e469469f11dddb66a530a1692a663ba9fcb.
- Updated permanent contract test in rumiai-tests commits 352d9bc1ae05866ab0363d124837416b10af48d4 and a0a33d2c49d27f32446574977c51c1bab16f15b0 for simulated loader, React Router stream and redirect-detection CDP flows. Published test not yet run with the official runner.
- Local Node v22 syntax and structural tests passed on the final-equivalent source. Synthetic loader and encoded stream parsing tests passed, and the native Node WebSocket/TCP CDP integration test exercised Page.navigate, share extraction, export and transcript. RAW gzip extraction and linear projection tests passed. This is simulated page evidence, not live ChatGPT page validation.
- No real live ChatGPT share extraction has been tested here: this environment cannot access chatgpt.com (DNS/network and browser administrator restrictions). No claim of real-page completeness is made.

## Current state
Source, manual and focused permanent test are committed; prior Electron API is retained. The user's prior observed error is addressed by a new acquisition mechanism, but compatibility with the exact live URL remains unverified. Private output and browser profile are not committed.

## Next action
Operator runs git pull --ff-only in their RumiAI workspace, then reruns the same direct command against the exact share URL. Examine emitted share-snapshot-captured provenance, audit source.projection, number/order of visible messages and actual content coverage. If share-snapshot-not-found persists, use reported loaderSources/streamChunks for next focused adjustment. Run focused permanent test in the official RumiAI test runner.

## Blockers / open questions
The actual current share page may have a different stream shape or hydration lifecycle from public reference implementations. Only physical operator-side re-run can establish compatibility and completeness.
