# development-validation-lab

Status: Active
Updated: 2026-09-29

## Goal

Design a developer-facing live experimentation and validation environment mechanism that can run real, disposable scenarios during RumiAI design/development, preserve the useful exploratory workflow of the historical m test-command, and provide a path for mature scenarios to support formal validation without duplicating rumiai-test or rumiai-validate responsibilities.

## Current repository revisions

- rumiai-dev: 6759114ac5d5365b5b44a5f2b37d0a080ca67324 (pre-checkpoint HEAD)
- rumiai-os: 5e4d66d9c67248409f165e80542d8c39bf70b957
- rumiai-tests: e5c2a70fe58ad9cb6ae7ccd1025d0015b42bc278
- rumiai-dev-PoCs: retained only as historical experimental evidence for this task; no longer an implementation gate

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- RUNNER.md
- PHYSICAL-TESTING.md
- TEST-PATTERNS.md
- handoff/README.md
- handoff/workflow-optimization.md
- handoff/rsudo-library-documentation-tests.md
- rumiai-tests/VALIDATION.md

## Superseding direction — 2026-09-29

The user explicitly stopped further PoC 047/048 debugging after repeated physical-Linux failures consumed excessive development time. This supersedes every older task-local statement that makes PoC 047/048, Expect/PTy handoff work or additional physical confirmation a gate for `testlab`.

Current direction:

- `testlab` is a tool of the technical `m` system and its product implementation lives in `rumiai-os`;
- proceed with the real minimal product rather than spending additional time stabilizing the old PoCs;
- the first baseline uses direct inherited terminal/standard streams for interactive `enter`; no Expect/PTy handoff adapter is part of the current `testlab` contract;
- PoC 047/048/050 results remain historical engineering evidence only and do not block product development;
- future PTY/dialogue automation requires a new concrete product need and is not inherited automatically from those experiments.

## Fixed task-local choices

- The working command identity is `testlab`.
- The historical massimilianonardi-ai/m repository is reference material only, not current authority.
- The new mechanism must not turn rumiai-test into an environment preparer or assertion-aware orchestrator.
- Permanent test assertions remain in normal .test files; environment/lab orchestration must not become an alternative implementation of target behavior.
- Podman is a strong candidate backend for disposable real environments, not yet a mandatory architecture choice.
- `testlab` is interactive-first as a strong design recommendation, not an absolute prohibition on unattended execution. Scenarios may deliberately mix automated setup/dialogue with direct human control when that gives better development evidence.
- Real scenario creation/lifecycle is the center of `testlab`; terminal-dialogue automation is supporting infrastructure, not the product's defining responsibility.
- No PTY/dialogue tool is a current `testlab` prerequisite. Expect, `script(1)` and the previous managed-Expect/package direction are outside the baseline; they may be reconsidered only for a future concrete scenario need.
- The minimal scenario contract is fixed for this task: a scenario definition obtains a concrete runtime reality; each execution produces/binds a scenario instance; ownership is recorded per resource; prerequisites are checked before runtime mutation; every created/bound resource is persisted immediately; readiness is established before activities; context exposes facts/handles rather than commands or assertions; activities remain outside the scenario; interactive access is separable from preparation; cleanup may affect only owned resources; persistent inventory is the recovery authority after interruption.
- The first implementation must remain imperative/minimal. No generic scenario DSL, resource graph, backend-neutral plugin framework or activity/assertion DSL is introduced until multiple real scenarios demonstrate a concrete need.

## Working design

