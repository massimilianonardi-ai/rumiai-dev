# RumiAI OS — Web control

Status: **Current / normative**  
Updated: 2026-10-06

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

The `web-control` runtime is a first-party **independent project/release unit**, not source distributed inside `rumiai-os`. Its project identity is:

```text
rumiai-web-control
```

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

The concrete first-party package identity is:

```text
rumiai-web-control
```

The provider-independent facility identity is:

```text
web-control
```

Consumers depend on the `web-control` facility rather than on the concrete package when provider substitution is relevant.

Compatibility level `1` requires:

```text
command: web-control
service: web-control
```

The public command is the ordinary deterministic client/control surface. The service is the long-running local controller runtime and follows the existing `srv` provider-backed service lifecycle.

Portable lifecycle therefore uses:

```text
srv start web-control
srv stop web-control
```

The provider service process MUST remain foreground from its own perspective and obey the baseline `srv` SIGTERM lifecycle.

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

- report controller/capability status;
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

The exact selector representation is not fixed by this contract merely because the first implementation uses Playwright.

## 6. Debug/introspection boundary

Low-level browser/debugger access is a privileged extension of `web-control`, not the ordinary provider-independent operation surface.

A concrete browser provider MAY expose controlled page-scoped debugger commands. The initial Chromium implementation may use Chrome DevTools Protocol internally.

The baseline MUST NOT require publication of an unrestricted browser remote-debugging endpoint.

A provider MUST NOT expose a raw debugger port to non-local networks by default.

Provider-specific debugger protocols and methods are not compatibility-level-1 semantics and MUST NOT leak into the provider-independent facility contract.

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
WEBCTRL-03  rumiai-web-control is an independent first-party project/release unit
WEBCTRL-04  mk owns project development lifecycle while pkg owns runtime installation/integration
WEBCTRL-05  package identity is rumiai-web-control and provider-independent facility identity is web-control
WEBCTRL-06  compatibility level 1 exposes the web-control command and provider-backed web-control service
WEBCTRL-07  persistent authenticated browser state uses dedicated web-control profiles rather than silently reusing an ordinary personal browser profile
WEBCTRL-08  live page identities are opaque web-control runtime identities
WEBCTRL-09  rendered HTML/text and screenshot are portable baseline capture evidence
WEBCTRL-10  deterministic interaction receives explicit targets; goal interpretation remains above the control boundary
WEBCTRL-11  raw debugger protocols are provider-specific privileged extensions, not the provider-independent baseline
WEBCTRL-12  unrestricted browser remote-debugging endpoints are not published by default
WEBCTRL-13  Playwright/CDP/Chromium are initial implementation choices and do not define the public contract
WEBCTRL-14  generic scheduling is outside web-control
```
