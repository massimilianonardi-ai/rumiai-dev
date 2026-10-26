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

## Working design / open questions

- Verify the newly independent `m` source revision as a downstream build/composition input and keep its runtime contract aligned with legacy consumers while `rumiai-os` transitions. The first concrete import and its 3-adapter subset are complete.
- Reuse the released `m-mk` root and tested `pkg-catalog` descriptor as the independent build/release boundary. Keep the published v0.1.0 artifact immutable while future mk work proceeds forward in source.
- Keep the `pkg-catalog` authority separate from the source checkout but resolve catalog selection/bootstrap availability only when an actual operation requires it.
- Decide whether any minimal packaging/export steps are necessary to make the `m-core` checkout directly usable; do not introduce a second general build system merely to create a build loop.
- Validate compatibility of existing `rumiai-os` consumers while gradually relocating higher-level code into owning repositories.

## Next action

1. Integrate the independent `m` checkout into the downstream `rumiai-os` composition and reconcile any duplicated original system files, platform-selector state and non-core project ownership without silently changing runtime semantics.
2. Add suitable permanent regression coverage in `rumiai-tests` for the independent source boundary and public operations, and verify required catalog-adapter compatibility beyond the initial 3-adapter subset. Baseline checkout smoke and managed Node installation evidence already exist on both major hosts.
3. Realign the permanent mk regression suite in `rumiai-tests` against the independently published `m-mk` and the real package launcher, including watch and full lifecycle behavior; reconcile remaining old monolith consumers before removing legacy system mk.
4. Continue forward-only source/distribution composition for the remaining legacy `rumiai-os` responsibilities. The independent `m`/`m-mk` boundary is now promoted in current canonical specifications, while broader product composition remains open.

## Blockers / open questions

No blocking architecture decision remains for the independent `mk` release
or the public `pkg install mk@v0.1.0` path: both are published and verified
on hosted Ubuntu/macOS. Pending work concerns downstream RumiAI OS composition,
remaining standalone `m` catalog adapters, permanent test-suite realignment
and coordinated legacy `mk` removal. A transient HTTP 403 from the upstream
Node.js GitHub API caused the first macOS live install attempt to fail; its
second attempt passed. No physical production-host deployment was performed.
