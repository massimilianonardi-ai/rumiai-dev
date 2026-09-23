# RumiAI Testing Rules

Status: **Current / canonical**  
Updated: 2026-09-18

This document defines the canonical rules for authoring, executing and preserving RumiAI tests.

The rules are normative for permanent tests and validation runs. Proofs of concept remain separate experimental work.

## 1. Purpose of tests

Tests protect consolidated, materially relevant properties of RumiAI and of the external dependencies RumiAI actually uses.

A permanent test should exist because it protects a contract, invariant, observable behavior or concrete regression. Test quantity is not a goal.

A test that no longer protects a current property, duplicates an already protected property without benefit, or costs more to maintain than the risk it mitigates should be simplified, merged or removed.

## 2. Repositories and roles

Canonical repository roles are defined by the root `README.md`.

For testing purposes:

- `rumiai-dev` defines current testing rules and expected behavior;
- `rumiai-tests` contains permanent executable tests, the runner/validation tooling and revision-specific validation evidence;
- `rumiai-os` contains the product/runtime being tested when that repository is the target;
- `rumiai-dev-PoCs` contains experiments and proofs of concept;
- `pkg-catalog` is package catalog data and may be part of a real composed target path when the tested behavior depends on it.

Permanent tests are not product content. A PoC may lead to a permanent test, but the two remain conceptually distinct.

## 3. Organization and discovery

Tests are organized primarily by the object or capability being verified.

Under `tests/`:

1. a regular `*.test` file is a permanent test;
2. a normal directory is a recursively selectable group;
3. hidden pathnames whose name begins with `.` are internal material and are not discovered;
4. every other file is ignored by the runner.

The pathname relative to `tests/` is the natural identifier of a test or group.

The `tests/` root represents the complete applicable suite.

## 4. Test independence

Independence means **execution and state independence**, not duplication of infrastructure code.

Each test must be executable individually and must produce the same result, given the same target, declared configuration and relevant host conditions, regardless of tests executed before or after it.

A test must not depend on:

- state left by another test;
- setup or cleanup performed by another test;
- intermediate results from another test;
- execution order;
- communication between tests.

A group is a container and selection unit, not an orchestrator. It does not introduce `before`, `after`, required shared setup or functional ordering.

This independence **does not prohibit** shared libraries from the same `rumiai-tests` revision. Infrastructure helpers such as target discovery, path normalization, temporary-resource plumbing and interactive drivers should be shared when the responsibility is genuinely common. Creation of a replacement target or a private execution environment is not a test-library responsibility; formal validation environment preparation belongs to `rumiai-validate`.

The exact `rumiai-tests` Git revision is already part of validation evidence and makes the shared-helper version used by a session reproducible.

Inline copying of common helpers is not the default. It is allowed only when the copied content is intentionally part of the specific test semantics or when there is a documented reason to freeze it inside that test.

## 5. Responsibility of an individual test

Each test must verify a clearly identifiable property.

Before implementing or materially extending a permanent test, identify the exact current property or properties it protects. Prefer a current invariant identifier when one exists; otherwise identify the authoritative specification section and observable rule. This protected-property set is the semantic boundary of the test.

Every semantic assertion in the test must map to that protected-property set. Setup, synchronization, terminal driving, fixture preparation and observation machinery may be necessary to reach the property, but they do not become additional product requirements merely because the test happens to depend on them.

In particular, an interactive test must not turn renderer details, cursor movement, terminal width, timing, intermediate screen contents, driver sequencing or another incidental observation into a product assertion unless the current contract explicitly makes that behavior normative. A task-validation test must not add unrelated product assertions simply because the same scenario can conveniently observe them.

The test owns:

- test-specific preconditions;
- scenario-specific preparation inside the environment it receives;
- external inputs and, only when explicitly allowed, semantically specific simulations or fixtures;
- execution of the supplied target;
- expected result;
- comparison between expected and observed behavior;
- specific diagnostics;
- cleanup of scenario-specific resources created by the test when the scenario requires it.

