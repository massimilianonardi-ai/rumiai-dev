# Chromium manual-session analysis — web-analyze

Status: Active
Updated: 2026-11-03

## Goal

Provide the `m` JavaScript library at `rumiai-os/lib/sys/js/web-analyze.lib.js` to launch the `chromium` executable from the effective `m` PATH, observe the user's manual browsing via native Chromium CDP on loopback TCP, and record extensive structured JSONL evidence. No Playwright dependency or separate provider/PoC is required. A new `bin/sys/web-analyze` Node.js command reuses this capture library to perform bounded, passive page-state exploration and produce Markdown evidence.

## Current repository revisions

- rumiai-dev: 5623d0282adb7b70399c084776078359695dfd57 (before this checkpoint)
- rumiai-os: 57886c999b0fcb49da87229a44b1369c3f148d53 (DOM settlement, artifacts, manuals and CI)
- rumiai-tests: af36e8f42bb4fea9cdd57ef5492a9198673b7f89 (real browser delayed-hydration and non-converging DOM tests)

## Applicable canonical sources

`README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `TEST-PATTERNS.md`, `specifications/README.md`, `specifications/rumiai-os/CURRENT-MODEL.md`, `BOOTSTRAP-ENVIRONMENT.md`, `FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`, `WEB-CONTROL.md`, `handoff/README.md`.

## Fixed task-local choices

- Existing manual-recorder invocation remains `nodejs <path-to-lib> <url> <analisys-dir>`, both CommonJS import and direct Node.js entrypoint. The new, distinct automation request explicitly authorizes `m web-analyze <url> <analysis-path>` as an executable `#!/usr/bin/env node` command; it does not rename or replace the library entrypoint.
- The destination analysis directory, including missing parents, is created automatically; any user-chosen pathname component is handled as pathname data rather than parsed as a CLI option. An existing directory can be used if it contains no conflicting evidence files. Existing JSONL streams and `summary.json` are never overwritten.
- Chromium is launched directly from the effective PATH, without Playwright, using a dedicated profile and ephemeral CDP TCP debugging port bound to `127.0.0.1`; sandbox and TLS verification remain enabled by default.
- Interactive CLI capture lasts until Chromium exits or SIGINT/SIGTERM; API callers may also stop explicitly. The capture finalizes multiple correlated JSONL streams plus `summary.json`.
- Existing lifecycle/interaction/DOM/network/console/performance/error JSONL logs retain redacted URL metadata and do not record entered text, HTTP bodies or WebSocket frames.
- **Current explicit user authorization (2026-10-19) supersedes the previous no-response-body scope for a separate raw evidence archive.** CDP Network.getResponseBody saves finished response bodies content-addressed in resources/ with full URL/status/provenance in resources.jsonl; Debugger.scriptParsed/getScriptSource saves compiled JS (including inline/eval where available) in scripts/ and scripts.jsonl. Both raw indexes and bodies may contain secrets/signed URLs and are for private analysis only, not redacted diagnostics or repository artifacts.
- On caller stop/SIGINT, wait up to 6 seconds for response lifecycle/body/source reads and require a 750ms quiet interval; unresolved requests, failed body retrieval, pending CDP reads and skipped redirect bodies remain explicit in per-resource indexes and summary. An external Chromium close cannot enforce network quiescence; long-lived SSE/WebSockets do not admit a global completion guarantee.
- User-provided real acceptance URL: `https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835`.
- The new command defaults to headless Chromium, records at most 29 DOM states after bounded passive document/nested-container scrolling, inventories links/forms/controls, retains compiled scripts and response-body archives, and produces Markdown and Mermaid outputs. Each invocation creates an isolated private `run-*` under the supplied directory. No automatic click, form submission, login or challenge bypass; unobserved routes/behavior are not asserted.
- Explicit 2026-11-03 correction: preserve a post-loading resting DOM, not just a fixed-delay or scrolling snapshot. Initial and final full main-document outerHTML is stored under `states/dom-rest-{initial,final}.html`, with JSON settlement evidence. Per-state bounded snapshots follow quiescence checks. `settled` requires document complete, fonts loaded, and 1.5s quiet DOM/network with no pending CDP requests/reads; unresolved but quiet requests after 4.5s yield `dom-quiet-network-pending` instead of a false completion claim. Initial/per-step waits are bounded at 15s/6s within a 45s exploration budget; non-converging pages retain snapshots marked `timeout`. These observations do not prove all eventual app work has completed.

## Acceptance scenarios

