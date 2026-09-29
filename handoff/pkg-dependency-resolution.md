# pkg dependency resolution usability and install preflight

Status: Active
Updated: 2026-09-29

## Goal

Realign the package dependency/provider model so manual configuration remains available without becoming an unnecessary blocking prerequisite; improve install/runtime diagnostics and preflight; identify and fix adjacent package-pipeline weaknesses exposed by real package use.

## Current repository revisions

- rumiai-dev: 72c7a698f375c00c19c0c15e589c62af59593687
- rumiai-os: 82c93374609dacb0a3af1f71c24cfc7345403ca0
- pkg-catalog: d63f87d2be67288ef57f4a5812fabbc3f0b24a0d
- rumiai-tests: 36768a3f6ee41d0c2a8d30184e3f92c275dcce5f

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
- Without either, exactly one compatible installed provider should resolve implicitly; zero is unresolved and more than one is ambiguous.
- Installation must not require runtime provider selection to already be configured.
- Dependency/provider diagnostics must expose the facility, constraints and resolution reason rather than only a generic failure code.

## Completed

- Reproduced that Keycloak declares only `java =25`.
- Confirmed current tests deliberately require failure when a compatible provider is installed but no binding/default exists.
- Confirmed current installation checks dependency resolution only late inside `pkg_integrate`.
- Confirmed stale provider-index state can block provider installation with a generic `provider-index-failed`.

## Current state

Contract, implementation and tests are inconsistent with the newly corrected desired operating model and must be changed together.

## Next action

Inspect provider/dependency resolution, install/integration pipeline, public query surfaces and provider-index lifecycle; implement the corrected model and proportional tests.

## Blockers / open questions

None.