- The intended responsibility is an operational development lab between ad-hoc shell experimentation and permanent/formal tests: start real disposable infrastructure, expose connection/state information, run or hand control to real target commands, allow inspection/debugging, and clean up.
- The current usage direction has three compatible degrees rather than separate products: live/manual interaction, guided hybrid interaction where deterministic portions are automated and control is handed to the user, and unattended execution for scenarios that are sufficiently deterministic. Interactive use is the preferred development surface; complete automation is not required for every scenario.
- The strongest reusable boundary appears to be an environment/scenario provider rather than a test runner. A provider should own real external infrastructure (for example an SSH/sudo host in a Podman container) while the selected test/PoC owns assertions.
- A scenario should be usable interactively during development and, after its environment contract stabilizes, potentially be reused by rumiai-validate as suite-owned execution preparation. Formal validation must still use the unchanged permanent tests and revision-specific evidence model.
- PTY/dialogue automation is outside the current baseline. The earlier Expect/`script(1)` investigation remains historical evidence; a future `m` adapter requires a new concrete scenario that cannot be served adequately by direct inherited terminal interaction.
- Direct native TTY attachment remains preferable when testlab only needs a human live shell/session. The adapter is used where a normalized PTY/recording/input boundary materially helps.
- Historical test-command ideas worth preserving conceptually: one-command scenario selection, live/manual inspection, easily activated experiments, real filesystem/process/network effects, optional pauses/interactive shells, and lightweight scenario-local setup/cleanup.
- Historical test-command mechanics not to inherit by default: source-all-files global namespace, test_<name> dispatch, commented-code-as-configuration, hardcoded personal paths, mutable shared /tmp names, dependence on prior scenario state, and mixed exploration/assertion/orchestration in one function.
- Reuse from rumiai-test/rumiai-validate should be conceptual and selective: hierarchical selection/grouping, separation of selection from execution requirements, disposable environment lifecycle, explicit session identity, host/target revision metadata, combined logs/transcripts, cleanup/audit, and the distinction between target failure and infrastructure error.
- In testlab, the first-class object should be the real `scenario`: a concrete reality that testlab either materializes or binds to, together with the lifecycle and observable information needed to use it. Activities performed inside that scenario may be manual exploration, PoC commands, scripted probes or permanent tests; those activities do not redefine the scenario itself.
- Candidate scenario substrates now include: the real existing host/system; a derived local filesystem copy/snapshot; an already-existing Podman container/pod or equivalent external environment; and a testlab-provisioned composed container topology. These are scenario substrate/lifecycle choices, not separate notions of test.
- Scenario substrate and scenario ownership should remain separate dimensions. An existing host/pod is externally owned and testlab must not destroy it; a copied filesystem or provisioned container topology can be testlab-owned and disposable. This separation prevents cleanup semantics from being inferred merely from whether the substrate is a host, filesystem or container.
- A scenario therefore needs to expose at least readiness plus the concrete handles needed by activities (for example paths, host/port, user/credentials, container/pod identity or service endpoints), while cleanup may affect only resources owned by that scenario.
- Do not import formal-validation constraints into ordinary lab use: normal testlab sessions should be able to exercise a dirty/uncommitted development checkout, should not require immutable publication, and need not produce PASS/FAIL when the experiment has no formal oracle. They should record enough target/Git/environment identity to explain what was exercised. A testlab run becomes formal validation evidence only through the existing validation contract, not merely because the live scenario was realistic.
- For rsudo, a Podman-backed real SSH/sudo target could replace boundary fakes for live/validation scenarios and exercise real sshd, sudo policy, TTY, password-required/passwordless/root cases and a real remote filesystem. Random localhost port publication and tmpfs mounts make non-invasive parallel scenarios plausible; exact portability behavior across Podman hosts still requires a PoC.

## Accepted task-local scenario contract

- A scenario definition describes how to obtain one concrete runtime reality; a scenario instance is the live reality produced or attached by one execution. This distinction is needed for persistent lifecycle/recovery without making activities or assertions part of the scenario definition.
- A scenario instance may contain multiple heterogeneous resources. Resource ownership is therefore per-resource, not a single scenario-wide flag:
  - testlab-owned resources may be cleaned up by testlab;
  - externally owned resources may be inspected/used according to the scenario but must never be destroyed by testlab merely because the scenario ends.
- The minimal generic lifecycle is conceptual rather than provider-specific:
  1. check host prerequisites before mutation;
  2. allocate persistent scenario-instance identity/state;
  3. create or bind resources while recording each resource immediately;
  4. establish readiness;
  5. publish the context/handles needed by activities;
  6. keep the scenario available for one or more activities and interactive inspection;
  7. close/release the instance, cleaning only owned resources;
  8. retain enough state to diagnose failures and recover cleanup after interruption.
