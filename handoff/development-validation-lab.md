# development-validation-lab

Status: Active
Updated: 2026-09-26

## Goal

Design a developer-facing live experimentation and validation environment mechanism that can run real, disposable scenarios during RumiAI design/development, preserve the useful exploratory workflow of the historical m test-command, and provide a path for mature scenarios to support formal validation without duplicating rumiai-test or rumiai-validate responsibilities.

## Current repository revisions

- rumiai-dev: 65724e25ae107c2c7eb6dad72b534d760dde9304 (pre-checkpoint HEAD)
- rumiai-os: 51d0cba5696a94caaf5ae39e2e476a31598a0ae1
- rumiai-tests: c5dbf627300d095215da21bc07362de03e09337f
- rumiai-dev-PoCs: 4b2619ce846b48c136dcbb44275c9854652dd1d6
- historical/reference m: 2a57a29880c2d7a32e18782122062c695fcb1a3a (master)

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

## Fixed task-local choices

- The working command identity is `testlab`.
- The historical massimilianonardi-ai/m repository is reference material only, not current authority.
- The new mechanism must not turn rumiai-test into an environment preparer or assertion-aware orchestrator.
- Permanent test assertions remain in normal .test files; environment/lab orchestration must not become an alternative implementation of target behavior.
- Podman is a strong candidate backend for disposable real environments, not yet a mandatory architecture choice.
- `testlab` is interactive-first as a strong design recommendation, not an absolute prohibition on unattended execution. Scenarios may deliberately mix automated setup/dialogue with direct human control when that gives better development evidence.
- Real scenario creation/lifecycle is the center of `testlab`; terminal-dialogue automation is supporting infrastructure, not the product's defining responsibility.
- The previous direction of creating a managed RumiAI Expect package is no longer preferred by default. Host tools required for testlab infrastructure may be explicit host prerequisites, like Podman, rather than `pkg`-managed content.
- Expect may be made an explicit reference-host prerequisite for scripted PTY interaction. On Ubuntu 26.04 it is available as the `expect` package in the Ubuntu `universe` component; availability does not imply installation. If this prerequisite is accepted, a RumiAI PTY/dialogue adapter can use Expect as the common backend instead of weakening semantics to the intersection of Expect and `script(1)`.
- The minimal scenario contract is fixed for this task: a scenario definition obtains a concrete runtime reality; each execution produces/binds a scenario instance; ownership is recorded per resource; prerequisites are checked before runtime mutation; every created/bound resource is persisted immediately; readiness is established before activities; context exposes facts/handles rather than commands or assertions; activities remain outside the scenario; interactive access is separable from preparation; cleanup may affect only owned resources; persistent inventory is the recovery authority after interruption.
- The first implementation must remain imperative/minimal. No generic scenario DSL, resource graph, backend-neutral plugin framework or activity/assertion DSL is introduced until multiple real scenarios demonstrate a concrete need.

## Working design

- The intended responsibility is an operational development lab between ad-hoc shell experimentation and permanent/formal tests: start real disposable infrastructure, expose connection/state information, run or hand control to real target commands, allow inspection/debugging, and clean up.
- The current usage direction has three compatible degrees rather than separate products: live/manual interaction, guided hybrid interaction where deterministic portions are automated and control is handed to the user, and unattended execution for scenarios that are sufficiently deterministic. Interactive use is the preferred development surface; complete automation is not required for every scenario.
- The strongest reusable boundary appears to be an environment/scenario provider rather than a test runner. A provider should own real external infrastructure (for example an SSH/sudo host in a Podman container) while the selected test/PoC owns assertions.
- A scenario should be usable interactively during development and, after its environment contract stabilizes, potentially be reused by rumiai-validate as suite-owned execution preparation. Formal validation must still use the unchanged permanent tests and revision-specific evidence model.
- PTY/dialogue handling should become a small `m` adapter only if the PoC confirms a useful stable contract. This follows the existing `pager`/`editor` pattern in hiding host/tool details, but the backend does not need to vary by host when a common prerequisite provides the stronger semantics everywhere.
- The current rumiai-tests interactive helper is seed evidence: Darwin uses Expect with prompt-before-response synchronization while Linux uses `script(1)` with prepared input plus post-run prompt verification. If Expect becomes a reference-host prerequisite, the stronger prompt-synchronized model can replace this semantic split rather than normalizing down to `script(1)` behavior.
- `script(1)` remains a potentially useful host tool for simple PTY/session-recording cases, but it should not define or weaken the adapter's dialogue contract merely because it is already present.
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

## Current state

The architectural gap and minimal scenario boundary are now identified and experimentally supported on an auxiliary Ubuntu host. The working command identity is `testlab`, with real scenario creation/lifecycle as its central responsibility and an interactive-first/hybrid usage direction. The accepted task-local scenario contract separates definition from live instance, records ownership per resource, separates readiness/context from activities, and makes persisted resource inventory the recovery authority. Repository placement, final scenario representation/CLI, PTY adapter surface and formal-validation integration remain open.

## Next action

1. Exercise PoC 047 on the physical/reference macOS host and the Ubuntu 26.04 reference host to verify Podman port publication, real SSH/sudo behavior and cleanup with the same scenario model.
2. In parallel, create a focused Expect-backed PTY/dialogue PoC that tests the stronger prompt-synchronized + optional-human-handoff semantics without making it part of testlab orchestration.
3. Only after those results, decide the first real testlab repository/command surface and scenario representation.

## Blockers / open questions

- Final repository/ownership.
- Scenario representation and lifecycle verbs.
- Exact initial scenario substrate set and whether Podman is only one scenario provider behind a backend-neutral scenario contract.
- Exact boundary for reusing mature scenarios inside rumiai-validate execution requirements.
- Exact PTY/dialogue adapter surface if Expect is accepted as a host prerequisite; `script(1)` should remain separate unless it can satisfy a concrete additional responsibility without weakening Expect semantics.
