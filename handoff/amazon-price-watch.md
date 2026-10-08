# Amazon Price Watch

Status: Active
Updated: 2026-10-08

## Goal

Replace the fragile model-driven Amazon Price Watch polling path with a deterministic application that uses the already-developed `web-control` runtime to observe Amazon.it product pages, while keeping the concrete Amazon-monitoring problem separate from the general RumiAI `web-control` / `web-sense` architecture work.

## Current repository revisions

- rumiai-dev: 23be3c39ddae8a4c069698639d2d151674597717
- rumiai-dev-PoCs: 394e8d5831e63be7e529db617c3c49328da9bbcd
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
- The existing spreadsheet has two monitored tabs, `Watch` and `Star Wars`, with the same operative first twelve columns: ASIN, description, current price, previous-price difference, monitored minimum, target, target distance, status, Amazon note, Amazon URL, last check, notified target.
- For the current phase, Google Sheets and Gmail are explicitly outside the experiment. The first question is only whether Amazon.it price observation can be made deterministic through `web-control`.
- Unverified or ambiguous prices must never be treated as verified prices. Access blocks, CAPTCHA/challenge pages, ASIN mismatch and ambiguous price candidates must produce an explicit failure result rather than a guess.

## Acceptance scenarios

1. Given one Amazon.it ASIN, a deterministic program invokes only public/current `web-control` operations and returns either a verified EUR price with page evidence or an explicit unverified reason.
2. Given several ASINs, one blocked/unavailable/ambiguous product does not cause a price guess and does not invalidate verified results for the other products.
3. The probe detects common Amazon access failures such as CAPTCHA, Robot Check, HTTP errors and equivalent challenge pages.
4. No model, ChatGPT session, Google Sheet write or Gmail action is required for the Amazon observation probe.

## Working design

The existing PoC 054 (`amazon-wishlist-browser-probe`) already contains useful deterministic Amazon diagnostics: final URL/status, CAPTCHA/Robot Check/service-error detection and ASIN extraction from rendered DOM. The next experiment should reuse those observations through the current `web-control` command surface instead of launching Playwright directly.

The first deterministic extractor should:
- open `https://www.amazon.it/dp/<ASIN>` through `web-control`;
- inspect the rendered page after bounded polling;
- verify navigation/access health and requested-ASIN identity;
- collect a deliberately small prioritized set of current-price DOM candidates from the product/buy-box price areas;
- parse EUR values deterministically;
- accept a price only when the evidence is non-blocked, ASIN-consistent and non-ambiguous;
- emit machine-readable JSON including evidence/reason even when unverified.

The current `web-control` baseline is sufficient for this experiment: page creation/navigation, rendered text/HTML inspection, capture, and the current CDP extension for deterministic DOM evaluation are available. This experiment does not promote Amazon-specific selectors or CDP use into the provider-independent `web-control` contract.

Once Amazon observation itself is validated, the existing ChatGPT task logic is mostly ordinary deterministic state logic: previous/current price, monitored minimum, target state, target-notified state and alert thresholds. Spreadsheet persistence and notification delivery are separate integration problems and should be added only after the Amazon observation layer is proven.

## Completed

- Recovered the current ChatGPT `Amazon Price Watch` task behavior and cadence.
- Inspected the current `Amazon Price Monitor` spreadsheet read-only and confirmed the shared operative schema of `Watch` and `Star Wars`.
- Inspected current `web-control` implementation and verified the primitives needed for a deterministic Amazon product-page probe.
- Recovered PoC 054 as prior evidence and a source of Amazon block-detection logic.

## Current state

The deterministic translation appears feasible. The only materially uncertain part that needs physical validation is reliable Amazon product-price extraction through the user's persistent `web-control` browser session. Sheets/Gmail/ChatGPT triggering are intentionally not part of the present experiment.

## Next action

Create a new PoC that drives current `web-control` against Amazon.it `/dp/<ASIN>` pages and emits verified/unverified JSON price observations. Validate it first on a small sample of real ASINs from the existing monitor before adding any spreadsheet or notification integration.

## Blockers / open questions

- Real Amazon.it DOM/price variants must be observed on the user's browser session before the selector/evidence policy can be considered reliable.
- The separate Google Sheets persistence and Gmail notification problems remain outside the current experiment.
