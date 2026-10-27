# ChatGPT shared-link export — PoC 068

Status: Active
Updated: 2026-10-27

## Goal

Produce a readable offline archive of ChatGPT public shared conversations, preserving rich text, mathematical formulas, diagrams, images and linked references where the observed page evidence permits. Distinguish source completeness from visual acceptance.

## Current repository revisions

- `rumiai-dev`: `0b8ff5f2b258ff576bd516b16282a47d505145f3` at this checkpoint.
- `rumiai-dev-PoCs`: `dcbf87589a7b0598ffbf0487b5cdeab7daee5661`.

Fresh remote HEAD retrieval remains mandatory on resumption.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`.
- `specifications/README.md`, `specifications/rumiai-os/WEB-CONTROL.md`.
- PoC code and tests under `rumiai-dev-PoCs/pocs/068-chatgpt-shared-link-export/`.

## Fixed task-local choices

- Preserve the accepted standalone semantic renderer; original CSS/DOM replay is a separate experimental mode.
- Prefer exact captured static CSS/font bodies instead of hand-reconstructing each source layout.
- Keep raw captures and HTML outputs outside Git, protected as private data.
- No replay of source React/JavaScript/network; avoid overwriting prior artifacts.

## Acceptance scenarios

- The operator gives a shared ChatGPT URL and obtains a private, offline-readable HTML result with the observed messages in sequence.
- The diagram after “2. La soluzione che adotterei” retains its actual structure, not just stacked text.
- Grouped OpenAI sources remain retrievable from working links and the compact +1 group can be expanded without the original React runtime. Long user messages can be fully read from the archive.
- The earlier accepted math on share 1 and rich reading on share 3 remain unaffected.

## Working design

- CSS insertion order and document ancestor/theme context were not preserved in the current static-body capture; evaluate actual rendering before deciding whether another targeted capture is required.
- Original CSS may not reproduce React-dependent popovers. If needed, design a safe standalone interaction limited to captured source links.

## Completed

- Share 2 regained DOM readiness and capture sweep. Physical vmdev evidence: 12 selected turns and a later full source capture at `/home/admino/chatgpt-share2-full-2MGSvdpK` with 51 turn snapshots, 46 CSS bodies, 1 font body, no recorded static-body failures, sweep finished.
- Commit `d5672b8` adds `render-same-session-styled.mjs`, reusing the already existing DOM assembler and static-resource localizer, with integrity checks, opt-in HTML creation and three fixture tests. Commit `c85de05` permits CSS hover on buttons without enabling scripts.
- Local Node syntax check and three orchestration tests with stubbed assembly/localization passed; they are not proof that the existing real assembler/localizer integration passes or that the physical site renders correctly.

- Commit `9d84c8f` removes the generic table-cell borders from the original-CSS preview and adds a private-safe interaction-structure inspector plus focused tests. No claim of visual acceptance of the corrected table or functional source controls. 

- Physical vmdev execution of four focused tests passed (0 failures); regenerated styled share 2 with 12 turns, no missing ordinals, 43 localized stylesheets and 77 unresolved references. Private-safe control inspection: `Mostra di più` on 1/5/9 (aria-expanded false), grouped +N labels on 2/4/6, with immediate label ancestry lacking link anchors. 
- Commit `cb763ddd` introduces **opt-in live interaction observation** during the existing sweep, for original-page show-more activation and source +N hover. It saves any newly observed links only in private event evidence; the sanitized inspector reports counts. This is not yet validated on physical vmdev and does not itself implement the offline controls.

- Physical vmdev interaction run: two tests passed, 59 turn snapshots, 8 hover attempts, 2 hovers revealing 4 distinct HTTPS URLs, no show-more clicks or reported errors. Source ownership remains unverified. Capture at `/home/admino/chatgpt-share2-interactive-QelaT13q`.
- Commit `f2ecce3` fixes show-more selection to match leaf-span label when the entire button contains extra hidden text. Adds candidate/label-match telemetry, a fake-DOM regression and a counts-only attribution inspector for the existing four URLs. These changes require vmdev tests and the fixed live capture has not yet been run.

- Physical vmdev run after `f2ecce3`: four real tests passed; new capture `/home/admino/chatgpt-share2-interactive-m8xthV9A` has 74 verified snapshots, 5 recognized preview labels, 5 click attempts and final user turns 1 and 9 marked `aria-expanded=true`; turn 5 is collapsed again in the latest snapshot. One of eight source-group hover counts agreed with `+N`; link identity remains unproven.
- Commit `431562e` adds opt-in expanded snapshot preference for the original-CSS assembler, and script-free checkbox/label controls scoped only to user `data-can-expand` previews. The accepted assistant diagram and semantic renderer are intentionally unmodified. A two-scenario fixture was added. Physical testing of the new offline mode and actual user text completeness is pending.

- Operator reports the local CSS-only user-preview expand/collapse control **works**, but expanded-source snapshots initially display open; user explicitly requires **collapsed by default**. The writing block starting “Scrittura”, after “Una richiesta sperimentale potrebbe essere questa:”, has insufficient text inset. Copy buttons are optional and must not justify weakening the offline CSP.
- Commit `a51a4ed` sets every preview checkbox initially unchecked and normalizes stale source `data-expanded` to collapsed while retaining complete captured text. It adds a 1rem logical inset narrowly scoped to original `--writing-block-editor-pl` editor elements, updates fixture assertions and records source/initial state counts separately. New code has preliminary syntax checks but still requires real vmdev Node tests and visual acceptance.

- Operator visually confirmed long user messages **start collapsed**, and both expand/collapse controls work correctly. The "Scrittura" writing block, after "Una richiesta sperimentale potrebbe essere questa:", still lacks original left and bottom inset; user explicitly rejects ad-hoc CSS fixes. Clipboard controls remain optional.
- PoC commits `455dad5` and `4806a2d` **remove** the fixed inline start/end 1rem writing-editor padding override. It preserves source HTML/CSS and adds `inspect-captured-writing-layout.mjs` to report original archived editor/ancestor structure without printing content or style values. Further root-cause analysis must compare source/live and archived *computed* styles, DOM ancestors and stylesheet cascade/order; the current offline page does not include all original application ancestors.
- The same commit corrects live source observation: uses the actual `aria-haspopup` trigger, attempts native popup click/hover, associates URL evidence only with `aria-controls` or a single newly visible popup, and retains page-wide new URL counts as unscoped evidence. Tests cover synthetic popup capture and private-safe layout scanning. The subsequent `4806a2d` correction also uses accurate diagnostic field names (`hasClassAttribute`, `scopedCountMatches`) instead of names implying unsupported evidence. This path needs a new physical opt-in capture before the grouped-source function can be implemented in the offline page.

- Physical vmdev evidence after `4806a2d`: tests 6 pass / 1 fail (the source-popup regression expected "single-new-popup" but returned "none"). The prior run's capture `/home/admino/chatgpt-share2-sources-Ld75fDXQ` yielded 75 turn snapshots, 8 source-hover attempts, 8 popovers labeled scoped, but **0 scoped URL targets** and 0 scoped count matches. Do not treat these eight popup detections as proof that links were recoverable. The writer-layout inspector found 2 writing-editor surfaces at ordinals 2 and 6, each bearing all four original editor padding variable names; computed values remain unknown.
- PoC commits `cfb430f` and `dcbf875` correct the root bug: the string `scopeType === 'none'` was tested by boolean negation, so fallback detection of newly appeared popups could never execute. A valid but linkless `aria-controls` node no longer prevents checking one newly visible popup. The sampler also recognizes previously hidden popup nodes, records linkless/clickable panel counts, distinguishes controlled panels from single-new-popup provenance and skips popup triggers nested in anchors. The broken regression fixture was augmented to protect this case. The latest `dcbf875` update adds privacy-safe per-group source structure (`sourceGroups` with ordinal/index, scoped anchor and link-like element counts, no URLs) and a summary regression check to avoid further blind recaptures. Local JavaScript syntax checks and V8 execution of the exact updated popup functions with mocked DOM passed; real vmdev Node tests and a new Chromium observation remain pending.
- Original writer CSS remains unchanged; only structural, privacy-safe evidence is currently available. Determine original-vs-offline computed style and cascade/ancestor differences before changing CSS.

## Current state

Operator physically inspected the original-CSS offline view and **accepted the diagram** following “2. La soluzione che adotterei”. Cost-per-token table styling and OpenAI +1 source controls remain unresolved. Native show-more toggle interaction and initially-collapsed default are operator accepted. Writing-editor style fidelity remains pending source-vs-offline diagnosis; manually patched padding was revoked. The earlier accepted semantic outputs remain unchanged.

## Next action

On vmdev, pull PoC `dcbf875` and run `node --test tests/live-share-interactions.test.mjs tests/captured-writing-layout.test.mjs tests/offline-preview-controls.test.mjs`. If tests pass, one new private `render-probe.mjs --headless --sweep --capture-image-bodies --capture-static-bodies --observe-interactions` capture is needed: older source-hover events contain empty scoped links and cannot be retroactively attributed. Inspect `inspect-live-share-interactions.mjs` safe summary including `sourceGroups`, `scopedWithLinks`, `controlledPopupWithLinks`, `linkLikeWithoutHref` and `scopedCountMatches` before mapping source groups offline. Only trust exact URL ownership from the associated popup. Preserve accepted diagram, initial-collapse controls and unmodified writer CSS. For writing fidelity compare actual computed padding and original stylesheet cascade in live and offline browsers, not merely inline attribute names.

## Blockers / open questions

- Cost-table test and control-structure inspector passed physically on vmdev; **visual** acceptance of the corrected table is still pending.
- CSS order and missing source DOM ancestors may cause layout mismatches.
- Browser interaction and collapsed-by-default behavior of native preview controls are operator-accepted. "Scrittura" left and bottom padding remains unverified against original computed style; do not revive a hard-coded fallback.
- Link count consistency is weak evidence, not source-to-pill provenance; repaired popup-fallback detection requires physical vmdev test and fresh CDP capture. The known 2026-10-27 `Ld75fDXQ` capture has no attributed source URLs.
- RAW source conversation completeness not proven by contiguous turn ordinals.
