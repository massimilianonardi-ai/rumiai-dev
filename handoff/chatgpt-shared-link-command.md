# ChatGPT shared-link export — one-command packaging

Status: Active
Updated: 2026-10-29

## Goal

Create one user-facing Node.js command that accepts a public ChatGPT shared URL and a new private output directory, orchestrating existing PoC 068 evidence capture, verified +N links, exact local image bodies and singleton links into an inert offline archive.

## Current repository revisions

- `rumiai-dev`: `a75bf9f3847e9ad05aee28fa68060266745ea4e8` (previous handoff checkpoint, before this final revision-reference correction).
- `rumiai-dev-PoCs`: `3066b35127a2dddc71c54259ce708abc45f3a0fb` (README operator-confirmation checkpoint; the exporter itself remains unchanged from `810fbb0`).

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `PHYSICAL-TESTING.md`.
- `specifications/README.md`, `specifications/rumiai-os/WEB-CONTROL.md`, `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`.
- Current PoC 068 implementation, tests and README.

## Fixed task-local choices

- A new packaging task, not re-opening the completed visual PoC.
- Preserve the accepted HTML and limitations; no source React/JavaScript, fabricated source targets, raw capture data in Git or unverified icon fetching.
- Normal caller supplies only a shared URL and a new output directory. Discover grouping/evidence internally; fail closed for unsupported layouts.

## Acceptance scenarios

- An accessible shared URL yields a private script-free HTML directory with exact evidenced source anchors and localized icons.
- Missing or ambiguous evidence refuses output; no partial purportedly complete result.
- Disposable private CDP evidence is removed on success unless explicitly retained.

## Working design

- The existing provenance restorers have evidence/cardinality requirements including a fixed eight-singleton layout. Do not silently relax those or claim general-page production readiness.
- Compose current native CDP modules inside the PoC, not as a new generic web-control provider.

## Completed

- **2026-10-29 operator correction:** the operator explicitly reports that a real export test had already been executed and that its result was perfect. This is affirmative operator-reported real-use validation; it supersedes the previous claim that no real test had been performed. The exact command/revision and private test outputs were not included in this correction; retain the report without misattributing it to an independently recorded run or extending it to untested shares.

- **2026-10-29 GitHub-hosted Ubuntu real-browser acceptance:** added isolated workflow `.github/workflows/poc-068-live-export.yml` in PoCs commit `b24b5184632fc86ab1914ad9b3822681f20bddf4`; successful push-triggered run [40954580470](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/40954580470). Node 22 `npm ci`, syntax checks and all 8 `export-offline` tests passed. The actual `node export-offline.mjs` invoked Chrome headlessly against the public share `6ad1c0f5-7110-83eb-bc19-356d48fc1259`, published its private local output, and returned verified 8 +N groups/19 links, 8 singleton links, 0 remote images, CSP script blocking and 264,928 bytes for `index.html`. The CI job and its browser step succeeded. No private archive, profile, captured payload or HTML was uploaded as an Actions artifact; runner data was ephemeral.

- Added `export-offline.mjs` as a single-invocation Node.js command inside PoC 068; user supplies only an accessible public shared URL and a fresh private output directory. It composes current capture/identity/renderer/icon/local singleton modules and limits targeted source retries. It publishes only a completed, audited archive; errors preserve private diagnostic captures and never publish partial output. `--keep-evidence` retains private captures after success by request.
- Added eight focused tests covering CLI/URL validation, source evidence disambiguation, full mock-boundary orchestration and image retry, failure atomicity, singleton mismatch and optional evidence retention.
- Updated package syntax-check script and PoC README with usage, honest exact-eight-singleton limitations and physical testing requirements. No changes to existing original-CSS rendering modules or the previously accepted archive.
- Git commits `8c27eb7`, `65a7139`, `fc9fabb` and `810fbb0`. The runner also retries a documented `sweep-not-ready` result once with a separate Chrome profile; two fixture tests cover that bounded retry and unrelated failures. V8 parse checks of the current CLI/tests passed; the tool isolate does not provide Node's URL global, so URL validation is **not** considered physically tested. At that original packaging checkpoint, there was no real Node test or single-command Chromium run; the subsequent GitHub-hosted validation below supersedes that pending state for its tested example.

## Current state

The operator-confirmed accepted sample and earlier Ubuntu live acceptance remain unchanged. Those results do not establish general share compatibility.

**2026-10-30 macOS dev export repair (active; publication blocked):** Issue #5 in `rumiai-dev` requests shared URL `6ae4dde6-93a0-83ed-820e-74d0e3f3c9e1`. The original authorized publisher failed without committing an archive. Read-only live Chrome diagnostics, isolated in GitHub-hosted Ubuntu runners, traced the 14–15 unmatched Google icon references to two or three distinct `/s2/favicons` URLs; source variability across runs prevents assuming a stable count. In the latest diagnostic run [41110299094](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/41110299094), Chrome observed 37 matched/15 unmatched references, one conflicting image URL, and for the unmatched resources four `404:image/png` and two `200:image/png` response observations across the captures. A previous scoped no-cookie HTTPS retrieval run failed to retrieve an exact Google favicon. The bounded recovery implementation and SHA-verified additional provenance are available in `rumiai-dev-PoCs@fcdd192eec0b8cc9756b42cb25cfe8b7aa00fe8f`; its 23 focused Node tests passed in the latest run, but the real target export **failed**. No image bytes, profiles, private HTML or raw URLs were published. The `rumiai-dev` publisher still pins its earlier accepted source revision; no retargeting or issue reopen has occurred. No physical validation is claimed.

## Next action

Keep issue #5 unrepublished until both original Google favicon URL(s) can be localized from verified exact bytes without source ambiguity. If independently acquired valid evidence becomes available, rerun the full exporter on the real share; only a successful result may justify pinning the publisher to the tested PoC revision and retriggering the issue. If the original service keeps returning 404 or ambiguous bodies, request an explicit operator decision before any change to the currently strict decorative-image completeness contract.

## Blockers / open questions

- The earlier accepted sample has no blocker; exact details of the operator-reported real run were not independently recorded.
- The macOS dev share remains blocked by 404/unavailable or conflicting evidence for Google favicon URLs (14–15 residual HTML references across runs); the recovery fallback has not passed a live export. The publisher must not substitute icons, drop the unresolved references or publish a partial archive under the current contract.
