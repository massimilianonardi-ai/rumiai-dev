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

## Working design

- The intended responsibility is an operational development lab between ad-hoc shell experimentation and permanent/formal tests: start real disposable infrastructure, expose connection/state information, run or hand control to real target commands, allow inspection/debugging, and clean up.
- The current usage direction has three compatible degrees rather than separate products: live/manual interaction, guided hybrid interaction where deterministic portions are automated and control is handed to the user, and unattended execution for scenarios that are sufficiently deterministic. Interactive use is the preferred development surface; complete automation is not required for every scenario.
- The strongest reusable boundary appears to be an environment/scenario provider rather than a test runner. A provider should own real external infrastructure (for example an SSH/sudo host in a Podman container) while the selected test/PoC owns assertions.
- A scenario should be usable interactively during development and, after its environment contract stabilizes, potentially be reused by rumiai-validate as suite-owned execution preparation. Formal validation must still use the unchanged permanent tests and revision-specific evidence model.
- `expect` is a strong candidate optional PTY/dialogue driver, not the orchestration model of testlab. Its useful boundary is `spawn`/prompt synchronization/response automation plus `interact` handoff to the user. Direct native TTY attachment remains preferable when no scripted dialogue is needed so testlab does not insert an unnecessary terminal intermediary.
- The current rumiai-tests interactive helper already demonstrates the need: Darwin uses Expect for prompt-synchronized dialogue while Linux uses `script(1)` plus post-run prompt verification. A portable Expect package could remove that host split for scenarios that genuinely need synchronized PTY dialogue, while permanent-test prompt handling must still distinguish driver synchronization from contract assertions.
- A RumiAI `expect` package appears feasible for the current Linux/macOS architecture families, but the upstream stable source is old and downstreams carry modern compiler/macOS patches. The current package subsystem materializes binary artifacts rather than compiling source at install time, so a robust package would need RumiAI-controlled prebuilt artifacts rather than directly treating the SourceForge source tarball as installable package content.
- For an initial Expect package PoC, prefer a self-contained private Tcl 8 runtime inside the Expect package rather than immediately creating a public Tcl facility solely for one consumer. The package launcher can derive runtime paths from the concrete command location, as current packages already do. A separate Tcl package/facility should be considered only if independent Tcl consumption/provider substitution becomes a real requirement.
- Expose only the upstream commands that testlab/RumiAI intentionally needs (initially likely `expect`) rather than automatically projecting Expect's entire collection of helper executables into the global command surface.
- Historical test-command ideas worth preserving conceptually: one-command scenario selection, live/manual inspection, easily activated experiments, real filesystem/process/network effects, optional pauses/interactive shells, and lightweight scenario-local setup/cleanup.
- Historical test-command mechanics not to inherit by default: source-all-files global namespace, test_<name> dispatch, commented-code-as-configuration, hardcoded personal paths, mutable shared /tmp names, dependence on prior scenario state, and mixed exploration/assertion/orchestration in one function.
- Reuse from rumiai-test/rumiai-validate should be conceptual and selective: hierarchical selection/grouping, separation of selection from execution requirements, disposable environment lifecycle, explicit session identity, host/target revision metadata, combined logs/transcripts, cleanup/audit, and the distinction between target failure and infrastructure error.
- Do not import formal-validation constraints into ordinary lab use: normal testlab sessions should be able to exercise a dirty/uncommitted development checkout, should not require immutable publication, and need not produce PASS/FAIL when the experiment has no formal oracle. They should record enough target/Git/environment identity to explain what was exercised. A testlab run becomes formal validation evidence only through the existing validation contract, not merely because the live scenario was realistic.
- For rsudo, a Podman-backed real SSH/sudo target could replace boundary fakes for live/validation scenarios and exercise real sshd, sudo policy, TTY, password-required/passwordless/root cases and a real remote filesystem. Random localhost port publication and tmpfs mounts make non-invasive parallel scenarios plausible; exact portability behavior across Podman hosts still requires a PoC.

## Completed

- Mandatory preflight completed for rumiai-dev, rumiai-os, rumiai-tests and the referenced historical m repository.
- Historical cmd/test-command structure and representative rsudo, filesystem, environment, terminal and Electron experiments inspected.
- Current testing, runner and validation contracts inspected together with current rsudo permanent tests.
- Current Podman documentation checked for random localhost port publication, healthchecks and bounded tmpfs mounts.
- Current Expect packaging/portability evidence reviewed: upstream stable remains 5.45.4 and requires Tcl; current Homebrew ships binary bottles for macOS ARM/Intel and Linux ARM/x86 but applies modern build/macOS patches and depends on Tcl 8.6, confirming broad host feasibility while also showing that pristine upstream source is not enough for a maintenance-free package.
- Current `rumiai-tests/lib/interactive.lib` reviewed: Darwin uses Expect with prompt-before-response synchronization; Linux uses util-linux `script` with prepared input and verifies prompts afterward.
- Current `rumiai-validate` lifecycle/requirements model reviewed for reusable ideas and deliberate differences from testlab.

## Current state

The architectural gap is now identified: RumiAI has a strict permanent-test runner and a strict formal-validation launcher, but no explicit developer lab/scenario surface for real disposable exploratory environments. The working command identity is `testlab`, with an interactive-first/hybrid execution direction. Expect is a promising optional PTY driver and a feasible package candidate pending a real relocatability PoC. Repository placement, scenario format and validation-integration contract remain open.

## Next action

Before implementing the rsudo scenario, define the minimal testlab interaction/lifecycle model and run an Expect packaging/relocatability PoC (Linux/macOS as available). Then use rsudo + real sshd/sudo in Podman to validate the resulting interactive/guided/unattended scenario boundary.

## Blockers / open questions

- Final repository/ownership.
- Scenario representation and lifecycle verbs.
- Whether Podman is the only initial backend or one provider behind a backend-neutral scenario contract.
- Exact boundary for reusing mature scenarios inside rumiai-validate execution requirements.
- Whether the initial Expect package bundles a private Tcl runtime dynamically with relative/runtime-derived paths or uses a more static layout; decide from PoC evidence rather than architecture preference.
