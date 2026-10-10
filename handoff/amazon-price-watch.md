# Amazon Price Watch

Status: Active
Updated: 2026-10-10

## Goal

Replace the fragile model-driven Amazon Price Watch polling path with a deterministic application that uses the already-developed `web-control` runtime to observe Amazon.it product pages, while keeping the concrete Amazon-monitoring problem separate from the general RumiAI `web-control` / `web-sense` architecture work.

## Current repository revisions

- rumiai-dev: bfae9567dab92671d0711cd2a2d1f3686d052e1f
- rumiai-dev-PoCs: 0f9c5b7fd78f22716cdd1be4423fda91b557eb78
- rumiai-web-control: 8ed3ab888ecdc4970d90a6f14f0d7b7b93fce122
- rumiai-os: 1c03cb644bd5b9cf1c728964487541ab00db3cd1
- rumiai-tests: f8c7e590130a5a1353d79f9dc6f5068e5c132525
- pkg-catalog: f0cdadb09ced5ca26c7745b5996de89cab24f7c1

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/WEB-CONTROL.md
- handoff/README.md

## Fixed task-local choices

- Amazon Price Watch is an application problem with its own lifecycle; it is not the design or implementation task for `web-sense`.
- The general Web architecture work and the Amazon application may proceed in parallel. Reusable requirements discovered while solving Amazon may inform the general Web work, but Amazon-specific operational state remains here.
- The current ChatGPT scheduled task is the behavioral source to translate, not the intended runtime architecture.
- Current scheduled cadence is six checks per day (00:00, 04:00, 08:00, 12:00, 16:00, 20:00 Europe/Rome); the task is currently disabled while the replacement path is investigated.
- The user owns and maintains the monitored product sets directly as Amazon wishlists. The deterministic monitor must consume wishlist identity/URL and discover products itself; the user must not maintain a parallel ASIN list merely for the monitor.
- The existing spreadsheet is legacy/current task state rather than the desired source of monitored-product membership. Its historical price/target fields may still inform later migration/state design, but wishlist membership belongs to Amazon.
- For the current phase, Google Sheets and Gmail are explicitly outside the experiment. The first question is only whether Amazon.it price observation can be made deterministic through `web-control`.
- Unverified or ambiguous prices must never be treated as verified prices. Access blocks, CAPTCHA/challenge pages, ASIN mismatch and ambiguous price candidates must produce an explicit failure result rather than a guess.

## Acceptance scenarios

1. Given an Amazon.it wishlist URL/identity, a deterministic program invokes `web-control`, discovers every currently listed product and returns a complete set of product observations without requiring user-supplied ASINs.
2. Wishlist lazy-loading/pagination is driven until completeness can be established deterministically; a partial list must not be silently accepted as complete.
3. For each discovered product, the program returns either the wishlist-visible price with sufficient evidence or an explicit unverified/unavailable reason. One bad item does not invalidate verified observations for other items.
4. The probe detects common Amazon access failures such as CAPTCHA, Robot Check, HTTP errors and equivalent challenge pages.
5. No model, ChatGPT session, Google Sheet write or Gmail action is required for wishlist observation.

## Working design

The existing PoC 054 (`amazon-wishlist-browser-probe`) already contains useful deterministic Amazon diagnostics: final URL/status, CAPTCHA/Robot Check/service-error detection and ASIN extraction from rendered DOM. The next experiment should reuse those observations through the current `web-control` command surface instead of launching Playwright directly.

The desired baseline is wishlist-first, not product-page-first. The monitor should:
- open the user-maintained Amazon.it wishlist through `web-control`;
- discover product identity (normally ASIN), description, product URL and wishlist-visible price directly from each rendered wishlist item;
- drive Amazon's lazy-loading/pagination until a deterministic completeness condition is reached;
- detect access/challenge/error pages and never treat a partial/blocked list as a complete successful observation;
- emit machine-readable JSON for the whole wishlist, including explicit unavailable/unverified item state.

Two retrieval mechanisms should be investigated in this order:

1. **Rendered-page baseline:** drive scrolling/lazy loading through the browser until no additional wishlist items appear and the page reaches a stable completion condition. This is the correctness/reference path because it uses the same browser behavior a user sees and does not depend on undocumented Amazon endpoints.
2. **Observed internal request optimization:** while exercising the rendered-page baseline, inspect the actual resource/XHR/fetch behavior used by Amazon to load subsequent wishlist chunks. If the browser session exposes a stable, deterministic request contract that can be replayed without bypassing authentication/challenge controls, a site-specific helper may use it to avoid physically scrolling the whole page. It remains an Amazon-specific implementation optimization, not a public `web-control` contract.

Do not assume a remembered or web-documented Amazon private endpoint. The request shape, continuation state and required cookies/tokens must be learned from the current page behavior in the user's real browser session.

