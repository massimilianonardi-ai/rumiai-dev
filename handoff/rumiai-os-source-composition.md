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
product architectures. The independent `m` source and separately distributed
`m-mk` package are now published and verified on hosted Ubuntu/macOS;
downstream `rumiai-os` composition and permanent-suite migration remain pending.

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

### Filesystem component resolution as common access primitive (2026-10-26, candidate)

The user proposed collapsing the **component lookup** portion of global,
consumer-contextual and private runtime access into a command/API that
accepts enough identity/selection/context information to yield **one
filesystem pathname identifying either a file or a directory**. This is a
promising common *lookup* contract for materialized `bin`, `lib`, `res`
and package roots, not an accepted name/signature or implementation yet.

Candidate request dimensions to evaluate (not all caller-supplied every
time): component identity and, only where necessary, component kind;
consumer/package context for contextual dependency bindings; optional
explicit concrete version or constraint; facility/capability identity
when substitutable provider resolution applies; relevant osarch and locale,
usually inferred from already-authoritative current selection.

The core operation must select through the already-authoritative `pkg`
package/concrete/dependency/provider context, or the existing `m` core
semantic roots, returning a unique, validated pathname. The filesystem
representation may be a canonical concrete-package path, a selected
symlink projection or an already-materialized consumer-local view; choosing
one has observable update/pinning, security and lifetime implications.
Returning the raw private executable rather than the proper package
launcher must not bypass dependency/environment application.

Contract constraints to resolve before promotion:
- one result vs no-match vs ambiguity vs invalid or unavailable context;
  diagnostics and status are independent of the successful path payload;
- caller-specified type versus type derived from identity/namespace,
  relative-versus-absolute and physical-versus-semantic selected paths;
- existing paths versus precomputed semantic paths (contrast `state-path`);
  file/directory validation, permissions, confinement and path traversal;
- stable concrete version for an executing consumer versus mutable global
  default symlinks; races across update/removal and cache invalidation;
- directory lookup vs discovery of an arbitrary set of topics/components:
  whether enumeration remains the owning higher-level interface;
- high-frequency localized lookup must not repeatedly traverse dependency
  graphs; the existing `lang` final identifier-string fallback occurs
  precisely when no file exists, and belongs to the translation operation;
- non-filesystem facility results (e.g. `env` literal values, service
  behavior) are **outside** this path-only primitive and keep their trusted
  typed-part contracts.

Existing `state-path`, `manual`, `lang`, `loadlib/loadsyslib`,
command launchers and `pkg` facility/provider selection demonstrate parts
of the required behavior; do not duplicate their current authorities.
`RESOURCE-MODEL.md` currently explicitly rejects an *unmotivated*
universal resource resolver. It is still authoritative while this broader
candidate is evaluated; no novel public command/function, namespace or
canonical spec change is authorized by this handoff alone.
Manual and localization content remain unconditionally **bundled with the
same software package**, regardless of how the path is resolved.

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

1. Before extracting further shared-library/resource consumers such as `pkg-analyze`, define and compare implementation-independent access contracts for `bin`, `lib`, and `res` across global/consumer-contextual/private visibility; test the existing symlink/launcher and facility/provider approaches. Resource distribution has been fixed to one concrete software package including its own manuals and translations. Do not promote unresolved access mechanisms into specifications.
2. Continue analyzing ownership/dependency boundaries for `pkg-analyze`, terminal primitives/menu/vsed/editor, gitman, SSH/rsudo administration, testlab, JavaScript core/UI and Web components. Reuse existing independent projects and package facilities rather than duplicating implementation.
3. **On hold until explicit user authorization:** any edit or migration to old `rumiai-os`, and any work on `rumiai-tests` (including re-alignment of its permanent suite). Do not treat those holds as validation blockers for independently released packages.
4. Independently maintain core `m` package adapter completeness under a separate authorized workstream; its adapter gaps should not be mistaken for missing user-installable product packages.

## Blockers / open questions

No blocking architecture decision remains for the independent `mk` release
or the public `pkg install mk@v0.1.0` path: both are published and verified
on hosted Ubuntu/macOS. Pending work concerns downstream RumiAI OS composition,
remaining standalone `m` catalog adapters, permanent test-suite realignment
and coordinated legacy `mk` removal. A transient HTTP 403 from the upstream
Node.js GitHub API caused the first macOS live install attempt to fail; its
second attempt passed. No physical production-host deployment was performed.
