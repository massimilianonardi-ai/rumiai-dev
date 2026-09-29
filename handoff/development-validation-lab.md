# development-validation-lab

Status: Active
Updated: 2026-09-29

## Goal

Design a developer-facing live experimentation and validation environment mechanism that can run real, disposable scenarios during RumiAI design/development, preserve the useful exploratory workflow of the historical m test-command, and provide a path for mature scenarios to support formal validation without duplicating rumiai-test or rumiai-validate responsibilities.

## Repository / validation evidence revisions

- baseline cross-host lifecycle validation remains recorded at `rumiai-os@5e4d66d9c67248409f165e80542d8c39bf70b957` / `rumiai-tests@c236f7497da0c468605078a9960f988af7e97534`, GitHub Actions run `36537384660`
- first substantial real scenario product revision: `rumiai-os@89e215c43d57fd96e8557799b764fff4f5bed7e3`
- updated base `testlab` validation with the shipped `rsudo` scenario present passed on Ubuntu and macOS in run `36541262130`
- real `testlab -> rsudo -> ssh -> sshd -> sudo` task validation passed at `rumiai-tests@25fbd5320ecbe5b724e656f6426605bb36e4e33e`, GitHub Actions run `36542681411`, against `rumiai-os@89e215c43d57fd96e8557799b764fff4f5bed7e3`
- the `testlab-rsudo` task scope was then returned to normal current-product semantics by removing its historical `rumiai-os-commit` pin; GitHub Actions run `36579379290` passed against current `rumiai-os@b1a785cad13ae11bf85f2626f470a2c2c32bab82` with `rumiai-tests@c8510ea893d7da8bada593ac2bfb7c51a8b961fd`
- the same persistent `rsudo` scenario was then reused for a second activity in the same instance: real `rsudo exec inject` with an injected library, repeatable named command, one-shot command, stdin continuation and privileged UID observation; run `36584756699` returned `VALIDATED` against `rumiai-os@e31d930534e6536c62d7953fca9398f9006eee28` / `rumiai-tests@12a22021fadf49250464f053700e48bcec9ad012`
- rumiai-dev-PoCs is retained only as historical experimental evidence for this task; it is no longer an implementation gate

Exact current remote HEADs must still be rechecked at the start of every resumed work unit; this handoff records task/evidence identity rather than pretending that unrelated concurrent repository development is frozen.

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/CURRENT-MODEL.md
- specifications/rumiai-os/TESTLAB.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- specifications/rumiai-os/STATE-MODEL.md
- specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
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

## User correction — 2026-09-29

The original implementation created a new project-root `testlab/` directory. That placement was not explicitly authorized and conflicted with the existing filesystem/resource model: controlled top-level roots already exist, and naming rules do not independently create architectural roots.

The corrected placement is:

```text
<project-root>/res/sys/testlab/scenarios/<scenario>
```

`testlab` is therefore a concrete technical `sys` resource class under the existing `res/` root. No project-root `testlab/` namespace remains part of the current contract.

## Fixed task-local choices

- The working command identity is `testlab`.
- Scenario definitions use the existing `res/sys/testlab/scenarios/` resource hierarchy; `testlab` does not create a new project-root directory.
- The historical massimilianonardi-ai/m repository is reference material only, not current authority.
- The new mechanism must not turn rumiai-test into an environment preparer or assertion-aware orchestrator.
- Permanent test assertions remain in normal .test files; environment/lab orchestration must not become an alternative implementation of target behavior.
- Podman is an optional scenario-specific implementation choice. The current `rsudo` scenario uses host Podman, but Podman is not a global `testlab` prerequisite and remains explicitly outside the macOS baseline.
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
- For `rsudo`, the Podman-backed real SSH/sudo target is now a shipped project scenario. It creates one owned disposable container, uses a random localhost SSH port, exposes SSH/sudo handles through scenario context, and keeps the project checkout plus base image external. Random-port adaptation remains scenario-local through a PATH `ssh` wrapper and does not change the public `rsudo` interface.

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
- The scenario/lifecycle model is now promoted in `specifications/rumiai-os/TESTLAB.md`; this handoff section is retained only for task-local development context and does not override the canonical specification.
## Completed

