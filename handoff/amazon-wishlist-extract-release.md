# Amazon wishlist extractor release

Status: Complete
Updated: 2026-10-12

## Goal
Promote only the extraction component of PoC 060 into the new independent `amazon-wishlist-extract` GitHub repository, release a versioned runnable archive and add its installable definition to `pkg-catalog`.

## Applicable canonical sources
`README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `CURRENT-MODEL.md`, `MK.md`, `WEB-CONTROL.md`, `PACKAGE-MODEL.md`, `TESTING.md`, `handoff/amazon-price-watch.md`.

## Fixed choices
- The user explicitly authorized this independent release unit.
- Only provider-neutral wishlist extraction/API/CLI and tests are promoted. Price Watch decisions, reports, Sheets, Gmail and scheduling stay in their current PoC/parent handoff.
- Consumer requires facility `web-control =2` and managed Node.js, without a new invented facility.
- `mk` owns development/build and `pkg` owns installation and dependencies.
- Never copy the user's wishlist IDs or account/profile data into the distributed project.

## Acceptance
A versioned repository and release archive with runnable package dependencies; isolated parser/API tests plus real Electron browser fixture; catalog entry resolving the release and launching a CLI through the ordinary `pkg` path; no claim that an untested authenticated Amazon wishlist is complete.

## Final completed state (2026-10-12)
- Source project: `massimilianonardi-ai/amazon-wishlist-extract`, source-release commit `ba0d5028b1b387567e260aac26cd2097ad10d42b`, with independent `mk.json`, CLI and reusable `extract(url, options)` API. Subsequent commits on main only adjust CI.
- Immutable GitHub release: `v0.1.0`, archive `amazon-wishlist-extract-v0.1.0-all.tar.gz`, 1,568,712 bytes, SHA-256 `176935befbf5729411d9548c197a9f1282d82eb5c2846de4483871de21d2ab98`; release asset and target were verified through the GitHub API.
- `pkg-catalog@23487b42d832b1f4c8a109bba18702cd769df888`: `pkg/amazon-wishlist-extract/all/n0001=v0.1.0`; dependency declarations strictly sorted as `nodejs =26`, `web-control =2`; package command template non-executable mode `100644`, runtime archive's bin executable remains executable; no invented Amazon facility.
- GitHub Actions run `38219877632` completed SUCCESS across Linux canonical `mk check test build`, macOS tests, real Electron local dynamic-wishlist fixture test, immutable release confirmation, and real `pkg` install/launcher on a clean Linux runner. The package integration job explicitly installed Electron v0.1.4, selected it for `web-control 2`, installed `amazon-wishlist-extract@v0.1.0`, verified the projected command and ran the actual installed launcher with an expected missing-URL usage error. It did **not** execute an authenticated Amazon.it extraction through the installed package.
- Earlier red runs were corrected by forward commits only: product tests need an explicit test URL; Electron sandbox test path was corrected; package dependency metadata needed lexical order; provider selection is explicit rather than silently arbitrary; catalog package command templates must be non-executable. No product artifact was overwritten.
- `rumiai-dev-PoCs@67eac275fc70840d6e8fb1d17514caf6ac18a7b5` README points future consumers to the standalone extractor, preserving historical PoC and independent Price Watch experiment.
- Final consistency review checked released source avoids private wishlist IDs and provider-specific CDP calls; read current `CURRENT-MODEL.md`, `WEB-CONTROL.md`, `MK.md` and `PACKAGE-MODEL.md` contracts; verified actual hosted execution results. No change to `rumiai-os` or user browser profiles.

## Remaining outside release task
Physical, authenticated Amazon.it Watch and Star Wars extraction completeness/price acceptance; practical integration into Amazon Price Watch's monitor/sheet/email pipeline; and scheduling remain owned by the ongoing `handoff/amazon-price-watch.md` and were not claimed complete here.
