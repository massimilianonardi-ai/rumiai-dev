# ChatGPT shared-link exports — GitHub Actions publication

Status: Active
Updated: 2026-10-29

## Goal

Allow the operator to provide a public ChatGPT share URL and topic in ChatGPT; trigger a GitHub Actions Linux export using the already accepted PoC 068 implementation and publish its existing offline directory under `rumiai-dev/chats/<topic>/<YYYY-MM-DD> <original chat title>/index.html` with the required local resources. Derive the original chat title and chat-start date automatically from verified share-page evidence, not from export date or the offline renderer's generic HTML title.

## Current repository revisions

- `rumiai-dev`: `4a26e94cf752f70ca5518bd2f62d8bc3d8ec1ba0` (pre-activation checkpoint).
- `rumiai-dev-PoCs`: `3066b35127a2dddc71c54259ce708abc45f3a0fb` (accepted exporter; existing GitHub Actions browser run 40954580470 passed).

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `specifications/README.md`, `handoff/README.md`.
- `specifications/rumiai-os/WEB-CONTROL.md` as a browser-security boundary; current `handoff/chatgpt-shared-link-command.md` for the exporter and its validated scope.
- PoC 068 `export-offline.mjs`, `render-probe.mjs`, `audit-rendered-dom-raw.mjs`, `localize-rendered-resources.mjs`, `localize-exact-captured-images.mjs` and `poc-068-live-export.yml`.

## Fixed task-local choices

- Publication destination is the **existing public** `massimilianonardi-ai/rumiai-dev` repository, below `chats/`, grouped into topic subdirectories.
- The archive path is `chats/<topic>/<YYYY-MM-DD> <original chat title>/index.html` plus the relative local resources already emitted by PoC 068; do **not** flatten into a single HTML file. Normal caller supplies only URL and topic; date and title must be discovered from original-page evidence and safe-normalized as path components.
- Do not replace the operator-accepted exporter/rendering or claim all future share layouts are supported.
- This publication workflow is independent of the earlier one-command exporter packaging/validation handoff.

## Acceptance scenarios

- A user-supplied share URL and topic lead to an authorized Actions job, a verified offline export and an independently browsable `index.html` with relative CSS, fonts and images under `chats/<topic>/<chat-start-date> <original chat title>/`.
- Path fields are validated as safe single path segments and publication is forward-only, collision-safe and never overwrites an existing unrelated conversation.
- Failure to verify the original title, chat-start date, relative resource integrity or source provenance does not publish a misleading or partial archive; captures/browser profiles and signed/private evidence are not committed or logged.

## Working design

- The operator selected the PoC's existing multi-file layout instead of a standalone HTML file. Preserve `index.html`, local `assets/`, stylesheets, fonts and their relative paths; validate the full output tree before Git publication. There is no single-file inlining or renderer change.
- `audit-rendered-dom-raw.mjs` shows parsing of serialized `linear_conversation` from separately archived React Router hydration, but normal `render-probe.mjs --capture-static-bodies` currently saves stylesheets/fonts, **not** the initial Document response body. Neither the finished HTML nor the share URL currently provides a verified creation date **or original title**. Extend the capture/metadata boundary to obtain both: original chat title from authoritative share metadata or verified original-page title, first relevant user-message creation timestamp from original conversation evidence; reject missing/ambiguous/generic values. The offline generated HTML title is generic and must not be mistaken for the original chat title. Exact field availability and time-zone conversion (proposed Europe/Rome) need live proof. The OpenAI account-data export documents a shared-conversation title field, but that is not proof that the public share HTML exposes it.
- A chat-linked GitHub Issue can trigger Actions using `issues` events, subject to an authorization check, minimal `contents: write` and a safe published-path validation. Pin exporter source revision; do not execute untrusted Issue text as shell.
- The current `rumiai-dev/RULES.md` and `README.md` state that the old GitHub chats mirror is disabled and Google Drive is the authorized mirror. The user's newer explicit destination instruction supersedes that for this workflow, but the authoritative documentation needs deliberate realignment during implementation; do not silently describe the new publication as the old mirror.
- `rumiai-dev` is public. Published HTML is world-readable and Git-retained; per-export authorization and handling of personal/sensitive content must be explicit before writing a real conversation.

## Completed

- Confirmed read-only that PoC 068 runs successfully end-to-end on GitHub-hosted Ubuntu/Chrome (`40954580470`), but that run did not publish an archive to Git.
- Verified existing exporter data/evidence boundary and current public repository/policy; identified the need for original timestamp and title evidence. Multi-file output now matches the chosen archive layout, so no single-file packing is needed.

## Current state

Publishing workflow is **not implemented**. This handoff captures the new independent workstream and its concrete constraints. No conversation output has been committed.

## Next action

Verify reliable original chat-title and chat-start timestamp availability from a representative share via privacy-safe metadata-only observation. Then implement and test the metadata extension, the full-directory publication/audit logic and the authorized GitHub Actions Issue-to-commit workflow, realigning the canonical chats publication policy in the same work unit.

## Blockers / open questions

- Whether the original chat title and first-message creation time can be extracted reliably from current shared-page evidence; the chosen timezone for `YYYY-MM-DD` is still to be verified.
- Title/path collision and invalid-title handling must be verified without overwriting unrelated archives.
