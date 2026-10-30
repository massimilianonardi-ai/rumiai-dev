# ChatGPT public archive resource validation repair

Status: Active
Updated: 2026-10-30

## Goal

Repair and complete the owner-requested public offline export of ChatGPT share `https://chatgpt.com/share/6ae474de-6564-83ed-adc0-f4a73f26a548`, topic `ChatGPT - export`, via `rumiai-dev` Issue #2. Preserve resource integrity and the non-mandatory citation-link policy.

## Current repository revisions

- `rumiai-dev`: current checkpoint `2010b98cc20239add113b1b1b4341233be286df9`; currently pins PoC code `87427118a0cc6993918400417852c2dce5272ac7`.
- `rumiai-dev-PoCs`: code revision `87427118a0cc6993918400417852c2dce5272ac7`, with first-party Chrome User-Agent and regression test; head includes isolated transport smoke workflow.
- Fresh HEAD checks are always required before subsequent writes.

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

- Initial Issue #2 and workflow run [41043087885](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41043087885) failed after 9 tests passed; no partial archive was committed.
- Added publisher diagnostics and CSS regression coverage (PoC commits `0cae619`, `e7f5a5a`). Second actual Chrome run [41045115672](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41045115672) confirmed a specific root-relative GitHub app icon, without any publication.
- Added exact-origin first-party image localizer, bounded/signed verified files, negative tests and exporter integration (PoC commits `df30238`, `5878a39`, `16999b9`, `19bfd5c`); updated PoC README in `0150564`.
- Updated publication workflow to pin `19bfd5c` and include the additional focused tests, and re-opened Issue #2, triggering live run [41046461277](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41046461277). Its preparatory checks and tests have passed; browser acquisition is ongoing.

## Current state

Second real run [41045115672](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41045115672) identified the exact blocker as the original `<img src="/images/ecosystem/apps/github/icon.png">` root-relative first-party ChatGPT icon; the publisher was correctly refusing a path outside its archive. The exporter initially counted only remote absolute image URLs, not same-origin root-relative images, and the saved CDP image index did not contain this static icon. The current PoC now includes bounded exact-origin image retrieval with MIME/signature/size/SHA validation, local HTML replacement and a final check for any remaining absolute image references. Focused unit tests passed in the new workflow's initial test step; the first end-to-end retry failed on Node HTTP status 403 (the image URL was not retrievable); an isolated hosted-runner transport smoke [41047331525](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/41047331525) verified Node fetch returns 200 image/png (9,380 bytes) with an ordinary Chromium User-Agent. The corrected exact-origin fetch is in the new live export attempt; publication remains pending.

## Next action

Await actual run [41047538020](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41047538020). If successful, verify GitHub files/title/date/assets/Issue comment and complete/retire this handoff using two forward commits. If it fails, diagnose the next concrete blocker without relaxing integrity.

## Blockers / open questions

The image endpoint's difference between the default Node User-Agent (403) and the ordinary Chromium User-Agent (200) was observed on the GitHub-hosted runner. The full share publication is still under validation.
