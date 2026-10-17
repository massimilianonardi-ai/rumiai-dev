# Generic web-page analysis — two real-site live PoC

Status: Active
Updated: 2026-10-17

## Goal

Develop and physically validate a general browser observation/replay method using the user's **two actual authorized pages**, preserving human scroll direction/sequence and acquiring native Chromium MHTML plus correlated CDP evidence. User explicitly rejected more synthetic fixtures/CI and requested **one live VM experiment**.

## Current revisions

- `rumiai-dev-PoCs` HEAD: `7c3b0703097e592fd1ee297fb4b89a27a051db21`.
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
- `evidence/` and `.runtime/` are gitignored. Prior fixture files/CI and expired PoC 068 workflow were removed from current main as part of the requested clean rebuild. Older commits remain in forward-only Git history.

## Validation state

The current direct live implementation has **not yet been physically executed on the user's VM**. Earlier physical runs of PoC 068 had broken HTML/CSS/resource viewing and replay behaviors; they are not acceptance of this new revision. No output archives have been committed or verified on the two real sites in PoC 069. `comparison.html` is only a visual screenshot comparison, not a site recreation.

## Exact next action

From the user's VM checkout `/m/src/git/rumiai-os_TEST/src/rumiai-dev-PoCs/pocs/069-web-page-analyze`:

```sh
git pull --ff-only
sh run-live.sh live-01
```

The user demonstrates both sites in Chromium and presses Enter when prompted. After each site's automatic acquisition, the PoC opens its comparison page directly in Chromium and the user reviews original vs native-MHTML-rendered screenshots. Run outputs go to `evidence/live-01/`. Share only the short `summary.json` and specific errors/diagnostics from `report.json`, not raw private archives.

Any physical failure must be diagnosed from the actual VM log and **corrected forward**; do not add further speculative workarounds or substitute fixtures.

## Known limitations to inspect

- The current observer chooses the most active scroll container, not all nested containers; `otherContainers` is recorded as a coverage gap.
- Dynamic SPA navigation may reset an in-page observer, which must fail explicitly instead of silently claiming coverage.
- Some disclosure actions are intentionally skipped if not safe or visible in replay, and should be listed as gaps.
- Native MHTML can retain original HTTP URLs as `Content-Location` identifiers; these are MIME resource identities, not paths to external exported files. The only public-facing comparison HTML uses relative local PNG paths.
- Native MHTML offline fidelity and page content completeness require actual user review, not a mechanical `complete` flag.