A test does **not** own cloning, copying or reconstructing `rumiai-os`, creating a replacement `HOME`/temporary user environment, or substituting another target environment for the one it received. Direct execution uses the real ambient environment. Formal validation uses the disposable environment supplied by `rumiai-validate`.

The runner must not know target semantics.

Common infrastructure logic must not be replicated in every test when a shared library already owns the same responsibility.

## 6. Observable contract before implementation

A test should prefer observable behavior and public or architectural invariants over incidental implementation details.

A white-box check is appropriate only when the internal representation is itself part of the contract, for example file mode, absence of a shebang, a fixed physical layout or another normative structural property.

Unless explicitly required, do not use the following as proxies for behavior:

- grep of internal source strings;
- private function names;
- textual call order in source code;
- line numbers;
- accidental spelling of equivalent pathnames;
- implementation details that may change without changing the contract.

### Authenticity of the system under test

A behavioral test must exercise the real system it claims to verify. Isolation exists to make the test repeatable and disposable; it does not authorize replacement of the system under test with an artificial reconstruction.

A permanent test must act on the target and execution environment it receives. It must not clone, copy, reconstruct or synthesize another `rumiai-os` tree, and it must not create a parallel private user environment merely to protect the supplied target. When formal isolation is required, `rumiai-validate` supplies an independent disposable clone of the exact target revision together with isolated mutable user roots while preserving the real target code and normal execution path.

For behavior exposed by a command, the normal test form is a small number of real commands invoking the real executable through its normal interface with arguments chosen to cover the contract cases. A test of `pkg install` must actually execute `pkg install` and traverse the real pipeline used by that command.

The following do not prove real target behavior:

- cloning, copying or reconstructing a second target tree inside an individual test;
- copying individual target files or fragments into an ad-hoc structure;
- creating a test-private replacement `HOME`, package/runtime root or equivalent execution environment instead of using the environment supplied to the test;
- sourcing an internal library instead of invoking the real entrypoint when the claimed contract is the entrypoint or composed system;
- redefining, intercepting or replacing target functions;
- replacing adapters, catalogs, downloaders, extractors, integrators or other components of the verified real path with fake implementations;
- constructing an artificial PATH containing modified copies of target executables;
- claiming composed behavior is validated when part of that composition was not actually executed.

Simulations, fixtures, stubs, pseudo-terminals or synthetic input are exceptions, not the default model. They are allowed when they represent input external to the logic under test that cannot reasonably be produced directly, especially user/interactive input, or when a current explicit contract authorizes them. They must not replace target components that the test claims to validate.

A test using a valid simulation proves only the property actually exercised through that simulation. It cannot be used as evidence for the same property through a real path that was replaced or excluded.

## 7. Granularity and cost

A test should be small enough to make a violation diagnosable, but fragmentation is not a goal.

Variants of the same contract may be cases in one test when they share setup, expected behavior and failure model and separation would not materially improve diagnosis.

Before creating a new permanent test, verify that the same property is not already protected.

During suite audits, each test should be classifiable as:

```text
keep        protects a distinct property at proportional cost
simplify    useful property, but the test is over-specified or infrastructure is excessive
merge       useful property, but fragmentation is unnecessary
remove      no distinct current property or insufficient value
```

## 8. Direct execution and shared libraries

A `.test` remains a directly executable program and must be able to locate the suite root from its own position when it needs common libraries.

Direct execution and execution through `rumiai-test` must exercise the same verification logic. The difference between an ambient development execution and a formal isolated validation is supplied externally through the inherited environment; the `.test` must not switch to a different implementation strategy.

Libraries under `rumiai-tests/lib/` may be deliberate runtime dependencies of permanent tests. They should be small, stable, testable and limited to common infrastructure responsibilities.

A change to a shared library requires proportional testing of the library and materially affected consumers, not duplication of the change into inline copies.

