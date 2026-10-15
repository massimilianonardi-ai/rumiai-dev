# ChatGPT shared-link export

Status: Active
Updated: 2026-10-15

## Goal

Export user-authorized ChatGPT shared-link conversations through the normal public `web-control` interface to immutable, readable, structured local archives, preserving available images, code and graphics without repeated turns.

## Current repository revisions

- rumiai-dev: 3ea84cd218faa201af23ce2a02f2b392ee462c5d (pre-checkpoint HEAD)
- rumiai-dev-PoCs: 53f269a4cdc2e91ad494de9d0f65336e6fae950d (unmodified working Python exporter plus persistent browser CDP adapter)
- pwc-web-control: 5f3c8d298ac916be72ea59461a167ac31610ca61
- electron-web-control: 22da3beab20e509cffcbd81866b51253df4e08a9

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- specifications/README.md
- specifications/rumiai-os/WEB-CONTROL.md
- specifications/rumiai-os/DIAGNOSTICS.md
- handoff/README.md

## Fixed task-local choices

- This is a ChatGPT-specific PoC consumer; do not change `web-control` providers, `rumiai-os` or their portable contracts as a side effect.
- Current user-approved approach: preserve the **unchanged native macOS Python CDP exporter** and reuse its persistent WebSocket/CDP mechanism, call-frame snapshot extraction, original active branch traversal and forensic writer. The experimental browser-share adapter is a **separate explicit CDP PoC**, not a change to `web-control` or its provider-neutral contract. CDP must be bound to local loopback in a dedicated explicit browser profile; never expose a remote debugger as an ordinary service. No `mergeActiveBranch` hook or `mapping/current_node` shared-page payload may be claimed without observing actual browser data.
- Prefer observed message identities `data-message-id` and `data-testid="conversation-turn-N"` when actually present. No text-body equality alone can reliably disambiguate separate identical turns. Surface uncertain alignment instead of producing repeated content.
- Archive revisions are immutable and contain raw DOM evidence separately from an HTML reading view with its own CSS; missing media must be reported, not fabricated. No user conversation text or signed asset URLs are committed to GitHub.

## Acceptance scenarios

1. One CLI invocation with a valid shared URL and local destination produces JSON, Markdown, styled HTML and raw evidence.
2. Repeat invocation appends a new revision and leaves existing revisions intact.
3. A conversation initially mounted at its end must acquire progressively earlier segments without repeating an already captured turn.
4. An export retains available local/remote images, preserves static SVG graphs visually in HTML and marks unsupported canvas/blob resources explicitly.
5. The user does not need internal browser page IDs, provider names or API endpoints; failures and incomplete results remain diagnosable.

## Working design

The real ChatGPT DOM may virtualize turns and load older segments only after navigation to a current segment boundary. The previous experimental bidirectional scanner with per-frame CDP wheel input and whole-window merge was slow and, according to the user's physical trial, produced repeated conversation content, failed image downloads and flattened graphs. That approach was removed.

Current DOM-only experiment targets the first currently visible turn via the public `page press` command with `Home` and bounded `PageUp` fallback. `page inspect html` then supplies any newly loaded prefix. The extraction adapter sees potential per-turn identity attributes but their actual prevalence on the user's live shared page is **not yet measured**; output reports `numberedTurns` and `identifiedMessages` for that check. No source-chat completeness can be proven by this heuristic.

DOM-only rendering cannot recover a browser canvas bitmap or `blob:` contents, and remote images can fail due to signed URL, authentication or corporate TLS. Static SVG remains in styled HTML, bounded base64 inline data images are saved as local assets, and remote HTTPS images are attempted concurrently with a time limit. The macOS native-app snapshot script provided earlier works through a different app-internal acquisition path; it is not an established shared-link API.

## Completed

- Implemented experimental PoC 068 with immutable archive versions, JSON/Markdown, raw rendered evidence and styled HTML.
- Initial 12/12 synthetic tests passed; original physical run returned 10 final turns, no downloaded images and one missing image. User confirmed older messages were not exported.
- Later CDP/whole-window revision had hosted synthetic tests but user reported a slow, repetitive HTML export, missing images and charts flattened into text.
- Replaced active acquisition with DOM prefix-only scanning using public `web-control page press` (Home/PageUp) and `page inspect`; removed unused CDP scroller and snapshot modules. Kept single prefix identity-merging responsibility and no whole-window duplication.
- Restored inline SVG in parsed content and styled HTML, added honest canvas placeholder, supported bounded base64 inline PNG/JPEG/etc. image assets and four concurrent bounded HTTPS image fetches. Kept offline HTML sanitization.
- Added tests for numbered DOM turns, duplicate content with distinct IDs, ambiguous unnumbered chunks, virtualized segments, delayed older segment after a false top, SVG rendering, canvas limitation, inline PNG asset materialization and public CLI archive behavior.
- GitHub Actions PoC run [38730061263](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/38730061263) passed **21/21** tests at exact source revision `ab308da3c5c07070ebba39d466014982680b4d34`. This is a simulated controller boundary, **not a real ChatGPT-page validation**. No provider/production code changes or public conversation uploads.

