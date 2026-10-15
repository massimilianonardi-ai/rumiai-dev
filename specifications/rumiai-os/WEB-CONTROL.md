# RumiAI OS — Web control

Status: **Current / normative**  
Updated: 2026-10-11

This document defines the deterministic Web observation/control capability used beneath RumiAI Web cognition.

## 1. Role and ownership

The deterministic capability is named:

```text
web-control
```

`web-control` belongs semantically to the technical `m` layer. It is general-purpose, deterministic infrastructure and MUST NOT contain RumiAI reasoning, user-goal interpretation, autonomous planning or generic scheduling policy.

The RumiAI AI-level capability is `web-sense`. The relationship is:

```text
RumiAI
    |
    v
web-sense
    |
    v
web-control
    |
    v
Web/browser/provider mechanics
```

`web-control` performs explicitly requested operations and returns observable evidence. `web-sense` interprets that evidence and decides what operation to request next.

## 2. Project and distribution boundary

Semantic ownership and source/distribution ownership are separate dimensions.

A concrete `web-control` provider is a first-party **independent project/release unit**, not source distributed inside `rumiai-os`. The current released concrete provider projects are:

```text
pwc-web-control       Playwright / Chrome
electron-web-control  Electron
```

The project identities are distinct; neither changes the provider-independent `web-control` contract.

The project development lifecycle is managed through the normal `mk` project model. Runtime installation/distribution is managed through `pkg`.

This means:

```text
mk
    develops/builds/tests/releases the project

pkg
    installs/selects/integrates released runtime artifacts
```

`mk` is not a second installer and `pkg` is not a project build engine.

Distribution outside `rumiai-os` does not change the semantic ownership of `web-control`: it remains an `m` capability.

The runtime artifact MUST consume only explicit public `m`/package/facility contracts. It MUST NOT depend on private `rumiai-os` implementation paths or internal libraries merely because the capability is `m`-owned.

## 3. Package and facility identity

The current installable provider package identities are:

```text
pwc-web-control
electron-web-control
```

Previously published `rumiai-web-control` package definitions remain compatible with their original release artifacts. Changing concrete package identity does not rename or migrate existing package-owned state.

The provider-independent facility identity is:

```text
web-control
```

Consumers depend on the `web-control` facility rather than on the concrete package when provider substitution is relevant.

Compatibility level `1` is the existing immutable published baseline: command `web-control` and service `web-control` expose the lifecycle, rendered inspection/capture and deterministic click/fill/press semantics defined in this document, without any requirement to support document scrolling.

Compatibility level `2` is a separate complete, self-contained contract. It requires the same command/service identities and all level-1 operation semantics **plus** the portable `page scroll` operation below. It is not inferred to be automatically compatible with level `1` by the package resolver: consumers must state which exact compatibility they accept, and providers must declare their supported level exactly. Historic level-1 provider releases and contracts remain unchanged.

Compatibility level `3` is a new complete interface level requiring all level-2 semantics **plus** the page-scoped persistent debugger-session contract in §6. Both first-party Chromium providers MUST implement the same level-3 command semantics before either publishes a level-3 provider package. Source support alone is not a release/facility compatibility declaration; the package catalog, release and validation must explicitly advertise and verify level 3. Existing level-1/2 contracts and package releases remain unchanged.

The public command is the ordinary deterministic client/control surface. The service is the long-running local controller runtime and follows the existing `srv` provider-backed service lifecycle.

Portable lifecycle therefore uses:

```text
srv start web-control
srv stop web-control
```

The provider service process MUST remain foreground from its own perspective and obey the baseline `srv` SIGTERM lifecycle.

For a browser-backed provider, the long-running provider service is the controller lifecycle; the controlled browser runtime is a managed subordinate resource. If that browser application terminates externally or crashes, the provider foreground process MUST remain available, detect that the browser is absent and recreate it when a later operation requires a browser. Browser recreation MUST use the same logical profile and MUST NOT imply persistence of prior live page identities. A status/observation request MUST be able to report that the browser is absent without implicitly recreating it; an operation that requires a live browser, such as creating a new page, triggers recreation. Closing an individual `web-control` page does not stop the service.

The public client command and the service implementation may be different ordinary package commands inside a concrete provider. Facility service realization chooses the provider-owned foreground start command without making that internal command a provider-independent public command.

## 4. Browser/session model

The browser-backed baseline uses persistent **profiles** and runtime **pages**.

A profile represents persistent browser/user session state such as cookies, local storage, authentication state, consent state and site preferences.

A provider MUST use a dedicated `web-control` profile location by default. It MUST NOT silently reuse the user's ordinary personal browser profile.

The default profile identity is:

```text
default
```

Additional named profiles may be supported. Profile names are logical `web-control` identities; callers MUST NOT depend on provider-private browser directory layouts.

