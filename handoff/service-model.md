# Service model

Status: Active
Updated: 2026-09-22

## Goal

Complete and physically validate the service/facility/pkg model connecting portable
`srv` lifecycle, package-provided service facilities and explicit user/system host
supervision without introducing a duplicate service registry, provider graph or
dependency graph.

GeoServer 3.0.1 remains the real reference service provider and Temurin Java 21 its
real dependency provider.

## Current repository revisions

Repository revisions most recently relied upon at this checkpoint:

```text
rumiai-dev      28aaa15199e11dfc738ad9fedbcc5e08d27b314a
rumiai-os       bdb66dde9e8fe45caef98c78f9084ed836232594
rumiai-tests    2ad28a4516f47875020f34e46f249aba5ce27f74
pkg-catalog     64d67a73f4f9485749e1b47712e42f77afb4773e
rumiai-dev-PoCs e3dcd58c9c39dae29c7c5a18a810833539553313
```

Fresh remote HEAD retrieval is mandatory on resume. Parallel work is active; preserve
all concurrent changes and reconcile forward before writing.

## Applicable canonical sources

Use the normal mandatory preflight. The task-specific source set is:

```text
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/STATE-MODEL.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
TESTING.md
PHYSICAL-TESTING.md
TEST-PATTERNS.md
handoff/service-model.md
```

Add `COMMAND-ENTRYPOINTS.md` only if a command entrypoint is modified.

## Fixed task-local choices

There is no unresolved service/facility/pkg design choice in this task.

GeoServer's broader upstream mutable-root audit remains separate under:

```text
todo/geoserver-mutable-runtime-state.md
```

Do not block current service validation on that deferred audit.

## Completed

The service/facility/pkg implementation already includes:

- provider-backed portable `srv start/stop` through the facility `service` typed part;
- service identity equal to facility identity;
- exact concrete provider launch through the normal package launcher;
- dependency/provider selection owned by `pkg`;
- user host supervision through systemd user units and launchd LaunchAgents;
- system host supervision through systemd system units and launchd LaunchDaemons;
- explicit pre-existing non-root execution accounts for system services;
- system package State Instance equal to service identity;
- selector metadata preparation required by system-service runtime;
- SourceForge mirror-candidate fallback with size/digest verification;
- GeoServer catalog consolidation under `pkg/geoserver/all/`;
- exact-target package stream precedence with `all` as the only generic fallback;
- platform-independent concrete identity for packages installed from `all`.

The `all` stream correction exposed one additional package-model defect. A
platform-independent consumer concrete was losing the applicable target platform
during dependency resolution, so GeoServer could not resolve the installed
osarch-specific Temurin provider.

The durable correction is now canonical in `PACKAGE-MODEL.md` as PKG-74. Product
implementation at `rumiai-os@bdb66dde9e8fe45caef98c78f9084ed836232594`:

- keeps concrete identity osarch separate from dependency-consumer osarch;
- passes the requested/current install target into dependency validation even when
  the chosen package stream is `all`;
- uses the active `m_OSARCH` for a platform-independent concrete at runtime;
- initializes the existing osarch library lazily when a runtime path such as
  provider-backed `srv` has not already initialized `m_OSARCH`;
- leaves provider/facility ownership and `srv` lifecycle boundaries unchanged.

Operational manuals for the affected package libraries were realigned in the same
work unit.

Permanent regression coverage was added to:

```text
tests/rumiai-os/pkg/dependency.test
```

It verifies a generic/platform-independent consumer concrete resolving an
osarch-specific facility provider while retaining the generic concrete identity.
The test's executable mode was restored in
`rumiai-tests@2ad28a4516f47875020f34e46f249aba5ce27f74` after the first Git-data
commit accidentally wrote it as non-executable.

## Hosted validation evidence

### GeoServer real service path

GitHub Actions run:

```text
geoserver-service
run 35728553311
rumiai-os bdb66dde9e8fe45caef98c78f9084ed836232594
rumiai-tests b3553477e78247ff0d9e5ed8066a99fdd0798adf
```

Results:

```text
Linux/x86_64
  validation/20260922T124006+0000-2468
  aggregate-status 0
  Scope result: VALIDATED
  external/geoserver/service-live.test PASS

Darwin/arm64
  validation/20260922T124021+0000-1975
  aggregate-status 0
  Scope result: VALIDATED
  external/geoserver/service-live.test PASS
```

The later suite-only commit `2ad28a45...` changes only the executable mode of
`tests/rumiai-os/pkg/dependency.test`, which is not selected by the
`geoserver-service` scope. Do not relabel the above evidence as having run at
`2ad28a45...`; its recorded suite revision is `b3553477...`.

### Broad provider/facility/srv regression

GitHub Actions run:

```text
package-provider-facility-bridge
run 35728865360
rumiai-os bdb66dde9e8fe45caef98c78f9084ed836232594
rumiai-tests 2ad28a4516f47875020f34e46f249aba5ce27f74
```

Results:

```text
Linux/x86_64
  validation/20260922T124309+0000-2360
  aggregate-status 0
  Scope result: VALIDATED
  rumiai-os/pkg/dependency.test PASS

Darwin/arm64
  validation/20260922T124317+0000-11915
  aggregate-status 0
  Scope result: VALIDATED
  rumiai-os/pkg/dependency.test PASS
```

This run also passed the selected `srv`, package integration/launch/download and
repository regression coverage on both hosts.

## Current state

Hosted validation now supports the corrected product revision
`bdb66dde9e8fe45caef98c78f9084ed836232594` on Linux/x86_64 and Darwin/arm64.

The software defect discovered after the `all` stream migration is resolved. There
is no known remaining product, catalog or permanent-test defect in the active task.

The task is **not complete** because the required physical validation gate has not
yet been repeated for these current revisions.

Earlier physical Ubuntu/x86_64 PASS evidence on `PRTL-GS-01` predates the
`all`/PKG-74 corrections and remains historical revision-specific evidence only.

## Next action

Run the two fixed scopes on the current physical Ubuntu/x86_64 auxiliary work host
`PRTL-GS-01`:

```sh
sudo -v
./rumiai-validate geoserver-service
./rumiai-validate package-provider-facility-final
```

Record the exact validation session IDs and exact `rumiai-tests` /
`rumiai-os` revisions.

Then run the same two fixed scopes on both stable reference hosts:

- stable macOS reference host;
- stable Ubuntu 26.04 ARM64 reference host.

A required `SKIP` is not a PASS.

After both stable reference hosts pass the current exact revisions:

1. run the final consistency gate;
2. synchronize this handoff with `Status: Complete` and exact physical evidence;
3. commit that final handoff snapshot;
4. remove the completed handoff in a later forward commit.

## Blockers / open questions

No architectural question remains.

The only remaining blocker is access to the required physical validation hosts. The
current chat has no confirmed connected terminal session to those machines. Hosted
GitHub Actions evidence is not a substitute for the physical gate defined by the
task.
