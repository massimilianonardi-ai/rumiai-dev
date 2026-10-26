# Autonomous m: complete functional validation

Status: Active
Updated: 2026-10-26

## Goal

Verify **all technical responsibilities actually included in the independent `m` source**, through real public interfaces and real package/catalog/provider/service mechanisms on relevant supported platforms. The required end state is a traceable PASS/FAIL/not-tested matrix, not a subset of successful package demonstrations. Do not declare the foundation validated until coverage includes `pkg` install/dependency/provider/uninstall and `srv`, as well as bootstrap, state, resource commands, TLS/NSS and negative paths.

This is an independently resumable *validation* task, separate from the architecture/source extraction work in `handoff/rumiai-os-source-composition.md`. The source-composition handoff remains authoritative for its own future migration and design decisions, not for this suite's checkpoint.

## Current repository revisions

Preflight 2026-10-26:
- `m/master@a033e5093d7c50b9c74127e90641f5be3ef34903`;
- `pkg-catalog/main@8a346e9c1b30fa40706213cf9798720d7ffd39ff`;
- `rumiai-dev/main@e4af65e751f48175284f57ff9c87ee7baa58ddd0` pre-handoff;
- `rumiai-os/main@673df1a2d5476ad57d54c7bc7e1fc2deeaf16195` and `rumiai-tests/main@89641269b80fc740dfce03b0764ee9e6e49c84e4` remain **frozen**; do not modify, migrate, or run the old suite as part of this task without new explicit authorization.

Refresh HEADs and README mandatory source order before each follow-up task. Past observed physical PASS must retain the exact product revision.

## Applicable canonical sources

`rumiai-dev/{README.md,RULES.md,CONSISTENCY-GATE.md,TESTING.md,PHYSICAL-TESTING.md,RUNNER.md}`;
`specifications/README.md`, `specifications/rumiai-os/{BOOTSTRAP-ENVIRONMENT,COMMAND-ENTRYPOINTS,DOCUMENTATION-MODEL,STATE-MODEL,PACKAGE-MODEL,SERVICE-LIFECYCLE,TLS-TRUST}.md`; supplement with feature-specific specifications when that feature is tested. The current `m` source, catalog and executable/manual inventory and read-only evidence from legacy tests are factual sources, not overrides.

## Fixed task-local choices

- **The test target is complete standalone m**, not independently published `mk` and `jsc` alone.
- Operator-facing install is via `./m pkg install ...`, not manual clones of package source projects. Separate repository checkouts are permissible *inside CI* to reuse test-owned drivers, but do not replace ordinary user-facing installation.
- For positive `srv` lifecycle, use a **real installed service provider** and its facility-service realization; an absent-service check alone is insufficient.
- Test a real provider with `pkg provider default`, a consumer-specific override via `pkg provider bind`, `pkg depend` and `pkg requirement` surfaces, runtime execution, stale/incompatible and ambiguity cases; observing that `mk` auto-installed Node does not establish those properties.
- Do not invent mock or rewritten package managers, fake repository adapters or substitute network/metadata to claim end-to-end PASS. Use public APIs and genuine catalog/releases, with separate narrowly marked component/offline checks only where appropriate.
- Run destructive provider/uninstall/service/system CA tests on disposable *full m* runtime environments (or prepared host supervisor test contexts), not against the user's pre-existing installation or unrelated host services. No opportunistic shutdown of an existing service or takeover of a shared port.
- The permanent `rumiai-tests` suite is frozen; independent `m`-owned CI smoke/integration checks may provide real development evidence, but are **not** represented as replacement permanent suite conformance.

## Acceptance scenarios and fixed verification matrix

All categories below must be accounted for; distinct supported-host behavior remains separate. `PASS` means actual observation at the specified revision; `PENDING` is not a failure or implicit PASS.