1. In an `m` shell with `nodejs` and `chromium` available, invoke the library with the shared-page URL and an absent `analisys-dir`; a visible Chromium window opens and the nested directory is created.
2. Navigate/interact manually, close Chromium or press Ctrl+C, then read timestamped lifecycle, interaction, DOM, network, console, performance and error logs and summary.
3. Repeat against a directory with existing evidence: fail without overwriting prior log files. An existing directory without conflicting evidence is accepted.
4. On an externally reachable host, verify actual shared-page navigation/response independently of debugger launch and logging mechanics.
5. Execute `m web-analyze https://example.org ./analysis` without knowing CDP identities: observe a new private run directory containing raw resources, script archive, rendered states, and navigable Markdown reports with Mermaid scroll flow.
6. Run a real dynamic local page whose nested scroller loads new controls and JSON: verify these changes and resource bodies are captured; repeat in the same parent without overwriting the prior run.
7. A page that hydrates content 1.2s after DOMContentLoaded must include that content in the initial resting snapshot; a page that changes its DOM continually must not be described as settled and must still save a bounded best-effort snapshot.

## Completed

- Created and published `lib/sys/js/web-analyze.lib.js` inside `rumiai-os` and mandatory matching `res/sys/manual/web-analyze.lib.js`; public function is `startWebAnalyze(options)`.
- Added direct `nodejs <path-to-lib> <url> <analisys-dir>` executable behavior in that same library, automatic recursive analysis directory creation, existing-evidence refusal, and graceful signal/browser-exit finalization; changes committed forward-only.
- Added permanent test scenarios in `rumiai-tests/tests/rumiai-os/web-analyze/`: `web-analyze.test` (real Chromium API observer), `cli.test` (direct graphical Chromium invocation with directory creation, signal shutdown and overwrite refusal), and `share-page.test` (exact shared ChatGPT URL).
- On an auxiliary Linux host using real Chromium and Node.js 22, the original direct CLI and API probes passed at original library blob 0985a89d6033d23abef396528f619c5901c549af.
- New raw archive published in rumiai-os commits c15bbc3240a9b0497543edd698eec919c11ad6cb and 5c132a627fd03fbce89c0f0f9ea39917b2e3a4bf, plus a focused GitHub Actions job at c225b1204831dd1cbdb4153740e63698ff125ae2. Permanent test fixture changes in rumiai-tests through b9285d0d8a30825d5c3105e3e7ae8a03ac04d500 use a real local HTTP server plus Chrome CDP: HTML, CSS, JS, JSON body preservation, Debugger compiled script source, and delayed request completion during stop().
- Real GitHub Actions run https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/39321448694 is PASS on Node.js 22 and the Chrome binary available on ubuntu-latest. Its job checked out tests at b9285d0d8a30825d5c3105e3e7ae8a03ac04d500 and ran the real native CDP permanent web-analyze probe successfully. This is real browser fixture evidence, NOT validation of ChatGPT asset coverage on the operator's host.
- Recent user-committed PoC 068 real share recording had 4,843 events and an unusually active div-target scroll/mutation timeline; the old event recorder logged window.scrollY rather than the event target scrollTop. The new network resource capture does not itself address per-message DOM ID correlation or instrument runtime event-listener registration.
- On that same host the real shared-page navigation returned `net::ERR_BLOCKED_BY_ADMINISTRATOR`. The dedicated remote-page test therefore reported SKIP, not PASS. Chromium process/CDP transport/capture success is independently evidenced; actual page-content loading is not.

- On 2026-11-03 published `rumiai-os@fe6cfd33759b06d46286684e6b2018606cd68baf` (Node command/manual and additive `sendPage` native-CDP page command method) and `rumiai-os@c78e4981ea7759f6798f14b13f135ef5e55a00b3` (CI including new real-command test). Published `rumiai-tests@e9c335408ccef021590d468949775e277bfec49d` with a real Chrome/Chromium local HTTP fixture exercising dynamic lazy controls, resource/script capture, output isolation, argument errors and Mermaid output. GitHub Actions run `41634919134` passed on hosted Linux with Node.js 22 and real Chromium. This does not prove all React behaviors or acceptance on a physical operator host.

- On 2026-11-03 extended the native-CDP library's returned session with read-only `networkActivity()` (counts + elapsed quiet time), and the command with DOM MutationObserver-based quiescence, full resting DOM exports, settlement metadata and Markdown reporting. First CI run `41638548568` exposed excessive waiting on requests left active by CDP; this is failure evidence, not a passing run. Corrected forward-only to distinguish `dom-quiet-network-pending` from `settled`, and bound the overall sweep. Current permanent fixture covers delayed hydration, delayed scroll-dependent control, preserved response bodies, repeated output isolation, and perpetual DOM mutation timeout. Hosted Linux Node.js 22 + real Chromium CI `41639402973` **PASS** for `rumiai-os@57886c999b0fcb49da87229a44b1369c3f148d53` and `rumiai-tests@af36e8f42bb4fea9cdd57ef5492a9198673b7f89`. This does not prove physical-host or arbitrary-site completeness.

