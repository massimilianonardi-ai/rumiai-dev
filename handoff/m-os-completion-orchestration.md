# Completion orchestration of autonomous m-os

Status: Active — planning and dependency coordination only
Updated: 2026-11-05

## Goal

Finish the **autonomous technical `m` distribution** as a usable, real, coherent product: a POSIX bootstrap with a real `pkg` installation/provider/service path, its required built-in commands and manuals, independent usable first-party packages, a properly composed shell/runtime context, v1/v2 catalog continuity, and revision-specific validation of the whole accepted scope. Maximize **safe** parallel work without duplicating code or promoting unaccepted interfaces.

This handoff exists solely for cross-workstream orchestration and completion acceptance. It does **not** take implementation ownership away from:
- `handoff/m-autonomous-validation.md` (complete public technical M01–M15 validation/evidence);
- `handoff/rumiai-os-source-composition.md` (core scope, export/real-package integration, full `context` design);
- `handoff/pkg-definition-model-review.md` (v2 catalog/runtime semantics and promotion);
- `handoff/pkg-dependency-resolution.md` (dependency-first installation and extractor reconciliation).

No duplicate normative specification or separate product architecture is established here. All paths/revisions below are **checkpoints to refresh**, not instructions to pin indefinitely.

## Current repository revisions

Verified remote starting point:
- `m-os/master@31693e814f682690adfd48185da822f7f5007f9e`; `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`.
- `pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609`; `pkg-catalog/pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7`.
- `m-core/main@0afb8752440808e9080a55c667576ff2f9b8eb32`, `m-term/main@c32aac18f6659ed4f569cb780080675fa64f9e3a`, `m-rsudo/main@2763019ada5b1e33151f0c1e58b75af22ed6e99c`.
- `m-mk/main@8c857460213199eeb4c5c070b4df60c885df376f`, `m-jsc/main@ca1b70d1e0c53e790244f28b67bcf2a2b7528c76`.
- Legacy `rumiai-os/main@8ae78944ef5e8d6297c50898d856db1a20c6fd9a` and permanent `rumiai-tests/main@fa4b6e96a9d777068f8940d0f5239d670f3d833e` are **frozen** for modification/execution unless the user explicitly lifts the freeze. Reading legacy source is permitted.

## Applicable canonical sources

