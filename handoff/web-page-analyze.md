# Generic web-page analysis — live Amazon + ChatGPT

Status: Active
Updated: 2026-10-17

## Current authority and retrieval

Before analysis/modification always verify current remote HEADs; follow `rumiai-dev/README.md` Mandatory Read Order: `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, current `specifications/rumiai-os/WEB-CONTROL.md`, `DIAGNOSTICS.md` if applicable, `TESTING.md`, this handoff, current PoC implementation and tests. Explicit user corrections are higher authority than this task-state checkpoint. Do not read Git history by default.

Latest PoC HEAD at this checkpoint: `8678cc7e4a4c10e18ed781dc68d972f4d3916386`; PWC baseline HEAD: `403f4fa9bbea419715e9c834e847c6f2b60ae421`. Revalidate at next work unit.

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
- User opening `comparison.html` through the Linux file manager later gets a transient desktop-document-portal URI `file:///run/user/1000/doc/.../comparison.html`, so relative PNG assets cannot be found. **This alias is from desktop file opening, not a PoC write destination.** The fix must make comparison viewable *after* a session from the persistent PoC directory, not introduce another resource rewriter.
- User additionally observed a **slight live/automated screenshot scroll misalignment** in ChatGPT comparisons. Source inspection found `reopen()` mapped `scrollTop` to the MHTML by source/archive `maxScroll` ratio, so small dynamic extent differences produced offset. No actual pixel-accurate alignment of the revised implementation has yet been physically tested.

## Current forward-only PoC changes

- `live.mjs`: record each original screenshot's visible scrolling-container rectangle (CSS-pixel coordinates, viewport size and device pixel ratio) alongside its original `scrollTop` in `capture.json`. Native MHTML, DOM and CSS are unchanged. The MHTML reopening path now **uses the exact source `scrollTop` in CSS pixels**, not a percentage of different total scroll heights. `archiveScrollTarget()` records intended/actual coordinate, extent mismatch and explicit clamp when the source coordinate does not exist in the reopened MHTML. It also records reopened viewport geometry. The original `live-02` initial ChatGPT alignment and later bounded direction-preserving recovery from the subsequent source code remain in place.
- `collage.mjs` and `generate-collage.mjs`: derived **screenshot-only** visual collage. Greedy original-viewport strips cover measured scroll intervals without repeating fixed browser/page chrome; each retains its original checkpoint. Explicit gaps cover missing top, internal and tail intervals; changing scroll extents/widths and unstable screenshots disallow claiming complete continuous coverage. Older `live-01` and `live-02` evidence lacks scrolling-viewport geometry: show a full-viewport chronological gallery instead of pretending it is stitchable. This is a *visual* artifact, not semantic restoration of invisible/removed DOM.
- `serve.mjs` + `view.sh`: after ANY trial, `sh view.sh live-02` (or other existing run name) generates the screenshot collage and starts a read-only loopback HTTP viewer bound to `127.0.0.1` on an automatically selected port. Only comparison/collage HTML, their original PNGs and small diagnostics are served. It excludes MHTML and raw DOM, uses a host/path allowlist and no filesystem paths outside the PoC, disallows scripts, and prints URLs to open in Chromium. Users no longer open `comparison.html` through the desktop file manager or transient document portal; they can stop/restart the viewer at any time. This does **not** rerun Amazon/ChatGPT and does not modify archived MHTML.
- `run-live.sh` runs all `tests/*.test.mjs` and prints the `view.sh` command after a trial, including an incomplete run. `tests/collage.test.mjs` and `tests/view.test.mjs` provide unit/regression coverage, and `tests/live.test.mjs` verifies absolute scroll alignment and explicit clipping.

## Validation and next physical step

Source files parse in the V8 isolate. The 8 live logic test bodies and 6 collage logic test bodies passed in the **shim**, not the real Node test runner on the user's VM. Read-only viewer's actual Node HTTP regression and end-to-end browser appearance have **not** been run physically from this updated revision. This distinction is material.

**First physical check does NOT require a new live browser run:**

```sh
cd /m/src/git/rumiai-os_TEST/src/rumiai-dev-PoCs/pocs/069-web-page-analyze
git pull --ff-only
sh view.sh live-02
```

Open the printed `http://127.0.0.1:<port>/` site comparison and collage links. Confirm old original screenshots stay available after a run; the site-specific collage will present the older run as a complete-viewport timeline because exact scrolling-container bounds were not captured yet. Do not open comparison HTML through the file manager. Use `sh view.sh live-01` for earlier evidence.

For a **new** run, `sh run-live.sh live-03` remains the next unused run name (verify what exists on the VM before reuse); it will record the viewport bounds required for a genuine cropped screenshot collage and use precise original-vs-reopened MHTML scroll alignment. The user has not yet physically accepted those new results. Preserve prior private runs.

## Open risks

- Slight original-vs-reopened viewport offset may persist if CSS/viewport geometry differs beyond the scrollTop coordinate. Compare the two stored geometry sets and image evidence without destructive postprocessing.
- Some ChatGPT states may be genuinely missing because of early interruption or application virtualization; collage must show missing coverage instead of inventing restored contents.
- Reopening MHTML with unrestricted network is **not proof of no external dependencies**, though the user visually confirmed the native archived file works.
- The provider/browser runtime is unchanged; no product contracts have been promoted on the basis of this unsettled experiment.
