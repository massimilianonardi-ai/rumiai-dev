# Amazon wishlist extractor release

Status: Active
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

## Current state
- New project initialized, provider-neutral parser, probe and `extract(url, options)` API promoted without private wishlist URLs or Price Watch modules. Product sources `amazon-wishlist-extract@edd527522d826e2af25d35165e6a3b7dab4d51c2`; release v0.1.0 is independently visible with exact asset `amazon-wishlist-extract-v0.1.0-all.tar.gz`, SHA-256 `176935befbf5729411d9548c197a9f1282d82eb5c2846de4483871de21d2ab98`. Release target commit is `ba0d5028b1b387567e260aac26cd2097ad10d42b`; later changes have only expanded CI.
- Canonical `mk` check/test/build and hosted Linux, macOS, and **real Electron local-fixture** pipelines passed in run `38218254944`. Release job succeeded. No physical Amazon.it acceptance is inferred.
- `pkg-catalog@6c63b6a014aaaa0d2ebc2f109a216c9ea71fcf5e` publishes independent `pkg/amazon-wishlist-extract/all/n0001=v0.1.0` with an external CLI and exact runtime dependencies `web-control =2`, `nodejs =26`, and no new invented facility.
- Full packaged smoke workflow `38218584301` passed Linux/macOS/Electron/release; real `pkg install` integration job is in progress at this checkpoint. A previous failing pipeline `38218097517` was corrected forward, not hidden or overwritten.

## Next action
Check packaged smoke result, resolve any demonstrated launch/catalog defects forward, reconcile source/catalog/handoff after final verification; close release handoff when acceptance is genuinely satisfied.