| ID | Area | Required public/real scenarios | Current evidence and coverage |
|---|---|---|---|
| M01 | clean bootstrap/environment | initial `m` w/o Node/mk/catalog; PATH/root, shell invocation, failure paths | Latest current-m Ubuntu core smoke plus real shell invocation PASS; broader bootstrap failure cases PENDING |
| M02 | osarch/host platform | detect/update/selector, supported platform materialization | Ubuntu osarch detect/update/show PASS on m@cf3660ca; alternate platform/error permutations PENDING |
| M03 | state-path and mutable scopes | system/user/package state, instances, path security, no side effects | Ubuntu pkg user path nonmaterialization, invalid scope rejection PASS on m@cf3660ca; instances/security/state persistence PENDING |
| M04 | localization and manuals | `lang`, `lang-set`, `manual`, `pager`, topic coverage/fallback | Public locale query/fallback, invalid locale, manual discovery/topic PASS Ubuntu on m@cf3660ca; interactive pager/resource variants PENDING |
| M05 | shell/core/libs/diagnostics | `shell`, `log`, core env/lib loading, controlled errors | Public managed shell, warn logging and invalid severity PASS Ubuntu on m@cf3660ca; full diagnostics/severity cases PENDING |
| M06 | transfer/integrity/archive | `http-fetch`, `digest`, `extract` real HTTPS, verified archive and invalid-input behavior | Public SHA-256 independently verified, stdin, tar.gz extraction and loopback HTTP body/length PASS Ubuntu on m@cf3660ca; HTTPS/formats/backends PENDING |
| M07 | package/catalog/versioning | real `pkg` current/exact version, offline historical compare, catalog snapshot semantics, errors | Chromium historical compare PASS on earlier revision, real current catalog pkg operations PASS Ubuntu `m@1e1ce599`; broader versions/errors PENDING |
| M08 | package install/default/launch | real multi-operand, dependency-first, verified download/extract, `pkg versions/default`, package managed HOME, idempotent repeat | **physical Ubuntu PASS** mk/jsc/Node install, defaults, JS/CSS, mk goal on `a033e509`; general edges pending |
| M09 | package uninstall/reinstallation | uninstall/version/default semantics, referenced-provider protection, uninstall+reinstall, no unrelated mutable state loss | Real jsc/mk/Node uninstall+reinstall via pkg PASS Ubuntu `m@1e1ce599`; referenced-provider protection/mutable-state cases PENDING |
| M10 | recursive dependency planner | `pkg depend`, `pkg requirement list`, ordering, incompatible, no/ambiguous providers | Real shared Node provider dependency planning and deduplication PASS Ubuntu `m@1e1ce599`; incompatibility/ambiguity/multi-provider PENDING |
| M11 | facility/provider semantics | `pkg provider default`, `pkg provider bind`, `pkg requirement resolve`, changing provider, typed cmd/env, runtime context, precedence, ambiguity | Real default/bind/requirement resolution, collision rejection, explicit ownership transition, consumer execution, unbind and unset PASS Ubuntu `m@1e1ce599`; multiple providers/env and ambiguity PENDING |
| M12 | portable service lifecycle | real published service provider install/default/`srv start/stop`, restart semantics, PID/state/logs, idempotence, negative cases | **PASS normal real service start/responsive status/stop/idempotent stop Ubuntu `m@1e1ce599`** using published electron-web-control; restart, stale metadata, fault/ownership cases PENDING |
| M13 | host service supervision | `srv host user` registration/start/restart/stop/remove on Linux systemd & macOS launchd; system registration with explicit account/admin under controlled host permissions | **PENDING**; explicit host capability/permissions needed for host-system positive path |
| M14 | TLS/CA/NSS & browser integration | CA add/list/remove, shared NSS synchronization, tamper fail closed, actual browser HTTPS acceptance/refusal | physical Ubuntu Chrome/Chromium PASS **on older `m@47e6055`**; refresh proportional evidence for current revision pending |
| M15 | complete command/manual coverage and negative validation | every `bin/sys` public interface, status errors, manual coverage, platform differences, consistency | GitHub Ubuntu current basic smoke PASS; full coverage **PENDING** |

Also inventory current repository adapter set (GitHub, Node.js, Chrome, Chromium, generic artifact) against installable catalog packages; missing adapter support must be reported as a product limitation rather than implicitly treating every catalog product as validated.

## Completed

- Prior physical Ubuntu at `m@a033e509` demonstrated genuine `./m pkg install mk@v0.1.0 jsc@v0.1.0`, catalog discovery, managed Node `v26.8.2`, defaults, and real `./m mk` action plus `./m jsc` JS/CSS compilation and execution of generated JS. This completes only the observed portion of M08.
- Existing Ubuntu github-hosted core smoke and mk/jsc public installs are PASS on `a033e509`; corresponding latest macOS jobs were **cancelled**, not FAIL/PASS.
- Historic physical Ubuntu browser HTTPS/CA trust work on `m@47e6055`; separate older Electron NSS test, not transferred to current revision.

## Current state

### Current standalone m full-validation checkpoint (2026-10-26)

The user reiterated that isolated `mk`/`jsc` execution did not meet the task objective: **verify the full autonomous `m` system**. This separate handoff owns full completeness and does not allow a partial PASS to close the project.

