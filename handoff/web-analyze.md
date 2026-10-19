# Chromium manual session analysis — web-analyze

Status: Active
Updated: 2026-10-19

## Goal

Build a standalone reusable JavaScript library named `web-analyze` that launches visible Chromium, observes a human's live navigation and interactions, and saves sufficiently detailed structured timestamped evidence for later behavior analysis. Keep it separate from the ChatGPT shared-link export logic in PoC 069 and from the provider-independent web-control contract.

## Current repository revisions

- rumiai-dev: 07096e23eaa3170419ae5a484bd4dd738c210729 (before this checkpoint)
- rumiai-dev-PoCs: 04fe90b77110b5acbd721cb5bc986b3435b97c46 (published source)
- pwc-web-control: 2e1759e994f52000975c6383b8cc7b229cd1b425 (read-only reference)

## Applicable canonical sources

README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md, specifications/README.md, specifications/rumiai-os/WEB-CONTROL.md, handoff/README.md.

## Fixed task-local choices

- Standalone experimental package `web-analyze` in PoC 071; no premature change to web-control facility/provider compatibility or rumiai-os runtime.
- Browser: visible Chromium, Playwright pinned at 1.63.0, persistent isolated profile, default sandbox and TLS checks enabled.
- Log format: multiple append-only JSONL streams with globally ordered sequence, UTC timestamps and process monotonic timestamps, plus summary.
- Avoid logging input contents, raw credentials, cookies, HTTP bodies and WebSocket payloads; redact URL query strings while warning that URL paths can be sensitive.
- No silent evidence overwrite; logs locally private and ignored by Git.

## Acceptance scenarios

1. User starts an HTTP(S) URL, interacts manually with visible Chromium, stops from terminal; new evidence folder contains ordered logs and summary.
2. Browser navigation, dynamic DOM churn, network activity, console/error events and significant performance entries are observed without application-specific logic.
3. Closing Chromium or stopping explicitly finalizes logs; logging pressure and missing instrumentation are reported instead of falsely asserting completeness.
4. A new session does not overwrite previous evidence; authenticated state stays in dedicated browser profile.

## Completed

- Initial remote preflight and canonical retrieval completed for `rumiai-dev`, PoCs and web-control context.
- Local source package authored in conversation artifact `web-analyze.zip` with reusable module, CLI, DOM observer, privacy-aware EventLog, tests and README.
- Node 22 auxiliary environment: syntax checks for all JavaScript sources/CLI passed; native Node test suite 2/2 passed for redaction, ordering, private file modes and overwrite refusal.
- Published complete reusable library, CLI, tests and documentation in `rumiai-dev-PoCs/pocs/071-web-analyze/`, forward-only revision `04fe90b77110b5acbd721cb5bc986b3435b97c46`. The remote JavaScript module SHA `ec3e74dd93b9219d6b64f85c4c57675c9ce72213` matches the tested local file after a forward correction to two lifecycle event listener lines; other code/tests blobs also match local test sources. Public `web-control` provider repositories and product runtime remained untouched.

## Current state

The complete source is published in PoC 071 and a local ZIP was generated. Node 22 syntax checks and two native event-logger tests pass on an auxiliary host. **No actual Chromium/Playwright end-to-end run has occurred**, because Playwright was unavailable in the auxiliary container despite Chromium being present. No product/runtime or provider contract was changed. An authentic browser session must establish that the event streams and finalization work on an actual GUI workstation.

## Next action

Run a real visible Chromium session on the user's graphical host after installing Playwright, inspect event coverage, error stream, resource response metadata and clean close/finalization, then correct observed gaps only from authentic evidence.

## Blockers / open questions

Real Chromium browser run and visual interaction evidence are pending.