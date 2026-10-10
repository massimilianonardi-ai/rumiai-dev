# Web-control provider split

Status: Active
Updated: 2026-10-10

## Goal

Retain the released Playwright/Chrome implementation `pwc-web-control` and develop `electron-web-control` as a separate implementation of the same provider-neutral `web-control` facility. Firefox plus extension remains a possible later experiment.

## Current repository revisions

- `rumiai-dev`: `115895b191377b0939a253a90e88b52272eac53e` (pre-handoff-update checkpoint; verify current remote HEAD on resume).
- `electron-web-control`: `425c2fd42d7e9c43fc8403fc7c2cb460ea00950b` (current README/source; v0.1.1 release was built from `11c7a69`).
- `pwc-web-control`: `0e7cf38e72145e5e7c85ea7312e30622b73e0baf`.
- `pkg-catalog`: `cd4dfb8aaa21b6c25ab0f00c95fa1c9834d02783`.
- `rumiai-tests`: `8ad2f147846154dc81edb5dd71c58f8c2951c3ba`.
- `rumiai-os`: `9b0a88bbee43b4dee02b403b5f22b56bac76de71` (reference for the mk build; refresh before further integration).

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `handoff/README.md`, `TESTING.md`, `PHYSICAL-TESTING.md`
- `specifications/rumiai-os/WEB-CONTROL.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`, `specifications/rumiai-os/SERVICE-LIFECYCLE.md`, `specifications/rumiai-os/STATE-MODEL.md`, `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`, `specifications/rumiai-os/DOCUMENTATION-MODEL.md`, `specifications/rumiai-os/DIAGNOSTICS.md`, `specifications/rumiai-os/MK.md`

## Fixed task-local choices

- Portable command, service and facility remain `web-control`, with compatibility level 1. Playwright concrete identity stays `pwc-web-control`. The prior `rumiai-web-control` package and authenticated profiles remain untouched.
- Electron provider source and local standalone HOME are separate, under `electron-web-control`. No automatic cross-provider cookie/session migration.
- Electron v0.1.1 is published with a provider-specific ordinary service command. Preserve the earlier v0.1.0 range/release as an immutable checkpoint; do not silently rename its installed concrete or profile state.
- Preserve browser sandboxing; no unrestricted CDP listener, CAPTCHA bypass or assertion that Electron is accepted by Google without an actual login trial.

## Acceptance scenarios

1. Old `rumiai-web-control` installs continue working; new `pwc-web-control` release resolves the unchanged `web-control` facility.
2. Standalone Electron controller allows `web-control status`, page navigation/inspection, capture and explicit interactions, preserves authenticated local test-fixture storage across restart, and survives all-window closure.
3. With Playwright already installed/selected and v0.1.0 partially integrated, `pkg install electron-web-control@v0.1.1` succeeds, the provider switches through `pkg provider default web-control electron-web-control`, and `srv` starts the Electron controller without clobbering the Playwright service command.

## Completed

