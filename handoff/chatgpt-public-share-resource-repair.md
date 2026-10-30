# ChatGPT public archive resource validation repair

Status: Complete
Updated: 2026-10-30

## Goal

Repair and complete the owner-requested public offline export of ChatGPT share `https://chatgpt.com/share/6ae474de-6564-83ed-adc0-f4a73f26a548`, topic `ChatGPT - export`, via `rumiai-dev` Issue #2. Preserve resource integrity and the non-mandatory citation-link policy.

## Current repository revisions

- `rumiai-dev`: `f9c5c614617c149f3def1f7d3d7a65cf0857bd9c` after the successful issue #2 publication (before final handoff retirement).
- `rumiai-dev-PoCs`: `ee6401d48c45d26c5d4100865b50d0bba66b6fa9` after removing the one-off transport diagnostic workflow.
- Successful export/workflow pinned PoC source `87427118a0cc6993918400417852c2dce5272ac7`.


## Applicable canonical sources

`README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `TESTING.md`, `handoff/README.md`, `chats/README.md`.

## Fixed task-local choices

- User authorized publication of the supplied share and now authorized diagnosis, repair and retry.
- Citation reachability/clickability is not an acceptance requirement.
- Preserve captured HTML, local asset integrity, CSP script blocking, validated original title/date, no partial Git publication, forward-only Git.
- No changes to `rumiai-os` or `rumiai-tests` for this work.

## Acceptance scenarios

1. The operator supplies a share URL and topic; the owner-authorized Issue runs the pinned exporter and publishes a complete script-disabled offline archive with all required referenced local assets.
2. If local resources are truly absent or invalid, the job refuses publication without overwriting anything, with actionable non-sensitive diagnostics.
3. Reopening Issue #2 after a corrected pinned exporter publishes the requested chat once, with a verified archive link and success report.

## Completed

- Issue #2 initially failed to publish because a captured original `img` used the ChatGPT root-relative URL `/images/ecosystem/apps/github/icon.png`, with no localized asset. The publisher correctly rejected the unresolved reference. Diagnostic run [41045115672](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41045115672) identified it.
- Implemented bounded first-party exact-URL retrieval, image MIME/signature/size/SHA checks, local HTML replacement, final structural/absolute-path rejection, and missing-asset diagnostics in PoC 068. Historical details and source revisions are recoverable through Git history.
- Hosted-runner transport check [41047331525](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/41047331525) showed default Node User-Agent 403 versus Chromium User-Agent 200 and 9,380-byte PNG; source fetch uses the verified browser User-Agent without relaxing origin or integrity requirements.
- Successful full Chrome + Git publication run [41047538020](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41047538020): **23/23 Node tests**, original chat title `export ChatGPT`, first-user date `2026-10-26`, topic `ChatGPT - export`, 46 files including 42 assets, 80 captured turn elements, `index.html` 1,220,060 bytes, exact 9,380-byte first-party PNG local, `script-src 'none'`. All workflow steps (including commit, forward-only push and owner-Issue comment) succeeded.
- Published archive: [`chats/ChatGPT - export/2026-10-26 export ChatGPT/index.html`](https://github.com/massimilianonardi-ai/rumiai-dev/blob/main/chats/ChatGPT%20-%20export/2026-10-26%20export%20ChatGPT/index.html).
- Issue [#2](https://github.com/massimilianonardi-ai/rumiai-dev/issues/2) closed as completed. Temporary diagnostic workflow removed via a later forward-only PoC commit. No product or `rumiai-tests` files modified.


## Current state

Successfully published and independently verified in the public destination repository. No partial failed archives were committed. Citation reachability remains optional, original scripts blocked, all required local resources validated. The HTML archive is historical/non-authoritative, consistent with `chats/README.md`. GitHub-hosted Chromium was exercised; no physical validation on an operator workstation is claimed.

## Next action

None. Work complete.

## Blockers / open questions

None.
