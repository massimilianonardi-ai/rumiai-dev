# mk tool development

Status: Active
Updated: 2026-09-22

## Goal

Continue development of `mk` as the `m` subsystem for project development-lifecycle orchestration, starting from the promoted JavaScript/JSON lifecycle baseline and extending it only from concrete project needs.

## Current repository revisions

```text
rumiai-dev      eca99e4a77b29dfa67230072b4f30fd156f6100f  (pre-checkpoint HEAD before this handoff synchronization)
rumiai-os       c2dcde09c2582ff67733911816088952fa1eb5ee  (current mk implementation exercised by native C++ PoC)
rumiai-tests    12992b0b3d6198347a393f2735db725f49d0ba0e  (current main; mk lifecycle permanent test unchanged by this work)
rumiai-dev-PoCs 28c83b01aaa1e95ad47d7966e2ef64d9db13e396  (native C++ graph-expansion PoC with recorded result)
pkg-catalog     64d67a73f4f9485749e1b47712e42f77afb4773e  (current main; no GCC/Clang package definition found for this PoC)
legacy m        2a57a29880c2d7a32e18782122062c695fcb1a3a  (reference-only current master used for historical makefile evidence)
```

Fresh remote HEAD retrieval remains mandatory before later work.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/CURRENT-MODEL.md
specifications/rumiai-os/MK.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
handoff/README.md
```

Additional subsystem specifications are retrieved only when a future mk extension actually crosses their boundary.

## Completed in the current implementation checkpoint

- The lifecycle contract was promoted in `specifications/rumiai-os/MK.md`.
- JavaScript is the current mk lifecycle-engine implementation language.
- JSON is the current declarative project configuration representation.
- The project configuration identity is project-root `mk.json`.
- The public command is goal-driven rather than based on hard-coded lifecycle subcommands.
- `dependency`, `prerequisite` and `requirement` have distinct meanings in the promoted model.
- The obsolete source-materialization capability, its specification, shell implementation, operational manuals and permanent test were removed.
- `bin/sys/mk` is a thin bootstrap-integrated launcher.
- `lib/sys/js/mk.lib.js` implements the first lifecycle vertical:
  - project discovery;
  - JSON parsing/validation;
  - profile overlays;
  - goal resolution;
  - operation/prerequisite planning;
  - cycle/reference validation;
  - `--goals`, `--show-goal` and `--plan`;
  - multiple requested goals as one plan;
  - sequential execution;
  - shell-free `process` actions.
- The public command and JavaScript library manuals were realigned with the implementation.
- The initial parser syntax defect discovered during test preparation was corrected in `rumiai-os` commit `6f26a4993337b7020d1ace2d46c827538b6de966`.
- `tests/rumiai-os/mk/lifecycle.test` replaced the obsolete materialization test and exercises the real public command.

## Validation evidence

A temporary GitHub Actions development workflow provisioned the managed Node.js runtime through the real `pkg` path and then executed the unchanged permanent lifecycle test through `rumiai-test`.

Evidence:

```text
GitHub Actions run
    35711640304

rumiai-os exercised
    6f26a4993337b7020d1ace2d46c827538b6de966

rumiai-tests exercised
    dc58d8df8592ea05cd5dc243ca9c3f56473e0d2d

Ubuntu hosted runner
    PASS rumiai-os/mk/lifecycle.test
    PASS 1 / FAIL 0 / SKIP 0 / ERROR 0

macOS hosted runner
    job completed successfully
    managed Node.js installation succeeded
    mk lifecycle permanent-test step succeeded
```

The temporary workflow was removed afterward in `rumiai-tests` commit `0b5fabccd79092af5c452dec65ddc7b49ad57d9a`; the validated `lifecycle.test` content remains unchanged.

After validation, `rumiai-os` advanced to the current HEAD only through concurrent changes to `readpass`/`readpassv`. The current `bin/sys/mk` and `lib/sys/js/mk.lib.js` blobs remain unchanged from the validated mk revision, so the hosted evidence still applies to the current mk implementation.

This was development/hosted test evidence, not a formal `rumiai-validate` task-validation record and not physical-host validation.


### Maven delegation stress test

`pocs/014-mk-maven-delegation` tested the simplest external-engine case against a real Maven project.

The project model was deliberately minimal:

```text
goal build
    -> operation maven-package
    -> process action
    -> mvn -q package
```

There is no Maven-specific adapter in `mk`.

The PoC verifies that:

- `mk --plan build` resolves exactly one operation, `maven-package`;
- `mk build` delegates that operation to the real managed Maven package;
- Maven compiles the Java source and produces `target/mk-maven-poc-1.0.0.jar`;
- the built class executes through the selected managed Java provider and prints `mk-maven-ok`.

Hosted evidence:

```text
GitHub Actions run
    35717912561

PoC revision exercised
    7fdb760c31e9168db68f72e51d0d0b62b67c68da

rumiai-os exercised
    bacf3b6d37b508c6b07bd8b6bb88019bc50a627f

Ubuntu
    PASS poc-014 mk -> Maven delegation

macOS
    PASS poc-014 mk -> Maven delegation
