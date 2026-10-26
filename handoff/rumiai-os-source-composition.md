# RumiAI OS source composition comparison

Status: Active
Updated: 2026-10-26

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
product architectures. The independent `m` source checkout has now been populated;
downstream `rumiai-os` composition and the separate `mk` package remain pending.

## Current repository revisions

Last verified on 2026-10-24:

- `rumiai-dev/main` pre-change: `69d4b4467fe35980667e3ea9234c50ab639209a8`; subsequent canonical package-policy alignment commit `2a5e83eadcdc2ff64024aa5af6c2eeef7bed331b`; this handoff commit follows.
- `rumiai-os/main`: `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`.
- `pkg-catalog/main`: `707ca9aee61f16270da222d8873e4e96a659ab5a`.
- `rumiai-tests/main`: `7bd33837210850cee26acaf02d78f873eab884e0`.
- `rumiai-dev-PoCs/main`: `c65bcf0306e88daaf3061962bafd750372751881`.
- `m/master` source extraction baseline: `b05bb649400c35314e97a3d0876f5413c8145aba`; current integrated checkout `809f4d63173c32ecede0cd6bb183da6fc6ab8fa9`. New commits added the technical core without rewriting earlier history. Source implementation and pre-existing operational manuals were copied from `rumiai-os/main` `673df1a2d5476ad57d54c7bc7e1fc2deeaf16195`.
- Original PoC 072 experiment branch: `rumiai-dev-PoCs/rumiai-os-composition-comparison`, last verified experiment commit `0c8f8fa098e5c74d8e2e15c6552a9c633a383048`; engine snapshot intentionally pinned there.

Refresh remote HEADs before resuming. These SHAs are checkpoints only, not authority.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `handoff/README.md`.
- `specifications/README.md`; `specifications/rumiai-os/{CURRENT-MODEL,MK,BOOTSTRAP-ENVIRONMENT,ENTRYPOINT-ROOT-RESOLUTION,COMMAND-ENTRYPOINTS,LANG-BOOTSTRAP,STATE-MODEL,RESOURCE-MODEL}.md`.
- `handoff/javascript-command-bootstrap.md` for the separate active native interpreter migration.
- Current `rumiai-os/lib/sys/js/mk.lib.js`, `bin/sys/mk` and `rumiai-tests/tests/rumiai-os/mk/lifecycle.test` as factual implementation/test evidence.

## Fixed task-local choices

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

Scenarios 1 and 2 have initial direct-checkout smoke evidence on Ubuntu and macOS for bootstrap, platform setup, command dispatch, manuals, localization and offline operations. Real `pkg install nodejs@v26.8.2` and managed-node invocation passed on both hosts in GitHub Actions run `40088928262`. The independent `mk` release/install and full downstream-consumer scenarios remain pending; the separate PoC 072 reduced-fixture evidence does not validate them.

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

## Working design / open questions

- Verify the newly independent `m` source revision as a downstream build/composition input and keep its runtime contract aligned with legacy consumers while `rumiai-os` transitions. The first concrete import and its 3-adapter subset are complete.
- Use PoC 073's verified source-root, package-local launcher/dependency and watch re-entry layout as implementation evidence. Convert the staged mk source into its own source repository and create a versioned downloadable verified release. A real `pkg-catalog` descriptor and artifact publication do not exist yet.
- Keep the `pkg-catalog` authority separate from the source checkout but resolve catalog selection/bootstrap availability only when an actual operation requires it.
- Decide whether any minimal packaging/export steps are necessary to make the `m-core` checkout directly usable; do not introduce a second general build system merely to create a build loop.
- Validate compatibility of existing `rumiai-os` consumers while gradually relocating higher-level code into owning repositories.

## Next action

1. Integrate the independent `m` checkout into the downstream `rumiai-os` composition and reconcile any duplicated original system files, platform-selector state and non-core project ownership without silently changing runtime semantics.
2. Add suitable permanent regression coverage in `rumiai-tests` for the independent source boundary and public operations, and verify required catalog-adapter compatibility beyond the initial 3-adapter subset. Baseline checkout smoke and managed Node installation evidence already exist on both major hosts.
3. Promote the PoC 073 mk source/packaging to a dedicated source repository and publish a versioned verifiable release; then create the corresponding `pkg-catalog` descriptor, test the **public** `pkg install mk` path and run full permanent mk regressions including watch. The current GitHub connector cannot create a repository or publish GitHub release assets, so this source/release step remains pending.
4. Only then promote the new source/distribution boundary to current canonical specifications and change product repository structure via authorized forward-only work.

## Blockers / open questions

No blocking architecture decision remains. The autonomous minimal `m` source
checkout and initial Ubuntu/macOS tests are complete. Pending work includes
downstream RumiAI OS composition, complete catalog-adapter compatibility,
permanent test realignment, independent `mk` source/release assets and the real
`pkg-catalog` descriptor for `mk`. GitHub API 403 responses for live upstream
release requests are external availability constraints, not a license to
relax integrity or silently bypass live discovery. Available repository write
tools still cannot create a new repository or publish GitHub release assets;
PoC 073 cannot stand in for the missing published `mk` release. No physical
deployment was performed.