- Scenario context should expose facts, not commands or assertions: paths, host/port, credentials created for the scenario, service endpoints, container/pod identities, or other concrete handles. The representation and naming are intentionally still open.
- Activity is deliberately not a second framework in the first design. Once a scenario is ready, the consumer may be an interactive user, an arbitrary command/PoC, `rumiai-test`, or later formal validation. Assertions remain owned by the activity/test layer.
- Interactive use must not be embedded in resource creation itself. Scenario creation/readiness must be separable from later interactive access so the same scenario implementation can also support unattended consumers.
- Crash/interruption recovery is part of the lifecycle problem: relying only on shell traps is insufficient for long-lived interactive scenarios. Persistent resource inventory should make it possible to identify and clean owned orphan resources without touching external resources.
- Candidate examples mapped to this model:
  - real host/system: primarily external resources; readiness validates the requested host capabilities; no host destruction;
  - local filesystem copy/snapshot: source external, derived copy owned/disposable, exported root pathname;
  - existing pod/container: external identity is bound/validated and never destroyed by default;
  - composed Podman scenario: network/containers/volumes created by testlab are owned, readiness waits for required services, context exposes endpoints/credentials, cleanup destroys only those owned resources.
- The accepted model remains task-local and is not yet a promoted product specification. Promotion waits until implementation ownership/API are selected and reference-host evidence is sufficient.
## Completed

- Mandatory preflight completed for rumiai-dev, rumiai-os, rumiai-tests and the referenced historical m repository.
- Historical cmd/test-command structure and representative rsudo, filesystem, environment, terminal and Electron experiments inspected.
- Current testing, runner and validation contracts inspected together with current rsudo permanent tests.
- Current Podman documentation checked for random localhost port publication, healthchecks and bounded tmpfs mounts.
- Expect packaging/portability was investigated, but the current design no longer requires a managed Expect package merely for testlab; prefer an adapter over already-available host PTY tools when its common semantics can be made real.
- Current `rumiai-tests/lib/interactive.lib` reviewed: Darwin uses Expect with prompt-before-response synchronization; Linux uses util-linux `script` with prepared input and verifies prompts afterward.
- Current `rumiai-validate` lifecycle/requirements model reviewed for reusable ideas and deliberate differences from testlab.
- PoC 047 (`rumiai-dev-PoCs/pocs/047-testlab-rsudo-scenario-lifecycle`) implemented to exercise the accepted scenario lifecycle against a real Podman SSH/sudo target without changing rumiai-os.
- GitHub Actions run `36302160822` passed on Ubuntu 24.04.5 amd64 against rumiai-os `51d0cba5696a94caaf5ae39e2e476a31598a0ae1`: POSIX-shell syntax passed; real rsudo traversed real SSH/sshd/sudo and observed UID 0; the owned container was present in the resource inventory while READY, absent after cleanup, repeated cleanup succeeded, and the external rumiai-os checkout remained clean.
- The PoC exposed one current integration fact: rsudo has no SSH port/config operand. The scenario therefore uses a local PATH adapter that delegates to the real host ssh with a scenario-local `-F` config. This preserves a real SSH boundary while avoiding host port 22 and avoiding mutation of the operator SSH configuration; it is experimental activity adaptation, not yet a product-interface decision.
- PoC 048 (`rumiai-dev-PoCs/pocs/048-expect-pty-dialogue-semantics`) implemented to test the PTY/dialogue boundary independently of testlab orchestration.
- GitHub Actions run `36302392760` passed on Ubuntu 24.04 amd64 with distro Expect 5.45.4 and on macOS 15 with host-provided Expect 5.45. The same driver exercised a TTY-required child, exact prompt-before-response synchronization, transcript capture, child exit-status propagation and timeout-as-driver-error semantics.
- PoC 048 revision `36eae9b84708beba3fc314a3c4f144438f6263ce` was re-run by Actions run `36302442950`; both Ubuntu and macOS matrix jobs passed.

- An intermediate PoC 050 explored moving scenario-specific SSH command selection into rsudo. That product direction was rejected after command-string semantics added complexity without improving the architectural boundary; the user restored direct `ssh` invocation. PoC 050 is retained only as experimental evidence for the rejected path.
- PoC 047's scenario-local `PATH` adapter is the current rsudo activity adaptation for disposable scenarios: it delegates to the real host `ssh` with scenario-local OpenSSH configuration, without changing rsudo or the operator's persistent SSH configuration. Persistent per-host SSH behavior belongs to OpenSSH/the caller environment.

