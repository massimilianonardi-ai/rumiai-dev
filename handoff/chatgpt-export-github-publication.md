# ChatGPT shared-link exports — GitHub Actions publication

Status: Active
Updated: 2026-10-30

## Goal

Allow the operator to provide a public ChatGPT share URL and topic in ChatGPT; trigger a GitHub Actions Linux export using the already accepted PoC 068 implementation and publish its existing offline directory under `rumiai-dev/chats/<topic>/<YYYY-MM-DD> <original chat title>/index.html` with the required local resources. Derive the original chat title and chat-start date automatically from verified share-page evidence, not from export date or the offline renderer's generic HTML title.

## Current repository revisions

- `rumiai-dev`: `ce92416baa837b189dc6c5cb581be2da6bd74f6f` (workflow pinned to metadata and original-CSS isolation revision; before this handoff update).
- `rumiai-dev-PoCs`: `1d7f17de67bdac9f714d996bec467dd9b3ad1f6b` (optional `--with-metadata`, publisher and original-CSS Document filter plus regression tests; integrated real-Chromium run `41027051553` ongoing).

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
- The share sample's original HTTP HTML contains `ChatGPT - Integrare Chat e Work` as its title, while `og:title` is a generic sharing invitation. Its React Router hydration `linear_conversation` yields a first user `create_time` corresponding to 2026-10-08 in Europe/Rome, distinct from the share creation time. A live GitHub curl extraction and targeted Node tests passed. `render-probe.mjs` now privately captures the original HTML Document in its static evidence; `export-offline.mjs --with-metadata` returns verified original title, timestamp and Europe/Rome date while disposing of private evidence after success. The CSS/font materializer excludes Document resources. Full real-Chromium evidence must still be checked against the new revision.
- The deployed workflow `.github/workflows/chatgpt-export.yml` accepts an owner-created Issue titled `ChatGPT export request` with a strict JSON body containing `url` and `topic`. Source revision is pinned and request content is passed to Node through private JSON, not shell interpolation. Publication uses a fast-forward-only Git push. A real Issue-to-commit execution remains unverified.
- Canonical `RULES.md`, `README.md`, and `chats/README.md` now distinguish this explicit public-share export from the disabled legacy GitHub mirror and from Google Drive. Recheck this alignment after each workflow change.
- `rumiai-dev` is public. Published HTML is world-readable and Git-retained; per-export authorization and handling of personal/sensitive content must be explicit before writing a real conversation.

## Completed

- **2026-10-30 implementation:** deployed owner-authorized GitHub Issue → Actions → multi-file export → forward-only commit workflow in `rumiai-dev`, with a completion/failure Issue comment. Updated canonical documentation in `RULES.md`, `README.md`, and `chats/README.md`. No actual conversation archive has yet been publicly committed.
- **2026-10-30 PoC extension:** `render-probe.mjs` privately captures original HTML Document bodies; added `share-metadata.mjs` and `publish-chat-archive.mjs`, and `export-offline.mjs --with-metadata` returns metadata without keeping private captures. Original share title and first-user timestamp were verified against real HTML, and component tests passed. Real Chrome run `41026492307` exposed a specific regression (`Invalid archived resource reference`) because the CSS/font materializer considered Document evidence; fixed it in `render-same-session-styled.mjs`, updated the existing CSS fixture, and added a Document-isolation regression test. A new integrated runner check `41027051553` passed its unit tests and was still executing its Chrome capture at the latest observation.

- Confirmed read-only that PoC 068 runs successfully end-to-end on GitHub-hosted Ubuntu/Chrome (`40954580470`), but that run did not publish an archive to Git.
- Verified existing exporter data/evidence boundary and current public repository/policy; identified the need for original timestamp and title evidence. Multi-file output now matches the chosen archive layout, so no single-file packing is needed.

## Current state

The publication workflow and exported metadata API are committed. The original title/date and safe archive path passed live-page and scoped tests; integrated Chrome run `41027051553` is in progress after the Document/CSS materializer regression fix. A real authorized Issue → public repository publication remains untested. No chat archive has been committed.

## Next action

Inspect completed GitHub run `41027051553`, its test/Chrome steps, and sanitized metadata report; reconcile any remaining failure forward. Once ready, create an owner-authorized Issue for an operator-supplied share URL and topic, then verify the first actual Git publication and Issue outcome. Never select a conversation/topic for public publication by inference.

## Blockers / open questions

- The integrated original-Document capture → optional exporter metadata result is not yet confirmed on a **completed** passing Chrome run for revision `1d7f17de67bdac9f714d996bec467dd9b3ad1f6b`.
- GitHub Issue trigger identity and `GITHUB_TOKEN` push permissions require one real authorized request to verify. The publisher rejects path collisions without overwriting and applies safe filename checks; broader share layouts remain unsupported.
