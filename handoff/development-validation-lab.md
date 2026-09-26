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

- The command/product name is intentionally unresolved.
- The historical massimilianonardi-ai/m repository is reference material only, not current authority.
- The new mechanism must not turn rumiai-test into an environment preparer or assertion-aware orchestrator.
- Permanent test assertions remain in normal .test files; environment/lab orchestration must not become an alternative implementation of target behavior.
- Podman is a strong candidate backend for disposable real environments, not yet a mandatory architecture choice.

## Working design

- The intended responsibility is an operational development lab between ad-hoc shell experimentation and permanent/formal tests: start real disposable infrastructure, expose connection/state information, run or hand control to real target commands, allow inspection/debugging, and clean up.
- The strongest reusable boundary appears to be an environment/scenario provider rather than a test runner. A provider should own real external infrastructure (for example an SSH/sudo host in a Podman container) while the selected test/PoC owns assertions.
- A scenario should be usable interactively during development and, after its environment contract stabilizes, potentially be reused by rumiai-validate as suite-owned execution preparation. Formal validation must still use the unchanged permanent tests and revision-specific evidence model.
- Historical test-command ideas worth preserving conceptually: one-command scenario selection, live/manual inspection, easily activated experiments, real filesystem/process/network effects, optional pauses/interactive shells, and lightweight scenario-local setup/cleanup.
- Historical test-command mechanics not to inherit by default: source-all-files global namespace, test_<name> dispatch, commented-code-as-configuration, hardcoded personal paths, mutable shared /tmp names, dependence on prior scenario state, and mixed exploration/assertion/orchestration in one function.
- For rsudo, a Podman-backed real SSH/sudo target could replace boundary fakes for live/validation scenarios and exercise real sshd, sudo policy, TTY, password-required/passwordless/root cases and a real remote filesystem. Random localhost port publication and tmpfs mounts make non-invasive parallel scenarios plausible; exact portability behavior across Podman hosts still requires a PoC.

## Completed

- Mandatory preflight completed for rumiai-dev, rumiai-os, rumiai-tests and the referenced historical m repository.
- Historical cmd/test-command structure and representative rsudo, filesystem, environment, terminal and Electron experiments inspected.
- Current testing, runner and validation contracts inspected together with current rsudo permanent tests.
- Current Podman documentation checked for random localhost port publication, healthchecks and bounded tmpfs mounts.

## Current state

The architectural gap is now identified: RumiAI has a strict permanent-test runner and a strict formal-validation launcher, but no explicit developer lab/scenario surface for real disposable exploratory environments. The command name, repository placement, scenario format and validation-integration contract remain open.

## Next action

Define the minimal first scenario around rsudo + real sshd/sudo in Podman, use it to determine the scenario lifecycle/API, then decide whether the reusable environment-provider responsibility belongs in rumiai-tests, rumiai-dev-PoCs or another already-current responsibility before introducing a new product command.

## Blockers / open questions

- Final command name and repository/ownership.
- Scenario representation and lifecycle verbs.
- Whether Podman is the only initial backend or one provider behind a backend-neutral scenario contract.
- Exact boundary for reusing mature scenarios inside rumiai-validate execution requirements.
