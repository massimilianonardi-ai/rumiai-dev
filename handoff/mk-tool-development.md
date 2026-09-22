# mk tool development

Status: Active
Updated: 2026-09-22

## Goal

Continue development of `mk` as the `m` subsystem for project development-lifecycle orchestration, extending the promoted declarative lifecycle model from concrete project needs while keeping tool/language-specific behavior outside the core.

## Current repository revisions

```text
rumiai-dev       1ce0bf53450d4d856c811bbce9e122c03a35464e  (pre-synchronization HEAD)
rumiai-os        688379f67ea3a2ddc55f43fbfc5020a07bb3ae0b
rumiai-tests     c58831f8eb9763ea779d88f06ee03010203805fb
rumiai-dev-PoCs  9b7c755aac5db5ae6eb90ff2a5de7772de6db9fb
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

## Working design

PoC 017 now supports the following candidate project-dependency model, which is not yet promoted to `MK.md`:

- a project dependency remains a first-class project-to-project relation rather than a fake operation or generic process action;
- the parent maps its requested goal(s) explicitly to requested goal(s) of the dependent project;
- one child `mk` instance owns the dependent project's planning/execution recursively;
- multiple parent goals mapped to the same direct dependency are aggregated into one child request with a de-duplicated child-goal set;
- parent profiles are not inherited implicitly across project boundaries;
- a dependency may select a child profile explicitly;
- `--plan` may preserve project boundaries by nesting the child `mk --plan` result instead of flattening child operations into the parent graph;
- a small invocation-chain context containing canonical project roots is sufficient to reject direct or indirect project-dependency cycles.

PoC 017 exposed one material open semantic boundary before promotion:

```text
    A
   / \
  B   C
   \ /
    D
```

Independent recursive child process trees can request `D` more than once. The first promoted contract still needs to decide whether repeated requests across sibling branches are permitted or whether one top-level request must provide shared project/goal de-duplication context.

The exact `mk.json` field names used by PoC 017 remain provisional until that semantic boundary is resolved.

## Completed

The contextual/conditional runtime-refinement model remains promoted and implemented as previously recorded.

PoC 016 established the current version-2 runtime-refinement model, now implemented in `rumiai-os` and protected by permanent lifecycle/refinement tests.

PoC 017 was added at:

```text
rumiai-dev-PoCs/pocs/017-mk-project-dependency-delegation/
```

and experimentally verifies:

- recursive `A → B → C` delegation;
- child-before-parent execution ordering;
- direct child-goal aggregation for multiple requested parent goals;
- no implicit profile inheritance;
- explicit child-profile selection;
- nested, non-executing `--plan`;
- `A → B → A` cycle rejection through propagated invocation-chain context;
- child request failure propagation.

The PoC passes locally with Node.js 22.16.0.

No `rumiai-os` product code or canonical `MK.md` contract was changed by PoC 017.

## Validation evidence

Hosted development validation for the previously completed runtime-refinement work unit remains:

```text
GitHub Actions run 35768833988

rumiai-os
    926179d3cb8808623dfe6f0bfed1e982dd0763ee

rumiai-tests
    570dcde5142c38e130295ee46912e87e7882f319

Ubuntu hosted runner:
    PASS rumiai-os/mk/lifecycle.test
    PASS rumiai-os/mk/refinement.test
    PASS 2 / FAIL 0 / SKIP 0 / ERROR 0
```

The macOS hosted runner did not reach either `mk` test because the real Node.js distribution request used by `pkg install nodejs` returned HTTP 403. Formal `rumiai-validate` task validation for that work unit remains unclosed because the disposable validation target has no managed/default Node provisioning path. Required SKIP is not PASS under `TESTING.md`.

PoC 017 evidence is experimental only and does not replace permanent product validation.

## Current state

The promoted single-project runtime-refinement contract still matches the current implementation baseline.

Project-to-project dependency execution remains unimplemented in `rumiai-os`, but PoC 017 has now reduced the candidate design to recursive `mk` delegation rather than a global flattened multi-project lifecycle graph.

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

Resolve the request-wide repeated-dependency/diamond semantic exposed by PoC 017.

Then, if the recursive delegation model remains sufficient:

1. promote the minimal project-dependency contract into `specifications/rumiai-os/MK.md` and `CURRENT-MODEL.md`;
2. implement it in `rumiai-os`;
3. add permanent multi-project tests in `rumiai-tests`;
4. run proportional development validation without altering `pkg` merely to manufacture hosted evidence.

## Blockers / open questions

- Should one top-level `mk` request permit the same dependent project to be requested independently through sibling branches, or must project+goal requests be de-duplicated across the whole request?
- macOS hosted `pkg install nodejs` currently receives HTTP 403 from the real Node.js distribution endpoint, preventing hosted macOS execution of the permanent `mk` tests;
- formal task validation still lacks a managed-Node provisioning path inside the disposable `rumiai-validate` target environment;
- should a future `requirement` resolve directly to an existing `pkg` facility/provider contract or require a distinct `mk` abstraction?
- what explicit input/output identity is minimally sufficient before incremental execution can be designed?
- where should long-running/watch behavior live relative to operation/action versus session/scheduler semantics?
