# Generic web-page analysis

Status: Active
Updated: 2026-10-17

## Goal

Investigate a generic browser-page analysis workflow, learning from a user's actual demonstration of how to reveal the page's relevant content, then replaying the learned interaction and acquiring browser-native page archives together with CDP DOM/layout/CSS and screenshot evidence.

## Current repository revisions

- rumiai-dev-PoCs: `6018507fd40b8fdac23f49d0273aedbadc2febc5` (initial clean-up and PoC 069 entrypoint)
- pwc-web-control: `403f4fa9bbea419715e9c834e847c6f2b60ae421` (provider unchanged)
- rumiai-os: `678c83f681125811f1dd9022bea122ef08e97e06` (unchanged)

Read remote HEADs again at next preflight.

## Applicable canonical sources

- `rumiai-dev/README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`
- `specifications/README.md`, `specifications/rumiai-os/WEB-CONTROL.md`
- `specifications/rumiai-os/DIAGNOSTICS.md` when code changes diagnosability
- `rumiai-dev-PoCs/pocs/069-web-page-analyze/README.md` — current experimental working scope

## Fixed task-local choices

1. The user rejected the ChatGPT HTML/Markdown/PDF reconstruction and the generic two-site recorder/replay/viewer path. Their displayed success metrics did not establish content fidelity. These mechanisms **must not be revived as hidden dependencies**.
2. A demonstration can progress toward the end, then backward to the start. The recorder must retain raw action direction, scroll container identity, visible state and sequencing, then infer and validate an explicit intent; a hard-coded forward scan is not a learned replay.
3. Browser-native complete-page archival is a distinct mechanism from `page.content()`, which exposes only rendered DOM serialization and does not rewrite external CSS/image/font references into a complete offline archive.
4. Data/output physically belongs **inside the PoC**. Temporary desktop document-opening aliases are not user-visible archive paths. Do not add ad hoc conversions to hide broken source references.
5. No changes to the existing `web-control` providers unless their currently supported operations prove insufficient by a concrete controlled experiment.
6. Raw user-controlled browser evidence must remain private until individually reviewed. Historical tracked ChatGPT sample archives are rejected as visual evidence.

## Acceptance scenarios

- On a controlled local page with known styles, fonts and content, show the browser's complete native save/archive output and verify that every offline resource reference resolves and renders from its actual PoC location.
- Demonstrate a bottom-to-top scroll of a nested scrolling area and confirm that the learned replay captures the observed direction/order and exposed content. Automatically scanning top-to-bottom instead is a failed test.
- Only after those two scenarios pass, apply the same method to the authorized Amazon wishlist and long ChatGPT shared conversation.

## Working design

Two independent outputs may eventually share the same observation and replay evidence: (a) a general navigable state collage when native fragments cannot safely be merged, and (b) an evidence corpus to develop a site-specific exporter. Neither output is implemented or accepted in the new PoC.

Compare browser-native archives and CDP-derived structural evidence at the **same stable replay checkpoints**; preserve screenshots as independent visual references. Do not add custom HTML/CSS reconstruction while native browser saving remains unvalidated.

## Completed

- Preflight completed against current canonical RumiAI repositories.
- Under PoC 068 removed 15 failed replay, offline-viewer, MHTML-rewriter and unfaithful publication source/test/document files. Removed their package scripts/dependency/command entrypoint. Replaced the misleading 30KB PoC README with a concise retired-scope explanation. Kept verified structured capture research and prior data evidence without asserting visual validity.
- Created `pocs/069-web-page-analyze/README.md` with a clean conceptual experiment, **no source code**. No repository implementation of the new method or user-browser physical test has been performed.

## Current state

The experimental restart is an empty PoC 069 working surface. Do not use prior run counts, page snapshots or the now-deleted viewer as acceptance. Old locally gitignored evidence under PoC 068's `experiments/evidence/` was not accessed or removed from the user's VM, and neither were historically committed sample archives. This is intentional preservation of user data and immutable Git history, **not a claim that all old local files are gone**.

## Next action

On the next implementation work unit, begin with a small local webpage fixture and test how native Chromium complete-page saving differs from DOM serialization. Separately observe and reproduce an explicit bottom-to-top user scroll. Validate each before building a site-wide export.

## Blockers / open questions

- Which native browser archival path provides the most faithful, reliably reopenable offline output for each supported page type?
- How should stable intent, visible checkpoints and state evidence be correlated without altering the user's sequence?
- Physical VM access is required for actual browser validation. All provider limitations must be measured rather than inferred.
