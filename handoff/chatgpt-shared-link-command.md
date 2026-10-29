# ChatGPT shared-link export — one-command packaging

Status: Active
Updated: 2026-10-29

## Goal

Create one user-facing Node.js command that accepts a public ChatGPT shared URL and a new private output directory, orchestrating existing PoC 068 evidence capture, verified +N links, exact local image bodies and singleton links into an inert offline archive.

## Current repository revisions

- `rumiai-dev`: `d8955933cc91feca457225ac410317819c662af3`.
- `rumiai-dev-PoCs`: `65a7139da03566d28d4dc2e7a083d21c75601587`.

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

- Added `export-offline.mjs` as a single-invocation Node.js command inside PoC 068; user supplies only an accessible public shared URL and a fresh private output directory. It composes current capture/identity/renderer/icon/local singleton modules and limits targeted source retries. It publishes only a completed, audited archive; errors preserve private diagnostic captures and never publish partial output. `--keep-evidence` retains private captures after success by request.
- Added six focused tests covering CLI/URL validation, source evidence disambiguation, full mock-boundary orchestration and image retry, failure atomicity, singleton mismatch and optional evidence retention.
- Updated package syntax-check script and PoC README with usage, honest exact-eight-singleton limitations and physical testing requirements. No changes to existing original-CSS rendering modules or the previously accepted archive.
- Git commits `8c27eb7` and `65a7139`. Preliminary V8 syntax checks completed; no real Node tests of the new entrypoint and no fresh single-command Chromium run yet.

## Current state

Implementation published for validation. **Not yet physically validated** as a general-purpose command. The underlying PoC output and its known wrapping and inert Fonti limitations remain unchanged.

## Next action

On vmdev, from `pocs/068-chatgpt-shared-link-export`, pull `65a7139`, run `npm install`, `npm run check`, `node --test tests/export-offline.test.mjs`, then exercise `node export-offline.mjs 'https://chatgpt.com/share/6ad1c0f5-7110-83eb-bc19-356d48fc1259' <fresh-private-output-dir>`. Confirm `index.html` opens offline, original CSS/icons, 8 native +N groups/19 HTTPS links and 8 singleton direct links. The single-command flow automatically captures live evidence, may perform multiple fresh Chromium sweeps, and fails closed when original source identity or images cannot be proven. Physical failures do not invalidate the previously accepted multi-step archive. Keep generated capture data and HTML private; do not commit evidence.

## Blockers / open questions

- Fresh real end-to-end one-command acceptance is pending.
