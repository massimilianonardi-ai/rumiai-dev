# ChatGPT shared-link export

Status: Active
Updated: 2026-10-15

## Goal

Export user-authorized ChatGPT shared-link conversations through the normal public `web-control` interface to immutable, readable, structured local archives, preserving available images, code and graphics without repeated turns.

## Current repository revisions

- rumiai-dev: 4efd07fe99c3d1e314309010e1e277a2f332b635 (pre-checkpoint HEAD)
- rumiai-dev-PoCs: ab308da3c5c07070ebba39d466014982680b4d34 (DOM-only prefix acquisition and media recovery)
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
- Superseding explicit user correction (2026-10-15): the original uploaded working Python CDP **snapshot capture** is the baseline to preserve, NOT the invented CDP mouse-wheel/DOM scrolling experiment. Earlier "do not use CDP" applied to the failed scrolling replacement and is superseded for the proven snapshot technique. Before implementing shared-link support, validate the actual browser renderer hook, because the original tool targets the macOS native ChatGPT app `app://-/index.html` and navigates `/work/conversation/<id>`, not `chatgpt.com/share/<id>`. Do not claim a compatible `mergeActiveBranch` hook on the shared page without direct evidence.
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
## Current state

Current PoC implementation at `ab308da3c5c07070ebba39d466014982680b4d34` is NOT physically accepted: user now reports that the page does not move and images are missing. Synthetic 21/21 CI evidence does not contradict the real failure. The original uploaded macOS Python exporter works in its native-app context: it discovers a JavaScript function containing `mergeActiveBranch`, holds a persistent CDP debugger, captures `JSON.stringify` of the in-memory conversation parameter at a breakpoint, and walks `mapping/current_node`. Its transcript preserves multimodal objects and references, but it does not download rendered image binary assets or produce a ChatGPT-styled offline HTML page. The Playwright web-control `debug cdp` convenience extension creates/detaches a fresh session per command, which cannot directly implement the reference's persistent breakpoint. Real shared-page renderer support for the hook remains unverified. No new code was changed in this analysis/checkpoint.

## Next action

Pivot the experiment away from repeated DOM scrolling, which failed the real-site test. Preserve the uploaded `chatgpt-export-v3(1).py` unchanged as the proven reference. Identify the actual shared-link browser renderer's conversation-data capture point in a controlled, persistent CDP session and validate whether a complete `mapping/current_node` snapshot is available there. Reuse original WebSocket/CDP breakpoint-event approach, snapshot capture and active-branch traversal where the page supports it; only then connect it to PoC 068 output. Keep the source-message object and `non_text` pieces, explicitly distinguish media references from downloaded image bytes. Do not ask the user for a redundant DOM scroll retest and do not claim a functioning shared-link CDP hook until physically observed.

## Blockers / open questions

- The assistant cannot inspect the user's physical local DOM/archive or use their configured web-control browser. The shared URL was inaccessible through the available assistant web fetch.
- The presence of `conversation-turn-N`/message IDs in the **actual** current shared DOM remains unverified; the adapter supports them based on current source patterns/tests only.
- Physical site has confirmed that the DOM-only Home/PageUp path does not scroll; further synthetic DOM scrolling refinements should not be treated as a path to acceptance.
- Original native-app script is not a drop-in browser-share exporter; presence and location of a browser-side conversation snapshot hook (if any) are unknown. A persistent CDP connection (distinct from existing web-control one-shot `debug cdp`) is necessary to reproduce the reference's breakpoint capture.
- Corporate TLS and browser-session-backed, `blob:` and canvas media may still be missing. The known centralized certificate management TODO remains separate.
