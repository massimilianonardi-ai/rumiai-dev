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
New GitHub repository reported empty at initial preflight. PoC source HEAD `962f5cc90a4c3e2d493a278618e120d7a335ac38`. At handoff creation `rumiai-dev` main advanced concurrently to `edea1cb2e6e4a9af56a7ad0a87474d87260d8e1f` for unrelated TextEdit state; no changes were overwritten.

## Next action
Initialize extraction-only project, `mk.json`, CI test/build/release and then package/catalog; perform proportionate validation and close handoff only when verified.
