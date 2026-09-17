# historical-pending-recovery

Status: Active
Updated: 2026-09-17

## Goal

Perform a one-time deliberate recovery of RumiAI work that was historically recognized as unfinished before the current `todo/` lifecycle existed, and repopulate only the items that are still genuinely open in the current project.

Historical material is used only to discover candidates. Every candidate must be verified against current authoritative documentation, implementation and tests before a current TODO is created.

## Current repository revisions

```text
rumiai-dev    45234f56e0d140f4614bcaea5109d92f9b05a4c0  (latest reconciled HEAD before this checkpoint)
rumiai-os     36c29d8412a523f722fd90004b78a07fdf0b06c8
rumiai-tests  298931c1dca03d44755893d64b9b3a7c0058b7ea
pkg-catalog   94f58995cbd487b17f3b82bc2724c70540927b88
```

Fresh remote HEAD retrieval remains mandatory before writes or current-state conclusions.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
todo/README.md
handoff/README.md
specifications/README.md
TESTING.md
TEST-PATTERNS.md
specifications/rumiai-os/PACKAGE-MODEL.md
```

Additional subsystem specifications were consulted only when required to classify a historical candidate.

## Fixed task-local choices

- This task is explicitly authorized to inspect Git history because its purpose is historical recovery.
- Historical commits, removed handoffs and superseded documents are candidate-discovery sources only; they do not become current authority.
- A candidate becomes a current TODO only after current repository state confirms that the work remains materially open.
- Resolved, superseded, duplicated, vague or no-longer-relevant historical items are not restored.
- Recovery itself does not implement or debug the recovered work; it creates minimal `todo/<topic>.md` entries for later activation.
- One TODO represents one coherent future workstream. Broad historical topics are split only when current evidence shows independently activatable responsibilities.
- Topics already represented by an active handoff are not duplicated in `todo/`.
- No historical archive directory is recreated. Git history remains the archive.

## Completed

- The missing known-but-not-active lifecycle layer was identified through `workflow-optimization`.
- The user approved `todo/` as the canonical deferred-work surface and explicitly approved a one-time historical inspection.
- `README.md`, `CONSISTENCY-GATE.md`, `todo/README.md` and `handoff/README.md` now define the deferred-work lifecycle and activation boundary.
- The pre-reset documentation/handoff tree at `11103af65669b8d4fbf4bc8ded2f2515a347b9ef` was deliberately inspected for unfinished/pending historical work.
- Historical candidates were compared against current specifications, current `rumiai-tests` implementation and current active handoffs rather than restored from old wording alone.

### Recovered current TODOs

Two independently activatable current gaps were confirmed and written as minimal TODOs:

```text
todo/pkg-install-real-validation.md
todo/rumiai-tests-suite-realignment.md
```

`pkg-install-real-validation` is current-confirmed because `PACKAGE-MODEL.md` and `TESTING.md` require real composed public-path coverage, while current `tests/rumiai-os/pkg/install.test` still replaces target pipeline responsibilities with test-built components. The future task must exercise and debug the real path rather than assuming in advance whether the defect is product-side or test-side.

`rumiai-tests-suite-realignment` is current-confirmed because current shared target/fixture libraries and `TEST-PATTERNS.md` define reuse/complete-replica expectations, while representative current tests still contain historical inline copies or reconstructed target infrastructure. The TODO is deliberately an audit/realignment task and does not assume every existing test requires modification.

### Historical candidates deliberately not restored

- **runner persistence/snapshot**: the historical `2026-08-29-rumiai-test-persistence-snapshot-contract-handoff.md` described work that is now present in current `RUNNER.md`, the current `rumiai-test` implementation and permanent runner tests. It is resolved, not deferred work.
- **resource/srv remediation**: historical failure/remediation handoffs show that the test-side corrections were subsequently made; representative current tests retain those corrections. The remaining historical physical-validation gate referred to old revision pairs and is not restored as a current TODO without a current requirement for that exact validation.
- **`mk` development**: current work is already represented by the active `handoff/mk-tool-development.md`, so creating a TODO would duplicate active task state.
- **older bootstrap, shell, naming, CLI, language/log and physical-pass handoffs**: the historical set is largely followed by pass/complete/consolidated work and/or represented by current canonical specifications and implementation. No independent current gap was established strongly enough to justify restoring them merely from historical intent.
- **historical testing-structure topics**: current evidence of remaining legacy patterns is consolidated into `todo/rumiai-tests-suite-realignment.md` rather than recreating multiple overlapping historical test TODOs.

## Current state

The historical candidate classification and current verification are complete. The recovery produced two current TODO items and intentionally rejected historical items that are resolved, superseded, already active or insufficiently supported by current evidence.

Concurrent work added `handoff/service-model.md` during the recovery; it was preserved through forward reconciliation and is unrelated to the recovered TODOs.

## Next action

Run the final documentation/consistency checks for the new TODO lifecycle and recovered items, synchronize `workflow-optimization` with the reusable workflow result, then close this handoff through the final-snapshot/delete lifecycle.

## Blockers / open questions

None.