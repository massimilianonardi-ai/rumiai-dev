# RumiAI OS source composition comparison

Status: Active
Updated: 2026-11-02

## Goal

Extract an autonomous, minimal technical source foundation, provisionally named
`m-core` by the user, containing the `m` bootstrap, `pkg`, and the foundational technical commands,
libraries and resources required for their runtime operation and shared
substrate responsibilities (including the technical manual interface,
localization selection, managed additional TLS trust and portable services). Keep the
existing independent `pkg-catalog` as the essential external catalog source.
Treat `mk` as an important but non-core, separately sourced and `pkg`-installable
development tool, whose Node.js runtime is provided through `pkg`, never required
from a clean POSIX host.

Compose downstream `rumiai-os` distributions from that technical foundation
and other optional projects. The earlier independent POSIX vs host-Node `mk`
composition experiments remain experimental evidence, not two parallel target
product architectures. The independent `m` source and separately distributed
`m-mk` package are now published and verified on hosted Ubuntu/macOS;
downstream `rumiai-os` composition and permanent-suite migration remain pending.

Full functional validation of the autonomous `m` source is independently tracked in `handoff/m-autonomous-validation.md`, including `pkg` provider/dependency/uninstall, positive `srv` lifecycle, host supervision and all other technical commands. Partial `mk`/`jsc` PASS here does **not** close that workstream.

## Current repository revisions

Repository identity checkpoint (2026-11-03): the GitHub source repository
formerly `massimilianonardi-ai/m` is now
`massimilianonardi-ai/m-os`. The GitHub rename retained `master` and
`pkg-schema-v2`, whose verified HEADs were
`ff55fc9f220f8da3f1f90d1bf4aa2e46c55a5d2a` and
`8c8397dbcf1df44822553aebd1891ab6db880945` respectively.
The technical `m` layer and runtime command retain their names. The
pre-rename `m/master` and `massimilianonardi-ai/m` strings in historical
physical/CI evidence below denote that same repository at its old URL,
not a current second repository. Future source retrieval must target
`m-os` and verify its current remote HEAD.

- 2026-11-02 library-view PoC and correction: `rumiai-dev-PoCs/main` verified at `b87cf52982c1c27cd149caabb7c3339c6791ae12`; `m/master` verified at `28b170feb7e28e0d3ae023b01ef04a8cceeebbc6`; `pkg-catalog/main` verified at `acdcd66a60c06f368c8e313f850b86d76f4bf1ae` before the experiment; during final consistency recheck pkg-catalog/main had advanced to `17a08adc0bb5bf708d3357d1f5e70d5110cdc9cc`. Its current top-level pkg/facility namespaces were reread, and no catalog files were edited in this task. Refresh all HEADs on resumption.

Last verified on 2026-10-24:

- `rumiai-dev/main` pre-change: `69d4b4467fe35980667e3ea9234c50ab639209a8`; subsequent canonical package-policy alignment commit `2a5e83eadcdc2ff64024aa5af6c2eeef7bed331b`; this handoff commit follows.
- `rumiai-os/main`: `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`.
- `pkg-catalog/main`: `707ca9aee61f16270da222d8873e4e96a659ab5a`.
- `rumiai-tests/main`: `7bd33837210850cee26acaf02d78f873eab884e0`.
- `rumiai-dev-PoCs/main`: `c65bcf0306e88daaf3061962bafd750372751881`.
- `m/master` source extraction baseline: `b05bb649400c35314e97a3d0876f5413c8145aba`; current integrated checkout `809f4d63173c32ecede0cd6bb183da6fc6ab8fa9`. New commits added the technical core without rewriting earlier history. Source implementation and pre-existing operational manuals were copied from `rumiai-os/main` `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`.
- Original PoC 072 experiment branch: `rumiai-dev-PoCs/rumiai-os-composition-comparison`, last verified experiment commit `0c8f8fa098e5c74d8e2e15c6552a9c633a383048`; engine snapshot intentionally pinned there.

- 2026-11-02 `m/master`: initial context implementation now includes `28b170feb7e28e0d3ae023b01ef04a8cceeebbc6` (refresh before resumption); `rumiai-dev/main`: initial context contract commit `4f4d1a4f7d7f2fe2804ada8015fade7093c8592b`, with subsequent handoff update following. `pkg-catalog/main` verified at `acdcd66a60c06f368c8e313f850b86d76f4bf1ae` and not modified.

Refresh remote HEADs before resuming. These SHAs are checkpoints only, not authority.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `handoff/README.md`.
- `specifications/README.md`; `specifications/rumiai-os/{CURRENT-MODEL,MK,BOOTSTRAP-ENVIRONMENT,ENTRYPOINT-ROOT-RESOLUTION,COMMAND-ENTRYPOINTS,LANG-BOOTSTRAP,STATE-MODEL,RESOURCE-MODEL}.md`.
- `handoff/javascript-command-bootstrap.md` for the separate active native interpreter migration.
- Current `rumiai-os/lib/sys/js/mk.lib.js`, `bin/sys/mk` and `rumiai-tests/tests/rumiai-os/mk/lifecycle.test` as factual implementation/test evidence.

## Fixed task-local choices

- **User correction (2026-11-02):** package `cmd/` is the command launcher/entrypoint surface, not an upstream `bin/` directory. A command may need environment preparation and fixed launch options; `link/` maps it to the packaged executable. Published PATH symlink groups must continue to expose the command wrapper. The distinction is now explicit in the current `PACKAGE-MODEL.md` launch contract. No `cmd/` to `bin/` migration is intended.

- **User authorization and first implementation (2026-11-02):** user explicitly authorized proceeding with the initial `context` implementation in autonomous `m`. The current first implementation intentionally supports only POSIX shell-local exact installed package `cmd/` PATH selections (`context` and repeated `pkg=<concrete>` operands), using pre-existing directories without context-time filesystem publication. This supersedes prior design-phase non-authorization for the limited `m` work unit; it does not lift the explicit freezes on `rumiai-os` or `rumiai-tests` and does not approve unimplemented facility/profile/policy grammar as if it were live.

- **User correction / revised working direction (2026-10-29):** favor a stable core **`sys` bootstrap directory** (rather than introducing an `m-sys` package solely to break bootstrap circularity), and favor **pre-existing, reusable `bin` directories composed only through ordered `PATH` changes by `context`**. Install/default/configuration operations, *not every invocation of `context`*, own symlink publication and update. In particular, existing per-concrete package command directories and a maintained default command view can be reused, with provider/version-specific directories prepended as overrides. Reassess the earlier recommendation to generate a complete immutable `bin` for every effective context: the user identifies that dynamic construction/refresh as avoidable and impractical. A dangling symlink in an earlier `PATH` directory is NOT a deletion/mask: POSIX shell testing found fallback to a later executable; decide whether negative selection is needed before implementing any masking layer. No runtime change authorized in this design phase.

- **Explicit user proposal adopted as active design direction (2026-10-29):** apply context selection operands **strictly left-to-right in command-line order**, with later choices overriding earlier choices for the same logical binding. Expand `full-context` presets inline at their operand position, without fixed precedence among `full-context`, `user`, `pkg`, `profile`, provider or other selection sources. This is an ordered composition of *selection intent*, not sequential mutation of shell environment. Perform complete compatibility/ownership/permission/protected-inheritance validation after composition and before activation. Protected bindings are not silently overrideable by ordinary later operands; an authorized explicit policy change or deterministic rejection is required. Operand grammar, masks/removals and policy syntax remain open.

- **User-confirmed expansion (2026-10-29):** approve automatic managed-shell initialization with plain `context` (A), override-only re-selection of desired dimensions (B), and one generalized context function reused by package/service/child consumers (C). Include **named complete-context presets as a composition input** to the same per-dimension engine, not a separate context type; `context full-context=my_full_profile` is the user's *example syntax*, not yet a finalized public grammar. Adopt an **environment-first and context-derived executable namespace** design direction: eliminate fixed `$m_ROOT/bin` as the long-lived globally authoritative command tree, generating reusable command symlink `bin` views for selected package concrete/provider choices. Plain `context` selects a default command view, whereas contexts with version/provider pins can compose matching override views through PATH precedence. This is a conceptual redesign for the next implementation, not an immediate change to current bootstrapping, package identity or canonical specifications. The exact view organization, update policy and ordering remain subject to pragmatic validation.

- **User-confirmed conceptual decisions (2026-10-28):** (1) one coherent kind of active `context` per shell regardless of entrypoint/initialization; (2) system and user scopes are **composable orthogonal domains**, not exclusive mode choices; (3) the consumer has a determinable identity, inferred from a trusted entrypoint when reliable and supplied explicitly otherwise; (4) **defaults are selected per dimension**, not as one undifferentiated `default` context; (5) profile/user and concrete identity are **resolved context selections**, not identities implicitly defined by mutable `current` symlinks (elimination of the latter remains the migration direction); (6) activation **replaces** the existing shell context, without restore/pop/stack. The agreement fixes these *conceptual decisions* for further design, not CLI syntax, configuration format, new profile-user feature, precedence details, or a currently implemented contract.
- **Explicit user decisions (2026-10-26):** the public function is named `context` and is a **POSIX sh function**, because it must be able to modify the current shell's environment. Its role is the general composition and activation of a resolved runtime context, including executables as well as libraries/resources; ordinary shell `PATH` lookup is one optimized consumption mechanism. The new architecture/implementation should be designed cleanly from first principles. Existing `pkg`, facility/provider and launcher code and even their present contracts are **inspiration and evidence, not design constraints**: during conceptual design, deliberately explore better semantics even when they would supersede the current architecture. Only after defining the best intended behavior should the team evaluate global practical tradeoffs, migration, compatibility, implementation complexity, robustness and performance. This design freedom is not authorization to modify the current runtime or silently replace current canonical contracts.
- **Explicit user simplification (2026-10-26):** one active `context` per shell, surviving until another context **replaces** it or the shell exits; **no context restore/pop/activation stack**. The user also proposes removing the many filesystem `current` selectors. Treat their elimination as the **desired architecture**, pending a clean replacement for persistent defaults and an explicit impact/migration assessment; do not infer that independent fresh shells no longer need persistent default-selection configuration. Neither change has yet been implemented or promoted into the existing filesystem/state/resource contracts.
- **Explicit user requirement (2026-10-26):** `context` must compose its effective shell/environment state from **explicit context parameters AND declared inheritance/propagation policies**. Values designated for preservation must not be silently overwritten by intermediate package, provider or nested-launch environment setup. The motivating real operational case is central Chromium certificate trust: effective browser `HOME` (and any deliberately propagated variables) must remain coherent with the trusted NSS certificate projection across nested execution. This is a semantic design requirement, not an endorsement of the existing launcher override API as the future `context` interface.
- **Explicit user choice (2026-10-26):** package-owned operational manuals and localization catalogs MUST ship in the same versioned artifact as their owning software; standalone doc/lang packages, including a shared package for one major release family, are categorically excluded. Common source content can still be reused when building releases, but each concrete package distributes its own matching copy. This distribution contract is recorded in `RESOURCE-MODEL.md`; it does not predetermine global/consumer-private resource exposure.

- **User-agreed design direction (2026-10-26, not yet a promoted implementation contract):** one package-owned semantic composition/dependency/provider model, with three distinct visibility/materialization scopes: **global**, **consumer-contextual**, and **package-private**. Physical projection may differ by resource class (existing command symlinks/launchers, existing typed facility/provider resolution and environment, or direct package-local access). Do not impose a universal symlink graph or a parallel dependency resolver by convenience; the unresolved implementation choices must be tested before specification promotion.

- **Explicit user hold (2026-10-26):** Do not modify `rumiai-os` at all until the user explicitly authorizes that repository. It is available only as an unchanged factual/source reference for extraction. Do not modify `rumiai-tests` at all until the user explicitly reopens its heavily questioned design; do not schedule, write, migrate or run that repository's tests as a prerequisite to extracting other independent packages. This instruction supersedes earlier next-action suggestions to change those repositories. Use proportionate, real, package-local validation in an authorized independent source/PoC repository instead.

- Keep `m`, `pkg`, their real prerequisite core facilities, and the user-selected fundamental shared capabilities together in one self-contained `m-core` source project; this source/release arrangement is the intended direction, not yet the published/current runtime layout.
- The clean-host prerequisite boundary must not include Node.js, `mk`, or an already installed RumiAI OS. `m` initializes and `pkg` operates without any of them.
- Keep `pkg-catalog` in its already independent repository as the essential catalog authority consumed by `pkg` operations; ordinary `m` bootstrap must not require catalog/provider resolution or network access.
- Separate `mk` source from `m-core`; package/install it via `pkg`, declaring the existing Node.js facility dependency through `pkg-catalog`. `mk` retains its technical `m` semantic ownership and build-orchestrator responsibilities, but no longer belongs to the minimal distribution.
- Treat `mk` as source-distributed JavaScript requiring no compilation; all of its implementation files, including any multiple JS modules, MUST stay beneath the package's own materialized `root/` (for example `root/bin/mk` and `root/lib/mk.lib.js`). Do not place `mk` implementation libraries in the system `m` library tree. A POSIX source copy/archive packaging step is sufficient; the normal package launcher and dependency integration remain `pkg` responsibilities.
- The core command inventory explicitly includes `pkg`, `osarch`, `state-path`, `http-fetch`, `digest`, `extract`, `log`, `lang`, `shell`, `manual`, `pager`, `lang-set`, `tls-ca`, `tls-nss-sync`, and `srv`, alongside the root `m` bootstrap and its `bin/sys/m` exposure. `pager` is required to preserve normal `manual` presentation (not only `manual --no-pager`).
- `srv` stays inside the foundation because it builds directly on existing `pkg` facility/provider/dependency and `state-path` contracts; it must not introduce an alternate resolver or bootstrap-time service supervisor. The `tls-ca` authority and `tls-nss-sync` projection remain technical `m` facilities, including their current package-launch integration, without making host-specific tools or systemd/launchd unconditional bootstrap prerequisites. `lang-set` remains owner-generic and must not introduce a dependency on the branded `ai` layer.
- Higher-level commands, libraries and resources outside the accepted foundational inventory and its real dependency closure move to other projects, preserving original runtime identities/interfaces until a separately authorized contract change.
- Existing PoC 072 tests of standalone `mk` under host Node remain historical experimental evidence; making host Node a production bootstrap requirement is rejected. Preserve the PoC unchanged unless a new evidence question requires extending it.
- Keep package management/provider resolution owned by `pkg`; no alternate build engine or package manager is needed to bootstrap `m-core`.
- Do not migrate production hosts or change `rumiai-os` runtime code solely from the architectural discussion. Align canonical specifications as the intended source arrangement becomes actual implemented/published behavior.

## Acceptance scenarios

1. A clean POSIX host without Node.js or `mk` checks out `m-core` and can execute `m`, resolve technical roots, and use `pkg` (given the documented host utilities and a reachable selected catalog when an installation needs it).
2. `m-core` bootstrap works when the package catalog cannot be reached; any network/catalog requirement arises only from a requested package operation.
3. A `pkg-catalog` descriptor for `mk` declares its Node.js runtime dependency. `pkg install mk` can plan, obtain, integrate and resolve compatible provider concretes, with normal ambiguity and failure behavior; it does not require a preinstalled host Node.js.
4. The installed `mk` runs using its managed provider and can orchestrate downstream projects without entering the `m-core` bootstrap dependency closure.
5. Root layout, manual/resource ownership, existing consumer interfaces and established `m`/RumiAI layer boundaries remain compatible after extraction.
6. Install two packages that realize the same facility compatibility level: the derived `facility/<name>/<revision>/<osarch>/` map exposes both installed concrete versions without replacing one provider or duplicating commands; removing one unreferenced concrete updates membership.
7. For a single provider with multiple installed versions, `provider@latest` follows the newest version still realizing that exact facility revision, including after installing a newer incompatible package release and after uninstalling a version; no cross-provider `latest` is created.
8. Configure a pinned `default`, then a policy-driven default following that provider's compatible `@latest`; a separate provider cannot silently take over. Independent context/consumer bindings retain their own selected concrete and coherent commands/environment.
9. Reinstall, upgrade and remove providers while protecting referenced concretes: missing or ambiguous selections are reported rather than resolved by a guessed version order, dangling symlink or unrelated global PATH fallback.

Scenarios 1 and 2 have initial direct-checkout smoke evidence on Ubuntu and macOS for bootstrap, platform setup, command dispatch, manuals, localization and offline operations. Real `pkg install nodejs@v26.8.2` and managed-node invocation passed on both hosts in GitHub Actions run `40088928262`. The real independent `m-mk@v0.1.0` release and the public `pkg install mk@v0.1.0` normal path passed on hosted Ubuntu and macOS (see checkpoint below). Full downstream-consumer and permanent-suite migration remains pending; PoC 072 reduced-fixture evidence does not validate it.

## Completed

- Added `rumiai-dev-PoCs/pocs/072-rumiai-os-composition` with three independent **local Git repositories generated from deliberately reduced fixtures** (`m`, `pkg`, `lang`), a standalone `build-posix.sh`, independent `mk.json` lifecycle, tests and hosted workflow.
- The builders clone all three repositories, check out the exact same SHAs, concatenate component-owned bootstrap fragments, install commands/resources and publish the tree. Tests compare tree content/modes/symlink identities and execute the resulting bootstrap.
- Real `mk.lib.js` from the pinned `rumiai-os` revision is run directly through host Node.js. No `m` launcher or managed Node installation is used.
- First hosted green run: GitHub Actions `39964211916`, PoC SHA `822555748e052dc6aad871e07046a60293fb21ae`; Ubuntu and macOS jobs passed.
- Expanded experimental tests to explicitly clear inherited `m` environment and reject missing source revisions. Green run `39964558371`, PoC SHA `ec09f5fd890342a1ddda7744d81026c6eafec5af`.
- Latest full branch revision `0c8f8fa098e5c74d8e2e15c6552a9c633a383048`: GitHub Actions run `39964601629` **PASS on Ubuntu and macOS**; includes the failure-path checks and cross-host fixes.
- Early macOS failures revealed actual portability issues in the experiment: BSD `diff -r` traversed a relative locale selector to report a directory loop; physical `/var` path resolution differs from logical temporary paths. Both checks were corrected. Earlier failed runs remain failed evidence, not PASS.
- Added PoC 073 on `rumiai-dev-PoCs/mk-package-local-runtime` branch: initial commit `6325990d26feb5632ada2eced70aa2d5489ddf1a`, extended revision `596feac910aced4fbd5db3bbd5a27f1e34d8fcd5`. The latter carries an isolated copy of the real current `mk.lib.js` with only the two `--watch` child-command references redirected to the package-local `cmd/mk`; POSIX archive packaging; a real package range fixture with `nodejs =26`, `cmd/mk`, and `link/mk`; and a full script using actual `pkg_integrate`/`pkg_default_apply` on an isolated real `rumiai-os` checkout where the old system mk executable/library have been removed.
- PoC 073 GitHub Actions run `40081595096`, initial SHA `6325990d`, **Ubuntu PASS**; extended run `40081898644`, SHA `596feac`, **Ubuntu PASS** including source-based package execution, real managed Node.js installation through `pkg`, `--goals`, `--plan`, executable actions, and package-local `--watch` re-entry on changed input. Final comment-only correction `caecb010ce7996d6a16435bb40d078ae9e4d285d`, run `40082091552`, **Ubuntu PASS**. All macOS jobs were still queued when last inspected, not validated. No full published `pkg install mk` test has run because the release repository/asset does not yet exist. Do not relabel queued macOS jobs or a direct `pkg_integrate` scenario as a published package install.

## Current state

### Branch R activation and source correction (2026-11-05)

The operator authorized R1/R2 under `handoff/m-os-completion-orchestration.md`. R1 nonprivileged independent-package integration is owned here; R2 real SSH/sudo and remote-menu tests remain G-HOST-gated until access to an explicitly authorized controlled target exists.

At `m-rsudo/main@07017bfd4aa1809370ca30c4fe28bb0ab85021a6`, a two-file forward-only change corrected `bin/sys/rssh` to select a readable `rsudo.lib.sh` from the chosen `m-rsudo@*/link/lib/sh` PATH view and reject absent/ambiguous views; `res/sys/manual/rssh` was aligned. It changes no `m-os` shared pkg/context runtime, catalog, frozen repository, or immutable release. `m-rsudo/v0.1.0` still contains the previous source and must not be represented as fixed.

