# GeoServer package state mapping

Status: Active
Updated: 2026-10-05

## Goal

Apply the same package-state analysis used for Keycloak to GeoServer: verify package identity/platform scope, run `pkg-analyze` plus real execution, determine which installation-root paths are mutated, enumerate supported command-line/environment controls that relocate or suppress those writes, and map only empirically justified mutable paths through package `var/`.

## Current repository revisions

- rumiai-dev: 222e8a1a665f26bbd281d600d77c6c7a97d0a7ec before this handoff creation
- rumiai-os: 2693e5695e7b75c45b1cda0a490435480960534d
- rumiai-tests: 790831c6bffadfe1efbb130fbdb0518c55dc2935
- pkg-catalog: f97a989d795192f8b2acb72a9b658817184633ab
- rumiai-dev-PoCs: efdec306d2765c193e4261e3d576b7ae58ce021a

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
- Current package definition has no `var/` state routing.

## Upstream configuration candidates

Current GeoServer documentation identifies at least:

- `GEOSERVER_DATA_DIR`: relocates the authoritative GeoServer data/configuration directory; default platform-independent binary location is `<installation-root>/data_dir`.
- `GEOSERVER_LOG_LOCATION`: relocates the GeoServer log file and may be supplied as environment variable or system property.
- `JETTY_OPTS`: configures the bundled Jetty runtime, including HTTP port and JVM/Jetty properties.
- Java system-property forms such as `-DGEOSERVER_DATA_DIR=...` are equivalent supported configuration surfaces for relevant application properties.

These are candidates only until the exact probed distribution and runtime footprint are inspected.

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
