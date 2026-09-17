# RumiAI Testing Rules

Status: **Current / canonical**  
Updated: 2026-09-17

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

This independence **does not prohibit** shared libraries from the same `rumiai-tests` revision. Infrastructure helpers such as target discovery, creation of complete isolated target replicas, path normalization, temporary-resource plumbing and interactive drivers should be shared when the responsibility is genuinely common.

The exact `rumiai-tests` Git revision is already part of validation evidence and makes the shared-helper version used by a session reproducible.

Inline copying of common helpers is not the default. It is allowed only when the copied content is intentionally part of the specific test semantics or when there is a documented reason to freeze it inside that test.

## 5. Responsibility of an individual test

Each test must verify a clearly identifiable property.

The test owns:

- test-specific preconditions;
- scenario-specific preparation;
- external inputs and, only when explicitly allowed, semantically specific simulations or fixtures;
- execution of the target;
- expected result;
- comparison between expected and observed behavior;
- specific diagnostics;
- cleanup of resources created by the test.

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

When the target must be protected from test effects, use a complete isolated replica that is semantically indistinguishable from the real system for the property being verified. The replica must use the real target revision, real executables, real libraries, real adapters, real files and normal execution path. State, `HOME`, temporary directories and other mutable resources may and should be isolated when necessary, provided that isolation does not replace target logic.

For behavior exposed by a command, the normal test form is a small number of real commands invoking the real executable through its normal interface with arguments chosen to cover the contract cases. A test of `pkg install` must actually execute `pkg install` and traverse the real pipeline used by that command.

The following do not prove real target behavior:

- copying individual target files or fragments into an ad-hoc structure;
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

Direct execution and execution through `rumiai-test` must exercise the same verification logic.

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

A real host incompatibility with a required property is `FAIL`, not `SKIP`.

Historical outcomes are never reinterpreted retroactively.

## 12. Isolation and cleanup

A test that may modify state or produce persistent effects must not therefore be transformed into a target simulation. When protecting the operator's original checkout or installation is necessary, the test should create or use a complete disposable replica of the real system, or isolate only mutable state while preserving the real execution path.

A target replica used for testing must come from the real revision under test, not from a selected collection of files rewritten or reconstructed ad hoc. The principle "do not modify the real target" means do not alter the operator's original instance; it does not mean replace the target with fixtures that imitate individual parts.

Each test owns and cleans up resources created specifically for that test. Cleanup should be attempted after `FAIL` or `ERROR` as well.

The runner does not implicitly implement target-specific sandboxing, setup, teardown or workspaces.

## 13. Logging and diagnostics

The runner captures test stdout and stderr into a single ordered stream equivalent to:

```sh
1>logfile 2>&1
```

A `FAIL` or `ERROR` must make at least the failed property, expected value and observed value understandable when applicable.

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

When ChatGPT provides an executable Linux environment, use it as a fast real laboratory when materially useful: execute the real target or a complete replica, reproduce failures, perform exploratory tests, verify host-specific assumptions and develop permanent tests.

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
- working trees used for the test must be clean;
- commits/revisions, host, architecture, date/time, executed selections, results and logs must be recorded;
- evidence must remain immutable and revision-specific.

Cross-host task validation is closed only when all required scope tests PASS on all required applicable hosts.

Previous sessions remain valid for properties they actually exercised; an overall FAIL session does not turn its individual PASS results into FAIL.

A validation cannot attribute to a PASS a property that the test did not actually exercise. In particular, a test that replaces parts of the target cannot close a scope requiring the real composed behavior of those parts.

Physical validation on stable reference hosts remains the final stage when required by the work unit and is governed by `PHYSICAL-TESTING.md`. Executions on auxiliary hosts or GitHub-hosted runners should precede it when materially useful, but are not retrospectively renamed as physical validation of a stable host they did not exercise.

## 19. `rumiai-test` and `rumiai-validate`

`rumiai-test` remains the simple semantically agnostic runner. Runner discovery, execution, logging, persistence and exit statuses are defined in `RUNNER.md`.

`rumiai-validate` is the operational launcher. It may apply a versioned validation scope composed of multiple selections and aggregate evidence without moving target semantics into the runner.

The launcher may use a temporary Git checkout/worktree of the exact target revision when needed to validate different scopes without modifying the operator's main checkout. Such a checkout/worktree is a real target replica: tests must continue to use the real entrypoints and components of that revision, not ad-hoc copies or substitutions of the verified pipeline.

An external workflow, including GitHub Actions, must remain an orchestrator: it may prepare checkouts, select hosts and invoke these tools, but must not duplicate target semantics or assertions that belong in `.test` files.

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
