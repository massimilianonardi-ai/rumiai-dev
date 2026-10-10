# Web-control provider split

Status: Active
Updated: 2026-10-10

## Goal

Retain the released Playwright/Chrome implementation `pwc-web-control` and develop `electron-web-control` as a separate implementation of the same provider-neutral `web-control` facility. Firefox plus extension remains a possible later experiment.

## Current repository revisions

- `rumiai-dev`: `d8d4383bb0f64c930f70cb71ea1f2f45a2ff0904` (pre-handoff-update checkpoint; verify remote HEAD on resume).
- `electron-web-control`: `69730fb5dba09e3b45e394116bf0b54a267f3e20`.
- `pwc-web-control`: `0e7cf38e72145e5e7c85ea7312e30622b73e0baf`.
- `pkg-catalog`: `53c897de35351ca88a531515f4a3a078e78d0fc8`.
- `rumiai-tests`: `1d0c87697a9fe4c3827a14824c691af974c21501`.
- `rumiai-os`: `9b0a88bbee43b4dee02b403b5f22b56bac76de71` (reference for the mk build; refresh before further integration).

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `handoff/README.md`, `TESTING.md`, `PHYSICAL-TESTING.md`
- `specifications/rumiai-os/WEB-CONTROL.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`, `specifications/rumiai-os/SERVICE-LIFECYCLE.md`, `specifications/rumiai-os/STATE-MODEL.md`, `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`, `specifications/rumiai-os/DOCUMENTATION-MODEL.md`, `specifications/rumiai-os/DIAGNOSTICS.md`, `specifications/rumiai-os/MK.md`

## Fixed task-local choices

- Portable command, service and facility remain `web-control`, with compatibility level 1. Playwright concrete identity stays `pwc-web-control`. The prior `rumiai-web-control` package and authenticated profiles remain untouched.
- Electron provider source and local standalone HOME are separate, under `electron-web-control`. No automatic cross-provider cookie/session migration.
- Publish only actual Electron runtime artifacts; the v0.1.0 package definition is now in `pkg-catalog` and requires formal public-path validation before being described as validated.
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
- `electron-web-control@69730fb` now has an `mk check/test/build` project lifecycle and a portable `v0.1.0` archive excluding `node_modules` and Electron binaries. GitHub Actions run `38086419722` passed on Linux and macOS, including Linux `mk`, and published the real GitHub release asset `electron-web-control-v0.1.0-all.tar.gz`.
- `pkg-catalog@53c897d` supplies `pkg/electron-web-control/all` and the `web-control 1` realization, with dependencies `electron =1` and `nodejs =26`. It extends the existing platform-specific Electron package with one provider-independent runtime-command facility `electron 1` on Linux x86_64, Linux ARM64 and macOS ARM64; no separate Electron binary is embedded.
- `rumiai-tests@1d0c876` added `external/electron-web-control/install-live.test`, its formal task scope and a multi-platform GitHub Actions runner. Run `38086638206` has started, but its final results are not yet established.

## Working design / known limitations

- Electron `sendInputEvent` keyboard/mouse events can be accepted by the main process but not reach DOM listeners on tested hosts. Current `press`/`click` detect delivery and use an explicitly logged DOM synthetic fallback (`isTrusted=false`) when needed. `fill` uses the DOM native value setter and synthetic input/change events. This can be fingerprinted/rejected by some sites; no stealth guarantee, and it is not equivalent to physical input. Evaluate native alternatives separately before treating the provider as viable for resistant sites.
- `ELECTRON_WEB_CONTROL_SOFTWARE_RENDERING=1` is only an explicit opt-in for virtual-display Viz errors. The normal desktop default remains hardware rendering.
- The provider is released and cataloged, but the real `pkg install`/facility/`srv` integration test is still executing; do not describe it as validated until its run reports the result.

## Current state

The standalone Electron baseline passed Linux and macOS. v0.1.0 is now a released portable provider and the catalog includes its package and declared Electron runtime facility. Dedicated public-path integration validation is running on Linux x86_64/ARM64 and macOS ARM64. The comparison with Playwright still has one concrete observed signal (`navigator.webdriver=false`) but no Google login evidence; the Playwright provider remains unchanged. GitHub-hosted tests are not physical validation on the user's machines.

## Next action

1. Inspect formal GitHub Actions run `38086638206` and correct any actual failures forward; verify the catalog, provider selection and `srv` lifecycle before claiming installed-provider readiness.
2. Evaluate native/DOM event delivery under physical desktop/browser sessions and test manual Google login compatibility without bypassing security challenges.
3. Perform user reference-host physical testing when accessible; separately retain the earlier pending physical check of `pwc-web-control` on the user's VM.

## Blockers / open questions

- Formal package integration validation is active (GitHub Actions `38086638206`); resolve failures rather than marking this task complete before results are inspected.
- User VM/desktop not connected to this execution environment; no physical browser-login validation.
- Electron's DOM synthetic interaction fallback is potentially detectable; native input equivalence remains unresolved.