## 9. Self-discovery and pathnames

Tests must not depend on the absolute pathname of a personal checkout.

It is correct to hardcode stable logical names and relationships that belong to the verified property; it is not correct to hardcode personal home directories, Homebrew paths, developer-local directories or equivalent host-specific spellings.

When the property concerns physical/canonicalized pathnames, the test expectation must also be canonicalized according to the applicable contract.

The runner does not discover the target on behalf of the test. A shared `rumiai-tests` library may do so for tests that share the same target-discovery contract.

## 10. Determinism, portability and hosts

Given the same test, target, declared configuration and relevant host conditions, the result must be reproducible.

A common property should normally use the same test across hosts. Do not create macOS/Linux/Windows copies merely to adapt expectations.

Current stable reference hosts are:

```text
macOS
Ubuntu 26.04 ARM64
```

Periodic hosts may include Ubuntu x64 and POSIX-compatible Windows environments when relevant.

Additional auxiliary environments are deliberately useful during development and test refinement. In particular, a Linux environment different from the stable hosts may expose accidental dependencies on a distribution, tool version or host-specific divergence that RumiAI abstractions should hide behind a common interface.

The executable Linux environment provided by ChatGPT, when available, may be used as a real auxiliary host for development, exploratory testing, bug reproduction and permanent-test refinement. Its actual identity must be detected in the session before assigning host-specific meaning to results; distribution, version and kernel must not be assumed stable between sessions. When the environment is Debian x86_64, its difference from Ubuntu provides an additional useful observation point for RumiAI POSIX portability.

A PASS on an auxiliary host adds evidence for the property actually exercised, but it does not replace required evidence on an applicable stable reference host.

A PASS on one host does not replace required evidence on another applicable host.

## 11. Individual test result

Test exit statuses remain:

```text
0 = PASS
1 = FAIL
2 = SKIP
3 = ERROR
```

- `PASS`: observed behavior matches the expectation;
- `FAIL`: the test executed correctly, but behavior did not match;
- `SKIP`: the test is not applicable or a declared precondition is absent;
- `ERROR`: the test could not determine a result because of a test, environment or infrastructure error.

`FAIL` is reserved for a contradiction of a declared protected property after the test has successfully reached and observed that property. A timeout, PTY/terminal-driver mismatch, parser failure, fixture/setup failure, unexpected harness exception or inability to synchronize the scenario is `ERROR` unless the awaited timing/event is itself the protected contract and the test has independently established that its observation mechanism is functioning.

A test harness must not collapse arbitrary exceptions or synchronization failures into `FAIL`. When one executable test contains both contract assertions and infrastructure/driver logic, those two failure classes must remain distinguishable in its exit status and diagnostics.

A real host incompatibility with a required property is `FAIL`, not `SKIP`.

Historical outcomes are never reinterpreted retroactively.

## 12. Execution environments, isolation and cleanup

Individual tests do not own environment isolation.

A direct `.test` execution, and a development run through `rumiai-test`, acts on the real ambient target and process environment supplied by the caller. This is deliberate: development execution must be able to test the actual checkout/environment being worked on.

Formal validation through `rumiai-validate` uses a disposable validation environment prepared by the launcher. For a `rumiai-os` target the environment starts from an independent clean Git clone checked out at the exact configured commit and isolated mutable user roots, including at least `HOME` and temporary storage plus applicable standard user-state roots such as XDG directories. The real host OS, architecture, system tools and other host properties remain real unless a specific current contract requires additional isolation.

Target preparation is part of the validation environment, not test setup. Before the audit baseline and before any test executes, `rumiai-validate` selects the real host platform through the target's canonical `osarch update` path. A validation scope may additionally declare target packages that must be present. Those packages are installed inside the same disposable target through the real public `pkg install` path; no host runtime may be copied or injected as a substitute. A declared package operand should pin a concrete version whenever the validated work depends on that concrete runtime rather than merely on whatever version current package resolution would select.

