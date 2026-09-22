# mk tool development

Status: Active
Updated: 2026-09-22

## Goal

Continue development of `mk` as the `m` subsystem for project development-lifecycle orchestration, extending the promoted declarative lifecycle model from concrete project needs while keeping tool/language-specific behavior outside the core.

## Current repository revisions

```text
rumiai-dev       a15a5f115a2a96f48f271028cf6d8cf0e0ed1123  (pre-synchronization HEAD)
rumiai-os        78f1ebf6f11d40f2f722ae3f37875118cbda8015
rumiai-tests     82a96f008b22e3e8fcd533206e174912591000ca
rumiai-dev-PoCs  416a30fd02531dbb74a21da1765ff4fb1ebbdff2
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

The runtime-refinement validation scope remains:

```text
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
```

stored in `rumiai-tests/validation/mk-runtime-refinement.conf` and pinned to `rumiai-os` commit `926179d3cb8808623dfe6f0bfed1e982dd0763ee`.

The project-dependency validation scope is:

```text
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
rumiai-os/mk/project-dependency.test
```

stored in `rumiai-tests/validation/mk-project-dependency.conf` and pinned to `rumiai-os` commit `78f1ebf6f11d40f2f722ae3f37875118cbda8015`.

## Completed

The contextual/conditional runtime-refinement model remains promoted and implemented as previously recorded.

PoC 017 established the project-to-project dependency baseline and is preserved under:

```text
rumiai-dev-PoCs/pocs/017-mk-project-dependency-delegation/
```

The resulting model has been promoted into `specifications/rumiai-os/MK.md` and `CURRENT-MODEL.md`.

The promoted version-2 project-dependency contract now requires:

- a dependency remains a first-class project-to-project relation, distinct from operation prerequisites and process actions;
- a dependency declares its child project and explicitly maps requested parent goals to requested child goals;
- one child `mk` engine process owns the dependent project's lifecycle recursively;
- child lifecycle operations/providers/collections/conditions are not flattened into the parent graph;
- multiple requested parent goals mapped to the same direct dependency are aggregated into one de-duplicated child-goal request;
- a parent profile is not inherited implicitly across a project boundary;
- a dependency may select a child profile explicitly;
- active direct dependencies must complete successfully before parent-local lifecycle work begins;
- recursive project cycles are rejected from canonical project identity carried in a private active invocation chain;
- version-2 plans preserve active dependencies as nested child-project plans;
- the dependency relation does not imply request-wide exactly-once execution or sibling-branch de-duplication; a diamond may independently request the same downstream project more than once.

`rumiai-os` commit `9ced19f7376cc8b4697a8240dea72f436a9facf1` implements the recursive dependency model in `lib/sys/js/mk.lib.js`.

Subsequent product commits align the manuals:

```text
69fb9ea5a8db918410ce35a4e79182db6050b183
    res/sys/manual/mk

78f1ebf6f11d40f2f722ae3f37875118cbda8015
    res/sys/manual/mk.lib.js
```

The implementation:

- accepts version-2 top-level/profile `dependencies`;
- validates dependency names, path/goal/profile shape and parent-goal references;
- resolves active child requests from the selected parent model;
- resolves child roots canonically;
- delegates each active direct child request to a fresh Node process loading the same current `mk.lib.js` engine and calling `mkMain`;
- passes only an internal canonical project-chain context needed for recursive cycle detection;
- reconstructs the caller environment for child delegation and prevents the private chain from leaking into normal project actions;
- supports nested planning for version-2 children and wraps a version-1 child line plan when reached from a version-2 parent;
- executes active dependencies before the parent project's local version-2 lifecycle.

The public shell launcher `bin/sys/mk` was not changed.

`rumiai-tests` contains the permanent executable:

```text
tests/rumiai-os/mk/project-dependency.test
```

protecting MK-28 through MK-35 through the real public `bin/sys/mk` path. It covers recursive A→B→C delegation, child-before-parent behavior, direct child-goal aggregation, implicit/explicit profile behavior, nested non-executing plan output, A→B→A cycle rejection, child failure propagation and deliberate repeated D execution in a diamond A→B/C→D.

The test was initially created with non-executable mode by the repository contents API; the first hosted run therefore classified it as test infrastructure ERROR before execution. Commit `f010b0337e95c4877c91b46a764c386a0577b20b` corrected only its Git mode to `100755`.

The temporary hosted development workflow was removed after evidence collection.

## Validation evidence

Project-dependency development validation used the real public `mk` command, the unchanged permanent tests and the real RumiAI-managed Node.js package provisioning path.

GitHub Actions run:

```text
35774948617
```

Exact revisions exercised:

```text
rumiai-os
    78f1ebf6f11d40f2f722ae3f37875118cbda8015

rumiai-tests
    f010b0337e95c4877c91b46a764c386a0577b20b
```

GitHub-hosted Ubuntu auxiliary runner:

```text
PASS rumiai-os/mk/lifecycle.test
PASS rumiai-os/mk/refinement.test
PASS rumiai-os/mk/project-dependency.test
PASS 3 / FAIL 0 / SKIP 0 / ERROR 0
```

The macOS hosted job did not reach the tests. Real `pkg install nodejs` again failed because the Node.js distribution request returned:

```text
curl: (56) The requested URL returned error: 403
```

This is provisioning/upstream evidence and is not a failure of the project-dependency behavior.

The earlier run `35774808861` is diagnostic only: managed Node provisioning succeeded on both jobs, lifecycle/refinement passed, but the new test was classified ERROR immediately because its Git executable bit had not yet been set. It is not product-failure evidence.

Formal `rumiai-validate` validation remains unclosed. The disposable committed target clone has no managed/default Node.js provisioning mechanism, and required SKIP is not PASS under `TESTING.md`. This work unit did not change `pkg` or validation infrastructure merely to manufacture formal evidence.

## Current state

The promoted single-project runtime-refinement model and the promoted project-to-project dependency model are implemented in the current product baseline and covered by permanent tests.

The current project-dependency architecture is deliberately recursive rather than a flattened global multi-project operation graph:

```text
parent requested goals
→ active dependency mapping
→ child project + child goals (+ optional explicit child profile)
→ fresh child mk engine process
→ recursive child lifecycle
→ child success
→ parent local lifecycle
```

The current baseline still deliberately excludes:

```text
incremental fingerprints/cache
parallel scheduling
remote execution
declarative requirement resolution
watch/hot-update session semantics
public generic provider/plugin registration
request-wide exactly-once/de-duplication semantics
```

## Next action

Use declarative requirement resolution as the next `mk` stress case only after retrieving the current `pkg` facility/provider contract and determining whether `mk` should consume that existing model directly or needs a distinct boundary.

Do not conflate a project dependency with an external requirement, and do not reopen the completed recursive project-dependency model merely to add future cache/session semantics.

## Blockers / open questions

- formal task validation still lacks a managed-Node provisioning path inside the disposable `rumiai-validate` target environment;
- macOS hosted `pkg install nodejs` still intermittently/consistently receives HTTP 403 from the real Node.js distribution endpoint and may prevent hosted macOS execution;
- should a future `requirement` resolve directly to the existing `pkg` facility/provider contract or require a distinct `mk` abstraction?
- what explicit input/output identity is minimally sufficient before incremental execution can be designed?
- where should long-running/watch behavior live relative to operation/action versus session/scheduler semantics?
