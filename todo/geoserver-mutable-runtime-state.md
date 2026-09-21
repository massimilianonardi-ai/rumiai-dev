# GeoServer mutable runtime state

## Intent

Audit every GeoServer 3.x path beneath the installed root that may be mutated at
runtime, then define the correct RumiAI package-state mapping for portable, user-host
and system-host execution before claiming GeoServer system-host support.

## Why pending

GeoServer may use `data_dir` inside the installation root, but that is not known to
be its only mutable path. The current service/facility/pkg work must not prematurely
route only `GEOSERVER_DATA_DIR` and thereby leave other mutable installation-root
paths unresolved.

## Scope

```text
pkg-catalog
rumiai-os package state/launcher integration as needed
rumiai-tests GeoServer service validation
```

## Evidence

The current GeoServer package still exposes the upstream installation root through
`GEOSERVER_HOME`; generic system-host policy forbids granting a service account
write ownership over executable package roots. The service-model handoff therefore
excludes GeoServer system-host validation until this audit is activated.
