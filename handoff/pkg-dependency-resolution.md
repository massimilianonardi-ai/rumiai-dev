# pkg dependency resolution usability and install preflight

Status: Active
Updated: 2026-09-29

## Goal

Realign the package dependency/provider model so manual configuration remains available without becoming an unnecessary blocking prerequisite; improve install/runtime diagnostics and preflight; identify and fix adjacent package-pipeline weaknesses exposed by real package use.

## Current repository revisions

- rumiai-dev: 17193959db406db95ed2af9aed097e5e13d068ae (pre-change base)
- rumiai-os: 42e542d24d380c91ed30369a24553f43099a0e3a
- pkg-catalog: d63f87d2be67288ef57f4a5812fabbc3f0b24a0d
- rumiai-tests: d04246cf97806be66afe89feabccca71d3b2c000

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/PACKAGE-MODEL.md

## Fixed task-local choices

- Do not auto-install missing dependency providers.
- Do not silently choose among multiple compatible installed providers.
- An explicit consumer binding remains highest precedence.
- A configured facility default remains explicit preference.
- Without binding/default, package consumers resolve an unambiguous compatible installed provider; multiple compatible versions of one provider package may be disambiguated by that package's default, while multiple provider packages remain ambiguous.
- Installation must not require runtime provider selection to already be configured or currently satisfiable.
- Dependency/provider diagnostics must expose the facility, constraints and resolution reason rather than only a generic failure code.

## Completed

- Implemented package-consumer implicit installed-provider resolution with explicit binding/default precedence and detailed failure reasons in rumiai-os `10db3ea43fd654c5e5bcf0f13cb64e2d4fa455fa`.
- Decoupled package integration from runtime dependency satisfiability, added pre-download dependency-metadata validation and install-time unresolved-dependency warnings in rumiai-os `42e542d24d380c91ed30369a24553f43099a0e3a`.
- Removed provider-index mutation from integration/deintegration; installed concrete facility metadata now drives provider discovery, so stale legacy index markers are inert.
- Added internal support for public `pkg requirement list <package-spec>` catalog queries without artifact download.

- Reproduced that Keycloak declares only `java =25`.
- Confirmed current tests deliberately require failure when a compatible provider is installed but no binding/default exists.
- Confirmed current installation checks dependency resolution only late inside `pkg_integrate`.
- Confirmed stale provider-index state can block provider installation with a generic `provider-index-failed`.

## Current state

Core rumiai-os implementation is realigned. Canonical package model is being updated in this work unit; manuals and permanent tests still need realignment and validation.

The global/non-package `pkg requirement resolve` query intentionally remains facility-default-only because it has no package-consumer runtime projection path. Implicit fallback applies to package consumers.

## Next action

Align rumiai-os manuals and rumiai-tests, validate the public composed paths, then run the final consistency gate.

## Blockers / open questions

None.