# GeoServer repository adapter for autonomous m

## Intent

Make the existing GeoServer catalog definition installable through the autonomous `m` package pipeline by implementing or otherwise reconciling its declared repository adapter type under the current `PACKAGE-MODEL.md` contract. Validate the actual published GeoServer artifact and Java dependency through real public commands where obtainable.

## Why pending

The current `pkg-catalog` v1 definition for `geoserver/all/repository/type` declares `geoserver`, but the current `m-os/master` package repository-adapter directory has no matching `pkg-repository-geoserver.lib.sh`. This prevents treating GeoServer install/dependency end-to-end behavior as validated by P2; adding a new repository adapter is a distinct package-source responsibility, not a side effect of P2 exact-root planning acceptance.

## Scope

- `m-os` package repository adapters and operational manual, subject to the normal code/API gates
- `pkg-catalog` GeoServer definition and integrity metadata
- Proportional real public install/dependency/service validation (hosted first, physical only when required and authorized)

## Evidence

- `rumiai-dev/specifications/rumiai-os/PACKAGE-MODEL.md`, `Real composed pipeline` and `Catalog and repository adapters`
- `pkg-catalog/main`: `v1/pkg/geoserver/all/repository/type` (`geoserver`)
- `m-os/master`: `lib/sys/sh/pkg/repository/` currently has only `artifact`, `chrome`, `chromium`, `github` and `nodejs` adapters; P2 [merge #3](https://github.com/massimilianonardi-ai/m-os/pull/3) did not add a GeoServer adapter
- Existing `todo/geoserver-mutable-runtime-state.md` separately owns upstream mutable-state analysis, not adapter acquisition
