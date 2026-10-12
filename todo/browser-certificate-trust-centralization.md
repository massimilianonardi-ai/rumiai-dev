# Centralized browser certificate trust for RumiAI

## Intent

Investigate and design a shared, managed trust/certificate authority mechanism for RumiAI browser providers so that authorized CA certificates do not need to be imported separately for every browser package, profile, instance or release.

## Why pending

The Electron/Chromium corporate-CA incident exposed diverging certificate lookup and browser-profile paths in nested package launches. The environment-preservation fix addresses executable HOME inheritance, but does not establish a central, browser-independent trust-management mechanism. The user deferred certificate work until back on the corporate network; no corporate CA is available in the current environment.

## Scope

Evaluate the appropriate semantic owner in `m`/RumiAI, the relation to host OS trust stores, per-user/per-service trust boundaries, NSS/Chromium and other supported browser backends, portability and persistence across upgrades, explicit trust additions/revocations, and certificate-verification security. Do not silently weaken TLS verification or share authenticated browser sessions. No implementation approach is decided by this TODO.

## Evidence

- `specifications/rumiai-os/STATE-MODEL.md` and `PACKAGE-MODEL.md` define managed package state and HOME.
- `specifications/rumiai-os/WEB-CONTROL.md` defines browser-provider isolation and persistent profiles.
- `electron-web-control/bin/web-control-service` and `src/main.mjs` select application/profile paths, while the `electron` dependency has its own managed launcher.
- `handoff/pkg-launch-environment-preservation.md` records the HOME/NSS incident and the remaining physical CA scenario.