`README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `DEVPLAN.md`, `TESTING.md`, `PHYSICAL-TESTING.md`, `handoff/README.md`, and `specifications/README.md`, routing as applicable to `rumiai-os/{CURRENT-MODEL,BOOTSTRAP-ENVIRONMENT,PACKAGE-MODEL,STATE-MODEL,LIBRARY-INTERFACES,FILESYSTEM-NAMING,COMMAND-ENTRYPOINTS,DOCUMENTATION-MODEL,DIAGNOSTICS,RESOURCE-MODEL,POSIX-PORTABILITY-LAYER,SERVICE-LIFECYCLE,TLS-TRUST,JSON-QUERY,RSUDO,SSH,MENU}.md`. Other command-specific specifications are mandatory when the corresponding implementation scope becomes active. Consult the owning handoffs above for task-local fixed choices.

User-intent evidence was previously reviewed from `chats/m-os/` archives, notably `2026-10-26 Verifica Ubuntu m`, `2026-10-29 m context 2`, `2026-11-03 m-context 3`, `2026-11-03 m-context 4`, `2026-11-04 m-context 5`, the JSON chat and the migration synthesis. These are **non-authoritative** archival evidence; `2026-10-26 m context/index.html` was empty. Do not consult Git history by default.

## Sufficiency gate / limits

**Verdict for the complete general-context + m-os program: Specifiche insufficienti.** The current `m-os` public baseline and many M01–M15 tasks have sufficient settled contracts for bounded unit-level planning. This is a **detailed conditional execution sequence**, not a claim that every future unit is ready to code or that its full-context public grammar is already approved.

**Already settled:** core/optional-package responsibility principle; POSIX bootstrap independent of Node/`mk`; real public `pkg install` and genuine artifacts; actual `srv` positive paths; v2 `link/bin` as uniform entrypoint and `link/lib/{sh,java}` library views; existing `v1` retained; no v2 resource exports (deferred); package-store existing protection retained; `rumiai-validate` target unchanged; forward-only migration; no synthetic substitute for a claimed real end-to-end result.

**Material contract gates:**
- **G-CONTEXT:** `BOOTSTRAP-ENVIRONMENT.md` currently specifies only shell-local exact `pkg=` and no-argument **reset**. User-approved direction for a future full context instead calls for no-argument default initialization, ordered selections/presets, coherent provider/facility/owner/state/environment dimensions and protected child propagation. Exact public grammar, defaults, trusted metadata, library consumer binding and environment replacement are not promoted. Do not implement an invented API.
- **G-PKG:** `PACKAGE-MODEL.md` Installation prose permits best-effort invalid operands but PKG-99 demands upfront full request validation; the dependency handoff records the selected upfront rule. Reconcile canonical prose + runtime + manuals before a claim of complete `pkg`/v2 semantics. Additionally, transparent ordinary-library consumer dependencies cannot be silently recast as facility dependencies.
- **G-HOST:** authorization and controlled infrastructure for privileged SSH/sudo, host-system service supervision and reference-host physical evidence are not implied by generic project authorization. Unrun required work remains PENDING, not PASS.

**Scope excluded from `m-os` core completion:** finishing all separate APISIX/Keycloak administration features; migrating or editing frozen legacy product/suite; v3 resource descriptors; hardening package-store permissions; changing formal `rumiai-validate` target; adding all optional legacy commands indiscriminately. These remain their existing owners' tasks, and do not block core acceptance solely by being incomplete.

## Acceptance scenarios and completion definition

1. On a clean supported POSIX environment with no managed Node/`mk`/catalog already installed, `./m` bootstrap, technical commands, state/manual/localization, and appropriate offline error paths work; only operations needing a package require a catalog/network.
2. A normal operator uses real `./m pkg install ...` with genuine catalog/release artifacts; versions/default, dependencies, provider selection/bindings, environment, uninstall/reinstall and rollback behave per the **reconciled canonical** contract, without substitutes.
3. The public `srv` starts a genuinely installed provider, verifies a responsive service and stops it; failure and restart paths cannot act on unrelated services. Host supervision is validated only in controlled applicable environments.
4. A shell/user selects concrete package commands and ordinary sh/Java library views through existing `context`, with demonstrated real consumers and fail-before-activation error behavior. **Later full-context** scenarios must first have a promoted grammar/selection/inheritance contract.
5. `m-core`, `m-term`, `m-rsudo`, `m-mk` and `m-jsc` integrate as their real published packages rather than copied global libraries; real menu operator PASS remains distinct from actual remote rsudo validation.
6. Every **current autonomous** technical command, adapter and manual is inventoried; uncovered specified `json` and any other actual gaps are resolved or explicitly scoped as separate packages before asserting the core is complete.
7. The v1/v2 runtime/catalog are consistent and promoted forward-only when permitted; the final exact integrated revision has a M01–M15 evidence matrix by host. No reclassification of auxiliary CI or operator reports into formal physical PASS.

## Parallel execution graph

```text
P0 authoritative source/target inventory
 ├─ A1 bootstrap/state ─ A2 manual/shell ─ A3 network/extract ─ A4 TLS/NSS
 ├─ J1 standalone json completeness (source-composition owner)
 ├─ S1 portable srv ─ S2 host-supervisor controlled validation
 ├─ R1 core/term/rsudo independent-package boundaries ─ R2 authorized SSH/sudo
 ├─ P1 pkg install canonical mismatch ─ P2 dependency/install/extract implementation
 │                                     ├─ P3 provider/version/default/uninstall reality
 │                                     └─ P4 installed facility derived-map integration
 ├─ V1 v1/v2 real adapter/library/Java coverage (independent catalog-side checks)
 │      └─ V2 runtime/catalog coordinated promotion (after P2 + P3/P4 as affected)
 └─ C1 accepted exact-package context tests (current contract)
        └─ C2 full-context contract gate ─ C3 full-context implementation (after P4)