New genuine public CLI integration coverage was added in independent `m` CI only, without product runtime changes or frozen-suite edits:
- `m/.github/workflows/m-pkg-provider-lifecycle.yml`: ordinary real `pkg requirement list`, `pkg depend`, multiple public `pkg install`, Node dependency and public execution, `pkg provider default/bind`, `pkg requirement resolve`, deliberate command-publication collision rejection and valid transition from package default to facility default, consumer runtime execution, provider removal, idempotent install, public uninstall and public reinstall. An early test erroneously assumed a facility could take over an existing package-default command. Diagnostic tracing exposed the conflict at `bin/ext-linux-x86_64/node`. Current `PACKAGE-MODEL.md` explicitly requires collision rejection; the test was corrected to expect rejection then deliberately unset the package default and publish via exact-pinned facility default. No product code was changed. The most recent test job **`pkg-public-lifecycle (ubuntu-latest)` PASS**, id `121646679008` at `m@1e1ce59939eb40c7051369b4d2c5915d6d126f0a`; its log explicitly ends with `PASS: public pkg dependencies, provider settings, runtime and uninstall/reinstall`. The separate **`provider-config-offline` PASS**, job `121646678440`, proves public setting/query/unset works on clean m without Node or catalog installation. A prior re-run failed due real transient GitHub releases API HTTP 403 during mk artifact acquisition, before provider assertions; preserve that as separate upstream failure evidence, not an intrinsic package/provider regression.
- `m/.github/workflows/m-srv-provider-live.yml`: first genuinely positive **portable `srv`** path with real catalog-backed `./m pkg install electron-web-control@v0.1.0`. This uses real Electron runtime and managed Node.js dependencies (observed `electron@v45.0.0!linux-x86_64` and `nodejs@v26.12.1!linux-x86_64`), real package sandbox and Xvfb host display. Public `pkg provider default web-control electron-web-control`, `srv start web-control`, actual responsive `m web-control status`, `srv stop web-control`, and repeated idempotent `srv stop web-control` all **PASS** on Ubuntu, job **`121646677996` at exact m HEAD `1e1ce59939eb40c7051369b4d2c5915d6d126f0a`**. Log: `srv: web-control started pid=16756`, `srv: web-control stopped`, `srv: web-control not running`, `PASS: real published provider install, srv lifecycle, responsive service and idempotent stop`. This is genuine installed-service behavior, not an in-process simulated server, and no persistent host service was installed.

Current `m` CI Ubuntu: checkout smoke `121646679176` PASS, public mk install `121646678699` PASS, public jsc install `121646678863` PASS, plus the provider and srv jobs above. **macOS jobs at this checkpoint remained queued**; do not mark PASS without a new check. This work has not validated `srv host user/system`, multiple distinct provider ambiguity/priority, failure/stale-runtime recovery, all state/manual/runtime-facility variants, or full regression scope. `m` changes through this checkpoint were **only CI workflow files**. No modifications to the frozen `rumiai-os`/`rumiai-tests` code or tests.


### Real technical command HTTP, digest, extraction and resource smoke (2026-10-26)

The `m/.github/workflows/m-technical-commands.yml` workflow was added, with no application/library changes, advancing standalone `m/master` to `cf3660ca0e206f94d0c8292b2b2cabeb096703ef`. On a real Ubuntu GitHub runner, it executed public `./m osarch update/show`, `digest -a sha256` compared against independent Python SHA-256 for both file and stdin, real `extract tar.gz` with byte comparison, and `http-fetch` against a real loopback Python HTTP server with body and Content-Length verification. It also exercised `state-path` nonmaterialization/invalid-scope rejection, `lang-set` query/invalid-locale, `lang` fallback, `manual` discovery/exact topic, `log` warn/invalid severity, and managed `shell`. **Ubuntu `technical-public` job `121650261617` PASS at `m@cf3660ca`**. Its macOS counterpart was queued at last observation; do not mark PASS yet. Further tests are required for HTTPS, paging, full locale catalogs, other archive formats, log variants and mutable-state ownership. Latest-m Ubuntu `srv-ubuntu-live` job `121650271263` and `pkg-public-lifecycle` job `121650259900` also PASS.

A full source and catalog inventory was read: public `bin/sys` commands `digest`, `extract`, `http-fetch`, `lang`, `lang-set`, `log`, `manual`, `osarch`, `pager`, `pkg`, `shell`, `srv`, `state-path`, `tls-ca`, `tls-nss-sync` and exposed bootstrap `m`. Current `pkg` has install, uninstall, versions, depend, default, provider and requirement interfaces, facility typed parts; existing catalog provides real `nodejs 26` provider and `ollama 1` service provider with `ollama-serve` realization. Presence in catalog does not itself establish support by the limited set of adapters in current autonomous m.

## Next action

1. Close remaining advanced M07/M09/M10/M11 scenarios: multiple providers, precedence and ambiguity, provider/uninstall protection, range and failure states, state preservation and the typed facility-env path. Keep real public CLI and catalog/released artifacts for end-to-end evidence.
2. Extend M12 beyond its successful real-service normal path to stale-PID, restart/error paths and explicit host user/system supervision M13. Host-system mutations require controlled account/permissions and must not touch unrelated production services.
3. Expand uncovered M01–M06 and M14–M15 cases (pager, localization, errors, State Instances, HTTPS, archive backends and browser TLS on current m) across supported hosts. Keep macOS queued/cancelled separate; uncovered rows PENDING.
4. Once earlier development/hosted validation is stable, request a **short public-command** physical Ubuntu confirmation plan for the full target without reinstalling already tested unrelated packages or manually cloning their source repositories.

## Blockers / open questions

- Legacy `rumiai-os` and `rumiai-tests` are frozen by explicit current user instruction; no old-suite modification or execution.
- A real positive service path exists through published `electron-web-control` on Ubuntu; next unknowns are extended lifecycle failures, host supervisor integration and additional platforms, not basic provider availability.
- Physical host system-user supervisor validation needs a controlled pre-existing account and explicit administrative context; don't alter production services or host security from an inferred test requirement.
