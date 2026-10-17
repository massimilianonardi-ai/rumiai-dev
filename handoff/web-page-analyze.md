# Generic web-page analysis — live Amazon + ChatGPT

Status: Active
Updated: 2026-10-17

## Current authority and retrieval

Before analysis/modification always verify current remote HEADs; follow `rumiai-dev/README.md` Mandatory Read Order: `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, current `specifications/rumiai-os/WEB-CONTROL.md`, `DIAGNOSTICS.md` if applicable, `TESTING.md`, this handoff, current PoC implementation and tests. Explicit user corrections are higher authority than this task-state checkpoint. Do not read Git history by default.

Latest PoC HEAD at this checkpoint: `127c3628c23a979b04ee0c5a59bc9371cc0c6bc0`; PWC baseline HEAD: `403f4fa9bbea419715e9c834e847c6f2b60ae421`. Revalidate at next work unit.

## Purpose and user-fixed requirements

Capture and interpret a human's actual browser navigation through two explicitly authorized pages:

- Amazon Wishlist `https://www.amazon.it/hz/wishlist/ls/33ZKBWLPZJJVO?ref_=list_d_wl_lfu_nav_3`
- Long ChatGPT share `https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835`

Use the existing `pwc-web-control` provider in an isolated visible Chromium, under `rumiai-dev-PoCs/pocs/069-web-page-analyze/`. Preserve observed wheel/scroll direction and sequencing (`down→up` included). Replay inferred phases, capture original native MHTML and CDP DOM/layout/CSS plus viewport screenshots, and compare original browser vs direct Chromium MHTML reopen. Do **not** regenerate/merge modified MHTML or rewrite CSS. `page.content()` is raw DOM serialization, not standalone complete HTML.

All browser profiles, evidence, generated comparative views and any other persistent files physically stay **inside this PoC**, gitignored. A short-lived runtime socket filename/alias outside the PoC may be needed due to Unix socket pathname limits, but never becomes an artifact path. Do not automatically upload raw evidence, user content or credentials. Git is forward-only; do not rewrite history.

## Actual live results

- `live-01`: the visible browser initialized, Amazon scroll replay and screenshot comparison operated, but intermediate screenshots appeared at the wrong position; ChatGPT failed its initial scroll alignment. User confirmed native MHTML displayed correctly when reopened directly in Chromium.
- `live-02`: Amazon replay completed `down→bottom, up→top` with checkpoints `0000..0038` and matching source position at capture time. ChatGPT correctly aligned to the bottom of its internal scroll container (approximately `26925`) and acquired `0000..0016` while rising to approximately `13242`; it then failed on a dynamic opposite-direction scroll. Screenshots/MHTML **inside the experiment's visual comparison** appeared distorted or unstyled. **Important user correction:** both Amazon and ChatGPT native MHTML files nevertheless display **perfectly when subsequently opened directly in Chromium**. The archive bytes therefore must not be assumed corrupt; the in-run reopening/viewing procedure needs separate evaluation.
- User established that a single ChatGPT MHTML saves only the DOM currently mounted: older virtualized chat portions have already been removed. We need a **collage from the separate original captured states**, while preserving segment provenance and noting gaps; a final native MHTML is just one final DOM state, never all previous contents.
- User opening `comparison.html` through the Linux file manager later gets a transient desktop-document-portal URI a temporary `file:` document-portal URI, so relative PNG assets cannot be found. **This alias is from desktop file opening, not a PoC write destination.** The fix must make comparison viewable *after* a session from the persistent PoC directory, not introduce another resource rewriter.
- User confirmed **both `live-02` and `live-03` have already been executed**; a prior chat stalled while reporting a **slight ChatGPT live/automated screenshot displacement**. Do not request those runs again. The existing `live-03` private screenshot evidence is on the user's Linux VM, not available for numerical pixel comparison in this remote work unit. Matching `scrollTop` alone does not rule out different internal content layout. No physically verified correction of the residual displacement has yet been obtained.

## Current forward-only PoC changes

