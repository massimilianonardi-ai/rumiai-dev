# Faithful `web-export` source preservation and resource relinking

Status: Active — generic exporter implementation published; ChatGPT-share acceptance remains open
Updated: 2026-11-08

## Goal

Implement the user's explicit `web-export` contract: keep the captured rendered HTML and its scripts/interactions, changing only references to resources whose response bodies were captured and verified. Do not add synthetic behavior or claim full offline behavior when uncaptured URLs or remote APIs remain.

Normal use: `m web-export <url> <new-directory>` should create an HTML export that retains the original page controls, clipboard/copy state, SVG icons, placeholders, links and click behavior. Exact verified resources become local files; unknown or ambiguous references keep their original URLs.

## Ownership and scope

This handoff owns the general RumiAI OS `web-export` command. `chatgpt-export.md` separately owns the Electron/Node structured ChatGPT snapshot exporter and is not the owner of this task. The supplied ChatGPT shared-page archive is an acceptance probe for this general exporter, not a reason to merge the two commands.

## Fixed correction

The previous implementation that removed scripts/handlers and injected generic interaction helpers was materially nonconforming. It caused the observed `You said:` copy prefix, missing copy icon transition/reset, missing send arrow and editable-placeholder regression. The previous claim of fidelity was misleading and unsupported by the performed checks; the user called it deception/hallucination. Record that assessment without asserting intentional deception. Prior helper-focused tests do not establish fidelity and are superseded.

## Current implementation

Current worktrees:
- `rumiai-os/.worktrees/web-export-os`, branch `work/web-export-offline-interactions-20261107`.
- `.worktrees/web-export-tests`, branch `work/web-export-offline-interactions-20261107`.
- `.worktrees/web-export-dev`, branch `work/web-export-offline-interactions-20261107`.

Product command/manual, permanent test and this handoff/specification work are being updated forward-only. Private capture/export remain under `work/user-chatgpt-share/` and are not tracked.

The converter now uses a source-preserving HTML scanner, keeps scripts and markup, and relinks supported HTML/CSS URL references only through a unique map of verified HTTP response bodies. Script content is stored unchanged. CSS URL replacements are confined to verified refs, including inline style attributes and style blocks; captured stylesheet body references are also relinked. When transformed stylesheet bytes change, manifest SHA-256, source SHA-256 and source SRI are updated. The real Chromium fixture verifies the emitted stylesheet digest and SRI value. CSSOM-only snapshots are not treated as HTTP response bodies. Ambiguous/missing bodies retain their URLs. No generated interaction helper, CSP, or network denial is emitted.

## Evidence so far

- User-installed Node/Chromium in `work/m-os` are used for this task; no new dependencies installed.
- Real Chromium local HTTP fixture exercises copy text and icon check/reset, disclosure expand/collapse, consent dismissal via the source inline handler, inline handler, send arrow SVG, placeholder/value, form, frame, link, resource relinking, and digest/SRI integrity.
- `rumiai-test rumiai-os/web-export/web-export.test` passed 1/1 on vmdev (Linux aarch64, Ubuntu 26.04.1, Chromium from `work/m-os`, Node 26.13), after the final source changes including terminal `<plaintext>` handling. Node syntax checks passed for the command and fixture. `git diff --check` passed in implementation checkout. Fixture covers CSSOM-only and ambiguous sources remaining remote; verified `url()`, `@import`, `image-set()`, inline style and stylesheet relinking; ordinary CSS strings left unchanged; stylesheet body/SRI integrity; source script byte equality; canonical links; controls; and missing URLs remaining remote.
- Converted existing capture `work/user-chatgpt-share/run-2026-11-07T12-18-10-590Z-284530-0` without a new capture. Its 471 resource rows yielded 409 verified assets, 17 preserved script elements, 440 relinked HTML references, one relinked CSS reference, 13 unmapped HTML references and 40 unmapped CSS references. Its saved final DOM contains turns 4–8 and omits turns 1–3. The export was previously opened in Chromium and showed the shell but not conversation messages. This cannot prove complete or faithful export of that share, nor real ChatGPT copy/disclosure behavior. Chromium `file://` restrictions may also affect source scripts.
- Remote heads before publishing: rumiai-dev `512e1c793255f3a8a2e9bfab925158be086fb2af` (task branch fast-forwarded to it); rumiai-os `73886b3c2623b9d8cf5a3ba51566031a6a262b41`; rumiai-tests `b1c8a3bcdbbf7007707037a8627b220d2fd8a024`. All three forward-only pushes to `main` succeeded: rumiai-dev `3923b7b04af1a2ae74bfb2f0bafd1408504f57e0`, rumiai-os `ccd790f`, rumiai-tests `08bc60f8b`.
- GitHub combined commit status lookup for all three published commits returned no status records (`statuses: []`). No CI result is claimed. The environment has no `gh` CLI. No physical validation was performed; test execution was on the user's `work/m-os` Linux aarch64 VM with headless Chromium.

## Next actions

1. Inspect GitHub Actions after the pushes; current checks are unreported, not green.
2. Obtain complete source evidence for the supplied ChatGPT share only if the user authorizes a new acquisition; current capture remains partial. Do not recapture now or fill missing turns/body data by inference.
3. Keep the incomplete ChatGPT capture acceptance limitation explicit.

## Completion boundary / limitations

The fixture proves generic preservation/relink behavior only for its covered cases. The available ChatGPT capture has DOM turn ordinals 4–8 and no 1–3; the generated export screenshot shows the application shell but not its conversation messages. Actual ChatGPT visual/interaction acceptance is not established. The user authorized a single capture, already used; do not recapture. Never reconstruct absent turns or infer missing response bodies. Source JS is retained, but uncaptured resources and remote APIs remain external, so this is not a guarantee of fully offline operation for every URL.
