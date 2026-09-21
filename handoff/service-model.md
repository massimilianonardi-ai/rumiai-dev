# Service model

Status: Active
Updated: 2026-09-21

## Goal

Complete the service model connecting portable `srv` lifecycle, package-provided
service facilities and explicit user/system host supervision without introducing a
duplicate service registry, provider graph or dependency graph.

The software/specification/formal-validation work is complete. The only remaining
active stage is physical validation on the stable reference hosts.

## Current repository revisions

```text
rumiai-dev      9bd32662ac47d14fc08b90f0c5ac278a94924596
rumiai-os       cbcf6467838eda79c1afedd22061299d5c1a40ff
rumiai-tests    ed173d66480579e1eb869d80beb43cfb9fccdf5d
pkg-catalog     39abe7d9ae53753dda9e2714fc39fe69adfafb8c
rumiai-dev-PoCs ab470307cb8a3e26d57b798fe021109209d66792
```

Fresh remote HEAD retrieval remains mandatory on resume.

## Applicable canonical sources

```text
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/STATE-MODEL.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
TESTING.md
PHYSICAL-TESTING.md
```

Add command/library/documentation specifications when modifying those surfaces.

## Completed

### Service/facility/pkg model

The current implementation and canonical specifications now cover:

- provider-backed portable `srv start/stop` through the facility `service` typed part;
- exact concrete provider launch with package-launcher HOME/environment/dependency semantics;
- GeoServer 3.0.1 as the first real service provider, with Temurin Java 21;
- user host supervision through systemd user units and launchd LaunchAgents;
- system host supervision through systemd system units and launchd LaunchDaemons;
- explicit pre-existing non-root execution accounts for system services;
- system package State Instance equal to service identity;
- exact provider reconciliation for system registrations and stale-registration failure;
- recursive preparation of only the provider-selector metadata required by a
  non-root system-service runtime;
- provider defaults/bindings remaining private under normal configuration and being
  made read-only/traversable only by system-service reconciliation when required;
- removal of the historical PATH-resolved `<service>-start` fallback.

`srv` never invokes privilege escalation itself and does not create/remove host
accounts.

### Permanent tests

`tests/rumiai-os/srv/host-system.test` protects the generic system-host contract,
including:

```text
administrative boundary
non-root execution account
system package State Instance HOME
dependency provider resolution under the service account
provider-default change -> stale registration
explicit install reconciliation
start/restart/stop/uninstall
state/account preservation
```

`tests/external/geoserver/service-live.test` uses the real package pipeline and
real GeoServer provider to exercise:

```text
pkg install Temurin Java 21
pkg install GeoServer 3.0.1
portable srv start/stop
srv host user install/start/restart/stop/uninstall
srv host system install/start/restart/stop/uninstall
```

GeoServer remains the real system-service reference. Its broader upstream mutable
installation-root audit is intentionally separate under:

```text
todo/geoserver-mutable-runtime-state.md
```

and does not block the current service-host validation.

### Validation workflow

The two task workflows keep `rumiai-validate` blocking. Upload of recoverable local
artifact copies is non-blocking because canonical revision-specific validation
evidence is already published by `rumiai-validate`; an external artifact-storage
failure must not relabel a successful formal validation.

## Current formal validation evidence

All evidence below is GitHub-hosted technical/formal evidence, not physical
stable-host validation.

### GeoServer real service path

GitHub Actions run:

```text
35656229331
```

Exact validated revisions:

```text
rumiai-tests@ed173d66480579e1eb869d80beb43cfb9fccdf5d
rumiai-os@cbcf6467838eda79c1afedd22061299d5c1a40ff
```

Scope:

```text
geoserver-service
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

Both matrix jobs completed successfully.

### Broad provider/facility/srv regression

GitHub Actions run:

```text
35656229627
```

Exact validated revisions:

```text
rumiai-tests@ed173d66480579e1eb869d80beb43cfb9fccdf5d
rumiai-os@cbcf6467838eda79c1afedd22061299d5c1a40ff
```

Scope:

```text
package-provider-facility-final
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

Both required matrix jobs completed successfully. The dispatch-only
`graalvm-coexistence` job is outside this task scope and is expected to remain
skipped on a normal push-triggered run.

## Current state

Implementation, manuals, canonical specifications and permanent tests are aligned at
the revisions above. The final consistency review also corrected temporary-path PID
uniqueness and restored normal provider-selector privacy outside explicit
system-service reconciliation.

No software/design blocker remains in the active service-model work.

GitHub-hosted validation does not satisfy the project's physical-validation stage.

## Next action

Run the already-fixed scopes on both stable physical reference hosts:

```text
macOS
Ubuntu 26.04 ARM64
```

Required physical scopes:

```text
geoserver-service
package-provider-facility-final
```

A required test returning `SKIP` is not a PASS.

If both scopes pass on both applicable physical hosts:

1. synchronize this handoff one final time with `Status: Complete` and the exact
   physical evidence/revisions;
2. commit that final snapshot;
3. remove this handoff in a later forward commit.

## Blockers / open questions

Physical validation requires access to the stable reference hosts and cannot be
performed from the current GitHub-hosted/chat execution environment.

There are no remaining service-model design questions.