The current `web-control` baseline is sufficient for this experiment: page creation/navigation, rendered text/HTML inspection, capture, and the current CDP extension for deterministic DOM evaluation are available. This experiment does not promote Amazon-specific selectors or CDP use into the provider-independent `web-control` contract.

Once Amazon observation itself is validated, the existing ChatGPT task logic is mostly ordinary deterministic state logic: previous/current price, monitored minimum, target state, target-notified state and alert thresholds. Spreadsheet persistence and notification delivery are separate integration problems and should be added only after the Amazon observation layer is proven.

## Completed

- Recovered the current ChatGPT `Amazon Price Watch` task behavior and cadence.
- Inspected the current `Amazon Price Monitor` spreadsheet read-only and confirmed the shared operative schema of `Watch` and `Star Wars`.
- Inspected current `web-control` implementation and verified the primitives needed for a deterministic Amazon product-page probe.
- Recovered PoC 054 as prior evidence and a source of Amazon block-detection logic.
- Created PoC 059 (`pocs/059-amazon-price-web-control`) with a dependency-free JavaScript probe that drives the public `web-control` CLI, verifies ASIN identity/access health, extracts prioritized visible EUR price candidates, rejects ambiguity, and optionally captures HTML/text/screenshot evidence. The script passed local `node --check` and invalid-argument behavior; no live Amazon/web-control runtime validation has yet been performed.
- Created PoC 060 (`pocs/060-amazon-wishlist-web-control`) as the wishlist-first experiment. It drives current `web-control`, accumulates ASINs across scroll rounds, records wishlist-visible price candidates, uses conservative stable-bottom completeness criteria, instruments future in-page `fetch`/XHR calls to expose lazy-load request candidates, and optionally captures HTML/text/screenshot evidence.
- First physical attempt on the user's Linux test host reached the PoC preconditions but did not reach Amazon execution: `node` was initially absent, `pkg install nodejs` succeeded, and `node --check probe.mjs` passed. `rumiai-web-control` installation failed with `pkg-install` reason `request-unresolvable`; consequently `srv start web-control` failed with `provider-resolution-failed`. Current catalog inspection confirms package `rumiai-web-control` v0.1.3, facility `web-control` compatibility 1, and the upstream GitHub v0.1.3 release all exist. An immediate retry of `pkg install rumiai-web-control` later in the same physical session advanced past package request resolution and failed instead with `dependency-unresolvable`. Direct isolation then showed `pkg depend rumiai-web-control` exits 1 and `pkg install chromium` fails with `pkg-install` reason `request-unresolvable` (exit 4). The just-installed `nodejs` package declares facility compatibility `nodejs 26`, exactly matching one dependency. The current blocker is therefore isolated to Chromium package version resolution. On Linux x86_64 the current Chromium repository adapter resolves `Linux_x64/LAST_CHANGE` from Google Storage and then validates metadata for `Linux_x64/<revision>/chrome-linux.zip`. Both exact requests were physically executed with `http-fetch` on the affected host and succeeded: `LAST_CHANGE` returned revision `1715765`; metadata returned the expected object name `Linux_x64/1715765/chrome-linux.zip`, positive size `250950201`, MD5 Base64 `K1WRX8tQZSkH4aTq2QmC6A==`, and CRC32C `RUvhCw==`. Network access and current Google Storage endpoint shape are therefore not the blocker. A direct physical diagnostic of the current Chromium adapter then passed every stage: repository validation, MD5 conversion, JSON parsing, live metadata, latest resolution, and `pkg_repository_resolve_version` all returned success for revision `1715765`. The failure is therefore above standalone adapter version resolution. Current source inspection exposed a separate contract mismatch in the range-comparison path: `pkg_repository_compare_versions` validates upstream metadata for both compared Chromium revisions, while the current package specification explicitly defines range anchors as ordering metadata that must not require historical upstream availability when ordering is locally decidable. However, the next physical catalog diagnostic showed that this mismatch is not the current installation blocker: `pkg_catalog_range_resolve` for `chromium@1715765!linux-x86_64` succeeded and selected `n0001=1697793`. The same diagnostic incorrectly reported stream/request failure because the ad-hoc script had not initialized `m_OSARCH`; the direct comparator result from that script was also invalid because it used the empty stream path. The next physical diagnostic established the actual host target as `m_OSARCH=linux-arm64`. The local Chromium scan is clean (`rc=0`, no installed Chromium), but `pkg_catalog_stream_resolve` fails because current `pkg-catalog` has no `pkg/chromium/linux-arm64` stream (and no `all` fallback). This is the actual installation blocker; the earlier Linux x86_64 resolver investigation exercised a stream that is not applicable to this VM. Current `pkg/chrome` is also Linux x86_64-only. The current `rumiai-web-control` contract remains sound because it depends on facility `chromium =1`, not a specific package implementation. Playwright 1.63.0, already pinned inside `rumiai-web-control` v0.1.3, defines native Linux ARM64 Chromium/Chrome-for-Testing support (browser version `153.0.8010.12`, path `linux-arm64/chrome-linux-arm64.zip`). The physical ARM64 PoC confirms that the artifact downloads and executes (`Google Chrome for Testing 153.0.8010.12`). The ARM64 archive contains `chrome_sandbox`; after `root:root` + mode `4755`, exporting `CHROME_DEVEL_SANDBOX` changes Chromium's failure from `No usable sandbox` to `The setuid sandbox is not running as root` followed by `Failed to move to new namespace ... Operation not permitted`. This proves Chromium is finding and invoking the intended SUID helper, but the helper's effective UID is not becoming 0. The current Chromium source reports this condition when `geteuid() != 0`, naming parent `PR_SET_NO_NEW_PRIVS`/ptrace as causes; a `nosuid` mount can produce the same observable effect by suppressing setuid semantics. The mount/policy diagnostic resolved this: `/tmp` is a `tmpfs` mounted `nosuid`, while the real RumiAI package store is on the root `ext4` filesystem mounted without `nosuid`; the launching shell reports `NoNewPrivs: 0` and `TracerPid: 0`. Therefore the failed SUID-helper PoC was invalidated specifically by its `/tmp` placement, not by inherited no-new-privileges or tracing. The normal RumiAI package store can preserve setuid semantics. The final physical helper-location test succeeded: with `chrome_sandbox` copied to a root-owned directory on the package-store filesystem, set to `root:root` mode `4755`, and `CHROME_DEVEL_SANDBOX` pointing to that helper, `web-control-service` started successfully with normal sandboxing enabled. `web-control status` returned exit 0 with `browserRunning: true` and an `about:blank` page, and the service emitted its normal `ready` event. This physically validates the complete Linux ARM64 browser + SUID sandbox path required by current `web-control`.

