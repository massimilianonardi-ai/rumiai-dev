# Generic web-page analysis — two real-site live PoC

Status: Active
Updated: 2026-10-17

## Goal

Develop and physically validate a general browser observation/replay method using the user's **two actual authorized pages**, preserving human scroll direction/sequence and acquiring native Chromium MHTML plus correlated CDP evidence. User explicitly rejected more synthetic fixtures/CI and requested **one live VM experiment**.

## Current revisions

- `rumiai-dev-PoCs` HEAD: `cd2a247efdc068fa77cf8911507c5abe4ce195b5`.
- `pwc-web-control` HEAD: `403f4fa9bbea419715e9c834e847c6f2b60ae421` (unchanged).
- `rumiai-os` HEAD: `cfb732b1bc8d88b1bc14cd97cb399e5d0cb0070d` (unchanged).
- Revalidate HEADs at the next work unit before reading or changing code.

## Canonical read order

`rumiai-dev/README.md`, `RULES.md`, `CONSISTENCY-GATE.md`,
`specifications/README.md`, `specifications/rumiai-os/WEB-CONTROL.md`,
`TESTING.md`, then this handoff and current PoC sources.

## Fixed task-local requirements

1. **No synthetic fixture or further CI experiments as a substitute for the authorized real-site run.** The latest user requested the PoC be built from zero around:
   - `https://www.amazon.it/hz/wishlist/ls/33ZKBWLPZJJVO?ref_=list_d_wl_lfu_nav_3`
   - `https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835`
2. Browser capture and replay must use the real visible user-controlled browser; first observe, then infer interaction phases and replay. Preserve input direction and reversals, especially `down → up`; never replace them with a fixed forward-only scan.
3. **Every persistent artifact and temporary file's actual data lives under PoC 069**, even when a short-lived Unix socket or symlink is required for Chromium/IPC pathname limits. Do not generate any desktop file-portal URI as an artifact reference.
4. Use the existing, unchanged `pwc-web-control` provider to execute deterministic browser actions and CDP. Experimental interpretation belongs to this PoC, not the provider.
5. Store native `Page.captureSnapshot` MHTML **unmodified**, raw `page.content()` DOM HTML clearly labeled as non-self-contained, CDP DOMSnapshot/computed CSS, and Chromium viewport screenshots. For each state, *directly reopen MHTML by Chromium navigating to its PoC file URI* and capture a second screenshot. Do not create a speculative HTML/CSS resource rewriter or hand-built source renderer.
6. Keep account/session/browser evidence private and gitignored. No GitHub commit of browser outputs or credentials. Visual completeness is never inferred from counts or file transport success.

## Current implementation

PoC 069 was rebuilt as a **live real-site experiment** on current main:

- `run-live.sh <new-run-name>`: one interactive entrypoint; clones pinned current PWC source into ignored PoC `.runtime/pwc` on first use, installs provider Playwright runtime, starts an isolated visible browser/profile, waits for readiness, runs four local action-plan tests and then the real two-site trial. Does not switch installed `web-control` providers or user browser profiles.
- `observe.js`: instrument the current page's trusted wheel/scroll/disclosure actions; store direction, scrollable container selector, extent and event order, without reading typed input/cookies.
- `live.mjs`: infer ordered direction phases and safe disclosure boundaries; recreate each page and align its initial position to the observed start; move **in inferred phase direction** through viewport-sized steps; capture native MHTML, raw DOM, CDP DOMSnapshot/CSS and viewport PNG. For each MHTML use the existing PWC browser to reopen its **real PoC-local file URI** and save `reopened.png`, reporting failure. Creates screenshot-only `comparison.html` using relative PoC paths and opens that file directly in the visible browser for manual side-by-side review, asking Enter before proceeding to next site. No modified source HTML or CSS presentation is created.
- `tests/live.test.mjs`: covers real-event phase construction, down/up reversal, initial mid-page/up traversal, scroll-delta-only fallback, and disclosure ordering. Static V8 parsing and four test bodies in an isolate passed in this work unit, but these are **not** a physical browser validation.
- `evidence/` and `.runtime/` are gitignored. Prior fixture files/CI and both superseded PoC 068 workflows were removed from current main as part of the requested clean rebuild. Older commits remain in forward-only Git history.

## Live-01 physical findings and corrective live-02 change (2026-10-17)

User physically ran `sh run-live.sh live-01` on the VM: visible PWC `[PWC_READY]`, existing four tests 4/4 PASS. Amazon demonstrated `down→bottom`, replay scrolled monotonically 98→14400 and generated/opened screenshot comparisons. **However, original intermediate screenshots showed the page beginning instead of the actual scroll checkpoint.** ChatGPT demonstrated `down→bottom, up→position, down→position, up→top` but failed `replay.start-position-was-restored-or-drifted` and closed without its comparison. These were verified operator observations, not accepted source fidelity. User positively validated the experiment organisation and screenshot comparison UI, and explicitly requested additionally opening the single overall exported MHTML directly in Chromium.

Current PoC HEAD after forward-only source and regression revisions: `ff49f9f5e0c5b0c87ff872d26ef50d0090f409e7`.