Exact source blob `2cfd7136bd2aa56708ee54fc1091d7ccd8c5857d` was checked with POSIX `sh -n` and an isolated, stubbed core/shell branch test (single/missing/ambiguous selected views), all PASS for those limited properties. Post-change source/manual diff was reviewed. No genuinely installed-package `rssh`, SSH transport, remote privilege execution, TTY session, CI run or physical host PASS is attributed to this correction.

Next R1 work: realign `rsudo-admin` Browse host's legacy global injected libraries and menu source against actual installed `m-core`/`m-term`/ `m-rsudo` views without inventing a second loader, and validate a real installed consumer/session before a new immutable release and catalog entry. R2 host/credentials/privileges remain PENDING explicit controlled authorization and authentic evidence.

### Branch C activation (2026-11-05)

The user authorized starting Branch C of
`handoff/m-os-completion-orchestration.md`. This existing source-composition
handoff owns C1/C2; orchestration coordinates dependencies. C1 source/evidence
audit and C2 contract analysis have begun. C3 remains blocked by the
unpromoted G-CONTEXT public contract and the P4 derived facility map / stable
pkg-v2 integration. No permission was inferred to modify or run the frozen
legacy `rumiai-os` and `rumiai-tests`.

**Source/evidence checkpoint.** Fresh HEADs:
`m-os/master@31693e814f682690adfd48185da822f7f5007f9e`;
`m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`;
`pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609`;
`pkg-catalog/pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7`.
First-party `m-core`, `m-term`, `m-rsudo` main HEADs match the prior
2026-11-05 composed-release checkpoint. `rumiai-tests/main` advanced
to `03616a323ef72efbfa172570d114530e6135d190`, but remains frozen.
The current `PACKAGE-MODEL.md` advanced concurrently and now reconciles
P1's upfront full-request validation and one-snapshot/exact-root policy;
that unrelated change was preserved.

**C1 findings.** Current `m-os/master` `context.lib.sh` + manual match
`BOOTSTRAP-ENVIRONMENT.md`: already-installed exact `pkg=`, ordered
replacement, PATH/CLASSPATH ownership/collision/atomic selection, and
no-argument reset. Feature v2 uses schema-aware `link/bin` and
`link/lib/{sh,java}`, not yet published on master. The existing
`context-libraries-test.sh` exercises real `pkg_integrate` and
POSIX/Java lookup over local test fixtures, not an authentic published
package. Previously recorded `m-core` run `42037725004` exercised
genuine three-package public install/shell consumers on Ubuntu/macOS
at pinned revisions, but not all C1 cases. Still to validate: authentic
Java-library consumer if available in the real catalog, negative and
replace/reset cases with installed real packages, and independent child
shell reinitialization. No new local/hosted/physical run was executed
during this checkpoint.

**C2 working design and blockers.** Settled task direction (not yet
public grammar): one POSIX shell context replaced until exit without a
stack; ordinary no-argument managed-shell defaults instead of present
reset; independent system/user dimensions and per-dimension defaults;
trusted or explicit consumer identity; left-to-right selections with
inline named presets; exact concrete cmd/lib/env consistency; protected
inherited values in cooperating nested consumers; pkg-created reusable
views without context-time symlink publication.

Material remaining contract decisions:
1. Precise operands/presets/removal grammar and migration of the
   existing no-argument reset.
2. Trusted per-dimension default and consumer/profile identity sources,
   state-selector migration and permissions.
3. Protected propagation/override policy, unset versus empty values,
   trust transfer through children, HOME and NSS projection.
4. Provider/facility versus ordinary-library consumer dependencies
   without duplicate authority or bypass of the package launcher.
5. Command-view exclusion/collision and atomic application; a higher
   PATH directory does not mask a lower directory's command by omission.

**Next Branch C action.** Produce normal/negative public acceptance
scenarios for C2, resolve only genuine high-impact ambiguities, promote
a coherent contract through the normal specification gate, and run
targeted real C1 checks without repeating already-PASS evidence. Recheck
P4/v2 readiness before C3. No product, catalog, release or permanent
suite modification was made at activation.

### Standalone POSIX `json` source-composition gap from archived m-os review (2026-11-05)

- The operator's archived `chats/m-os/2026-11-03 json posix command/index.html` explicitly asks for a robust, generally usable standalone JSON query tool with a jq-like bounded read-only CLI, suitable for future early `m`/`pkg` use before jq or Node.js is available. The current canonical `specifications/rumiai-os/JSON-QUERY.md` already assigns `bin/sys/json` to technical `m` with a defined POSIX standalone interface; this is **not** a new devplan-invented API or authorization to implement another JSON parser.
- Current source inspection: frozen legacy `rumiai-os/main@3611c62debd83b4e4bff4571b03d51eae3dc7067` contains `bin/sys/json` and `res/sys/manual/json`; current autonomous `m-os/master@31693e814f682690adfd48185da822f7f5007f9e` and `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd` lack `bin/sys/json`. They do contain the distinct existing `lib/sys/sh/json.lib.sh`, which must not be mislabeled as the standalone query command.
- This is a concrete **source/completeness mismatch** to classify and close under this extraction workstream against the current JSON, command/manual and testing contracts. A read-only source/manual/consumer inventory can run independently of unfinished full `context` semantics; any future product import/test/release requires its own normal authorization and proportional authentic proof. Preserve the legacy repository freeze. The APISIX and Keycloak archived chats are separately owned `rsudo` administration work, not missing bootstrap commands.

### Consolidated m-context / real-package status (2026-11-05)

**Scope and checkpoint.** This summarizes the active source-composition responsibility and the first implemented shell-local `context` phase, **not** the entire autonomous `m` validation program. Current inspected source heads: `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`, `pkg-catalog/pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7`, `m-core/main@0afb8752440808e9080a55c667576ff2f9b8eb32`, `m-term/main@c32aac18f6659ed4f569cb780080675fa64f9e3a`, and `m-rsudo/main@2763019ada5b1e33151f0c1e58b75af22ed6e99c`. The hosted composition test is pinned separately to `rumiai-tests/pkg-real-source-composition@a8db8cf5f681933d333e68f83e2d6220b62b32ea`. Refresh remote HEADs on resumption.

**Implemented / confirmed working:**

