# Autonomous m: complete functional validation

Status: Active
Updated: 2026-11-05

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

### S initiated: portable srv and host supervision (2026-11-05)

- The operator authorized execution of Branch S of `m-os-completion`. The dedicated forward-only `m-os/m-os-completion-s` branch starts from `master@e0bcf2d69ba4e4209a93fd7d0c9b08a00def3a0f`; S1 workflow change is `25e66a829afb86d293d7e3bd9460249fc728a092` in `.github/workflows/m-srv-provider-live.yml`. No product runtime, catalog, first-party release, frozen legacy or permanent-suite file was modified.
- S1 now has additional authentic public scenarios prepared around the existing real `electron-web-control@v0.1.0` install: missing default / malformed service name; repeat start; another caller's ordinary stop vs explicit `-f`; stop/start recovery; provider-default removal while the actual process runs; and a fresh launch after rebinding. Unrelated-PID takeover and stale-PID recycling are **not yet validated**. S2 has only a **prepared** non-root rejection check; user/system positive host-supervisor paths still require the controlled host/authority gate.
- **Execution status: PENDING.** No GitHub Actions run for `m-os-completion-s` was listed at this checkpoint, so none of those prepared scenarios is a claimed PASS. Prior master `m-srv-provider-live` run [41426638581](https://github.com/massimilianonardi-ai/m-os/actions/runs/41426638581) at `3feb1f0cfa2b2bd74c82ec3aaf9e57726a6cd841` failed **before srv**, at the real `pkg install` dependency resolver (`nodejs =26` provider-unresolvable). This is a dependency/package integration blocker to route through the existing P2 owner, not evidence that an S1 lifecycle assertion failed.
- **Next S action:** execute and inspect the exact S branch workflow on disposable hosted infrastructure, reconcile forward after P2 changes when real installation remains blocked, and correct actual S-owned failures only. Complete proportional S1 stale/lifecycle scenarios, then S2 user/system host operations on explicitly controlled applicable systemd/launchd environments; keep host and revision-specific outcomes separate from operator reference-host physical validation.

### A1 initiated: public bootstrap/state coverage (2026-11-05)

- Fresh preflight used `rumiai-dev/main@f17b38d1e68489074e8497c3a984e2cc26ea67d4` (subsequently advanced forward), `m-os/master@31693e814f682690adfd48185da822f7f5007f9e` and current independent catalog/package HEADs. Later `rumiai-dev` movement was checked; only the unrelated browser-column handoff and the package model's own reconciliation changed before this checkpoint.
- The mainline command/manual and repository-adapter inspection is recorded once as P0 in `handoff/m-os-completion-orchestration.md`; it does not supersede the M01–M15 evidence table above. Actual `m`, `osarch`, `state-path`, core/base/osarch libraries and their manuals were read against the root/bootstrap/state/entrypoint/POSIX contracts.
- `m-os/master@e0bcf2d69ba4e4209a93fd7d0c9b08a00def3a0f` adds `.github/workflows/m-bootstrap-state-public.yml` only; no runtime product, catalog, package release or frozen `rumiai-tests` modifications. The A1 workflow invokes genuine public commands on hosted Ubuntu/macOS with physical-root/symlink/PATH bootstrap, no unmanaged state-path materialization, default/explicit user binding, package State Instance and malformed-operand statuses, as well as `osarch` explicit selection and unsupported-selection rejection.
- **Result: PENDING.** The workflow source and commit diff were inspected. No run tied to that commit was confirmed at this checkpoint; no development host, reference host or physical test was executed. A generated workflow file is not runtime evidence. Previous M01–M03 evidence remains revision-specific to the exact earlier commits named above.
- **Next A1 action:** obtain and inspect Ubuntu/macOS Actions job results for this exact commit, correct any observed failure within A1-owned files with manual/diagnostics consistency, then extend remaining selector fault/rollback and state-path abnormal-path cases proportionately. Do not mark A1 PASS until observed on required hosts. A2, A3 and A4 may proceed on their own nonconflicting files/state with fresh preflight; A3 must not edit P2-owned package extraction libraries.


### Branch A2–A4 public CI coverage authored (2026-11-05)

Fresh preflight: `rumiai-dev/main@d3bbb4ec6d957965557a7e46ed8070864a7192b2`, `m-os/master@e0bcf2d69ba4e4209a93fd7d0c9b08a00def3a0f`, independent package/catalog HEADs and frozen suite revisions were checked before work. Source and manuals for the actual A2/A3/A4 commands were inspected against current `LANG-BOOTSTRAP`, `PAGER`, `DOCUMENTATION-MODEL`, `DIAGNOSTICS`, `POSIX-PORTABILITY-LAYER`, `TLS-TRUST`, `COMMAND-ENTRYPOINTS` and the matching scope handoffs. No public command API or manual contract was changed.

- **A2, M04–M05:** `m-os/master@998aa2aad12aefd4e2dcfeb0ede495b4d54465df` added `.github/workflows/m-shell-resources-public.yml` with real public shell/explicit library sourcing, locale switch and rejection without mutation, fallback, exact manual topic and missing-topic status, diagnostic severity/filter behavior on Ubuntu/macOS.
- **A3, M06:** `m-os/master@ffa7a9df1b851804ec7220c49b7be0beb3ae1d72` added `.github/workflows/m-transfer-integrity-public.yml` with real host sha256/sha512/md5 comparison, tar/zip/gzip extraction and corrupt gzip rejection, actual local HTTPS/TLS rejection and test-local trusted transfer/length. The local HTTPS server uses real socket/SSL and the production `http-fetch`, not a replacement backend. The self-signed test CA is scoped only to the curl process. Archive traversal and remaining format backends are still unverified.
- **A4, M14:** `m-os/master@d056358ce9cbaf717c476bb1bc0112038e6a6f1d` added `.github/workflows/m-tls-nss-public.yml`; `8c21070960c46936d56ab3a0973770f863e9d022` corrected its revocation assertion to check the exact former nickname. It exercises `tls-ca` valid CA/private-key rejection/idempotence/removal, isolated browser HOME and Linux NSS import/manifest-tamper/revocation when the actual `certutil` and `flock` capabilities exist, and explicit NSS non-applicability on macOS. Missing NSS tools produce an explicit `PENDING` observation, not a false NSS PASS. A real browser negative→trusted→revoked HTTPS transition remains a separate required A4 gate.

**Evidence status for A1–A4:** `PENDING` execution. GitHub Actions REST currently reports no run for the A1 workflow commit, and no new job for these new CI-only commits has been verified. These commits prove authored test source only, not pass/fail behavior on any host. The ChatGPT auxiliary host cannot fetch the complete public repository over its network in this session (GitHub DNS resolution failed), so no independently reconstructed/partial checkout has been mislabeled as an authentic target execution. No reference-host physical validation was performed. The frozen permanent suite and legacy product, package catalog, release artifacts and `m-os` runtime sources remain unmodified by this branch A work.

**Next A work:** obtain executed Ubuntu/macOS jobs for the exact workflows/revisions (workflow_dispatch or fresh eligible push as available), inspect public output and classify each host/result. Fix any discovered failures in the owning A1–A4 surface with matching manual/diagnostics/revision checks, then extend A3 traversal and A4 actual browser revocation coverage. Coordinate A1/core touches with A2 and keep A3 out of P2-owned `pkg-download`/`pkg-extract`.


**Cross-workstream completion plan:** `handoff/m-os-completion-orchestration.md` now owns the detailed conditional P0/A*/J*/S*/R*/C*/P*/V*/I* dependency map and integration orchestration. This validation handoff remains owner of M01–M15 actual test/evidence state; this reference does not transfer or duplicate that state. The complete `m-os` DEVPLAN still carries explicit contract/host gates, so the new map is not blanket implementation authorization.

### DEVPLAN re-review of full m-os completion against m-os archived conversations (2026-11-05)

**Verdict for one end-to-end executable plan: Specifiche insufficienti**, but the reason is narrower than in the preceding checkpoint. The **current-contract autonomous `m-os` validation** already has a bounded M01–M15 acceptance matrix and can advance independently; completion of the **user-requested general `context`** remains a separate high-impact unsettled public design. Do **not** hold the ready present-contract evidence streams behind that future design, invent a finished grammar, or treat this provisional dependency sketch as delegated executable units. `DEVPLAN.md` is the generic procedure; this active handoff owns the task-specific planning checkpoint.

**Archive source coverage (non-normative user-intent / historical evidence only):**

- Inspected `chats/m-os/2026-10-26 Verifica Ubuntu m/index.html`, `2026-10-29 m context 2/index.html`, `2026-11-03 m-context 3/index.html`, `2026-11-03 m-context 4/index.html`, `2026-11-04 m-context 5/index.html`, and `2026-11-04 migrazione rumiai-os a m-os - riepilogo.md`; cross-checked user decisions with current `handoff/{rumiai-os-source-composition,pkg-definition-model-review,pkg-dependency-resolution}.md` and `specifications/rumiai-os/{CURRENT-MODEL,BOOTSTRAP-ENVIRONMENT,PACKAGE-MODEL,STATE-MODEL,LIBRARY-INTERFACES,RESOURCE-MODEL,JSON-QUERY}.md`. The archived `2026-10-26 m context/index.html` exists but is empty (0 bytes), so no intent is attributed to its missing content.
- Also examined the archived `2026-11-03 json posix command`, `2026-11-04 rsudo APIsIX`, `2026-11-04 rsudo APIsIX 2`, and `2026-11-04 keycloak k04` conversations. `json` is relevant to technical `m` completeness; APISIX and Keycloak are specialized `rsudo` modules governed by their own specifications/handoffs and are **not** standalone `m-os` bootstrap acceptance gates. Archives and assistant statements do not override the current repo contracts.

**Corrections to previous broad insufficiency assessment:**

1. **The autonomous technical-core scope is substantially fixed, not an unanswered choice.** The operator wants the smallest **operationally complete autonomous `m`** with bootstrap + `pkg`, without bootstrapping through Node.js or `mk`; `pkg-catalog` remains independent and network/catalog access is demand-driven. Existing optional tools are extracted by cohesive ownership, not copied wholesale from legacy `rumiai-os`. The operator expressly rejects treating `mk/jsc` PASS as proof of the full system and insists on public `pkg install`, providers/dependencies, service lifecycle and real negative cases. Use M01–M15 as the bounded autonomous-validation acceptance inventory, and route optional package-source extraction separately.
2. **The operator has already fixed several previously over-questioned choices.** The v2 schema stays as-is; do not add package-store filesystem sealing, extend `rumiai-validate` target identity, reopen resource exports (`v3` or later), change accepted `link/bin` / `link/lib/{sh,java}` semantics, or generalize package-specific wrappers. Existing v1 authoring stays under `v1`, feature v2 under `v2`. Finish authentic real-artifact/Java/host validation, then coordinate forward-only promotion of runtime/catalog once consistency gates pass. A transient upstream GitHub HTTP 403 can require bounded retry/scheduling; it is not a reason for simulated packages or endless unrelated refinement.
3. **The general `context` direction is already substantial user intent, not a blank-sheet design:** one shell-active context with replacement rather than a stack; operands folded left-to-right; selective overrides and named complete-context presets as ordered inputs; ordinary no-argument activation of an appropriate default context in managed shells; coherent provider/facility, package, environment/state dimensions and protected inheritance into nested consumers. Reuse pre-existing package/default/provider command views composed by `PATH` without regenerating symlinks on each `context` call. These directions are documented in the source-composition handoff, **but only exact-installed `pkg=` selection with no-arg reset is currently promoted/implemented**. The full public grammar, defaults, inheritance/trust, consumer library binding and projection lifecycle remain to be specified/realigned before independent full-context implementation.
4. **One newly verified inventory mismatch:** `JSON-QUERY.md` currently specifies independent POSIX `bin/sys/json` and the frozen legacy `rumiai-os` tree supplies that source and `res/sys/manual/json`, while current autonomous `m-os/master` and `pkg-schema-v2` omit that executable. The existing `m-os/lib/sys/sh/json.lib.sh` is a *different* interface. This is an actionable core-source completeness assessment, owned by `handoff/rumiai-os-source-composition.md`; do not assume that M01–M15's previous 16-command inventory alone proves exhaustive completeness.
5. **The package-install discrepancy is not an invitation to re-ask the user.** Current `PACKAGE-MODEL.md` Installation prose permits per-operand best-effort, but PKG-99 requires upfront full-request syntax validation; `handoff/pkg-dependency-resolution.md` records the operator's selected upfront validation and dependency-first same-snapshot planning. Existing owner must reconcile the canonical conflict and implementation/test evidence before `pkg`/v2 acceptance. Ordinary sh/Java library exports are not facility dependencies; transparent consumer package-library requirements remain an unresolved different concern.

**Current inspected repository checkpoints (refresh before resuming):** `m-os/master@31693e814f682690adfd48185da822f7f5007f9e`, `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`; `pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609`, `pkg-catalog/pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7`; `m-core@0afb8752440808e9080a55c667576ff2f9b8eb32`, `m-term@c32aac18f6659ed4f569cb780080675fa64f9e3a`, `m-rsudo@2763019ada5b1e33151f0c1e58b75af22ed6e99c`. Hosted real three-package composed CI PASS remains pinned to [m-core 42037725004](https://github.com/massimilianonardi-ai/m-core/actions/runs/42037725004); operator-confirmed vmdev interactive menu PASS is not a revision-pinned formal physical run.

**Provisional parallel dependency map, not an implementation assignment:**

- **Now independently assess/validate (no contract redesign):** (A) `m-os` public core M01–M06 and M14 negative/portability gaps, including legacy/current `json` source/manual gap classification by the source-composition owner; (B) M12–M13 real portable `srv` failure/restart and permitted Linux/macOS host-supervisor scenarios; (C) real v1/v2 catalog install, library-export, Java-adapter and consumer scenarios under the pkg-definition owner, preserving existing CI evidence; (D) `m-core`/`m-term`/`m-rsudo` exported package integration and package-local `rssh`/remote-injection correction under the source-composition owner, with SSH/sudo tests only against authorized targets; (E) M15 current command/manual inventory, status/host evidence gaps. Investigations can run together, but no overlapping writes to the same `m-os` source/CI/manual or shared package release.
- **A coordinated single-owner `pkg` integration lane:** `pkg-dependency-resolution` first resolves already-known install semantic/spec mismatch, while `pkg-definition-model-review` independently completes nonconflicting v2 catalog/adapter and real consumer verification. Actual overlapping `m-os/lib/sys/sh/pkg` edits, published package integration/launcher/default/provider semantics, and final v2 mainline promotion require explicit file/branch ownership plus ordered forward-only reconciliation. Do not fork incompatible `pkg` APIs or treat an offline green matrix as a whole-real-system PASS.
- **The blocking contract lane, in parallel with evidence work:** source-composition owner compares the already fixed `context` user intent with the currently promoted `BOOTSTRAP-ENVIRONMENT`/package/state/library contracts, resolves the minimal missing public default/preset/provider/environment/child-inheritance and ordinary-library consumer semantics, and promotes only accepted decisions. No new API or executable full-context implementation until this gate passes.
- **Final integration only after prerequisites:** coordinate v1/v2 runtime/catalog/manual/test consistency and forward-only mainline promotion; replay *required* actual public M01–M15 paths on exact integrated HEADs and then the proportionate reference-host progression (Ubuntu ARM64, Ubuntu x86_64, macOS ARM64 per `PHYSICAL-TESTING.md`). Required absent host/privilege evidence stays PENDING, not a fabricated PASS. Separate package APISIX/Keycloak feature completion and later legacy `rumiai-os`/frozen `rumiai-tests` migration cannot silently enlarge this gate.

**Blocking high-impact conditions for a single ready full-`m-os` implementation plan:** (i) promoted full-`context` public interface/normal paths, precedence, environment/protected propagation and consumer library selection; (ii) canonical `pkg install` contradiction and coherent provider/package consumer boundary; (iii) agreed revision-coupled final validation target and available controlled access for privileged/physical paths. Conditions (ii) and (iii) have existing owner/validation procedures and do not justify new broad architecture choices. Neither package-store hardening, `rumiai-validate` extension, schema-v2 expansion, nor extraction of all legacy tools is a blocker.

**Next action:** Source-composition handoff closes and promotes the smallest concrete full-`context` semantic differences; pkg-dependency owner reconciles the already-selected install semantics and their canonical prose; the independent existing owners continue actual M01–M15 and real v2 evidence and classify `json`. Then rerun the complete `devplan` sufficiency gate and issue fresh-chat-executable task units with named file ownership, exact public tests, integration commits and acceptance. No product/CI/permanent-test changes or test execution occurred in this planning-only review.

Repository identity update (2026-11-03): the independent source formerly
at `massimilianonardi-ai/m` is now `massimilianonardi-ai/m-os`,
with `master@ff55fc9f220f8da3f1f90d1bf4aa2e46c55a5d2a` preserved.
The `m` semantic layer/runtime is unchanged. Earlier revision-specific
`m@...` evidence below identifies the same repository before the rename;
it is not new validation of the renamed-source workflow checkouts.
Refresh `m-os` HEAD before continuing full autonomous validation.

Rename-only CI validation (2026-11-03): the updated `m-mk` and
`m-jsc` GitHub Actions successfully check out the renamed
`massimilianonardi-ai/m-os` repository on Ubuntu. Their published
install/release workflows `41656855078`/`41656855012` (mk) and
`41657220781`/`41657220779` (jsc) then fail during public
`pkg-depend`/install because exact `mk@v0.1.0`,
`jsc@v0.1.0` or `nodejs@v26.8.2` requests cannot be resolved
by current `m-os/master`. The checkout rename works, but package
resolution on current master is **not a PASS**; investigate in
the autonomous package/dependency validation workstream without treating
this rename-only commit as evidence of a new product change. The
associated macOS jobs were queued at this checkpoint.

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