A*, J1, S*, R*, and non-conflicting V1 / C1 evidence can run concurrently.
P1/P2/P3/P4, V2 and C3 that edit common m-os pkg/context files are serial or
coordinated by a single writer. Final I1 integration checks -> I2 physical evidence.
```

A work unit is *functionally independent* only if it does not consume an unsettled upstream interface; it is *operationally independent* only if it does not write the same files, mutable catalog branch, package releases, host service or provider state. Shared `m-os` tree writes require one branch/file integration owner; distinct files alone are not permission to change shared public semantics in parallel.

## Detailed units: settled/current-contract work

### P0 — Scope and evidence inventory (READY, planning/inspection only)

- **Deliverable:** source-backed manifest of each current `m-os/bin/sys` command, `res/sys/manual` topic, exported library, repository adapter, catalog-backed real scenario and M01–M15 status by revision/host, noting true missing-source vs missing-test vs optional extracted package. Confirm the 16 current command identities in `m-os/pkg-schema-v2/bin/sys` and independently specified `json` mismatch, without treating the old tree as the target.
- **Inputs/baseline:** above HEADs; `CURRENT-MODEL`, `COMMAND-ENTRYPOINTS`, `DOCUMENTATION-MODEL`, `TESTING`; files under `m-os/bin/sys`, `res/sys/manual`, `lib/sys/sh/pkg/repository`, `.github/workflows`; owning M01–M15 handoff.
- **Boundaries:** planning/documentation only; no test/CI/product changes. Existing validation owner maintains evidence, source-composition owner maintains scope. P0 coordinates references without duplicating per-unit operational state.
- **Done:** every public command has a source/manual/accepted-scope row; real adapter availability, frozen legacy source-only gaps and outdated evidence are classified. A newly discovered contract conflict is routed to its owner, not silently fixed. **Feeds:** A*, J1, S*, P*, V1, I1.

### A1 — Clean bootstrap/platform/state (M01–M03; READY after P0)

- **Target:** `m-os/master` and then relevant feature revision; `m`, `bin/sys/osarch`, `bin/sys/state-path`, `lib/sys/sh/{core,base,osarch}.lib.sh` and associated manuals. Contracts: `BOOTSTRAP-ENVIRONMENT`, `STATE-MODEL`, `CURRENT-MODEL`, portability/entrypoint/diagnostics rules.
- **Deliverable/acceptance:** isolated clean clone with host Node/`mk` absent from prerequisites: direct bootstrap, relative/symlink invocation, OS/architecture selection, system/user/package/State Instance paths, no unauthorized filesystem materialization, missing-selector and malformed-state diagnostics. Compare Ubuntu/macOS applicability rather than inventing one universal host result.
- **Validation:** real public-command invocations plus branch-specific negative cases; each PASS names exact HEAD/host/command/log. Recheck manuals and appropriate existing CI `m-core-checkout.yml`, `m-technical-commands.yml`; maintain test ownership/frozen suite. Internal algorithm choices may be delegated; new state identity or platform contract escalates.
- **Parallel/conflict:** independent of package schema and S*/R*; coordinate edits to `m` and global `core` only with A2/C3.

### A2 — Shell, localization, manuals, diagnostics and command coverage (M04–M05/M15; READY after P0)

- **Target:** `m-os/bin/sys/{shell,lang,lang-set,manual,pager,log}`, `res/sys/{manual,lang}`, relevant shell libraries. Read `LANG-BOOTSTRAP`, `PAGER`, `LIBRARY-INTERFACES`, `DOCUMENTATION-MODEL`, `DIAGNOSTICS` before any code work.
- **Acceptance:** managed-shell POSIX behavior; library sourcing only by supported identity; locale fallback and invalid language; exact manual topic discovery/paging and missing-topic handling; diagnostic severity/status meaning, no secret leakage; all published functions/commands have matching manuals.
- **Validation:** real subprocess/shell tests with terminal/host-specific paths where applicable, not only greps of source; M15 inventory records separate negative status and manual checks. A2 owns any changes to shared `shell`/`core` until integrated; C1 does not concurrently edit them. Escalate any proposed public API change.

### A3 — Transfer/integrity/extract (M06; READY with restricted path ownership)

- **Target:** `m-os/bin/sys/{http-fetch,digest,extract}`, their manuals; `m-os/lib/sys/sh/pkg/{pkg-download,pkg-extract}.lib.sh` is **owned by P2** and not concurrently editable by A3. Read current `PACKAGE-MODEL`, `DIAGNOSTICS` and public command contracts.
- **Acceptance:** genuine HTTPS and loopback transfers, byte/size/digest checks, stdin/file hashing, supported archive extraction with path-traversal/format/corruption failures, no partial output accepted as integrity success; macOS flat/dmg-pkg cases where applicable.
- **Evidence:** real artifact bytes and independently checked outcomes; existing `m-technical-commands.yml` is starting evidence only. P2 alone changes dependency-package extraction plumbing; A3 may report an upstream defect for P2 to own. No catalog mock claimed as real install.

### A4 — Managed CA/NSS/browser (M14; READY in disposable host environments)

- **Target:** `m-os/bin/sys/{tls-ca,tls-nss-sync}`, relevant manuals, `TLS-TRUST`, host adapter specs. Source is `m-os` current HEAD, not historical legacy HEAD.
- **Acceptance:** test-only CA approval/list/removal, unrelated host/profile trust preserved, NSS projection and idempotence, tamper fail-closed, actual browser rejection -> trusted HTTPS -> revocation/rejection when supported. Do not change host system trust or unrelated user profiles.
- **Evidence:** isolated real browser+HTTPS execution or marked unavailable host capability; earlier operator Chrome/Chromium PASS is revision-pinned older evidence, not automatic PASS for current revision. A4 does not share mutable CA state with other agents.

### J1 — Standalone POSIX json completeness (READY for source/contract inventory; implementation requires normal authorization)

- **Target:** `m-os/bin/sys/json` (absent), `m-os/res/sys/manual/json` (absent), and existing distinct `m-os/lib/sys/sh/json.lib.sh`. Existing source/manual for the command are readable in frozen legacy `rumiai-os`; `JSON-QUERY`, `COMMAND-ENTRYPOINTS` and documentation/portability contracts are normative.
- **Outcome:** decide scope against the already current technical `m` command contract; when authorized, import/adapt only the actual standalone command and operational manual into `m-os` with a real parser/filter normal path plus malformed UTF-8/JSON, optional/filter/stream/exit-status checks. Do not create a second JSON engine or require Node/`jq`.
- **Proof:** self-contained real POSIX command testing, including `json --check`, read-only jq-subset extraction and negative cases; named M15 row, manual current. Source-composition owns J1; A2 coordinates manual-discovery impact. Frozen legacy remains untouched.

### S1 — Positive and negative portable service lifecycle (M12; READY after P0, current v1 accepted path)

- **Target:** `m-os/bin/sys/srv`, `m-os/lib/sys/sh/pkg/facility/*` service-boundary only under exclusive ownership; `SERVICE-LIFECYCLE` and applicable `PACKAGE-MODEL`. Public installed `electron-web-control`-like real catalog service evidence exists on an earlier exact revision.
- **Acceptance:** install genuine provider through `./m pkg install`, select system service facility default, `srv start` and observe actual responsive process, stop/idempotent stop; restart/stale PID, mismatched provider/ownership, failure and no takeover of unrelated PID or port.
- **Proof:** disposable full-`m` state + public commands; `.github/workflows/m-srv-provider-live.yml` as prior evidence. If v2 `link/bin` changes service launch, defer the shared `pkg` implementation to V2 integrator rather than edit conflicting paths. Linux/macOS separate.

### S2 — Host supervision (M13; G-HOST gated for privileged branches)

- **Target:** `srv host user/system`, current `SERVICE-LIFECYCLE`, platform service adapters and manuals; isolated supervised real process with declared expected lifecycle.
- **Acceptance:** on supported Linux systemd/macOS launchd with operator-authorized host capability: register/start/restart/stop/remove and verify exact service identity, persisted state and cleanup. System-scope operations need explicit permitted account/admin context, no changes to unrelated production services. An absent capability produces documented PENDING/SKIP applicability, **not** acceptance PASS.
- **Dependency:** S1 establishes portable process behavior; branch-specific host proof remains gated by access.

### R1 — Independent first-party real package integration (READY for nonprivileged paths)

- **Target/ownership:** source-composition handoff; `m-core`, `m-term`, `m-rsudo` separate repositories and current published `v0.1.0` unchanged. Source: `m-rsudo/bin/sys/{rssh,rsudo-admin}`, `m-core/lib/sys/sh/loadlib-inject-stream.lib.sh`, `m-term` menu assets, manuals; v2 `pkg-catalog/v2/pkg/{m-core,m-term,m-rsudo}`.
- **Acceptance:** real GitHub releases installed via public `pkg install`, correct selected `link/bin` and `link/lib/sh` views, real shell-library consumers, no fallback to legacy `$m_LIB_DIR/sys/sh` for extracted package modules; validate `rssh` extension and `rsudo-admin` injected source/menu path design against the actual source-stream contract.
- **Evidence:** existing `m-core/.github/workflows/integration.yml` Ubuntu/macOS PASS is baseline for local nonremote paths; menu interactive vmdev PASS is operator report; new tests must target changed real normal paths, not replay already-PASS checks without change. R1 may change its own independently owned package sources only when authorized, with matching manuals/new immutable releases after real proof; `m-os` shared loader changes require C1/P2 integrator consent.

### R2 — Actual rsudo SSH/sudo/remote menu (G-HOST gated)

- **Target:** exported `m-rsudo` version resulting from R1, controlled explicitly authorized SSH/sudo host or suitable dedicated isolated real SSH/sudo testlab; `RSUDO`, `SSH`, `MENU` and package manuals.
- **Acceptance/evidence:** authenticate as declared principal with strict host-key verification, validate real `rsudo --connect` privileged exit/UID, stdin/TTY separation, error and cancellation paths, `rssh`, `rsudo-admin` browse and remote source injection. Record target identity, host authority scope, local/remote revision, redacted transcript and cleanup. Without authorization result is PENDING, not an implementation FAIL.

### C1 — Current exact-package shell context (READY; no new grammar)

- **Target:** `m-os/lib/sys/sh/context.lib.sh`, `res/sys/manual/context.lib.sh`, `m-os/.github/scripts/context-libraries-test.sh` and real install pipeline; `BOOTSTRAP-ENVIRONMENT` currently defines exact `pkg=` and no-arg reset. Feature v2 `link/bin` is not yet the published mainline `cmd` wording; preserve that distinction until promotion.
- **Acceptance:** genuine `m-core` / `m-term` / `m-rsudo` separate installed package views; sh source via `PATH` with existing `loadsyslib` used correctly, Java JAR `CLASSPATH` where a real package exports it; replacement order, collisions, shell-local state, reset, failed-selection no-mutation, user PATH preservation and child-shell function reinitialization. No synthetic package masquerading as end-to-end proof.
- **Evidence:** real cross-package consumer output on Ubuntu/macOS and vmdev if applicable, pinned source/catalog/release identities, separate tests for error branches. C1 is **not** approval for default presets/providers/protected inheritance. Only C1 writer edits the current context library until G-CONTEXT is promoted.

### P1 — Canonical pkg install contradiction (READY for authority reconciliation)

- **Owner:** `handoff/pkg-dependency-resolution.md`. Current `PACKAGE-MODEL` Installation best-effort sentence contradicts PKG-99. Already-fixed task-local direction: validate entire request list up front, one catalog snapshot, exact roots and dependency-first sequence. Compare current `m-os/lib/sys/sh/pkg/{pkg-install,pkg-depend,pkg-common}.lib.sh`, relevant manuals and actual public tests.
- **Deliverable:** one consistent authoritative spec, command/manual behavior, regression expectations; do not silently let a convenience algorithm decide observable semantics.
- **Done:** public invalid-first/valid-second and valid-first/invalid-second batch semantics have a deterministically specified result; failure-before-mutation evidence matches the promoted rule. Internal helper naming/private cross-library calls do not become new public APIs. P1 gates P2/V2.

### P2 — Install/dependency/extract correctness (READY after P1, single pkg writer)

- **Owner/target:** same dependency handoff, `m-os/lib/sys/sh/pkg/{pkg-install,pkg-depend,pkg-extract,pkg-local,pkg-integration}.lib.sh`, `bin/sys/{pkg,extract}` only with A3 ownership coordination; operational manuals. No edits to frozen suite.
- **Acceptance:** real multi-request validation, exact root resolution from one snapshot, `pkg depend` recursive dependency-first behavior, same root identity used at execution, strict installed concrete validation, uninstallation/reinstallation, extractor promoted names and cleanup, rollback on corrupt artifact, provider ambiguity error preserved. Real GeoServer/dependency case when available must be genuine or reported untested.
- **Proof:** public `./m pkg install`, `./m pkg depend`, `pkg requirement`, `pkg uninstall` with real catalog/artifacts and isolated `m`, plus proportional offline negative tests where real external failure cannot be controlled. No `extract2`/old-manual identities. Share a precise interface checkpoint with P3/P4/V1 before they integrate.

### P3 — Version/default/negative provider and uninstall matrix (READY for isolated real evidence; shared pkg changes after P2)

- **Owner:** validation handoff M07–M11 with `pkg` integrator for any product fix. Target `m-os/lib/sys/sh/pkg/{pkg-versions,pkg-default,pkg-provider,pkg-requirement,pkg-uninstall,pkg-launch}.lib.sh`; `pkg-catalog` real providers; `PACKAGE-MODEL` current paths and manual `pkg`.
- **Acceptance:** current vs exact concrete, incompatible/no/ambiguous provider, two providers and multiple versions, explicit consumer binding vs system default, typed cmd/env realization and collision rejection, referenced-provider removal protection, state untouched after failed uninstall, clean reinstall, runtime exact environment/command coherence.
- **Proof:** revise the M07–M11 matrix using real public commands and genuine releases, not just Node/`mk` happy paths. Existing `.github/workflows/m-pkg-provider-lifecycle.yml` is starting evidence, not a new whole-m PASS. Data-only catalog coverage may run during P2; `pkg` code edits must serialize after P2.

### P4 — Derived installed facility map (G-PKG integration; contract settled, source edit serialized)

- **Owner:** source-composition handoff for accepted `PACKAGE-MODEL` facility-map behavior, single shared `pkg` integrator for implementation. Target `m-os/lib/sys/sh/pkg/pkg-provider.lib.sh` and installation/uninstall/default hooks only after P2 interface checkpoint.
- **Acceptance:** `facility/<facility>/<compatibility>/<osarch>/` enumerates all installed validated provider concretes; provider-local compatible `@latest` obeys real version ordering even when the newest package release dropped compatibility; optional default selects exact concrete or that provider's `@latest`, never a cross-provider greatest version. Removing one unreferenced provider updates only its derived membership. The map is derived, not competing authority.
- **Proof:** public install/default/uninstall and concrete-view inspections against genuinely validated provider artifacts; ambiguous/missing/unorderable cases reject. Coordinate P3 and full-context C3; no generic `pkg@latest` alias policy invented.

### V1 — v2 real adapter/artifact/library/Java validation (READY independently of C3)

- **Owner:** `handoff/pkg-definition-model-review.md`, catalog `pkg-catalog/pkg-schema-v2`, `m-os/pkg-schema-v2` adapter sources and manuals. Current feature workflows include `validate-v2-*.yml`, `m-pkg-java-v1-live.yml`, `m-context-shell.yml` and `.github/scripts/pkg-v2-*.sh`.
- **Acceptance:** v1 definitions remain usable unchanged under `v1`; v1/v2 exact identity and coexistence, real Node.js/jq/mk/jsc/ollama, direct and wrapper `link/bin`, shell `link/lib/sh`, Java `link/lib/java` with real Maven/Temurin adapters and a genuine Java consumer, service entrypoint and rollback cases. Preserve intended package HOME/env/state and package-specific wrappers. Inherited resources stay deferred to v3.
- **Proof:** recorded exact Ubuntu/macOS run IDs, real releases and verified payloads, negatives with authentic product paths; transient upstream GitHub 403 classified as acquisition failure, no guessed core regression. A workflow with correct YAML but no executed Java job is NOT PASS. Catalog-only changes can run concurrently with A*/S*/R*; shared `m-os/lib/sys/sh/pkg` changes require P2/P3/P4 integrator.