- Independent authentic `m-core`, `m-term`, and `m-rsudo` source projects are populated with real libraries, commands and operational manuals. Their three immutable `v0.1.0` GitHub release archives and SHA256SUMS are published; the v2 feature catalog provides real package descriptors and `link/bin` / `link/lib/sh` projections. There is no counterfeit producer or consumer package.
- The initial POSIX-shell `context` function is implemented in `m-os`: exact **already installed** `pkg=<concrete>` selections, left-to-right replacement of the same package, selected v2 `link/bin` + `link/lib/sh` via `PATH` and `link/lib/java` via `CLASSPATH`, rejection of ambiguous/invalid views, failure-before-activation checks, and no-argument reset. Those are implemented source/contract properties; do not claim that every edge case has been exercised by the specific published end-to-end smoke.
- **Hosted composed PASS:** actual public `m pkg install` from released artifacts, shell `context` selection of all three real packages, library projection, real `array` operations, actual `menu -Z` and `read-key unexpected` invalid-argument statuses, and `rsudo` argument/module-dispatch failure paths. GitHub Actions `m-core` run [42037725004](https://github.com/massimilianonardi-ai/m-core/actions/runs/42037725004): Ubuntu **PASS 1/1** and macOS **PASS 1/1**, using the exact pinned source/catalog/test revisions above. This test did **not** open a TTY menu or connect through SSH/sudo.
- **Operator-reported vmdev PASS:** the real interactive `menu` works. The user did not supply a raw terminal transcript or exact new local revision; record it as operator confirmation, **not** formal revision-coupled physical-reference evidence. Earlier vmdev `mk` goal execution and `jsc` compilation/import also reported PASS (with only an optional minifier warning); those are separate pilot properties, not proof of completed `context` or full `m`.

**Known source mismatches / not operationally ready:**

- On the originally inspected `m-rsudo/v0.1.0` release, `rssh` still selects the legacy global `$m_LIB_DIR/sys/sh/rsudo/rsudo.lib.sh`. The newer `m-rsudo/main@07017bfd4aa1809370ca30c4fe28bb0ab85021a6` source/manual resolves the selected package-local `link/lib/sh` view, but is unreleased and has not passed an installed-package interactive session. See Branch R checkpoint above.
- `m-rsudo/bin/sys/rsudo-admin` Browse host still injects legacy global library names (`base array map term menu`) and `$m_BIN_SYS_DIR/menu`. The available `m-core` `loadlib_inject_stream` still resolves selected library references under global `$m_LIB_DIR/sys/sh`. The package-local `m-term`/core sources therefore need explicit injection/lookup realignment before the remote browser can be claimed operational. Other `rsudo-admin` workflows have not received complete real-package functional testing.
- Real SSH authentication, privileged `rsudo` remote execution, interactive remote source injection and return/status handling remain **NOT TESTED** against an authorized SSH/sudo target. This is a validation gap, not evidence that the remote protocol failed.
- The initial `context` does **not** automatically install dependent library packages, choose facility/provider bindings, compose full environment/state/profile/default presets, or guarantee protected variable propagation through nested consumers. Plain `context` currently **clears** its package selections, not initializes a finished default context. The intended full environment-first context remains design/work in progress.
- The v2 runtime/catalog remain on `pkg-schema-v2` **feature branches**, not promoted mainline. Current canonical package specifications describe published v1 behavior and the initial `context` contract, whereas v2 implementation uses the `link/` views. Do not silently describe provisional v2 source behavior as a promoted mainline contract. The `m-term` README still has the older 'interactive TTY not verified' wording; its evidence statement should be reconciled with this user report when that package documentation is next touched.

**Remaining work, in execution order:**

1. Verify real published `rsudo` SSH/sudo through an **explicitly authorized, controlled target**, capturing exact local/remote revision, result and diagnostics. Do not infer permission to use an existing host; an isolated dedicated SSH/sudo testlab target is acceptable when adapted to the actual packaged setup.
2. Realign `rssh` package-local shell extension and `rsudo-admin` remote injected-library / menu-source selection using existing exported package views; then exercise the real interactive and remote normal paths, error handling and operational manuals. Keep current immutable `v0.1.0` assets unchanged; publish a new version only after authorized, proportionate validation.
3. Finish proportional real-context consumer checks (including package-local shell library exports, negative/collision/reset cases and relevant Java library paths), distinguishing source/unit evidence from public `pkg install`/end-to-end proof. Do not replace public packages with synthetic stand-ins or repeat existing PASS without a material revision change.
4. Coordinate v2 runtime/catalog consistency and eventual forward-only mainline promotion with `handoff/pkg-definition-model-review.md`; the independently owned package-dependency mismatch remains under `handoff/pkg-dependency-resolution.md`. Full `context` provider/environment/preset/inheritance semantics continue as unsettled work in this handoff; entire independent `m` validation belongs to `handoff/m-autonomous-validation.md`. The explicit freezes on legacy `rumiai-os` and `rumiai-tests` mainline changes remain in force unless the user reauthorizes them.

**Validation classification:** current turn: source/manual/test inspection and operator report incorporation only; **no new runtime test, remote connection, release, runtime/catalog change or formal physical validation**. Historical run status above applies only to its pinned revisions.

### Operator-reported vmdev interactive menu result (2026-11-05)

- The operator confirms that the real interactive `menu` test works on `vmdev`. Mark the pending operator TTY usability check as **operator-reported PASS**. This report does not contain the raw terminal transcript, selected result, exact vmdev checkout SHAs or a formal physical-reference validation session; do not claim those as independently verified. The separate hosted Ubuntu/macOS package-composition smoke remains revision-pinned as recorded below.
- Real `rsudo` privileged SSH/sudo execution still requires an explicitly authorized test target and access. `rssh` package-local shell-extension path and `rsudo-admin` remote source/menu injection remain separate unvalidated integration gaps. No product source, package release or catalog was changed by this checkpoint.

### Real m-core/m-term/m-rsudo v2 releases and hosted end-to-end PASS (2026-11-05)

- Responding to the operator's insistence on **actual packages and actual consumers**, adapted the genuine extracted sources to consume selected package-local `link/lib/sh` views through POSIX dot lookup, retaining `loadsyslib` for real `m-os` system-library identities. `m-core` `ssh.lib.sh` and `ipc.lib.sh` now use the exported `rand`/`ipc` sources; `ssh_auth` resolves the actual selected package-owned `ssh-askpass` command and rejects absence. `m-term` `menu` and `menu.lib.sh` use installed `menu`, `term`, `array`, `map` exports. `m-rsudo` `rsudo`/`rsudo-admin` and module imports use actual selected package library views; the internal module lookup restricts loading to `m-rsudo` concrete `link/lib/sh` directories. No general `m-os` loader change, counterfeit package or synthetic test.
- The three **immutable real GitHub releases `v0.1.0`** are now published by repository-owned source-only `build.sh` and GitHub Actions: `m-core-v0.1.0-all.tar.gz` (25,661 bytes, build run `42036211488` PASS), `m-term-v0.1.0-all.tar.gz` (21,775 bytes, run `42036221231` PASS), `m-rsudo-v0.1.0-all.tar.gz` (58,540 bytes, run `42036231135` PASS). Each release includes `SHA256SUMS`; archives contain real `bin/`, `lib/sh/`, `res/manual/` project files. Published release tags are immutable; subsequent source/main README or Keycloak updates do **not** change already released v0.1.0 assets.
- `pkg-catalog/pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7` adds exactly 45 catalog files for the three `all` packages: real GitHub adapter references, version/order metadata, SHA256 digest selection, `format=tar.gz`, 17 POSIX shell library projections (`link/lib/sh`) and seven executable projections (`link/bin`). It introduces no fake `dependency`: current `pkg` dependency descriptors refer to **facility** contracts, whereas these packages have explicit ordinary-library relationships and the current `context` API selects installed exact concretes. Do not claim automatic package dependency resolution for these libraries.
- **Actual hosted end-to-end PASS on Ubuntu AND macOS**: `m-core` [GitHub Actions run 42037725004](https://github.com/massimilianonardi-ai/m-core/actions/runs/42037725004), Ubuntu job `127280128346`, macOS job `127280128084`, both `success`. The pinned permanent `rumiai-tests/pkg-real-source-composition@a8db8cf5f681933d333e68f83e2d6220b62b32ea` executed via `rumiai-test` against **actual** `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`, the exact feature catalog above and the published release assets. Real `m pkg install`, concrete `link/lib/sh` projection, `context pkg=m-core@v0.1.0 pkg=m-term@v0.1.0 pkg=m-rsudo@v0.1.0`, POSIX sourcing and `array` function, the real `menu` and standalone `read-key` invalid-argument behavior, and the real `rsudo fs` module dispatch (unknown operation, rejected before remote SSH) all passed. Ubuntu runner `PASS 1/1` (2.96s), macOS `PASS 1/1` (8.66s), with zero FAIL or ERROR. This is a valid hosted composed-path smoke, **not** real TTY selection nor privileged remote execution nor stable physical host proof.
- The initial Ubuntu run failed because the test workflow checked out `pkg-catalog` in a detached HEAD and the real `pkg` attempted `git pull`; this was a **CI checkout setup issue**, not a package/schema failure. Fixed the workflow to clone branch `pkg-schema-v2` and assert exact SHA `9d889...` before execution; successful run is `42037725004`. Earlier errored runs are not PASS.
- During the work unit `rumiai-os/main` advanced again with Keycloak-module changes. Reconciled its current `rsudo-mod-keycloak.lib.sh` and operational manual forward to `m-rsudo/main`, retaining the package-local legacy-module source lookup. The already tagged v0.1.0 `m-rsudo` release does not silently inherit those later commits; its Keycloak state remains revision-pinned. The current source branches' READMEs now report release layout and exact hosted evidence without falsely claiming complete interactive remote features.
- **Still pending and real at this source-release checkpoint:** a revision-pinned formal host record beyond the operator's subsequently confirmed `vmdev` menu operation; an explicitly approved SSH/sudo test target for a real `rsudo` command; package adaptation of `rssh` and `rsudo-admin` remote `loadlib-inject-stream`/menu-path assumptions; and any warranted new, forward-only package releases. The hosted test did not exercise privileged SSH or an interactive TTY. No product-mainline promotion or changes to frozen `rumiai-os` were performed by this task.

### Real source split: m-core, m-term, m-rsudo (2026-11-05)

- **Explicit current user correction:** Do not use synthetic fake producer/consumer packages as substitutes for the real package boundary. The operator created three independent empty GitHub repositories: `massimilianonardi-ai/m-term` for existing `term.lib.sh`, `menu.lib.sh`, `menu`, `read-key`; `massimilianonardi-ai/m-rsudo` for the entire existing `rsudo` subsystem; and `massimilianonardi-ai/m-core` for shared supporting libraries and commands actually consumed by those modules. This scope is now fixed for the source-composition workstream. The user has already proved real `mk` and `jsc` on vmdev.
- Fresh remote HEAD preflight for `rumiai-dev`, `m-os`, `rumiai-os`, `pkg-catalog`, `rumiai-tests` completed. New repositories were confirmed through the GitHub repository API to exist with default `main` but **no initial commit**; remote HEADs could not exist until initialization. Initialized all three with a concise README and imported real sources from `rumiai-os/main@3f1bf0bd9ed293330687f32e15e31039a2ddd83e` without modifying the legacy repository. During the final gate that upstream branch advanced to `b8e93e7cf297792330990b20528b1f5a9e1eed8d`, changing only the rsudo Keycloak module and its manual; the exact two new upstream file blobs were reconciled forward into `m-rsudo/main`, so source content now matches the **later upstream HEAD**.
- `m-term/main@7c62bbcc4b7bc4a263895ce4782a97f92066f8df`: imported exact `lib/sys/sh/{term,menu}.lib.sh`, `bin/sys/{menu,read-key}`, and their four original operational manual topics (8 imported files).
- `m-rsudo/main@48c043ec7f9dbe2caa02934c1008ea3b99b79a84`: imported all eight existing `lib/sys/sh/rsudo/*.lib.sh` modules, `bin/sys/{rsudo,rsudo-admin,rssh}`, their ten available manual topics, and the actual `res/sys/testlab/scenarios/rsudo` scenario (22 imported files). Legacy source does not have `res/sys/manual/rsudo-mod-db-pg.lib.sh` despite having that source module; this existing documentation-coverage mismatch remains for later correction, not a fabricated new manual.
- `m-core/main@5aa6e57349f71cc0ab1fe759575e9de8ce185c1b`: imported the shared `{array,map,rand,enc,ipc,ssh,loadlib-inject-stream}.lib.sh` sources, `bin/sys/{readpass,ssh-askpass}`, and their nine existing manual topics (18 imported files). Existing `m-os` bootstrap/core/pkg/state sources remain in `m-os`, without cloning the substrate into a second implementation. All imported Git blob SHA values match the frozen legacy source; original mode preservation also verified except `array.lib.sh`, which is executable in legacy and was deliberately imported non-executable to meet the current library contract.
- Verified direct `loadsyslib` closure from actual sources: `menu` -> `array/map/term`; `rsudo` -> `rand/enc/ssh` and dynamic rsudo modules; `ssh` -> `rand/ipc`; `ipc` -> `rand`; rsudo exec -> `loadlib-inject-stream`. No schema or runtime adaptation has been asserted. These repositories currently contain **authentic extracted source and manuals**, not released/installable `pkg` v2 artifacts. Current code still uses the global `loadsyslib` lookup and is not automatically consumable through package-local `context` `link/lib/sh` search roots.
- In direct response to the user's rejection of the synthetic test, removed `m-os/pkg-schema-v2` `.github/scripts/context-package-consumer-test.sh` in forward commit `1e3a038a5abf6f8c176272d8e44464c842d3cefd`. The earlier fake test has **never** run successfully and must not be used as integration evidence. No actual composed install or terminal/SSH interactive test was executed in this work unit. `m-os`, `pkg-catalog` mainlines and frozen `rumiai-os`/`rumiai-tests` remain unchanged.
- **Next real path:** build ordinary first-party releases from actual `m-core`, `m-term`, `m-rsudo` source (without duplicating m-os root), publish corresponding definitions in the existing `pkg-catalog` v2, then install them with public `m pkg install` in a clean controlled runtime and execute `menu` or `rsudo` using actual exported shell libraries and existing m system facilities. Resolve observed `loadsyslib` versus package library lookup mismatch explicitly under canonical library/bootstrap/package contracts; do not claim that copying files proves this behavior. Because `rsudo` is privileged SSH/sudo, run remote end-to-end only against an operator-authorized test target; use safe local checks until then.

### Real two-package POSIX context consumer smoke prepared (2026-11-05)

- Operator's vmdev terminal proved `m-os@44ba31c190c63567bcc73604c7c87faff9ba73b6` and `pkg-catalog@1d38ccf509797ae34f8aa6b090b934d0d6e65a51` on `linux-arm64`: `./m mk` executed one real goal (`mk OK`), and `./m jsc` compiled an actual module then `./m node` successfully imported it (`jsc OK`). The missing optional `google-closure-compiler` emitted a warning, not a test failure. This is a real operator-host smoke on vmdev; Ubuntu release and stable physical reference-host qualification were not independently established.
- Operator requests deeper first-stage `context` validation: one package exporting ordinary POSIX sh source, another installed package executing a command that consumes that export and an `m` system shell library in the **same child process**. This is the already-promoted `PACKAGE-MODEL.md` ordinary-library view + `BOOTSTRAP-ENVIRONMENT.md` `context pkg=<exact concrete>` contract, not the still-pending full context environment/provider/nested-policy design.
- Added `m-os/pkg-schema-v2@75a7d2df4dc55bcc05e5551a1e23d7e20b8410ab` executable `.github/scripts/context-package-consumer-test.sh`. It uses genuine `pkg_integrate` to install two temporary v2 package identities, `context-sh-ci-provider@1/@2` publishing `link/lib/sh/context-sh-ci-value.lib.sh` and `context-sh-ci-consumer@1` publishing a real `link/bin/context-sh-ci-probe` command. The consumer's native POSIX shell entrypoint sources `core.lib.sh`, invokes `loadsyslib "pkg/pkg-common"` and its public `pkg_concrete_read`, then POSIX-dot-sources the selected provider's library from `PATH`. Public `context` is applied in the live initialized shell: tests selected views, child inheritance of PATH, provider version replacement, idempotence, failed-selection state preservation, and reset preserving original PATH/CLASSPATH. No default selectors of operator-installed Node/mk/jsc are altered; the fixture checks its concrete names are unused and cleans up only its own installations.
- The script passed `sh -n`/`dash -n` syntax checks and a focused here-document-generation probe in the auxiliary Linux environment. The exact committed script was re-read with original Git mode `100755` and scope-reviewed. **No actual vmdev execution/output has yet been provided**, so the cross-package composed behavior is NOT recorded as PASS. The test uses authentic `pkg_integrate` but does **not** test catalog Git lookup, remote artifact download, or `pkg install` itself; those claims remain separate.
- Next: on existing vmdev checkout run `git pull --ff-only` and `./m sh .github/scripts/context-package-consumer-test.sh`, then inspect real output and repair any actual failure. Do not expand the v2 schema or implement hypothetical wider `context` policies merely to validate this bounded property. Full `context` semantics beyond the current shell package-view phase remain pending under this handoff.

### DEVPLAN review from m-os and m-context chat archives (2026-11-04)

**Planning-only; verdict: Specifiche insufficienti for complete m-os /
fully transparent pkg-v2 consumer-context development.** The earlier
“sufficient” DEVPLAN incorrectly reduced the goal to explicit
`context pkg=<exact concrete>` shell-library lookup. This demonstrates
only one initial mechanism, not the intended completed runtime/context.

**Review basis:** current `README.md`, `RULES.md`,
`CONSISTENCY-GATE.md`, `DEVPLAN.md`, `TESTING.md`, relevant current
package/bootstrap/library/state/resource specifications, current
m-os master/v2 `context` code/manual and permanent mixed-v2 tests;
`handoff/{m-autonomous-validation,pkg-definition-model-review,
pkg-dependency-resolution,rumiai-os-source-composition}.md`.
Chat archives read: `chats/m-os/2026-10-29 m context 2/index.html`,
`chats/m-os/2026-11-03 m-context 3/index.html`,
`chats/m-os/2026-11-03 m-context 4/index.html`,
and `chats/m-core/2026-10-26 Verifica Ubuntu m/index.html`
from historical `rumiai-dev@8484b9b5`; inspected but task-separate
m-os rsudo APISIX/JSON POSIX archives. The older m-context
2026-10-26 HTML body was unavailable (not read). Chat archives are
user-intent evidence, **not current normative specifications**.

**Recovered fixed goals:** fully validate all autonomous m-os technical
responsibilities, not only mk/jsc or selected package paths; keep
`m-os` as repository identity and `m` as runtime. Preserve current v1
and frozen v2 schema boundaries: `link/bin` direct or optional `cmd`
wrapper, `link/lib/{sh,java}` ordinary exports **not facilities**;
pkg materializes, context only selects existing views; no v2
resource exports; declarative metadata and package-specific cmd
exception. Full context direction additionally includes one active
shell context (replacement, no stack), ordered dimension overrides,
defaults/presets, coherent facility/provider/state/consumer and
protected child inheritance, none of which is currently complete.

**Existing workstream owners / provisional dependencies:**
- `M`: resume `handoff/m-autonomous-validation.md` M01–M15 with real
  public workflows, failures and exact host/revision evidence.
- `V`: resume `handoff/pkg-definition-model-review.md` v2 branch
  validation, reconcile the current `pkg install` contract mismatch
  with `handoff/pkg-dependency-resolution.md`, and promote
  forward with manuals/tests/current specification realignment only
  when supported. Do not silently expand v2, package-store security
  or `rumiai-validate` targets.
- `L-I` **ready, read-only, this handoff**: inventory current legacy
  shell libraries, actual callers and manuals versus autonomous m-os;
  classify mandatory core versus independent cohesive package units.
- `L-P` **conditional on L-I and stable v2 export behavior**:
  run a real v2 library-only package + distinct consumer on coordinated
  feature branches, using public catalog-backed install, selected exact
  concrete, POSIX dot lookup, real public library function and negative
  paths. This can give V evidence **before mainline merge**; it proves
  only explicit lookup.
- `C` **blocking design decision, this handoff**: establish whether
  normal v2 consumers declare/automatically obtain a compatible
  ordinary library-package dependency or explicitly pin/select an
  already installed concrete, and whether full environment-first
  `context` completion belongs to this milestone or follows it.
  Existing `pkg depend` is facility-oriented; ordinary libraries do
  not create a second dependency graph. Full context grammar,
  protected propagation, default/preset semantics and consumer
  launch behavior remain working design, not promoted API.
- Later cohesive library migrations and composed acceptance must
  follow the applicable V/L/C contract and full M coverage.

**Operational parallelism:** M, V, and read-only L-I can proceed
independently. V exclusively owns concurrent v2 runtime/catalog
changes; L-P requires coordinated file and revision ownership.
Do not schedule fully transparent consumer support before C resolves
public semantics. No code, catalog, tests or deployment changed.

**Head checkpoints, not future authority:** `m-os/master@31693e81`,
`m-os/pkg-schema-v2@dad7c0d2`, `pkg-catalog/main@7892040e`,
`pkg-catalog/pkg-schema-v2@420e0870`,
`rumiai-os/main@5c4fd7c1`, `rumiai-tests/main@f5c625a3`.

- The user explicitly authorized integration into the reused `massimilianonardi-ai/m` repository. `master` at `809f4d63173c32ecede0cd6bb183da6fc6ab8fa9` now has the functional standalone `m` checkout: 15 technical commands beyond the root bootstrap, 28 shell libraries (4 basic, 16 package, 5 facility, 3 GitHub/Node.js/artifact adapters), 44 operational manuals, essential en_US/it_IT localization, state/catalog/shell baseline and existing selectors, plus README and GitHub Actions. The previous two original files remain unchanged.
- SHA/mode comparison with `rumiai-os/main` verified that all imported command/library/resource/state files are byte-identical; only the project README differs as intended and five missing library manual topics and workflow sources were newly authored. The source artifact still requires `osarch update` on initial host setup because the current platform selectors are carried over from `rumiai-os`.
- Normal-path hosted validation: run `40088797938` passed basic checkout smoke on Ubuntu/macOS; run `40088928262` passed the real `pkg install nodejs@v26.8.2` public path and materialized `node` command on Ubuntu/macOS, with host `node` shadowed for bootstrap checks. After fast-forwarding `master`, run `40089045452` failed on macOS due to HTTP 403 from the **external** Node.js GitHub release API (Ubuntu passed), not due to a changed `m` source. The live download test was split into an explicitly dispatched workflow; deterministic `master` smoke run `40089184835` passed on both Ubuntu/macOS. The transient failure remains recorded as failure.
- This extraction intentionally includes only the GitHub, Node.js and shared artifact repository adapters first; other adapter types in the current catalog remain unsupported by this checkout until added. The copied `osarch` selector still references a placeholder `ai-osarch` for alignment, without including branded `ai` implementation. Both limits need explicit downstream composition/realignment rather than silent inference.
- No changes to `rumiai-os/main`, `pkg-catalog/main` or permanent tests in `rumiai-tests/main` occurred in this work unit. The original `rumiai-os` implementation still coexists as transition source evidence; it is not yet rewired to consume the new independent repository.


The source boundary decision now favors an autonomous `m-core` plus the existing
independent `pkg-catalog`, with `mk` packaged separately via `pkg`.
There is no current `pkg/mk` entry in `pkg-catalog/main`, and the current
`rumiai-os/bin/sys/mk` still lives in the root runtime and explicitly calls
`pkg default nodejs`; these are pending implementation changes, not evidence
that the future package installation already works. Current `pkg install`
does invoke recursive `pkg depend` and installs planned dependencies first.
The previously contradictory `PACKAGE-MODEL.md` dependency policy subsection
was realigned to its existing detailed pipeline, implementation, public manual
and permanent tests in `rumiai-dev` commit `2a5e83eadcdc2ff64024aa5af6c2eeef7bed331b`.

PoC 073 validates package-integrated module-local `mk` in isolation, but is not
a dedicated `mk` source repository and does not exercise the public
`pkg install mk` release path. PoC 072 remains reduced-fixture evidence and
must not be credited as complete downstream `rumiai-os` composition.

### Physical checkout exploration (2026-10-26)

On user-operated Ubuntu x86_64 host `PRTL-GS-01`, the separate `/m/src/git/m-os_TEST` checkout resolves `m_ROOT` and `m_BOOTSTRAP_BIN` to that checkout and identifies `massimilianonardi-ai/m` `master` at `809f4d63173c32ecede0cd6bb183da6fc6ab8fa9`. `osarch show` returned status 0 with consistent `linux-x86_64` sys/ext/ai selectors and matching generated-environment selection. The three `bin/{sys,ext,ai}-osarch` selector links show as locally modified in Git; preserve them. This is environment/selection exploratory evidence only, **not** proof of the complete functional test suite, installations, NSS synchronization or services. Next operator step is non-mutating runtime smoke and command/manual/state/TLS query checks, followed by staged real integrations.

### Ubuntu checkout core smoke (2026-10-26)

The same user-operated Ubuntu checkout passed direct `./m sh -c` bootstrap-root exports; `state-path system sys shell conf`, `state-path user sys shell conf`, `state-path user pkg nodejs home`; `lang-set` query (`en_US`); operational manual reads for `pkg` and `core.lib.sh`; empty `tls-ca list`; and `sh -n` parsing of the root bootstrap and all shell libraries. `./m lang hello` returned status 1 because the exploratory invocation supplied only one operand where `lang <domain> <message-id>` requires two; rerun the correct invocation. `./m pkg versions nodejs` returned status 1 without output, consistent with no available installed package class/version and not by itself a defect. Nothing in these probes demonstrates actual package download/install, NSS reconciliation or service lifecycle. Next: exercise a real localized message and isolated offline file/digest/extraction/NSS-no-op paths before integration tests.

### Ubuntu core operations and NSS platform defect (2026-10-26)

On `PRTL-GS-01`, the real independent `m@809f4d63173c32ecede0cd6bb183da6fc6ab8fa9` checkout produced the expected localized message `filesystem/path-invalid`, missing-message identity fallback `example.missing`, the known SHA-256 of `abc`, a file SHA-256, and successful real TAR extraction plus byte comparison. All six exercised checks returned status 0.

The seventh probe `./m tls-nss-sync <fresh-real-browser-home>`, with `tls-ca list` previously empty, **failed** status 4: `tls-nss-sync.backend-unavailable: NSS projection is currently Linux-only`, even though host `uname -s` is Linux and `osarch show` selects `linux-x86_64`. Current `m/bin/sys/tls-nss-sync` branches on `"$m_OSARCH"` but never imports `osarch.lib.sh`; the m bootstrap and core/base shell libraries do not establish that exported variable. `osarch` initializes it only for its own command process. This can reject legitimate Linux invocation and block browser launch through `launcher_nss` even with no extra CAs. The same source behavior exists in `rumiai-os@673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`: defect inherited by extraction, not introduced by the independent repo. Current `rumiai-tests/tests/rumiai-os/tls-trust/contract.test` covers CA approval/import/removal but does not include a dependency-free no-CA NSS no-op regression for this exact startup path.

The follow-up user-host countercheck confirmed `m_OSARCH=<unset>` inside `./m sh -c`, `./m osarch` reported `linux-x86_64`, and `env m_OSARCH=linux-x86_64 ./m tls-nss-sync <fresh-browser-home>` returned status 0. This confirms the missing initialization mechanism as the cause of the no-extra-CA NSS failure, without changing the source or proving populated NSS projections.

**Realignment status (2026-10-26)**: The standalone `m` command correction, manual consistency and hosted regression are now complete as recorded below. The unmodified `rumiai-os` command still has the inherited defect, and permanent test-suite realignment in `rumiai-tests` remains pending. The corrected independent `m` has not yet been revalidated on the user's physical host. Preserve user-local selector symlinks and installed-package projections.

### Ubuntu managed Node.js and standalone m NSS correction (2026-10-26)

On physical Ubuntu x86_64 `PRTL-GS-01`, the user verified with the still-unmodified `m@809f4d63173c32ecede0cd6bb183da6fc6ab8fa9`: public `pkg depend nodejs@v26.8.2` returned status 0 and fetched the catalog; public `pkg install nodejs@v26.8.2` downloaded the Node artifact (~32.1 MiB) and returned 0; `pkg versions nodejs` and `pkg default nodejs` both returned `nodejs@v26.8.2!linux-x86_64` with status 0; `./m node --version` returned `v26.8.2` with status 0; launcher path resolved to `bin/ext-osarch/node`. Subsequent local git status preserved the three user-local modified platform symlinks and reported new untracked `bin/ext-linux-x86_64/` materialization; do not remove/reset these physical-host effects without an explicit reason.

After explicit user authorization to update **the independent `m` repository only**, commit `5c1e02a10e5300ab953d86aa677583f63e6a068d` on `m/master` corrects `bin/sys/tls-nss-sync` by loading the existing m core and `osarch` library in the command process, with distinct missing-runtime/library diagnostics (statuses 29 and 30). Its operational manual and repository README were aligned, and `.github/workflows/m-core-checkout.yml` now asserts the no-extra-CA NSS no-op with `m_OSARCH` unset on Linux and expected status 4 for a non-Linux host. Reviewed the commit diff: only these four intended files changed, preserving the executable file mode and existing statuses. GitHub Actions push run `40287862700` is **PASS on Ubuntu and macOS** for exactly that SHA. Hosted smoke validates the empty-CA path and bootstrap compatibility, not CA approval/import/revocation.

User-host follow-up: `git pull --ff-only` fast-forwarded the existing checkout to `m@5c1e02a10e5300ab953d86aa677583f63e6a068d` while preserving all prior local changes. The same no-extra-CA `./m tls-nss-sync <new-temp-home>` now returned **status 0** without creating `<home>/.m`; managed `./m node --version` remained `v26.8.2`. Local `git status --short` retained only the existing three modified osarch selector links and untracked `bin/ext-linux-x86_64/` package launcher projection. **Physical Ubuntu reproduction fixed for this narrow no-CA path**, and hosted smoke passed on both OS platforms for the exact same revision.

**Remaining**: add appropriately owned permanent regression evidence in `rumiai-tests` rather than relabeling the repository smoke as a permanent suite; reconcile the unchanged `rumiai-os` copy in an appropriately authorized work unit; validate populated NSS CA approval/import/revocation and dependent browser launches separately if in scope. No update was made to `rumiai-os` or `rumiai-tests` in this work unit.

### Ubuntu HTTPS fetch and manual discovery (2026-10-26)

On physical Ubuntu x86_64 `PRTL-GS-01` at independent `m@5c1e02a10e5300ab953d86aa677583f63e6a068d`, `./m http-fetch -t 30 -o <temporary-file> -- https://raw.githubusercontent.com/massimilianonardi-ai/m/<same-commit>/res/sys/lang/en_US/filesystem/path-invalid` returned status 0, and `cmp` against the local revision-coupled catalog file also returned status 0 (21-byte exact match). `./m manual | wc -l` reported 44 manual topics, matching the checkout inventory. These are successful physical-host command probes, not complete package-transport or TLS trust lifecycle validation. The following targeted isolated TLS authority/NSS cycle has now passed; remaining extended verification is independent NSS trust preservation, managed-entry tamper detection and any launcher integration not exercised yet.

### Ubuntu isolated CA approval/import/revocation (2026-10-26)

On user-operated `PRTL-GS-01`, Test 6 ran against a fresh `git clone --no-hardlinks` of the physical checkout at pinned `m@5c1e02a10e5300ab953d86aa677583f63e6a068d`, selected the host platform through real `osarch update`, and explicitly asserted the resolved `system sys tls conf` path was underneath the temporary clone. A newly generated short-lived CA with `CA:TRUE` and signing keyUsage was approved via public `tls-ca add`, listed through `tls-ca list`, then imported into a temporary browser HOME's actual NSS SQL DB via public `tls-nss-sync`. Repeated sync succeeded; `tls-ca remove` and re-sync removed the managed certificate and ownership manifest. Operator output included `CA authorization: PASS`, `NSS import: PASS`, `NSS repeated sync: PASS`, `NSS revocation: PASS`, and `TLS CA lifecycle: PASS`. The temporary clone and test materials were deleted on shell exit. The original checkout's final `git status --short` still showed only the prior three modified osarch links and untracked `bin/ext-linux-x86_64/`.

Scope: real Ubuntu host and a disposable real clone of exact m source revision, not changes to the selected operational CA authority; the test did **not** assert preservation of unrelated NSS entries, reaction to modified managed trust flags, or actual browser launcher behavior. Those cases and appropriately owned permanent coverage remain to be assessed.

### Ubuntu isolated NSS preservation and tamper rejection (2026-10-26)

On user-operated physical Ubuntu `PRTL-GS-01`, Test 7 used another disposable `git clone --no-hardlinks` at exact `m@5c1e02a10e5300ab953d86aa677583f63e6a068d` and asserted system CA configuration resolution remained under the clone. It created two short-lived real CA certs, approved only the managed one, initialized a real NSS SQL DB in disposable browser HOME, and inserted a distinct independently managed NSS certificate via `certutil`. Public `tls-nss-sync` imported the approved CA and preserved the unrelated entry. An intentional `certutil -M ... -t ',,'` alteration to the m-managed nickname caused `tls-nss-sync.owned-entry-modified` **status 22**, as intended. After restoring `C,,`, sync succeeded; authorized removal and another sync removed the managed CA while preserving the unrelated entry. User output explicitly confirmed `Existing certificate preserved: PASS`, `Tamper detection status=22`, `Tamper detection: PASS`, `Unrelated certificate survived revocation: PASS`, and `NSS PROTECTION TEST: PASS`. Original checkout Git status retained only the pre-existing osarch selector modifications and untracked package command projection.

This extends physical, isolated real-path evidence for managed NSS ownership and tamper rejection, **not** a permanent `rumiai-tests` run or proof of end-to-end browser launcher behavior. The existing `rumiai-tests/tests/rumiai-os/tls-trust/contract.test` already asserts preservation of unrelated NSS entries in its own target; pending standalone m source integration/permanent coverage should avoid duplicating coverage needlessly. Next substantive testing domain: provider-backed `srv` lifecycle with an isolated real provider/service fixture (never invoke host supervisor registration on the physical account as an exploratory shortcut); browser package launch behavior should be validated when a real supported browser provider is available.

### Browser launcher NSS integration audit and physical scenario (2026-10-26)

The user selected browser integration testing before the separate `srv` work. At current `m/master@5c1e02a10e5300ab953d86aa677583f63e6a068d`, `pkg-catalog/main@73c0cd7003802ce120c693c9427b22f1141a2f8b` and `rumiai-tests/main@039e8114497e0a9651d231678716f96b9f447358`, source inspection confirms that the Linux `pkg/chrome`, `pkg/chromium` and `pkg/electron` command descriptors invoke the public `launcher_nss` path. The current m `pkg-launch.lib.sh` prepares package state/environment and calls the fixed `m/bin/sys/tls-nss-sync` with final effective HOME immediately before `exec`; `m_ENV_DO_NOT_OVERRIDE=HOME` uses the caller-supplied one-shot final HOME; an NSS failure blocks launch with status 8. This is static mechanistic evidence, **not yet a passed real browser launch test**.

The independent `m` checkout currently lacks the `pkg-repository-chrome.lib.sh` and `pkg-repository-chromium.lib.sh` adapters referenced by the catalog's Chrome/Chromium Linux definitions; do not claim these packages can be installed through this standalone m revision. `electron@v44.3.0!linux-x86_64` uses the existing GitHub adapter, but its catalog range declares `setuid_root: chrome-sandbox`, whose real package integration requires privileged chmod/chown via `sudo` on a non-root host. An isolated clone with private mode and a passwordless privilege precheck may exercise the real public `pkg install electron@v44.3.0`, positive NSS side effect under default package HOME, trusted one-shot HOME override, and tamper-induced launcher failure status 8, without altering the user's operational browser state. Upstream download and physical Electron execution have not yet been run for this checkpoint; shared-library/sandbox behavior and external release availability may still block the executable phase. Avoid fake browser executables and do not disable the sandbox to make tests pass.

Existing `rumiai-tests/tests/external/electron/linux-launch-live.test` exercises real installed Electron GUI startup when available, and `tests/rumiai-os/tls-trust/contract.test` covers real CA approval/NSS import/removal/preservation; neither source by inspection is proof that the corrected standalone `m` launch automatically projects NSS trust at its effective HOME. Do not conflate these validation boundaries.

**Physical Electron integration attempt (2026-10-26)**: user ran the isolated Electron NSS test block on `PRTL-GS-01`; it stopped at its first preflight with `SKIP: Electron requires sudo for chrome-sandbox` because non-interactive `sudo -n true` did not pass. Neither clone, CA approval nor Electron package install/launch were attempted. The original Git status remained unchanged. This is explicitly **SKIP, not FAIL/PASS**. The next operator step, if host administrator rights are available and authorized by the user, is `sudo -v` interactively in their own terminal, verify `sudo -n true`, and rerun the exact isolated scenario; no sandbox bypass or mock should substitute. If the account has no sudo authority, keep physical Electron launch pending and use an appropriately privileged disposable Linux runner/VM to obtain separate hosted evidence. New `pkg-catalog/main@e8679ece70b523c7798bc4cc10bfd450810fcf64` still declares exact `electron@v44.3.0!linux-x86_64`. Preserve user-local selector symlinks and package projection.

### Physical Electron NSS package-launch PASS (2026-10-26)

User on physical Ubuntu `PRTL-GS-01` reran the previous browser integration scenario after authorizing sudo in their terminal. The test first verified `sudo -n true` and created a separate `git clone --no-hardlinks` of the current local checkout at exact independent `m@5c1e02a10e5300ab953d86aa677583f63e6a068d`, with TLS authority and Electron package HOME both explicitly confirmed to resolve inside that disposable clone. A self-signed short-lived test CA was authorized only within cloned m state. `./m pkg install electron@v44.3.0` downloaded the **real ~117 MiB Electron Linux x86_64 artifact** through the selected live pkg-catalog and configured the real `chrome-sandbox` setuid-root requirement through `sudo`; public `./m pkg default electron` returned `electron@v44.3.0!linux-x86_64`.

The public `./m electron --version` on the **normal managed package HOME** returned `v44.3.0` and status 0, and real NSS SQL inspection confirmed automatic import of the approved test CA into that HOME (`Normal HOME NSS sync: PASS`). A separate public `HOME=<separate-temp-browser-home> m_ENV_DO_NOT_OVERRIDE=HOME ./m electron --version` also exited 0 and projected the CA into the **effective inherited** browser HOME (`Inherited HOME NSS sync: PASS`). After deliberately changing the owned entry's NSS CA trust flags via `certutil -M ... -t ',,'` under only that inherited HOME, the same public Electron launcher returned **status 8**, surfaced the expected projection-failure diagnostic, and emitted no browser version output (`Fail-closed launcher: PASS (status 8)`). Final operator summary: **`ELECTRON LAUNCH + NSS INTEGRATION: PASS`**. Cleanup removed the temporary clone, leaving the original checkout with only its already existing three osarch selector modifications and `bin/ext-linux-x86_64/` untracked installed-package projection. The initial interactive `SKIP` remains historical evidence; this later full PASS supersedes it as the current Electron outcome for this same source revision.

Scope limitation: this proves actual managed Electron executable startup, automatic NSS synchronization in two HOME modes, and fail-closed launch on modified managed CA trust; it does **not** exercise Electron `BrowserWindow` navigation over HTTPS, external CA chain validation in rendered pages, or actual installed Chrome/Chromium launchers. The independent `m` source still needs its missing Chrome/Chromium repository adapter capability if those packages are to be installed through the new public `pkg` command; ordinary browser launch behavior remains separate from package installation. Any permanent regression addition belongs in `rumiai-tests` and should build on existing browser/package and TLS suites rather than duplicating their properties.

### Independent mk package candidate against autonomous m (2026-10-26)

The existing PoC 073 isolated package-local source was retained on
`rumiai-dev-PoCs/mk-package-local-runtime`, now at
`fdf655405eb3a22c34b549c013387d0fa01c34ea`. Its POSIX packaging harness
was corrected for macOS `chmod` semantics; its real watch input-change scenario
now avoids a baseline-snapshot startup race without replacing the target.
The existing real `pkg_integrate` / `pkg_default_apply` path now runs both
against an isolated copy of legacy `rumiai-os@673df1a2` (with embedded mk
removed) and directly against the autonomous `m@5c1e02a` (which has no
embedded mk). Each checkout selects the actual host osarch in its disposable
clone. No product checkout or user's installed state was changed.

GitHub Actions run `40309229176` at exact PoC revision
`fdf655405eb3a22c34b549c013387d0fa01c34ea` is **PASS Ubuntu + macOS**
for both composed scenarios, real managed Node.js, package-local source,
`--goals`, `--plan`, a lifecycle process and watch re-entry. An Ubuntu job
also uploaded `mk-v0.1.0-release-candidate` with SHA-256 checksum as a
temporary Actions workflow artifact. The archive is **not** a GitHub release.
Earlier failed runs `40308481026`, `40308625741`, `40308770547`,
`40308893970` remain failed evidence of corrected macOS packaging and
watch-test race issues; do not relabel them PASS.

Blocking publication tasks are still: create the independent `mk` source
repository (unsupported by the connected GitHub write actions), populate it
from the validated staged source, publish a versioned verified release asset,
add the real catalog descriptor in `pkg-catalog`, execute public
`pkg install mk` from a clean standalone m checkout, and realign permanent
mk tests and documentation. The current phase did **not** change `m`,
`rumiai-os`, `pkg-catalog` or `rumiai-tests`, nor did it perform physical
host validation.

### Independent m-mk release and real public package installation (2026-10-26)

The user created the empty `massimilianonardi-ai/m-mk` repository. The
verified PoC 073 engine, package-local native Node.js entrypoint, POSIX
source archive builder, package-owned manuals and local real-integration
smoke tests were copied forward (not rewritten) as independent source.
`m-mk/main@707d4c624a2fe7dcb149899346f71d5cd4a4bbf5` produced
GitHub release `v0.1.0` after Ubuntu/macOS genuine integration tests
passed in workflow `40312048980`. The artifact
`mk-v0.1.0-all.tar.gz` is 30810 bytes with GitHub release asset
`sha256:41104f6c7034a569ceac6efa9724a85e86c918c425d1ace035be725f7867aa2e`.
The archive contains package-local `bin/mk`, `lib/mk.lib.js` and
`res/manual/` without projecting `mk` implementation into `m/lib/sys`.

The matching public `pkg-catalog/main@6a324426f11d151bb43945579d8dd018674dee48`
descriptor registers `pkg/mk/all/n0001=v0.1.0`, the existing GitHub
repository adapter targeting `m-mk`, SHA-256 artifact verification and
the real `nodejs =26` dependency, native package launcher and link.
`m-mk/main@4880b4676ed6d7f46965a41f7e9b3d4d867ddf18` adds a
clean-root **public** `pkg install mk@v0.1.0` scenario exercised on
the real independent `m@5c1e02a` runtime, including managed Node.js,
command projection, `--goals`, `--plan` and an executed action.
Workflow `40312408376` attempt 1 passed Ubuntu and failed macOS
because GitHub's external upstream Node.js release API returned HTTP
403 before `mk` download; attempt 2 reran the failed job and is
**PASS Ubuntu and macOS**. Do not erase or relabel that initial failure.
The versioned release remains pinned to its initial source commit and
was not rebuilt from the later CI/test-only commit.

Canonical source/distribution and package-local manual boundaries were
realigned forward in `rumiai-dev` commits `12c90959d4ba7aa376024ee4e684ff137665826f`
and `fd8428f5adc6ea09c55a0c287a8c2fdd53956191`, followed by a stale global-library example correction at `d5e16b15ed366dc04dc30e13e37a637a039850d6`.
No `m` or legacy `rumiai-os` source modifications or physical
production-host deployment were made in this unit. Existing legacy
`rumiai-os/bin/sys/mk` and `lib/sys/js/mk.lib.js` still require
consumer-aware removal. The existing permanent `rumiai-tests` mk
suite is not yet realigned to the independent published package; the
repository-owned release/integration CI evidence is not presented as a
replacement for those permanent regressions.

### Standalone m Chrome and Chromium upstream adapter integration (2026-10-26)

The user explicitly authorized continuing browser TLS/NSS integration after the real Electron package-launch PASS. Retrieved current remote HEADs and the canonical `rumiai-dev` mandatory source set, then inspected old product adapters and current tests. In standalone `m/master@47e6055f8ccdccee6906ec1de387b17124e56527`, imported exactly the existing two non-executable shell libraries `lib/sys/sh/pkg/repository/pkg-repository-chrome.lib.sh` (Git blob `77f03fc4899136f26937aa51dca1e608b1785d84`) and `pkg-repository-chromium.lib.sh` (blob `a39b2496082331992cf8e52e029dd897dbc4246b`) from `rumiai-os/main@673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`. `m` already owns an identical `json.lib.sh` required by Chromium (blob `6cea464d85f1c747c61b97e81bb2fd72d4543c09`), so no JSON duplication was needed. This preserves the established repository-type selection and public `pkg install` / generic download/verification path; it does not modify the common NSS launcher. The original `rumiai-os` lacked the adapter manuals; created required new `res/sys/manual/pkg-repository-{chrome,chromium}.lib.sh` within m rather than carrying this incompleteness forward. Updated m README adapter inventory and the existing `.github/workflows/m-core-checkout.yml` smoke to check new manuals, load both real libraries, exercise local Chrome numeric ordering, and reject malformed Chromium versions on Ubuntu/macOS. The smoke was committed on push; **no current hosted-run PASS has yet been retrieved**. Exact source blob equality and changed-file diff were checked with current GitHub API; shell smoke and live browser installations remain unverified for this new m revision until executed.

**Inherited specification/test mismatch identified**: current Chromium `pkg_repository_compare_versions` validates both snapshot revisions by live Google object metadata, including equality, despite `PACKAGE-MODEL.md` requiring locally determinable numeric historical comparisons to avoid redundant upstream requests. Existing `rumiai-tests/tests/rumiai-os/pkg-repository-chromium/contract.test` specifically expects rejection of an unavailable historical revision in a comparison. Porting preserved the old implementation bytes rather than silently changing its observable behavior and invalidating the existing test; this discrepancy requires a separately validated implementation/test realignment (standalone m, and later the still-unmodified downstream `rumiai-os`). Chromium's new manual explicitly discloses the current behavior and pending realignment.

The user-host next verification must use `git pull --ff-only` in the original `m` checkout, preserving the three modified osarch selector links and existing untracked Node projection, then a disposable clone at the **new** exact m revision. Exercise `pkg install chrome` and `pkg install chromium` through the real catalog/upstream adapters, inspect the public browser version launch, approve only a temporary-clone CA, assert automatic NSS import to the real managed package HOME, and induce managed-NSS tampering to verify launcher status 8. The original physical Electron PASS applies to old `m@5c1e02a`, not this new revision. Do not claim Chrome/Chromium physical PASS, full GUI HTTPS verification or standalone-m permanent test-suite coverage before they occur; existing `rumiai-tests` external browser tests still validate their separately specified legacy `rumiai-os` target. No modifications were made to `rumiai-os`, `pkg-catalog` or `rumiai-tests` in this work unit.

### Browser physical Test 9 preflight SKIP: corrected test-only osarch assertion (2026-10-26)

On physical Ubuntu `PRTL-GS-01`, operator fast-forwarded the existing independent `m` checkout from `5c1e02a` to `47e6055f8ccdccee6906ec1de387b17124e56527` preserving three local selector modifications and the untracked Node launcher projection, then authorized sudo and ran the proposed disposable clone browser integration scenario. The clone and `./m osarch update` succeeded, but the assistant-written test asserted `[ "$(./m osarch show)" = linux-x86_64 ]`, yielding `SKIP: requires linux-x86_64` before approving a CA or installing either browser. This is a **test-script mistake**: the current `m/bin/sys/osarch` and operational manual specify that bare `./m osarch` prints the single normalized identity, whereas `./m osarch show` prints a multiline inspection report. The correct test-only condition is `[ "$(./m osarch)" = linux-x86_64 ]`. The test SKIP supplies no negative evidence about Ubuntu, Chrome/Chromium adapter correctness, or NSS integration; neither browser package was downloaded/launched. The original checkout Git status remains unchanged. No m implementation or spec change is warranted by this SKIP. User should rerun the same isolated physical test with the one-line condition corrected, retaining the exact source revision and host authorization precondition.

### Physical Chrome + Chromium NSS integration PASS (2026-10-26)

User reran the corrected **Test 9** on reference Ubuntu host `PRTL-GS-01` with the isolated `m/master@47e6055f8ccdccee6906ec1de387b17124e56527` clone. The only test-script repair was replacing `./m osarch show` with bare `./m osarch` for an exact `linux-x86_64` selector assertion. The real `./m osarch update` and explicit `state-path system sys tls conf` containment guard passed before temporary CA approval. A new short-lived CA was approved under cloned m state, not the user's operational authority.

Both browser installations used the public `./m pkg install <browser>` with the current fetched catalog and real upstream artifacts, including required real sudo-mediated `chown 0:0` / `chmod 4755` for the package-local `chrome-sandbox`. **Chrome** downloaded approximately 138 MiB and installed `chrome@156.0.8078.47-1!linux-x86_64`; `./m chrome --version` returned **status 0**, `Google Chrome 156.0.8078.47`. **Chromium** downloaded approximately 242 MiB and installed `chromium@1726878!linux-x86_64`; `./m chromium --version` returned **status 0**, `Chromium 158.0.8126.0`. For *each* browser, the public launcher automatically reconciled the approved CA into the actual package HOME's NSS SQL DB; direct `certutil -L` verified the managed nickname, printed `<browser> automatic NSS sync: PASS`. Deliberately changing only the managed trust flags to `,,` caused the next public launcher to fail closed with **exit 8**, the expected `tls-nss-sync.owned-entry-modified` and `pkg-launch.tls-nss-sync-failed` diagnostics, and no browser version output. Restoring `C,,` and running the public sync succeeded. The operator output ended with **`CHROME + CHROMIUM NSS INTEGRATION: PASS`** and original checkout Git status still contained only the three preexisting selector modifications and `bin/ext-linux-x86_64/` untracked package command projection. All tested CA material and browser installations were within the disposable clone, removed at shell completion.

This closes the **real Linux native package launch / automatic NSS projection / fail-closed** validation scenario for Chrome and Chromium on the exact m revision, supplementing the separate prior real Electron PASS on `m@5c1e02a`. It does **not** prove web-page HTTPS validation by the browser engine, Chrome/Chromium one-shot inherited HOME behavior, GUI/browser-profile integration, or a permanent `rumiai-tests` run. The preflight test-only SKIP remains recorded as a corrected preliminary attempt, not a product failure. The previously identified Chromium historical compare-via-network mismatch with the current package spec/tests remains open and is not altered by successful browser installation. No code or test repository mutation is implied by this physical evidence.

### Remaining first-party package inventory and isolated jsc extraction (2026-10-26)

A fresh comparison of `rumiai-os/main@673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`
(read-only) with standalone `m/master@47e6055f8ccdccee6906ec1de387b17124e56527`
shows 31 old `bin/sys` command identities and 16 already present in
standalone `m`. The independently released `mk` accounts for one more,
leaving 14 old commands to place: `jsc`, `pkg-analyze`, `editor`,
`read-key`, `readpass`, `readpassv`, `menu`, `vsed`, `gitman`,
`rssh`, `rsudo`, `rsudo-admin`, `ssh-askpass`, `testlab`.
They are **not** presumed to require 14 source repositories or packages.
Current working grouping (not yet a promoted packaging contract):
`jsc` standalone compiler; `pkg-analyze` standalone developer tool;
terminal primitives/interactive commands; `gitman` depending on terminal
facilities; SSH/rsudo administration; `testlab` scenario lifecycle.
Non-command work includes `lib/sys/js/core`, `core-ext`, `ui`,
`text-edit.lib.js`, `dynamic-loader.lib.js`, Web/ChatGPT export scripts,
other global shell libraries, upper RumiAI activation/resources and possible
duplicates with existing independent Web repos. The new `m` currently has
five repository adapters (`artifact`, `chrome`, `chromium`, `github`,
`nodejs`), compared with twelve in old `rumiai-os`; remaining adapters
are package-runtime implementation responsibilities, not automatically
separate user-installable packages.

Since the future jsc source repository does not yet exist, a genuine
**isolated package-local candidate** was staged in
`rumiai-dev-PoCs/jsc-package-local-runtime` at
`29bed6bc6cfafc96265c9b4d4b8b9e811b6aa6e9`, under
`pocs/074-jsc-package-local-runtime`. It copies the exact current
`rumiai-os` CommonJS engine without modification; the package-local
POSIX command resolves its sibling engine from its physical command root
rather than `m/lib/sys/js`, and corrects an inherited invalid `log warning`
severity to `log warn`. The source archive builder requires no Node.js
or `mk`; the test-only catalog fixture declares `nodejs =26`, real
`pkg_integrate` and `pkg_default_apply` are used against a disposable
copy of standalone `m`, and real managed Node.js executes actual JavaScript
and CSS compilation. This PoC has not been published in `pkg-catalog` and
is not a release or evidence for the public `pkg install jsc` path.

GitHub Actions workflow `40315415150` at the exact candidate commit
passed Ubuntu; the first macOS attempt failed at upstream Node.js release
API HTTP 403 before compiler execution. Failed-job retry (attempt 2)
is **PASS Ubuntu and macOS**. Preserve the initial external failure as
separate evidence. No `rumiai-os`, `rumiai-tests`, `m` or
`pkg-catalog` files were altered for the jsc PoC.

### Browser HTTPS engine trust and revocation probe prepared (2026-10-26)

After real Ubuntu `m@47e6055f8ccdccee6906ec1de387b17124e56527` native Chrome/Chromium automatic NSS import/fail-closed PASS, the next browser scenario is an **actual HTTPS request by the real browser engine** to an isolated local TLS origin, not only NSS SQL database inspection. A disposable standalone shell operator probe was produced as conversation artifact `rumiai-browser-https-nss-test.sh` (SHA-256 `136543bbb22a852b8423970549a8f4131588c9ce126a2cd8e90dcc20de39ba80`). It deliberately pins the exact m revision, clones it with `git clone --no-hardlinks`, asserts state isolation, generates an ephemeral certificate-authority and a real server certificate with DNS/IP subjectAltName, starts a local Python HTTPS server bound only to 127.0.0.1, and verifies its TLS chain via OpenSSL. It installs actual Chrome and Chromium via public `m pkg install`, launches each with `--headless=new --dump-dom` through public `m chrome/chromium`, under unique temporary browser profiles and **without** certificate-error bypass or sandbox disabling. The scenario checks browser-observed certificate-authority refusal before CA authorization, actual signed-page rendering after public `tls-ca add`, and renewed refusal plus owned NSS entry removal after public `tls-ca remove`.

Validation to date is strictly **script Bash parsing PASS** plus OpenSSL server-certificate SAN/chain generation and verify PASS in an assistant-provided Linux container. Actual physical Ubuntu Chrome/Chromium headless HTTPS process results are **pending operator execution**; no browser HTTPS PASS is claimed and there is no change to m, `rumiai-os`, `pkg-catalog` or `rumiai-tests`. The auxiliary container's installed Chromium was not able to provide meaningful headless DOM evidence under its own execution restrictions; it is not substitute physical evidence. The prepared script cleans up its local server and test material on exit and preserves the user's existing checkout modifications. If actual headless trust failure diagnostics differ from the anticipated `ERR_CERT_AUTHORITY_INVALID`, inspect actual browser outputs and reconcile rather than weakening validation. The inherited Chromium repository adapter's unnecessary live historical version comparison remains a separate previously recorded pending realignment.

### Physical browser-engine HTTPS validation PASS (2026-10-26)

The operator executed the complete previously prepared `rumiai-browser-https-nss-test.sh` script on actual Ubuntu reference host `PRTL-GS-01` in a disposable `git clone --no-hardlinks` of **standalone `m/master@47e6055f8ccdccee6906ec1de387b17124e56527`**. The script verified clone/system-trust path containment, created a new private short-lived test CA and a separate localhost leaf certificate with `DNS:localhost,IP:127.0.0.1` SAN, and started a real TLS server bound to `127.0.0.1:37637`. OpenSSL validated the private certificate chain with its explicit trusted CA. The browser commands were invoked through real `./m chrome` and `./m chromium`, with fresh separate `--user-data-dir` profiles, `--headless=new --dump-dom`, and **no TLS-certificate verification bypass or sandbox bypass**.

Real catalog-backed `./m pkg install chrome` downloaded ~138 MiB and configured the package-local setuid sandbox through sudo. **Chrome `156.0.8078.47-1!linux-x86_64`** launched natively and returned `Google Chrome 156.0.8078.47`. Real catalog-backed `./m pkg install chromium` downloaded ~242 MiB and configured its sandbox. **Chromium `1726888!linux-x86_64`** launched natively and returned `Chromium 158.0.8126.0`. Snapshot `1726888` differs from previous physical Test 9's `1726878` because this run used new live discovery; both results are revision-specific observations, not a catalog change.

For **both Chrome and Chromium**, Phase 1 **PASS**: headless browser explicitly signaled `ERR_CERT_AUTHORITY_INVALID` or `ERR_CERT_INVALID`, did not render the unique HTTPS content marker and therefore rejected the unapproved CA (the browser processes themselves may still return exit 0 when rendering a certificate error page). Phase 2 **PASS**: `./m tls-ca add` authorized fingerprint `33adf9846ef7a091211e2000574a2e13f331c1701d6ca560b24bd834ecc0cace`, and both real engines loaded the signed localhost HTTPS page, returned status 0, rendered its unique marker, and contained the managed NSS entry under their separate effective package HOMEs. Phase 3 **PASS**: `./m tls-ca remove` revoked that CA; both freshly launched engines again rejected the same HTTPS page with certificate authority errors, omitted the unique content marker, and `certutil -L` confirmed the managed NSS CA entry was removed from each package HOME. Final operator result **`REAL CHROME + CHROMIUM HTTPS TRUST AND REVOCATION: PASS`**, with the exact source commit echoed. Checkout Git status retained only its pre-existing `bin/{ai,ext,sys}-osarch` modifications and `bin/ext-linux-x86_64/` projection; the script's temporary files, local server and clones were cleaned on exit.

**Evidence scope:** genuine native Ubuntu Chrome/Chromium browser-engine HTTPS trust acceptance and rejection on clean process startups, authorization and revocation, based on public `m` APIs. This does not measure running-browser trust-cache invalidation, macOS behavior, arbitrary public HTTPS compatibility, or Electron's browser-engine navigation. Earlier standalone Electron positive NSS startup/managed-entry tamper scenarios were run against `m@5c1e02a` and are separate revision evidence. No permanent `rumiai-tests` execution or modification is claimed; the user's explicit freeze on `rumiai-tests` and old `rumiai-os` remains in effect. The previously identified Chromium `pkg_repository_compare_versions` historical ordering/network mismatch remains open and is unaffected by this PASS.

### Independent m-jsc source, published release and public pkg installation (2026-10-26)

User created the new empty `massimilianonardi-ai/m-jsc` repository.
The previously validated `rumiai-dev-PoCs/jsc-package-local-runtime@29bed6bc6cfafc96265c9b4d4b8b9e811b6aa6e9`
command, unchanged CommonJS compiler engine, POSIX archive builder and
package-owned manuals were moved into `m-jsc` without touching the
legacy `rumiai-os`. The source entrypoint loads its sibling package-local
engine, and uses the global `m` shell core only for established interfaces.
The first full import commit was `55280e377b4cbcd697faa60fa4ae03a1b1ff370f`.

Versioned immutable release `m-jsc/v0.1.0` was published from
`m-jsc@0f5371ba10e55b21a95b9021bf82a64aacfd28be` with asset
`jsc-v0.1.0-all.tar.gz` (6,799 bytes), SHA-256
`d4d5a4ab667b1c89bca89b9d1726b483cd64021dd2df1bc5f685a0a72f492bfc`.
The real `pkg-catalog@8a346e9c1b30fa40706213cf9798720d7ffd39ff`
registered `pkg/jsc/all/n0001=v0.1.0`, its existing GitHub repository
adapter, SHA-256 verification, `nodejs =26` execution dependency, normal
command launcher and relative target link. No global system implementation
was projected into standalone `m`.

GitHub Actions run `40319511067` for the published source:
Ubuntu genuine package-local integration PASS, macOS initially blocked by
HTTP 403 while fetching upstream Node.js GitHub release metadata (not a
compiler execution failure), source release job PASS. A later run
`40319768375` on `m-jsc@952b97dd291cf178362f541129640f3375841b04`
is **PASS on both Ubuntu and macOS**, including actual managed Node.js
compiler execution, JavaScript/CSS compilation, POSIX packaging and
pre-existing release preservation. The package release itself is pinned
to its initial versioned source; later source changes were confined to CI
or public install validation.

The separate real public `pkg install jsc@v0.1.0` run
`40319768324`, also at `m-jsc@952b97dd291cf178362f541129640f3375841b04`,
is **PASS Ubuntu + macOS** with genuine artifact retrieval/verification,
managed Node.js, package-local engine, JavaScript/CSS output and negative
source-path validation, in disposable standalone `m@47e6055f8ccdccee6906ec1de387b17124e56527`
roots. This is hosted GitHub execution, not physical workstation validation.

The explicit user freeze remains binding: **no edits to `rumiai-os` or
`rumiai-tests` without fresh permission**. They were read only or not
accessed, respectively, during the release. Package-owned test workflows
are allowed and are not a substitute for claims about the paused
`rumiai-tests` repository.

### Standalone m Chromium local historical ordering realignment (2026-10-26)

Explicit user authorization: repair only independent `m`'s pre-existing Chromium snapshot comparison/upstream-availability mismatch, without touching frozen legacy `rumiai-os` or frozen `rumiai-tests`. Current canonical `PACKAGE-MODEL.md` requires that historical/ordering comparisons which are determinable locally do not fetch upstream metadata, while exact version resolution and artifact resolution still validate current upstream availability/integrity.

At `m/master@682635220b25aa50731637c601a43299f8a1a1d4` (forward from `47e6055f8ccdccee6906ec1de387b17124e56527`), changed **only** `lib/sys/sh/pkg/repository/pkg-repository-chromium.lib.sh`, its matching `res/sys/manual/pkg-repository-chromium.lib.sh`, and existing `.github/workflows/m-core-checkout.yml`. The existing `pkg_repository_compare_versions` validates repository type/platform and canonical decimal versions, then compares numeric snapshot positions via existing overflow-safe digit-length/lexicographic `LC_ALL=C awk` logic; removed only the two calls of `_pkg_repository_chromium_metadata` inside comparison. Equality and syntactically valid historical revisions now order without network and without asserting installability; `pkg_repository_resolve_version` latest/exact and `pkg_repository_resolve_artifact` retain the original upstream metadata requirements, including MD5 digest evidence. The manual was corrected to match. No changes to public function names, numeric return conventions, package launcher, download, NSS, or catalog data.

The existing m GitHub checkout-smoke on both ubuntu-latest and macos-latest now exercises real library loading, local less/equal/greater ordering, deleted/unavailable historical snapshot (`333`), very large digit positions (no numeric overflow), invalid decimal inputs, validation of extraneous repository descriptor fields, and the distinction between offline compare and metadata-required exact resolution. The test instruments **only HTTP** through a disposable command shadowing the transport; real adapter source and validation functions are unchanged. First attempted CI at `0e1297b9d9e6f60a99cb891e24173231d0f5cd13`, Actions run `40324579170`, **FAIL Ubuntu and macOS** before comparison assertions due to an invalid `http-fetch()` shell function name (POSIX identifiers cannot contain `-`). Corrected the smoke test to use a disposable external `http-fetch` command at a temporarily prepended PATH, preserving the real m adapter. Follow-up Actions run **`40324860773` at exact m commit `682635220b25aa50731637c601a43299f8a1a1d4` PASS Ubuntu and macOS**; both check jobs completed success (not inferred from the earlier failed run). Final current remote HEAD, three-file delta, manual/function consistency and separation of network access were checked against GitHub source. This is hosted smoke evidence, **not** physical validation for this new source revision.

The separate older `rumiai-tests/tests/rumiai-os/pkg-repository-chromium/contract.test` explicitly expects `pkg_repository_compare_versions` to reject a deleted upstream snapshot. That test's expectation is incompatible with the promoted local-ordering contract; it and the corresponding legacy `rumiai-os` Chromium adapter remain **pending realignment**, untouched due to the user's explicit repository freeze. Existing physical Ubuntu browser TLS/HTTPS PASS remains tied to `m@47e6055` and is not relabelled as proof for `682635220`. No outstanding known blocker remains for local historical ordering in independent `m`.

### Standalone m current-HEAD cross-package validation (2026-10-26)

User requested renewed verification of current standalone `m` after the Chromium local version-comparison correction. Mandatory preflight confirmed `m/master@682635220b25aa50731637c601a43299f8a1a1d4` before changes, current canonical RumiAI development and testing contracts, and still-frozen legacy `rumiai-os` and `rumiai-tests`. The auxiliary ChatGPT container was observed as Debian 13 x86_64 but cannot resolve github.com; remote source execution there was therefore **not claimed**. Existing GitHub Actions run `40324860773` (Ubuntu/macOS checkout smoke) on exact source commit `682635220` is PASS.

Added the self-contained `m/.github/workflows/m-composed-pkg-live.yml` verification workflow (no application/library/manual changes), creating `m/master@a033e5093d7c50b9c74127e90641f5be3ef34903`. It checks out current m into `m-source` and source-controlled **existing** public-install integration scripts from pinned `m-mk@4880b4676ed6d7f46965a41f7e9b3d4d867ddf18` and `m-jsc@952b97dd291cf178362f541129640f3375841b04` into separate trees, then executes each upstream test script **against that exact current m**, on Ubuntu and macOS. Each existing test copies m into isolated disposable runtime state and executes genuine public `m pkg install mk@v0.1.0` or `m pkg install jsc@v0.1.0` via selected real `pkg-catalog`, with managed Node.js, package-root/manual/launcher checks and actual `mk` action or `jsc` JS/CSS compilation. This does not edit the independently maintained package repos or substitute package-component mocks.

GitHub Actions run `40328421623` at `a033e509`: **Ubuntu mk PASS** (job `121591082401`, explicit output `PASS: public pkg install mk@v0.1.0, managed Node, real launcher and action`), **Ubuntu jsc PASS** (job `121591082638`, explicit output `PASS: public pkg install jsc@v0.1.0, managed Node, real JS/CSS compilation`). Ubuntu core checkout smoke in separate run `40328421657` is **PASS** (job `121591083233`). At this checkpoint, **macOS mk and jsc integration plus macOS core smoke remain queued**, not passed or failed; their final state needs to be retrieved later before claiming multi-host completion. The `jsc` log has warnings for unavailable optional JS/CSS minifiers; genuine compilation succeeded.

Physical Ubuntu operator validation for `m@a033e509` remains pending; an operator script can use a disposable local clone of the updated m and execute the pinned upstream `m-mk` / `m-jsc` tests without touching pre-existing git modifications. Previous physical Linux Chrome/Chromium/Electron NSS and browser-engine HTTPS PASS remains revision-specific to the earlier `m@47e6055` and is **not relabelled** for current m. The user's freeze on `rumiai-os` and `rumiai-tests` is preserved.

### Physical Ubuntu direct public pkg install mk and jsc PASS (2026-10-26)

Operator correctly objected that the previous proposed physical test's cloning of `m-mk` and `m-jsc` repositories to run their implementation-oriented integration scripts was not the appropriate **operator-facing validation** of `m`, even though those scripts internally call real public `pkg install`. The physical check was corrected to use only ordinary public commands on the user's current Ubuntu `PRTL-GS-01` checkout, with the user's explicit knowledge that package installation modifies the selected m checkout. Starting from existing `m@47e6055`, `git pull --ff-only` fast-forwarded to exact **`m/master@a033e5093d7c50b9c74127e90641f5be3ef34903`**, preserving pre-existing three osarch selector modifications and untracked bin/ext-linux-x86_64. Real `./m pkg install mk@v0.1.0 jsc@v0.1.0` automatically fetched current `pkg-catalog@8a346e9c1b30fa40706213cf9798720d7ffd39ff` and downloaded the published artifacts (30,810-byte mk release and 6,799-byte jsc release; host download output showed 30,810 and 6,799 bytes, respectively). No source-project git clone or direct download/install was used by the operator. Both installers returned success. `./m pkg versions mk`, `./m pkg versions jsc`, `./m pkg versions nodejs` returned `mk@v0.1.0`, `jsc@v0.1.0`, `nodejs@v26.8.2!linux-x86_64`; the corresponding `./m pkg default` calls returned those same selections. `./m node --version` executed the managed runtime and printed `v26.8.2`. Original Git status after real installation retained three pre-existing selector modifications and gained normal untracked `bin/ext/` alongside `bin/ext-linux-x86_64/`, reflecting package command projections; neither was removed.

**Validation scope:** on physical Ubuntu, `m@a033e509` real catalog update, public mk/jsc installed release acquisition, managed Node dependency, installed/default resolution and Node public launcher PASS. Executing real `./m mk` project actions and real `./m jsc` JS/CSS compilation **has not yet been done by this physical operator session**; next probe must directly call these installed commands on temporary user project inputs, without cloning package source repos, downloading scripts, reinstalling packages or modifying git-tracked product files. Hosted Ubuntu separate exact-m public-install source scripts already PASS, but are distinct evidence.

Latest check-runs for `m@a033e509` show the three Ubuntu jobs in run `40328421623` and `40328421657` **success**; all three macOS jobs in those two runs are **cancelled**, not pass and not test failure. Preserve that exact status and do not treat earlier hosted macOS PASS on `m@682635220` as evidence for `a033e509`.

### Physical Ubuntu direct public mk and jsc execution PASS (2026-10-26)

On reference host `PRTL-GS-01` with the **already installed** published `mk@v0.1.0`, `jsc@v0.1.0` and managed `nodejs@v26.8.2!linux-x86_64` on standalone `m/master@a033e5093d7c50b9c74127e90641f5be3ef34903`, the operator ran a test entirely through **public `./m mk`, `./m jsc`, `./m node` commands**, using a temporary user-authored project and no source repository clones or package reinstall. The `mk` project defined one goal `check` and operation `calculate`, running `node -p '21*2'`; `./m mk --project <temp-project> --goals` printed `check`, `--plan check` printed `calculate`, and execution `... check` printed `42`. For `jsc`, a descriptor compiled `const answer = 42;` as CommonJS export, and the managed `./m node` process `require`d generated output, printing `JSC result: 42`. A separate CSS descriptor compiled `.demo { color: red; }` into a nonempty output. The operator output concluded **`MK + JSC EXECUTION: PASS`**. Both `jsc` operations emitted `jsc.minifier-unavailable` warnings for optional `google-closure-compiler` and `uglifycss`, respectively, without failure; no minifier-specific functionality was validated. This completes the genuine physical Ubuntu public-install/default/runtime/execution work unit for these two independently packaged components at the exact m revision (preceding physical install check and this run). It does **not** prove macOS physical behavior, other standalone packages or full suite conformance.

No changes were made to `m`, `pkg-catalog`, `m-mk`, `m-jsc`, frozen `rumiai-os` or frozen `rumiai-tests` by this checkpoint. The earlier external-host CI `m@a033e509` macOS jobs were **cancelled**, not PASSED, and are distinct from the physical Ubuntu PASS. Follow-up scope for future work: current architecture analysis of bin/lib/res composition remains the active handoff's next action; do not repeat mk/jsc installation to recreate already observed success.

### POSIX context command selection: first production increment (2026-11-02)

In authorized autonomous `m`, implemented and committed:
`lib/sys/sh/context.lib.sh`, loaded by `core.lib.sh`; published matching
operational manuals `context.lib.sh` and amended `core.lib.sh`;
added `.github/workflows/m-context-shell.yml` for hosted Ubuntu/macOS
bootstrap-path tests. Current implementation resolves exact installed concrete
`cmd/` paths, handles ordered repeated package selections, replaces only its
previous PATH layer, preserves other PATH entries, rejects protected core
command collisions and cross-package command name ambiguity, and leaves PATH
and active selection unchanged on validation failure.

A synthetic local POSIX sh component fixture using the context implementation
and a minimal stub for the existing package identity parser passed selection,
override, collision, invalid target, user PATH edits and reset cases. This
does **not** validate the full real `m` bootstrap or package installer. The
hosted workflow has been published but no hosted PASS result was inspected
in this work unit. No physical host validation occurred.

The supported first-phase public grammar and behavior were promoted to
`specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md`. Crucial pending work
for the full user-requested `context` capability: automatic managed-shell
invocation (the current core only makes the function available when sourced),
coherent provider facility cmd/env/service selection and the new facility
map; profile/user/system and full-context preset resolution; protected
inheritance/propagation and NSS/home obligations; child execution context;
collisions with inherited shell functions and command hashing; concurrency/
removal semantics; and complete composed runtime testing. This is a
**partial implementation**, not a finished context engine or validated
deployment. `rumiai-os` and `rumiai-tests` were not touched.

### Runtime-separated ordinary library exports: implemented first unit (2026-11-02)

User authorized implementing the agreed runtime-separated package views
after the previous design checkpoint. In autonomous `m/master`, current
HEAD as verified during this work unit is
`3feb1f0cfa2b2bd74c82ec3aaf9e57726a6cd841`
(refresh remotely before any further edit).

Implemented in `m/lib/sys/sh/pkg/pkg-integration.lib.sh`:
- accept optional ordinary range `lib/sh/<leaf>.lib.sh` and
  `lib/java/<leaf>.jar` descriptor files, each containing a safe
  relative pathname inside the already validated useful root;
- validate descriptor identity, suffix, non-executable shell sources
  with POSIX sh parse, root containment, and real readable targets;
- materialize concrete-local `lib/sh` and `lib/java` symlinks to the
  exact package concrete `root/` on `pkg_integrate`;
- restore staging root on library materialization failure, with new
  status 21 and specific diagnostic; remove exports with the concrete.
No provider/facility declaration is needed.

Implemented in `m/lib/sys/sh/context.lib.sh`:
- reuse the existing ordered `pkg=<exact-concrete>` selection across
  present `cmd`, `lib/sh`, `lib/java` directories;
- compose `PATH` for executable and POSIX-dot library lookup and
  `CLASSPATH` for literal `<concrete>/lib/java/*` Java JAR lookup;
- preserve inherited set/unset classpath distinction, keep unrelated
  search-path edits, replace own contributions, reject duplicate
  library names and shell-library/selected-command collisions,
  validate before mutation and probe readonly target variables.
- no context-time filesystem writes, no new public operand or separate
  library selection graph.

Promoted implemented first-stage contracts to current
`specifications/rumiai-os/PACKAGE-MODEL.md` and
`BOOTSTRAP-ENVIRONMENT.md`. Updated operational manuals for
`context.lib.sh`, `pkg-integration.lib.sh` and the `pkg` command.

Added `m/.github/scripts/context-libraries-test.sh`, invoked from
`m/.github/workflows/m-context-shell.yml` on Ubuntu/macOS with Java 21.
The script targets real `pkg_integrate` and real core `context`
from an initialized `./m`, using isolated staged library-only
package fixtures and compiled JVM classes; it asserts source/JVM
version switches, actual symlinks, reset semantics, duplicate-name
rejection, readonly rejection, external PATH/CLASSPATH edits and
failure-without-mutation. **Published test workflow only: no completed
hosted CI PASS was retrieved or inspected in this work unit.**
The fixtures do not prove external catalog-backed `pkg install`,
production app launchers, or real installation migration. No physical
host validation was run.

The initial code remains intentionally bounded: `cmd/` remains the
package command-entrypoint directory (distinct from upstream
`root/bin/` executables); only sh/Java ordinary library exports are
implemented; other runtime loader semantics, Java `-cp` override behavior,
provider/child process environmental coherence, full-context presets,
global default library views, auto-init shells, user/system profile
selection and controlled inheritance remain pending. No changes to
frozen `rumiai-os` or `rumiai-tests`; no new catalog package range
was migrated to use these exports.

## Working design / open questions

### Runtime composition matrix and resource packaging choices (2026-10-26, provisional)

The user clarified that *logical resolution* means the already existing
`pkg` facility/provider selection model, not necessarily a new pathname or
URI resolver. Evaluate the current **symlink + command launcher** mechanism
against **facility/provider resolution + typed environment** as two existing
implementations of one underlying package composition intent. Do not pretend
that either mechanism already handles package-manual discovery, package-local
`lang` catalog integration or arbitrary runtime libraries.

Separate four independent axes for each published component:

1. **Distribution unit**: files bundled with one binary release, separate
   independently released component package, or distribution shared by a
   compatible family of binary releases.
2. **Logical selection**: concrete package/version, package default,
   consumer dependency/facility binding, compatibility/locale selection. The
   existing facility contract represents substitutable provider-independent
   capabilities, not automatically every ordinary library or resource.
3. **Exposure scope**: global, consumer-contextual, package-private.
4. **Physical access**: executable symlink/launcher, pre-resolved environment
   or consumer-local projection, direct private path/runtime import, or
   resource-specific lookup. A physical projection is derived from validated
   package state, never an independent graph authority.

The resource distribution-unit choice is now **closed** by the explicit
user decision and promoted in `RESOURCE-MODEL.md`: package-owned `manual`
and `lang` resources always accompany the software in the same concrete
artifact. Do not explore separate documentation, translation or
shared-major-family installable packages. Identical source files may be
reused when producing versioned artifacts. This does not decide the
independent resource-access and visibility contracts.

### `context`: accepted name and unconstrained conceptual design (2026-10-26)

The user **confirmed the exact public POSIX sh function name `context`**.
Because it will modify the invoking shell's environment, it must operate
directly in that shell when environment mutation is desired (not in a
subshell/pipeline/command substitution). The function is conceived as a
general coherent runtime-context composition and application capability,
not only a pathname lookup. The shell's normal `PATH` fast path for
default commands remains an important optimization of the same semantic
resolution system, not an independent resolver.

**Explicit user method:** first design the optimal, simplest coherent
semantic behavior **freely**, taking ideas from existing `pkg`,
facility/provider and launcher mechanisms but allowing *all* old
architecture and contracts to be reconsidered. The existing contracts
remain authoritative for the *current deployed code*, **not constraints
that prohibit proposing a better future design**. Do not prematurely
require reuse of existing internal components, schemas, precedence or
materialization details. Fresh implementation is the intended direction.
Only **after** developing the conceptual model should a second,
pragmatic stage assess portability, correctness, robustness,
performance, implementation simplicity, migration cost, compatibility
and explicit canonical realignment. Any incompatibility must be
identified and planned rather than silently inherited or silently
changed in current code.

Still-open design dimensions: what an activated context means;
selection and binding of packages, versions, facilities and private
components; single-context replacement and child inheritance; whether `context` also has
pure queries; environment variable/path precedence and security;
validation before changing the invoking shell; symlinks and cached
views versus direct variable/projection application; lifecycle of a
resolved context across updates; the range of output/side effects
needed by non-shell runtime consumers. These are questions, not
new accepted API signatures or new universal `LIB_PATH` requirements.

Do not modify frozen `rumiai-os` or `rumiai-tests`. No implementation
or specification promotion has been requested in this naming/design
checkpoint.

### Declared environment inheritance and propagation (2026-10-26, required context behavior)

The user specifically requires that `context` derive its effective
environment from **explicit request parameters and specified rules for
inheriting/passing values between contexts**, including a way to pass
selected incoming variables through nested composition without overwriting
them. A plain last-assignment-wins merge is not a sufficient semantic
contract. The rule should remain meaningful for direct shell application,
package launcher transitions and nested process execution.

Current-state *evidence only*: `PACKAGE-MODEL.md` documents
`m_ENV_DO_NOT_OVERRIDE`, a single-invocation request to carry validated,
already-present caller variables to the final process despite subsequent
package/provider/user environment layers. It distinguishes unset from
present-but-empty values, rejects missing and duplicate identifiers and
control-plane variables, and does not prevent normal dependency and HOME
state preparation. In `m`, the launcher captures overrides before
environment application, and the optional NSS browser integration uses
the final effective `HOME` (including a trusted nested override) before
executing the browser. `TLS-TRUST.md` specifies centralized approved
additional CAs, per-effective-HOME NSS database projection on Linux and
no coupling of writable NSS state between distinct package/service HOMEs.
Do **not** assume preserving an arbitrary `HOME` assignment is itself
sufficient to implement Chromium certificate trust.

During unconstrained conceptual design, address at least:
- for each relevant value: whether it is unset, set-empty or set-nonempty;
  source identity, explicit assignment, inherited value and allowed override;
- ordering/precedence between inherited, explicit, package/provider and
  nested contexts, including protected propagation that cannot be
  silently replaced and intentional explicit overrides when permitted;
- different operation kinds where appropriate (retain, assign, remove,
  ordered search-path composition), with a deterministic conflict policy;
- which propagation rules survive into children and grandchildren, how
  trust/control variables stay separate from ordinary application env,
  and whether child contexts are isolated/replaced without a restore stack;
- validation before modifying the caller's POSIX shell, minimal exported
  data, and consistent environment *and* required derived side effects
  (e.g. NSS synchronization for the actual effective browser HOME);
- explicit scenario: an outer approved browser context supplies a value
  that is declared preserved; an intervening package attempts to redefine
  it; the next nested Chromium/Electron launch receives the intended value
  and its matching authorized trust projection, or fails deterministically.

These are **behavioral requirements and design questions**, not names of
new public policy operators or an instruction to adopt the old override
mechanism. Favor free first-principles modeling, followed later by
pragmatic comparison against current implementations/contracts.

### Environment-first resolved contexts and optional command views (2026-10-26, working design)

The user proposes maximizing the representation of **resolved context
values in shell environment variables** rather than requiring consumers
to re-read filesystem selectors, follow many links or invoke resolvers
individually. This does NOT imply removing the authoritative persistent
configuration, package payloads or state from filesystem storage:
the environment should primarily be a derived, ready-to-consume
projection of the selected context. The POSIX sh `context` function
must still honor explicitly requested parameters and declared
inheritance/protected-propagation rules through nested contexts.

Concrete motivation: a consumer that currently invokes
`state-path` separately for package `conf`, `cache` and other areas
could receive those already selected paths after a **single**
`context` call, with names such as `m_CONF_DIR` and `m_CACHE_DIR`
used by the user as examples, not yet new public variable contracts.
Similarly the selected osarch, user-state choice, system-state profile,
package concrete, provider-related paths and resource roots may be
calculated and exposed to the extent relevant to the consumer.
Avoid exporting a giant Cartesian product of all state scopes/areas
or eagerly creating absent state directories. Distinguish state path
identities and semantic selector paths from immutable physical targets
so context switching does not silently introduce stale assumptions.

The user also observes that the traditional global/default command
`PATH` symlink directory is only a *special case*: since multiple
versions and facility providers can coexist, selected consumer contexts
may optionally have **prepared filesystem command views** comprising
symlinks to the appropriate installed package entrypoints, with each
shell context selecting its corresponding directory through PATH.
This can retain native shell command discovery efficiency even for
non-default versions, but creation of per-context bin directories
is only a candidate materialization tool, to be justified by actual
benefit and measured overhead. Any command link must preserve required
launch/environment semantics and validated package identity, not
bypass a needed launcher.

Conceptual consequences to analyze *before* implementation:
- one prepared, coherent runtime environment for repeated consumer
  operations; minimize repeated resolver processes/graph traversals;
- make context activation and replacement idempotent, avoiding PATH
  growth, duplicate entries and stale inherited context metadata;
- define snapshot vs live selector semantics, when context needs
  refreshing after state-profile, version, facility or language changes;
- distinguish exported values needed by child processes from
  current-shell-only function/state metadata, and ensure requested
  propagation protection remains in force across nested launches;
- ensure non-POSIX consumers use valid runtime-specific module/library
  loading mechanisms (no assumed universal LIB_PATH);
- assess shell environment size, collision/precedence, secret exposure,
  trusted identity/permission boundaries, and failure-safe application;
- compare direct exported paths, selective provider environment,
  and optional per-context symlink views for simplicity, update cost,
  cleanup, concurrency and normal use performance.

Use current `state-path`, bootstrap semantic roots, provider-environment
materialization and global command links as *evidence* only: the user
has expressly authorized first-principles architectural exploration
without binding the new ideal model to current `pkg` or launcher
contracts. This remains working design, not a promoted contract or
implemented runtime behavior.

### `context` lifecycle: one active context per shell, replaced until exit (2026-10-26)

**User simplification adopted as the new design direction:** do not model
a stack of activated contexts and do not expose a "restore previous
context" operation. The live context belongs to the invoking POSIX
shell and lasts until it is replaced by another resolved context or
the shell/process terminates. Explicit and protected inheritance
policies still govern what may flow into an intentionally derived
context or child process. Derivation is a *composition rule*, not
push/pop activation or preservation of an old activation stack.

**Conceptual lifecycle, candidate mechanics**:
1. *Request*: choose the consumer and any explicit package, provider,
   osarch, state scope, profile, locale and inheritance policies.
   Unspecified choices may come from permitted incoming context
   state and configured persistent defaults.
2. *Prepare*: validate/resolve a complete coherent selection, calculate
   relevant state/resource/command roots and variables once, preserve
   provenance and protection policy, and prepare any useful derived
   symlink command view. This stage must not partly mutate the shell.
3. *Apply or replace*: apply the prepared environment to the invoking
   shell. If context A was previously active, replace **only A's owned
   contributions** with the new context B: unset keys no longer owned
   or supplied by B, update changed keys, avoid accumulating A's PATH
   segments and enforce inheritance/policy conflicts. Applying B again
   must not duplicate B's contributions. Replacing A is NOT equivalent
   to arbitrarily appending B atop A.
4. *Use/propagate*: consumers use the already selected variables, paths
   and optional command-index views; an integrated child context
   obtains the declared propagated values AND relevant rules. Child
   modifications cannot mutate its parent shell. POSIX exports of
   values alone do not enforce policy for arbitrary unintegrated apps.
5. *End*: the live shell terminates; no shell-environment restore or
   stack unwind is required. Temporary or cached filesystem
   projections, if used, require a safe independent reuse/GC policy:
   POSIX shell exit is not a reliable global cleanup notification.

The old restoration problem is removed, but **replacement still needs
a small amount of ownership information**, not a full historical
snapshot stack. Study how a coherent new environment projection can
be computed from a stable underlying host baseline plus policy-
permitted inherited values while preserving legitimate user changes.
For `PATH`, either track context-owned entries without ambiguous
subtraction, or reconstruct from a controlled baseline and the new
selected command views. Do not silently discard unowned PATH edits
or overwrite protected env changes. A failed preparation must leave
the *existing* active context effective; a narrow trusted apply step
should avoid partially switching to B. Exact rollback of arbitrary
shell code is not required or promised.

**User-proposed elimination of filesystem `current` selectors**:
- Global `state/system/current`, `state/user/current`,
  `res/*/lang/current` and similar mutable selectors are *current
  implementation*, not inherently necessary in the ideal model.
- Distinguish a *persistent default preference* (read when a new shell
  or independent process initializes) from a *shell-active selected
  identity* and from a *concrete immutable package/profile path*.
- The intended context can expose pre-resolved profile, user/state,
  locale, osarch, provider and resource variables directly without
  following these `current` selectors at every access. Prefer clear
  pinned selection semantics for a non-default consumer: global
  changes must not invisibly retarget its running environment.
- Persistence of defaults across independent shells still needs some
  durable representation; it does **not** imply `current` symlinks are
  required. Any alternative must avoid secretly recreating equivalent
  mutable indirection under a new name, while remaining resilient to
  configuration changes and protected against unauthorized identity
  inference. It must not conflate RumiAI's user-state namespace with
  authenticated POSIX user identity.
- Normal global command discovery through a bounded PATH/symlink
  index remains a possible **performance optimization**, including
  a separately prepared view for selected non-default package/provider
  versions. This is unrelated to retaining filesystem `current`
  selectors as runtime identity authority.

**Revised acceptance scenarios to test later**:
A. `context(A)` prepares complete state/locale/provider/command
   references with one shell function call and no repeated state-path
   processes for normal consumer operations.
B. `context(A)` then `context(B)` in the same shell leaves only B's
   managed env/path contributions; repeat B has identical results,
   with no stack, pop or restore.
C. A protects a value (including a valid empty value when declared);
   a derived B cannot silently overwrite it, and Chromium/Electron
   trust synchronization matches the effective browser HOME.
D. A preparation failure leaves A unchanged. A valid B apply does
   not depend on running A's teardown/restoration hooks.
E. New independent shells pick a configured default without sharing
   another shell's mutable active context; shells bound to A and B
   can coexist with different package/provider/profile/locale choices.
F. Persistent default/profile/provider changes affect *new*
   resolutions, not already pinned active selections. Mutable
   symlinks used for global PATH discovery must not silently
   override a context-specific concrete version.
G. Unowned user PATH/environment changes during an active context
   are handled according to a deliberate rule rather than clobbered
   accidentally; side-effect projections remain valid and safely
   collectible independently from shell-exit signals.

**Still open**: exact public parameters and whether a pure query is
useful, explicit vs derived inheritance precedence, how to track
context ownership compactly in POSIX sh, policy for user-edited
managed variables, default preference representation, compatibility
with existing consumers after removal of `current` selectors,
environment projection lifetime and filesystem cache/GC, and
pragmatic performance/security tests. Prior current
`STATE-MODEL.md`, `BOOTSTRAP-ENVIRONMENT.md`,
`LANG-BOOTSTRAP.md`, `CURRENT-MODEL.md` and package contracts
still describe today's implementation and must be explicitly
realigned as one coordinated future implementation work unit if
the ideal design is adopted.

### Context domains, selection axes and consumers (2026-10-27, model; core design confirmed 2026-10-28)

The user **accepted the six core design choices** summarized under
"Fixed task-local choices": one active context kind per shell;
independent/composable system and user domains; identifiable consumer;
per-dimension defaults; selected profile/user identity not dependent
on `current` symlinks; replace-until-exit without restoration.
The matrices and scenario distinctions below guide the next design
step. Specific signatures, automatic inference rules, persistent
default representation, user-profile model and migration remain open.

**Do not create one mutually exclusive mode enum** out of these labels:
- `system` / `user` describe **state/configuration scopes**;
  a consumer may require both at once, e.g. system trust/configuration
  plus separate user-specific writable data;
- `default` is a **selection policy for unspecified dimensions**,
  not a state scope, actor or executable consumer;
- `pkg` is an **owner class and possible consumer identity**, not a
  third system/user state scope;
- a `profile` identifies a chosen configuration within an applicable
  scope (current canonical `system` profile and `user` binding differ;
  generalized user-profile selection is a *new candidate*, not a
  description of today's contract);
- the POSIX effective execution identity is a **host security
  principal**, never derived merely from the RumiAI logical user/profile
  label. It governs real filesystem permissions.

**Conceptual input axes**:
1. requesting entrypoint/execution mode: an ordinary host shell,
   m-initialized interactive shell, m command, managed service,
   application/package launcher or other child process;
2. consumer identity: interactive m session, technical m facility,
   concrete package/application, service instance, build/test job;
3. system profile and optional user-state identity/profile as
   independent bindings; requested state owner and areas determine
   the relevant directories and write scope;
4. concrete package/version, service instance where applicable,
   dependency/capability requirements and provider selections;
5. osarch, locale, runtime-specific resource/loading needs;
6. explicitly supplied overrides and **inherited value + propagation
   policies**, including protected values, unset/empty distinction,
   allowed override and PATH-composition rules.

**Default and start-of-shell proposal**:
An OS-native shell begins with a host environment; it is not
automatically an m context merely because its process exists.
An m-managed interactive shell may initialize a user-oriented
"default selection" *resolved context* while simultaneously
holding the applicable system-profile bindings, host POSIX identity
and system capabilities. "Default" is calculated per dimension
from explicit permitted input, declared inherited policy and
persistent selected preferences, rather than implemented as a
`current` symbolic-link context. A separate `m command` run as a
child cannot set environment variables in the calling shell;
a directly sourced POSIX `context` function can.

Service and maintenance execution have distinct *requested
consumer/state configurations*, not different context engines:
a system service may use system-owned package state with a
service-specific State Instance and a separately constrained
non-root host principal. Neither mere root UID nor setting
`scope=system` implicitly authorizes administrative operations.
An m-initialized consumer may use system-owned read-only resources
and user-owned state concurrently; access rights remain external
to semantic selection.

**Who consumes**:
- interactive shell, scripts and administrative commands: use the
  effective export/PATH projection directly;
- package/application launchers: select concrete package and
  capabilities, state directories, user/app overrides and child env;
- service launchers: package plus service instance, scope, host
  principal and supervision/trust side effects;
- build/test tools: optionally choose distinct package/provider
  versions and development/test profiles per process/shell;
- libraries, manuals, language and runtime adapters: read the
  already-selected roots/catalogs on demand, not solve the graph
  for every library import/message lookup;
- child/embedded browser or runtime processes: inherit only declared
  exports and honored propagation policy via trusted integrations.

**Proposed request/selection algorithm** (policy design, not CLI syntax):
- resolve which consumer is being prepared from its trusted entrypoint
  if derivable; demand an explicit identity only if ambiguous;
- collect explicit selections, then inherited approved selections,
  persistent per-dimension preferences and safe inferred defaults;
- check protected-value conflicts *before* precedence application:
  an explicit attempt to override protected inherited data fails
  unless an authorized override rule explicitly permits it;
- derive system profile, user binding, package concrete, provider graph,
  locale, osarch and relevant state areas, then validate and apply a
  single coherent environment projection;
- when context A is replaced by B, do not treat every A-owned export
  as an implicit inheritance source: carry forward only permitted
  inherited values/policies and non-owned host environment. Do not
  duplicate PATH entries or retain A-only state variables.
  One active context per shell; no restore stack.

**Minimum scenarios**:
A. Fresh m-managed interactive shell: system profile P1, user logical
   binding U1, default package/provider selections; no package
   consumer argument required simply to use the shell.
B. Same user opens a second shell bound to P2/U2 while first stays
   P1/U1; no shared mutable `current` path changes either shell.
C. A command of concrete package X: user area paths, X roots,
   X's bundled manuals/language, compatible provider concrete;
   the calling interactive shell is not modified by execution.
D. System service: system-owned service-instance `home`/`conf`,
   system trust policy and separate real POSIX service account;
   not confused with a normal user-scope package launch.
E. Nested Chromium/Electron: protected effective HOME and its policy
   survive recognized child composition; NSS projection corresponds
   to the actual final browser HOME.
F. Fresh shell or process with no persisted user/profile preference
   receives a safe, documented default or a precise failure; never
   invent an authenticated user identity from a logical profile name.

**Still open**: whether global defaults should be per system/user
profile or layered; if there should be both named system and user
profiles (today only system profiles are canonical); conflict
precedence, exact schema and minimal public parameters; trust
boundary for inherited context metadata; whether interactive context
is automatically applied by a shell startup integration or only via
explicit m initialization; and whether some technical m bootstrap
paths must be available before full context resolution.
Do not promote conceptual terms to file layout, public keys or CLI
until evaluated and confirmed. `current` elimination and single
active shell context remain the intended redesign, not yet an
implementation in the current code.

### Startup defaults and optional complete presets (2026-10-28 proposal, accepted direction 2026-10-29)

The user has confirmed automatic plain-`context` initialization,
selective override-only calls and unified package/service/child use,
with **per-dimension defaults (B) plus composable named full-context
presets (C)**. A single undifferentiated global bundle (A) remains
rejected as the architectural foundation. The call syntax, preference
schema and environment variable names below remain illustrative.

**Candidate A: one complete persistent global default** for every
managed shell. Easy to reason about for the initial case, but a poor
fit for concurrent user identities, provider selections, package
versions and service instances. **Not recommended** as the base.

**Accepted design B: independent defaults by selection axis**.
A new managed interactive shell combines independently configured
system profile, optional logical user binding, locale, platform,
installed package/provider defaults and any explicit/approved incoming
selections. Missing parameters are resolved per dimension; no global
`default` context object is required. A POSIX host shell is
unchanged until it deliberately initializes m/context; a managed
shell may initialize its normal context during its supported startup
flow. The caller supplies only non-derivable differences.

**Accepted design extension C: named complete-context preset** selecting
several dimensions at once through the *same* B resolution engine,
not a new type/graph authority. The user illustrates this as
`context full-context=my_full_profile`; an explicit per-dimension
argument could override the preset's corresponding choice when
inheritance protection and constraints allow. Exact grammar and
configuration format are not yet approved. Do not introduce named
user profiles merely to create unnecessary symmetry with system profiles.

Illustrative interaction surface (not committed syntax/API):
```sh
context                              # prepare ordinary managed-shell defaults
context profile=development          # replace only effective profile selection
context user=work locale=en_US       # select logical user/locale; derive the rest
context consumer=mk version=v0.1.0   # prepare mk context when explicitly requested
```
The function must already be sourced/available in the calling POSIX
shell for shell mutation. A separately started package command,
service or other child resolves its own context in its process and
cannot rewrite the invoking interactive shell. Consumers whose
identity is unambiguously known through a trusted launch path should
not have to restate `consumer`. Example values and keys above are
**illustrative only** and must not be promoted as names.

**Current selection ordering (supersedes the earlier candidate fixed-source
precedence):** establish only the default/fallback **baseline** for
unprovided dimensions from applicable consumer constraints, declared
inherited choices, logical-user/system preferences and deterministic
technical values; resolve any conflicts between those sources through
an explicit policy still to be defined. Then fold the **ordered caller
operands** from left to right, expanding complete presets in place.
There is no fixed preference between an operand originating in a user,
package, system profile or complete preset; the later overrideable
binding wins. Distinguish unset from empty and deletion from absence.
Dependency compatibility, state ownership, protected inherited values
and host POSIX access controls remain independent hard constraints:
a protected binding cannot be overwritten silently by a later operand.
An ordinary context replacement must not carry all A-owned variables
into B as though they were automatically authorized inherited inputs.

Examples to validate:
1. m-managed interactive shell, with no explicit args, selects
   system profile `office`, logical user `development`,
   `linux-x86_64`, locale `it_IT` and available default
   providers. Its state/cache/resource paths are pre-resolved
   env outputs and its PATH contains only the selected relevant
   command projections.
2. A second shell selects another system profile and user binding,
   without altering the first shell or changing a global `current`
   symlink; independent processes see their own exported env.
3. A concrete package `mk` launched from the first shell
   selects its own package graph, instance state and provided
   resource roots while retaining applicable system policy;
   the parent shell remains unchanged.
4. A service instance picks system-scoped writable state,
   service-specific identity and provider requirements; a
   separately configured non-root POSIX account determines
   actual filesystem permission. This is not equivalent to
   `user=service`.
5. A child browser/Electron execution preserves any explicitly
   protected effective HOME across intermediate context resolution
   and triggers the authorized NSS projection for that effective
   browser HOME.
6. Switching active contexts A -> B removes A-owned exported state
   variables and PATH entries, deduplicates B, does not restore A,
   and does not accidentally clobber unowned host edits.
7. A later persistent default change affects *new* shell
   initialization or deliberate re-resolution, not a currently
   pinned concrete version. If implicit selection is ambiguous
   or invalid, fail instead of guessing.
8. A host POSIX shell not managed by m remains independent; merely
   being a process does not imply it should be rewritten to the
   current configured m selection.

Important design question: persistent defaults must exist beyond
one shell's lifetime, but need not use `current` symlink selectors.
A small authoritative preference source read on initialization
is a **possible implementation**, not yet an approved path/file
schema. Separate the enduring choice from the resolved active
identity, and avoid requiring external catalog/network access
for ordinary offline startup. Decide missing-user/default policy
without conflating RumiAI's logical user-state identity with a
POSIX authenticated principal.

**Next design work**: choose the minimum caller-facing parameter
grammar and explicit-vs-inherited semantics; define which defaults
are allowed at each scope, how conflicting provider/version
requirements are reported, and the necessary small shell-resident
metadata for safe A -> B projection replacement. Validate complete preset expansion and per-dimension override behavior
using the same resolver as plain `context` and consumer-specific requests.

### Derived command views replace the fixed root bin: accepted design direction (2026-10-29)

The user wants to remove the permanently fixed `bin` directory
from the **root m layout**, making command-directory + PATH
an implementation strategy of the context-resolution system.
The physical executables remain owned by core or the installed
immutable package concretes; only the *published command namespace*
is derived from selected versions/provider bindings. A PATH-visible
`bin` grouping is a publication surface for `cmd` entrypoints, not
a substitution of the package's upstream binaries for those commands.
A context chooses command symlink view(s) and applies an ordered PATH.
This extends the default-case symlink index to alternative pinned
versions and facility providers. The user accepts it as a
design direction; names and physical cache layout are undecided.

**Illustrative only; not proposed real paths**:
```text
installed executable payloads: <core> / <pkg-A@1> / <pkg-A@2> / <provider-B@3>
          |
          v
context selection -> immutable/coherent command views (symlinks)
                       + environment values
          |
          +--> plain context  : PATH=<default-view>:<host-path>
          +--> pinned context : PATH=<specific-override-view>:<base-view>:<host-path>
          +--> complete preset: expanded selections -> same context mechanism
```

The `default` command view should expose *one selected applicable
installed concrete per published command*, with user-preferred
"latest" candidates when allowed; this must not silently reinterpret
existing configured package/facility defaults or fetch arbitrary
upstream latest at shell startup. Explicitly distinguish:
(a) newest **installed** applicable concrete selected deterministically,
(b) configured package/facility default, and (c) live upstream latest.
Resolve the policy and handling of command name collisions before
committing semantics. A profile's explicit pin takes precedence over
an otherwise eligible default, subject to dependency consistency.

Critical conditions of use:
- **Bootstrap boundary:** `m` must load its fundamental POSIX shell
  mechanism and resolve its physical root without relying on an
  as-yet-unbuilt context view or an unavailable root `bin`. Core
  executable ownership/location is separate from exported command
  lookup. Missing/stale cached views need an offline rebuild or
  error behavior that does not make m unstartable.
- **PATH layering:** context-specific override views can precede
  baseline/default views; an override of a command name must reliably
  win. Name collisions, transitively required commands and facility
  constraints must be handled by one resolved graph rather than PATH
  lookup guessing dependency compatibility. No repeated A-owned
  segments when replacing A with B; preserve allowed host PATH and
  protected inherited contributions.
- **Consistency:** validate concrete identities, targets and launch
  obligations; a symlink to a managed executable must not skip
  required launcher/environment/state/TLS logic. Resolve aliases
  or wrapper entrypoint requirements using the chosen new architecture.
- **Freshness:** avoid mutating a command view used by an already-pinned
  shell. Prefer coherent revisioned/immutable views with safe publication,
  then repoint new context activations to new revisions after
  install/uninstall/default changes. Plan retention and garbage
  collection without depending on POSIX shell-exit notification.
  The bare name `default` can express *selection policy* without a
  mutable global `current` filesystem indirection in active PATH.
- **Cost:** do not eagerly allocate a fresh bin for every invocation.
  Consider reusing identical content-keyed views, producing narrow
  override views only for changed command bindings, or a single
  flattened context view; compare filesystem creation/rebuild costs,
  PATH lookup overhead, cache invalidation and number of symlinks.
- **Scope:** only components genuinely looked up by command name need
  PATH/symlinks; state dirs, libraries, resources, selected profile,
  user/osarch and provider data remain primarily environment projections.

Design questions, not yet approved facts: physical replacement
location for core commands after root bin removal; command-name
collision policy; newest-installed vs configured-default semantics;
whether layered override views or one complete view has better
robustness/performance; launch integration; view freshness/retention;
how to keep stable concrete selections across parallel shells and
concurrent package transactions. The user's high-level preference
for context-derived bin directories should **not** accidentally
create an unbounded per-shell cache or hidden mutable global selector.

### Ordered selection folding and bin/PATH feasibility (2026-10-29, analyzed candidate)

**User proposal, recommended:** parse and apply all command-line
operands strictly **left to right**, expanding each named
`full-context` bundle exactly where it appears in the operand
sequence. There is no intrinsic priority for selection *origins*
such as user, package, system profile or complete preset.
Selections should be normalized by **logical binding key**:
two package selections for different package identities coexist;
a later selection of the *same* package/version binding replaces
the earlier selection, with the analogous rule for a facility,
profile, locale and other dimensions. A later profile may implicitly
replace several bindings. Resolve the final aggregate once, then
validate compatibility and derived dependencies. Do **not** source
untrusted or arbitrary user commands as operand transformers.

Illustration (not public argument grammar):
```text
context full-context=development pkg=node@v24
  => development expanded, then node=v24

context pkg=node@v24 full-context=development
  => node=v24, then development expanded (possibly node=v26)

context full-context=development user=work provider=js:node@v24
  => preset, then selected user, then provider pin
```
The *order of explicit selections* is not an override authorization
for a protected inherited HOME/variable, a capability-compatibility
invariant, or real POSIX filesystem permissions. Separate overrideable
choices from mandatory constraints, protected propagation and derived
facts (such as detected host osarch). Overwriting a provider binding
may invalidate a prior consumer constraint and must trigger an error
at the final graph-validation stage rather than a silent compromise.
Clarify semantics of explicit unselect/mask if a later selection wishes
to *remove* a command or provider entirely, not merely replace it.

**Important PATH mapping:** left-to-right **selection** folding and
left-to-right **PATH directory lookup** have opposite ordering if
each operand produces an additive new command view: later operands
must end up **earlier in PATH** to win. Example:
`context full-context=dev pkg=node@v24` might lead to
`PATH=<node24-override>:<dev-or-default-view>:<host>` once resolved.
This mapping is an implementation strategy, not a separate
selection precedence rule.

**Identified key limitation of naive stacked directories:** PATH
can shadow but cannot remove a command already available in an
older/lower-priority directory. Example: if an earlier base view
contains `foo`, a later overlay that simply omits `foo` does not
hide it; `foo` is still found in base. A deliberately disabled
package or an incompatible default provider therefore requires
a recomputed base that excludes it, a single complete effective
view, or an explicit masking mechanism with carefully specified
observable behavior. Do not claim absence in upper view is an
unset operation. A simple local POSIX `/bin/sh` experiment
verified first-match selection, fallback to a lower PATH directory
on upper absence, and non-discovery only after removing the
underlying base directory from PATH; this is POSIX search-path
mechanics evidence, **not RumiAI product validation**.

**Two materialization options**, both derived from one fully validated
effective command map (not independent PATH-based facility discovery):
- **Flat complete view**: one immutable generated `bin` directory
  per unique compatible map, containing exactly the public command
  names selected for the context. Simplifies negative selection,
  collision detection, PATH length and a coherent snapshot. Can
  require a greater initial symlink build than narrow overlays.
- **Layered views**: immutable/reusable base command view plus small
  override directories prepended to PATH in reverse effective
  selection priority. Cheap for narrow positive changes and
  potentially shareable, but requires handling exclusions, aliases,
  command collisions, incompatible shadowing, PATH growth and
  obsolete directory cleanup explicitly. Always derive the layers
  from a validated map: mere concatenation of arbitrarily built
  provider bins is insufficient.
- **Hybrid evaluation**: normalize to one resolved map regardless,
  then use a complete flattened view by default and optional
  safe override layers when the change is purely additive or
  replaces known commands, with verified no-accidental-fallback.
  Avoid building an extra complexity framework until realistic
  performance evidence justifies the hybrid.

**Further hard limits to design around:**
- `PATH` yields **one effective external executable per command
  name in a process** (subject also to shell builtins/functions and
  search/cache behavior). It cannot simultaneously satisfy two
  independent consumers that need incompatible versions under the
  same name; their *child process contexts* or direct concrete paths
  must differ rather than expecting magical per-consumer PATH search.
- A selected provider may need non-PATH env, private resources,
  `HOME`/TLS/NSS setup and a trusted launcher. The symlink itself
  does not enforce compatible state or policies. Preserve concrete
  identity from execution entrypoint even through a generated view.
- `m` bootstrap and fundamental core functionality must be invocable
  via known physical paths before any generated bin exists. Eliminate
  the fixed `$m_ROOT/bin` *published namespace* as desired without
  making context initialization circular.
- `default` view must be locally and deterministically selected;
  explicit `pkg default` and facility defaults are not synonyms
  for newest installed or upstream latest. Collision policy with
  protected core commands, host PATH and same-name packages is an
  explicit semantic choice.
- Publish generated views coherently after validating link targets.
  Prefer immutable content-addressed/revisioned views, reusing equal
  selections across shells and preventing partial in-place mutation
  of an active shell's PATH targets. Installation/removal should not
  silently change pinned bindings; define lifecycle/references and
  safe garbage collection without shell-exit callbacks.
- Rebuild the managed PATH section on context A -> B rather than
  blindly prepending; preserve allowable unowned host entries and
  correctly handle shell command-hash and noninteractive child
  invocation behavior. Public resolution must not be implemented
  solely by `PATH` search.

**Revised recommendation after the user's implementation-simplicity
correction:** accept left-to-right folding as the selection contract,
while treating **already materialized, reusable command-directory
layers + ordered PATH** as the *default implementation candidate*.
The physical published views are maintained at package install,
uninstall, default/provider selection or explicit configuration
change, not rebuilt on every `context` call. Keep a normalized
logical selection map for compatibility/collision validation if it
proves useful, but this does not imply creating a flattened bin.
Materialize a special flattened view only if a concrete requirement
(e.g. true negative selection) and measured tradeoffs justify it.
Do not create a general masking abstraction merely to satisfy an
unrequested theoretical feature.

### Bootstrap sys and static bin/PATH composition: reconsidered after user correction (2026-10-29)

The user pushes back on the previous default recommendation of one
generated flat bin **per fully resolved context**: that model would
require unnecessary filesystem materialization on context activation
and a complex cache/update lifecycle. The user proposes:
- the always-available bootstrap commands in a stable core `sys`
  directory (an `m-sys` package is possible but not justified just
  for bootstrap); the core can load and execute `context` without
  first preparing a package command view;
- default `bin` symlinks maintained by pkg/default operations
  and available before `context` is called, plus per-version/provider
  command bins pre-created at install/configuration time;
- `context` only selects/combines applicable existing bin paths,
  normally prepending pinned/override command dirs ahead of a default
  bin, while simultaneously preparing non-PATH environment values;
- no general filesystem rebuild or per-shell bin creation merely
  because context operands or a named full-context preset are
  evaluated. A profile is an ordered selection of prepared
  candidates, not an instruction to generate a fresh bin.
This is the **preferred model to evaluate first**; exact bin ownership
and paths remain unapproved.

Concrete minimal POSIX /bin/sh experiment (Linux host, independent
temporary directories, not RumiAI product test): a static
`default/node -> <node-v26>/cmd/node`, alongside
`<node-v24>/cmd/node`, gave Node v26 for
`PATH=<default>:<host>` and Node v24 for
`PATH=<node-v24>/cmd:<default>:<host>`, with no context-time
symlink changes. Removing the pinned path returned v26. This
supports a simple, pre-materialized override architecture.

**Correction to suggested negative-mask behavior:** a dangling
symbolic link in the earlier PATH directory does **not** hide a
same-name executable in a later PATH directory. Tested on Linux
`/bin/sh`, `dash`, `bash`: all resolved and executed the lower
executable with an upper dangling symlink (also when the upper
symlink referred to a non-executable file). A symlink to an
*existing executable stub* can stop fallback by executing the
stub, but the command remains discoverable and gains stub exit
semantics: this is **not a true deletion**. A profile must either
accept inherited default commands as always available, choose a
different set of base bins/exclude their paths when an explicit
negative selection is required, or separately implement such
negative-selection semantics. Do not complicate the common path
for an unconfirmed deletion requirement.

**Meaningful differences that still require decisions:**
- **Default freshness:** a shared mutable symlink
  `<default>/node` updated from v26 to v28 means that an *already
  running shell using that default PATH* will begin seeing v28
  on a later command invocation. By contrast a shell prepending a
  stable concrete v24 cmd directory stays pinned to v24, assuming
  the installed concrete is retained. Choose deliberately whether
  default is live or snapshot; user preference for "latest" might
  favor live default. Avoid claiming both pinning and live updates
  for the same directory without separate selections.
- **Versioned command directories:** current installed package
  concretes already include managed `cmd/` entrypoints validated
  by the package launcher. They may be exposed directly in PATH or
  via prebuilt symlinks, but preserving command identity and required
  launcher/provider/HOME/NSS environment setup remains mandatory.
- **Resolution/compatibility:** the physical PATH first-match rule
  is useful for command overrides but is not sufficient to select
  providers subject to the consuming package's dependency/ABI
  constraints or to ensure that non-PATH variables match the
  selected commands. `context` still resolves/validates the
  applicable graph, without necessarily materializing new views.
- **Name collisions:** if two package command directories publish
  the same name, the earlier PATH directory wins. Require an
  explicit deterministic policy or a detected conflict when that
  would contradict the requested selections. Shell builtins,
  functions and host PATH are separate lookup considerations.
- **Deletion is optional:** if disabling/hiding a lower-priority
  command is not a supported operation, this limitation is not a
  blocker. If it is, removal must affect the *effective lookup
  namespace* (e.g. omit a base directory) rather than rely on a
  dangling symlink. Validate intended behavior before adding
  syntax or a masking layer.
- **Update concurrency:** install/default operations maintain the
  default bin; consider atomic publication of changes and
  concurrent readers. Static per-version bins should be stable.
  Define what uninstall may remove while still used by another
  shell; this is a separate package-retention problem, not a
  reason to rebuild bins at context-time.
- **PATH replacement:** shell context A -> B must replace the
  context-owned directory segment and keep permitted host PATH
  edits and protected inherited env; never prepend endlessly.
  Re-evaluate command hashing/caching after a PATH change.
- **Bootstrap scope:** a core `sys` directory for bootstrap does
  not automatically mean every technical utility belongs there;
  keep the minimal core/package boundary. The exact physical
  relocation of existing core commands requires later coordinated
  specification and runtime realignment.

**Recommended reference cases:**
1. No-argument `context`: adds already maintained default bin,
   core sys bin and inherited host PATH; no symlink created.
2. Select concrete v24: prepends existing v24 command directory
   ahead of default; no filesystem write.
3. Change concrete v24 -> v26: drops only A-owned PATH entry,
   exposes already installed v26; B invocation is idempotent.
4. Update default v26 -> v28: document whether a live-default
   shell sees the change and ensure pinned v24 shell does not.
5. Attempt to mask `foo` by creating an upper dangling symlink
   above a lower executable: verify lower is still found.
6. Provider-specific package launch: PATH command version and
   provider environment agree, and launcher sees the correct
   package concrete and effective HOME.
7. Two independent concurrent shells: use distinct selected
   version directories without mutating each other's bindings.

This supersedes the earlier **flat-view-first** implementation
preference, while retaining a complete logical selection and
compatibility check, the user's left-to-right operand rule,
environment propagation and the context-derived (rather than
root-fixed) executable namespace.

### pkg-owned latest/default/policy selectors and reusable bin groupings (2026-10-29, user proposal under refinement)

**Exploratory user proposal:** `bin` views are pkg-subsystem-owned state,
and each groups command names from multiple installed packages.
For each package name (scoped by applicable platform/package class),
consider `latest`, `default` and
`default-policy=auto|manual`. Default policy is `auto`;
when a new installed candidate becomes latest, default follows it;
manual pins a specific default until intentionally changed.
Materialize `bin/latest` and `bin/default` automatically,
plus explicitly requested named groupings. Apply analogous selection
policy per facility compatibility version. Pkg owns symlink creation,
updates and grouping. Context only composes selected existing
directories into PATH, respecting ordered caller operands. These
are user suggestions, NOT approved concrete paths, public field
names, commands or final behavior.

**Recommended semantic separation**:
- pkg `conf` stores the authoritative selection/policy;
- installed package concretes own immutable command payloads;
- pkg-owned `cache` or equivalent derived state holds regenerable
  grouped `bin` views. Do not equate the pkg-subsystem selection
  metadata with writable state private to an arbitrary application.
- `context` resolves and validates the effective selection and
  composes pre-created view paths plus non-PATH env; no filesystem
  writes during ordinary context calls.

**Example of the auto/manual behavior**:
```text
install node@v24       latest-installed=v24 default=v24 policy=auto
install node@v26       latest-installed=v26 default=v26 policy=auto
select default v24     latest-installed=v26 default=v24 policy=manual
install node@v28       latest-installed=v28 default=v24 policy=manual
switch policy auto     latest-installed=v28 default=v28 policy=auto
```
Propose that an explicit manual default selection changes policy
to manual unless explicitly overridden. On uninstall/removal of a
manual pinned default, do not silently point at another package:
reject or require a deliberate transition. Package version order
must respect the relevant authoritative stream/adapter ordering
and platform eligibility, not naive filename/semver comparison.

**Terminology warning:** current `PACKAGE-MODEL.md` defines
upstream `latest` as a live remote assertion, not the newest
installed or most recent catalog-known version. For this proposal,
`latest` must mean a deterministic *latest installed applicable*
candidate; choosing eventual public names must prevent ambiguity
with upstream-latest install requests. Normal context startup
must not require remote network discovery.

**Facility is a different selection problem:** a facility's
compatibility/version level is a provider-independent contract.
Several provider packages may implement that same level and each
can have its own concrete version. A facility selector must therefore
distinguish (facility, compatibility version, provider choice,
provider concrete). A `latest` provider is NOT automatically
defined by comparing versions across unrelated packages. Auto
selection needs a deterministic applicable rule, or must report
ambiguity / preserve the configured provider. Only facility cmd
parts belong in `bin`; env and service parts remain coupled with
the selected provider through their respective consumers.

**Consequences to validate**:
1. `bin/latest` and `bin/default` are multi-package namespaces,
   so two packages and a facility provider may export the same
   command name. Pkg must reject conflicts or follow an explicit,
   deterministic policy compatible with context's final selection.
2. Live shared `bin/default` updated by pkg can cause a shell
   that retains its PATH to use new executables after a package
   update *without another context call*. That can desynchronize
   previously prepared provider env, HOME, resources or runtime ABI.
   Choose between safe live-default guarantees and pkg-time-created
   stable generation views which context can select without
   generating files itself; do not promise snapshot and live
   semantics simultaneously.
3. Global/system and logical-user defaults cannot all occupy one
   undifferentiated physical `bin/default` if shells may legitimately
   have different persistent default policies. Specify authority
   and scope/profile ownership before choosing physical paths.
4. Pkg should publish related symlink updates consistently for
   concurrent readers. Atomic replacement of an individual link
   is not an atomic revision of a whole command group.
   Consider pkg-time immutable generations/publication while
   keeping context-time operations read-only.
5. Provider compatibility and trusted launcher identity cannot be
   inferred solely from PATH. Versioned package commands and
   facility cmd/env/service realization must remain coherent
   with selected packages. Uninstall must account for still-used
   pinned concretes. Dangling links cannot reliably mask commands.
6. `bin` named groups must be created on explicit pkg config
   request (and reusable), not for each theoretical combination
   of parameters or on every context call.

**Recommended evaluation scenarios:** (a) three installs with
auto->manual->auto, (b) two provider packages for one compatible
facility version, (c) named grouping and override through PATH,
(d) two simultaneous shells with different selected views,
(e) change default while a shell has matching provider-specific
env already applied, (f) collision of two public command names.

Keep the earlier confirmed composition semantics: ordered left-to-
right selections with inline full-context expansion, no fixed
priority among operand origins, validated protected inheritance,
one active context per shell without restoration. Do not promote
this exploratory pkg-selection model to current specifications
until the open correctness and ergonomics issues are resolved.

### Facility provider map: accepted contract; implementation pending (2026-10-29)

The user approved the final topology and selector semantics, now promoted to
`specifications/rumiai-os/PACKAGE-MODEL.md` under
"Installed facility provider map". This section is only an implementation
checkpoint: the autonomous `m` runtime at
`cf3660ca0e206f94d0c8292b2b2cabeb096703ef` still has no
`$m_ROOT/facility` index. In particular, its `pkg provider default`
configuration is one selector per facility name rather than
`(facility, compatibility, osarch, scope)`, and `pkg install` currently
selects a package default automatically. The existing installed concrete
`facility-cmd/<facility>` and `facility-env/<facility>` projections
are reusable as-is.

Pending work before claiming a running implementation:
- reconcile the new derived map on installation/removal, including one link
  per provider concrete, per-provider compatible installed latest, and
  non-conflicting default projections;
- identify authoritative per-provider version ordering for all installed
  concretes, including offline updates/removal and historic catalog ranks;
  never choose `latest` by path/string sort or last installed;
- reconcile globally configured vs scoped `default` selections with existing
  state/provider APIs; avoid a second authoritative provider index;
- keep effective provider command/environment/service selections coherent
  when aliases change; preserve existing reference protections;
- realign relevant manuals and permanent/hosted behavior tests, and validate
  real install/uninstall/reselection; follow explicit product authorization.
The selected layout does **not** imply that these behavior changes have
already landed. Legacy `rumiai-os` and `rumiai-tests` remain on hold.

### Package alias selectors and independent multi-facility provider identities (2026-10-29, current user refinement)

The user now proposes a more concrete **indirect symlink chain**:
upon installing `pkg/foo@1.2.3!linux-arm64`, pkg automatically
maintains `pkg/foo@latest!linux-arm64 -> foo@1.2.3!linux-arm64`
(latest **installed** applicable concrete); it creates
`pkg/foo@default!linux-arm64` **only when explicitly requested
through pkg**. Multi-package command group entries can link
through these stable aliases and automatically follow alias
updates without rewriting each entry in a grouped `bin`.
The user asks how to represent a concrete `foo` that exports both
`facility_1` and `facility_2`. The spelling of facility names
here is only illustrative; actual identifier grammar remains the
current controlled convention. Do not treat this example as final
public syntax, path layout or approved replacement for current
upstream-`latest` semantics.

**Design recommendation:** represent *one* immutable package
concrete, including its independent declared facility realizations
(`facility` declaration, `facility-cmd/<facility>`,
`facility-env/<facility>` and any service part), while maintaining
**independent facility-selection aliases** by facility identity,
compatibility version, applicable osarch and configuration scope.
A facility alias selects a provider *concrete* or validated provider
selector, not a second installed copy of the package. Two facility
defaults can initially resolve to the same foo concrete, but can
independently diverge to foo/bar later.

**Schematic logical example, NOT real filesystem names:**
```text
pkg/foo@1.2.3!linux-arm64/
  facility                    # declares facility_1 compat=1, facility_2 compat=2
  facility-cmd/facility_1/...
  facility-cmd/facility_2/...
  facility-env/facility_1
  facility-env/facility_2
pkg/foo@latest!linux-arm64  -> foo@1.2.3!linux-arm64
pkg/foo@default!linux-arm64 -> foo@1.2.3!linux-arm64  # only if configured

pkg-owned facility selection state (illustrative):
  facility_1/compat-1/linux-arm64/default -> foo@1.2.3!linux-arm64
  facility_2/compat-2/linux-arm64/default -> foo@1.2.3!linux-arm64

later:
  facility_1/default -> bar@2.0.0!linux-arm64
  facility_2/default -> foo@1.2.3!linux-arm64
```
The actual facility selector may be a config file containing a
package selector rather than a filesystem symlink if that better
preserves the consumer/provider compatibility and ownership
contract; do not make mutable symlink contents a new competing
authority over an existing provider configuration.

**Distinct alias semantics**:
- `foo@latest` is latest installed foo, NOT the current
  upstream-latest request in the promoted package contract.
- `foo@default` is optional and explicit; absence is not silently
  equivalent to latest. This user proposal supersedes the earlier
  speculative **automatic creation of every package default**.
  The earlier auto/manual policy remains an open question *for
  an explicitly configured default*: should the selector follow
  package latest after creation, or remain pinned by default?
- `facility_1/default` selects the provider for the specified
  facility compatibility level. It is **not automatically identical**
  to `foo@default` and must be independently configurable. Even if
  it tracks `foo@latest` by intent, pkg must prevent an automatic
  update to a newer foo version that no longer declares or
  satisfies the same facility contract.
- No arbitrary global `facility/latest` exists when there are
  incomparable provider packages; require explicit provider policy
  or report ambiguity. Facility compatibility level selection is
  distinct from provider package concrete version ordering.

**Why stable double indirection is useful but not sufficient**:
```text
<bin-group>/foo-command
    -> pkg/foo@latest!linux-arm64/cmd/foo-command
    -> pkg/foo@1.2.3!linux-arm64/cmd/foo-command

<bin-group>/facility-command
    -> <facility_1-selected-provider>/facility-cmd/facility_1/<command>
```
Retargeting an alias automatically changes execution targets with
no group-bin rewrite **only while the new concrete continues to
publish the same command leaf names and compatible facility parts**.
Newly added/renamed/removed command names need pkg-time group
maintenance; dangling links are not negative PATH masks.
Changing a selected provider via an alias can also make command
runtime environment, service integration or trusted launcher
preparation inconsistent with variables already resolved in a
running shell. A *live* alias is not a *pinned* context. Decide
which selectors can stay live and how dependent env is synchronized.

**Test cases for this revised model**:
A. Install two foo concretes: latest alias changes and stable group
   link follows without context-time writes.
B. Explicitly create/update/remove default alias; absent default
   has a defined no-fallback meaning, unless the caller requests
   latest explicitly.
C. Foo declares two different facility compatibility versions:
   two independent facility defaults point to foo; change only
   facility_1 to bar while facility_2 keeps foo.
D. Install a newer foo no longer providing facility_1: the
   facility_1 selector cannot silently follow foo@latest into an
   incompatible provider.
E. Change exports from one concrete to the next: pkg reconciles
   group-bin command-name membership at install/config time;
   links alone do not add/remove names.
F. Launch a consumer while a live provider alias changes:
   ensure provider cmd/env/service selections and concrete launcher
   identity remain coherent; consider pinning an execution snapshot
   or dedicated child-context validation.

This maintains the user's intended ownership boundary:
pkg publishes and updates aliases, provider selections and reusable
grouped bins; context composes ordered PATH and other environment
from those available surfaces without constructing symlinks
for each invocation.

### Further library runtime support and lookup models (2026-11-02, pending)

Ordinary `pkg`-owned versioned exports for sh/Java, and `context`'s
PATH/CLASSPATH projection, are now described in current
`PACKAGE-MODEL.md` and `BOOTSTRAP-ENVIRONMENT.md`; implementation
and validation state is recorded in the current checkpoint above.
The former working-design candidate sections for those two runtimes
are no longer separate active contracts.

**Still open:** potential changes to reusable PATH-visible command-view
symlink groupings **while preserving per-concrete `cmd/` launcher scripts**;
safe ordinary shell library access via the current `loadlib` contract
or a later explicit package loader;
Python site/`.pth` compatibility; Node ESM/CJS and native loader
requirements; and globally maintained default library views. These
are not covered by the current initial sh/Java export implementation.
Avoid inventing uniform runtime-variable semantics and do not conflate
ordinary library links with facilities.

### Unified contextual environment resolution (2026-10-26, working design)

The user's correction: one composition resolver should cover executables,
libraries and resources alike. The POSIX shell's native PATH search is an
optimized consumption path for globally selected executables, not a separate
source of resolution authority. A small index of command symlinks remains
useful; other resolved contexts may also benefit from per-consumer symlink
groups, but this is an implementation choice.

The proposed generalized result is broader than one file/directory: a
coherent prepared execution environment, possibly including selected
package/provider identities, PATH, runtime-specific library search roots,
resource roots, environment values and derived filesystem projections.
The public POSIX sh function name `context` has been confirmed by the user.

Keep logical graph selection, environment/projection preparation, and
application/execution conceptually distinct while studying existing pkg
facility bindings, provider environment planning and command launcher as
behavioral evidence, not as required implementation dependencies.
There is no universal runtime facility apply in the current PACKAGE-MODEL;
nor is LIB_PATH a standard portable loader variable. A child command
cannot alter its caller's environment. These require explicit validation
and design, not assumed new contracts.

Evaluate minimal context parameters, variable precedence, ambiguity,
native PATH fast path, safe environment application, snapshot lifetime,
atomic projection refresh, cleanup and runtime-specific module loading.
Neither bootstrap nor package-private lookup may introduce mandatory
catalog/network access. Code/manual/lang continue bundled in each package.
The existing rumiai-os and rumiai-tests repository freeze remains binding.

The existing command PATH lookup is a consumer-side filesystem
optimization: a bounded set of global command directories avoids growing
PATH with every package. Contextual components can instead use pre-resolved
provider environments, package-local paths or selectively materialized
per-consumer directories. These are **not distinct semantic resolvers**.

The existing file/directory result remains useful as a *requested output*
or as one field of the resolved context, but not the universal result type.
An environment may include typed value members and service behavior that
cannot be represented by a pathname. A generic context must not override
the trusted facility part-specific contracts or bypass the public launcher
for commands.

Requirements to validate include explicit/default selection, consistent
version bindings, path/variable safety, ownership and collision handling,
source resource/package boundaries, deterministic ambiguity failures,
configuration precedence, update concurrency and the lifetime of a prepared
environment. Global manual discovery remains distinct from targeted
manual selection; localized lookup should reuse prepared context rather
than solve provider dependencies for every message. Existing
`state-path`, `manual`, `lang`, `loadlib/loadsyslib` and pkg provider
selection remain authoritative until an explicit contract is promoted.

Illustrative matrix, not yet implementation contract:

```text
content         typical scope       currently available access
m command       global              internal executable
pkg command     global              pkg-default links + real launcher
private lib     package-private     package-local import
shared lib      consumer-context    facility env possible; generic lib usage open
m manual        global              global res/sys/manual lookup
pkg manual      public/consumer     retained in pkg root; publication open
m lang          global              current sys lang selector and fallback
pkg lang        consumer/private    retained in pkg root; publication open
```

The user proposes a uniform, implementation-independent **access contract**
for consumer operations, without requiring one physical resolver or one
universal call syntax. Design it against *existing* APIs such as external
command execution via `m`, `pkg` package/facility selection, `loadlib` /
`loadsyslib` for core shell libraries, `manual` topic presentation,
`lang` domain/message lookup, and `state-path` for state. Avoid inventing
an official `lib` or `res` API name before evaluating reuse and precise
request/response/ambiguity semantics. Distinguish **selection** (package
identity, provider, consumer context, default/version) from **operation**
(execute, source/import, read/present, translate); materialization (symlink,
facility environment, package-local path) is an implementation choice.

Normal-path contract candidates to evaluate, not yet promoted:
- execution of the current package command without caller awareness of
  its physical root, retaining the existing `m`/launcher semantics;
- retrieval/presentation of the correct manual for a selected command or
  library and optionally an explicitly selected version, with deterministic
  ambiguous-name handling; manuals remain bundled in the concrete package;
- localized message lookup with selected language/fallback and a clear
  owner/consumer context, with no repeated graph traversal in the hot path;
- use of a shared library by two different consumers bound to different
  compatible provider versions, without inadvertent global takeover;
- private access inside a package without a public projection;
- clean updates/removal, no dangling projections, no second authoritative
  package/provider registry; all physical state is derived/recoverable.

Benchmark real symlink and facility/provider materialization costs and
error/reconciliation cases before proposing any new typed facility part,
entrypoint or resolver. Do not mistake identical *naming* of operations
for a meaningful shared semantic contract.

The user also suggested that the technical root `m` **could eventually be
represented as an already-installed `pkg`**, allowing `pkg` to manage its
own updates. This idea is expressly **suspended**, not a new requirement,
task or source change. Any future consideration must first establish
bootstrap independence, circular-dependency prevention, recovery/rollback,
integrity, root relocation and safe atomic upgrade behavior; do not
resolve those questions or start implementation in the present unit.


- Verify the newly independent `m` source revision as a downstream build/composition input and keep its runtime contract aligned with legacy consumers while `rumiai-os` transitions. The first concrete import and its 3-adapter subset are complete.
- Reuse the released `m-mk` root and tested `pkg-catalog` descriptor as the independent build/release boundary. Keep the published v0.1.0 artifact immutable while future mk work proceeds forward in source.
- Keep the `pkg-catalog` authority separate from the source checkout but resolve catalog selection/bootstrap availability only when an actual operation requires it.
- Decide whether any minimal packaging/export steps are necessary to make the `m-core` checkout directly usable; do not introduce a second general build system merely to create a build loop.
- Validate compatibility of existing `rumiai-os` consumers while gradually relocating higher-level code into owning repositories.

## Next action

**Related specialized pkg-definition work:** The comprehensive
`pkg-catalog` definition-schema review and any coordinated
`link/bin` / `link/lib` catalog-runtime migration are independently
owned by `handoff/pkg-definition-model-review.md`. This source-
composition handoff retains only that relationship; avoid duplicating
its working schema, migration decisions or validation state here.

**Previous source-extraction next action (completed):** The operator rejected the synthetic test, which was removed forward. The source repositories were populated with actual assets; the initial release/catalog/install composition is now implemented and hosted-validated, as recorded above.

**Immediate next real validation:** The operator has reported `vmdev` interactive menu operation PASS; do not repeat the same test without a material change. Verify the corrected `rssh` main source through a genuinely installed selected package, and realign the remaining `rsudo-admin` remote stream/menu source assumptions before publishing any new immutable release. Verify actual `rsudo` SSH/sudo only against an explicitly authorized controlled host. Distinguish isolated source checks from hosted package/remote/physical evidence.

**Additional context/library work:** Validate the published `m`
sh/Java library exports on the real hosted workflow and then through
one real catalog-backed package installation/consumer where an
actual package definition declares an export. Reconcile any failures
forward, preserve exact package version binding and coexistence with
existing command/loader defaults; do not rename or bypass the
package `cmd/` entrypoints, and do not extend runtime support
without a verified loader contract. This workstream is independent of facilities.

1. Finish the authorized incremental `context` capability: integrate no-argument initialization with managed shells, derive a coherent effective context with facility/provider selections and exact package runtime env, reconcile system/user/profile defaults and active-context replacement, implement validated protected inheritance and child propagation, and exercise actual installed package/provider and nested launch scenarios. Reuse already-installed command directories; do not introduce per-call symlink generation. The published first-phase shell function is not yet an environment/provider-context implementation. Preserve frozen repositories and real/authentic validation requirements.
2. Implement the approved facility provider-map contract from `PACKAGE-MODEL.md` in the autonomous `m` repository as an isolated, validated work unit, beginning with derived provider membership and per-provider compatible-latest ordering. Then reconcile revision/platform/global defaults with authoritative state and existing `pkg provider default` without silently changing current public callers. Preserve pkg-owned install/uninstall/alias reconciliation, context-owned PATH and environment composition, and exact concrete cmd/env coherence. The separately proposed package `@latest`/`@default` alias redesign and policy still requires its own resolution; do not conflate generic package latest with facility-compatible provider latest. Validate cases for multiple provider versions, dropped compatibility, ambiguous defaults, user/consumer scopes, changed commands, removal and nested execution. Keep `rumiai-os` and `rumiai-tests` frozen.
3. First classify the missing autonomous standalone `bin/sys/json` (current `JSON-QUERY.md` and legacy source/manual) against the fixed technical-core boundary, then continue analyzing ownership/dependency boundaries for `pkg-analyze`, terminal primitives/menu/vsed/editor, gitman, SSH/rsudo administration, testlab, JavaScript core/UI and Web components. Reuse existing independent projects and package facilities rather than duplicating implementation.
4. **On hold until explicit user authorization:** any edit or migration to old `rumiai-os`, and any work on `rumiai-tests` (including re-alignment of its permanent suite). Do not treat those holds as validation blockers for independently released packages.
5. Independently maintain core `m` package adapter completeness under a separate authorized workstream; its adapter gaps should not be mistaken for missing user-installable product packages.

## Blockers / open questions

No blocking architecture decision remains for the independent `mk` release
or the public `pkg install mk@v0.1.0` path: both are published and verified
on hosted Ubuntu/macOS. Pending work concerns downstream RumiAI OS composition,
remaining standalone `m` catalog adapters, permanent test-suite realignment
and coordinated legacy `mk` removal. A transient HTTP 403 from the upstream
Node.js GitHub API caused the first macOS live install attempt to fail; its
second attempt passed. No physical production-host deployment was performed.
