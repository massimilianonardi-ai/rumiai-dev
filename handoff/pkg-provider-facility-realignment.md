# Package provider/facility realignment

Status: Complete
Updated: 2026-09-19

## Goal

Realign package/provider/facility semantics, implementation, catalog representation and permanent tests so package identity remains distinct from facility identity, provider selection is explicit and mutable, and consumers receive provider runtime projection through the generic package launcher.

## Current repository revisions

```text
rumiai-dev baseline  20b6926a061da4e52a08baa36a0bd1e0f7cd9e84
rumiai-os            b4df991dcfbea71e2ef2aa091e3daca7d1954a01
rumiai-tests         322cee67192e38c828145325131c9fe6d0574c40
pkg-catalog          bd06488d3c67160e820c04d13067f852c8861c32
rumiai-dev-PoCs      af61caccde43151ef83a96b8988536f9aa997a0b
```

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`

## Fixed task-local choices

None. Durable provider/facility semantics are promoted into the canonical package contract.

## Completed

- Package identity and facility identity are separate; multiple installed providers of the same facility are supported.
- Temurin is a concrete `temurin` package and GraalVM is a distinct package; both provide `java 25`.
- `pkg provider default` and `pkg provider bind` implement system facility defaults and per-consumer selector bindings.
- Dependency resolution uses explicit consumer binding first, otherwise facility default, with no implicit single-provider fallback and no automatic dependency-provider installation.
- Provider selectors retain intent: unversioned selectors follow package defaults; explicit versions remain pinned.
- Integration validates dependencies but does not materialize install-time concrete bindings.
- Runtime launch re-resolves the effective selector and generically applies declarative `facility-cmd` and `facility-env` projections.
- Uninstall protects concrete providers referenced by current provider-selection configuration.
- Temurin/GraalVM catalog definitions materialize Java command and `JAVA_HOME` projections on supported platforms.
- Maven and Keycloak consume Java only through dependency/provider projection; provider-specific package environment logic was removed.
- All 64 current catalog command wrappers were realigned to the grouped `lib/sys/sh/pkg/pkg-launch.lib.sh` path.
- Permanent tests cover provider configuration, selector precedence, late binding, package-default following, pinned selection, incompatible-provider rejection, no install-time binding, runtime rebinding, projection precedence, provider coexistence and live Maven/Keycloak consumption.
- Operational manuals for the affected `pkg` command and package libraries match their current public interfaces and do not expose internal helpers.
- Current hosted validation on exact revisions succeeded:
  - structural provider-model run `35425393903`: PASS;
  - live provider/runtime run `35425395236`: PASS, 8/8 matrix jobs.
- Final static consistency scan found no residual highest-compatible-provider uniqueness mechanism, provider-specific Maven/Keycloak Java wiring or pre-grouping catalog launcher path.

## Current state

The provider/facility realignment defined by the current package contract is implemented, represented in the catalog, covered by permanent tests and validated against the revisions above.

The separately required future global command/environment publication owned by a facility default remains intentionally outside the current package contract's concrete mechanism and is tracked as deferred work in `todo/facility-default-global-projection.md`.

## Next action

None for this task.

## Blockers / open questions

None.