## Detailed units: gated/future contracts and integration

### C2 — Promote full-context public contract (G-CONTEXT; READY FOR DESIGN, NOT IMPLEMENTATION)

- **Owner:** `handoff/rumiai-os-source-composition.md`; inspect current `BOOTSTRAP-ENVIRONMENT`, `PACKAGE-MODEL`, `STATE-MODEL`, `LIBRARY-INTERFACES`, `CURRENT-MODEL` and `m-os/lib/sys/sh/context.lib.sh`.
- **Deliverable:** one noncontradictory, formally promoted public contract for: no-arg managed-shell startup/default vs old reset; one active context replaced until exit; strict left-to-right selection fold with inline named presets; existing package/facility/user/profile dimensions; system/default vs consumer-bound provider selection; exact concrete cmd+env+lib coherence; protected inherited variable ownership/trust, shell/child/nested execution and failure atomicity; no per-call symlink generation. Define what remains intentionally unsupported, rather than inventing Python/Node loader variables or a universal resource API.
- **Gate/acceptance:** specify at least: fresh managed shell, default initialization, overridden provider while another consumer remains pinned, nested child with protected HOME and browser NSS, ambiguous provider failure without environment change, and second `context` replacing the first. Resolve public syntax, profile selection authority, trusted inheritance and ordinary-library dependencies through current specification promotion. A code agent must not guess these from old chat examples. If a fundamental ambiguity survives repo review, explicitly escalate *that choice* to the user.

