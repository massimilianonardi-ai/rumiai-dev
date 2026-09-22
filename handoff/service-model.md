# Service model

Status: Complete
Updated: 2026-09-22

## Goal

Complete and physically validate the service/facility/pkg model connecting portable
`srv` lifecycle, package-provided service facilities and explicit user/system host
supervision without introducing a duplicate service registry, provider graph or
dependency graph.

GeoServer 3.0.1 is the real reference service provider and Temurin Java 21 its real
dependency provider.

## Closure revisions

Current remote HEADs observed immediately before this final snapshot:

```text
rumiai-dev      7081d078fdd6e57947f3dbc86b83a67c291c9ba6
rumiai-os       926179d3cb8808623dfe6f0bfed1e982dd0763ee
rumiai-tests    99ac706e6e6b1aac4d4f51e2390ee397c16e1f7f
pkg-catalog     64d67a73f4f9485749e1b47712e42f77afb4773e
rumiai-dev-PoCs 1ee1da8f2295ef694dc542def05e012f907fe64e
```

Parallel work advanced `rumiai-os` after this task's product revision. The two
versioned task validation scopes at `rumiai-tests@99ac706e6e6b1aac4d4f51e2390ee397c16e1f7f`
still intentionally pin and execute:

```text
rumiai-os bdb66dde9e8fe45caef98c78f9084ed836232594
```

That revision is therefore the exact product revision closed by the evidence below.
Do not relabel these physical PASS results as validation of later `rumiai-os`
revisions.

## Durable result

The completed model includes:

- provider-backed portable `srv start/stop` through the facility `service` typed
  part;
- service identity equal to facility identity;
- exact concrete provider launch through the normal package launcher;
- dependency/provider selection owned by `pkg`;
- user supervision through systemd user units and launchd LaunchAgents;
- system supervision through systemd system units and launchd LaunchDaemons;
- explicit pre-existing non-root execution accounts for system services;
- system package State Instance equal to service identity;
- selector metadata preparation required by system-service runtime;
- GeoServer catalog consolidation under `pkg/geoserver/all/`;
- exact-target package stream precedence with `all` as the only generic fallback;
- platform-independent concrete identity for packages installed from `all`;
- SourceForge mirror-candidate fallback with size/digest verification.

The platform-independent-consumer dependency defect exposed by the `all` stream
migration is resolved by the canonical PKG-74 contract in
`specifications/rumiai-os/PACKAGE-MODEL.md`.

The implementation at
`rumiai-os@bdb66dde9e8fe45caef98c78f9084ed836232594` keeps concrete identity
platform class separate from dependency-consumer platform class, uses the applicable
target platform during install-time dependency validation, and resolves the active
`m_OSARCH` lazily on runtime paths that have not already initialized it.

Permanent regression coverage remains in:

```text
tests/rumiai-os/pkg/dependency.test
```

and protects a generic/`all` consumer resolving an osarch-specific facility
provider without acquiring an osarch suffix itself.

## Hosted evidence

The corrected product revision was validated before the physical gate.

```text
geoserver-service
  GitHub Actions run 35728553311
  rumiai-os bdb66dde9e8fe45caef98c78f9084ed836232594
  Linux/x86_64  VALIDATED
  Darwin/arm64  VALIDATED

package-provider-facility-bridge
  GitHub Actions run 35728865360
  rumiai-os bdb66dde9e8fe45caef98c78f9084ed836232594
  Linux/x86_64  VALIDATED
  Darwin/arm64  VALIDATED
```

The exact suite revisions recorded by those historical hosted runs remain the
revisions published by the runs and are not rewritten by this closure.

## Physical reference-host evidence

Formal physical validation was executed with:

```text
rumiai-tests 99ac706e6e6b1aac4d4f51e2390ee397c16e1f7f
rumiai-os    bdb66dde9e8fe45caef98c78f9084ed836232594
```

### Stable macOS reference host

```text
Platform: Darwin/arm64

geoserver-service
  Published: validation/20260922T202322+0200-2831
  Scope result: VALIDATED
  required FAIL:  0
  required SKIP:  0
  required ERROR: 0

package-provider-facility-final
  Published: validation/20260922T202608+0200-33939
  Scope result: VALIDATED
  required FAIL:  0
  required SKIP:  0
  required ERROR: 0
```

The real GeoServer service path passed, including
`external/geoserver/service-live.test`. The broad closure scope also passed the
selected provider/dependency/environment/facility, package integration/launch/
download, `srv`, and repository-adapter regression coverage.

### Stable Ubuntu ARM64 reference host

```text
Platform: Linux/aarch64

geoserver-service
  Published: validation/20260922T202109+0200-9024
  Scope result: VALIDATED
  required FAIL:  0
  required SKIP:  0
  required ERROR: 0

package-provider-facility-final
  Published: validation/20260922T203011+0200-38084
  Scope result: VALIDATED
  required FAIL:  0
  required SKIP:  0
  required ERROR: 0
```

The same real GeoServer service path and broad closure selections passed on the
Linux/aarch64 stable reference host.

The previously requested auxiliary Ubuntu/x86_64 rerun on `PRTL-GS-01` was not
used as closure evidence here. Its earlier PASS remains historical for its older
revision. Under the current physical-testing contract, the stable macOS and Ubuntu
ARM64 reference hosts above are the final physical gate for this work unit.

## Final consistency gate

The final consistency check confirmed:

- PKG-74 remains in the current canonical package model;
- current service/package contracts retain the completed ownership boundaries;
- current `rumiai-os` still contains the relevant dependency/platform behavior;
- current permanent `dependency.test` still protects PKG-74;
- both current task validation scopes still pin the exact closed product revision
  `bdb66dde9e8fe45caef98c78f9084ed836232594`;
- `pkg-catalog` remains at the GeoServer `all`-stream revision used by the task;
- no required physical selection returned FAIL, SKIP or ERROR;
- no unresolved service/facility/pkg architectural question remains.

## Deferred non-goal

GeoServer's broader upstream mutable-runtime-root audit remains separate under:

```text
todo/geoserver-mutable-runtime-state.md
```

It is not part of this completed work unit.