When target-package preparation consumes `pkg-catalog`, the validation scope must also declare the exact expected catalog commit. The launcher records the actual immutable catalog snapshot used by package preparation and rejects the environment before tests run if it differs from the configured commit. This prevents silent catalog drift from being attributed to the configured validation scope. The package subsystem remains the authority for package resolution and installation; `rumiai-validate` does not reimplement catalog or package semantics.

Host-platform selection and declared package preparation may create or change operational selector/package paths in the disposable tree after the exact source commit has been materialized. Those changes are validation-environment preparation, not source revision changes. The filesystem audit baseline is captured only after preparation completes, so test-induced changes remain distinguishable from the declared prepared state.

Tests must use that supplied prepared target/environment unchanged as their execution base. They may create scenario-specific inputs and resources inside it, but they must not create another target clone/copy, another replacement user environment, or a fake RumiAI-owned component whose real behavior is claimed by the test.

The normal validation isolation granularity is `session`: one disposable environment spans the complete `rumiai-validate` invocation so the suite can also reveal cumulative state effects. `rumiai-validate` also provides a stronger `test` isolation mode in which each discovered test receives a newly created disposable environment. That mode mechanically prevents one test's filesystem state from becoming another test's starting state. Test correctness must not depend on which isolation granularity is selected.

Formal validation performs an automatic metadata-only filesystem audit of each disposable environment from its prepared baseline until immediately before destruction. In `session` mode this comparison covers the whole validation invocation; in `test` mode it covers each per-test environment lifetime. `CHANGED` is evidence, not an automatic test failure. Failure to complete a required audit is validation infrastructure error.

This environment isolation is not a security sandbox. Processes still execute on the real host and may access host resources not redirected by the validation environment when their permissions allow it.

Each test remains responsible for cleanup that is semantically part of its scenario, especially processes or external resources whose lifetime must end before the assertion is complete. Environment destruction and generic target/user-state cleanup belong to `rumiai-validate`, not to the individual test.

`rumiai-test` does not implicitly implement target-specific sandboxing, setup, teardown or workspaces.

## 13. Logging and diagnostics

The runner captures test stdout and stderr into a single ordered stream equivalent to:

```sh
1>logfile 2>&1
```

A `FAIL` or `ERROR` must make at least the failed property, expected value and observed value understandable when applicable.

For `FAIL`, diagnostics should identify the protected invariant or specification rule when practical. For `ERROR`, diagnostics should identify the test/harness stage that prevented observation. This distinction must be visible without reverse-engineering the test implementation.

Diagnostics should be concise and cause-oriented rather than large unnecessary dumps.

## 14. External tools

An external tool is tested only for properties on which RumiAI concretely depends.

Do not generically validate an entire external utility, runtime or service.

## 15. Development runs and execution environments

A development run supports the fast loop:

```text
development -> targeted tests -> correction -> targeted tests
```

Target and suite may be dirty and the run does not constitute formal evidence for a commit.

### ChatGPT/Linux auxiliary environment

When ChatGPT provides an executable Linux environment, use it as a fast real laboratory when materially useful: execute the real target in the environment being exercised, reproduce failures, perform exploratory tests, verify host-specific assumptions and develop permanent tests. Formal disposable target/user-state isolation remains a responsibility of `rumiai-validate`, not of permanent `.test` files.

The auxiliary environment is not a shortcut around target-authenticity rules. It must execute the same real entrypoints and components intended to be verified. When an exploratory result protects a property worth keeping, move that property into the `rumiai-tests` suite rather than leaving it as ephemeral session knowledge.

### GitHub Actions

GitHub Actions is an automated orchestration environment for executing real tests on clean GitHub-hosted runners and, when useful, across multiple operating systems or architectures. The workflow must not reimplement test semantics or replace target components: it should prepare the exact required revisions and invoke `rumiai-test` or `rumiai-validate` for the appropriate selections.