A page is a live browser document/tab-like runtime object. Page identities are opaque `web-control` runtime identifiers. They are not Playwright handles, CDP target IDs or browser implementation identifiers, and persistence of page identity across controller restart is not implied.

## 5. Deterministic baseline capabilities

The baseline capability covers these semantic operations.

### Lifecycle/observation

- report controller/capability status, including browser-runtime availability for browser-backed providers without implicitly starting an absent browser;
- enumerate live pages;
- create and close a page;
- navigate a page to an explicit URL;
- report final URL and document title after navigation.

### Inspection

For one live page, the baseline can expose:

- current rendered document HTML after page JavaScript has executed;
- current readable body text;
- current cookie/local-storage/session-storage evidence when explicitly requested;
- ordinary page metadata needed to identify the observation.

Inspection returns observed data. It does not interpret that data in relation to a user goal.

### Capture/export

A page can be persisted as evidence.

The portable baseline formats are:

```text
html
text
screenshot
```

The HTML capture represents the current rendered DOM serialization, not merely the original navigation response body.

A capture records at least:

```text
page identity
final URL
title
capture timestamp
produced artifact identities/paths
```

Provider-specific richer archive formats such as MHTML MAY be exposed as extensions but are not required by compatibility level 1.

### Deterministic interaction

The baseline supports explicit target/action primitives sufficient for deterministic browser control, including:

```text
click
fill
press
```

The caller supplies the target/operand. Deciding which page element satisfies a natural-language goal belongs to `web-sense`, not `web-control`.

The compatibility-level-2 deterministic operation `page scroll` accepts a page identity and a finite signed vertical CSS-pixel delta (`0` means observe without moving). It reports the resulting document-level `scrollY`, `documentHeight`, `viewportHeight` and `atBottom` flag. Scrolling runs in the actual page context so application-driven lazy loading can observe it. The returned geometry is an instantaneous observation; a caller must allow page loading to settle and confirm stable results before asserting enumeration completeness. The command performs no site interpretation and exposes no general script evaluation, debugger or network instrumentation.

The exact selector representation is not fixed by this contract merely because the first implementation uses Playwright.

## 6. Debug/introspection boundary

Compatibility levels 1 and 2 do not include debugger operations. Chromium-specific one-shot debugging such as the existing Playwright `debug cdp <page> <method> [params-json]` was historically a provider extension and must not be mistaken for the common level-1/2 interface.

### Complete compatibility-level-3 persistent debugger interface

Level 3 adds the **same controller-owned session operations and response envelopes in both** `pwc-web-control` and `electron-web-control`, without exposing a remote-debugging port. The currently qualified low-level protocol for the two Chromium-based providers is Chrome DevTools Protocol (CDP): the command/event transport and ownership lifecycle are portable across these two providers, while individual CDP method names and payloads follow the external Chromium protocol and are not promised for a hypothetical non-Chromium provider.

```text
web-control debug session open <page>
web-control debug session send <session> <cdp-method> [params-json]
web-control debug session events <session> [after-sequence] [limit] [wait-ms]
web-control debug session close <session>
```

- **Open** attaches one persistent debugger to an existing opaque page identity and returns `{session, page}`. The session identity is an opaque controller-local handle, not a CDP target identifier, and survives client command exits and page navigation. At most one managed persistent debugger session is open per page. An already attached external debugger may prevent opening.
- **Send** dispatches one method with a JSON object of protocol parameters and returns `{session, result}` with the unmodified method result. It can evaluate a suspended call frame and resume execution while a prior `Debugger.paused` event is outstanding. The absence of params means `{}`. Invalid method or malformed params is an error.
- **Events** returns `{session, after, lastSequence, events}` where each event is `{sequence, method, params}`, monotonically numbered from 1 for that session. `after-sequence` starts at 0; only strictly later events are returned. `limit` defaults to 100 and is 1–128. `wait-ms` defaults to 0 and is 0–30000; positive values wait until an event, closure or timeout. Calls are separate normal local IPC requests; no long-lived CLI subprocess or raw debugger socket is required.
- **Bounded delivery:** events are buffered in memory only, capped at 128 entries and 4 MiB total, with oversized individual events capped at 1 MiB. If an event is dropped/evicted, a caller with a cursor before the retained boundary receives explicit `debug.events-overflow`, never a falsely complete sequence. Clients that need every event must drain promptly. Long polling does not persist events across controller restarts.
- **Close** explicitly detaches and invalidates the session. Page/browser close, renderer loss, external debugger detach and controller shutdown also invalidate the handle. Subsequent use fails with `debug.session-not-found`; the client must open a new session on a live page. A session may disappear while an event poll is outstanding; the poll then fails with this identity.
- Ordinary page commands, including navigation and native click/fill/press, remain supported when a managed session exists. Providers coordinate any debugger use for internal native input rather than detaching the caller's session. The existing Playwright one-shot `debug cdp` remains backward compatible; both Chromium providers may expose its equivalent, but it is not the persistent session and cannot be used to implement multi-request breakpoint handling.

