# Completion orchestration of autonomous m-os

Status: Active — C3/SRV-42 candidates and integrated P3/P4/J1 checks pass hosted run 42891477651; M01–M15/I1 and I2 remain open; A1–A4 hosted workflows and privileged host operations remain excluded
Updated: 2026-11-10

### Historical continuation checkpoint (2026-11-08; superseded by the 2026-11-10 checkpoint below)

- This continuation started from verified `rumiai-dev/main@327ee61bd4065b3832be5b1d7e6be9d275f90cc8`; subsequent checkpoints are pushed forward-only. Detailed GeoServer adapter state is in `handoff/geoserver-repository-adapter.md`, with cross-plan M10/M12 evidence in `handoff/m-autonomous-validation.md`.
- GeoServer adapter work is now published as draft [m-os PR #12](https://github.com/massimilianonardi-ai/m-os/pull/12), current head `b1e4f040506592f0433e26005741f887266f4462`, based on exact `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`. It is not merged and no hosted run exists. Local Ubuntu evidence includes genuine 3.0.1 and 3.0.2 installs; 3.0.1 returned HTTP 302 and 3.0.2 served WFS HTTP 200 after explicit provider defaults. The focused workflow is in the PR branch but GitHub does not list it until it reaches the default branch. Keep hosted/platform acceptance open.

### Current continuation checkpoint (2026-11-10)

- Fresh refs verified before this update: `rumiai-dev/main@a0fd46ff70ed75cc56d246159cb0ff110278e990`, `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`, `pkg-catalog/main@164b06441bef655eca2ac3f44ddee7e5b2c6cf3d`, and `pkg-catalog/codex/m-os-context-srv-ci@ac7b3226426374a7d0545e9efb688caf207b645c`.
- User decisions are settled: generalized `context` uses the approved dimensions and validated `--migrate-legacy`; account defaults use `$m_ROOT/state/<UID>`; no-argument `context` initializes defaults and `context --clear-defaults` clears them. SRV-42 uses a persistent per-service supervisor that owns the child.
- Candidate refs: C3 PR #24 `82b08864820ff97f427d442b65841b1c0e03370d` (A1 test correction only; hosted C3 code suites pinned `5f57a7de...`), SRV PR #25 `d509429b0e722c0998ac787de7d74c21456e905b`, P3 fixture PR #26 `e4eb909ecc9c38ea9b99ba5c794b6a1d1a0a0905`. Hosted compositions are `6296da51240f12e31c0e1ae327c88658a7ff8baf` and `ec0bddbfdf5b5127c33b0697c02356f7629d6f83`.
- Follow-up after that hosted checkpoint: PR #25 is now `c786bbef730c4efb2ff9423f3a43a52fa1688d6b` after CI-trigger updates; no run for that head is visible yet, so M13 current-source host-user revalidation remains open. `SERVICE-LIFECYCLE.md` SRV-11 now states the accepted private child-owning supervisor invariant in `rumiai-dev/codex/m-os-validation-20261110` commit `3dfbd23d`.
- Runner [42891477651](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42891477651) at `pkg-catalog@ac7b322...` completed **13/13 PASS**: C3/SRV exact public suites on Ubuntu/macOS, native supervisor lifecycle on both, integrated P3/P4 suites on both, JSONTestSuite on both, and Ubuntu authentic-provider ambiguity/typed-env plus genuine published-provider `srv` lifecycle. Exact job IDs and evidence limits are in `handoff/m-autonomous-validation.md`.
- Local exact A1 workflow body at PR #24 head passed on integrated tree `ec0bddbf`; A2 and A3 workflow bodies also passed locally on that disposable source. A4 CA/NSS/revocation passed on Ubuntu ARM64 using extracted-only verified `certutil`; this session had no Chrome/Chromium, so the browser step stayed pending. Earlier full browser PASS remains separate evidence.
- Remaining work: full current M01–M15/I1 ledger, host-user manager revalidation against the new supervisor, product distribution integration, residual adapter/platform/consumer gaps and nonprivileged I2. Do not dispatch hosted A1–A4, run privileged host operations, modify frozen repositories, or infer completion from the 13/13 matrix.
- GraalVM M10 offline-order work is available as stacked draft `m-os` PR #20 (`d4b4e387...`) with catalog history draft PR #4 (`50faddb3...`). The exact P4 regression now passes locally and the catalog sync workflow passed, but no hosted m-os run exists; track detailed evidence in `handoff/m-autonomous-validation.md` and `handoff/graalvm-repository-adapter.md`.

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
- `rumiai-dev/main@ea5d6259efb14b4527310a37b3cfe92980857619` is the verified remote preflight before this checkpoint; it includes the latest autonomous-validation evidence and preserves concurrent OUT-09/OUT-11 updates. Do not overwrite that work.
- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`; PR #9 updates only README after tested runtime `ed5ec60...`. P3 PR #5 merged as `6db5531...`; J1 PR #6 merged as `1df35f70...`; V2 runtime PR #8 merged as `ed5ec60...`.
- The then-current S branch `m-os/m-os-completion-s@15a2c4f96584c07b92088e5530d4ecb09a9477b8` contained a forward-only master merge and PR #4 was draft. Its `ps -o lstart` identity snapshot had one-second resolution and `stop` signaled after a separate check. These limitations belonged to the superseded PID-based design; the 2026-11-10 accepted persistent per-service supervisor candidate replaces that mechanism and has scoped hosted evidence recorded above.
- P3/P4/J1 exact-master hosted runners on `pkg-catalog` commit heads `d352513`, `2a63b75`, `7827963` completed successfully: P3 6/6 current-source + 3/3 supporting public checks, P4 2/2, J1 2/2. See validation handoff for run IDs and limits.
- A2 manual candidate `m-os/codex/a2-current-integration@84f436bffe1a79491609fcf3d1f93c2067174d60` (PR #10 Draft) contains the migration no-default restoration clarification and the two corrected JSON/shell manual semantics. PR #11 `m-os/codex/a4-browser-observation@4b688d87b46a0320448ca4c86485a116760cc1b3` remains Draft. Do not merge either while the operator-deferred A1–A4 hosted workflows would be triggered; local exact-source evidence is not hosted acceptance.
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`; V2 source `pkg-schema-v2@2c0df87a488bfeac6d185336ea5ae5a4ea469c4a` merged forward in PR #2 (merge tree equals validated `5928848...`). V2 runtime merged at `m-os/master@ed5ec60...` (tree matches validated candidate `168b8656...`). Exact post-merge suites pass; catalog promotion is complete.
- R1 package source heads verified read-only: `m-core/main@fb28e38fb478d0de01f379f6b4b5596c65921b2a`, `m-term/main@d75098655e24ee14e17789a0241a1781386dd75d`, `m-rsudo/main@f17e3826d5eb115cfafeeae7bdb292d53656531d`. Frozen `rumiai-os` and `rumiai-tests` remote heads were fingerprinted only; their contents remain untouched/unexecuted.
- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d` and `m-os/m-os-completion-s@15a2c4f96584c07b92088e5530d4ecb09a9477b8` were refreshed during this continuation; the S branch is a forward-only merge of master and remains unmerged on draft PR #4. Runner `pkg-catalog/m-os-completion-s-ci@835e0806190689a9f824627b3f718e94af8766dc` completed hosted run `42413203723`, 6/6 PASS on the exact integrated S candidate (Ubuntu 26.04, macOS ARM64, macOS 15 Intel offline safety; genuine provider lifecycle on Ubuntu; two-concrete host-user lifecycle on Ubuntu and macOS ARM64). This does not establish privileged system-host registration or physical-host validation.
- C2 audit refreshed current `m-os/master`, `pkg-catalog/main` and canonical specifications. Already settled boundaries: independent shell/process selections; unsupported package `var/` must fail closed; service context comes only from trusted registration; CA approval/revocation remains administrative; ordinary libraries remain attached to selected package concretes without an implicit dependency graph. Open normative choices remain the generalized grammar/reset/default behavior, selector-free default/preset authority and migration, child envelope, context-aware state roots/`m_STATE_*` compatibility, and provider override precedence. The audit rejected automatic adoption of arbitrary `current` symlink targets into a new context registry because that would grant unapproved path authority. Preserve legacy selectors until an explicit mapping/validated migration exists; do not start C3 against guessed semantics.
- Exact current-master direct state consumers were inspected: root `m` sources global env files from readonly `m_STATE_SYS_DIR`; `state-path` resolves system/user `current`; provider integration/materialization/reference logic also uses `m_STATE_SYS_DIR`. A C2 migration therefore needs a coordinated bootstrap/state/provider transition, not just a context-library edit.
- `m-os/master@5884cf05ebd3033524db3890a7e34fc0decdd4f6`; `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`.
- `pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609`; `pkg-catalog/pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7`.
- `m-core/main@0afb8752440808e9080a55c667576ff2f9b8eb32`, `m-term/main@c32aac18f6659ed4f569cb780080675fa64f9e3a`, `m-rsudo/main@a7248612773cdbd8d9cb9781915065fba5f0cc4c`.
- `m-mk/main@8c857460213199eeb4c5c070b4df60c885df376f`, `m-jsc/main@ca1b70d1e0c53e790244f28b67bcf2a2b7528c76`.
- Legacy `rumiai-os/main@8ae78944ef5e8d6297c50898d856db1a20c6fd9a` and permanent `rumiai-tests/main@b8e1c71db7aa4b94fedef323c5b3f1030dab1c24` are **frozen** for modification/execution unless the user explicitly lifts the freeze. Reading legacy source is permitted.

## Applicable canonical sources

`README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `DEVPLAN.md`, `TESTING.md`, `PHYSICAL-TESTING.md`, `handoff/README.md`, and `specifications/README.md`, routing as applicable to `rumiai-os/{CURRENT-MODEL,BOOTSTRAP-ENVIRONMENT,PACKAGE-MODEL,STATE-MODEL,LIBRARY-INTERFACES,FILESYSTEM-NAMING,COMMAND-ENTRYPOINTS,DOCUMENTATION-MODEL,DIAGNOSTICS,RESOURCE-MODEL,POSIX-PORTABILITY-LAYER,SERVICE-LIFECYCLE,TLS-TRUST,JSON-QUERY,RSUDO,SSH,MENU}.md`. Other command-specific specifications are mandatory when the corresponding implementation scope becomes active. Consult the owning handoffs above for task-local fixed choices.

User-intent evidence was previously reviewed from `chats/m-os/` archives, notably `2026-10-26 Verifica Ubuntu m`, `2026-10-29 m context 2`, `2026-11-03 m-context 3`, `2026-11-03 m-context 4`, `2026-11-04 m-context 5`, the JSON chat and the migration synthesis. These are **non-authoritative** archival evidence; `2026-10-26 m context/index.html` was empty. Do not consult Git history by default.

## Sufficiency gate / limits

**Verdict for the complete general-context + m-os program: Specifiche insufficienti.** The current `m-os` public baseline and many M01–M15 tasks have sufficient settled contracts for bounded unit-level planning. This is a **detailed conditional execution sequence**, not a claim that every future unit is ready to code or that its full-context public grammar is already approved.

**Already settled:** core/optional-package responsibility principle; POSIX bootstrap independent of Node/`mk`; real public `pkg install` and genuine artifacts; actual `srv` positive paths; v2 `link/bin` as uniform entrypoint and `link/lib/{sh,java}` library views; existing `v1` retained; no v2 resource exports (deferred); package-store existing protection retained; `rumiai-validate` target unchanged; forward-only migration; no synthetic substitute for a claimed real end-to-end result.

**Material contract gates:**
- **G-CONTEXT:** `BOOTSTRAP-ENVIRONMENT.md` currently specifies only shell-local exact `pkg=` and no-argument **reset**. Ordered selection/preset composition and no-argument default initialization were design proposals, not approved public behavior. The approved boundaries are listed in the C2 audit below; public grammar, defaults/reset migration, preset authority/storage, trusted child propagation, library consumer binding, state-root migration and provider precedence remain open. Do not implement an invented API.
- **G-PKG:** P2 is accepted and implemented on merged master; P3/P4/J1 and V2 runtime/catalog promotions are also complete on their recorded revisions. Preserve the current upfront full-request, single-catalog-snapshot, exact-root dependency-first rule in `PACKAGE-MODEL.md`. Do not reopen completed milestones or assume their scoped PASS closes whole-plan validation. Transparent ordinary-library consumer dependencies cannot be silently recast as facility dependencies.
- **G-ACCESS:** Only ordinary, nonprivileged authorized reference-host access remains a practical evidence condition. Operator-privileged remote SSH/sudo, system-supervisor, protected-host CA and privileged physical work is excluded from this plan and deferred to `todo/m-os-operator-privileged-validation.md`; its unexecuted status is not a gate for the active nonprivileged completion scope.

**Scope excluded from `m-os` core completion:** all operator-privileged acceptance/host administration (separate TODO); finishing all separate APISIX/Keycloak administration features; migrating or editing frozen legacy product/suite; v3 resource descriptors; hardening package-store permissions; changing formal `rumiai-validate` target; adding all optional legacy commands indiscriminately. These remain their existing owners' tasks, and do not block core acceptance solely by being incomplete.

## Acceptance scenarios and completion definition

1. On a clean supported POSIX environment with no managed Node/`mk`/catalog already installed, `./m` bootstrap, technical commands, state/manual/localization, and appropriate offline error paths work; only operations needing a package require a catalog/network.
2. A normal operator uses real `./m pkg install ...` with genuine catalog/release artifacts; versions/default, dependencies, provider selection/bindings, environment, uninstall/reinstall and rollback behave per the **reconciled canonical** contract, without substitutes.
3. The public `srv` starts a genuinely installed provider, verifies a responsive service and stops it; failure and restart paths cannot act on unrelated services. Host supervision acceptance here is **unprivileged `srv host user` only**; privileged system service operations are deferred.
4. A shell/user selects concrete package commands and ordinary sh/Java library views through existing `context`, with demonstrated real consumers and fail-before-activation error behavior. **Later full-context** scenarios must first have a promoted grammar/selection/inheritance contract.
5. `m-core`, `m-term`, `m-rsudo`, `m-mk` and `m-jsc` integrate as genuine published packages; local `rsudo` shell/menu/source-injection paths remain active. Actual privileged remote SSH/sudo acceptance is exclusively deferred and never inferred from local PASS.
6. Every **current autonomous** technical command, adapter and manual is inventoried; uncovered specified `json` and any other actual gaps are resolved or explicitly scoped as separate packages before asserting the core is complete.
7. The v1/v2 runtime/catalog are consistent and promoted forward-only when permitted; the exact integrated revision has an M01–M15 evidence matrix **for active nonprivileged scenarios**. Deferred privileged scenarios remain untested, not silently PASS. Do not reclassify auxiliary CI/operator reports as formal physical PASS.

## Parallel execution graph

```text
P0 authoritative source/target inventory
 ├─ A1 bootstrap/state ─ A2 manual/shell ─ A3 network/extract ─ A4 TLS/NSS
 ├─ J1 standalone json completeness (source-composition owner)
 ├─ S1 portable srv ─ S2 unprivileged host-user supervision
 ├─ R1 core/term/rsudo independent-package boundaries (local, nonprivileged)
 ├─ P1 pkg install canonical mismatch ─ P2 dependency/install/extract implementation
 │                                     ├─ P3 provider/version/default/uninstall reality
 │                                     └─ P4 installed facility derived-map integration
 ├─ V1 v1/v2 real adapter/library/Java coverage (independent catalog-side checks)
 │      └─ V2 runtime/catalog coordinated promotion (after P2 + P3/P4 as affected)
 └─ C1 accepted exact-package context tests (current contract)
        └─ C2 full-context contract gate ─ C3 full-context implementation (after P4)
A*, J1, S*, R*, and non-conflicting V1 / C1 evidence can run concurrently.
P1/P2/P3/P4, V2 and C3 that edit common m-os pkg/context files are serial or
coordinated by a single writer. Final I1 integration checks -> I2 nonprivileged physical evidence.
Privileged operator validation is outside this DAG: `todo/m-os-operator-privileged-validation.md`.
```

A work unit is *functionally independent* only if it does not consume an unsettled upstream interface; it is *operationally independent* only if it does not write the same files, mutable catalog branch, package releases, host service or provider state. Shared `m-os` tree writes require one branch/file integration owner; distinct files alone are not permission to change shared public semantics in parallel.

## Detailed units: settled/current-contract work

### P0 — Scope and evidence inventory (READY, planning/inspection only)

- **Deliverable:** source-backed manifest of each current `m-os/bin/sys` command, `res/sys/manual` topic, exported library, repository adapter, catalog-backed real scenario and M01–M15 status by revision/host, noting true missing-source vs missing-test vs optional extracted package. Confirm the 16 current command identities in `m-os/pkg-schema-v2/bin/sys` and independently specified `json` mismatch, without treating the old tree as the target.
- **Inputs/baseline:** above HEADs; `CURRENT-MODEL`, `COMMAND-ENTRYPOINTS`, `DOCUMENTATION-MODEL`, `TESTING`; files under `m-os/bin/sys`, `res/sys/manual`, `lib/sys/sh/pkg/repository`, `.github/workflows`; owning M01–M15 handoff.
- **Boundaries:** planning/documentation only; no test/CI/product changes. Existing validation owner maintains evidence, source-composition owner maintains scope. P0 coordinates references without duplicating per-unit operational state.
- **Done:** every public command has a source/manual/accepted-scope row; real adapter availability, frozen legacy source-only gaps and outdated evidence are classified. A newly discovered contract conflict is routed to its owner, not silently fixed. **Feeds:** A*, J1, S*, P*, V1, I1.

#### P0 source/manual manifest (2026-11-05)

Source-inspected `m-os/master@31693e814f682690adfd48185da822f7f5007f9e` (before A1 CI commit), `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`, `pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609` and `pkg-catalog/pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7`. Each current mainline `bin/sys` identity below has a matching operational manual; this is a **source inventory, not a behavioral PASS**.

| Identity | Source | Manual | Acceptance owner |
|---|---|---|---|
| `m` | root `m` via `bin/sys/m` | `res/sys/manual/m` | A1 |
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

Mainline repository adapters: `pkg-repository-{artifact,chrome,chromium,github,nodejs}.lib.sh`; the v2 feature adds `pkg-repository-{apache-maven,temurin}.lib.sh`. Catalog mainline has real `nodejs`, `mk`, `jsc`, `electron-web-control`, `ollama` definitions, among others; the v2 feature contains `jq`, `jsc`, `m-core`, `m-rsudo`, `m-term`, `mk`, `nodejs`, `ollama`. Catalog presence does not prove adapter correctness or complete public installation. The independently specified `bin/sys/json` and manual remain missing from both `m-os` branches; J1/source-composition owns that real implementation gap. M01–M15 PASS/PENDING and host/revision evidence remain exclusively in `handoff/m-autonomous-validation.md`; current-manual semantic verification remains M15 PENDING.

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

### S2 — Unprivileged host-user supervision (M13 user path only)

- **Target:** `srv host user` on supported systemd/launchd using a disposable unprivileged calling account and provider; the current `SERVICE-LIFECYCLE`, adapters and manuals.
- **Acceptance:** install/start/restart/stop/uninstall an isolated real provider, verify actual POSIX-account routing, process identity, state and cleanup, without changing system-level service registrations, protected host resources or unrelated users' services. Public nonroot system-operation refusal is an acceptable negative-path test.
- **Dependency:** S1 portable service lifecycle; positive `srv host system` is **not an active M13 acceptance requirement** and is reserved to `todo/m-os-operator-privileged-validation.md`.

### R1 — Independent first-party real package integration (READY for nonprivileged paths)

- **Target/ownership:** source-composition handoff; `m-core`, `m-term`, `m-rsudo` separate repositories and current published `v0.1.0` unchanged. Source: `m-rsudo/bin/sys/{rssh,rsudo-admin}`, `m-core/lib/sys/sh/loadlib-inject-stream.lib.sh`, `m-term` menu assets, manuals; v2 `pkg-catalog/v2/pkg/{m-core,m-term,m-rsudo}`.
- **Acceptance:** real GitHub releases installed via public `pkg install`, correct selected `link/bin` and `link/lib/sh` views, real shell-library consumers, no fallback to legacy `$m_LIB_DIR/sys/sh` for extracted package modules; validate `rssh` extension and `rsudo-admin` injected source/menu path design against the actual source-stream contract.
- **Evidence:** existing `m-core/.github/workflows/integration.yml` Ubuntu/macOS PASS is baseline for local nonremote paths; menu interactive vmdev PASS is operator report; new tests must target changed real normal paths, not replay already-PASS checks without change. R1 may change its own independently owned package sources only when authorized, with matching manuals/new immutable releases after real proof; `m-os` shared loader changes require C1/P2 integrator consent.


### C1 — Current exact-package shell context (READY; no new grammar)

- **Target:** `m-os/lib/sys/sh/context.lib.sh`, `res/sys/manual/context.lib.sh`, `m-os/.github/scripts/context-libraries-test.sh` and real install pipeline; `BOOTSTRAP-ENVIRONMENT` currently defines exact `pkg=` and no-arg reset. Feature v2 `link/bin` is not yet the published mainline `cmd` wording; preserve that distinction until promotion.
- **Acceptance:** genuine `m-core` / `m-term` / `m-rsudo` separate installed package views; sh source via `PATH` with existing `loadsyslib` used correctly, Java JAR `CLASSPATH` where a real package exports it; replacement order, collisions, shell-local state, reset, failed-selection no-mutation, user PATH preservation and child-shell function reinitialization. No synthetic package masquerading as end-to-end proof.
- **Evidence:** real cross-package consumer output on Ubuntu/macOS and vmdev if applicable, pinned source/catalog/release identities, separate tests for error branches. C1 is **not** approval for default presets/providers/protected inheritance. Only C1 writer edits the current context library until G-CONTEXT is promoted.

### P1 — Canonical pkg install contradiction (SPECIFICATION RECONCILED; P2 RUNTIME PENDING)

- **Owner:** `handoff/pkg-dependency-resolution.md`. `PACKAGE-MODEL.md` now specifies upfront validation of every request, a single catalog snapshot, exact roots and dependency-first installation; the source/manual path remains P2 ownership. Compare current `m-os/lib/sys/sh/pkg/{pkg-install,pkg-depend,pkg-common}.lib.sh`, manuals and authentic public tests.
- **Deliverable:** one consistent authoritative spec, command/manual behavior, regression expectations; do not silently let a convenience algorithm decide observable semantics.
- **Done for P1 specification only:** deterministic full-batch failure-before-mutation and exact-root/snapshot semantics are promoted. P2 must still align implementation, operational manuals and real regression evidence; internal private cross-library calls do not become public APIs. P2 gates V2.

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

### C2 — Promote full-context public contract (G-CONTEXT; DESIGN AUDIT COMPLETE, SPECIFICATION GATE OPEN)

- **Owner:** `handoff/rumiai-os-source-composition.md`; inspect current `BOOTSTRAP-ENVIRONMENT`, `PACKAGE-MODEL`, `STATE-MODEL`, `LIBRARY-INTERFACES`, `CURRENT-MODEL` and `m-os/lib/sys/sh/context.lib.sh`.
- **Deliverable:** one noncontradictory, formally promoted public contract for: no-arg managed-shell startup/default vs old reset; one active context replaced until exit; strict left-to-right selection fold with inline named presets; existing package/facility/user/profile dimensions; system/default vs consumer-bound provider selection; exact concrete cmd+env+lib coherence; protected inherited variable ownership/trust, shell/child/nested execution and failure atomicity; no per-call symlink generation. Define what remains intentionally unsupported, rather than inventing Python/Node loader variables or a universal resource API.
- **Current audit result:** independent source review confirms process-local isolation, fail-closed unsupported `var/`, trusted service registration, separate administrative CA authority, concrete-owned ordinary libraries, and no implicit library dependency graph. It also confirms that bootstrap, `state-path` and provider runtime still directly consume readonly `m_STATE_*` roots and global `current` selectors. Grammar/reset/default behavior, persistent default/preset authority, arbitrary legacy selector migration, child envelope, state-root compatibility and provider override precedence are not settled by current specifications or accepted user decisions. Automatic import of arbitrary `current` symlink targets into a new registry was rejected as an unjustified grant of path authority.
- **Gate/acceptance:** C2 remains open until these choices are promoted coherently in `BOOTSTRAP-ENVIRONMENT`, `STATE-MODEL` and `PACKAGE-MODEL`, including a safe legacy migration boundary. Preserve current selectors and existing first-phase semantics meanwhile; do not start C3 against a guessed contract. Once promoted, require fresh managed-shell default initialization, overridden provider while another consumer remains pinned, nested child with protected HOME/browser NSS, ambiguous provider failure without environment change, and second `context` replacing the first.

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

### I2 — Nonprivileged reference-host validation and closure (after I1)

- **Owner:** validation handoff. Confirm exact product/release revisions on the operator's Ubuntu 26.04 ARM64 VM, Ubuntu 24.04/26.04 x86_64 VM and macOS 27 ARM64 when ordinary authorized access is available, following `PHYSICAL-TESTING.md`.
- **Acceptance:** normal public-command bootstrap, package install/provider, portable service, unprivileged host-user lifecycle, context and local package/menu consumer scenarios with isolated user-owned state and cleanup. Never assume privileged host rights or remote sudo. Record exact revisions/host/commands/results and distinguish operator reports from formal physical evidence.
- **Closure:** complete only the applicable **nonprivileged** active contract with real evidence; real privileged remote `rsudo`, `srv host system`, protected CA administration and privileged physical steps remain separately deferred and untested, not required to close this scope. Lack of ordinary reference-host access is still reported honestly.

## Parallel dispatch order and conflict policy

**Wave 0, immediate and planning-only authorization:** P0, P1's authoritative conflict review, C2's contract comparison, J1's source/manual inventory, V1's missing-run inventory and R1's package-path analysis can begin together. None needs a new public interface or privileged host.

**Wave 1, after explicit product/CI authorization where applicable:** A1/A2/A3/A4, S1, J1 implementation (only after J1 boundary check), R1 nonprivileged remediation, V1 real published-artifact tests and C1 real package-context checks can proceed concurrently **only with disjoint files/state**. If A1 and A2 both need `core`, one integrator serializes their changes. P2 owns all `pkg` install/extract files; do not race P3/P4/V1 changes there.

**Wave 2, serial shared-pkg integration:** P1 -> P2 -> P3/P4 interface reconciliations -> V2, with P3 and P4 test-data analysis performed in advance. Rebase/re-read forward whenever a shared HEAD advances; preserve other actor commits. C3 waits for C2 plus P4 and accepted v2 runtime views.

**Wave 3, final:** I1 revision-specific integrated **nonprivileged** evidence -> I2 accessible nonprivileged reference-host checks -> close the active task only if its applicable M01–M15 and generalized-context acceptance pass. Operator-privileged tasks are excluded from scheduling, delegation and closure gates; they are deferred in `todo/m-os-operator-privileged-validation.md`.

**Executor protocol:** each independent chat receives (i) local unit ID from this handoff, (ii) owner handoff, (iii) source/branch checkpoint to freshly verify, (iv) exact writable files/branch and prohibited shared surfaces, (v) public expected tests + manual updates, (vi) expected upstream output and integration handoff. Every executor follows fresh HEAD preflight, no history by default, current source authority, proportional real tests, reviewed diff, forward-only updates and consistency gate. When an interface or host/privilege contract is unsettled, stop only that affected unit and escalate; do not freeze independent ready work.

## Historical state checkpoints (superseded by the 2026-11-10 continuation checkpoint above)

### S1 current-master SRV-42 correction (2026-11-07)

- A controlled public-command probe on current `m-os/master@a78a24bd...` showed that a complete legacy runtime record with a live PID but no process-start identity was accepted as already running and then signaled by `srv stop`; this contradicts current canonical SRV-42. The test used and terminated only its own `/bin/sleep` process.
- Forward-merged current master into existing S branch and pushed `m-os/m-os-completion-s@15a2c4f96584c07b92088e5530d4ecb09a9477b8` (PR #4). The master branch was not changed. `srv start` and `srv stop -f` now reject the exact legacy fixture and stale start identity with `live-runtime-state-invalid`, preserving process/state; incomplete metadata, stale cleanup, missing default, invalid service, and non-root administrative refusal also passed locally on this exact candidate. No host supervisor or pre-existing process was touched. Exact hosted S1/S2 integration validation now PASS 6/6 in pkg-catalog run 42413203723, pinning `master@a78a24bd...` and S@`15a2c4f9...`; see the validation handoff. PR integration remains pending final review; same-second PID reuse and check-to-signal race remain documented limits.

### Latest integrated-source checkpoint (2026-11-07; current)

- P3 and P4 are integrated on `m-os/master@1df35f70...`; J1 JSON is integrated in the same master. Exact final-master hosted checks completed successfully: P3 current-source run [42401852595](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42401852595) 6/6, P3 public lifecycle/protection runs [42401852426](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42401852426) 3/3 and [42401852487](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42401852487) 2/2, P4 map/lifecycle [42401870421](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42401870421) 2/2, and J1 public JSON/JSONTestSuite [42401889106](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42401889106) 2/2. Earlier post-merge HTTP 403 acquisition failures are superseded by these exact-master successes.
- V2 runtime PR #8 is merged as `m-os/master@ed5ec60...`; catalog PR #2 is merged as `pkg-catalog/main@0b69223...`. Both merge commits have trees identical to the exact branches validated in CI. Exact merged-master full V2 matrix passed 16/16 [42403134850](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42403134850), mixed-schema 2/2 [42403134968](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42403134968), Java/Maven 2/2 [42403134965](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42403134965), mk/jsc 2/2 [42403134894](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42403134894), Node.js 2/2 [42403134876](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42403134876), and nonprivileged Ollama service/host-user [42403134864](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42403134864). The host-system job was explicitly skipped and excluded.
- C2 accepted policy decisions are recorded; exact public context grammar/default/preset persistence, trusted child propagation, `env` compatibility, real `var/` behavior and ordinary library/provider consumer semantics remain unresolved. C3 is gated on those contracts. Full I1 M01–M15 current integrated matrix and I2 accessible reference-host checks remain open; privileged tasks stay deferred.
- A2 runtime candidate `m-os@0f4f5c3213435e29022e8ffa4e32e1a19d9c7158` passed its full public workflow body and rollback-failure injection locally on Ubuntu ARM64; bounded M12 no-provider/malformed-live/foreign-owner negatives also passed there. Documentation-only follow-up `m-os@7692c4fe51e177b44cf3b77d2a779b529c897dac` fixes bootstrap status clarity across all 14 m-dependent command manuals. PR #10 remains draft/mergeable, based on `a78a24bd...`; no deferred A1–A4 hosted workflow was dispatched, so hosted/cross-host acceptance remains open.
- A1–A4 hosted runs remain explicitly deferred by current handoff. Do not resume them implicitly.

The historical entries below retain the status observed at their dates and revisions. They do not override this current checkpoint: P3/P4/J1/V2 are merged, and V2 catalog promotion is complete.

### Operator-approved C2 invariants and privileged work deferral (2026-11-07)

- Accepted and canonically recorded: independent concurrent shell/ordinary-process profiles; host service profiles bound by authorized registration; host-authorized CA approval with consumption from a verified selected system profile; incompatible package launches fail closed before using the wrong state. These design invariants do not constitute C3 implementation or a new public context grammar.
- All operator-privileged work was transferred out of the active execution DAG/acceptance units to `todo/m-os-operator-privileged-validation.md`. Unprivileged `srv host user`, disposable TLS/NSS, local rsudo/menu and nonprivileged physical public paths remain in scope. Older historical evidence may still mention privileged pending cases, but cannot authorize or schedule them.

### Branch S final-source hosted macOS PASS and safe exact-master integration probe (2026-11-06)

- S1/S2 exact `m-os/m-os-completion-s@d8f96689e3b288ea56cc7ab4da96a0a14c62adec` is now **PASS 5/5** on [run 42199875387](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42199875387) and **PASS 6/6** on [run 42200525680](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42200525680), including the completed real macOS 26 ARM64 live legacy-PID safety, native two-concrete host-user manager lifecycle and auxiliary macOS 15 Intel safety checks. All raw macOS logs contained explicit terminal PASS rather than SKIP. Owning validation handoff has exact runner and job IDs; GitHub-hosted evidence does not imply operator physical PASS.
- The separate [local GitHub-hosted integration probe 42240263411](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42240263411) pins current integrated `m-os/master@e07fbec09fae49cab0d688940e6406a25b6b5e83` and S `m-os@d8f96689`; it performs a **runner-only** Git merge and tests the merged tree via genuine S public commands. No conflicts; Ubuntu 26.04 offline safety, real published-provider cycle and native two-concrete host-user cycle **PASS 3/3**. macOS ARM64 offline/user and macOS 15 Intel offline remain queued at this checkpoint; no accepted macOS merged-tree evidence until their actual logs are checked.
- [Draft PR #4](https://github.com/massimilianonardi-ai/m-os/pull/4) remains unmerged; S does not push a merge commit to source or mutate shared P2/V2 catalog, privileged manager or frozen legacy suite. Same-second PID recycling/read-to-kill atomicity, G-HOST, other POSIX backends, and operator physical reference hosts still gate full S acceptance.

### Branch S live legacy PID state fail-closed (2026-11-06)

- S1 corrected a concrete remaining safety defect at `m-os/m-os-completion-s@d8f96689e3b288ea56cc7ab4da96a0a14c62adec`: complete older runtime records without process-start identity no longer authorize a live PID on public `srv start` / `srv stop -f`. Dead-PID state still cleans. Canonical `SERVICE-LIFECYCLE.md` now specifies SRV-42 and the revision-coupled `srv` manual documents this deliberate compatibility tradeoff; only S-owned runtime/manual/public safety workflow changed. A real live disposable unrelated PID is protected by the new test.
- [Exact pinned CI run 42199875387](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42199875387), temporary runner `pkg-catalog/m-os-completion-s-ci@165ff20680096648655afcbd18ce75aba691a5d1`: Ubuntu 26.04 offline safety, actual published provider lifecycle, native two-concrete host-user manager all **PASS (3/3)**; auxiliary [run 42200525680](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42200525680) also verified macOS 15 Intel S1 legacy-PID safety **PASS** against the same product revision, while macOS 26 ARM64 safety and host-user jobs remained **QUEUED** at checkpoint. `handoff/m-autonomous-validation.md` owns job IDs and future verdicts. Start identity from Linux/Darwin `ps lstart` remains second-resolution; this correction does **not** close same-second PID reuse, process identity/kill race, other host adapters, G-HOST privileged system supervisor or designated reference-host physical requirements.
- Keep [m-os Draft PR #4](https://github.com/massimilianonardi-ai/m-os/pull/4) unmerged and S isolated; no shared P2 `pkg`, `pkg-catalog/main`, frozen test/runtime or unauthorized host mutation.

### Branch S hosted macOS account routing and published service PASS (2026-11-06)

- [Run 42195884135](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42195884135) pinned to `m-os/m-os-completion-s@8efbbff85e1b858066c37946ef62ef7eee63d679` completed **3/3 PASS**: Ubuntu 26.04, macOS 15 Intel and macOS 26 ARM64 real native host-user two-concrete default switching, TERM/exit and actual-account supervisor routing with redirected caller HOME/XDG. [Run 42193825267](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42193825267) on earlier test source `m-os@49ad0d9` completed **4/4 PASS**, including actual macOS ARM64 `electron-web-control@v0.1.0` published install and host-user install/start/readiness/restart/stop/uninstall; previously observed upstream 403 is not assumed permanently eliminated. Owning `handoff/m-autonomous-validation.md` records the exact runner/job IDs, split source scopes, and residual gates.
- This is real GitHub-hosted evidence, not an operator macOS 27 reference-host physical PASS or privileged `srv host system` G-HOST authorization; legacy/no-snapshot PID records, same-second PID reuse, and other POSIX host adapters remain pending. [Draft PR #4](https://github.com/massimilianonardi-ai/m-os/pull/4) stays unmerged. Only S test workflow, isolated CI runner, PR and task handoffs changed; no S edits to production `srv`, shared P2 files, frozen repos or catalog main.

### Branch S native two-provider and actual-account host routing check (2026-11-06)

- S2 exact `m-os@49ad0d9453a1ac0a67b9ad2ee4894bfd9a394848` native `srv host user` provider-version re-selection + live PID/TERM now **PASS Ubuntu 26.04 and macOS 15 Intel** in [run 42193825267](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42193825267), jobs `127812007937` and `127812008048`; macOS 26 ARM64 native version-switch has now **PASS** in the same run, job `127812007780`; independently published-Electron acquisition remains **QUEUED**.
- S added a **test-only** real-account-supervision boundary check at `m-os/m-os-completion-s@8efbbff85e1b858066c37946ef62ef7eee63d679`: fake caller HOME/XDG must not divert `srv host user install/start` from the actual POSIX account. [Exact-source CI 42195884135](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42195884135) Ubuntu job `127818910072` and macOS 15 Intel job `127818909461` both **PASS** with explicit two-provider native lifecycle log; macOS 26 ARM64 job `127818909822` remains **QUEUED**. Owning `handoff/m-autonomous-validation.md` holds exact target/runner/job data and remaining gates. These tests do not validate a published release on macOS, a privileged system service, same-second PID recycling, or the operator reference hosts. [Draft PR #4](https://github.com/massimilianonardi-ai/m-os/pull/4) still unmerged. No P2/shared pkg, main catalog definition or frozen repository writes by S.

### Branch S two-concrete native host-user provider re-resolution (2026-11-06)

- S-owned isolated real-provider workflow at `m-os/m-os-completion-s@49ad0d9453a1ac0a67b9ad2ee4894bfd9a394848` now exercises two distinct installed concretes, public package-default transitions, native `srv host user start/restart/stop`, live PID stability, provider-specific TERM and stop. Real Ubuntu `systemd --user` **PASS** at [run 42193537286](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42193537286), job `127811076949`. First fixture-only failure [run 42193372851](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42193372851) was corrected by retaining a copy of source payload before real `pkg_integrate` consumes it, without modifying product `pkg`.
- macOS 26 ARM64 two-concrete native `launchd` and genuine published Electron acquisition remain **QUEUED**, not PASS: [run 42193825267](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42193825267) pins exact S, includes Ubuntu native re-resolution PASS, macOS 15 Intel and ARM64 local-provider jobs plus separate published macOS provider retry. `handoff/m-autonomous-validation.md` owns exact runner/jobs, result follow-up, and G-HOST/legacy-PID/physical gates. Prior 5/5 Ubuntu/macOS S matrix PASS remains exact to earlier revision only. [Draft PR #4](https://github.com/massimilianonardi-ai/m-os/pull/4) still unmerged, no P2/shared runtime/frozen suite writes.

### Branch S hosted macOS/Ubuntu matrix acceptance checkpoint (2026-11-06)

- All previously queued S1 and S2 macOS jobs are **genuine PASS**, not merely queued or `SKIP`. In particular macOS 26 ARM64 native `launchd` with isolated integrated provider and macOS 15 Intel explicit native TERM/old-PID disappearance passed. Owning `handoff/m-autonomous-validation.md` has the complete source/runner/job IDs and distinct evidence boundaries.
- Unified S1/S2 exact-source GitHub-hosted [run 42192103307](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42192103307) on `m-os/m-os-completion-s@433f341351ab8240563189229b0b3dd0ea2dda1e` **PASS 5/5** (Ubuntu/macOS 26 ARM64 offline, Ubuntu published real provider, Ubuntu/macOS 26 ARM64 native user supervisor). The macOS positive *portable* `srv start` / `srv stop -f` path now ran with a real local provider before native host-user operations, closing the prior hosted Darwin positive gap.
- No full S/M12/M13 promotion or merge yet: macOS published Electron installation still has separate upstream HTTP 403, privileged host-system paths need explicit controlled G-HOST, legacy PID identity and same-second reuse remain open, and operator reference-host physical validation remains PENDING. [Draft PR #4](https://github.com/massimilianonardi-ai/m-os/pull/4) stays unmerged. No shared P2/V2, `pkg-catalog/main`, frozen runtime/test, or reference-host mutation by S.

### Branch S forced-stop and native TERM evidence (2026-11-05)

- S1 now explicitly protects an unrelated live PID from **forced `srv stop -f`** when persistent instance identity is stale: [real Ubuntu run `42116060510`](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42116060510) **PASS** against `m-os@d014d41e`. This extends earlier S1 rejection of `start` on the same stale process metadata.
- S2 isolated real package-provider/native `systemd --user` coverage now checks foreground process SIGTERM and eventual old PID disappearance on **both restart and stop**: [real Ubuntu run `42116611051`](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42116611051) **PASS** against exact `m-os@fe344c6bb6a1dd939e1d0eb442633bcf84a38e47`. macOS 15 Intel and original macOS 26 ARM64 native-host jobs remain QUEUED, not accepted. This does not resolve upstream published-provider 403 on macOS.
- The owning `handoff/m-autonomous-validation.md` records source/runner revisions, job IDs, and residual PID/system-host/physical gates. No shared P2, frozen tests or privileged production host touched. [Draft PR #4](https://github.com/massimilianonardi-ai/m-os/pull/4) remains unmerged.

### Branch S host-specific process verification and native-user exercise (2026-11-05)

- [S1 exact-source run 42098169071](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42098169071) completed **3/3 PASS** on Ubuntu real provider/offline and macOS offline stale-identity regression. The S-owned process-start inspection is now explicitly confined to Linux/Darwin host backends with fail-closed behavior on other hosts (`m-os/m-os-completion-s@5c996d97`), and command manual updated. A later [Ubuntu exact-source run 42113668108](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42113668108) passed both jobs, macOS queued.
- S2 macOS published-provider attempt 2 again failed at GitHub Releases HTTP 403 before the target host-user lifecycle. To independently probe actual supervisor behavior, S introduced a separate local integrated provider fixture, **without pretending that published installation succeeded**: [run 42114372442](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42114372442) real Ubuntu `systemd --user` **PASS**, macOS `launchd` queued. Detailed test IDs, candidate revisions, setup correction and pending scope are in `handoff/m-autonomous-validation.md`.
- No privileged system-host operation, reference-host physical validation, shared P2 files or frozen tests touched; [m-os draft PR #4](https://github.com/massimilianonardi-ai/m-os/pull/4) remains unmerged. Other POSIX host identity capabilities and same-second/legacy PID collision risk are not proven closed.

### Branch S process-identity correction checkpoint (2026-11-05)

S1 reproduced a genuine unrelated-live-PID acceptance regression
[`pkg-catalog` run 42096777829](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42096777829)
against `m-os@46be6d7a`. The isolated S owner corrected runtime process-start
identity recording/verification and `srv` manual/status/localization
(`m-os/m-os-completion-s@1903fb52c8a1b83f4d408c63fa6cdbad3f48f17d`).
The focused real Ubuntu rerun [42097127805](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42097127805)
passed both offline regression and real provider lifecycle; final-source
[42098169071](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42098169071)
had both Ubuntu jobs PASS and macOS queued. This is **not** universal process
reuse safety, full M12/M13 completion, or physical validation. S2 macOS
user-host first job failed **before srv** at upstream GitHub release HTTP 403,
with rerun requested, while Linux user-host already passed. The existing
`handoff/m-autonomous-validation.md` owns precise logs, SHAs and residual
legacy-process-identity/system-host coverage. Draft `m-os` PR #4 is not merged;
parallel package and catalog owners are unchanged.

### Branch S live CI evidence checkpoint (2026-11-05)

S1 ran authenticated public `m-os` commands on exact target
`11d01a1123022a6c05ce792063579fd1d115892f` through isolated,
active `pkg-catalog` hosted Actions [42091997203](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42091997203):
Ubuntu/macOS offline safety plus genuine Ubuntu published service all **PASS**.
The independently routed S2 `host user` Linux lifecycle also **PASS** in
[42092734957](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42092734957)
at `m-os@5ec400f20638e4992f81c4b4d8468bc65406cabe`;
macOS host-user was still queued. This does **not** cover S2 privileged system
scope, source-change PID-recycling risk, or operator reference hosts.
The isolated catalog branch only owns a temporary workflow; catalog main
and product package definitions remain untouched. **Draft m-os PR #4** is
unmerged; detailed job IDs, paths, and remaining S tasks belong to the existing
`handoff/m-autonomous-validation.md` owner.

### Branch A2–A4 dispatch checkpoint (2026-11-05)

The independently scoped branch A CI work advanced `m-os/master` forward from the A1 workflow commit `e0bcf2d69ba4e4209a93fd7d0c9b08a00def3a0f` to `1f8880c78febf390596faa9b6662ec8cab5c5e42`. A2, A3 and A4 each have a dedicated genuine-public-command GitHub Actions workflow; the A3 HTTPS harness uses a distinct CA-signed server identity (auxiliary transport-harness check only) and the A4 NSS projection tests exact revocation plus preservation of unrelated NSS trust. Only the A3-owned `extract` runtime command and its operational manual changed, along with branch-A CI workflows; catalog, packages, shared `pkg` files, frozen legacy code and permanent suite were not modified by branch A. **Execution remains PENDING**: no corresponding current `m-os` Actions run has been verified; authored workflows do not prove PASS. The exact operational scope and required result collection are owned solely by `handoff/m-autonomous-validation.md` (M01–M06/M14/M15). A3 includes hostile tar/zip traversal tests; the auxiliary host-backend check confirmed Info-ZIP can accept and normalize a `../` member with status 0 (not a full `m-os` runtime observation). A3-owned command `bin/sys/extract`, its manual and workflow were then corrected forward-only at `56049e57`, `0f14d548` and `15745d7b` to reject unsafe ZIP/JAR/WAR members before materialization with new statuses 3/4. The later A3 update at `m-os/master@e173dc9ed2bdb95753c3f12ab1f84045b5a2bce3` also blocks existing destination-symlink traversal for TAR and compressed TAR using a shared member-path guard with ZIP; command manual and public CI negative cases were realigned. Isolated Linux host backend behavior and preflight cases are observed, but full `./m extract`, macOS, archive-created links, races and other-format protection remain PENDING. The A3 workflow-only follow-up at `m-os/master@1f8880c78febf390596faa9b6662ec8cab5c5e42` additionally probes archive-created symlinks followed by escaping members in disposable TAR and ZIP paths; this is authored test coverage only, with no hosted runtime execution yet. A4 now includes a conditional real browser HTTPS reject→trust→revoke smoke, also unexecuted. The owning validation handoff records precise evidence and next steps. A3 must not modify P2-owned pkg extraction files; final installed-package browser and reference-host proof remain separate. These independent CI files do not release P2/V2/context gates.


### Branch R — guarded v0.1.2 package-source checkpoint (2026-11-06)

R1 authentic `m-core/m-term/m-rsudo v0.1.1` public package installation, selected consumers and in-memory menu source injection are **2/2 hosted PASS Ubuntu/macOS** in `m-rsudo` run `42097660573`. A later R1 negative regression check (run `42198682673`) detected a genuine shell-status discrepancy: the immutable `m-rsudo v0.1.1` command's missing-library dot-source can terminate Ubuntu noninteractive `sh` with status 2 before its intended explicit exit 3. In `m-rsudo/main@de73060502ee046221004a40125520b963f549be`, the already-owned package-view resolver was moved before source loading; preflight and distinct statuses were aligned with its manual. A new immutable `m-rsudo v0.1.2` release was successfully published from `41cb41678f17d2da8e45bdd5e89164d0ba0cbad8`, preserving `v0.1.0` and `v0.1.1`. `pkg-catalog/pkg-schema-v2@2c0df87a488bfeac6d185336ea5ae5a4ea469c4a` adds only the new `m-rsudo/n0003=v0.1.2` range and ordering entry. Its actual public `pkg install` plus selected `m-core/m-term v0.1.1`, `rssh` missing/duplicate-view, source-injection fail-closed and **real local rsudo-admin PTY Browse host (no credentials) + Escape** scenarios are **PASS Ubuntu** in run `42200139984`; macOS **QUEUED** at this checkpoint. Corrected source-composition run `42199494915` is also Ubuntu PASS / macOS QUEUED. No SSH or sudo host was contacted. Owning handoff: `handoff/rumiai-os-source-composition.md`. Remaining R1: collect macOS v0.1.2 evidence and assess untested actual conflicting installed version views; do not relabel the old v0.1.1 negative as PASS. R2 real remote privilege, auth and browser remain G-HOST-gated pending explicit controlled authorization; no shared `m-os/pkg`, frozen suite/legacy or physical host change.

### Branch V1 dispatch checkpoint (2026-11-05)

The operator authorized starting Branch V. **V1 is active under the existing `handoff/pkg-definition-model-review.md` owner; V2 promotion remains BLOCKED.** A single scoped catalog-side workflow addition at `pkg-catalog/pkg-schema-v2@ae3e2011462be46c0326179f2117b81b85e5df5e` started [real v1 Java/Temurin/Maven CI run 42085304112](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42085304112) against pinned `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd` and existing unpromoted Java permanent test `3f0eeb2d...`. Its Ubuntu/macOS jobs were queued at the checkpoint; no Java PASS is claimed. A failed-jobs-only rerun of the prior v2 catalog [run 42036487502](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42036487502) attempt 2 was also accepted and queued to recheck the sole macOS jq upstream HTTP 403; the first attempt's other 13 jobs were successful. Exact CI results and V1 next actions are tracked only in the owning pkg-definition handoff. No shared `m-os/pkg` runtime, catalog definition, release, `rumiai-tests/main`, or v2 mainline was modified; P2/P3/P4 and V1 evidence still gate V2.

### Branch S independent offline safety checkpoint (2026-11-05)

`m-os/m-os-completion-s@8a0451e08e808123cd74c0979e071b485249d75a`
adds a real-public-command S1 fault-safety workflow for hosted Ubuntu/macOS,
independent of genuine package installation. The exact new YAML and POSIX
shell syntax passed checks on a byte-verified local copy; **no S-branch Actions
run or behavioral result was observed**, so S1/S2 acceptance stays PENDING.
P2 already owns the upstream `nodejs =26` install problem in its distinct
draft PR; no `pkg` file was edited by S. S2 privileged positive host
integration remains authorization/environment gated. Operational test detail
and next action belong to `handoff/m-autonomous-validation.md`.

### Branch S dispatch checkpoint (2026-11-05)

The operator explicitly started S1/M12 and S2/M13. The isolated
`m-os/m-os-completion-s@25e66a829afb86d293d7e3bd9460249fc728a092`
branch was created forward-only from current
`m-os/master@e0bcf2d69ba4e4209a93fd7d0c9b08a00def3a0f`, preserving
concurrent A1's separate workflow change. S1's existing real
`m-srv-provider-live.yml` workflow was extended with genuine public
negative/restart/ownership/provider-selection scenarios; S2 only has a
non-administrator denial check prepared. No product code, catalog, release,
frozen suite, or host-system registration was changed.
**Result: PENDING** — no Actions run on this branch was observed at the
checkpoint. Last inspected older master S1 run
[41426638581](https://github.com/massimilianonardi-ai/m-os/actions/runs/41426638581)
failed during real `pkg install` due unresolved `nodejs =26`, before
reaching `srv`. P2 owns package resolution; S1 must recheck after that
integration, without editing P2-owned code. S2 positive Linux/macOS
user/system supervision remains controlled-host/authority gated.
`handoff/m-autonomous-validation.md` owns the detailed M12/M13
execution/evidence next action; this orchestration owns only dependencies.

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


**Supplementary P0 structural observations on that same source checkpoint:** 31 observed `lib/sys/sh/**/*.lib.sh` identities have matching manual topic names (presence only, not public API correctness); `pkg-catalog/main` contains 27 v1 package-definition names and the v2 feature contains 8 names. The standalone `json` gap and `pkg install` drift remain classified separately. This is not new runtime PASS.

**P1 progress:** `rumiai-dev` commit `639e990c5ad61a5092f42561e8d151a99f2ef6b8` reconciled the canonical upfront-request syntax and exact-root/same-snapshot installation semantics, and owning handoff `d06a69253720a4806ef2f83209f7d7cce722d232` records current autonomous `pkg` implementation/manual mismatch. P1 remains **partial**, P2 requires one shared-pkg implementation writer and actual public test evidence. No pkg implementation, catalog or frozen suite was modified by P1.

### Branch P — P2 current exact-root and validation checkpoint (2026-11-05)

P0 inventory and P1 canonical request/snapshot reconciliation remain complete. P2 is implemented on unmerged forward-only `m-os/m-os-completion-p2@44b8133b4c0acbbc7bee54b765d48a0a51c9bf4b`, [draft PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3), with current concurrent A3 `extract`/manual additions merged from `m-os/master@15745d7b575d725073d0fd11d221bd0117ee916e` without conflicting pkg writes. `pkg install` validates the entire batch upfront, concretizes requested roots in one catalog snapshot, plans against those exact identities in that same snapshot without second remote-version discovery, installs dependency-first and distinguishes pre-existing roots from dependency-fulfilled ones. The existing standalone read-only `pkg depend` retains its request semantics. Library/command manuals and genuine public CI scenarios have been realigned, with strict malformed-store and branch-specific local status checks.

**Real revision-specific P2 evidence:** an isolated `pkg-catalog/m-os-completion-p2-ci` workflow executes the **original** P2 public script from an exact `m-os` checkout. [Run 42095006573](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42095006573), pinned to this integrated product head, has **Ubuntu SUCCESS** for the real published Node/mk/jsc public install/default/dependency and negative-batch/repeated-root/mixed-root/corrupt-store cases; **macOS remains QUEUED/PENDING**. Earlier [42094006865](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094006865), [42094446208](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094446208), [42094701542](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094701542) also yielded Ubuntu success on their own older exact SHAs only. No new native `m-os` Actions run or formal/physical M01–M15 validation is claimed. PR #3 remains **DRAFT**, P2 acceptance **PARTIAL**, P3/P4 and V2 shared pkg writes remain gated. Detailed acceptance and evidence ownership remains exclusively in `handoff/pkg-dependency-resolution.md`.

### Branch I — I1 readiness checkpoint (2026-11-05)

Operator-authorized **I** is active for a read-only I1 entry audit. **I1 integrated execution is BLOCKED** until the upstream P2/P3/P4, V1/V2, J1 and current-context acceptance gates; **I2 is PENDING** until I1 passes and authorized reference hosts are available. The P0 inventory above and M01–M15 evidence owner remain unchanged. P1 has reconciled canonical upfront batch validation and exact-root-first planning, but `m-os` current install source still uses original operand requests for `pkg depend` and installation. The separate POSIX `json` entrypoint is missing. Hosted three-package PASS [run 42037725004] is pinned to feature revisions; catalog run 42036487502 had an upstream macOS jq HTTP 403 acquisition failure, not a proved product regression. No new branch-I runtime/host test or product edit was executed. Remote source review included `m-os/master@e0bcf2d69ba4e4209a93fd7d0c9b08a00def3a0f`, `pkg-catalog/pkg-schema-v2@ae3e2011462be46c0326179f2117b81b85e5df5e`, and frozen `rumiai-tests/main@53d9551d225d2bf2ecb5e3017b242cf2c417d833`. Refresh HEADs before I1 execution.

### Branch I — release coherence / queued evidence check (2026-11-05)

This is **I1 readiness evidence, not I1 execution or a new M01–M15 PASS**. At this read-only review, [catalog Java V1 run 42085304112](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42085304112) still had Ubuntu Java/Maven job `127448677067` successful and macOS `127448676953` queued. [Catalog v2 run 42036487502](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42036487502) attempt 2 still had 13 matrix jobs successful and macOS `v2-jq` job `127446872211` queued; the previous HTTP 403 failure remains attempt-1 acquisition evidence, not a reproduced product defect. No new CI execution was started by I. The new A1 bootstrap/state and S1 lifecycle workflows had no matching completed Actions runs at this check; their owners retain execution and M01–M15 recording.

The five separately released real `v0.1.0` artifacts were verified through GitHub Releases, each with an archive and `SHA256SUMS`: `m-core@7213052f2576ec866f46da1dea9466ce750da21f`, `m-term@b7c7ef0200287d4704e33bdcdc1808d8bbd57373`, `m-rsudo@27a64ba95143a7d0869b21b80aaca5853290e6d3`, `m-mk@707d4c624a2fe7dcb149899346f71d5cd4a4bbf5`, and `m-jsc@0f5371ba10e55b21a95b9021bf82a64aacfd28be` (release tag commit IDs, **not** new local run evidence). Mainline source HEADs are later than those tags. The `m-rsudo` release-to-`main@07017bfd4aa1809370ca30c4fe28bb0ab85021a6` comparison includes `bin/sys/rssh` and `res/sys/manual/rssh` changes, so the previously successful installed `m-rsudo/v0.1.0` consumer test **does not validate the corrected unreleased `rssh` source**. R1/source-composition owns real installed-path validation, any later immutable release and catalog alignment; no release or schema was altered here. Changes after `v0.1.0` in `m-core`/`m-term` were workflow/README or README-only; in `m-mk`/`m-jsc` they were workflow/test changes, not proof of a revised artifact.

The I1 critical path remains: P2 exact-root/same-snapshot `pkg` implementation plus public regressions; applicable P3/P4 provider data-path evidence; J1 specified standalone `json`; C1 acceptance and C2/C3 contract/integration gate; genuine V1 results and V2 coordinated promotion; R1 published artifact/source coherence; finally one pinned complete integrated M01–M15 public test scope. I2 cannot be run as a substitute for any of these. `rumiai-os` and `rumiai-tests/main` remain frozen. The isolated assistant container could not resolve github.com for a real checkout; this is remote source/release/Actions inspection, with **no executed runtime/physical tests**.

### Branch I — P2 draft integration review and updated release evidence (2026-11-05)

**I1 remains BLOCKED; I2 remains PENDING.** Fresh remote preflight and current canonical read order were repeated. The existing single-writer P2 lane is now independently active in [m-os draft PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3), branch `m-os-completion-p2@cbafc1646b7e0d831f53816186bffc619e5d1afc` (not merged), while `m-os/master@5884cf05ebd3033524db3890a7e34fc0decdd4f6` retains the previous runtime. P2 has staged exact-root resolution, same-catalog-snapshot planner reuse, installed-store checks, status/manual realignment and a genuine-public Ubuntu/macOS workflow, but **no workflow run** was returned for the P2 branch. This does not constitute product PASS.

I1 independently inspected the draft implementation and submitted [PR review #5790367732](https://github.com/massimilianonardi-ai/m-os/pull/3) with two source-level acceptance risks. First, an explicitly requested root also installed as a dependency could incorrectly produce `already-installed` on the same fresh invocation; P2 independently corrected the source-level distinction between preexisting roots and in-batch dependency roots in `cbafc1646b7e0d831f53816186bffc619e5d1afc`, **not yet runtime-tested**. Second, the reused `pkg_depend_plan` still resolves those selected exact roots in `request` mode through `pkg_catalog_request_resolve`; this can require fresh repository-version discovery even for a valid already-installed concrete. Verify the exact-installed-root/same-snapshot contract and standalone public `pkg depend` preservation in P2 before I1 promotion. I made no shared pkg source change or duplicate P2 writer.

The current independent release-to-source diff contains **unreleased runtime changes**, not just documentation: `m-core/main@9c8e36e45e3b405f763c770c7b6d4cfeac93dab1` changes `loadlib-inject-stream`; `m-term/main@f11487bd613d64a1e2c51f5a4dadd48dee50bcc4` changes `menu` and a menu library; `m-rsudo/main@07017bfd4aa1809370ca30c4fe28bb0ab85021a6` changes `rssh` and a keycloak module relative to each immutable `v0.1.0` tag. Previously successful published-artifact runs do **not** validate these later source corrections. The R1/source-composition owner retains installed-path validation and any future releases; do not assume the new mainline source is present in `v0.1.0`.

At this checkpoint, [Java V1 run 42085304112](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42085304112) and [mk/jsc V1 run 42087769769](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42087769769) each have a real Ubuntu job successful and macOS queued. [V2 matrix run 42036487502](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42036487502) attempt 2 has 13 successful jobs and macOS `v2-jq` still queued; do not promote attempt-1 HTTP 403 as a code failure. C1 PR #2 and A1–A4/S1 authored workflows have no verified completion evidence for these current revisions. No I1 integrated runtime or I2 host session was performed. The next I1 action is to consume exact P2 public-run results, resolved source-review questions and V1/V2/C/J/R evidence, then freeze one integration target for M01–M15; do not start I2 early.

### Branch I — real Java cross-platform PASS and jq upstream retry (2026-11-05)

This checkpoint is **source/CI evidence review, not combined I1 or physical I2 execution**. At pinned `pkg-catalog/pkg-schema-v2@ae3e2011462be46c0326179f2117b81b85e5df5e`, [real Java V1 run 42085304112](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42085304112) **completed 2/2 success**: hosted Ubuntu job `127448677067` and hosted macOS ARM64 job `127448676953`; the latter's log explicitly reports `PASS 1 / FAIL 0 / ERROR 0` for `m-os/pkg-java-v1/java-provider-and-maven.test`. This is authentic installed Java/Temurin/Maven auxiliary acceptance for the event-pinned feature runtime and test revisions, **not** evidence for subsequently changed `m-os/master`, unpromoted full `context`, or physical reference-host certification.

The targeted [catalog v2 jq run 42036487502](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42036487502) **attempt 2 completed failure**, with the macOS job `127446872211` again encountering HTTP 403 at `https://api.github.com/repos/jqlang/jq/releases/tags/jq-1.8.2` on three bounded download attempts, before v2 jq program assertions. The other 13 matrix jobs are successful for their recorded pinned original attempt. This is a **repeatable acquisition obstruction on that macOS runner**, not a proved semantic product regression and **not a PASS**. Avoid unlimited retries or an unvalidated workaround; V1 owns diagnosis and any bounded corrective CI/catalog approach. The [real published v2 mk/jsc run 42087769769](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42087769769) remains Ubuntu success, macOS queued, at `pkg-catalog/pkg-schema-v2@ed599dcd09a286eb3e0d21b4cc8f04adaada556c`.

P2 is **source-staged but unvalidated**, not absent: `m-os/m-os-completion-p2@f74ecbabe552fc9e2284c26caea5f5dd4cbb1a3f`, [draft PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3), includes same-batch dependency/root overlap handling, genuine published-artifact assertions and manuals; `m-os/master@29fa1358d2056b624f5ec0d48d8fd6262eddedf4` has not integrated it. The P2 branch still has no observable GitHub Actions run; the prior I1 source-review concern regarding installed-root re-resolution through `pkg_catalog_request_resolve` requires actual examination by the shared pkg owner. Parallel R1 `m-rsudo/main@a7248612773cdbd8d9cb9781915065fba5f0cc4c` added real-source injection workflows ([run 42089426209](https://github.com/massimilianonardi-ai/m-rsudo/actions/runs/42089426209) queued), without changing the immutable `v0.1.0` release; S and C1 workflows also lack verified behavioral PASS. P3/P4, full `context`, standalone `json`, complete M01–M15 replay and controlled reference hosts remain gated. No source, catalog, release, frozen suite or host deployment was changed by I in this checkpoint. Direct network access from the auxiliary Linux container still cannot resolve GitHub, so no local runtime run can honestly be claimed.

### Branch I — genuine host CI progress and exact-source P2 run (2026-11-05)

**I1 is still BLOCKED and I2 PENDING**; this is a scoped upstream-evidence checkpoint, not a combined acceptance/physical run. Genuine public-path test results now include: V1 [published v2 `mk/jsc` run 42087769769](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42087769769) **Ubuntu/macOS 2/2 PASS** with real `rumiai-test` 1/1 on each at pinned `pkg-catalog@ed599dcd`, `m-os/pkg-schema-v2@1e3a038a`, `rumiai-tests/pkg-v2-mk-jsc-validation@c7a8b213`; [Java/Temurin/Maven run 42085304112](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42085304112) **2/2 PASS** at its own revision; C1 [run 42090408793](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42090408793) genuine installed first-party context **2/2 PASS**; S1 [run 42091997203](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42091997203) offline and real provider service **3/3 PASS**; S2 [run 42092734957](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42092734957) user-host Ubuntu **PASS**, macOS queued; R1 [source-injection run 42089426209](https://github.com/massimilianonardi-ai/m-rsudo/actions/runs/42089426209) **2/2 PASS**, but not an installed release or SSH/sudo proof. V1 jq retry attempt 2 remains an upstream macOS HTTP 403 acquisition failure before jq assertions, while an earlier exact-revision jq functional PASS is independently recorded in the owning V1 handoff. No result here promotes generalized C2/C3 or supersedes the owning evidence ledgers.

To unblock a real P2 check without changing the independently owned `pkg` runtime or PR branch, I created **CI-only** `pkg-catalog/m-os-completion-p2-ci@2894eaa483eeb32132c59cd09ebd767d8659a2c7` with one workflow that checks out `m-os/m-os-completion-p2@f74ecbabe552fc9e2284c26caea5f5dd4cbb1a3f` and executes its unchanged original `m-pkg-p2-public.yml` public shell script on hosted Ubuntu/macOS. [Run 42094006865](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094006865) Ubuntu job `127479173970` is **PASS** (raw log confirms genuine Node.js, mk/jsc, requested-root/dependency overlap, repeated installed root and corrupt-symlink rejection); macOS job `127479174626` was **QUEUED** on last inspection. Evidence and outstanding installed-historical-root/provided-ambiguity/cleanup review have been surfaced in the P2 owning handoff and PR #3. Do not claim P2 cross-platform/full acceptance, merge or release shared write ownership yet.

Fresh preflight observed autonomous `m-os/master@4f4fcb58b7278a20f7b032ed4812152d2f49106b` still lacks P2 integration (only independent TLS workflow movement since earlier I review). Standalone J1 `json`, general context C2/C3, P3/P4/V2 promotion, remaining M01–M15 acceptance and controlled I2 physical environments are outstanding. No product runtime, release, catalog definition, frozen test/legacy code or reference host was changed by this I work.

### Branch I — acceptance gate reconciliation at current P2/V2/release revisions (2026-11-05)

This is a **read-only coordination checkpoint, not an I1 integrated PASS**. Current `m-os/master@1f8880c78febf390596faa9b6662ec8cab5c5e42` does **not** include unmerged P2, C1 or S source PRs. The now-current P2 [public hosted run 42098513609](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42098513609) at `m-os/m-os-completion-p2@0d3f877243af79e108cc19fda504a619cf57957b` is **COMPLETED 2/2 PASS** on Ubuntu `127494805820` and macOS `127494806453`; both raw logs end in the expected real Node.js/mk/jsc installer/overlap/repeat-root/store-rejection assertion. The earlier macOS [run 42094006865](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094006865) failed upstream Node GitHub API HTTP 403 before product assertions; do not confuse that acquisition failure with the newer successful exact P2 revision. Draft [P2 PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3) stays **unmerged** and has explicit pending negative coverage for provider ambiguity, failure cleanup and historical installed-root behavior, owned by its single writer.

The V2 catalog [matrix run 42094814482](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094814482), exact `pkg-catalog/pkg-schema-v2@a75f9be1c9a62a72899022eddf55e163d86ab630`, has **13/14 jobs successful**, only `v2-jq (macos-latest)` `127481972996` **QUEUED**; no full matrix PASS. Other exact-feature V1 Java/Maven and mk/jsc public runs have their already recorded separate 2/2 hosted PASS, which are not a combined post-promotion run. The C1 exact-package public test has real Ubuntu/macOS PASS but [PR #2](https://github.com/massimilianonardi-ai/m-os/pull/2) is draft and C2/C3 grammar/authorization/storage/propagation remain unpromoted.

The first-party `m-core`, `m-term` and `m-rsudo` immutable **`v0.1.1` releases now exist**, with real archives and `SHA256SUMS`. The [m-rsudo installed v0.1.1 public run 42096124385](https://github.com/massimilianonardi-ai/m-rsudo/actions/runs/42096124385) has **Ubuntu PASS** (`127486491314`), but macOS **FAIL during m-core release metadata download (HTTP 403)** (`127486491826`) before installed-path behavior. Do not claim released-source cross-host PASS or remote SSH/sudo acceptance from a successful source-injection CI job. S1 portable service evidence and S2 unprivileged user-host Ubuntu work progressed under the validation owner; macOS/native supervisor and protected host-system paths remain separately gated.

**Outstanding integration-entry conditions:** P2 negative acceptance and forward-only merge; P3/P4 provider maps and uninstall/default evidence; coordinated V2 promotion with current-source tests; J1 standalone POSIX `bin/sys/json` and its manual (still **absent** on inspected `m-os/master` and `pkg-schema-v2`); C2/C3 contract decisions and implementation; R1 released source/installed-path coherence; and remaining M01–M15 current-revision evidence. I1 **BLOCKED**, I2 **PENDING** until actual integrated acceptance and authorized reference hosts. `rumiai-os` and `rumiai-tests/main` were not modified or executed by this coordination review.

### Branch I — cross-workstream entry-gate reconciliation (2026-11-06)

**I1 stays BLOCKED; I2 stays PENDING.** On fresh remote preflight, `m-os/master@1f8880c78febf390596faa9b6662ec8cab5c5e42` still exposes 16 `bin/sys` commands but lacks the separately specified POSIX `bin/sys/json` and its command manual. Its current `pkg install` still uses the pre-P2 public dependency planner. [P2 PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3), [C1 PR #2](https://github.com/massimilianonardi-ai/m-os/pull/2), and [S PR #4](https://github.com/massimilianonardi-ai/m-os/pull/4) remain draft/unmerged; an auxiliary branch PASS does not substitute for integrated master acceptance.

**Evidence newly closed after the prior I checkpoint:** [V2 catalog matrix 42094814482](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094814482) is **completed SUCCESS 14/14**, exact `pkg-catalog/pkg-schema-v2@a75f9be1c9a62a72899022eddf55e163d86ab630`. The formerly queued macOS v2-jq job `127481972996` has log-confirmed **real public jq install and command/context PASS** at the run's pinned older `m-os` runtime; no new mainline promotion is implied. For S1, [42113668108](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42113668108) is **3/3 PASS** including macOS offline process-safety. For S2, [42114372442](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42114372442) is **2/2 PASS** for genuine Ubuntu/macOS user-supervisor operations with an isolated *local integrated provider*, and [42116611051](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42116611051) is **2/2 PASS** including macOS 15 Intel checks that the native restart/stop actually terminates the previous service PID. These are deliberately **not** published-release installation, privileged system-host, or operator reference-host PASS.

**Separately unresolved:** [C1 published version-replacement attempt 2, run 42095853638](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42095853638), **Ubuntu PASS / macOS FAIL** before version-switch assertions due upstream GitHub API HTTP 403 retrieving `m-core@v0.1.0`; [R1 v0.1.1 installed run 42096124385](https://github.com/massimilianonardi-ai/m-rsudo/actions/runs/42096124385) has Ubuntu PASS / macOS same-class release acquisition HTTP 403 before behavior. P2 retains provider ambiguity, cleanup and installed-historical-root negatives despite genuine [2/2 public smoke](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42098513609); P3/P4, C2/C3 normative decisions/real implementation, J1, V2 forward integration and a pinned full M01–M15 execution still gate I1. Original V1/V2 upstream acquisition failures and later successful scoped jobs must remain separate revision-specific records. All findings were based on read-only source/CI inspection; no runtime, catalog definition, first-party release, frozen suite, privileged host or physical reference machine was modified/executed by I.

### Branch I — released v0.1.1 two-host closure and pre-integration readiness review (2026-11-06)

**I1 remains BLOCKED, I2 PENDING**, but the R1 **published first-party package installation + selected source-consumer path** is no longer merely Ubuntu-only evidence. Actual [m-rsudo run 42097660573](https://github.com/massimilianonardi-ai/m-rsudo/actions/runs/42097660573) **COMPLETED PASS 2/2**: hosted Ubuntu `127491838515` and macOS ARM64 `127491839390`; both raw logs demonstrate `./m pkg install` of released `m-core/m-term/m-rsudo@v0.1.1` followed by shipped `context`, native command/error-path, `rssh` shell-extension and clean-child in-memory menu source checks. Exact workflow uses `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd` and exact catalog `pkg-schema-v2@a75f9be1c9a62a72899022eddf55e163d86ab630`; this is **not** the current merged `m-os/master` integration target or operator physical-host proof. Release-to-current-main comparisons for the three first-party projects found only README or CI/test additions after immutable `v0.1.1` tags, not modified shipped runtime files. The owning `handoff/rumiai-os-source-composition.md` and its stale queued next action were reconciled forward at `rumiai-dev@b0cf967b06b48f4087567ce6f77e1ca9b2ef7532`.

At the current exact feature revisions, the independently verified milestones available to I1 include **P2 published install smoke 2/2**, **V1/V2 catalog matrix 14/14**, **R1 v0.1.1 published install/selected consumers 2/2**, and **S1/S2 exact-source hosted matrix 5/5** ([run 42192103307](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42192103307), `m-os/m-os-completion-s@433f341351ab8240563189229b0b3dd0ea2dda1e`, including actual macOS portable `srv start/stop -f` and unprivileged `launchd`). They are **not one integrated version set**; S2 macOS local integrated provider does not prove public Electron acquisition or privileged host-system service. C1 exact-package public tests have separate scoped 2/2 PASS, while genuine macOS v0.1.0→v0.1.1 replacement remains **NOT TESTED after upstream GitHub HTTP 403**, distinct from R1's successful direct v0.1.1 installation.

**Remaining ordered critical path:** P2 owner closes ambiguity/cleanup/historical installed-root acceptance, then forward-integrates its draft PR; shared `pkg` owner completes P3/P4 provider/uninstall/facility map validation; V2 owner forward-integrates catalog and runtime coherently and validates actual merged revisions. Separately, C2/C3 requires promoted full-context contract and implementation, J1 still needs standalone POSIX `bin/sys/json` plus manual on autonomous `m-os`, and S/R host-privileged work needs controlled authorization. Only after the applicable product/release set is coherent does I1 freeze revisions for the owning M01–M15 acceptance ledger, with actual missing scenarios preserved as PENDING. I2 still requires passing I1 and controlled reference hosts. No I-owned product source, catalog/release, frozen suite or physical host changed in this checkpoint.

### Branch I — P2 extended negatives and V2 catalog reconciliation boundary (2026-11-06)

**I1 still BLOCKED; I2 PENDING.** In the existing P2 single-writer lane, [run 42193302580](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42193302580) has authentic hosted **Ubuntu + macOS 2/2 PASS** at pinned `m-os/P2@0d3f877243af79e108cc19fda504a619cf57957b` with the new tests: real public `pkg depend` and `pkg install` return provider-ambiguous at both hosts, an installed historic unlisted concrete returns already-installed without rediscovery, malformed dependency planning fails without creating the new requested root and leaves no invocation staging directory. **The ambiguity candidate directories and historical installed root are deliberately test-created fixtures** inside the real installed `m` store: this is authentic public-path *negative planner* evidence, not proof of genuine remote publication for those synthetic providers. The newer `m-os/m-os-completion-p2@573ac82e466c5d452ccb30b9b4475b75769c638d` adds a real `pkg_download` HTTP wrong-digest negative/partial-output cleanup test and associated workflow only, not another product runtime change. Its [run 42194425875](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42194425875) is now **COMPLETED SUCCESS 2/2**: Ubuntu job `127814008166` and macOS job `127814008817`, both checked out exact source `573ac82e...` and reached the three P2 real-public PASS assertions, including actual `pkg_download` HTTP `digest-mismatch` rejection and staged-byte cleanup. This is **not** full-public-install artifact failure recovery or genuine GeoServer integration. The P2 owner retains the still-missing full-public-install artifact failure/recovery and genuine GeoServer dependency acceptance, with no implicit transactional rollback requirement beyond canonical `PACKAGE-MODEL.md`. [Draft PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3) is still open and unmerged.

**Forward-only integration audit:** the current `m-os/master@1f8880c78febf390596faa9b6662ec8cab5c5e42` still uses its old multi-request `pkg install` planner and lacks standalone `bin/sys/json` plus manual; the P2, C1 and S PRs remain draft despite GitHub reporting them mergeable individually. P2 and V2 both change `lib/sys/sh/pkg/pkg-install.lib.sh` and its manual, so the future integrator must reconcile semantics and test the combined product rather than select one version of these files blindly. `pkg-catalog/main@4083aa19c4362f00ec62428a631edfa493faf7f0` now has v1 `keycloak` index `26.8.2` and v1 `ollama` index `v0.40.15`, while current `pkg-schema-v2@a75f9be1c9a62a72899022eddf55e163d86ab630` stops at `26.8.1` and `v0.40.14`; the catalog's V2 owning handoff records the needed preservation. These are **concrete merge-preparation inputs**, not acceptance, merge authorization, or a signal to modify shared product code from I. The M01–M15 matrix still contains pending current-integration, standalone J1, C2/C3 and host-gated scenarios; no unified I1 target is yet valid.

### Branch I — P2 accepted on merged master and P3/P4 writer gate opened (2026-11-06)

P2 [PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3) merged forward to `m-os/master@a08f4730323be108893b9a3327e63a36711f0158`, and the exact post-merge [CI run 42197729661](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42197729661) **COMPLETED SUCCESS 2/2**. Both raw Ubuntu `127825079265` and macOS ARM64 `127825079636` logs explicitly show checked-out `a08f473` and four terminal PASS groups: genuine public Node/mk/jsc dependency-first/exact-root install; public ambiguous provider, historical installed-root and planning cleanup; real HTTP corrupt digest staging cleanup; and public `pkg install` failing closed on a controlled corrupt HTTPS artifact with no partially published concrete/stale install staging. Earlier branch-head PASS and the merged revision PASS are separately recorded; neither substitutes for a full product/physical run. The P2 owning handoff [accepted the bounded merged work unit and released the single shared `pkg` writer](https://github.com/massimilianonardi-ai/rumiai-dev/commit/4f3e63323806b369fd324d0a4e12eef38c604612) for **serialized P3/P4** implementation. The GeoServer adapter/install work and current evidence are separately owned by `handoff/geoserver-repository-adapter.md`; the controlled artifact regression did not fake a GeoServer success.

**Immediate integration consequence:** P3's real `pkg provider`/versions/default/uninstall negative and multiple-provider matrix plus P4's derived installed-facility map may now advance under their existing validation and source-composition owners. All fixes must build from merged master and preserve P2's exact-root-one-snapshot, statuses, diagnostics, installed-concrete invariants; P4 and P3 share the `pkg` integrator serially. V2's existing feature `pkg-install.lib.sh` (old public `pkg depend` and original roots) and manual **cannot simply overwrite** merged P2 `pkg-install.lib.sh` (single snapshot, `pkg_depend_plan`, exact-root contexts, pre-existing-root distinction). These exact source revisions were both read; forward reconciliation and new real integrated tests remain required after P3/P4. Also preserve concurrent newer v1 Keycloak/Ollama indices from `pkg-catalog/main`.

**I1 stays BLOCKED; I2 PENDING.** There is still no coherent promoted P3/P4+V2+C2/C3+standalone J1 product revision, and the M01–M15 owner has not issued a complete exact-revision acceptance run. S1/S2 and R1 published package positive evidence remains separate hosted work; privileged/reference-host permissions remain gated. No I-owned production code, frozen legacy tests or physical host was modified or executed. An additional I-side temporary P3 CI branch could not be created because the available GitHub branch-creation action was blocked; therefore **no new I-side P3 workflow run or PASS is claimed**.

## Next action

1. Continue ready nonprivileged M01–M15 work using exact revisions; treat run 42891477651 as scoped candidate evidence, not a full-suite substitute. Keep hosted A1–A4 workflows deferred.
2. Revalidate `srv host user` against the persistent-supervisor candidate only if the test-owned manager state stays within `/m/src/git/chatgpt`; otherwise keep that host row pending and advance independent gaps.
3. Complete I1 when every applicable M01–M15 row has exact evidence or an explicit excluded/deferred owner. Proceed to nonprivileged I2 when ordinary authorized reference-host access is available.


## Blockers / open questions

- C3 and SRV-42 decisions are settled and candidate implementations have exact/integrated hosted evidence. Final candidate review/integration, distribution packaging and full M01–M15/I1 remain open; M13 host-user integration needs current-source revalidation.
- Hosted A1–A4 workflows remain explicitly deferred. Local replays do not replace them.
- Nonprivileged I2 awaits ordinary authorized reference-host access. Privileged host-system services, remote SSH/sudo and protected-host CA administration remain in the operator TODO, outside this task.
- `rumiai-os` and `rumiai-tests` remain frozen and untouched.
