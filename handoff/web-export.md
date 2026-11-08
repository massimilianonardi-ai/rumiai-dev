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
- Forward-only publication SHAs: rumiai-os implementation/manual `ccd790fb9f712432f32fdf135f3531b6e340a075`; product CI workflow `6a4b102` (full test-suite pin `rumiai-tests@906d9890d5a408753631b33c7f411f5e5cb60b37`); rumiai-tests Chromium readiness fix `906d9890d5a408753631b33c7f411f5e5cb60b37`; rumiai-dev docs/handoff current checkpoint to be recorded below.
- GitHub Actions `Standalone web-export with real Chromium` initially failed twice: first because the workflow pinned an obsolete suite expecting `web-export/1`, then because the Chromium target was observed before the `file://` document finished loading, and once because `actions/checkout` was given a short SHA interpreted as a ref. All three causes were corrected forward-only. The latest product run on `rumiai-os@6a4b102` is **success**: [run 42500991970](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/42500991970). It checks out the full test SHA above and runs the public CLI with real hosted Chromium.
- The separate broad `rumiai-os-health` workflow on `rumiai-tests@08bc60f8b` failed in both Ubuntu ARM64 and macOS validation with unrelated existing suite failures/errors across other subsystems (17 failures plus 11/14 errors). In its captured validation, `rumiai-os/web-export/web-export.test` was **SKIP**, not run, because that validation environment lacked the required runtime. This is not evidence of a `web-export` defect; the focused hosted Chromium workflow and local real-Chromium test are the relevant executions and both pass. No physical reference-host validation was performed.
- Follow-up audit searched all existing files in the authorized `user-chatgpt-share` capture: `states/dom-rest-initial.html`, `states/dom-rest-final.html`, `states/state-000.json`, root/rest mutation logs, CDP DOM tree/snapshot and MHTML. The HTML/JSON snapshots contain exactly turns 4–8; the partial MHTML contains only a subset. No existing evidence contains turns 1–3. Other ChatGPT captures in `work/` are unrelated URLs/runs and cannot supply this share's missing content. The archive itself marks DOM evidence partial and warns that one settled observation is not exhaustive.

## Next actions

1. Do not recapture the share under the existing one-capture constraint. Complete ChatGPT-specific visual/interaction acceptance only if the user provides a complete existing archive or explicitly changes that constraint.
2. Keep generic `web-export` delivered and tested as documented; do not claim that the partial ChatGPT archive passed real-share acceptance.

## Completion boundary / limitations

The fixture proves generic preservation/relink behavior only for its covered cases. The available ChatGPT capture has DOM turn ordinals 4–8 and no 1–3; the generated export screenshot shows the application shell but not its conversation messages. Actual ChatGPT visual/interaction acceptance is not established. The user authorized a single capture, already used; do not recapture. Never reconstruct absent turns or infer missing response bodies. Source JS is retained, but uncaptured resources and remote APIs remain external, so this is not a guarantee of fully offline operation for every URL.
