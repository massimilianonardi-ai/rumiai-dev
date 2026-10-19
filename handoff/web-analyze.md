# Chromium manual session analysis — web-analyze

Status: Active
Updated: 2026-10-19

## Goal

Implement the JavaScript library `rumiai-os/lib/sys/js/web-analyze.lib.js` in the technical `m` library tree. It must launch the actual `chromium` executable as resolved in the effective environment (especially the `m` shell), observe a human browsing session, and save highly detailed correlated logs. This is not an independent PoC, package or new `web-control` provider; any overlap with current web-control capabilities must be checked explicitly before implementation.

## Current repository revisions

- rumiai-dev: 586de16c41d4b183b6356cfcbc8648c6b483d250 (pre-checkpoint)
- rumiai-dev-PoCs: 04fe90b77110b5acbd721cb5bc986b3435b97c46 (unaccepted experimental source)
- rumiai-os: f7f35e2ccd56e9c21530f94e28ee9eb5e6d82e0a (not modified)
- pwc-web-control: 2e1759e994f52000975c6383b8cc7b229cd1b425 (read-only reference)

## Applicable canonical sources

README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md, specifications/README.md, specifications/rumiai-os/CURRENT-MODEL.md, FILESYSTEM-NAMING.md, LIBRARY-INTERFACES.md, DOCUMENTATION-MODEL.md, DIAGNOSTICS.md, WEB-CONTROL.md, handoff/README.md.

## Fixed task-local choices

- User-fixed output: `rumiai-os/lib/sys/js/web-analyze.lib.js`, with mandatory matching owner-local operational manual `res/sys/manual/web-analyze.lib.js` and appropriate permanent test coverage.
- The library must launch `chromium` directly through the active executable resolution environment, including when invoked from the `m` shell. The CDP interface is native to Chromium; Playwright is NOT required to enable CDP, launch Chromium or analyze a browsing session.
- Playwright was an unrequested convenience dependency of the discarded PoC implementation; do not introduce it as a requirement without a demonstrated benefit and explicit discussion. The initial technical approach to evaluate is Chromium + native CDP, with an appropriate private transport and an isolated browser profile. Preserve sandbox and TLS verification.
- Log format: multiple append-only JSONL streams with globally ordered sequence, UTC timestamps and process monotonic timestamps, plus summary.
- Avoid logging input contents, raw credentials, cookies, HTTP bodies and WebSocket payloads; redact URL query strings while warning that URL paths can be sensitive.
- No silent evidence overwrite; logs locally private and ignored by Git.

## Acceptance scenarios

1. Through the `m` JavaScript library, a caller starts an HTTP(S) URL by launching actual `chromium` available on the effective `m` PATH, interacts manually with visible Chromium and obtains ordered logs and a summary.
2. Browser navigation, dynamic DOM churn, network activity, console/error events and significant performance entries are observed without application-specific logic.
3. Closing Chromium or stopping explicitly finalizes logs; logging pressure and missing instrumentation are reported instead of falsely asserting completeness.
4. A new session does not overwrite previous evidence; authenticated state stays in dedicated browser profile.

## Completed

- Initial remote preflight and canonical retrieval completed for `rumiai-dev`, PoCs and web-control context.
- Local source package authored in conversation artifact `web-analyze.zip` with reusable module, CLI, DOM observer, privacy-aware EventLog, tests and README.
- Node 22 auxiliary environment: syntax checks for all JavaScript sources/CLI passed; native Node test suite 2/2 passed for redaction, ordering, private file modes and overwrite refusal.
- Published complete reusable library, CLI, tests and documentation in `rumiai-dev-PoCs/pocs/071-web-analyze/`, forward-only revision `04fe90b77110b5acbd721cb5bc986b3435b97c46`. The remote JavaScript module SHA `ec3e74dd93b9219d6b64f85c4c57675c9ce72213` matches the tested local file after a forward correction to two lifecycle event listener lines; other code/tests blobs also match local test sources. Public `web-control` provider repositories and product runtime remained untouched.

## Current state

**User correction (2026-10-19): the PoC 071 implementation is in the wrong repository and introduces an unrequested Playwright dependency.** It is not accepted as the requested `m` library and its tests do not validate that deliverable. Chromium exposes CDP directly, so lack of Playwright is not a valid reason to say Chromium cannot be tested. Current work unit is an explanation-only phase: no product source has been changed yet. The earlier PoC remains factual experimental code, not the required implementation.

## Next action

First explain to the user the concrete advantages/limitations of Playwright versus native Chromium CDP, without implementing the library in this explanation-only phase. When proceeding, inspect the existing `m` libraries/integration and implement `web-analyze.lib.js` in `rumiai-os`, its manual and permanent tests. Validate launch in the `m` environment with real Chromium and explicitly report any host-only validation still pending.

## Blockers / open questions

Real Chromium browser run and visual interaction evidence are pending. No mandatory Playwright dependency exists.