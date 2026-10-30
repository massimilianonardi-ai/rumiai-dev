# ChatGPT public archive resource validation repair

Status: Active
Updated: 2026-10-30

## Goal

Repair and complete the owner-requested public offline export of ChatGPT share `https://chatgpt.com/share/6ae474de-6564-83ed-adc0-f4a73f26a548`, topic `ChatGPT - export`, via `rumiai-dev` Issue #2. Preserve resource integrity and the non-mandatory citation-link policy.

## Current repository revisions

- `rumiai-dev`: `f2f5127dace24dafa6d69b0b9e99ebf897f5ef18` at task preflight.
- `rumiai-dev-PoCs`: `f7567415961bdb4346d4b1bd6319e92679dfb597` at task preflight.
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

- Initial Issue #2 and workflow run [41043087885](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41043087885) failed after 9 tests passed; actual Chrome export ran but `publish-chat-archive.mjs` rejected an unspecified missing/outside local resource. No archive was committed.

## Current state

The current publisher only reports a generic missing/outside resource error; the failing resource identity was not preserved in Actions logs. Need safe diagnostic details before changing resolution semantics.

## Next action

Add a precise local-reference diagnostic and focused regression test, run the job against Issue #2 to discover the failing reference, correct the actual cause, rerun end-to-end and verify the resulting GitHub tree. Sync this handoff at meaningful checkpoints.

## Blockers / open questions

Actual offending reference (HTML attribute vs stylesheet url) still unknown.
