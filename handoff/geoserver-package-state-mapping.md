# GeoServer package state mapping

Status: Complete
Updated: 2026-10-05

## Goal

Apply the same package-state analysis used for Keycloak to GeoServer: verify package identity/platform scope, run `pkg-analyze` plus real execution, determine which installation-root paths are mutated, enumerate supported command-line/environment controls that relocate or suppress those writes, and map only empirically justified mutable paths through package `var/`.

## Current repository revisions

- rumiai-dev: 226208cfbbbe677347261084cf0f7d614c650dbd before this handoff synchronization
- rumiai-os: 2693e5695e7b75c45b1cda0a490435480960534d
- rumiai-tests: 9a3d0fb9a7fb2b6c61fed1966586319cf71c0691
- pkg-catalog: c1425bd5097bd18526a42da866ea98906a3325a4
- rumiai-dev-PoCs: 71f47e5f2f3b26ff7d6a0e2d335a85459b669088

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/STATE-MODEL.md

## Current package facts

- GeoServer is already correctly defined under `pkg/geoserver/all`; no osarch stream migration is required.
- Current range anchor is `3.0.1`.
- Current dependency is `java >=17 <22`.
- Current ordinary command is `geoserver-start -> bin/startup.sh`.
- Current package environment computes `GEOSERVER_HOME` from the installed concrete root.
- Current package definition now routes the official factory `data_dir` through `var/data`.

## Verified upstream controls

The 3.0.1 binary and current documentation support the relevant state-location controls:

- `GEOSERVER_DATA_DIR`: relocates the complete GeoServer data/configuration directory. The bundled startup script defaults it to `$GEOSERVER_HOME/data_dir` and then passes it as `-DGEOSERVER_DATA_DIR=...`.
- `GEOSERVER_LOG_LOCATION`: relocates the active GeoServer log file independently of the data directory.
- `GEOWEBCACHE_CACHE_DIR`: relocates GeoWebCache cache state independently of the data directory.
- `JAVA_OPTS=-Djava.io.tmpdir=...`: relocates JVM/GeoTools temporary state; the probe observed the GeoTools EPSG HSQL database there.
- `JETTY_OPTS`: configures the bundled Jetty runtime, including the HTTP port used by the probes.

The bundled `startup.sh` itself supplies `-DGEOSERVER_DATA_DIR` after `JAVA_OPTS`, so `GEOSERVER_DATA_DIR` is the practical supported control for the binary wrapper's data directory.

## Working plan

1. Capture the exact current GeoServer release selected by the catalog and its binary archive.
2. Run current `pkg-analyze` against a fresh extracted GeoServer root.
3. Hash the root before/after execution so in-place modifications are visible.
4. Probe baseline startup and targeted relocation variants, including external `GEOSERVER_DATA_DIR` and `GEOSERVER_LOG_LOCATION`.
5. Compare direct-upstream evidence with the real composed RumiAI install/start path.
6. Classify mutable paths into `conf`, `data`, `cache`, `log`, `run`, or `tmp` only where supported by evidence and current state semantics.
7. Realign pkg-catalog and permanent tests if required.
8. Run the consistency gate before completion.

## Initial open questions

- Whether bundled Jetty writes under `logs/`, `work/`, `temp/`, `webapps/`, or other root-local paths during normal startup.
- Whether `data_dir` should be routed wholesale through managed package state or explicitly relocated by generated environment.
- Whether log state should remain inside managed data state or receive a separate `log` area when `GEOSERVER_LOG_LOCATION` is controlled.
- Whether any runtime-generated Jetty caches are regenerable and should map to package `cache`.

## Empirical findings

PoC 056 ran the real GeoServer 3.0.1 binary on Java 21 through current `pkg-analyze`, supplemented by SHA-256 before/after manifests.

Baseline startup changed only paths below `data_dir/`. Observed changes included GeoPackage WAL/SHM files, GeoWebCache configuration/layer metadata, logging material, security keystore/version state, and modifications to existing configuration files such as `global.xml`, `security/config.xml` and the NaturalEarth datastore definition. No package-root path outside `data_dir` changed in the observed startup/shutdown cycle.

