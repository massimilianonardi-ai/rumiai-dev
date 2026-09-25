# Package facility integration validation deduplication

Status: Complete
Updated: 2026-09-25

## Goal

Remove duplicated cmd/env facility-realization validation from `pkg-integration.lib.sh` by reusing the trusted facility typed-part handlers without changing package semantics or introducing catalog context into integration.

## Current repository revisions

Final task-state checkpoint:

```text
rumiai-dev    da58ede73cb5264a7add861a11e68107f463eb45  (pre-final-snapshot HEAD)
rumiai-os     b66891732a99addbacba574aaf53779284319e16
rumiai-tests  318500723ee2674d951b9ab5a8df584adcd2db08
pkg-catalog   da9b8989088c8b3f2d8201ad09e5f7180f334a16
```

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
```

## Fixed task-local choices

- `pkg_integrate` remains independent of `pkg-catalog` context.
- Trusted typed-part handlers own realization-local cmd/env/service validation.
- Integration retains package-definition envelope checks and the requirement that every realization facility is declared by the package.
- Provider conformance retains exact facility-contract membership checks.

## Completed

- `rumiai-os@6eca0babbdcf8a71aab81ce69692aee6f7f98e70` introduced `_pkg_facility_cmd_realization_validate` and `_pkg_facility_env_realization_validate`.
- Cmd/env provider validators compose those realization validators with exact contract membership checks.
- `pkg-integration.lib.sh` now reuses the trusted cmd/env/service realization validators instead of maintaining duplicate realization semantics.
- The affected facility/integration operational manuals were aligned in the same product change.
- Current product `b668917...` still contains that structure. The delta after the formal closure validation target is unrelated rsudo work.
- Current permanent `pkg-integration/contract.test` exercises valid shared cmd/env realizations and rejects escaping/invalid cmd/env realizations through the real integration path.
- In formal validation `20260925T153805+0000-1309`, `rumiai-os/pkg-integration/contract.test` passed on hosted Darwin/arm64 against `rumiai-os@baee6bf1b356d4855ab3eaf390ca8ee64f86508c` with `rumiai-tests@318500723ee2674d951b9ab5a8df584adcd2db08`.

## Current state

The deduplication goal is implemented, documented and protected by observable integration coverage. No catalog context was introduced into integration and no package/default/binding/service semantic change remains pending.

## Next action

None.

## Blockers / open questions

None.