- PoC 048 was extended from prompt-synchronized PTY driving to a real reversible Expect `interact` handoff. The experiment now proves automated setup -> operator PTY handoff -> operator input/output -> local return of control -> resumed automation on the same live child.
- Intermediate PoC 048 runs exposed a real portability difference: after a spawn has passed through `interact`, Expect 5.45/macOS and Expect 5.45.4/Linux do not preserve the target exit status consistently through Expect's own post-`interact` process-status path. `close_on_eof 0` did not eliminate the divergence.
- The final PoC 048 boundary therefore keeps PTY/dialogue/handoff responsibility in Expect while a minimal POSIX target wrapper records the target status and a minimal POSIX launcher propagates that status only after the Expect driver completed successfully. Driver/infrastructure errors remain distinct from target results.
- GitHub Actions run `36312456161` passed PoC revision `81c514d31980e42a775ba929dc506ea848ca6189` on both Ubuntu 24.04 amd64 / Expect 5.45.4 and macOS 15 / Expect 5.45, including the reversible `interact` handoff and preserved fixture status 37.
- PoC 047 was rerun after the rsudo SSH-command experiment was removed. GitHub Actions run `36312547115` passed PoC revision `8bb77b43f0afbfb45f03cdb6f1875b92cce0ffe0` against current `rumiai-os@c1aa711645b39f36850d35abc02c31d8db916120`: POSIX-shell syntax passed and the real Podman scenario again observed `PASS real rsudo -> real ssh -> real sshd -> real sudo`.
- The hosted-CI stage is therefore complete for the current 047/048 design. Physical/reference-host execution is now the remaining evidence gate before selecting the first real testlab repository/CLI/scenario representation.
- After the PoC evidence documentation was synchronized, the exact current `rumiai-dev-PoCs@1b5de8c4b0a752ba8d4f8718718fa66eab16f954` was rerun automatically: PoC 047 run `36312663146` PASS and PoC 048 run `36312663141` PASS. These are the current-HEAD hosted checks.