The service owns the session and event subscription, not the command client. No client may reconstruct provider-private browser state, and no unrestricted TCP CDP endpoint is published by default. The local controller IPC remains private/restricted; raw debugger methods can expose cookies, credentials, scripts and private page state, so this operation is explicitly privileged and must not be enabled over arbitrary remote transports.

A future non-Chromium provider must implement the agreed level-3 command semantics (including the specified protocol) to claim level 3 or use another compatibility level with a distinct documented capability. Do not silently interpret a partial provider feature as a common `web-control` capability.

## 7. Provider boundary

The `web-control` contract is provider-independent.

The first implementation is expected to use a real Chromium-class browser controlled through Playwright, but:

- Playwright is an implementation/provider dependency, not the public contract;
- CDP is a provider-specific low-level mechanism, not the public contract;
- Chromium is an initial browser implementation choice, not the semantic definition of `web-control`;
- Electron is not required by the core contract.

A later provider may use another browser/control stack when it satisfies the same compatibility contract.

Deterministic site-specific helpers may live below the AI boundary when they implement a defined repeatable operation. Specificity alone does not make a helper part of `web-sense`.

## 8. State and security

When installed as a package, persistent browser/profile state belongs to the provider package's normal managed package HOME/state contract. Callers MUST NOT reconstruct its physical state path.

Portable service runtime/log lifecycle remains owned by `srv`; `web-control` does not introduce a second service supervisor.

The controller boundary is local by default.

Security-sensitive browser state includes authenticated cookies, local storage, active sessions and debugger capabilities. Implementations MUST therefore:

- keep controller IPC local by default;
- preserve the browser's sandbox/isolation mechanisms by default; an unsandboxed browser mode may exist only as an explicit provider-specific opt-in and MUST NOT be the normal package default;
- use restrictive local permissions for private control endpoints;
- avoid exposing raw browser debugging interfaces as the normal public API;
- preserve explicit human intervention for login, consent or challenge flows rather than implementing CAPTCHA/anti-bot bypass behavior.

## 9. Relationship to scheduling and AI

Generic scheduling is outside `web-control`.

A scheduler may invoke RumiAI/`web-sense`, which in turn consumes `web-control`, but `web-control` does not decide when a task should run or whether an observed condition is important.

Examples:

```text
"navigate to this URL"
    web-control responsibility

"capture this page now"
    web-control responsibility

"find the product price in this page"
    web-sense/adapter interpretation

"tell me when this becomes a good offer"
    RumiAI reasoning + scheduling
```

## 10. Current invariants

```text
WEBCTRL-01  web-control belongs semantically to m and is deterministic
WEBCTRL-02  web-sense is the AI layer above web-control
WEBCTRL-03  pwc-web-control and electron-web-control are separate first-party provider project/release units
WEBCTRL-04  mk owns project development lifecycle while pkg owns runtime installation/integration
WEBCTRL-05  concrete provider package identities are pwc-web-control and electron-web-control; provider-independent facility identity is web-control
WEBCTRL-06  compatibility level 1 exposes the web-control command and provider-backed web-control service
WEBCTRL-07  persistent authenticated browser state uses dedicated web-control profiles rather than silently reusing an ordinary personal browser profile
WEBCTRL-08  live page identities are opaque web-control runtime identities
WEBCTRL-09  rendered HTML/text and screenshot are portable baseline capture evidence
WEBCTRL-10  deterministic interaction receives explicit targets; goal interpretation remains above the control boundary
WEBCTRL-11  raw debugger method payloads remain Chromium-specific and privileged; the shared level-3 session lifecycle is a defined additional contract, not part of levels 1/2
WEBCTRL-12  unrestricted browser remote-debugging endpoints are not published by default
WEBCTRL-13  Playwright/CDP/Chromium are initial implementation choices and do not define the public contract
WEBCTRL-14  generic scheduling is outside web-control
WEBCTRL-15  browser-backed providers preserve browser sandboxing by default; unsandboxed mode is explicit provider-specific opt-in only
WEBCTRL-16  browser-backed provider services outlive browser-runtime termination, detect browser absence and recreate the browser on demand without preserving prior live page identities
WEBCTRL-17  browser-backed status reports browser-runtime absence without starting it; browser-required operations recreate it on demand
WEBCTRL-18  compatibility level 2 adds portable page scroll with vertical delta and post-scroll document geometry
WEBCTRL-19  level 3 requires identical page-scoped persistent debugger open/send/events/close semantics across both Chromium providers
WEBCTRL-20  debugger sessions survive separate commands and page navigation but not page/browser/controller shutdown or external detach
WEBCTRL-21  debugger event streams use monotonic cursors and explicit bounded-buffer overflow instead of silent loss
WEBCTRL-22  level 3 never requires publishing a raw browser remote-debugging port; level 1 remains semantically immutable
```
