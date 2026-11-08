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

## Current execution checkpoint (2026-11-08)

The adapter is implemented on `m-os/codex/geoserver-repository-adapter` at
`c2a21cc2cbe0ca5760c16b254f355fa7949b17b4` and published as [draft PR #12](https://github.com/massimilianonardi-ai/m-os/pull/12).
The branch adds `pkg-repository-geoserver.lib.sh` and its operational manual;
`master` was not changed. The implementation uses the official GeoServer
GitHub Releases API for stable release identity/order and the exact-version
SourceForge RSS record for binary size and MD5.

On Ubuntu ARM64, against exact `m-os/master@a78a24bd` and
`pkg-catalog/main@0b69223a`, shell syntax and `git diff --check` passed;
public `pkg depend geoserver@3.0.1` and `pkg depend geoserver` selected
`temurin@21+35!linux-arm64`. The exact 3.0.1 SourceForge binary was installed,
its service reached local HTTP readiness (302), and it stopped cleanly. The
unversioned install resolved and installed GeoServer 3.0.2; its service did not
reach readiness in this disposable runtime, so 3.0.2 service validation remains
open. These are local Ubuntu results, not hosted or cross-platform acceptance.

### Remaining gates

- Review and hosted validation of draft PR #12 on its exact head.
- Reproduce and diagnose GeoServer 3.0.2 service readiness from a clean isolated
  runtime state; retain 3.0.2 service as pending until then.
- Validate a fresh install/service path on supported hosted platforms and
  evaluate any catalog/artifact changes separately under their owning workflow.
- Keep upstream mutable runtime state under
  `todo/geoserver-mutable-runtime-state.md`; this adapter does not close it.