## Corrected slow-navigation capture startup (2026-10-19)

- User physically observed `web-analyze.cdp-timeout: Page.navigate did not respond` while the target share was beginning to download; previous `Page.navigate` command used the generic 12-second CDP timeout and propagated the error to startup failure, closing Chromium.
- Current `startWebAnalyze` dispatches navigation asynchronously after attaching all CDP instrumentation. It waits at most one second for a fast navigation acknowledgement, then declares capture ready with `navigationPending`. Slow, failed or timed-out initial navigation never stops a healthy CDP recording session; asynchronous outcome is logged as `page.initial-navigation-accepted`, `page.initial-navigation-failed` or `page.initial-navigation-command-failed`. The navigation command itself has a 120-second response timeout for diagnostics, not a session lifetime cap. Other genuine startup failures still reject.
- Product source commit 941358b8454e71ccc9d16c47946844bd2e6e9d0a, manual commit 378276e1f3b6880af21a55aab4c3424d66a0dd3b, CI pinned-test revision at 58244e937345d99acdaf948454e20f3e18f3bac0. Permanent test at `rumiai-tests@c243a6bc1a5a153e0b17bfadba53250dc53032c8` uses an HTTP document delayed 13.5 seconds (> previous 12 seconds), verifies early start, continued resource capture and successful archiving after the late response.
- Real Chromium + Node.js 22 GitHub Actions run **PASS**: https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/39322930821 ; runner executed test at the pinned revision. This confirms real local browser/CDP fixture behavior; the exact remote ChatGPT URL remains an operator-side validation pending on the new code.
- Verified no change to the separately pinned `chatgpt-export.lib.js` Markdown baseline.

## Real shared-page archived-resource validation (user-operated, 2026-10-19)

- Operator committed evidence at `rumiai-dev-PoCs@cfc4533627382bb0e339ea1c424eb96d1f88b123` under `pocs/068-chatgpt-shared-link-export/analysis-chromium-resources-02/` for the agreed target share.
- `summary.json`: 4,768 events across 71.81 seconds, zero dropped logged events; 631 requests observed, 614 bodies archived (40,498,763 bytes), 13 redirects without bodies, 2 failed requests, 2 unfinished at shutdown, 0 pending CDP reads. In `resources.jsonl` there are also 11 `finished-without-metadata` records (unmatched requests from early attachment/races). They do not imply 11 additional successfully archived requests.
- `scripts.jsonl`: 530 script parse events, all 530 source reads saved, zero failures, producing 525 distinct source file objects due to duplicate-content hashing. The output directory has 589 distinct resource payload files for 614 saved outcomes.
- Initial navigation was acknowledged at 10.36 seconds, Page.loadEventFired at 11.86 seconds; capture continued until operator shutdown around 71.75 seconds. Thus the user-observed navigation-timeout regression is no longer occurring in this run.
- This is actual target-host validation of CDP response/script capture, *not* proof of 100% resource completeness or DOM replay accuracy. The preserved resource and script indices can contain full signed URLs and source/body data.
- **Security/privacy:** user committed a new entire Chromium profile and raw response archive again. Files in profile may include browser/session secrets; the historical record cannot be sanitized through a normal forward commit. Do not inspect/expose private values or automatically rewrite Git history; request an authorized remediation plan if these artifacts are not intentionally safe to retain in the repository.

## Current state

Native-CDP manual capture remains available and has user-operated evidence against the original shared URL. The new `bin/sys/web-analyze` automates bounded passive inspection, nested scroll, screenshot/DOM state capture, full initial/final DOM-at-rest snapshots and Markdown reports, preserving timeout/ongoing-network caveats. The composed command has a passing real-browser fixture CI run `41639402973` for the current revisions; physical operator-host execution of the *new command* has not been verified. Coverage remains incomplete for never-visited interactions, authenticated states and unrecoverable/persistent resources.

## Next action

Validate the new public `m web-analyze` command on the operator's actual Chromium/m environment and representative dynamic target, keeping raw output private. Then correlate saved compiled scripts with observer callbacks and React component/turn identities, and design explicit, controlled interaction scenarios to move beyond passive scroll evidence. Do not commit browser profiles or raw unreviewed resources.

## Blockers / open questions

The new command was not validated against the real ChatGPT share or on the operator's physical workstation. Complete reconstruction of all possible behaviors from one URL is not technically guaranteed; controlled interaction scenarios, authentication and server-side conditions may be needed. Physical validation and coverage of every loaded resource remain open. CDP cannot guarantee recovery of all response bodies (e.g. early eviction, redirects, persistent streams, resources loaded before attachment). Access to raw artifacts may expose session/private information; users must keep the output private.
