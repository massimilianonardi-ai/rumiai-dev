# historical-pending-recovery

Status: Active
Updated: 2026-09-17

## Goal

Perform a one-time deliberate recovery of RumiAI work that was historically recognized as unfinished before the current `todo/` lifecycle existed, and repopulate only the items that are still genuinely open in the current project.

Historical material is used only to discover candidates. Every candidate must be verified against current authoritative documentation, implementation and tests before a current TODO is created.

## Current repository revisions

```text
rumiai-dev    4fb602eea0db52dab394b1b1d5172ab76f6ac985  (pre-activation HEAD)
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
```

Add subsystem specifications only when a recovered candidate reaches their responsibility.

## Fixed task-local choices

- This task is explicitly authorized to inspect Git history because its purpose is historical recovery.
- Historical commits, removed handoffs and superseded documents are candidate-discovery sources only; they do not become current authority.
- A candidate becomes a current TODO only after current repository state confirms that the work remains materially open.
- Resolved, superseded, duplicated, vague or no-longer-relevant historical items are not restored.
- Recovery itself does not implement or debug the recovered work; it creates minimal `todo/<topic>.md` entries for later activation.
- One TODO should represent one coherent future workstream. Broad historical topics may be split only when current evidence shows independently activatable responsibilities.
- Topics already represented by an active handoff are not duplicated in `todo/`.
- No historical archive directory will be recreated. Git history remains the archive.

## Completed

- The missing known-but-not-active lifecycle layer was identified through `workflow-optimization`.
- The user approved `todo/` as the canonical deferred-work surface and explicitly approved a one-time historical inspection.
- Current remote HEADs of the repositories most likely involved in recovered work were retrieved before activation.

## Current state

The recovery task is active. The pre-reset `rumiai-dev` history and historical handoffs/documents have not yet been classified under the new TODO lifecycle.

Known examples such as real `pkg install` validation/debugging and broad `rumiai-tests` realignment are only candidate hints until verified through the deliberate recovery procedure.

## Next action

1. inspect the pre-reset documentation tree and removed active/historical handoffs for explicit unfinished/pending work;
2. group candidate topics without treating old wording as authority;
3. verify each candidate against current specifications, implementation and tests;
4. create minimal current TODO files only for candidates still open;
5. run the documentation consistency gate and close this recovery handoff through the normal final-snapshot/delete lifecycle.

## Blockers / open questions

None.