- `live.mjs`: record each original screenshot's visible scrolling-container rectangle (CSS-pixel coordinates, viewport size and device pixel ratio) alongside its original `scrollTop` in `capture.json`. Native MHTML, DOM and CSS are unchanged. The MHTML reopening path now **uses the exact source `scrollTop` in CSS pixels**, not a percentage of different total scroll heights. `archiveScrollTarget()` records intended/actual coordinate, extent mismatch and explicit clamp when the source coordinate does not exist in the reopened MHTML. It also records reopened viewport geometry. The original `live-02` initial ChatGPT alignment and later bounded direction-preserving recovery from the subsequent source code remain in place.
- `collage.mjs` and `generate-collage.mjs`: derived **screenshot-only** visual collage. Greedy original-viewport strips cover measured scroll intervals without repeating fixed browser/page chrome; each retains its original checkpoint. Explicit gaps cover missing top, internal and tail intervals; changing scroll extents/widths and unstable screenshots disallow claiming complete continuous coverage. Older `live-01` and `live-02` evidence lacks scrolling-viewport geometry: show a full-viewport chronological gallery instead of pretending it is stitchable. This is a *visual* artifact, not semantic restoration of invisible/removed DOM.
- `serve.mjs` + `view.sh`: after ANY trial, `sh view.sh live-02` (or other existing run name) generates the screenshot collage and starts a read-only loopback HTTP viewer bound to `127.0.0.1` on an automatically selected port. Only comparison/collage HTML, their original PNGs and small diagnostics are served. It excludes MHTML and raw DOM, uses a host/path allowlist and no filesystem paths outside the PoC, disallows scripts, and prints URLs to open in Chromium. Users no longer open `comparison.html` through the desktop file manager or transient document portal; they can stop/restart the viewer at any time. This does **not** rerun Amazon/ChatGPT and does not modify archived MHTML.
- `run-live.sh` runs all `tests/*.test.mjs` and prints the `view.sh` command after a trial, including an incomplete run. `tests/collage.test.mjs` and `tests/view.test.mjs` provide unit/regression coverage, and `tests/live.test.mjs` verifies absolute scroll alignment and explicit clipping.

- New `alignment.mjs`: samples visible text-element DOM paths, hashed signatures and vertical positions. When the original MHTML is reopened, the same elements are located to measure content displacement. A uniform median displacement supported by at least two elements (spread <=4 CSS pixels, magnitude <=100 CSS pixels) may be corrected by scrolling the **reopened browser page**. A reflow, missing matches or uncorrectable offset is exposed in `offline.json`; no pixels, CSS or MHTML bytes are rewritten.
- `live.mjs`: archived screenshot scroll stabilization tolerance tightened from 8 to 1 CSS pixel; original screenshot, post-screenshot and post-archive content-anchor drift are recorded, and resulting MHTML content alignment and reopened screenshot position stability are checked. The visual comparison links both live and MHTML alignment diagnostics. Status `complete` cannot pass when a measured content shift remains unaligned or a reopened screenshot position drifts.
- `tests/alignment.test.mjs`: five logical regressions, including a browser-evaluation expression exercised against a synthetic DOM; source `tests/live.test.mjs` retains eight logic tests.

## Validation and next physical step

This continuation verified current GitHub HEADs and canonical read order, then made forward-only PoC changes and inspected the resulting code. The V8 isolated shim successfully executed **5/5 alignment logic test bodies** and **8/8 pre-existing live logic test bodies** (13/13 total), after the final logic changes. The altered `live.mjs` and `alignment.mjs` parse in V8 after substituting Node-only module constructs for the syntax check. These are **not** Node's test runner, Chromium, or physical validation on the user's Linux VM. An independent local Node 22 smoke checked two isolated offset cases; it did not execute checked-out PoC files. Actual `live-03` was performed by the user **before this new anchor correction** and does not validate the revised implementation.

Do **not** repeat or overwrite `live-02` or `live-03`. Their existing files remain private and unchanged. For diagnosis of that previously reported visual mismatch, use the existing `live-03` screenshot pair and `capture.json`/`offline.json` metrics from the user's VM; those older JSON records do not contain the newly added content-anchor fields, so the precise offset cannot be inferred from scrollTop alone. The new mechanism can be validated only in a **separate unused** live trial (for example `live-04`, after confirming it does not exist). The task remains active until the user visually accepts actual Chromium source-vs-reopened alignment; do not claim the measured offset is eliminated without that evidence.

## Open risks

- A slight original-vs-reopened offset may persist when text anchors are unavailable, browser geometry changes or ChatGPT reflows. The algorithm deliberately refuses to compensate inconsistent offsets; compare stored geometry and actual pixels without destructive postprocessing.
- Some ChatGPT states may be genuinely missing because of early interruption or application virtualization; collage must show missing coverage instead of inventing restored contents.
- Reopening MHTML with unrestricted network is **not proof of no external dependencies**, though the user visually confirmed the native archived file works.
- The provider/browser runtime is unchanged; no product contracts have been promoted on the basis of this unsettled experiment.