- The historical `m` test-command, current testing/validation contracts and representative interactive/environment mechanisms were analyzed to recover useful development-lab behavior without inheriting historical implementation structure.
- The minimal scenario model was established around concrete scenario instances, prerequisite checks before mutation, per-resource ownership, readiness, factual context, persistent recovery inventory and cleanup restricted to owned resources.
- PoC 047 demonstrated a real Podman-backed rsudo/SSH/sudo scenario lifecycle in hosted CI. It remains historical evidence for a possible container-backed scenario, not a product prerequisite.
- PoC 048 investigated prompt-synchronized PTY automation and reversible operator handoff. Hosted/macOS evidence was useful, but repeated physical Linux failures made this line of investigation disproportionately expensive. On 2026-09-29 the user explicitly stopped further PoC 047/048 debugging and removed all such physical/PTY work as a gate for `testlab`.
- PoC 050 explored and rejected moving scenario-specific SSH command selection into rsudo; no product contract was promoted from that path.
- Ownership is closed: `testlab` belongs to technical `m` and is implemented in `rumiai-os`.
- The initially introduced top-level `rumiai-os/testlab/` layout was identified as unauthorized filesystem-model drift and corrected forward: scenarios now live under `rumiai-os/res/sys/testlab/scenarios/`, with `testlab` explicitly promoted as a technical resource class.
- The current product contract was promoted in `specifications/rumiai-os/TESTLAB.md`.
- The first product implementation added `bin/sys/testlab`, its mandatory operational manual, and project-local `host` and `scratch` scenarios.
- Permanent contract/lifecycle tests and a dedicated Linux/macOS formal-validation workflow were added in `rumiai-tests`.
- The first validation attempt exposed only a test-suite root-resolution defect; evidence from both hosts identified the same harness error and it was corrected.
- The next macOS run exposed a real portability defect: passing `--` to a utility that did not support it. Product and tests were corrected according to `POSIX-PORTABILITY-LAYER.md`.
- Formal validation run `36537384660` then passed on both Ubuntu and macOS for the current baseline, against `rumiai-os@5e4d66d9c67248409f165e80542d8c39bf70b957` and `rumiai-tests@c236f7497da0c468605078a9960f988af7e97534`.
- The first substantial real scenario `rumiai-os/res/sys/testlab/scenarios/rsudo` was promoted. It prepares a real password-authenticated OpenSSH/sudo target in one owned Podman container, records target/image as external resources, exposes connection facts in context, and uses direct inherited terminal streams for interactive `enter`.
- `TESTLAB-15` and `TESTLAB-16` were added to the canonical specification to keep Podman/SSH tooling scenario-specific and to constrain cleanup to the created container.
- Base `testlab` validation run `36541262130` passed on Ubuntu and macOS with the new scenario shipped, confirming that Podman did not become a global prerequisite.
- Initial `testlab-rsudo` validation attempts exposed test-harness issues rather than product failures: the disposable target was incorrectly compared with an empty Git status instead of its post-preparation baseline, and rootless Podman storage initially leaked into the validator's isolated `HOME`. The permanent test now compares target before/after state and the workflow supplies the already-prepared host Podman environment explicitly.
- Formal task validation run `36542681411` passed the real `testlab -> rsudo -> ssh -> sshd -> sudo` path with UID 0 observed, scenario cleanup completed, and scope result `VALIDATED` against `rumiai-os@89e215c43d57fd96e8557799b764fff4f5bed7e3` / `rumiai-tests@25fbd5320ecbe5b724e656f6426605bb36e4e33e`.
- `validation/testlab-rsudo.conf` no longer pins the original product revision. It now follows the normal current-product path of `rumiai-validate`; run `36579379290` returned `VALIDATED` with one PASS and zero FAIL/SKIP/ERROR against `rumiai-os@b1a785cad13ae11bf85f2626f470a2c2c32bab82` / `rumiai-tests@c8510ea893d7da8bada593ac2bfb7c51a8b961fd`. This confirms the shipped scenario remains usable across subsequent rsudo evolution for the protected real `id -u` path; it does not by itself validate rsudo injection/admin behavior.
- `tests/rumiai-os/testlab-rsudo/real.test` now deliberately performs multiple activities against one ready scenario instance. In addition to the direct privileged `id -u` probe, it executes current `rsudo exec inject` through the real SSH/sudo target with injected `array`, a named helper, a one-shot command and continuation stdin, verifying isolated statuses and UID 0. GitHub Actions run `36584756699` passed with one PASS and zero FAIL/SKIP/ERROR and scope result `VALIDATED`. This is concrete evidence that scenario lifetime is reusable across activities without moving activity assertions into `testlab` itself.

