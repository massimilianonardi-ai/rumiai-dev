# Facility default global projection

Status: Active
Updated: 2026-09-19

## Goal

Define and implement the global command/environment projection owned by a facility default, while preserving the existing package-default publication model, consumer-specific provider overrides and the technical m bootstrap boundary.

## Current repository revisions

```text
rumiai-dev       d034dcfca095a839200ce181908cf88381e3160e
rumiai-os        a1644b2238f17633d19cdf2e963c7cc8f09dfa6a
rumiai-tests     322cee67192e38c828145325131c9fe6d0574c40
pkg-catalog      bd06488d3c67160e820c04d13067f852c8861c32
rumiai-dev-PoCs  af61caccde43151ef83a96b8988536f9aa997a0b
```

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

- Global facility publication is command publication only; `facility-env` remains consumer-launch projection and is not injected into ambient `m`/shell state.
- Global facility commands reuse the existing `bin/ext` and `bin/ext-<osarch>` roots.
- Unversioned facility-default selectors publish through provider package-default selectors; versioned selectors publish through pinned concretes.
- Consumer-specific bindings do not alter global facility command publication.
- Publication must preserve external-command ownership and fail on unrelated command-name collisions.

## Working design

The remaining implementation design is transactional/mechanical rather than semantic:

- reconcile command sets when a facility default changes;
- reconcile unversioned facility projections when a provider package default changes and the selected concrete exposes a different command set;
- preserve/restore existing valid projections on failed transitions as far as the package-default mutation contract requires.

No bootstrap or shell environment mechanism is added by this task.

## Completed

- Previous provider/facility realignment is complete and validated.
- Current provider metadata already materializes generic `facility-cmd` and `facility-env` data.
- Current consumer launch re-resolves provider selection and applies those projections generically.
- Current package defaults publish package-owned commands into `bin/ext[-osarch]`.
- Current bootstrap/PATH, osarch selection and shell startup behavior were inspected for reuse boundaries.
- PoC 011 (`rumiai-dev-PoCs@cb8c5d636ce65e6cb00626ed08947fe25a25988e`) validated selector-preserving global command links, pinned selectors, independent osarch projections and exact-target collision ownership; GitHub Actions run `35425864532` PASS.
- The global-command / consumer-environment distinction was promoted into `PACKAGE-MODEL.md`.

## Current state

The global facility command publication contract is now settled and canonical, but implementation is still pending. Facility defaults currently store selector intent only and do not publish facility commands.

## Next action

Implement global facility command publication in the package subsystem, add permanent regression coverage and validate provider-default plus provider-package-default transitions.

## Blockers / open questions

- transactional rollback details when a facility-default or provider-package-default transition fails after partial filesystem mutation.
