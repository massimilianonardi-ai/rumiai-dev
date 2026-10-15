# ChatGPT shared-link export

Status: Active
Updated: 2026-10-15

## Goal

Build a deterministic, reusable exporter for ChatGPT conversations accessible through explicit `https://chatgpt.com/share/...` links, using the public `web-control` interface and preserving structured messages and available media without overwriting earlier exports.

## Current repository revisions

- rumiai-dev: 269f9a8e97dce18cab900c1c94bbeb11f62ba06b (pre-checkpoint HEAD)
- rumiai-dev-PoCs: ddbff77455f2423b1e19a4023522bbb4bd2f5f3b (structured JSON adapter, nested CDP wheel and lazy boundary probes, styled HTML)
- pwc-web-control: 5f3c8d298ac916be72ea59461a167ac31610ca61
- electron-web-control: 22da3beab20e509cffcbd81866b51253df4e08a9

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- specifications/README.md
- specifications/rumiai-os/CURRENT-MODEL.md
- specifications/rumiai-os/SENSE-MODEL.md
- specifications/rumiai-os/WEB-CONTROL.md
- specifications/rumiai-os/DIAGNOSTICS.md
- handoff/README.md

## Fixed task-local choices

- Implement an independent ChatGPT-specific deterministic consumer of the public `web-control` command, not a change to either browser provider.
- Use modern JavaScript and the public `web-control` interface. Explicit user correction after physical failure: the current PoC may use the already-published Playwright-specific `debug cdp` command for genuine wheel input into ChatGPT's nested/segmented scroll container; this does not modify the provider-independent web-control contract. The Electron portable fallback is not proven to handle nested segmented ChatGPT scrolling.
- Begin with an experimental implementation in `rumiai-dev-PoCs` until the actual shared-page DOM and asset behavior are validated.
- Preserve captured rendered HTML windows as source evidence and distinguish the separately generated styled offline `conversation.html`. Never infer unavailable attachments, invisible messages or unsurfaced image bytes.
- Keep revisions independent and forward-only; do not overwrite prior exports.
- No shared conversation text or attachment is committed to GitHub by this experiment.

## Acceptance scenarios

1. Given a valid public ChatGPT conversation sharing URL and an output directory, one command opens it through the selected `web-control` provider and writes a structured JSON + readable Markdown export alongside captured HTML.
2. Rerunning the same URL appends a distinct version and preserves prior versions.
3. Extracted assistant/user order and inline code, links and image references remain visible in structured and readable exports.
4. A revoked, restricted, unsupported or incomplete share does not silently produce a success-looking empty conversation; the tool reports the limitation and retains available evidence.
5. The user need not specify browser provider names, runtime page IDs or private profile paths.

## Working design

The live ChatGPT share DOM virtualizes/unmounts older turns. This has been confirmed by the user's visual inspection of the first real archive; the old end-only capture collected 10 final turns and missed earlier turns/images. The revised experiment traverses both directions, captures each distinct rendered HTML window under `capture/segments/`, and merges overlapping message ranges (preferring visible turn/message identifiers). Reaching the top and bottom without detected gaps is only scan evidence; it does not prove a complete source-chat export. Image binaries may still be unavailable because they are downloaded by Node separately from the authenticated browser.

The user-supplied `chatgpt-export-v3(1)(1).py` targets the **native macOS ChatGPT app**: it uses CDP debugger breakpoints around `mergeActiveBranch` to capture the app renderer's full in-memory conversation `mapping/current_node` snapshot. It is not an implementation of a public shared-link API, nor a verified pagination endpoint. Exploring whether a structurally equivalent payload exists in the shared page's embedded scripts/network responses is a separate site-specific experiment requiring captured real-page evidence; any such path is undocumented and must not be hardcoded from guesses.

## Completed