## Current state

The first real `testlab` baseline is promoted and implemented.

Canonical contract:

- `specifications/rumiai-os/TESTLAB.md` owns the current semantics;
- `testlab` belongs to `m`;
- project scenarios are executable child programs under `<project-root>/res/sys/testlab/scenarios/`, never sourced;
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
rumiai-os/res/sys/testlab/scenarios/host
rumiai-os/res/sys/testlab/scenarios/scratch
rumiai-os/res/sys/testlab/scenarios/rsudo
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
- `scratch` creates an instance-owned disposable work directory;
- `rsudo` creates one owned disposable Podman SSH/sudo target while keeping the project checkout and image external.

Permanent baseline coverage lives under `rumiai-tests/tests/rumiai-os/testlab/`, with task scope `validation/testlab.conf` and Linux/macOS workflow `.github/workflows/testlab.yml`. The real `rsudo` scenario is additionally protected by `tests/rumiai-os/testlab-rsudo/real.test`, `validation/testlab-rsudo.conf` and the Ubuntu host-prepared workflow `.github/workflows/testlab-rsudo-scenario.yml`. The `testlab-rsudo` task scope intentionally has no persistent product revision pin; revision freezing belongs to the individual validation invocation/evidence when needed.

Formal validation run `36537384660` passed on both `ubuntu-latest` and `macos-latest` against product revision `5e4d66d9c67248409f165e80542d8c39bf70b957` and test-suite revision `c236f7497da0c468605078a9960f988af7e97534`. The validation exercises real product lifecycle behavior including prerequisite rejection before instance allocation, persistent preparation, context publication, frozen-scenario re-entry, owned-resource cleanup, repeated close, failed-prepare recovery and status reporting.

The first macOS validation attempt also exposed a real GNU/BSD portability defect: the new code/tests passed `--` to utilities whose current host implementation does not accept that terminator. The product and tests were corrected to follow the current `POSIX-PORTABILITY-LAYER.md` rule that `--` is used only where the invoked utility actually supports it.

## Next action

The first substantial real scenario is now implemented and formally exercised. Do not extract a generic Podman/provider layer from a single scenario.

Continue from concrete development needs:

1. use the shipped `rsudo` scenario as the disposable real SSH/sudo environment for rsudo/SSH development activities when that reality is useful;
2. exercise the normal interactive-first `testlab` menu/enter flow during real development and refine it only when concrete friction is observed;
3. add a second substantial scenario only when a distinct RumiAI development need requires one;
4. after at least two real scenarios share the same non-trivial mechanics, evaluate whether those repeated mechanics deserve a common `m` abstraction;
5. do not reopen PTY/Expect handoff work unless a concrete scenario cannot be served by direct inherited terminal interaction.

The current `rsudo` validation deliberately uses an explicitly prepared host Podman environment. Generic `rumiai-validate` host-prerequisite preparation has not been introduced; that larger validation concern remains separate from `testlab`.

## Blockers / open questions

No blocker remains for continued `testlab` development.

Still intentionally open:

- which distinct substantial scenario, if any, is justified next by a concrete development need;
- which, if any, repeated scenario mechanics deserve a shared `m` abstraction after multiple real uses;
- the exact future boundary for mature scenario reuse by `rumiai-validate`;
- whether a future concrete need justifies any PTY/dialogue adapter.

Podman remains an optional scenario-specific implementation choice rather than a global `testlab` or macOS prerequisite.