```

The first PoC run (`35717818592`) failed before reaching `mk`: Maven was installed before a provider was selected for Maven's catalog-declared `java >=17` dependency. Reordering provisioning to install/select Temurin first and install Maven afterward made both hosts pass. This confirms an existing `pkg` dependency/provider rule; it does not justify Maven-specific behavior in `mk`.

Conclusion from this stress case: the current generic `process` action is sufficient for a simple opaque Maven delegation. No Maven-specific adapter or new mk core primitive is justified by this case.

During the same work unit, stale source-materialization wording in `PACKAGE-MODEL.md` was realigned with the current lifecycle boundary. `pkg` continues to own package/facility/provider/dependency semantics, while `mk` may consume package-provided tools/facilities without creating a parallel provider graph.


### Native C++ fine-grained stress test

`pocs/015-mk-native-cpp` tested the opposite end of the orchestration spectrum.

The current reference file:

```text
massimilianonardi-ai/m
var/#_os/m/bin/makefiles/makefile_type_cpp_gcc.mk
revision 2a57a29880c2d7a32e18782122062c695fcb1a3a
```

was used only as historical/design evidence. The relevant behavior is recursive source discovery, derived object paths/directories, one compile per source and one final link, with source add/remove/rename changing the effective graph without editing the build description.

The PoC first used a hand-written static `mk.json` containing separate compile operations and a final link operation. The current unmodified `mk` planner/executor built and ran that graph successfully.

The PoC then added a new translation unit and changed `main.cpp` to require it without changing the static graph. The build failed as expected because the new source had no operation. This isolates the missing behavior as graph derivation rather than compile/link execution.

A PoC-only JavaScript expander then performed:

```text
project filesystem
    -> deterministic source discovery
    -> concrete operation graph
    -> ordinary current version-1 mk.json
    -> existing mk planner/executor
```

The generated model uses only current primitives:

```text
goal
operation
prerequisite
process action
```

and successfully handled source add, rename and removal without editing the experimental project descriptor.

Hosted evidence:

```text
GitHub Actions run
    35720179362

PoC revision initially exercised
    1e3260d4f07b7e365ba1cde961cdac199988ed35

result-recording PoC HEAD
    28c83b01aaa1e95ad47d7966e2ef64d9db13e396

rumiai-os exercised
    c2dcde09c2582ff67733911816088952fa1eb5ee

Ubuntu
    PASS poc-015 mk native C++ graph expansion
```

The macOS job did not reach `mk` in either workflow attempt. Both attempts failed during `pkg install nodejs` because the upstream download returned HTTP 403. Therefore there is positive Ubuntu hosted evidence and no macOS execution evidence for this PoC; the macOS provisioning failure is not evidence against the mk graph model.

The architectural consequence is narrower than a new public API: the existing planner/executor is sufficient once a concrete graph exists. The demonstrated missing responsibility is **pre-planning derivation/expansion of the concrete operation graph from declarative project intent plus current project state**.

The PoC deliberately does not select the final expansion boundary. A trusted reusable builder/operation provider, a generic declarative expansion facility, or another extension mechanism remain working-design candidates. No `mk` product code or canonical schema was changed from this experiment.

## Working design still open

The following areas remain deliberately unresolved and must be derived from concrete lifecycle cases rather than treated as implicit features:

```text
project dependency execution/composition
declarative requirement resolution and its boundary with pkg facilities/providers
input/output and artifact semantics beyond the current process action
pre-planning graph derivation/expansion from project state
automatic source/input discovery within that expansion boundary
incremental invalidation and fingerprints
cache semantics
parallel scheduling and resource constraints
external-engine adapter interface
native/reusable builder or operation-provider interface
generated-source flows
long-running/watch/hot-update execution
workspace and persistent mk state layout when such state becomes necessary
documentation-build declarations inside the general lifecycle model
```

The current vocabulary remains useful for design discussion, but vocabulary terms do not by themselves create implementation requirements.

## Current state

The first executable lifecycle vertical is present and tested. The current implementation intentionally stops before incrementality, caching, parallelism, project dependency execution and a generalized extension/plugin API.

The delegated Maven case validated the coarse-grained end of the model. The native C++ PoC now validates that the existing planner/executor also handles the fine-grained end once a concrete graph has been produced. The next design question is therefore the extension boundary that produces such graphs, not a second execution architecture.

## Next action

Use one or more concrete project scenarios to extend the current baseline. Good stress cases remain:

```text
generated sources feeding later operations
project-to-project dependency orchestration
long-running JavaScript development/hot-update flow
```

Use the generated-source case next to compare graph-expansion boundary shapes before promoting or implementing one. In particular, determine whether one reusable operation-provider/builder boundary can express both filesystem discovery and generated-source graph growth without introducing a general executable configuration language or tool/language hard-coding in the mk core.

## Blockers / open questions

- What exact semantics should project `dependency` have when requested goals differ across dependent projects?
- Should `requirement` resolve directly to an existing `pkg` facility/provider contract, or is an additional mk-level abstraction justified by a concrete build-time need?
- Which explicit input/output identity is minimally sufficient for correct incremental execution?
- What trusted extension boundary should derive/expand concrete operations before planning without turning mk.json into executable configuration?
- Does long-running/watch execution belong to operation/action semantics or to an execution-session/scheduler layer?