### C3 — Implement generalized context (BLOCKED until C2 + P4)

- **Future outcome only:** existing `context` shell surface and relevant `pkg` launcher/provider/state/managed-shell consumers implement the **promoted** default/preset/provider/propagation semantics without a second registry or per-call command-view publication. Preserve exact concrete commands plus libraries and atomic failure; support real nested consumers and respective manuals.
- **Readiness:** only after C2 fixes grammar/trust and P4 has stable facility map + P2/V2 package layout. Then split into coherent ready units according to settled interfaces; do **not** preassign speculative functions or overlapping files.
- **Acceptance outline:** operator normal no-argument shell, explicit ordered overrides, real provider-sensitive package, shared sh/Java consumer, nested context and negative/permission scenarios on required platforms. No present success claim.

### V2 — Coordinated v2 promotion (BLOCKED until P1/P2 + applicable P3/P4 + V1)

- **Owner:** pkg-definition handoff and single `m-os` integration writer. Forward reconcile `m-os/pkg-schema-v2` into `m-os/master` and `pkg-catalog/pkg-schema-v2` into `pkg-catalog/main` without rewriting either history; preserve concurrent v1 catalog edits.
- **Deliverables:** canonical `PACKAGE-MODEL` and bootstrap context wording match *actually promoted* `link/bin` / `link/lib` behavior; command/library manuals and current CI use matching revisions; no manual v1 installations silently invalidated. Check deployment from a clean clone and a real v1 installed-state migration/coexistence path. Publish additional package versions only when actually needed and validated.
- **Evidence:** full post-merge diff review; real adapter/consumer/test smoke both hosted platforms; no promotion based on old green commits alone. A change in shared `pkg` contracts must return to P1/P2/P4 for reconciliation before merging.

