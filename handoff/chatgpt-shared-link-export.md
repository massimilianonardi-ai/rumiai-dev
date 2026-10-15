# ChatGPT shared-link export

Status: Active
Updated: 2026-10-15

## Goal

Export user-authorized ChatGPT shared-link conversations through the normal public `web-control` interface to immutable, readable, structured local archives, preserving available images, code and graphics without repeated turns.

## Current repository revisions

- rumiai-dev: fa2bcc49a12af1e8ac95d549da30683db1d2eb1e (pre-checkpoint HEAD)
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
- Explicit user correction after real-site failures: **do not use CDP**. Navigate, capture an initial DOM window, jump to the top of the loaded segment, wait for a *new older DOM prefix*, prepend only those messages, and repeat. Do not concatenate whole virtualized HTML windows, repeatedly traverse the whole page, or equate a quiet DOM with full source completeness.
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

## Current state

The current PoC is committed, CI green, and awaiting physical-site retest of the new DOM-only behavior. It reports counts of IDs/numbered turns, detected earlier DOM prefixes, failed media reasons and uncertain alignment. The user's prior real export showed that the preceding approach was not acceptable; no physical validation of the new revision is available. Images and graphics are improved only for data URLs and static SVG, not all browser-rendered visual modalities.

## Next action

On the user's configured host, update the PoC checkout and run the supplied share URL into the next immutable archive revision, using the corporate CA with Node if still required. Inspect CLI fields `messageCount`, `numberedTurns`, `identifiedMessages`, `observedBoundaryExtensions`, `uncertainWindowAlignment`; compare `conversation.html` to the original and privately inspect `assets[].reason` for remaining missing images. If earlier turns still do not load, use the saved actual DOM (after careful removal of private text and signed URLs) to identify a focusable chat scrolling target rather than guessing a private API.

## Blockers / open questions

- The assistant cannot inspect the user's physical local DOM/archive or use their configured web-control browser. The shared URL was inaccessible through the available assistant web fetch.
- The presence of `conversation-turn-N`/message IDs in the **actual** current shared DOM remains unverified; the adapter supports them based on current source patterns/tests only.
- Provider-neutral keyboard Home/PageUp may focus the wrong scrolling container on the real page; physical evidence must settle this before claiming source completeness.
- Corporate TLS and browser-session-backed, `blob:` and canvas media may still be missing. The known centralized certificate management TODO remains separate.
