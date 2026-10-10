# Web-control provider split

Status: Active
Updated: 2026-10-10

## Goal

Retain the released Playwright/Chrome implementation `pwc-web-control` and develop `electron-web-control` as a separate implementation of the same provider-neutral `web-control` facility. Firefox plus extension remains a possible later experiment.

## Current repository revisions

- `rumiai-dev`: `7dce477b7a14630df0a2d7e1aad6b782f9242eb2` (before this handoff update; verify new remote HEAD on resume).
- `electron-web-control`: `bddc834c621e48dbbfdb6817ec0b5dffec3dc143`.
- `pwc-web-control`: `0e7cf38e72145e5e7c85ea7312e30622b73e0baf`.
- `pkg-catalog`: `dc2b47a8f39f2b5130199f8b983e2535a3e5af22`.
- `rumiai-tests`: `5a76290934563224286eea2b14eaca94aeced63e`.
- `rumiai-os`: `382369cfde55b158bdf9bb8c7c7ba352fb00ca5e`.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `handoff/README.md`, `TESTING.md`, `PHYSICAL-TESTING.md`
- `specifications/rumiai-os/WEB-CONTROL.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`, `specifications/rumiai-os/SERVICE-LIFECYCLE.md`, `specifications/rumiai-os/STATE-MODEL.md`, `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`, `specifications/rumiai-os/DOCUMENTATION-MODEL.md`, `specifications/rumiai-os/DIAGNOSTICS.md`, `specifications/rumiai-os/MK.md`

## Fixed task-local choices

- Portable command, service and facility remain `web-control`, with compatibility level 1. Playwright concrete identity stays `pwc-web-control`. The prior `rumiai-web-control` package and authenticated profiles remain untouched.
- Electron provider source and local standalone HOME are separate, under `electron-web-control`. No automatic cross-provider cookie/session migration.
- A `pkg-catalog` Electron package is not created before compatible released artifacts and actual installation/facility tests.
- Preserve browser sandboxing; no unrestricted CDP listener, CAPTCHA bypass or assertion that Electron is accepted by Google without an actual login trial.

## Acceptance scenarios

1. Old `rumiai-web-control` installs continue working; new `pwc-web-control` release resolves the unchanged `web-control` facility.
2. Standalone Electron controller allows `web-control status`, page navigation/inspection, capture and explicit interactions, preserves authenticated local test-fixture storage across restart, and survives all-window closure.
3. Future Electron package integrates through real `pkg install electron-web-control`, provider selection, `srv start web-control`, with sandbox and isolated state, before being advertised as installable.

## Completed

- Playwright repo/package rename, `pwc-web-control` v0.1.4 release, catalog mapping and permanent RumiAI OS integration tests. GitHub Actions `38074484807` validated public package/service path on Ubuntu x86_64 and ARM64.
- Initialized `electron-web-control` with Node CLI, an actual Electron 44.3.0 `BrowserWindow` controller/service, Unix-domain socket 0600, persistent isolated Electron partition, sandboxed renderers (`nodeIntegration:false`, `contextIsolation:true`, `sandbox:true`), separate HOME, page/popup tracking, navigation, DOM inspection, cookie/local/session storage, HTML/text/PNG capture, `click`, `fill`, and `press`. No Playwright dependency.
- Fixed Electron ESM startup deadlock (top-level `app.whenReady()` await), Linux GitHub runner SUID sandbox helper configuration (root-owned mode 4755), and Xvfb Viz screenshot failure via an explicit software-rendering option. Default browser sandbox remains active.
- Real Electron tests passed on **Linux (Xvfb/Openbox) and macOS GitHub Actions**, run `38079356546` at `electron-web-control@bddc834`: CLI/status, window lifecycle, popup, dynamic DOM, click/fill/press, HTML/text/PNG capture, cookie/localStorage across service restart, controller remaining available when no browser windows remain, browser window recreated on demand.
- Test fixture observed `navigator.webdriver === false` with Electron on those CI hosts and no renderer `process`/`require`; this is an observation, **not evidence that Google permits authentication**.
- Removed Playwright-only `debug cdp` and MHTML from Electron client usage; project README identifies current limitations.

## Working design / known limitations

- Electron `sendInputEvent` keyboard/mouse events can be accepted by the main process but not reach DOM listeners on tested hosts. Current `press`/`click` detect delivery and use an explicitly logged DOM synthetic fallback (`isTrusted=false`) when needed. `fill` uses the DOM native value setter and synthetic input/change events. This can be fingerprinted/rejected by some sites; no stealth guarantee, and it is not equivalent to physical input. Evaluate native alternatives separately before treating the provider as viable for resistant sites.
- `ELECTRON_WEB_CONTROL_SOFTWARE_RENDERING=1` is only an explicit opt-in for virtual-display Viz errors. The normal desktop default remains hardware rendering.
- The current provider is an **experimental standalone runtime**, not yet a `pkg` distributable; no release artifact, package registration, `srv` integration or `mk build` release pipeline yet.

## Current state

The Electron independent smoke-test baseline works on the two tested GitHub-hosted systems. The comparison with Playwright has one concrete measured signal (`navigator.webdriver=false`) but no Google authentication evidence. The earlier Playwright provider remains unchanged. GitHub-hosted tests are not physical validation on the user's machines.

## Next action

1. Design and implement platform-appropriate Electron release packaging through `mk`; use existing `pkg`/facility semantics rather than inventing a new provider mechanism, and validate real `pkg install` + `srv` integration before adding an installable `electron-web-control` catalog definition.
2. Evaluate native/DOM event delivery under physical desktop/browser sessions and test manual Google login compatibility without bypassing security challenges.
3. Perform user reference-host physical testing when accessible; separately retain the earlier pending physical check of `pwc-web-control` on the user's VM.

## Blockers / open questions

- User VM/desktop not connected to this execution environment; no physical browser-login validation.
- Electron's DOM synthetic interaction fallback is potentially detectable; native input equivalence remains unresolved.