The current normal use is after local/auxiliary refinement of the test or work unit, when checking the same behavior from clean or different environments adds material information. Running Actions after every local modification is unnecessary when it adds no meaningful evidence.

RumiAI does not use GitHub required status checks as merge authority or as a substitute for work-unit judgment. Actions results are technical evidence and diagnostics; they do not independently authorize promotion and do not automatically block Git history. Introducing a required status check or automatic merge gate in the future requires a new explicit decision.

Self-hosted runners are not part of the current workflow. They may be reconsidered in the future but must not be introduced implicitly as a suite or validation requirement.

### Headless GUI

Headless GUI execution is an execution technique, not a separate validation level. When the property allows it, a real graphical application may be exercised with its real toolkit and required real services using infrastructure such as a virtual display, session bus and accessibility stack, for example Xvfb, D-Bus and AT-SPI.

A headless test must launch and drive the real application; it must not replace GTK, application code or another component belonging to the verified property with a fake. It may validate properties such as application start, window/widget creation, input, actions, dialogs, observable transitions and accessibility structure when those properties do not depend on the complete physical desktop.

A headless test does not prove properties that genuinely depend on GNOME Shell, Mutter/Wayland, portals, keyring, graphics acceleration, multi-monitor behavior or another desktop integration absent from the exercised environment. Those properties require an appropriate real environment before they can be declared validated.

### GitHub Codespaces

GitHub Codespaces is an interactive remote development environment, not a replacement for GitHub Actions and not a required component of the current testing workflow. It may be reconsidered for onboarding or remote development, but its availability does not itself add validation evidence and must not become a project dependency implicitly.

### Normal progression

When applicable, the desired progression is:

```text
development/change
    -> real execution and exploratory testing on a local or auxiliary host
    -> real permanent test refined in rumiai-tests
    -> GitHub Actions on clean/multi-host environments when it adds value
    -> product expected to be complete and working
    -> physical validation on the required real hosts
```

Not every work unit requires every intermediate step, but each used step must exercise the real property it claims to verify. The purpose of progression is to move defect discovery as early as possible, not to accumulate formal gates.

## 16. Validation run, session result and task validation

A validation run produces evidence associated with precise revisions.

Distinguish three levels:

```text
test result       result of an individual property
session result    aggregation of tests executed in the session
task validation   evaluation of only the tests required by the work unit
```

The overall session result does not automatically invalidate a work unit.

If a session contains tests from multiple contexts, a work unit is validated when **all tests declared necessary by its validation scope PASS** on the applicable hosts. FAIL, ERROR or SKIP from tests outside the scope remain real evidence but do not invalidate that work unit.

A required test that returns `SKIP` is not a PASS: the work unit remains unvalidated on that host until the required property is actually exercised or the applicable scope/host is corrected by authoritative current input.

Required test selection must be fixed **before validation** based on:

- the changed contract;
- directly and materially affected consumers;
- relevant known regressions;
- cross-platform properties actually involved.

The scope must not be narrowed after a failure merely to exclude a test that demonstrated material dependence on the change.

If a test initially considered unrelated fails during a session and analysis shows that the work unit caused the failure, that test enters the required scope before closure.

## 17. Validation scope

A **validation scope** is the versioned set of selections required to validate a work unit or health gate.

A scope may contain one or more existing tests or groups. It does not require duplicating tests into a new hierarchy.

For a `rumiai-os` scope, target-environment prerequisites are versioned with the scope rather than hidden in an external workflow. Current preparation records are:

```text
target-package<TAB><package-spec>
pkg-catalog-commit<TAB><exact-commit>
```

`target-package` is repeatable and means that the real disposable target must successfully execute `pkg install <package-spec>` during launcher preparation. `pkg-catalog-commit` is a singleton and is required when one or more target packages are declared; it is invalid without target-package preparation. The package spec uses the package subsystem's existing operand grammar rather than introducing a validation-only package identity syntax.

