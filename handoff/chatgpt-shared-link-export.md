# ChatGPT shared-link export

Status: Active
Updated: 2026-10-15

## Goal

Build a deterministic, reusable exporter for ChatGPT conversations accessible through explicit `https://chatgpt.com/share/...` links, using the public `web-control` interface and preserving structured messages and available media without overwriting earlier exports.

## Current repository revisions

- rumiai-dev: 0ff1e2804276b66ffd05af3e93526253068efa75 (pre-handoff HEAD)
- rumiai-dev-PoCs: a451b7903fddf4d4e5b2e8cbf66d82d51ac88932 (pre-experiment HEAD)
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

## Current state

Preflight and design boundary established. Experimental implementation and end-to-end live share validation remain outstanding.

## Next action

Implement and exercise a narrow export PoC over the portable CLI using synthetic HTML cases first; then validate against a real shared conversation and explicitly assess media coverage and rendering drift.

## Blockers / open questions

- No actual ChatGPT shared-link URL has been supplied for end-to-end real-site validation.
- No live web-control service is available in the assistant's current Debian auxiliary environment.
- Source page may omit uploaded file bytes or assets even when thumbnails/links are present.