### I1 — Combined current technical acceptance and release coherence (BLOCKED until relevant implementation gates)

- **Owner:** orchestration coordinates; validation handoff owns the actual M01–M15 evidence ledger and tests; source-composition/v2 owners retain their own fixes. Build an exact revision set of `m-os`, `pkg-catalog` and required independently released source packages.
- **Acceptance:** every actually in-scope technical command/manual/adapter/consumer has proportional real normal+negative paths, platform applicability and an explicit PASS/FAIL/PENDING entry. No outstanding reproducible critical bug, semantic conflict or missing required package. Repeat tests selectively when revisions affect their claims; never call a CI smoke the full suite.
- **Stop rule:** unavailable frozen permanent-suite changes are identified as pending external authorization, not bypassed. No full completion claim until applicable evidence requirements are satisfied.

### I2 — Reference-host physical validation and closure (G-HOST, after I1)

- **Owner:** validation handoff. Execute exact current product/release revisions using the operator's designated Ubuntu 26.04 ARM64 VM, Ubuntu 24.04/26.04 x86_64 VM and macOS 27 ARM64 as applicable, in that order under `PHYSICAL-TESTING.md`.
- **Acceptance:** minimal actual public-command path proves bootstrap, package install/provider/service/context, relevant platform-specific host behavior; real interactions use authorized targets, isolated mutable state and cleanup. Record exact host/revisions/command/status/logs. User-reported TTY menu PASS stays operator evidence until an applicable formal record exists. Host/system administrative scenarios cannot be executed on inferred privileges.
- **Closure:** independent owners close their handoffs only upon their own validation; durable promoted contracts remain in canonical specifications. Orchestration closes only when the target **as bounded by current accepted contracts** is complete and pending external-host/authority work is honestly classified.

