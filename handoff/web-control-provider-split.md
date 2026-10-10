# Web-control provider split

Status: Active
Updated: 2026-10-10

## Goal

Retain the released Playwright/Chrome implementation `pwc-web-control` and develop `electron-web-control` as a separate implementation of the same provider-neutral `web-control` facility. Firefox plus extension remains a possible later experiment.

## Current repository revisions

- `rumiai-dev`: `f35960f73c23a8b719d5b115a0b324a0682cf82a` (current HEAD observed for this checkpoint; refresh on resume).
- `electron-web-control`: `425c2fd42d7e9c43fc8403fc7c2cb460ea00950b` (current README/source; v0.1.1 release was built from `11c7a69`).
- `pwc-web-control`: `0e7cf38e72145e5e7c85ea7312e30622b73e0baf`.
- `pkg-catalog`: `cd4dfb8aaa21b6c25ab0f00c95fa1c9834d02783`.
- `rumiai-tests`: `f3063b6d7adc0184147111eb83265504799d8c1a` (current HEAD; Electron regression change `d71be125`).
- `rumiai-os`: `e5e773c14f19ac1b29d007ae93e76b3b13031a2b` (current HEAD; latest Electron regression jobs recorded `43c3ebf420edb7a005f3d7e1bb96552234762f0e` as their checked-out product revision).

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
4. On a physical graphical desktop, starting the Electron provider opens an **opaque, usable browser window** with an obvious way to enter a URL and navigate without first knowing a page ID or running a CLI command. A manual login remains possible through ordinary mouse/keyboard interaction and retains the provider-owned profile.

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
- `rumiai-tests@d71be125` made the v0.1.0 collision reproduction mandatory: it now asserts `default-selection` failure, retained v0.1.0 materialization without its package default, and preservation of the Playwright command projection before testing v0.1.1 recovery. Actions `38088704041` completed **VALIDATED** on Linux x86_64 and ARM64 (five PASS, zero FAIL/SKIP/ERROR in each job). Both jobs checked out `rumiai-os@43c3ebf420edb7a005f3d7e1bb96552234762f0e`; this evidence is revision-specific and does not validate subsequent unrelated HEADs. macOS ARM64 was queued at this checkpoint.
- `rumiai-tests@1d0c876` added `external/electron-web-control/install-live.test`, its formal task scope and a multi-platform GitHub Actions runner. Run `38086638206` proved five PASS, zero FAIL, zero SKIP and `Scope result: VALIDATED` independently on Linux x86_64 and ARM64. Its macOS ARM64 job was still queued at the last check; this does not establish macOS package conformance.

## Working design / known limitations

- Electron `sendInputEvent` keyboard/mouse events can be accepted by the main process but not reach DOM listeners on tested hosts. Current `press`/`click` detect delivery and use an explicitly logged DOM synthetic fallback (`isTrusted=false`) when needed. `fill` uses the DOM native value setter and synthetic input/change events. This can be fingerprinted/rejected by some sites; no stealth guarantee, and it is not equivalent to physical input. Evaluate native alternatives separately before treating the provider as viable for resistant sites.
- `ELECTRON_WEB_CONTROL_SOFTWARE_RENDERING=1` is only an explicit opt-in for virtual-display Viz errors. The normal desktop default remains hardware rendering.
- The v0.1.1 release and catalog now use distinct ordinary service command `electron-web-control-service`; facility/service identity remains `web-control`. Dual-provider installation, explicit provider selection, recovery after v0.1.0 failed default selection and `srv` passed real formal tests on Linux x86_64 and ARM64. macOS ARM64 package validation remains pending and the renderer interaction fallback may be synthetic.

## Current state

The v0.1.1 portable release and corrected `pkg-catalog` metadata eliminate the ordinary-service-command collision with Playwright. The stronger real package/recovery test passed on Linux x86_64 and ARM64 at `rumiai-tests@d71be125` in Actions `38088704041`. It proves failure of v0.1.0 at `default-selection`, materialization of that old concrete without a package default, preservation of Playwright's ordinary service command, and successful installation/selection/public `srv` operation with v0.1.1. The prior run `38088010462` also validated both Linux architectures at `rumiai-tests@8ad2f14` but must not be attributed to d71. The old run `38087870211` had successful Linux jobs but was not the final test revision. macOS ARM64 package validation remains queued.

Current `rumiai-os` implementation has a separate, more general issue: `pkg_install_one` returns success immediately for an already materialized concrete without rerunning `pkg_default_apply`; thus retrying the exact partially materialized v0.1.0 is not a repair operation. This also differs from the current `PACKAGE-MODEL.md` already-installed failure contract and the existing `pkg/install-live.test` expectation. It was identified by current source/test comparison, not proven by a new complete generic package-install test here. Do not silently treat a retry as repaired or change the general multi-operand/dependency semantics inside the Electron catalog fix; the broader `pkg install` behavior requires its own targeted realignment and coverage.

The user's running Playwright service and existing package/profile state remain untouched. Physical VM recovery and manual Google login are still untested. The Linux Electron dependency's root-owned setuid helper is a separate sandbox installation prerequisite (the VM previously emitted an authorization warning), not the cause of the default-selection collision.

## Next action

1. On the user's Linux ARM64 VM, first inspect the existing `pkg provider default web-control`, package defaults and `srv` state, then run only `pkg install electron-web-control@v0.1.1`; verify `pkg default electron-web-control` and the preserved Playwright service command. Do not reinstall v0.1.0, remove package/profile data or change the already-running service implicitly.
2. At a deliberate service handover, stop the existing `web-control` service through the normal `srv stop web-control` path, change the global facility default with `pkg provider default web-control electron-web-control`, and `srv start web-control`; confirm `web-control status`. If stop reports an ownership refusal or setuid preparation requires authorization, handle that explicitly rather than forcing or disabling sandbox by default.
3. Obtain macOS ARM64 formal package evidence when its runner executes; independently test Electron event delivery and manual Google authentication on real desktop hosts. Track the generic `pkg install` partial-install/retry contract mismatch separately from the fixed Electron command collision.

## Blockers / open questions

- macOS ARM64 package validation for the current strengthened test in `38088704041` remains queued; earlier `38088010462` also has a queued macOS job. Neither is a PASS. The provider is not physically validated on the user's Mac.
- User VM/desktop not connected to this execution environment; no physical browser-login validation.
- Electron's DOM synthetic interaction fallback is potentially detectable; native input equivalence remains unresolved.
