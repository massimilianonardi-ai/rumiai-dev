# ChatGPT shared-link export — one-command packaging

Status: Complete
Updated: 2026-10-31

## Goal

Deliver and validate the operator-authorized public ChatGPT shared-link offline
export workflow documented canonically in `chats/README.md`. The workflow
must preserve visible conversation content and substantive image integrity,
allow inert citations and exclude citation/link decorative icons, prohibit
original JavaScript and partial Git publication, and support longer virtualized
conversations within bounded capture.

## Current repository revisions

- `rumiai-dev`: `725d9d21f4693225963352470fc6c8c7bd9a7e87` (published computer use archive, before final handoff closure).
- `rumiai-dev-PoCs`: `3712dc38ad2a39cfef330ad549a67c1a67634d7b`
  (successfully validated updated exporter pinned by the publisher).

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `PHYSICAL-TESTING.md`.
- `specifications/README.md`, `specifications/rumiai-os/WEB-CONTROL.md`, `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`.
- Current PoC 068 implementation, tests and README.

## Fixed task-local choices

No unresolved task-local architecture or publication choices remain.
`chats/README.md` is the canonical continuing contract; archived handoff
details are revision-specific evidence, not a second source of current rules.

## Acceptance scenarios

- An accessible shared URL yields a private script-free HTML directory with exact evidenced source anchors and localized icons.
- Missing or ambiguous evidence refuses output; no partial purportedly complete result.
- Disposable private CDP evidence is removed on success unless explicitly retained.

## Working design

None. Earlier source-card/singleton-restoration candidates are not part of
the citation-independent integrated export contract and have not been promoted.

## Completed

- **2026-10-29 operator correction:** the operator explicitly reports that a real export test had already been executed and that its result was perfect. This is affirmative operator-reported real-use validation; it supersedes the previous claim that no real test had been performed. The exact command/revision and private test outputs were not included in this correction; retain the report without misattributing it to an independently recorded run or extending it to untested shares.

- **2026-10-29 GitHub-hosted Ubuntu real-browser acceptance:** added isolated workflow `.github/workflows/poc-068-live-export.yml` in PoCs commit `b24b5184632fc86ab1914ad9b3822681f20bddf4`; successful push-triggered run [40954580470](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/40954580470). Node 22 `npm ci`, syntax checks and all 8 `export-offline` tests passed. The actual `node export-offline.mjs` invoked Chrome headlessly against the public share `6ad1c0f5-7110-83eb-bc19-356d48fc1259`, published its private local output, and returned verified 8 +N groups/19 links, 8 singleton links, 0 remote images, CSP script blocking and 264,928 bytes for `index.html`. The CI job and its browser step succeeded. No private archive, profile, captured payload or HTML was uploaded as an Actions artifact; runner data was ephemeral.

- Added `export-offline.mjs` as a single-invocation Node.js command inside PoC 068; user supplies only an accessible public shared URL and a fresh private output directory. It composes current capture/identity/renderer/icon/local singleton modules and limits targeted source retries. It publishes only a completed, audited archive; errors preserve private diagnostic captures and never publish partial output. `--keep-evidence` retains private captures after success by request.
- Added eight focused tests covering CLI/URL validation, source evidence disambiguation, full mock-boundary orchestration and image retry, failure atomicity, singleton mismatch and optional evidence retention.
- Updated package syntax-check script and PoC README with usage, honest exact-eight-singleton limitations and physical testing requirements. No changes to existing original-CSS rendering modules or the previously accepted archive.
- Git commits `8c27eb7`, `65a7139`, `fc9fabb` and `810fbb0`. The runner also retries a documented `sweep-not-ready` result once with a separate Chrome profile; two fixture tests cover that bounded retry and unrelated failures. V8 parse checks of the current CLI/tests passed; the tool isolate does not provide Node's URL global, so URL validation is **not** considered physically tested. At that original packaging checkpoint, there was no real Node test or single-command Chromium run; the subsequent GitHub-hosted validation below supersedes that pending state for its tested example.

- **2026-10-31 computer use acceptance and publication:** The initial and
  immediately retried publisher runs [41181630821](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41181630821)
  and [41184266527](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41184266527)
  failed with exit 3, initially reported as missing DOM readiness. Private-safe
  diagnostics showed that both basic and full capture modes did recognize
  approximately 141 conversation wrappers, but traversed only about 41k of
  over 218k CSS pixels in 85 seconds; the six-minute sweep limit and conflated
  timeout/readiness diagnostics were the relevant problem. PoC 068 revision
  `3712dc38ad2a39cfef330ad549a67c1a67634d7b` applies overlapping
  85%-viewport steps with 220 ms settlement, separates timeout (exit 5)
  and disconnected (exit 6) from missing DOM (exit 3), and verifies that
  the virtualized fixture retains all 16 turns. The real browser fixture
  workflow [41185803386](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/41185803386)
  passed. The actual target export [41185803537](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/41185803537)
  passed with 140 rendered turns, zero missing ordinals, 0 remote images,
  script-blocking policy, 14/14 scoped tests and recorded sweep completion.
  The official issue #8 was reopened after pinning that revision, and
  [publisher run 41186135521](https://github.com/massimilianonardi-ai/rumiai-dev/actions/runs/41186135521)
  succeeded. The archive is
  `chats/computer use/2026-08-29 Computer Use - Piano P5A P5E/index.html`;
  its 23 local assets and audits were verified through the repository API,
  and issue #8 has the success link. No partial archive was committed and
  no RAW conversation completeness or operator-host physical validation
  is claimed.

## Current state

Completed. Issue #8 has a verified published offline archive. The official
GitHub publisher pins the tested exporter revision. Existing chat archives
and concurrent unrelated repository changes were preserved.

## Next action

None for this task. Future opt-in exports use the canonical
`chats/README.md` process and a separate authorized request.

## Blockers / open questions

None blocking this task. Offline visible-HTML archives do not certify RAW
conversation completeness, pixel-identical rendering or physical operator-host
acceptance.