- Physical macOS preflight on 2026-09-27 established the operator host as macOS 27.0 arm64 with host Expect 5.45, OpenSSH client/keyscan and OpenSSL available. The canonical workspace layout places `rumiai-dev-PoCs` under `rumiai-os/src/`, so from the PoC checkout the product root is two levels up. The user explicitly does not want Homebrew or Podman installed on the macOS reference host. This is not treated as a failed prerequisite to remediate: Podman remains an optional scenario backend, so PoC 047 physical execution is scoped to Ubuntu 26.04 ARM64 while PoC 048 remains the macOS physical gate for the PTY/handoff boundary.
- Physical macOS PoC 048 automated run on 2026-09-27 passed against `rumiai-dev-PoCs@1b5de8c4b0a752ba8d4f8718718fa66eab16f954` and `rumiai-os@c1aa711645b39f36850d35abc02c31d8db916120`. The observed terminal output included the expected synchronized dialogue, deliberate timeout-classification path, automated `interact` handoff harness, resumed automation and final `PASS expect PTY dialogue and interact handoff semantics`.
- Physical macOS direct-operator PoC 048 handoff on 2026-09-27 also passed on the same revision pair. The operator received the live `human>` prompt through Expect `interact`, entered `operator`, observed `human-seen:operator` and `resume>`, returned control with the experimental local `__TESTLAB_RETURN__` sequence, and the resumed automation completed. The launcher status and private recorded target status were both exactly `37`, followed by `PASS manual Expect interact handoff`. The macOS physical PoC 048 gate is therefore complete.
- Physical Ubuntu 26.04.1 ARM64 preflight on 2026-09-27 completed successfully against `rumiai-dev-PoCs@1b5de8c4b0a752ba8d4f8718718fa66eab16f954` and `rumiai-os@c1aa711645b39f36850d35abc02c31d8db916120`. The host reports `aarch64`; OpenSSH client/keyscan and OpenSSL are present; Expect 5.45.4 and Podman 5.7.0 were installed from Ubuntu packages; `podman info` succeeds.
- Physical Ubuntu direct-operator PoC 048 initially failed on `rumiai-dev-PoCs@1b5de8c4b0a752ba8d4f8718718fa66eab16f954`: the automated `run.sh` path passed, but the direct handoff returned from `interact` before the operator could type at `human>`, then resumed automation and failed with `send: spawn id ... not open`. This exposed a PoC-driver defect that hosted nested PTY automation had not revealed.
- The handoff driver was corrected in `rumiai-dev-PoCs@a6eb6773a4ca812509a1d79b66f05af31aa5bae3` to bind the operator side explicitly to Expect `tty_spawn_id` (`/dev/tty`) and the child side explicitly to the saved child spawn id, rather than relying on the default `user_spawn_id`/stdin mapping. Missing controlling TTY is now an infrastructure error. GitHub Actions run `36346422386` passed the corrected PoC on both Ubuntu 24.04 / Expect 5.45.4 and macOS 15 / Expect 5.45.
- Because PoC 048 changed after the earlier macOS physical PASS, that prior macOS evidence remains valid only for `rumiai-dev-PoCs@1b5de8c4...`.
- The first physical retry of `a6eb6773...` on Ubuntu still failed in the same visible way: the direct handoff returned before the operator could enter the child response, then automation resumed against a closed spawn. This disproved the hypothesis that selecting `tty_spawn_id` alone solved the problem.
- The current working hypothesis is queued terminal input at the automation->operator boundary: the physical shell command is pasted as a multi-line block, and an empty/residual complete line can reach the child immediately when `interact` begins. The old fixture could not distinguish this from EOF because both paths used status 32.
- PoC 048 revision `5bcaa1b6fe1f949b446a32d68d26e486a37c55c2` adds an explicit operator-acquisition barrier through `expect_tty`: before the child accepts human input, the driver ignores any non-matching complete lines and waits for the literal PoC-local word `takeover`; only then does it send a private `handoff-start` token, wait for the child `human>` prompt and enter `interact`. The fixture now uses distinct statuses for EOF versus mismatched input at each handoff stage. GitHub Actions run `36347213482` passes this revision on both Ubuntu 24.04 / Expect 5.45.4 and macOS 15 / Expect 5.45.
- The physical diagnostic status record from the failed `5bcaa1b6...` run was `38`, not EOF: the fixture received a complete human-response line different from `operator`. The transcript showed no visible payload after `human>`, so the observed failure class is queued/spurious terminal input reaching the child at the instant `interact` begins, not loss of the controlling terminal.
- PoC 048 revision `8c0b66656c0ed8386bdefe3fd1bc45d5849e9976` replaces the fixed takeover word with a runtime-only token `takeover-<driver-pid>`. `expect_tty` discards every complete line until that exact token is entered, making it impossible for stale pre-run input to satisfy the acquisition barrier. The automated harness discovers and echoes the generated token. GitHub Actions run `36351158040` passed this revision on both Ubuntu 24.04 / Expect 5.45.4 and macOS 15 / Expect 5.45.
- A subsequent physical Ubuntu attempt on current `rumiai-dev-PoCs@e9346a7f12b04b4fb78d24d933ca60f4ebe500f8` confirmed that the runtime-token acquisition barrier itself works: the driver displayed `takeover-29550`; the operator entered the stale example token `takeover-18427`, which the driver correctly rejected with `driver:ignored-input`, then continued waiting. The run was manually interrupted with Ctrl-C before the correct displayed token was entered. This attempt is therefore not a PoC failure and does not establish post-acquisition `interact` behavior.
- The physical Ubuntu run with the correct runtime token still failed immediately after entering `interact`: the token was accepted, the fixture reached `human>`, and then the child closed before the operator could enter `operator`. This disproved the remaining stale/pre-run-input explanation.
- The refined diagnosis is the cooked-to-raw transition on the same controlling terminal at the exact handoff boundary. Expect documents that `expect_tty` reads `/dev/tty` in cooked mode by default while `interact` uses raw mode; the physical Linux behavior shows an extra line event reaching the child during that transition.
- PoC 048 revision `bd0348747ed99b84c4fcaaa99c431f5a2bc47234` now puts `/dev/tty` into raw mode before the runtime-token acquisition, consumes the token including its raw carriage return, disables local echo, and enters `interact` without a cooked-to-raw transition. It restores the prior raw/echo state explicitly when handoff returns or fails, and `interact` now distinguishes operator-TTY EOF from child-PTY EOF instead of degrading to a later generic closed-spawn send error. GitHub Actions run `36354854797` passed this revision on both Ubuntu 24.04 / Expect 5.45.4 and macOS 15 / Expect 5.45.
- The physical Ubuntu run of `bd034874...` still failed after the correct runtime token was accepted: the fixture reached `human>`, then `interact` reported `child reached EOF during operator handoff` before the operator could enter `operator`. This shows that even pre-switching `/dev/tty` to raw mode did not make a separate `expect_tty` acquisition phase safe on the physical Linux boundary.
- PoC 048 was then restructured so one `interact` call owns the complete human phase. Before takeover, the operator TTY has no default output mapping and unmatched characters are discarded. The runtime token is matched locally inside `interact` and is typed without Enter, so no line terminator can cross into the child. Once matched, the driver sends the private `handoff-start` control record, marks handoff active, and then forwards subsequent operator characters to the child one by one. The experimental return sequence remains locally consumed. This removes the `expect_tty -> interact` transition entirely.
- The first CI revision of this design exposed only a harness-text mismatch (`and press Enter` versus `(no Enter)`), not a PTY failure. After aligning the harness, `rumiai-dev-PoCs@9f9ae728a89250c9ca9a888483c958e6f98ae03a` passed GitHub Actions run `36356600969` on both Ubuntu 24.04 / Expect 5.45.4 and macOS 15 / Expect 5.45.
- Physical direct-operator confirmation of `9f9ae728...` is still required on Ubuntu 26.04 ARM64 and macOS before the current PoC physical gate is complete.

