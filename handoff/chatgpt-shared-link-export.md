# ChatGPT shared-link export

Status: Active
Updated: 2026-10-15

## Goal

Build a deterministic, reusable exporter for ChatGPT conversations accessible through explicit `https://chatgpt.com/share/...` links, using the public `web-control` interface and preserving structured messages and available media without overwriting earlier exports.

## Current repository revisions

- rumiai-dev: fbbb715a1218eefcd9dea0221b276fed5f187356 (pre-checkpoint HEAD)
- rumiai-dev-PoCs: cf4f7e9306c83d9e9374594b62dd6c705d00f810 (window scanner, merge tests and documentation)
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
- Use modern JavaScript and the provider-neutral compatibility-2 navigation/inspection/capture/scroll operations; do not depend on `debug cdp`.
- Begin with an experimental implementation in `rumiai-dev-PoCs` until the actual shared-page DOM and asset behavior are validated.
- Preserve the captured rendered HTML as source evidence. Never infer unavailable attachments, invisible messages or unsurfaced image bytes.
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
- GitHub Actions PoC run 38721404476 PASS (syntax and fixture suites) at `cf4f7e9306c83d9e9374594b62dd6c705d00f810`. This tests synthetic virtualized page windows through the real exporter command with a simulated external web-control protocol boundary. It is **not** physical-site revalidation of the new revision.

## Current state

PoC 068 has a new bidirectional DOM-window scanner at `cf4f7e9306c83d9e9374594b62dd6c705d00f810`, with passing hosted simulation evidence (run 38721404476). The old physical-host run on the actual shared link was demonstrably incomplete due to virtualized DOM unmounting. The newer source has **not** yet been tested on the user's host or source link. It preserves image URL references from every observed window but cannot guarantee the image binary; the original missing-image diagnostic and any structured JSON embedded in the real shared page remain uninspected. Source-chat completeness cannot be asserted by scanning alone. No user conversation bytes were committed.


## Next action

On the user's real web-control host, update the PoC checkout and rerun the supplied sharing URL into an immutable new revision (with `NODE_EXTRA_CA_CERTS` set if corporate network TLS still requires it). Compare new message count and saved markdown against source UI, inspect `capture/segments/` and `assets[].reason` without publishing content/signed URLs. If still incomplete, obtain a sanitized example of the captured shared-page HTML containing its script/data shape and evaluate a browser-visible structured JSON capture route, inspired by but not conflated with the native-app CDP snapshot method.


## Blockers / open questions

- An actual share URL was supplied, but the assistant's available web fetch was disabled and the local container could not resolve chatgpt.com; no access to its live DOM has been obtained.
- No live web-control service is available in the assistant's current Debian auxiliary environment.
- Source page may omit uploaded file bytes or assets even when thumbnails/links are present.
- Corporate npm TLS issue was previously observed, but user has now completed 12/12 local tests and a real export. How local npm trust was remedied was not independently observed. Dedicated centralized browser CA work remains deferred under `todo/browser-certificate-trust-centralization.md`.
- Image binaries remain unverified: the prior version downloaded none, and the new scan only improves discovery of images in evicted turn windows; source/CDN/session/TLS diagnostics remain to be examined.
- No direct evidence yet of a structured shared-page payload/API shape from the actual share DOM or network traffic. The uploaded native macOS script cannot be transplanted into provider-neutral `web-control` without changing scope/contracts.