- Current code at `ab308da3c5c07070ebba39d466014982680b4d34` remains mechanically CI-green but user's new physical test reports that the page does not move and images are still missing; treat as a failed acceptance.
- Re-read the actual uploaded `chatgpt-export-v3(1).py`: `get_renderer` selects native `app://-/index.html` only; `discover_snapshot_function` scans app scripts for `mergeActiveBranch`, and `capture_snapshot` holds a persistent `Debugger.setBreakpointByUrl` through app navigation and reads `JSON.stringify` of the matching call-frame argument. `export_snapshot` preserves raw snapshot, full message objects and separate non-text parts; it does not independently retrieve image bytes.
- Verified current `pwc-web-control/src/controller.mjs`: `debug.cdp` opens a new per-command session and detaches immediately, incompatible with preserving that breakpoint over navigation. A shared-link browser renderer hook has not been observed; the relevant adaptation must be evidence-led.
- Added Python `unittest` to `npm test` alongside the existing 21 Node fixture tests. The Python tests cover URL validation, hook marker matching, actual reference writer's active-branch and multimodal serialization, privacy-only JSON key diagnostics, and failure evidence uniqueness. Exact PoC revision `53f269a4cdc2e91ad494de9d0f65336e6fae950d` passed GitHub Actions run `38734325881`: 21/21 Node tests and 7/7 Python tests; both are mocked/synthetic, **not physical browser-share validation**. Physical share URL fetch in the assistant's web environment returned DisabledError, and the auxiliary environment has no user's Chrome CDP service.

## Current state

The previous DOM-only exporter remains in the repository as an unaccepted experimental comparison: user's physical trials reported no scrolling, missing images, repetition and unacceptable slowness. The new primary experimental entrypoint `export-share-cdp.py` was added under PoC 068 (current HEAD `53f269a4cdc2e91ad494de9d0f65336e6fae950d`), importing the reference file `reference/chatgpt-export-v3.py` copied byte-for-byte from the user's supplied `chatgpt-export-v3(1).py` (33346 UTF-8 bytes). The reference is not modified.

The adapter opens a fresh blank tab in an explicitly launched localhost-only Chromium debugger, attaches via the ORIGINAL persistent WebSocket/CDP implementation, navigates the share URL, inspects only structured JSON actually received by the browser and literal embedded JSON scripts, and searches loaded browser JS for the original semantic `mergeActiveBranch` marker when no snapshot was observed. It arms a persistent breakpoint only if that marker is actually present, and otherwise fails explicitly. Accepted snapshots must contain a valid parent-linked `mapping/current_node` chain. Successful export delegates to the unchanged reference writer for RAW gzip, JSONL, Markdown transcript, non-text parts, audit, checksums and ZIP. It writes a separate `ACQUISITION.json` with evidence method and explicitly reports that no image binaries were downloaded.

Failure is forward-only, writing numbered privacy-reduced `share-cdp-diagnostic-NNNN.json` files with phase, script count, source JSON key shapes (never values), and specific error identity. No actual shared-link hook or network snapshot shape is yet known from the user's browser. Hosted tests exercise the original writer and mocked CDP hook discovery, not physical browser-site success. The old `node export.mjs` workflow is not considered accepted.


## Next action

Run the new `python3 export-share-cdp.py "https://chatgpt.com/share/<id>" "./archive" --port 9222` on the user's physical host against an **explicit separate local Chromium profile** started with `--remote-debugging-address=127.0.0.1 --remote-debugging-port=9222`. Do not repeat DOM scrolling experiments. If structured snapshot capture succeeds, validate the full active branch and multimodal objects before adding separate asset-bytes/CSS/graph rendering to the output. If it fails, inspect numbered private diagnostic JSON key shapes, then examine the real page's structured response representation without guessing an endpoint or claiming the native-app hook is common to the website.


## Blockers / open questions

- The user requested a Node.js port using the common `web-control` interface rather than a standalone Chromium CDP port. The separate `handoff/web-control-debug-sessions.md` currently owns implementation/validation of a new common persistent debugger API on BOTH Playwright and Electron source branches (future compatibility level 3, not yet a declared installed provider compatibility). Once available in a released provider, migrate the exporter to Node.js atop that interface without altering the preserved original Python reference.
- The assistant cannot inspect the user's physical local DOM/archive or use their configured web-control browser. The shared URL was inaccessible through the available assistant web fetch.
- The presence of `conversation-turn-N`/message IDs in the **actual** current shared DOM remains unverified; the adapter supports them based on current source patterns/tests only.
- Physical site has confirmed that the DOM-only Home/PageUp path does not scroll; further synthetic DOM scrolling refinements should not be treated as a path to acceptance.
- Original native-app script is not a drop-in browser-share exporter; presence/location of a website renderer snapshot hook remains unknown. The new adapter implements persistent CDP independently of web-control's one-shot debugger interface, but still requires explicit localhost Chromium CDP physical validation.
- Capturing multimodal reference objects is not downloading their image data. CSS, actual image/graph bytes (including `blob:` or canvas), and corporate TLS needs remain separate. The centralized certificate management TODO remains separate.