## Current state

The first real `testlab` baseline is promoted and implemented.

Canonical contract:

- `specifications/rumiai-os/TESTLAB.md` owns the current semantics;
- `testlab` belongs to `m`;
- project scenarios are executable child programs under `<project-root>/testlab/scenarios/`, never sourced;
- lifecycle phases are `check`, `prepare`, `enter`, `cleanup`;
- persistent instance state is user-scoped technical state resolved through `state-path user sys testlab data`;
- each allocated instance freezes its scenario executable so later enter/cleanup behavior does not drift when the project source changes;
- context exposes factual handles; scenario-specific persistent resource inventory is the cleanup/recovery authority;
- lifecycle states are `preparing`, `ready`, `failed`, `closed`;
- the baseline introduces no scenario DSL, generic resource graph, provider/plugin framework, Expect/PTy adapter or assertion language.

Current product implementation:

```text
rumiai-os/bin/sys/testlab
rumiai-os/res/sys/manual/testlab
rumiai-os/testlab/scenarios/host
rumiai-os/testlab/scenarios/scratch
```

Public forms:

```text
testlab
testlab scenarios
testlab prepare <scenario> [<scenario-arg> ...]
testlab status [<instance-id>]
testlab context <instance-id> [<key>]
testlab enter <instance-id>
testlab close <instance-id>
```

The shipped `rumiai-os` project scenarios are deliberately small:

- `host` binds to the current project/host as an externally owned reality;
- `scratch` creates an instance-owned disposable work directory.

Permanent coverage lives under `rumiai-tests/tests/rumiai-os/testlab/`, with task scope `validation/testlab.conf` and Linux/macOS workflow `.github/workflows/testlab.yml`.

Formal validation run `36537384660` passed on both `ubuntu-latest` and `macos-latest` against product revision `5e4d66d9c67248409f165e80542d8c39bf70b957` and test-suite revision `c236f7497da0c468605078a9960f988af7e97534`. The validation exercises real product lifecycle behavior including prerequisite rejection before instance allocation, persistent preparation, context publication, frozen-scenario re-entry, owned-resource cleanup, repeated close, failed-prepare recovery and status reporting.

The first macOS validation attempt also exposed a real GNU/BSD portability defect: the new code/tests passed `--` to utilities whose current host implementation does not accept that terminator. The product and tests were corrected to follow the current `POSIX-PORTABILITY-LAYER.md` rule that `--` is used only where the invoked utility actually supports it.

## Next action

The basic lifecycle is now implemented and validated. Development should continue by adding **real useful project scenarios** one at a time and extracting common machinery only when repeated concrete scenarios demonstrate it.

The next product-design work should therefore focus on:

1. exercise the current interactive-first `testlab` against normal development use and refine the bare-menu workflow where concrete friction appears;
2. select the first substantial real scenario beyond `host`/`scratch` from an actual RumiAI development need;
3. keep backend-specific mechanics inside that scenario until at least a second real scenario demonstrates a common abstraction;
4. consider reuse by `rumiai-validate` only after a mature scenario has a stable execution-environment contract;
5. do not reopen PTY/Expect handoff work unless a concrete scenario cannot be served by direct inherited terminal interaction.

## Blockers / open questions

No blocker remains for continued `testlab` development.

Still intentionally open:

- which substantial real scenario should be promoted next;
- which, if any, repeated scenario mechanics deserve a shared `m` abstraction after multiple real uses;
- the exact future boundary for mature scenario reuse by `rumiai-validate`;
- whether a future concrete need justifies any PTY/dialogue adapter.

Podman remains an optional scenario-specific implementation choice rather than a global `testlab` or macOS prerequisite.
