# ChatGPT shared-link exports — GitHub Actions publication

Status: Complete
Updated: 2026-10-30

## Goal

Allow the operator to provide a public ChatGPT share URL and topic in ChatGPT; trigger a GitHub Actions Linux export using the already accepted PoC 068 implementation and publish its existing offline directory under `rumiai-dev/chats/<topic>/<YYYY-MM-DD> <original chat title>/index.html` with the required local resources. Derive the original chat title and chat-start date automatically from verified share-page evidence, not from export date or the offline renderer's generic HTML title.

## Current repository revisions

- `rumiai-dev`: `24d8aaf1bc34eeecaa39687e0e2a48038077166d` (canonical chat citation policy corrected; workflow pinned and reopened-event retry enabled).
- `rumiai-dev-PoCs`: `f7567415961bdb4346d4b1bd6319e92679dfb597` (citation-independent exporter, tests, README; m-context smoke run launched).

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

## Final validation and publication

- **User correction:** external citation destination reachability, click behavior and fixed +N/singleton cardinality are no longer export acceptance requirements. The default exporter preserves captured citation controls visually but does not restore external targets or reject when they are unverifiable. HTML/CSS, exact local image resources, script blocking, title/date provenance and safe Git publication remain required.
- **Citation-independent smoke:** GitHub-hosted Ubuntu/Chrome run [41036454863](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/41036454863) concluded `success`; 22 focused Node tests passed. The real m-context share produced 1,370,089-byte HTML in the private runner, verified original date `2026-10-26`, source title captured, and `citationLinkVerificationRequired:false`.
- **Live operator-requested publication:** original Issue [#1](https://github.com/massimilianonardi-ai/rumiai-dev/issues/1) was reopened after the prior failed linked-citation attempt. The new GitHub Actions run [41037053581](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41037053581) completed `success`: author request check, checkout, dependency/tests, Chrome export, Git forward-only commit, and an Issue success comment all passed. Public archive directory is `chats/m-context/2026-10-26 m context/` with `index.html`, 42 local assets, and 3 archive audit JSON files (46 files). The public `index.html` was 1,370,044 bytes in the committed version. The original failure was the user-rejected +N HTTPS verification gate, not a Git authorization failure.
- **Canonical state:** `chats/README.md` now expresses the operator-approved citation policy, distinct from content/resource/CSP requirements. `.github/workflows/chatgpt-export.yml` pins the current exporter and supports both `opened` and `reopened` for authorized Issues. The current PoC README documents the citation-independent command and preserves old linked archive validation only as revision-specific evidence.
- Current validated repository revisions at the beginning of this closeout: `rumiai-dev@cd165ace9d6d8b21b5e8879e1eb322b1e884abce` and `rumiai-dev-PoCs@f7567415961bdb4346d4b1bd6319e92679dfb597` (plus diagnostic-only workflow commits in PoCs; the default exporter source is at `a5ad33a`, tests at `e50d6ea`).
- No more work is required for the specified m-context publication. Future independently requested shares may encounter other image, metadata or DOM layout constraints; these are not implied successes.

## Completed

- **2026-10-30 operator correction (current):** citation destination reachability and click-functionality guarantees are **removed entirely as export prerequisites**. The new integrated `export-offline.mjs` captures original visible DOM/CSS/images, retains citation controls visually and does not perform source-card or singleton-link target verification. Citation controls can be inert; only content, local resources, CSP, title/date and safe publication are gated. Historical guarded link-recovery PoC scripts remain separate and are not invoked. The standalone `rumiai-dev-PoCs` repo implementation and Node tests were updated (source `a5ad33a`, tests `e50d6ea`, docs `f756741`). The new real-browser m-context smoke run `41036454863` was in progress at this checkpoint.
- **First live publication attempt:** authorized Issue [#1](https://github.com/massimilianonardi-ai/rumiai-dev/issues/1) supplied `https://chatgpt.com/share/6ae46210-ceac-83eb-bf52-09b707731aff`, topic `m-context`. GitHub run [41033345519](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41033345519) validated request, setup, tests, Chrome then **refused before any Git commit** because prior strict exporter could not verify every +N source HTTPS target. This link requirement is the precise rule superseded by the operator. Workflow source is now pinned to the revised exporter and supports Issue `reopened` for retrying the same request.
- **Previous integrated Chrome metadata run 41027051553:** browser export and original title/date extraction passed for the prior reference sample; the overall run failed later only at a report-file Git merge. Do not confuse this with a successful m-context publication.

- **2026-10-30 implementation:** deployed owner-authorized GitHub Issue → Actions → multi-file export → forward-only commit workflow in `rumiai-dev`, with a completion/failure Issue comment. Updated canonical documentation in `RULES.md`, `README.md`, and `chats/README.md`. No actual conversation archive has yet been publicly committed.
- **2026-10-30 PoC extension:** `render-probe.mjs` privately captures original HTML Document bodies; added `share-metadata.mjs` and `publish-chat-archive.mjs`, and `export-offline.mjs --with-metadata` returns metadata without keeping private captures. Original share title and first-user timestamp were verified against real HTML, and component tests passed. Real Chrome run `41026492307` exposed a specific regression (`Invalid archived resource reference`) because the CSS/font materializer considered Document evidence; fixed it in `render-same-session-styled.mjs`, updated the existing CSS fixture, and added a Document-isolation regression test. A new integrated runner check `41027051553` passed its unit tests and was still executing its Chrome capture at the latest observation.

- Confirmed read-only that PoC 068 runs successfully end-to-end on GitHub-hosted Ubuntu/Chrome (`40954580470`), but that run did not publish an archive to Git.
- Verified existing exporter data/evidence boundary and current public repository/policy; identified the need for original timestamp and title evidence. Multi-file output now matches the chosen archive layout, so no single-file packing is needed.

## Current state

Complete. Operator-requested m-context export was published successfully and its GitHub-hosted implementation validated. The public archive and final Issue link were checked directly against the remote repository.

## Next action

None for this work unit. New operator-supplied URLs and topics can be handled as separate explicit publication requests.

## Blockers / open questions

None for this completed m-context export. Do not interpret citation-independent output as guaranteed navigation behavior or complete RAW conversation evidence.