With an external `GEOSERVER_DATA_DIR`, the package-root delta was empty and the same writes moved under the external data directory. Adding `GEOSERVER_LOG_LOCATION` moved the active `geoserver.log` out of that directory. Adding `JAVA_OPTS=-Djava.io.tmpdir=...` moved the GeoTools EPSG HSQL temporary database. Adding `GEOWEBCACHE_CACHE_DIR` moved GeoWebCache `geowebcache.xml`, metadata and temporary/cache state into the external cache directory. With all relocation controls active, the package root remained unchanged.

The successful direct-probe evidence is GitHub Actions run `37293536922` (probe job). Earlier run `37293028983` also passed the four-case probe before the GeoWebCache-specific case was added.

## Mapping decision

Map the complete official factory `data_dir` as package `data`:

```text
pkg/geoserver/all/n0001=3.0.1/var/data
    data_dir
```

This is deliberately one mapping. Current package-state validation rejects overlapping/nested `var/` paths, so `data_dir` cannot simultaneously be mapped as `data` while nested `data_dir/gwc` or `data_dir/logs` are mapped to other areas. Splitting the upstream data directory into a large set of non-overlapping internal paths would be brittle and would lose the factory-directory abstraction supplied by GeoServer itself.

The finer runtime controls for log/cache/tmp remain available to consumers and service configuration, but are not additional static `var/` mappings required to keep the package root immutable.

## Implemented changes

### pkg-catalog

Added `var/data` with `data_dir` to the existing platform-independent GeoServer range. Revision: `c1425bd5097bd18526a42da866ea98906a3325a4`.

### rumiai-tests

`external/geoserver/install-dependency-live.test` now verifies that installation initializes managed `data/data_dir`, routes `root/data_dir` through a symlink, retains factory `global.xml`, and keeps the concrete platform-independent.

`external/geoserver/service-live.test` carries the same data-state/all-stream checks and no longer contains the stale package-osarch whitelist or an osarch-qualified synthetic GeoServer selector.

Current revision: `9a3d0fb9a7fb2b6c61fed1966586319cf71c0691`.

## Validation status

- PoC 056 direct upstream state probe including external data/log/tmp/cache relocation: passed on Linux in run `37293536922`.
- Existing composed pre-mapping probe confirmed that the un-routed package modified only `root/data_dir/**` and that `geoserver@3.0.1` is an all-stream concrete.
- Permanent GeoServer validation at rumiai-tests `f92a64ea13c9a8c034221f8701dfef532285cb2e` passed on macOS, including the new install-time data-state assertions and the complete `service-live.test`; scope result was VALIDATED.
- Current rumiai-tests revision `9a3d0fb9a7fb2b6c61fed1966586319cf71c0691` passed the complete `geoserver-service` validation on Linux in run `37294447444`, including repository, recursive dependency install, managed `data_dir`, portable service, user-host service and system-host service; scope result was VALIDATED.
- An earlier workflow demonstrated that host-supervisor prerequisites can legitimately cause `service-live.test` to SKIP on some GitHub-hosted instances; that result was not relabelled as PASS.

## Final consistency result

The current catalog contains only the platform-independent `pkg/geoserver/all` stream and exactly one GeoServer `var/` declaration: `var/data -> data_dir`. No stale osarch-qualified synthetic GeoServer selector remains in the permanent tests. The mapping matches the observed direct and composed runtime behavior and the current package/state specifications.

Validation evidence is proportional and real:

- direct upstream execution and relocation probes on Linux: PASS;
- current full permanent GeoServer validation on Linux: VALIDATED;
- permanent GeoServer validation with the new data-state assertions on macOS: VALIDATED.

No physical-host validation claim is made beyond those executed GitHub Actions environments.

## Current state

Complete. Durable state is carried by pkg-catalog and permanent tests; this handoff can be removed from the current tree after this completion snapshot.
