# mk tool development

Status: Active
Updated: 2026-09-22

## Goal

Continue development of `mk` as the `m` subsystem for project development-lifecycle orchestration, starting from the promoted JavaScript/JSON lifecycle baseline and extending it only from concrete project needs.

## Current repository revisions

```text
rumiai-dev   1e8119bab2af742ad8ca2495c21aeea35d5f55f7  (pre-checkpoint HEAD before this handoff synchronization)
rumiai-os    bacf3b6d37b508c6b07bd8b6bb88019bc50a627f  (current main; mk implementation unchanged since validated 6f26a4993337b7020d1ace2d46c827538b6de966)
rumiai-tests 0b5fabccd79092af5c452dec65ddc7b49ad57d9a  (current main; lifecycle.test unchanged since validated workflow revision)
pkg-catalog  39abe7d9ae53753dda9e2714fc39fe69adfafb8c  (current main at final consistency check)
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

## Working design still open

The following areas remain deliberately unresolved and must be derived from concrete lifecycle cases rather than treated as implicit features:

```text
project dependency execution/composition
declarative requirement resolution and its boundary with pkg facilities/providers
input/output and artifact semantics beyond the current process action
automatic source/input discovery
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

The next design/implementation work should therefore stress the existing model with a real project shape rather than adding abstractions speculatively.

## Next action

Use one or more concrete project scenarios to extend the current baseline. Good stress cases remain:

```text
delegation to Maven or CMake as one opaque operation
native C/C++ compilation with automatically discovered sources
generated sources feeding later operations
project-to-project dependency orchestration
long-running JavaScript development/hot-update flow
```

Promote or implement a new abstraction only when those cases demonstrate that the current goal/operation/prerequisite/process model is insufficient.

## Blockers / open questions

- What exact semantics should project `dependency` have when requested goals differ across dependent projects?
- Should `requirement` resolve directly to an existing `pkg` facility/provider contract, or is an additional mk-level abstraction justified by a concrete build-time need?
- Which explicit input/output identity is minimally sufficient for correct incremental execution?
- Does long-running/watch execution belong to operation/action semantics or to an execution-session/scheduler layer?
