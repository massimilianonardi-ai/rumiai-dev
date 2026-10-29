# ChatGPT shared-link exports — GitHub Actions publication

Status: Active
Updated: 2026-10-29

## Goal

Allow the operator to provide a public ChatGPT share URL, a topic and a chat title in ChatGPT; trigger a GitHub Actions Linux export using the already accepted PoC 068 implementation and publish the resulting offline conversation under `rumiai-dev/chats/<topic>/<YYYY-MM-DD> <title>.html`. The date means **chat start**, not share creation or export date.

## Current repository revisions

- `rumiai-dev`: `4a26e94cf752f70ca5518bd2f62d8bc3d8ec1ba0` (pre-activation checkpoint).
- `rumiai-dev-PoCs`: `3066b35127a2dddc71c54259ce708abc45f3a0fb` (accepted exporter; existing GitHub Actions browser run 40954580470 passed).

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `specifications/README.md`, `handoff/README.md`.
- `specifications/rumiai-os/WEB-CONTROL.md` as a browser-security boundary; current `handoff/chatgpt-shared-link-command.md` for the exporter and its validated scope.
- PoC 068 `export-offline.mjs`, `render-probe.mjs`, `audit-rendered-dom-raw.mjs`, `localize-rendered-resources.mjs`, `localize-exact-captured-images.mjs` and `poc-068-live-export.yml`.

## Fixed task-local choices

- Publication destination is the **existing public** `massimilianonardi-ai/rumiai-dev` repository, below `chats/`, grouped into topic subdirectories.
- Expected final filename is `YYYY-MM-DD <chat title>.html`, where the date is determined automatically from original conversation evidence. The caller gives URL, topic and title.
- Do not replace the operator-accepted exporter/rendering or claim all future share layouts are supported.
- This publication workflow is independent of the earlier one-command exporter packaging/validation handoff.

## Acceptance scenarios

- A user-supplied share URL, topic and title lead to an authorized Actions job, a verified offline export and an independent HTML file under `chats/<topic>/` with the chat's original start date.
- Path fields are validated as safe single path segments and publication is forward-only, collision-safe and never overwrites an existing unrelated conversation.
- Failure of date provenance, HTML/resource packing or source verification does not publish a misleading or partial archive; captures/browser profiles and signed/private evidence are not committed or logged.

## Working design

- The PoC 068 final archive currently emits `index.html` plus local `assets/`, CSS and fonts, so a true one-file `.html` needs an additional self-contained packaging/verification step preserving CSP/script blocking and link behavior.
- `audit-rendered-dom-raw.mjs` shows parsing of serialized `linear_conversation` from separately archived React Router hydration, but normal `render-probe.mjs --capture-static-bodies` currently saves stylesheets/fonts, **not** the initial Document response body. Neither the finished HTML nor the share URL currently provides a verified creation date. Acquire and validate first relevant user-message timestamp at the browser capture boundary (or a separate evidence-backed metadata extractor); reject missing/ambiguous timestamps. Exact field presence and local-time conversion need proof on live evidence.
- A chat-linked GitHub Issue can trigger Actions using `issues` events, subject to an authorization check, minimal `contents: write` and a safe published-path validation. Pin exporter source revision; do not execute untrusted Issue text as shell.
- The current `rumiai-dev/RULES.md` and `README.md` state that the old GitHub chats mirror is disabled and Google Drive is the authorized mirror. The user's newer explicit destination instruction supersedes that for this workflow, but the authoritative documentation needs deliberate realignment during implementation; do not silently describe the new publication as the old mirror.
- `rumiai-dev` is public. Published HTML is world-readable and Git-retained; per-export authorization and handling of personal/sensitive content must be explicit before writing a real conversation.

## Completed

- Confirmed read-only that PoC 068 runs successfully end-to-end on GitHub-hosted Ubuntu/Chrome (`40954580470`), but that run did not publish an archive to Git.
- Verified existing exporter data/evidence boundary and current public repository/policy; identified timestamp and single-file packaging requirements.

## Current state

Publishing workflow is **not implemented**. This handoff captures the new independent workstream and its concrete constraints. No conversation output has been committed.

## Next action

Verify reliable original chat-start timestamp availability from a representative share via privacy-safe metadata-only observation. Then implement and test a single-file archival packager and the authorized GitHub Actions Issue-to-commit workflow, realigning the canonical chats publication policy in the same work unit.

## Blockers / open questions

- Whether reliable first-message creation time can be extracted from the current shared-page representation, and the chosen timezone to render the date.
- Full fidelity of one-file HTML after bundling fonts, CSS and images has not been tested.
