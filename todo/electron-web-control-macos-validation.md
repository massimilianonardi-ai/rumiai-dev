# Electron web-control macOS ARM64 package validation

## Intent

Validate the released electron-web-control@v0.1.3 through the composed pkg/srv path on macOS ARM64, and perform a physical GUI acceptance trial only when a reference Mac session is available.

## Why pending

Linux x86_64 and Ubuntu 26.04 ARM64 package validation passed. The macOS ARM64 package job in rumiai-tests GitHub Actions 38119393873 is still queued. Electron standalone tests passed on macOS but do not validate the package/service path or a physical Mac desktop. This does not block the completed Linux provider-split work.

## Scope

rumiai-tests, pkg-catalog, electron-web-control, reference macOS host if physical trial is requested.

## Evidence

rumiai-tests/tests/external/electron-web-control/install-live.test; electron-web-control README.md at d05fc096e321c51b2df905fe6ac3799ddfe335cd; rumiai-dev/specifications/rumiai-os/WEB-CONTROL.md.