## Current state

PoC 060 remains the wishlist-first experiment and passes Node syntax checking on the user's Linux test host. The earlier Linux ARM64 package blocker has now been implemented in the current repositories: `rumiai-os` contains the `chrome-for-testing` repository adapter, `pkg-catalog` contains `pkg/chromium/linux-arm64` using the Stable Chrome for Testing stream with the proven SUID sandbox environment, and `rumiai-tests` contains both the adapter contract test and a composed `external/rumiai-web-control/install-live.test`. A fresh physical run on the user's ARM64 VM pulled those revisions successfully, but `pkg install rumiai-web-control` stopped before Chromium installation with GitHub HTTP 403 during the dependency-planning phase and was reported as `dependency-unresolvable`; therefore the package revisions themselves have not yet passed the real end-to-end path. Source tracing shows the failing network operation occurs immediately after `pkg depend` opens its own catalog snapshot and before dependency-provider scanning, while current `pkg install` passes the already resolved concrete root `rumiai-web-control@v0.1.3` into `pkg depend`; the first repository operation there is the GitHub release lookup for that exact root. Node.js is already installed and compatible, so this failure is not caused by the new Node.js distribution adapter. PoC 059 remains diagnostic/fallback evidence for individual product pages. Sheets/Gmail/ChatGPT triggering remain intentionally outside the present experiment.

## Next action

On the user's Linux ARM64 VM, inspect GitHub's unauthenticated REST rate-limit status without consuming the primary limit, including the authoritative `x-ratelimit-*` headers / core remaining-reset values. If the observed 403 is a primary or secondary GitHub REST rate-limit condition, do not retry blindly; record the reset/retry boundary and then repeat the real package validation only when the upstream permits it. If the 403 is not rate limiting, capture the exact failing GitHub response and correct the repository path before proceeding. Once `pkg install rumiai-web-control` succeeds, select/start the `web-control` provider through the normal service path, confirm `web-control status` reports `browserRunning: true`, and only then run PoC 060 against the wishlist.

## Blockers / open questions

- The Linux ARM64 browser compatibility and sandbox mechanism are resolved, and the corresponding package/catalog/test integration exists in current HEADs. The first integrated physical run now fails earlier in dependency planning because the GitHub-backed `rumiai-web-control` root lookup receives HTTP 403. The root repository is public and an immediately preceding GitHub lookup in the same install path succeeded, so REST rate limiting is the leading explanation; confirm it from GitHub's rate-limit endpoint/headers before changing product logic. The current package implementation also differs from the canonical `PACKAGE-MODEL.md` install composition by pre-resolving roots before invoking `pkg depend`; that mismatch is real but should not be silently changed merely to mask the upstream 403.
- Real Amazon.it wishlist DOM, lazy-loading completion behavior and any internal continuation request must be observed on the user's browser session before the extraction/completeness policy can be considered reliable.
- The separate Google Sheets persistence and Gmail notification problems remain outside the current experiment.