## Parallel dispatch order and conflict policy

**Wave 0, immediate and planning-only authorization:** P0, P1's authoritative conflict review, C2's contract comparison, J1's source/manual inventory, V1's missing-run inventory and R1's package-path analysis can begin together. None needs a new public interface or privileged host.

**Wave 1, after explicit product/CI authorization where applicable:** A1/A2/A3/A4, S1, J1 implementation (only after J1 boundary check), R1 nonprivileged remediation, V1 real published-artifact tests and C1 real package-context checks can proceed concurrently **only with disjoint files/state**. If A1 and A2 both need `core`, one integrator serializes their changes. P2 owns all `pkg` install/extract files; do not race P3/P4/V1 changes there.

**Wave 2, serial shared-pkg integration:** P1 -> P2 -> P3/P4 interface reconciliations -> V2, with P3 and P4 test-data analysis performed in advance. Rebase/re-read forward whenever a shared HEAD advances; preserve other actor commits. C3 waits for C2 plus P4 and accepted v2 runtime views.

**Wave 3, final:** I1 revision-specific integrated evidence -> I2 controlled physical validation -> close task only if the required M01–M15 and full-context acceptance actually pass. R2 and privileged S2 run in isolated authorized environments; their availability can be scheduled independently of other source edits but cannot be fabricated.

**Executor protocol:** each independent chat receives (i) local unit ID from this handoff, (ii) owner handoff, (iii) source/branch checkpoint to freshly verify, (iv) exact writable files/branch and prohibited shared surfaces, (v) public expected tests + manual updates, (vi) expected upstream output and integration handoff. Every executor follows fresh HEAD preflight, no history by default, current source authority, proportional real tests, reviewed diff, forward-only updates and consistency gate. When an interface or host/privilege contract is unsettled, stop only that affected unit and escalate; do not freeze independent ready work.

## Current state

### P0 — Current-source inventory checkpoint (2026-11-05)

**Inspection complete for scope routing, not a runtime-validation PASS.** Read the actual `m-os/master@31693e814f682690adfd48185da822f7f5007f9e` tree, matching manuals and workflows, `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`, and `pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609` / `pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7`. The source/manual inventory below is the *mainline target*, not proof of execution:

