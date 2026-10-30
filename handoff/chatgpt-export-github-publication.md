# ChatGPT shared-link exports — GitHub Actions publication

Status: Active
Updated: 2026-10-30

## Goal

Allow the operator to provide a public ChatGPT share URL and topic in ChatGPT; trigger a GitHub Actions Linux export using the already accepted PoC 068 implementation and publish its existing offline directory under `rumiai-dev/chats/<topic>/<YYYY-MM-DD> <original chat title>/index.html` with the required local resources. Derive the original chat title and chat-start date automatically from verified share-page evidence, not from export date or the offline renderer's generic HTML title.

## Current repository revisions

- `rumiai-dev`: `2e69792ffc125d2df9514cc88b043b345ae713c8` (publication workflow and canonical documentation added; before this handoff checkpoint).
- `rumiai-dev-PoCs`: `aa4501aaaec18aebfe6d1eb1655a737ff7eb4df8` (metadata module, private Document acquisition, archive publisher and targeted tests; integrated full-browser probe triggered).

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `specifications/README.md`, `handoff/README.md`, `chats/README.md`.
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
- The share sample's original HTTP HTML contains `ChatGPT - Integrare Chat e Work` as its title, while `og:title` is a generic sharing invitation. Its React Router hydration `linear_conversation` yields a first user `create_time` corresponding to 2026-10-08 in Europe/Rome, distinct from the share creation time. A live GitHub curl extraction and targeted Node tests passed. `render-probe.mjs` now privately captures the original HTML Document in its static evidence; the full real-Chromium pipeline reading that evidence was triggered but its result must still be verified.
- The deployed workflow `.github/workflows/chatgpt-export.yml` accepts an owner-created Issue titled `ChatGPT export request` with a strict JSON body containing `url` and `topic`. Source revision is pinned and request content is passed to Node through private JSON, not shell interpolation. Publication uses a fast-forward-only Git push. A real Issue-to-commit execution remains unverified.
- Canonical `RULES.md`, `README.md`, and `chats/README.md` now distinguish this explicit public-share export from the disabled legacy GitHub mirror and from Google Drive. Recheck this alignment after each workflow change.
- `rumiai-dev` is public. Published HTML is world-readable and Git-retained; per-export authorization and handling of personal/sensitive content must be explicit before writing a real conversation.

## Completed

- **2026-10-30 implementation:** deployed owner-authorized GitHub Issue → Actions → multi-file export → forward-only commit workflow in `rumiai-dev`, with a completion/failure Issue comment. Updated canonical documentation in `RULES.md`, `README.md`, and `chats/README.md`. No actual conversation archive has yet been publicly committed.
- **2026-10-30 PoC extension:** `render-probe.mjs` privately captures original HTML Document bodies; added `share-metadata.mjs` and `publish-chat-archive.mjs`, plus targeted tests. The sample original title and first-user date were independently recovered from its live HTML on GitHub Actions. The CI metadata/test result was `testStatus: pass`. A real export with new private-document metadata checking is triggered separately and must not be counted as passed until its report is observed.

- Confirmed read-only that PoC 068 runs successfully end-to-end on GitHub-hosted Ubuntu/Chrome (`40954580470`), but that run did not publish an archive to Git.
- Verified existing exporter data/evidence boundary and current public repository/policy; identified the need for original timestamp and title evidence. Multi-file output now matches the chosen archive layout, so no single-file packing is needed.

## Current state

The publication workflow and exporter metadata adapter are implemented and committed. The first-user date/title and target path selection passed live-page and mock-boundary tests; the integrated Chrome capture check has been initiated but not yet confirmed. The first real authorized Issue → repository publication run remains untested. No chat archive has been committed.

## Next action

Confirm the result of the real Chromium integrated capture check on the GitHub runner; reconcile any failure forward. Once ready, use an explicitly supplied share URL and topic to create the first authorized Issue and verify actual GitHub publication and Issue outcome. Do not publish a chat without the operator's explicit request for that particular URL/topic.

## Blockers / open questions

- The integrated original-Document capture → metadata read has not yet been confirmed on the completed browser run.
- GitHub Issue trigger identity and `GITHUB_TOKEN` push permissions require one real authorized request to verify. The publisher rejects path collisions without overwriting and applies safe filename checks; broader share layouts remain unsupported.
