# Generic web-page analysis

Status: Active
Updated: 2026-10-17

## Goal

Investigate a generic browser-page analysis workflow, learning from a user's actual demonstration of how to reveal the page's relevant content, then replaying the learned interaction and acquiring browser-native page archives together with CDP DOM/layout/CSS and screenshot evidence.

## Current repository revisions

- rumiai-dev-PoCs: `f3888d510b70974042312634c3f0bd1fcb09738e` (first controlled Chromium fixture and tests in PoC 069)
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
- Removed the failed code, viewers, offline HTML/CSS rewrite, replay scripts, tests, rejected generated conversations, ZIPs, raw capture samples and all other tracked content from the active PoC 068 tree. The final batched forward-only commit `45dd830debe721858bb7f2ca21a4bb10f4ac79c2` deleted 1,263 previously tracked old PoC files, leaving **only** its retired README. Old commits preserve the exact bytes and prior experiment evidence without rewrite. The replacement current tree has no active PoC 068 implementation.
- Created `pocs/069-web-page-analyze/` with HTML/CSS/SVG/JS local fixture, `experiment.py`, browser tests and a strictly local/gitignored evidence destination. No prior PoC 068 source, DOM rewrite or viewer is imported. The first recorder targets the fixture's known `#scrollbox` and infers direction phases from the original event samples; it does not yet generalize across arbitrary page containers.

## Current state

The controlled PoC 069 experiment is implemented but **not accepted for complete-page offline fidelity**. On the actual auxiliary Linux Chromium browser, its controlled embedded-fixture run exercised browser mouse-wheel scroll events: 31 browser-originated trusted scroll samples, phases `down [0→3715]` then `up [3715→0]`, 6 initially rendered items, all 24 available at the bottom and after the return to top; replay ended at `scrollTop=0`. Three MHTML+DOMSnapshot+viewport screenshots were saved locally **inside the auxiliary PoC test folder**. A separate real Chromium CDP test intercepted an independently requested fixture stylesheet via Playwright resource fulfillment and confirmed that MHTML included a distinct `text/css` MIME part at its original absolute web resource location. These tests use real browser/CDP input, **not a browser-URL navigation test**, because this hosted environment's administrator blocks `file://` and loopback `http://` navigations. They do not validate native Chrome `Save Page Complete`, CSS-file-relative offline reopening, or screenshot pixel equivalence.

The `--embedded-host-test` auxiliary option in `experiment.py` intentionally inlines the fixture CSS and JS for the scroll test and reports `nativeCssIncluded:null`. The distinct resource-response test examines browser MHTML packaging without claiming full offline rendering. The default HTTP fixture flow has not been physically validated in the user's VM. All new output targets the current PoC's ignored `evidence/`. Do not touch or restore old PoC 068 exporters, nor the private untracked local evidence on the user's VM.

## Next action

The next bounded gate is **real local-HTTP navigation** to the fixture and direct reopening of Chromium's native MHTML on a host without the auxiliary browser URL policy. Verify CSS/SVG resources and compare native offline rendering against the original screenshot before considering Save Page Complete HTML, any collage generator or broad real-site analysis. The controlled browser test suite is currently defined under `pocs/069-web-page-analyze/tests/`; the user should not be asked to rerun Amazon or ChatGPT at this point.

## Blockers / open questions

- Which native browser archival path provides the most faithful, reliably reopenable offline output for each supported page type?
- How should stable intent, visible checkpoints and state evidence be correlated without altering the user's sequence?
- The auxiliary-host Chromium is verified for wheel/CDP capture but its navigation policy prevents a real locally hosted fixture URL. Stable-host/VM offline-reopen validation is still needed before fidelity acceptance.