At least two uses are distinguished:

```text
task    minimum sufficient scope to close a work unit
health  broad system health/integrity check
```

The full suite is normally a `health` gate. It is appropriate for releases, milestones, cross-cutting changes or deliberate broad checks, but **it is not the universal prerequisite for closing every task**.

Different task scopes must be able to coexist and run independently so unrelated development is not blocked by unrelated failures.

## 18. Formal validation requirements

Unless a documented exception applies:

- the target and `rumiai-tests` must be committed;
- the `rumiai-tests` working tree used to launch validation must be clean;
- the target environment must start from a clean disposable clone of the exact configured target commit, with any declared platform/package preparation performed only inside that disposable environment before the audit baseline;
- commits/revisions, host, architecture, selected target platform, date/time, executed selections, results, logs and validation-environment audit evidence must be recorded;
- when package preparation participates, the declared package operands and actual `pkg-catalog` commit used by the real package path must also be recorded;
- evidence must remain immutable and revision-specific.

Cross-host task validation is closed only when all required scope tests PASS on all required applicable hosts.

Previous sessions remain valid for properties they actually exercised; an overall FAIL session does not turn its individual PASS results into FAIL.

A validation cannot attribute to a PASS a property that the test did not actually exercise. In particular, a test that replaces parts of the target cannot close a scope requiring the real composed behavior of those parts.

Physical validation on stable reference hosts remains the final stage when required by the work unit and is governed by `PHYSICAL-TESTING.md`. Executions on auxiliary hosts or GitHub-hosted runners should precede it when materially useful, but are not retrospectively renamed as physical validation of a stable host they did not exercise.

## 19. `rumiai-test` and `rumiai-validate`

`rumiai-test` remains the simple semantically agnostic runner. Runner discovery, execution, logging, persistence and exit statuses are defined in `RUNNER.md`. Its discovery-only `--list` mode is the canonical way for another RumiAI testing tool to expand a selection into the exact ordered test identifiers that the runner would execute.

`rumiai-validate` is the operational formal-validation launcher. It applies a versioned validation scope, prepares the exact disposable target/user environment, invokes the unchanged real tests, performs the validation-environment filesystem audit, publishes revision-specific evidence and aggregates the scope result without moving target assertions into the runner.

For `rumiai-os`, formal validation always executes an independent disposable Git clone at the exact configured commit rather than the operator's target working tree or a Git worktree attached to it. The operator checkout may be used as a source/update point by the launcher, but it is never the target executed by the validation tests. Host-platform selection and target-package preparation are launcher responsibilities performed through the disposable target's own canonical public commands; they must not be moved into workflows, permanent tests or `rumiai-test`.

The default validation isolation granularity is `session`. The explicit stronger `test` mode uses `rumiai-test --list` to obtain canonical discovery and then runs each listed test in a fresh disposable environment; the validator must not duplicate runner discovery rules.

An external workflow, including GitHub Actions, must remain an orchestrator: it may prepare hosts and invoke these tools, but must not duplicate target semantics or assertions that belong in `.test` files.

## 20. Promotion and removal of tests

A corrected bug should produce a regression test when reproduction is deterministic, maintainable and protects a property that must remain true.

Not every test bug requires another test of the test. Common infrastructure corrections should preferably be concentrated in the appropriate shared library and protected at the lowest useful level.

A permanent test may and should be removed when its property is superseded, duplicated or no longer materially useful. Historical evidence remains immutable in previous commits/sessions.

## 21. Source of truth

`rumiai-dev` defines current testing rules and expected behavior.

`rumiai-tests` contains executable test implementation and revision-specific validation evidence.

`rumiai-dev-PoCs` contains experiments and PoCs.

`rumiai-os` contains product/runtime implementation and does not become the normative source of testing rules.

When a test suite conflicts with current `rumiai-dev` contracts, the current contracts prevail and the test must be realigned or removed.
