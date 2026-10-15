# ChatGPT shared-link export

Status: Active
Updated: 2026-10-15

## Goal

Build a deterministic, reusable exporter for ChatGPT conversations accessible through explicit `https://chatgpt.com/share/...` links, using the public `web-control` interface and preserving structured messages and available media without overwriting earlier exports.

## Current repository revisions

- rumiai-dev: 482306740fa4fb1a47e755861f2923a3ec806b33 (pre-checkpoint HEAD)
- rumiai-dev-PoCs: 0ba2245c84842789849cca2f9ab86b0e3ec60c03 (opt-in live validation workflow, README, private output ignore)
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

The live ChatGPT share DOM can change and may present only a subset of the source chat. The first version targets observed `data-message-author-role` message containers, retains raw evidence and fails explicitly when no message structure is recognizable. Native attachments and remote image availability must be assessed against an actual user-provided or otherwise authorized share before promotion. Image downloads may need origin authorization and must not be represented as complete when unavailable.

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

## Current state

PoC implementation is committed in `rumiai-dev-PoCs` and has passing synthetic/controlled-boundary CI evidence through source revision abc6d1b7a338e6e7509da742c008c5885d2041ef. The latest PoC revision 455c17de4ae1aebc0b3a87b3fd834ad2f0b13e91 also passed GitHub Actions run 38705531193; it changes only README validation scope after the preceding source-and-test revision. The user has now supplied an actual share URL in the chat, but it was deliberately not committed to a repository. Access via the assistant web tool returned DisabledError; direct network access from the auxiliary container failed to resolve chatgpt.com. Real site extraction and media fidelity therefore remain unvalidated.

## Next action

Resolve the one-shot npm corporate-CA trust issue on the user's Ubuntu host without weakening TLS, confirm dependency installation and PoC fixture tests, then run the exporter through that host's installed real web-control provider using the already-supplied share URL. Compare visible turns, code, images and file links with captured evidence; correct only observed gaps before promotion.

## Blockers / open questions

- An actual share URL was supplied, but the assistant's available web fetch was disabled and the local container could not resolve chatgpt.com; no access to its live DOM has been obtained.
- No live web-control service is available in the assistant's current Debian auxiliary environment.
- Source page may omit uploaded file bytes or assets even when thumbnails/links are present.
- On the user's corporate-network Ubuntu host, `npm install` in PoC 068 failed with `SELF_SIGNED_CERT_IN_CHAIN` fetching `linkedom` from registry.npmjs.org (2026-10-15). The host's already known corporate CA file is `/usr/local/share/ca-certificates/rpr-DOM-CA.crt`. A one-shot `NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/rpr-DOM-CA.crt npm install` was recommended with TLS verification retained. No successful retry has yet been observed. Central browser CA management remains a separately deferred concern under `todo/browser-certificate-trust-centralization.md`.
