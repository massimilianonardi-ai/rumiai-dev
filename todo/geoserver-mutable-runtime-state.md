# GeoServer mutable runtime state

## Intent

Audit every GeoServer 3.x path beneath the installed root that may be mutated at
runtime, then define whether any additional RumiAI package-state mapping is needed
for production-grade portable, user-host and system-host execution.

## Why pending

GeoServer may use `data_dir` inside the installation root, but that is not known to
be its only mutable path. The current service/facility/pkg work intentionally leaves
the upstream layout unchanged and continues to use GeoServer for real service
validation; the broader mutable-path model will be analyzed separately.

## Scope

```text
pkg-catalog
rumiai-os package state/launcher integration as needed
rumiai-tests GeoServer service validation
```

## Evidence

The current GeoServer package still exposes the upstream installation root through
`GEOSERVER_HOME`. Generic system-host registration does not grant new ownership or
write access to executable package roots, but the package's upstream mutable-path
surface still deserves a dedicated audit. That audit is not a prerequisite for
using GeoServer as the real system-service validation provider.
