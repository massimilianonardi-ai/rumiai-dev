# Amazon Price Watch

Status: Active
Updated: 2026-10-10

## Goal

Replace the fragile model-driven Amazon Price Watch polling path with a deterministic application that uses the already-developed `web-control` runtime to observe Amazon.it product pages, while keeping the concrete Amazon-monitoring problem separate from the general RumiAI `web-control` / `web-sense` architecture work.

## Current repository revisions

- rumiai-dev: a26e3b089c58665be244cd778974d7155929b55b
- rumiai-dev-PoCs: 3dc9480baf4b112c263935a9e52cc1104c981936
- rumiai-web-control: 8ed3ab888ecdc4970d90a6f14f0d7b7b93fce122
- rumiai-os: 382369cfde55b158bdf9bb8c7c7ba352fb00ca5e
- rumiai-tests: 345ef3837e3184058453789e78b46344b2a665b9
- pkg-catalog: 9e1a24277de4f203c9796c50c04d2ad73395b0fa

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/WEB-CONTROL.md
- specifications/rumiai-os/PACKAGE-MODEL.md
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

## Physical wishlist-price evidence (2026-10-10)

- User-run Linux ARM64 PoC 060 completed wishlist enumeration: 54 unique ASINs, 20 rounds, 14 observed network requests, no detected challenge. Initial price verification was 0/54; 44 items yielded a container candidate and 10 none. This is user-reported physical evidence, not a fresh execution by the assistant.
- All 44 candidates were from the generic `[id^="itemPrice_"]` container and contained two euro values. The user supplied actual wishlist DOM for ASIN B0DPHTGJ4B: `span[id^="itemPrice_"].a-price > span.a-offscreen` carries current 495,47 EUR, with an aria-hidden sibling repeating its visual representation. A separate neighboring `.wl-deal-price-and-striked-price` section contains a labeled 30-day-low reference of 521,55 EUR.
- PoC 060 now selects the accessible current-price text within the price widget and checks the widget's visibility instead of excluding the intentionally offscreen child. No individual product-page navigation is introduced. Synthetic fixture selector was aligned. Commits in rumiai-dev-PoCs: 489f383, c3b300d.
- **Pending:** run synthetic test and fresh physical PoC 060 on the user's VM; verify current-price count and reference ASIN. Confirm whether the 10 products with no price are actually unavailable rather than assuming so. Preserve explicit unverified results where evidence is insufficient.

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

## Package discovery workstream (active)

The catalog's immutable version history is separate from live upstream `latest`; an unavailable latest request fails explicitly with a suggested pinned version, never a silent historical fallback. Known GitHub releases are ordered by upstream creation/publication chronology, not by parsing SemVer. The normal install path must keep using the public `pkg` composition.

### Verified work checkpoints (2026-10-10)

- `rumiai-os` `382369c` implements local comparisons and explicit known-version resolution when both tags are indexed, live resolution for missing tags/latest, contextual upstream transfer diagnostics and an explicit historical-version hint when latest discovery fails. Library manuals were updated.
- `rumiai-tests` `345ef38` repaired the legacy catalog fixtures by removing `repository/version` fields that were invalid for the actual GitHub adapter. The obsolete dependency test was replaced with a real public `pkg depend` scenario (earlier `82b1a4c`). The test of the historical-index/latest failure hint and Chromium sandbox path is also present.
- **Real hosted validation:** `web-control-package` GitHub Actions run `38043194476` completed **VALIDATED on both Linux x86_64 and Ubuntu 26.04 ARM64** (both jobs success), including `pkg/catalog.test`, `pkg/depend.test`, GitHub adapters, real Chromium installation and the `rumiai-web-control` install/start/inspect/relaunch path. This result used the catalog snapshot before automatic population of the other 36 streams.
- `pkg-catalog` `d3a2607` is a real successful, bot-authored forward-only commit from GitHub Actions run `38043558949` (success). The job queried 10 GitHub release repositories and populated **36** stream-local `repository/versions` histories (164 indexed lines). The script now stops scanning at the most recent known release during incremental refresh; on first discovery and weekly reconciliation, it stops at the earliest supported range/history anchor rather than enumerating unrelated pre-catalog releases. This change resolved an observed GitHub HTTP 422 for Electron after REST pagination exceeded the relevant range. The workflow runs daily and invokes its full reconciliation mode on Sundays. Authentication uses the ephemeral workflow token.
- The first hosted sync attempt `38043468377` had discovered 36 streams but lost its publication race against a concurrent forward commit (`git push` correctly refused a non-fast-forward); the succeeding run `38043558949` published against a fresh HEAD with no history rewrite.
- A targeted repeat of both Ubuntu 26.04 ARM64 and Ubuntu x86_64 `web-control-package` jobs against the newly populated catalog completed with success and `Scope result: VALIDATED` for the ARM64 run. The original two-platform validation remains recorded in run `38043194476`; reruns belong to its later attempts and must not be attributed to the original snapshot.
- `pkg-catalog` later commit `9e1a242` adds safe bounded full reconciliation when incremental scanning observes a new historically earlier release. GitHub Actions `38043914285` had correctly refused a nonconforming incremental observation for DBeaver; the follow-up live job `38043975075` finished successfully, verified 10 repositories and reported **histories updated: 0**, with no generated data commit. This is real no-change/idempotence evidence, not a unit proof of every edge case. A separate workflow-only idempotence check was attempted but blocked and is unnecessary to claim the observed no-change result.

### Physical ARM64 validation blocker (2026-10-10, user VM)

