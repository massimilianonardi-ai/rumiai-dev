# ChatGPT shared-link export — one-command packaging

Status: Active
Updated: 2026-10-29

## Goal

Create one user-facing Node.js command that accepts a public ChatGPT shared URL and a new private output directory, orchestrating existing PoC 068 evidence capture, verified +N links, exact local image bodies and singleton links into an inert offline archive.

## Current repository revisions

- `rumiai-dev`: `460eee164e7ee24b94c579a942b5922491f1d691`.
- `rumiai-dev-PoCs`: `5da8a3f3b444c765950e09de68560f27426b1f7d`.

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

## Current state

Preflight done; implement the orchestrator and targeted tests. Real end-to-end Chromium validation remains required.

## Next action

Finish one-command implementation and test from a clean invocation on vmdev. Preserve the previously approved archive.

## Blockers / open questions

- Fresh real end-to-end one-command acceptance is pending.
