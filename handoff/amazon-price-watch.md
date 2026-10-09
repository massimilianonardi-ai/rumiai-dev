# Amazon Price Watch

Status: Active
Updated: 2026-10-08

## Goal

Replace the fragile model-driven Amazon Price Watch polling path with a deterministic application that uses the already-developed `web-control` runtime to observe Amazon.it product pages, while keeping the concrete Amazon-monitoring problem separate from the general RumiAI `web-control` / `web-sense` architecture work.

## Current repository revisions

- rumiai-dev: 6f22b79ae32e8645bc1f8454e08f949a7104bc77
- rumiai-dev-PoCs: 87508593ce64626e7ca82c4fa9d1d0c6db4a5a46
- rumiai-web-control: 8ed3ab888ecdc4970d90a6f14f0d7b7b93fce122
- rumiai-os: 6a964ba3f5c8acf462737e3b92daaf1af32de57e
- rumiai-tests: 89cd8308ba6a5272e7d4163864f5f28c1de88e66

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
- First physical attempt on the user's Linux test host reached the PoC preconditions but did not reach Amazon execution: `node` was initially absent, `pkg install nodejs` succeeded, and `node --check probe.mjs` passed. `rumiai-web-control` installation failed with `pkg-install` reason `request-unresolvable`; consequently `srv start web-control` failed with `provider-resolution-failed`. Current catalog inspection confirms package `rumiai-web-control` v0.1.3, facility `web-control` compatibility 1, and the upstream GitHub v0.1.3 release all exist. An immediate retry of `pkg install rumiai-web-control` later in the same physical session advanced past package request resolution and failed instead with `dependency-unresolvable`. Direct isolation then showed `pkg depend rumiai-web-control` exits 1 and `pkg install chromium` fails with `pkg-install` reason `request-unresolvable` (exit 4). The just-installed `nodejs` package declares facility compatibility `nodejs 26`, exactly matching one dependency. The current blocker is therefore isolated to Chromium package version resolution. On Linux x86_64 the current Chromium repository adapter resolves `Linux_x64/LAST_CHANGE` from Google Storage and then validates metadata for `Linux_x64/<revision>/chrome-linux.zip`. Both exact requests were physically executed with `http-fetch` on the affected host and succeeded: `LAST_CHANGE` returned revision `1715765`; metadata returned the expected object name `Linux_x64/1715765/chrome-linux.zip`, positive size `250950201`, MD5 Base64 `K1WRX8tQZSkH4aTq2QmC6A==`, and CRC32C `RUvhCw==`. Network access and current Google Storage endpoint shape are therefore not the blocker. A direct physical diagnostic of the current Chromium adapter then passed every stage: repository validation, MD5 conversion, JSON parsing, live metadata, latest resolution, and `pkg_repository_resolve_version` all returned success for revision `1715765`. The failure is therefore above standalone adapter version resolution. Current source inspection also exposed a contract mismatch in the range-comparison path: `pkg_repository_compare_versions` validates upstream metadata for both compared Chromium revisions, while the current package specification explicitly defines range anchors as ordering metadata that must not require historical upstream availability when ordering is locally decidable. The current permanent Chromium contract test encodes the older opposite expectation by requiring comparison to reject a syntactically valid but unavailable revision. Physical confirmation of the actual catalog range-resolution stage is still pending.

## Current state

PoC 060 now represents the wishlist-first experiment and passes Node syntax checking on the user's Linux test host. Amazon.it enumeration/completeness remains unvalidated because `rumiai-web-control` now resolves but dependency resolution fails before the `web-control` service can start. PoC 059 remains diagnostic/fallback evidence for individual product pages rather than the normal monitor entrypoint. Sheets/Gmail/ChatGPT triggering remain intentionally outside the present experiment.

## Next action

Run an isolated real-catalog diagnostic through `pkg_catalog_init`, `pkg_catalog_version_resolve`, `pkg_catalog_request_resolve`, and `pkg_catalog_range_resolve` for Chromium. Also call the Chromium comparator for the catalog anchor `1697793` versus current revision `1715765`. This will distinguish a request/catalog issue from the already-identified historical-anchor availability mismatch. Do not bypass `pkg` for the final installation path. Once Chromium resolution works, install `rumiai-web-control`, start `web-control`, and run PoC 060 against wishlist `33ZKBWLPZJJVO` with evidence capture enabled.

## Blockers / open questions

- Physical `rumiai-web-control` package request resolution now succeeds, but dependency planning fails because direct `pkg install chromium` on Linux x86_64 fails at package request/version resolution with `request-unresolvable`. The exact Google Storage `LAST_CHANGE` and metadata requests and the standalone Chromium adapter version-resolution path all succeed on the affected host. Current implementation/test semantics for Chromium version comparison conflict with the current package specification by requiring historical compared revisions to remain available upstream; the real-catalog range stage still needs physical confirmation as the immediate failure point.
- Real Amazon.it wishlist DOM, lazy-loading completion behavior and any internal continuation request must be observed on the user's browser session before the extraction/completeness policy can be considered reliable.
- The separate Google Sheets persistence and Gmail notification problems remain outside the current experiment.
