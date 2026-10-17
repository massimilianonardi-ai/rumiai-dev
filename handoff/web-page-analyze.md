# Generic web-page analysis — real Amazon + ChatGPT live PoC

Status: Active
Updated: 2026-10-17

## Goal and authority

Investigate whether visible Chromium sessions can learn the user's real navigation intentions and acquire faithful native MHTML + CDP evidence for these **two specifically authorized real pages**:

- Amazon Wishlist: `https://www.amazon.it/hz/wishlist/ls/33ZKBWLPZJJVO?ref_=list_d_wl_lfu_nav_3`
- Long ChatGPT share: `https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835`

The user explicitly rejected fixture/CI substitutes, unfaithful reconstructed HTML/CSS, and any exported references through transient desktop portals. Their current correction is: **preserve ChatGPT start alignment from `live-02`, revert the new MHTML visual regression so reopening behaves as in `live-01`, and continue the physically reviewed live-site path**.

Before any task, verify remote HEADs and read `rumiai-dev/README.md` mandatory read order, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/WEB-CONTROL.md`, `specifications/rumiai-os/DIAGNOSTICS.md` where applicable, `TESTING.md`, this handoff, and current code/tests. Do not treat this handoff or prior commits as normative.

## Repositories / current revision snapshot

- `massimilianonardi-ai/rumiai-dev-PoCs` current HEAD at update: `1bd4c4de8bb38bbfa92126d8bb19fc27bb8420b1`.
- `massimilianonardi-ai/pwc-web-control` baseline HEAD: `403f4fa9bbea419715e9c834e847c6f2b60ae421` (provider unchanged).
- `massimilianonardi-ai/rumiai-os`: not modified.
- Revalidate all involved HEADs before resuming, including any concurrently advanced branches.

## Fixed task-local constraints

1. Current PoC source: `rumiai-dev-PoCs/pocs/069-web-page-analyze/`. Runs use `sh run-live.sh <fresh-name>`, a visible isolated `pwc-web-control` Chromium profile, and only the two user-authorized real URLs.
2. Preserve actual wheel/scroll/disclosure event sequence, its container and direction. Intent phases including `down→up` must survive inference and replay. Dynamic counter-scroll must be measured and handled with bounded **same-direction** correction, never silently interpreted as learned user input.
3. All real capture files, screenshots, MHTML, DOM snapshots, browser runtime and logs remain under the PoC; only short-lived Unix IPC socket/alias filenames may exist outside due to Linux socket-path limits. No desktop file manager/portal links are generated.
4. Preserve native `Page.captureSnapshot` MHTML unchanged; `page.html` from `page.content()` is **not** complete offline HTML. Capture CDP DOMSnapshot and viewport screenshots separately. The screenshot comparison HTML uses only PoC-relative PNGs. No fake renderer, custom CSS rewriter or MHTML stitching is authorized.
5. Chromium opens original native per-checkpoint and final `overall/page.mhtml` directly. A final MHTML is **one live final-DOM state**, not a union of dynamically removed/virtualized nodes. Account data and evidence are gitignored and never automatically published.
6. Mechanical `complete:true` never establishes actual visual fidelity, correct stylesheet loading, or complete chat content. Accept only what the user physically inspects on their VM. All Git changes are forward-only.

## Actual physical evidence

### live-01 (pre-2026-10-17 corrective revision)

The user's visible Chromium run passed four plan unit tests, captured Amazon's `down→bottom` replay, and opened screenshot comparisons. The original intermediate scroll screenshots appeared at the page beginning, but the user explicitly confirmed **the native MHTML opened and looked correct with CSS**. ChatGPT's initial scroll alignment failed before replay and no comparison completed. Those are partial/negative outcomes, not a successful exporter.

### live-02 (2026-10-17; full supplied terminal log, 167 lines)

The user ran `git pull --ff-only && sh run-live.sh live-02`, PWC initialized and six plan/alignment tests passed.

- **Amazon:** user demonstration `down→bottom, up→top`. Automatic replay produced checkpoints `0000..0038`, progressing from `119` to `14882` and returning to `0`. Every printed `intended`, `beforeFocus`, `screenshotTop`, `afterScreenshot`, `afterArchive` matched; source scroll was restored and native MHTML viewport alignment was reported true. The program printed `[ESITO] amazon-wishlist captured`, but the user saw **incorrect/missing CSS both in screenshot comparisons and the opened overall MHTML**. Therefore Amazon's **visual result was rejected** even though the scroll coordinate gate passed.
- **ChatGPT:** user demonstration `down→bottom, up→top`. Initial replay successfully aligned near the bottom (`start=26941, reached=26925, stable=true`), acquiring checkpoints `0000..0016` while rising from `26925` to `13242`. There the site caused a reverse-direction scroll and the replay stopped with `replay.opposite-direction`. Its partial comparison and native final MHTML did open, but the user confirmed the **same broken-CSS rendering** as Amazon. The source content was not fully traversed; result `incomplete`.

The user's latest correction: **keep this successful ChatGPT starting alignment and the direction-aware replay, restore the visually correct MHTML opening from live-01, and fix the ChatGPT mid-replay opposite-direction interruption.**

The assistant cannot inspect private raw `evidence/live-01/` or `live-02/` MHTML/PNG on the user's VM. The terminal log proves scroll coordinates and where replay stopped, not which exact CSS resource failed.

## Forward-only changes for next live-03

In current PoC `live.mjs`:

- Removed the entire experimental persistent CDP `Network.setBlockedURLs` mechanism from both `reopen()` and `showOverall()`. The user visually accepted `live-01` reopening without that blocker; CSS broke in `live-02`, which added it. This is a **strong regression suspect, not a proven single root cause**. Chromium now reopens native MHTML as in `live-01`. Consequently **network-independent offline resource completeness is NOT verified** in this version: do not describe the reopened view as offline-isolated.
- Kept the `live-02` ChatGPT scroll-extent settling and bounded initial `stabilizePosition()` alignment; retained the per-step capture, source scroll restoration, screenshot comparison, and separate overall MHTML opening.
- When a dynamic page moves contrary to the requested direction (or a step makes no progress), attempt up to four further moves **in the planned direction**, using current geometry and updated destination. Record each disturbance and whether recovery succeeded under `report.replay.disturbances`. If none succeeds, record one incomplete scroll-phase outcome and retain partial visual evidence; never incorrectly call that phase complete.
- `capture.json` now records a small `liveStyles` summary (stylesheet/link counts and computed body styles), and `offline.json` records comparable reopened styles with `networkIsolationVerified:false`. This distinguishes missing CSS in an original online screenshot from incorrect reopening, without altering source HTML/CSS.
- Current PoC `README.md` documents exact `live-02` physical failures and scoped `live-03` behavior. Prior private evidence is immutable; use a fresh run name.

## Validation and next action

Source diff / V8 grammatical parsing plus the six existing JavaScript logic test bodies exercised in a V8 shim **passed** during this work unit. This is not a real Node/PWC browser validation. No new `live-03` physical run has occurred; MHTML CSS fidelity after the rollback remains unverified.

Next user live run (only when ready): from `pocs/069-web-page-analyze/`,
`git pull --ff-only && sh run-live.sh live-03`.

Review two questions separately: (1) does each original and reopened MHTML view return to the CSS fidelity the user observed in `live-01`? (2) does ChatGPT continue upward past `13242`, with any dynamic scroll corrections logged rather than hidden? Preserve raw private files; user should share only short terminal diagnostics and relevant `capture.json`/`offline.json` summaries, not account data.

No modifications to `pwc-web-control`, `rumiai-os`, `rumiai-tests` or other product sources. The current PoC remains experimental, without visually accepted full export.
