# ChatGPT shared-link export

Status: Active
Updated: 2026-10-15

## Goal

Archive user-authorized ChatGPT shared-link conversations completely and readably, including multimedia, without duplicated turns or DOM-window heuristics, using the normal common web-control facility and Node.js.

## Current repository revisions

- rumiai-dev: 994e415d29685fae92a3aae74c15e0c1663ac10e (pre-checkpoint HEAD)
- rumiai-dev-PoCs: 7df999257366577eec418b4813a35bef57635611 (Node.js structured snapshot adapter)
- pwc-web-control: 403f4fa9bbea419715e9c834e847c6f2b60ae421 (released v0.1.6)
- electron-web-control: 077eb502f1d68235b4e5c9c28e4a7560795bce17 (released v0.1.6)
- pkg-catalog: 7cd9b7585b9343a153e516c9c47b6fb92b7330e0 (facility web-control 3 and both provider realizations)

## Applicable canonical sources

- README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md, handoff/README.md
- specifications/README.md, specifications/rumiai-os/WEB-CONTROL.md
- specifications/rumiai-os/DIAGNOSTICS.md
- handoff/web-control-debug-sessions.md (separate implementation/release lifecycle)

## Fixed task-local choices

- The original user-provided 33,346-byte macOS Python CDP snapshot exporter remains byte-for-byte unchanged at PoC 068 reference/chatgpt-export-v3.py. Its structural snapshot capture and mapping/current_node active-branch traversal are the reference behaviors.
- User explicitly wants Node.js and the common web-control interface. The active Node entrypoint is export-share.mjs and consumes compatibility-3 web-control debug sessions. It never opens a raw browser debugger TCP port, launches a parallel browser or depends directly on Playwright/Electron internals. The separate Python export-share-cdp.py adapter and legacy DOM-based export.mjs are retained for reference only and are not the accepted entrypoints.
- Never assume the native app:// mergeActiveBranch hook or a complete mapping/current_node object exists on the shared browser page. The user must not be given a fabricated or partial transcript as a complete export.
- Preserve the full message objects, branch identities, technical/non-text parts, and failure diagnostics. Preserve successive immutable exported versions. Do not commit user conversation content or signed asset URLs.
- Multimedia object metadata is NOT image binary data. Real images, SVG/canvas charts and ChatGPT-faithful HTML are separate downstream acceptance requirements, not yet demonstrated by the structured snapshot PoC.

## Acceptance scenarios

1. Starting with only a shared URL and destination directory, the user runs one Node.js command through the installed web-control provider; no internal page IDs, Chrome debug ports, provider-specific commands or Python are needed.
2. On an actually observed valid renderer snapshot, all visible current-branch messages are exported without repetition, with complete raw audit and multimodal references.
3. Each export writes a unique new directory and ZIP, never overwriting previous evidence.
4. On a shared site without a compatible snapshot, the command exits nonzero and preserves a numbered privacy-reduced diagnostic, never reporting successful completeness.
5. Eventually export images, graphic assets and readable HTML where browser-visible; missing media remains explicit, not silently omitted.

## Working design

The current node adapter observes only browser-delivered structured responses/JSON scripts and (if demonstrably present) the semantic original mergeActiveBranch hook in loaded JS. The web-control 3 session handles CDP navigation/events/evaluation/resume through both providers. The original Python script used a native app:// renderer and its validated hook must not be extrapolated to https://chatgpt.com/share/.

The failed DOM-based attempts used scrolling and window merging, produced repeated content, missing images/graphics and an immobile page in user physical tests; do not regress to those approaches.

## Completed

- Built legacy PoC 068 with immutable revision capture, JSON/Markdown, styled DOM HTML, attempted remote/data image download; user physical tests rejected its scrolling/duplication and media behavior.
- Preserved the user-supplied original Python macOS CDP exporter unchanged and built a separate experimental standalone-Chromium Python shared-link adapter. CI showed structural tests, NOT real shared-site support.
- Coordinated with the separate web-control debugger session task; published both Chromium provider releases v0.1.6, facility compatibility 3 and common open/send/events/close protocol.
- Converted Python structural capture and export to Node.js in PoC 068: snapshot-acquire.mjs, snapshot-export.mjs and export-share.mjs. Uses only the common web-control CLI/session commands; restores active branch traversal, non-text message objects, raw gzip, Markdown, JSONL, audit, SHA256, and a Node-native DEFLATE ZIP. No Python or shell zip needed for the new entrypoint.
- Tests include mocked provider session network capture and persistent paused frame resume, hook detection and URL validation, immutable artifact output and ZIP decompression, cyclic/gapped mapping failures and multimedia preservation. At exact PoC revision 7df999257366577eec418b4813a35bef57635611, GitHub Actions run 38744593125 passed 28/28 Node tests and 7/7 retained Python reference tests, including Node syntax check. Hosted mocked/fixture results must not be presented as physical ChatGPT URL acceptance.

## Current state

The Node.js port and hosted CI are complete, and the provider/package sources are genuinely released at compatibility 3. The actual user's shared ChatGPT page has NOT been run through the new Node exporter; compatibility with browser page structured JSON remains unverified. The exporter currently reports imagesDownloaded=0 and observationComplete=false even on a structured capture; reconstructing HTML/assets and live-site acceptance remain open.

## Next action

On the user's configured web-control 3 host, run from PoC 068:
node export-share.mjs https://chatgpt.com/share/<id> ./archive

If the source supplies a full snapshot, verify all active messages and multimodal metadata before adding real image/graph preservation. If it does not, inspect the numbered share-debug-diagnostic JSON field shapes privately to identify the real shared-page payload; do not invent endpoints or return to DOM scrolling. Do not require reinstalling a separate Chromium browser or a raw CDP port.

## Blockers / open questions

- The user's physical web-control instance/profile and actual shared URL renderer data are not accessible through the assistant's hosted CI environment. Physical functional acceptance remains open.
- Real image binary download and faithful graphic/HTML rendering remain open after data acquisition.
- The provider-install integration formal validation passed on both Linux architectures. Electron macOS ARM64 package job was still queued at the last shared-debugger handoff checkpoint; check its current status before making a universal installed-host claim.
