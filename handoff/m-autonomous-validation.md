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
| M01 | clean bootstrap/environment | initial `m` w/o Node/mk/catalog; PATH/root, shell invocation, failure paths | GitHub Ubuntu/macOS core smoke on `a033e509` partial; macOS latest jobs cancelled |
| M02 | osarch/host platform | detect/update/selector, supported platform materialization | Ubuntu physical selection prior commits; GitHub Ubuntu smoke current, broader matrix pending |
| M03 | state-path and mutable scopes | system/user/package state, instances, path security, no side effects | partial earlier Ubuntu; comprehensive pending |
| M04 | localization and manuals | `lang`, `lang-set`, `manual`, `pager`, topic coverage/fallback | basic GitHub smoke; normal paging and localization fallback pending |
| M05 | shell/core/libs/diagnostics | `shell`, `log`, core env/lib loading, controlled errors | basic smoke; full contracts pending |
| M06 | transfer/integrity/archive | `http-fetch`, `digest`, `extract` real HTTPS, verified archive and invalid-input behavior | earlier Ubuntu sample; full supported format/backends pending |
| M07 | package/catalog/versioning | real `pkg` current/exact version, offline historical compare, catalog snapshot semantics, errors | current Chromium compare CI PASS Ubuntu; rest pending |
| M08 | package install/default/launch | real multi-operand, dependency-first, verified download/extract, `pkg versions/default`, package managed HOME, idempotent repeat | **physical Ubuntu PASS** mk/jsc/Node install, defaults, JS/CSS, mk goal on `a033e509`; general edges pending |
| M09 | package uninstall/reinstallation | uninstall/version/default semantics, referenced-provider protection, uninstall+reinstall, no unrelated mutable state loss | **PENDING** |
| M10 | recursive dependency planner | `pkg depend`, `pkg requirement list`, ordering, incompatible, no/ambiguous providers | **PENDING** (mk/jsc auto Node is only partial dependency install evidence) |
| M11 | facility/provider semantics | `pkg provider default`, `pkg provider bind`, `pkg requirement resolve`, changing provider, typed cmd/env, runtime context, precedence, ambiguity | **PENDING** |
| M12 | portable service lifecycle | real published service provider install/default/`srv start/stop`, restart semantics, PID/state/logs, idempotence, negative cases | **PENDING** |
| M13 | host service supervision | `srv host user` registration/start/restart/stop/remove on Linux systemd & macOS launchd; system registration with explicit account/admin under controlled host permissions | **PENDING**; explicit host capability/permissions needed for host-system positive path |
| M14 | TLS/CA/NSS & browser integration | CA add/list/remove, shared NSS synchronization, tamper fail closed, actual browser HTTPS acceptance/refusal | physical Ubuntu Chrome/Chromium PASS **on older `m@47e6055`**; refresh proportional evidence for current revision pending |
| M15 | complete command/manual coverage and negative validation | every `bin/sys` public interface, status errors, manual coverage, platform differences, consistency | GitHub Ubuntu current basic smoke PASS; full coverage **PENDING** |

Also inventory current repository adapter set (GitHub, Node.js, Chrome, Chromium, generic artifact) against installable catalog packages; missing adapter support must be reported as a product limitation rather than implicitly treating every catalog product as validated.

## Completed

- Prior physical Ubuntu at `m@a033e509` demonstrated genuine `./m pkg install mk@v0.1.0 jsc@v0.1.0`, catalog discovery, managed Node `v26.8.2`, defaults, and real `./m mk` action plus `./m jsc` JS/CSS compilation and execution of generated JS. This completes only the observed portion of M08.
- Existing Ubuntu github-hosted core smoke and mk/jsc public installs are PASS on `a033e509`; corresponding latest macOS jobs were **cancelled**, not FAIL/PASS.
- Historic physical Ubuntu browser HTTPS/CA trust work on `m@47e6055`; separate older Electron NSS test, not transferred to current revision.

## Current state

A full source and catalog inventory was read: public `bin/sys` commands `digest`, `extract`, `http-fetch`, `lang`, `lang-set`, `log`, `manual`, `osarch`, `pager`, `pkg`, `shell`, `srv`, `state-path`, `tls-ca`, `tls-nss-sync` and exposed bootstrap `m`. Current `pkg` has install, uninstall, versions, depend, default, provider and requirement interfaces, facility typed parts; existing catalog provides real `nodejs 26` provider and `ollama 1` service provider with `ollama-serve` realization. Presence in catalog does not itself establish support by the limited set of adapters in current autonomous m.

## Next action

1. Complete real *public-path* development/hosted tests of M07–M11 using the current m + current catalog, preferably on CI disposable runners and without changing frozen `rumiai-tests`; read real public manuals for inputs and ensure no fake implementation path.
2. Positive `srv` testing M12 using an installable live service provider and a test-owned process/port. Only use a host supervisor M13 when host capabilities are explicit, avoid destructive operations on unrelated services.
3. Extend M01–M06, M14–M15 using proportionate real checks and earlier evidence where exact revisions permit. Return to physical Ubuntu only after earlier real executions make success expected; request short public command blocks, not manual package-source clones.
4. Summarize by item, revision, host and evidence; keep `PENDING` visible until real result obtained. Check GitHub Actions status before claiming it.

## Blockers / open questions

- Legacy `rumiai-os` and `rumiai-tests` are frozen by explicit current user instruction; no old-suite modification or execution.
- Which currently catalogued service packages can install end-to-end via the limited standalone adapter set must be verified before service selection. If no real service package is installable, report product gap and evaluate the minimal authorized correction rather than simulate a successful service.
- Physical host system-user supervisor validation needs a controlled pre-existing account and explicit administrative context; don't alter production services or host security from an inferred test requirement.