The user ran `pkg install rumiai-web-control` on `vmdev` from `/m/src/git/rumiai-os_TEST`. The package cache Git fast-forwarded `pkg-catalog` from `f0cdadb` to `9e1a242`, but install returned `[fatal] [operation="pkg-install"] [reason="dependency-unresolvable"]`. Subsequent `srv start web-control` returned `provider-resolution-failed` and the `web-control` command was absent. These are downstream symptoms of the incomplete install; the physical VM install has **not** passed.

The current catalog `rumiai-web-control@v0.1.3` declares exactly `chromium =1` and `nodejs =26`. `pkg/chromium/linux-arm64` and `pkg/nodejs/linux-arm64` are present, so the failure cannot be attributed merely to a missing Linux ARM64 catalog stream. Current hosted clean-environment validation passed, but this does not establish the user's local `rumiai-os` checkout HEAD or package/provider state.

The subsequent physical diagnostics established a decisive revision mismatch. The VM working tree `/m/src/git/rumiai-os_TEST` reports **`rumiai-os@016c95dbfa384d5259a6200498c905b9bb8b61e0`**, whereas remote `rumiai-os/main` is **`382369cfde55b158bdf9bb8c7c7ba352fb00ca5e`**. Thus the VM downloaded the recent `pkg-catalog@9e1a242` but its command runtime predates the indexed-release lookup and related dependency/diagnostic changes. Its `pkg depend rumiai-web-control` returned status 1 with no diagnostic, `pkg versions chromium` showed no installed Chromium, `pkg versions nodejs` returned `nodejs@v26.11.1!linux-arm64`, and neither the Chromium nor Node.js facility had a configured default. This evidence **does not yet prove** which dependency step would fail on the current runtime; the stale runtime must be eliminated as a test variable before attributing the failure to the catalog or provider state.

The VM checkout is materially dirty: tracked `.gitignore`, `README.md`, `product-name` and `product-version` are locally deleted, while `bin/ext-linux-arm64/`, `bin/ext/`, `pkg/`, `src/`, and several `state/` areas are untracked. These may contain valuable user/test state; **do not reset, clean, or pull over this checkout**. Next physical step is a **separate new clone** of the current `rumiai-os/main` in a sibling location on the same suitable filesystem. Use its own `./m pkg depend rumiai-web-control` and capture output/status before invoking install; do not silently reuse the old checkout's executable or mutable package store. If that read-only dependency plan works, test `./m pkg install rumiai-web-control` and then provider/service from the fresh root, retaining the prior checkout untouched. Hosted `VALIDATED` results are not physical evidence for this old user checkout.

### Current boundaries

PoC 060 has a wishlist-first, deterministic scroll/ASIN/price/network-probe implementation in `rumiai-dev-PoCs`, but has **not yet been exercised on the user's Ubuntu ARM64 VM against the real Amazon.it wishlist**. Commits `875620a` and `133553a` added rejection of HTTP 4xx/5xx and redirects outside the Amazon.it wishlist path (including login), plus an isolated mock CLI test for a valid wishlist, HTTP 503 and login redirect. PoC workflow `38044257053` passed syntax and synthetic command-boundary scenarios without contacting Amazon or publishing real wishlist data. These tests do not prove real Amazon DOM selector or scrolling behavior. Existing hosted package/live-browser validation proves the runtime path, not correctness of Amazon wishlist extraction. On the user's VM the mounted filesystem and browser profile matter; a GitHub runner does not have access to that authenticated session. Do not publish private wishlist observations or cookies in public workflow logs.

### Next action

1. Add bounded-history reconciliation edge-case tests (new release, chronology ambiguity, pagination boundary and upstream failure without partial writes) if advancing the package subsystem further; record the observed no-change scheduler validation `38043975075` separately.
2. On the user's Ubuntu ARM64 VM run normal `pkg install rumiai-web-control`, `srv start web-control`, `web-control status` and the actual `pocs/060-amazon-wishlist-web-control/probe.mjs`. Capture only appropriately private evidence; measure completeness/access challenges and compare observed browser-driven lazy loading with any candidate internal API.
3. Only after real wishlist observation passes, decide how to integrate deterministic price state and separate notifications. Google Sheets and Gmail are not part of the present experiment.

## Blockers / open questions

- No outstanding failure in the **validated hosted web-control package scope** at `rumiai-tests@345ef38`. The first full x86_64/ARM64 run and the two targeted reruns against the newly populated catalog both completed successfully; the final Amazon application remains a separate physical acceptance target.
- The older REST HTTP 403 was precisely at a GitHub release-tag comparison endpoint. Indexed known versions now avoid redundant history comparisons; upstream availability, `latest`, artifact metadata and transfers can still fail independently, with explicit errors/hints rather than silent fallback.
- The remaining primary application evidence gap is real Amazon.it wishlist DOM, scrolling/completeness and any continuation calls on the user's own browser profile.
- Google Sheets persistence and Gmail notifications remain outside scope.

## Physical validation — 2026-10-10

User executed PoC 060 on Linux ARM64 after the current-price DOM fix. Synthetic command-boundary scenarios: PASS. Real wishlist run: `complete: true`, `blocked: false`, 54 items, 44 verified prices, 10 without verified prices. Reference ASIN B0DPHTGJ4B: verified current price 495.47 EUR, matching wishlist DOM. Result file `private-poc060/result-new.json` (83 KB); stderr file empty. No product-detail navigation was required. This validates current-price extraction for 44/54 items, not availability classification for the other 10. Next: inspect only sanitized reasons/availability indicators for the remaining 10; do not claim they are unavailable without evidence. The user's terminal unexpectedly closed during execution, but the result JSON was subsequently read successfully.
