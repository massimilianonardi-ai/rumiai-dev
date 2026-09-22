# mk tool development

Status: Active
Updated: 2026-09-22

## Goal

Continue development of `mk` as the `m` subsystem for project development-lifecycle orchestration, extending the promoted declarative lifecycle model from concrete project needs while keeping tool/language-specific behavior outside the core.

## Current repository revisions

```text
rumiai-dev       c4370189dfdf9f9d844a631048efc402ac21fb7b  (pre-synchronization HEAD)
rumiai-os        926179d3cb8808623dfe6f0bfed1e982dd0763ee
rumiai-tests     89e079fa0487551451db5ec0acf5eb43969a9f50
rumiai-dev-PoCs  1ee1da8f2295ef694dc542def05e012f907fe64e
pkg-catalog      64d67a73f4f9485749e1b47712e42f77afb4773e
```

Fresh remote HEAD retrieval remains mandatory before later work.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
RUNNER.md
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

Additional subsystem specifications are retrieved only when a future `mk` extension crosses their boundary.

## Fixed task-local choices

The validation scope for the runtime-refinement work unit is fixed to:

```text
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
```

The scope is stored in:

```text
rumiai-tests/validation/mk-runtime-refinement.conf
```

and is pinned to `rumiai-os` commit `926179d3cb8808623dfe6f0bfed1e982dd0763ee`.

## Completed

The contextual/conditional runtime-refinement design requested by the current task has been promoted and implemented.

PoC 016 established the minimal general model for:

- context-derived file collections;
- generated-source collections blocked by successful current-request completion;
- trusted operation providers;
- result/output/state condition operands;
- conditional plan structure;
- iterative runtime refinement;
- compatibility with version-1 static planning.

The durable contract is now canonical in:

```text
specifications/rumiai-os/MK.md
specifications/rumiai-os/CURRENT-MODEL.md
```

`rumiai-os` commit `926179d3cb8808623dfe6f0bfed1e982dd0763ee` implements:

- version 1 unchanged as the static fully resolved lifecycle model;
- version 2 contextual `files` collections;
- explicit include/exclude/profile replacement;
- `after` barriers requiring successful current-request completion;
- trusted `map-process` provider derivation;
- declarative `when` conditions;
- result/output/state operands;
- named declared outputs;
- `failure: "continue"`;
- structured version-2 plan output;
- iterative resolve/execute/observe/refine execution;
- dependency-cycle rejection across the dynamic model.

The implementation also protects these edge cases:

- a skipped producer does not satisfy a generated-collection `after` barrier;
- a failed/skipped producer cannot make a stale pathname count as current-request output evidence;
- provider prerequisites remain effective when the mapped collection is empty.

The command and library manuals were realigned in the same product commit. The library exposes only public `mkMain`; all implementation helpers remain underscore-prefixed.

`rumiai-tests` now contains permanent `refinement.test` coverage for the dynamic model and retains `lifecycle.test` for the version-1/static vertical.

## Validation evidence

Hosted development validation used the unchanged permanent tests through `rumiai-test` and the real public `mk` command after provisioning the real RumiAI-managed Node.js package.

GitHub Actions run:

```text
35768833988
```

Exact revisions exercised:

```text
rumiai-os
    926179d3cb8808623dfe6f0bfed1e982dd0763ee

rumiai-tests
    570dcde5142c38e130295ee46912e87e7882f319
```

Ubuntu hosted runner:

```text
PASS rumiai-os/mk/lifecycle.test
PASS rumiai-os/mk/refinement.test
PASS 2 / FAIL 0 / SKIP 0 / ERROR 0
```

macOS hosted runner did not reach either `mk` test. `pkg install nodejs` failed three consecutive times because the real Node.js distribution request returned HTTP 403. This is a provisioning/upstream blocker, not evidence against the `mk` behavior under test.

The temporary hosted-development workflow was removed after recording the run; current `rumiai-tests` HEAD therefore contains the permanent test and validation scope but not the temporary workflow.

Formal `rumiai-validate` task validation has not been closed. The current permanent tests deliberately SKIP when a managed/default Node.js runtime is absent, while the current formal validator creates a clean disposable target clone and this work unit did not introduce a validation-environment package-provisioning hook. Required SKIP is not PASS under `TESTING.md`.

## Current state

There is no known remaining specification/implementation mismatch for the runtime-refinement model covered by this work unit.

The promoted version-2 contract and the current implementation now agree on:

```text
declarative intent
+ current observable context
→ partially resolved structured plan
→ execute ready work
→ observe new evidence
→ refine
→ continue
```

The current baseline still deliberately excludes:

```text
incremental fingerprints/cache
parallel scheduling
remote execution
project-to-project dependency execution
declarative requirement resolution
watch/hot-update session semantics
public generic provider/plugin registration
```

## Next action

Use project-to-project dependency orchestration as the next concrete stress case for `mk`.

The next work unit should determine the smallest declarative/runtime semantics needed when one project depends on another and requested goals may differ, reusing the current resolution/refinement model instead of inventing a second orchestration mechanism.

Keep the macOS Node.js hosted-provisioning blocker explicit; do not alter `pkg` from this `mk` task merely to manufacture validation evidence.

## Blockers / open questions

- macOS hosted `pkg install nodejs` currently receives HTTP 403 from the real Node.js distribution endpoint, preventing hosted macOS execution of the permanent `mk` tests;
- formal task validation still lacks a managed-Node provisioning path inside the disposable `rumiai-validate` target environment;
- what exact semantics should project `dependency` have when requested goals differ across dependent projects?
- should a future `requirement` resolve directly to an existing `pkg` facility/provider contract or require a distinct `mk` abstraction?
- what explicit input/output identity is minimally sufficient before incremental execution can be designed?
- where should long-running/watch behavior live relative to operation/action versus session/scheduler semantics?