- Verified remote HEADs for current development and web-control provider repositories.
- Read current canonical development, Web-control, sense/model, diagnostic and testing contracts.
- Inspected both provider public commands and the existing Web-access handoff.
- Confirmed this exporter has an independent completion/validation lifecycle from the general web-sense workstream.
- Verified current OpenAI share-link behavior: personal links are snapshots and may represent individual responses or partial content.
- Added `pocs/068-chatgpt-shared-link-export`: Node.js CLI over provider-neutral `web-control 2`, rendered-HTML extraction, JSON/Markdown export, attempted first-party image downloads with explicit unavailability, immutable numbered export revisions and preserved HTML/text capture evidence.
- Added synthetic DOM parser tests and actual exporter-entrypoint workflow tests with a simulated external controller protocol. The latter do not validate a real provider.
- GitHub Actions PoC run 38705389302 passed on hosted Ubuntu (Node.js 22), including syntax, six initial extractor cases, follow-up parser cases and simulated-command workflow; this is not user-host physical validation.
- Reviewed the modified PoC file set against current repository contracts; no web-control provider, package catalog or rumiai-os runtime changes were made.
- Prepared opt-in GitHub Actions workflow `.github/workflows/poc-068-chatgpt-live-export.yml`: manually supplied URL, real pinned `pwc-web-control` CLI/service on Chrome/Xvfb, disposable no-upload archive, and summary-only output. No URL or conversation content was committed. Workflow has not been dispatched against the user's link.
- Added `archive/` and `node_modules/` to the PoC ignore list, and documented workflow privacy caveats and exact validation scope. Existing PoC fixture workflow `38709297713` passed on hosted Ubuntu at revision `0ba2245c84842789849cca2f9ab86b0e3ec60c03`; this is not a live ChatGPT site validation.
- Post-change diff covered only the opt-in workflow, PoC README and .gitignore; no provider/production API or canonical specification changed.
- User-reported physical-host test of the original end-only implementation: 12/12 fixture tests PASS; real share export `archive/0001` reported 10 final messages, 0 images downloaded, 1 image unavailable. User inspection demonstrated the chat had additional older turns and images which had been virtualized away; the previous scan's claim of settled bottom was insufficient.
- Implemented bidirectional virtualized-window acquisition/merging, raw per-window evidence, explicit scan-edge/gap flags and regression tests for overlapping windows, repeated text, discontinuities and end-to-end mocked viewport virtualization. No provider/runtime interfaces changed. Source reviewed against WEB-CONTROL and RumiAI testing/quality contracts.
- GitHub Actions PoC run 38721404476 PASS (syntax and fixture suites) at `cf4f7e9306c83d9e9374594b62dd6c705d00f810` (initial virtualized DOM scanner).
- Ported the uploaded native-app Python reference's `mapping/current_node` active-path traversal, text/non-text preservation and filtering to JS for actual detected embedded application/json snapshots. Did not invent a shared-link endpoint or transplant the native-app private breakpoint.
- Added self-contained styled `conversation.html`, with HTML-fragment sanitization and CSS for readable offline code/tables/messages; optional final-segment MHTML provider capture. Image bytes remain separately downloaded/unavailable.
- User clarified that ChatGPT loads *additional segments only on reaching the current segment boundary*, so the DOM's top/bottom is not the chat's top/bottom. Replaced direct scrollTop changes with actual Playwright CDP wheel dispatch at the message-pane position and repeated edge probes (24 stable samples; resets on changed content, geometry or scroll position), with boundary-change diagnostics. These are heuristics and never assert source-chat completeness for DOM-only scans.
- GitHub Actions PoC run `38725399854` PASS: 19 synthetic/CLI tests including a false top-edge that unlocks earlier turns only after repeated negative wheel events. Run `38725507876` also passed with the subsequent boundary-change diagnostic correction. Latest README-only revision `ddbff77455f2423b1e19a4023522bbb4bd2f5f3b` had a running Actions verification at this checkpoint; hosted fixture tests are not physical ChatGPT-page verification. No provider or rumiai-os production source changed.

## Current state

Current PoC revision `ddbff77455f2423b1e19a4023522bbb4bd2f5f3b` supports existing web-control navigation, optional Playwright CDP wheel events directed at the actual scrollable ChatGPT message container, prolonged probing of lazy segment boundaries, capture of intermediate DOM windows, optional detected embedded structured snapshot traversal, and styled self-contained `conversation.html` output. Prior physical export was incomplete; the user is actively testing the newer source on their local host, but no new physical result has been reported. The simulated lazy top-segment case has passing hosted evidence. DOM scan quiet edges are not completeness proof (`observationComplete: false` absent a structured snapshot). CSS is a readable reconstruction, not the real ChatGPT CSS bundle; image binary fidelity remains unverified. No user conversation bytes were committed.


## Next action

Collect user's physical-host result for the current revised PoC, especially the message count, `scrollSource`, `observedBoundaryExtensions`, `observedEdgeProbes`, `observedSettledAtTop`, and local styled `conversation.html` appearance. Compare the actual source with the reconstructed export, inspect asset diagnostics privately, and correct site-specific gaps using evidence from the live page. Record the final CI result for the exact source revision; do not claim physical validation from hosted fixtures.


## Blockers / open questions

- An actual share URL was supplied, but the assistant's available web fetch was disabled and the local container could not resolve chatgpt.com; no access to its live DOM has been obtained.
- No live web-control service is available in the assistant's current Debian auxiliary environment.
- Source page may omit uploaded file bytes or assets even when thumbnails/links are present.
- Corporate npm TLS issue was previously observed, but user has now completed 12/12 local tests and a real export. How local npm trust was remedied was not independently observed. Dedicated centralized browser CA work remains deferred under `todo/browser-certificate-trust-centralization.md`.
- Image binaries remain unverified: Node separately fetches discovered OpenAI-owned HTTPS URLs, but signed/authenticated, blob, CSS-backed and corporate-TLS resources may remain unavailable. Source/CDN/session/TLS diagnostics need physical evidence.
- No direct evidence yet of the actual embedded shared-page JSON/segment API shape or that the page exposes `mapping/current_node`. Ported traversal activates only on observed embedded JSON; native macOS breakpoint remains app-specific.
- Current lazy-boundary implementation has not been physically validated on the user's page. Some providers/page designs may not support the Playwright CDP wheel extension or may require a different message-container target.
