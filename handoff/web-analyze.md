# Chromium manual session analysis — web-analyze

Status: Active
Updated: 2026-10-19

## Goal

Build a standalone reusable JavaScript library named `web-analyze` that launches visible Chromium, observes a human's live navigation and interactions, and saves sufficiently detailed structured timestamped evidence for later behavior analysis. Keep it separate from the ChatGPT shared-link export logic in PoC 069 and from the provider-independent web-control contract.

## Current repository revisions

- rumiai-dev: dff3eeb7531fc6f6878e7ac1710db0fa9e17800d (pre-write)
- rumiai-dev-PoCs: 0c34ce468a46f3fddc4d80fb25ecc798209f75f5 (pre-write)
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
- Node 22 auxiliary environment: syntax checks for JavaScript sources and CLI passed; native Node test suite 2/2 passed for redaction and isolated ordered log streams.

## Current state

The local conversation artifact is usable after installing declared Playwright dependency, but **no actual Chromium/Playwright end-to-end run has occurred**; Playwright is unavailable in the assistant container. Git repository publication of the source and browser validation remain to be completed. No product/runtime or provider contract was changed.

## Next action

Publish the locally tested source in PoC 071, review resulting diff/source, then run a real visible Chromium session on the user's graphical host and inspect log coverage and close/finalization behavior.

## Blockers / open questions

Real Chromium browser run and visual interaction evidence are pending.