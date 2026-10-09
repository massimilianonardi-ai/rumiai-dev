# Amazon Price Watch

Status: Active
Updated: 2026-10-08

## Goal

Replace the fragile model-driven Amazon Price Watch polling path with a deterministic application that uses the already-developed `web-control` runtime to observe Amazon.it product pages, while keeping the concrete Amazon-monitoring problem separate from the general RumiAI `web-control` / `web-sense` architecture work.

## Current repository revisions

- rumiai-dev: a56180ed515add7e4a395700e68c4d212429750d
- rumiai-dev-PoCs: 070076170dea9e3c60da50f6dfb19584359d26ed
- rumiai-web-control: 8ed3ab888ecdc4970d90a6f14f0d7b7b93fce122
- rumiai-os: 6a964ba3f5c8acf462737e3b92daaf1af32de57e
- rumiai-tests: 89cd8308ba6a5272e7d4163864f5f28c1de88e66
- pkg-catalog: 7d63806188414d5e872c7802bc59209375db9fa6

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
- First physical attempt on the user's Linux test host reached the PoC preconditions but did not reach Amazon execution: `node` was initially absent, `pkg install nodejs` succeeded, and `node --check probe.mjs` passed. `rumiai-web-control` installation failed with `pkg-install` reason `request-unresolvable`; consequently `srv start web-control` failed with `provider-resolution-failed`. Current catalog inspection confirms package `rumiai-web-control` v0.1.3, facility `web-control` compatibility 1, and the upstream GitHub v0.1.3 release all exist. An immediate retry of `pkg install rumiai-web-control` later in the same physical session advanced past package request resolution and failed instead with `dependency-unresolvable`. Direct isolation then showed `pkg depend rumiai-web-control` exits 1 and `pkg install chromium` fails with `pkg-install` reason `request-unresolvable` (exit 4). The just-installed `nodejs` package declares facility compatibility `nodejs 26`, exactly matching one dependency. The current blocker is therefore isolated to Chromium package version resolution. On Linux x86_64 the current Chromium repository adapter resolves `Linux_x64/LAST_CHANGE` from Google Storage and then validates metadata for `Linux_x64/<revision>/chrome-linux.zip`. Both exact requests were physically executed with `http-fetch` on the affected host and succeeded: `LAST_CHANGE` returned revision `1715765`; metadata returned the expected object name `Linux_x64/1715765/chrome-linux.zip`, positive size `250950201`, MD5 Base64 `K1WRX8tQZSkH4aTq2QmC6A==`, and CRC32C `RUvhCw==`. Network access and current Google Storage endpoint shape are therefore not the blocker. A direct physical diagnostic of the current Chromium adapter then passed every stage: repository validation, MD5 conversion, JSON parsing, live metadata, latest resolution, and `pkg_repository_resolve_version` all returned success for revision `1715765`. The failure is therefore above standalone adapter version resolution. Current source inspection exposed a separate contract mismatch in the range-comparison path: `pkg_repository_compare_versions` validates upstream metadata for both compared Chromium revisions, while the current package specification explicitly defines range anchors as ordering metadata that must not require historical upstream availability when ordering is locally decidable. However, the next physical catalog diagnostic showed that this mismatch is not the current installation blocker: `pkg_catalog_range_resolve` for `chromium@1715765!linux-x86_64` succeeded and selected `n0001=1697793`. The same diagnostic incorrectly reported stream/request failure because the ad-hoc script had not initialized `m_OSARCH`; the direct comparator result from that script was also invalid because it used the empty stream path. The next physical diagnostic established the actual host target as `m_OSARCH=linux-arm64`. The local Chromium scan is clean (`rc=0`, no installed Chromium), but `pkg_catalog_stream_resolve` fails because current `pkg-catalog` has no `pkg/chromium/linux-arm64` stream (and no `all` fallback). This is the actual installation blocker; the earlier Linux x86_64 resolver investigation exercised a stream that is not applicable to this VM. Current `pkg/chrome` is also Linux x86_64-only. The current `rumiai-web-control` contract remains sound because it depends on facility `chromium =1`, not a specific package implementation. Playwright 1.63.0, already pinned inside `rumiai-web-control` v0.1.3, defines native Linux ARM64 Chromium/Chrome-for-Testing support (browser version `153.0.8010.12`, path `linux-arm64/chrome-linux-arm64.zip`), making that exact browser stack the next physical PoC candidate before introducing a catalog/provider change.

## Current state

PoC 060 now represents the wishlist-first experiment and passes Node syntax checking on the user's Linux test host. Amazon.it enumeration/completeness remains unvalidated because `rumiai-web-control` now resolves but dependency resolution fails before the `web-control` service can start. PoC 059 remains diagnostic/fallback evidence for individual product pages rather than the normal monitor entrypoint. Sheets/Gmail/ChatGPT triggering remain intentionally outside the present experiment.

## Next action

Physically validate the exact ARM64 browser stack already matched to `rumiai-web-control`: unpack the v0.1.3 release in temporary storage, use its pinned Playwright 1.63.0 to download Chromium/Chrome-for-Testing `153.0.8010.12` for Linux ARM64 into a temporary browser path, verify the browser executable starts, and if practical start the controller directly with `WEB_CONTROL_BROWSER_EXECUTABLE` pointing at that temporary binary. This is PoC evidence only; do not treat the temporary Playwright download as the final installation path. If successful, add a proper `linux-arm64` provider for facility `chromium =1` through the current package model, then install `rumiai-web-control`, start `web-control`, and run PoC 060 against wishlist `33ZKBWLPZJJVO`.

## Blockers / open questions

- Physical `rumiai-web-control` package request resolution now succeeds, but dependency planning fails because direct `pkg install chromium` on Linux x86_64 fails at package request/version resolution with `request-unresolvable`. The actual VM target is `linux-arm64`, and current `pkg-catalog` provides no Chromium or Chrome stream for that target. Therefore `pkg install chromium` fails correctly at stream resolution; network, Google Storage, local package state and the Linux x86_64 adapter path are not the current blocker. A separate historical-anchor comparison contract mismatch remains real but unrelated to this installation. The next question is whether the Playwright 1.63.0 Linux ARM64 Chromium/Chrome-for-Testing artifact already matched to `rumiai-web-control` runs successfully on this VM and can become the basis of a proper `chromium =1` provider.
- Real Amazon.it wishlist DOM, lazy-loading completion behavior and any internal continuation request must be observed on the user's browser session before the extraction/completeness policy can be considered reliable.
- The separate Google Sheets persistence and Gmail notification problems remain outside the current experiment.