| Public command | Current source | Current manual | Workstream |
|---|---|---|---|
| `m` | root `m` via `bin/sys/m` symlink | `res/sys/manual/m` | A1 |
| `osarch` | `bin/sys/osarch` | `res/sys/manual/osarch` | A1 |
| `state-path` | `bin/sys/state-path` | `res/sys/manual/state-path` | A1 |
| `shell` | `bin/sys/shell` | `res/sys/manual/shell` | A2 |
| `lang` | `bin/sys/lang` | `res/sys/manual/lang` | A2 |
| `lang-set` | `bin/sys/lang-set` | `res/sys/manual/lang-set` | A2 |
| `manual` | `bin/sys/manual` | `res/sys/manual/manual` | A2 |
| `pager` | `bin/sys/pager` | `res/sys/manual/pager` | A2 |
| `log` | `bin/sys/log` | `res/sys/manual/log` | A2 |
| `http-fetch` | `bin/sys/http-fetch` | `res/sys/manual/http-fetch` | A3 |
| `digest` | `bin/sys/digest` | `res/sys/manual/digest` | A3 |
| `extract` | `bin/sys/extract` | `res/sys/manual/extract` | A3 |
| `tls-ca` | `bin/sys/tls-ca` | `res/sys/manual/tls-ca` | A4 |
| `tls-nss-sync` | `bin/sys/tls-nss-sync` | `res/sys/manual/tls-nss-sync` | A4 |
| `srv` | `bin/sys/srv` | `res/sys/manual/srv` | S1/S2 |
| `pkg` | `bin/sys/pkg` | `res/sys/manual/pkg` | P1–P4/V1/V2 |

The 16 mainline command identities all have corresponding manual files; `lib/sys/sh` exported library manual leaf identities are present in the same source tree, but a semantic public-API/manual audit remains M15 PENDING. The independent `JSON-QUERY.md` contract for a standalone `bin/sys/json` and manual remains **unimplemented in both current m-os branches**; this is J1/source-composition ownership, not an A2 synonym for the existing `json.lib.sh`.

Current mainline repository adapter sources: `pkg-repository-{artifact,chrome,chromium,github,nodejs}.lib.sh`. The v2 feature additionally contains `pkg-repository-{apache-maven,temurin}.lib.sh`. Catalog mainline currently has v1 package definitions including real `nodejs`, `mk`, `jsc`, `electron-web-control`, `ollama`; the v2 feature catalogs `jq`, `jsc`, `m-core`, `m-rsudo`, `m-term`, `mk`, `nodejs`, `ollama`. Catalog entries are not equivalent to a working installed-provider scenario. The *only* accepted M01–M15 run-by-host/revision classifications remain in `handoff/m-autonomous-validation.md`; historical CI jobs and physical evidence there are not transferred to the new `m-os` revision.

**A1 dispatched as an authorized source-CI change:** `m-os/master@e0bcf2d69ba4e4209a93fd7d0c9b08a00def3a0f` added `.github/workflows/m-bootstrap-state-public.yml` for real public positive/negative bootstrap, symlink/PATH, state and osarch checks on hosted Ubuntu/macOS. This is test *authoring*, not a reported PASS; no executed job has been verified. A2/A3/A4 remain independently ready, their source files unchanged. The owning validation handoff records the A1 operational next action.


- The conditional program remains governed by its existing gates. P0's mainline source/manual/adapters inventory is complete; A1 now has a committed product-owned CI smoke (unverified execution). No product runtime/catalog/package release or frozen permanent-suite change was made; no A1 PASS is claimed.
- Already observed: genuine three-package published composed smoke Ubuntu/macOS PASS at `m-core` Actions run `42037725004` on pinned older revisions, and operator-reported `vmdev` interactive menu PASS; these are not full current product or authorized remote physical proof.
- The previously supplied strategic map lacked complete task outcomes, dependency/write ownership, acceptance and integration gates. This document adds the bounded task details without falsely turning unsettled full-context design into an implementation API.

## Next action

1. Use P0 to confirm exact accepted scope/evidence and communicate unit ownership; concurrently have C2 resolve full-context interface gaps and P1 reconcile `pkg install` mismatch under their existing owners.
2. Start independent nonconflicting public validation and authentic package integration checks once each executor has current repo preflight and applicable product/CI authorization. Prioritize usable real `m-os`, not fine-grained refactoring without consumer value.
3. Once C2/P1/P2/V1 outcomes stabilize, rerun the complete `DEVPLAN.md` sufficiency and clean-chat resumption gates for C3/V2, and publish fully executable units only for those now-ready interfaces.

## Blockers / open questions

- Full generalized `context` public grammar/default/preset/profile and protected inheritance/consumer library selection is not promoted; `BOOTSTRAP-ENVIRONMENT` no-arg reset must not be silently replaced.
- Canonical installation contradiction and downstream shared `pkg` integration ownership require P1 resolution.
- Privileged SSH/sudo, host service management and final reference-host runs need controlled authorized environments; required tests not run remain PENDING.
- Legacy `rumiai-os` and `rumiai-tests` are frozen; final formal suite alignment/migration cannot be silently assumed authorized.