- Playwright repo/package rename, `pwc-web-control` v0.1.4 release, catalog mapping and permanent RumiAI OS integration tests. GitHub Actions `38074484807` validated public package/service path on Ubuntu x86_64 and ARM64.
- Initialized `electron-web-control` with Node CLI, an actual Electron 44.3.0 `BrowserWindow` controller/service, Unix-domain socket 0600, persistent isolated Electron partition, sandboxed renderers (`nodeIntegration:false`, `contextIsolation:true`, `sandbox:true`), separate HOME, page/popup tracking, navigation, DOM inspection, cookie/local/session storage, HTML/text/PNG capture, `click`, `fill`, and `press`. No Playwright dependency.
- Fixed Electron ESM startup deadlock (top-level `app.whenReady()` await), Linux GitHub runner SUID sandbox helper configuration (root-owned mode 4755), and Xvfb Viz screenshot failure via an explicit software-rendering option. Default browser sandbox remains active.
- Real Electron tests passed on **Linux (Xvfb/Openbox) and macOS GitHub Actions**, run `38079356546` at `electron-web-control@bddc834`: CLI/status, window lifecycle, popup, dynamic DOM, click/fill/press, HTML/text/PNG capture, cookie/localStorage across service restart, controller remaining available when no browser windows remain, browser window recreated on demand.
- Test fixture observed `navigator.webdriver === false` with Electron on those CI hosts and no renderer `process`/`require`; this is an observation, **not evidence that Google permits authentication**.
- Removed Playwright-only `debug cdp` and MHTML from Electron client usage; project README identifies current limitations.
- `electron-web-control@69730fb` now has an `mk check/test/build` project lifecycle and a portable `v0.1.0` archive excluding `node_modules` and Electron binaries. GitHub Actions run `38086419722` passed on Linux and macOS, including Linux `mk`, and published the real GitHub release asset `electron-web-control-v0.1.0-all.tar.gz`.
- `pkg-catalog@53c897d` supplies `pkg/electron-web-control/all` and the `web-control 1` realization, with dependencies `electron =1` and `nodejs =26`. It extends the existing platform-specific Electron package with one provider-independent runtime-command facility `electron 1` on Linux x86_64, Linux ARM64 and macOS ARM64; no separate Electron binary is embedded.
- `rumiai-dev@ac3e2fd` updated the current `WEB-CONTROL.md` specification to name both released concrete providers while keeping the provider-independent contract unchanged.
- `electron-web-control@d2b5777` updated the current README with the verified Linux installation path and stated macOS/physical limitations; the released v0.1.0 archive remains the exact earlier published artifact.
- A physical Linux ARM64 VM reported `pkg install electron-web-control@v0.1.0` failing at stage `default-selection`, status `19`, with a concurrently installed Playwright `web-control-service` command and an already-running legacy controller. The `web-control` command was not projected as the new facility default. Root cause: both concrete package ranges published the same ordinary service command, contrary to multiple-provider coexistence.
- `electron-web-control@11c7a69` published `v0.1.1`, with Linux `mk` build plus Linux/macOS standalone test PASS (Actions `38087565410`).
- `pkg-catalog@cd4dfb8` defines a new `n0002=v0.1.1` range whose ordinary service command is `electron-web-control-service`, with `facility-service/web-control/start` pointing to it. The old `v0.1.0` range remains untouched.
- `rumiai-tests@8ad2f14` added a real regression path installing/selecting Playwright, reproducing a v0.1.0 default-selection conflict, then installing v0.1.1, switching the `web-control` facility and exercising `srv` without overwriting the old provider's service command. Formal Linux x86_64 and ARM64 task validations both PASSED with `Scope result: VALIDATED` (Actions `38088010462`).
- `rumiai-tests@1d0c876` added `external/electron-web-control/install-live.test`, its formal task scope and a multi-platform GitHub Actions runner. Run `38086638206` proved five PASS, zero FAIL, zero SKIP and `Scope result: VALIDATED` independently on Linux x86_64 and ARM64. Its macOS ARM64 job was still queued at the last check; this does not establish macOS package conformance.

## Working design / known limitations

- Electron `sendInputEvent` keyboard/mouse events can be accepted by the main process but not reach DOM listeners on tested hosts. Current `press`/`click` detect delivery and use an explicitly logged DOM synthetic fallback (`isTrusted=false`) when needed. `fill` uses the DOM native value setter and synthetic input/change events. This can be fingerprinted/rejected by some sites; no stealth guarantee, and it is not equivalent to physical input. Evaluate native alternatives separately before treating the provider as viable for resistant sites.
- `ELECTRON_WEB_CONTROL_SOFTWARE_RENDERING=1` is only an explicit opt-in for virtual-display Viz errors. The normal desktop default remains hardware rendering.
- The v0.1.1 release and catalog now use distinct ordinary service command `electron-web-control-service`; facility/service identity remains `web-control`. Dual-provider installation, explicit provider selection, recovery after v0.1.0 failed default selection and `srv` passed real formal tests on Linux x86_64 and ARM64. macOS ARM64 package validation remains pending and the renderer interaction fallback may be synthetic.

## Current state

The v0.1.1 portable release and corrected `pkg-catalog` metadata resolve the ordinary-command collision that caused physical VM install failure for v0.1.0. Formal package/recovery scopes passed on Linux x86_64 and ARM64 (`38088010462`), including a real prior Playwright provider default and a failed v0.1.0 default selection. Existing user-managed VM state remains untouched; its recovery requires an explicit physical retry and controlled service restart. Mac ARM64 package validation was still queued at the last check, and manual Google login remains untested. Hosted validation is not evidence of physical reference-host validation.

## Next action

1. Run the precise v0.1.1 install/stop/switch/start sequence on the user's physical Linux ARM64 VM without deleting installed browser state, and observe real status and Google login separately. The formal Linux recovery tests already passed.
2. Evaluate native/DOM event delivery under physical desktop/browser sessions and test manual Google login compatibility without bypassing security challenges.
3. Perform user reference-host physical testing when accessible; separately retain the earlier pending physical check of `pwc-web-control` on the user's VM.

## Blockers / open questions

- macOS ARM64 formal package validation (latest active run `38088010462`) remains queued/pending; the v0.1.1 Linux x86_64/ARM64 formal recovery scenario passed. The provider is not physically validated on the user's Mac.
- User VM/desktop not connected to this execution environment; no physical browser-login validation.
- Electron's DOM synthetic interaction fallback is potentially detectable; native input equivalence remains unresolved.
