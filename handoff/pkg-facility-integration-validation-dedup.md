# Package facility integration validation deduplication

Status: Active
Updated: 2026-09-21

## Goal

Remove duplicated cmd/env facility-realization validation from `pkg-integration.lib.sh` by reusing the trusted facility typed-part handlers without changing package semantics or introducing catalog context into integration.

## Current repository revisions

```text
rumiai-dev      4e12536cabeec5e5b6698db2dabef49f45030a97
rumiai-os       470f36729cf1ff8b64c4a8534e79b0f82d047258
rumiai-tests    f384b9da79b467d8cdb6e26482b5ef350d543af4
pkg-catalog     12ea704ee4e25e62ab3ed0125133660b4e0c42cb
rumiai-dev-PoCs ab470307cb8a3e26d57b798fe021109209d66792
```

Fresh remote HEAD retrieval remains mandatory before writes.

## Applicable canonical sources

```text
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
TESTING.md
TEST-PATTERNS.md
```

## Fixed task-local choices

- `pkg_integrate` remains independent of `pkg-catalog` context.
- Trusted typed-part handlers own type-specific realization validation.
- Integration retains its own responsibility for package-definition envelope checks and for requiring every realization facility to be declared by the package.
- Provider conformance retains exact contract membership checks; integration performs only realization-local structural/target validation.
- No package/default/binding/service semantics change is authorized or required by this refactor.

## Completed

- Fresh preflight and current-source inspection completed.
- Confirmed duplicate cmd/env realization logic still exists in `pkg-integration.lib.sh`.
- Confirmed the service typed-part already follows the desired split through `_pkg_facility_service_realization_validate`.

## Current state

The cmd/env handlers expose contract-aware provider validators but do not yet expose internal realization-only validators reusable by integration. `pkg-integration.lib.sh` still independently implements command realization and environment realization validation.

## Next action

Introduce internal cmd/env realization validators in the trusted handlers, refactor provider validators to compose them with exact contract checks, replace duplicated integration logic with those handlers, then run targeted permanent/formal validation.

## Blockers / open questions

None currently.
