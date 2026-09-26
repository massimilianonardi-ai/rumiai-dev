# development-validation-lab

Status: Active
Updated: 2026-09-26

## Goal

Design a developer-facing live experimentation and validation environment mechanism that can run real, disposable scenarios during RumiAI design/development, preserve the useful exploratory workflow of the historical m test-command, and provide a path for mature scenarios to support formal validation without duplicating rumiai-test or rumiai-validate responsibilities.

## Current repository revisions

- rumiai-dev: 4bfd43721c2abaac7f2b094d2b3019825e488003 (pre-handoff checkpoint HEAD)
- rumiai-os: 4f429c811f9c19889d0d8f6fa42b0423356beecd
- rumiai-tests: e30ef19cabe1d2c1511fe49db23c8d7b89feff11
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
- The previous direction of creating a managed RumiAI Expect package is no longer preferred by default. When suitable host tools are already available, a host-normalizing `m` adapter should consume those capabilities rather than packaging Expect merely for testlab.

## Working design

- The intended responsibility is an operational development lab between ad-hoc shell experimentation and permanent/formal tests: start real disposable infrastructure, expose connection/state information, run or hand control to real target commands, allow inspection/debugging, and clean up.
- The current usage direction has three compatible degrees rather than separate products: live/manual interaction, guided hybrid interaction where deterministic portions are automated and control is handed to the user, and unattended execution for scenarios that are sufficiently deterministic. Interactive use is the preferred development surface; complete automation is not required for every scenario.
- The strongest reusable boundary appears to be an environment/scenario provider rather than a test runner. A provider should own real external infrastructure (for example an SSH/sudo host in a Podman container) while the selected test/PoC owns assertions.
- A scenario should be usable interactively during development and, after its environment contract stabilizes, potentially be reused by rumiai-validate as suite-owned execution preparation. Formal validation must still use the unchanged permanent tests and revision-specific evidence model.
- PTY/dialogue handling should become a small host-normalizing `m` adapter only if the PoC confirms a useful stable common contract. This follows the existing `pager`/`editor` pattern: capability-based backend choice, host-neutral consumer contract, host details hidden behind the adapter.
- The current rumiai-tests interactive helper is the seed evidence: Darwin uses Expect with prompt-before-response synchronization while Linux uses `script(1)` with prepared input plus post-run prompt verification.
- Do not claim those two backends are equivalent where they are not. The initial common adapter contract should be limited to behavior both implementations can actually guarantee (for example running/attaching a command through a PTY and capturing/forwarding the session). Prompt-synchronized dialogue is a stronger capability and must not be emulated merely by feeding all input early and checking prompts after execution.
- Direct native TTY attachment remains preferable when testlab only needs a human live shell/session. The adapter is used where a normalized PTY/recording/input boundary materially helps.
- Historical test-command ideas worth preserving conceptually: one-command scenario selection, live/manual inspection, easily activated experiments, real filesystem/process/network effects, optional pauses/interactive shells, and lightweight scenario-local setup/cleanup.
- Historical test-command mechanics not to inherit by default: source-all-files global namespace, test_<name> dispatch, commented-code-as-configuration, hardcoded personal paths, mutable shared /tmp names, dependence on prior scenario state, and mixed exploration/assertion/orchestration in one function.
- Reuse from rumiai-test/rumiai-validate should be conceptual and selective: hierarchical selection/grouping, separation of selection from execution requirements, disposable environment lifecycle, explicit session identity, host/target revision metadata, combined logs/transcripts, cleanup/audit, and the distinction between target failure and infrastructure error.
- In testlab, the first-class object should be the real `scenario`: an owned set of disposable resources/services/state plus readiness, exposed endpoints/credentials/state, interactive access and cleanup. Activities performed inside that scenario may be manual exploration, PoC commands, scripted probes or permanent tests; those activities do not redefine the scenario itself.
- Do not import formal-validation constraints into ordinary lab use: normal testlab sessions should be able to exercise a dirty/uncommitted development checkout, should not require immutable publication, and need not produce PASS/FAIL when the experiment has no formal oracle. They should record enough target/Git/environment identity to explain what was exercised. A testlab run becomes formal validation evidence only through the existing validation contract, not merely because the live scenario was realistic.
- For rsudo, a Podman-backed real SSH/sudo target could replace boundary fakes for live/validation scenarios and exercise real sshd, sudo policy, TTY, password-required/passwordless/root cases and a real remote filesystem. Random localhost port publication and tmpfs mounts make non-invasive parallel scenarios plausible; exact portability behavior across Podman hosts still requires a PoC.

## Completed

- Mandatory preflight completed for rumiai-dev, rumiai-os, rumiai-tests and the referenced historical m repository.
- Historical cmd/test-command structure and representative rsudo, filesystem, environment, terminal and Electron experiments inspected.
- Current testing, runner and validation contracts inspected together with current rsudo permanent tests.
- Current Podman documentation checked for random localhost port publication, healthchecks and bounded tmpfs mounts.
- Expect packaging/portability was investigated, but the current design no longer requires a managed Expect package merely for testlab; prefer an adapter over already-available host PTY tools when its common semantics can be made real.
- Current `rumiai-tests/lib/interactive.lib` reviewed: Darwin uses Expect with prompt-before-response synchronization; Linux uses util-linux `script` with prepared input and verifies prompts afterward.
- Current `rumiai-validate` lifecycle/requirements model reviewed for reusable ideas and deliberate differences from testlab.

## Current state

The architectural gap is now identified: RumiAI has a strict permanent-test runner and a strict formal-validation launcher, but no explicit developer lab/scenario surface for real disposable exploratory environments. The working command identity is `testlab`, with real scenario creation/lifecycle as its central responsibility and an interactive-first/hybrid usage direction. PTY normalization is a separate candidate `m` adapter responsibility. Repository placement, scenario format and validation-integration contract remain open.

## Next action

Define the minimal scenario lifecycle/data boundary first, then PoC the host-normalized PTY adapter semantics using the real tools available on the reference hosts. Use rsudo + real sshd/sudo in Podman as the first end-to-end scenario to validate both boundaries.

## Blockers / open questions

- Final repository/ownership.
- Scenario representation and lifecycle verbs.
- Whether Podman is the only initial backend or one provider behind a backend-neutral scenario contract.
- Exact boundary for reusing mature scenarios inside rumiai-validate execution requirements.
- Exact minimum PTY adapter contract that Expect and script-backed implementations can both satisfy without semantic weakening; stronger prompt-synchronized dialogue may need a distinct capability.