**Source-grounded failure mechanisms and changes** (`pocs/069-web-page-analyze/live.mjs`):
1. Before, each `original.png` was taken **after** native MHTML and CDP DOMSnapshot, while the PoC also repeatedly created/closed temporary tabs for each MHTML. The revised code `Page.bringToFront`s the true replay tab, aligns its intended scroll, and captures the online viewport screenshot **before** MHTML/DOM. It records before-focus, before-screenshot, after-screenshot and after-archive positions; the `[STATO]` log reports native-archive drift rather than inferring that replay scroll deltas were wrong.
2. The native MHTML viewer starts with a fresh browser scroll offset (the MHTML does not preserve live `scrollTop`). The revised reopening routine scrolls the saved MHTML page to the corresponding screenshot position based on the original scroll extent before taking `reopened.png`. It separately records `offlinePositionAligned`; it then returns focus to and stabilizes the **actual** replay tab before continuing. Restore failure is retained as an explicit gap rather than hidden.
3. ChatGPT's SPA can asynchronously restore its scroll after navigation. Initial extent is now observed until stable or bounded timeout; starting position alignment is retried with observed geometry/late scroll restoration, rather than aborting immediately after one displaced sample. A failed alignment is recorded and marks replay incomplete; it does **not** prevent partial screenshots and review pages. Exception handling in replay also preserves already acquired checkpoints and marks `executionError`.
4. New `overall/page.mhtml` is a **single native final-DOM snapshot** acquired after the replay's demonstrated phases, not a stitched claim of full content across virtualized states. Its `manifest.json` explicitly says previous virtualized elements may be absent. After the existing screenshot comparison prompt, Chromium opens this native MHTML using its exact PoC-local file URL for user inspection. Source MHTML bytes are never rewritten and no desktop portal is invoked.

Native MHTML reopening now uses a controller-owned persistent CDP debugging session with `Network.enable` and `Network.setBlockedURLs` for HTTP(S) throughout both the per-state and overall-MHTML file navigation. This prevents silently fetching CSS/images from live sites during the offline visual comparison; CDP session and tab are closed afterward. Screenshot diagnostics now distinguish intended, before-focus, screenshot-time, after-screenshot and after-native-archive scroll positions. `replay()` preserves partial screenshots/comparison even if a later phase throws. A bounded initial scroll-extent settling observation was also added for lazy ChatGPT initialization. These mechanics still require physical validation of provider support and the resulting screenshots.

The `tests/live.test.mjs` PoC checks have two added cases for deferred SPA scroll restoration and for a target beyond the currently available scroll extent. Six fixture-independent test bodies passed **in a V8 evaluation shim**, and revised `live.mjs` parses; **full native Node tests and the two-site physical `live-02` experiment have NOT run yet**. The prior physical 4/4 test pass belongs only to `live-01` revision.

The next physical action is a new immutable evidence run from PoC 069:
`git pull --ff-only && sh run-live.sh live-02`. Check the `[STATO]` lines for Amazon: intended/original scroll must increase with the replay instead of resetting to 0, and any archive-induced shift must be visible in the capture metadata. For ChatGPT, check `[ALLINEAMENTO]` and whether partial or complete screenshot comparison and final overall native MHTML open even with SPA auto-scroll. Review source-vs-reopened MHTML rendering. Nothing new is pushed from private `evidence/` to GitHub; old `live-01` evidence is preserved.

## Live-02 CSS regression — operator interim observation (2026-10-17)

During the user's **still-in-progress** physical `live-02` trial, they reported that Amazon's screenshots and the final opened MHTML appeared **unstyled or visually distorted**, whereas the MHTML in `live-01` had looked good. Treat this as **unaccepted negative interim evidence**; no live-02 final terminal report, per-checkpoint manifests, PNGs, or MHTML bytes have yet been reviewed. Do not mark the new browser/export flow as successful.

Current PoC source explicitly attaches a persistent per-page CDP debugger session and calls `Network.setBlockedURLs` with `http://*` and `https://*` **before** opening each MHTML (`reopen` and `showOverall`). Chromium MHTML MIME `Content-Location` identifiers may still carry original HTTP(S) resource URLs; it is a plausible, **not yet established**, hypothesis that the blanket block interferes with native in-archive resource resolution. Crucially, this per-page block should not explain missing CSS in the separate **online** `original.png` without another mechanism. The current live capture already records `original.png`, `reopened.png`, original/checkpoint scroll offsets, `capture.json`, and `offline.json` to distinguish these mechanisms.

**Do not ask the user to interrupt or rerun the still-running experiment.** Do not change the PoC source based only on this intermediate symptom. When the user returns with the completed results, distinguish online vs reopened CSS failures, inspect `archivedCssParts` and actual per-site logs, and make one evidence-grounded forward fix. Keep native MHTML unmodified, preserve prior private `live-01` and `live-02` evidence, and do not revive ad hoc CSS converters/viewers or synthetic substitution tests.

## Validation state

The current direct live implementation has **not yet been physically executed on the user's VM**. Earlier physical runs of PoC 068 had broken HTML/CSS/resource viewing and replay behaviors; they are not acceptance of this new revision. No output archives have been committed or verified on the two real sites in PoC 069. `comparison.html` is only a visual screenshot comparison, not a site recreation.

## Exact next action

Execute a fresh live physical trial in the user's VM with `sh run-live.sh live-02`, after `git pull --ff-only`. Preserve `live-01` as negative evidence. Inspect original intermediate scroll screenshots and reopened image position, ChatGPT alignment/replay diagnostics, and the final overall MHTML opened directly in Chromium. Do not claim complete content fidelity until the operator reviews these on the VM.

## Known limitations to inspect

- The current observer chooses the most active scroll container, not all nested containers; `otherContainers` is recorded as a coverage gap.
- Dynamic SPA navigation may reset an in-page observer, which must fail explicitly instead of silently claiming coverage.
- Some disclosure actions are intentionally skipped if not safe or visible in replay, and should be listed as gaps.
- Native MHTML can retain original HTTP URLs as `Content-Location` identifiers; these are MIME resource identities, not paths to external exported files. The only public-facing comparison HTML uses relative local PNG paths.
- Native MHTML offline fidelity and page content completeness require actual user review, not a mechanical `complete` flag.
