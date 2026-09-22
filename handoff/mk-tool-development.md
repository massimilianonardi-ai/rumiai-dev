# mk tool development

Status: Active
Updated: 2026-09-22

## Goal

Continue development of `mk` as the `m` subsystem for project development-lifecycle orchestration, extending the promoted declarative lifecycle model from concrete project needs while keeping package/provider semantics in `pkg` and tool/language-specific behavior outside the core.

## Current repository revisions

```text
rumiai-dev       00a51d6811e7a68f17ee656c546448b20060937d  (pre-synchronization HEAD)
rumiai-os        b3c39830b66e85f4ec63def3f3bcd91af853cbe7
rumiai-tests     80faa275df8c97be088c79419a70d54c7d8131c7
rumiai-dev-PoCs  1821be1904c432b969f395b28dc193ac8ced01b1
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
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
handoff/README.md
```

Additional subsystem specifications are retrieved only when a future `mk` extension crosses their boundary.

## Fixed validation scopes

Runtime refinement:

```text
validation/mk-runtime-refinement.conf
rumiai-os-commit 926179d3cb8808623dfe6f0bfed1e982dd0763ee
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
```

Project dependencies:

```text
validation/mk-project-dependency.conf
rumiai-os-commit 78f1ebf6f11d40f2f722ae3f37875118cbda8015
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
rumiai-os/mk/project-dependency.test
```

Facility requirements:

```text
validation/mk-facility-requirement.conf
rumiai-os-commit b3c39830b66e85f4ec63def3f3bcd91af853cbe7
rumiai-os/pkg/dependency.test
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
rumiai-os/mk/project-dependency.test
rumiai-os/mk/requirement.test
```

## Completed model

The following version-2 capabilities are promoted, implemented and protected by permanent tests:

- contextual file collections;
- trusted operation providers;
- declarative conditions and observable result/output/state operands;
- named declared outputs and runtime refinement;
- recursive project-to-project dependency delegation;
- named external facility requirements resolved through the existing `pkg` facility/provider model.

Project `dependency`, operation `prerequisite` and external `requirement` remain distinct concepts.

## Facility requirement work unit

PoC 018 is preserved under:

```text
rumiai-dev-PoCs/pocs/018-mk-facility-requirements/
```

It established that `mk` does not need a second provider/dependency resolver.

The promoted baseline is:

```text
mk named requirement
    facility identity + pkg compatibility constraints

reachable operation/provider
    -> requirement query

pkg
    -> configured system facility default
    -> installed provider resolution
    -> existing compatibility validation

satisfied
    -> consumer may become ready

unsatisfied
    -> plan remains inspectable
    -> consumer remains blocked
    -> requirement is queried again on later refinement passes
```

A project is not a package consumer. It therefore does not receive a synthetic package-consumer binding. Project requirements use the system facility default, matching the existing non-package-consumer/global facility selection model.

Requirement resolution is read-only. It does not:

- install providers;
- choose among installed providers implicitly;
- create or modify facility defaults;
- create package-consumer bindings;
- introduce another facility command/environment projection layer.

Facility commands/environment remain owned by normal `m`/`pkg` bootstrap semantics.

## Canonical promotion

The requirement model was promoted in `rumiai-dev`:

```text
9fddcde54ea39dc8882752765c7ee6eba6397a54
    specifications/rumiai-os/MK.md

9a6dd735755ec715e37b195c3936a1df93fb64c3
    specifications/rumiai-os/PACKAGE-MODEL.md

197fca75b9fd52ae4e6e464bdb8ceaf3fe332ac6
    specifications/rumiai-os/CURRENT-MODEL.md
```

The promoted `mk` invariants are MK-36 through MK-43. The package query is protected by PKG-75/PKG-76 and the current-model summary by CURRENT-45 through CURRENT-48.

## Product implementation

`pkg` now exposes:

```text
pkg requirement resolve <facility> <constraint>...
```

The query resolves the configured system facility default through the normal package-class/osarch semantics, validates that the selected installed concrete declares the requested facility at a compatibility satisfying every supplied constraint, and prints the concrete provider identity.

Implementation surfaces:

```text
lib/sys/sh/pkg/facility/pkg-dependency.lib.sh
    public pkg_dependency_default_resolve

lib/sys/sh/pkg/pkg-requirement.lib.sh
    public pkg_requirement subcommand entrypoint

bin/sys/pkg
    requirement dispatch
```

The new public subcommand library explicitly loads both the facility contract and dependency resolver. The first hosted development run exposed that the historical dependency library relied on facility helpers already having been loaded by its caller; commit `2b8696ad2cbba822d59df07551fd6b0b1da811ee` fixed this new public-boundary load-order dependency without changing resolution policy.

`mk` version 2 now accepts:

```json
{
  "requirements": {
    "jdk": {
      "type": "facility",
      "facility": "java",
      "constraints": [">=21", "<26"]
    }
  }
}
```

Operations and trusted providers may reference named requirements through a `requirements` array. Profiles may replace/add named requirement definitions.

The JavaScript engine:

- validates requirement declarations and references without reimplementing the package compatibility parser;
- resolves only requirements reachable from the requested lifecycle;
- invokes the real public package boundary through a fresh `m pkg requirement resolve ...` query;
- resolves each reachable requirement once per refinement pass and queries it again on later passes;
- exposes `satisfied`/`unsatisfied` state and selected provider concrete in structured plans;
- keeps conditional operations conditional before requirement state can make them executable;
- blocks ordinary operations and trusted-provider derived work while requirements are unsatisfied;
- does not retroactively invalidate already-completed operations if external provider state later changes;
- reports unsatisfied requirements only when they are the actual blocker preventing further progress;
- preserves pending collection/refinement semantics for providers before treating a provider requirement as the terminal blocker.

The public `bin/sys/mk` launcher was not changed.

The final product HEAD for this work unit is:

```text
b3c39830b66e85f4ec63def3f3bcd91af853cbe7
```

The last commit after the behaviorally tested revision is documentation-only, aligning the dependency list in `pkg-requirement.lib.sh`'s manual.

## Permanent tests

`rumiai-tests/tests/rumiai-os/pkg/dependency.test` now also protects the public requirement query, including:

- successful resolution through a system facility default;
- package-default late binding;
- compatibility mismatch;
- invalid constraint status;
- independence from package-consumer bindings;
- absence of implicit fallback when no facility default exists.

New permanent executable:

```text
tests/rumiai-os/mk/requirement.test
```

protects MK-36 through MK-43 through the real public `bin/sys/mk` and `pkg` paths. It covers:

- unreachable requirements omitted from the plan;
- reachable unsatisfied requirement plan state;
- operation blocking without executing the consumer;
- prerequisite-driven provider-default change followed by successful re-resolution;
- satisfied plan state with selected provider concrete;
- profile replacement of a requirement;
- requirement gating on a trusted `map-process` provider;
- final unsatisfied requirement failure before the consuming action runs.

The test file is committed executable (`100755`).

## Development validation evidence

The first diagnostic hosted run:

```text
35778910973
```

failed in the new package-query coverage before Node provisioning. It exposed the missing explicit facility-library load in the new public `pkg-requirement.lib.sh` boundary. This was a real implementation integration defect and was corrected forward.

The successful hosted development run is:

```text
35779022415
```

Exact behavior revisions exercised:

```text
rumiai-os
    2b8696ad2cbba822d59df07551fd6b0b1da811ee

rumiai-tests
    ab1fcf2c0b388f902c821ddf70809f4d651fb375
```

GitHub-hosted Ubuntu auxiliary runner:

```text
PASS rumiai-os/pkg/dependency.test
PASS rumiai-os/mk/lifecycle.test
PASS rumiai-os/mk/refinement.test
PASS rumiai-os/mk/project-dependency.test
PASS rumiai-os/mk/requirement.test
PASS 5 / FAIL 0 / SKIP 0 / ERROR 0
```

GitHub-hosted macOS runner:

```text
PASS rumiai-os/pkg/dependency.test
PASS rumiai-os/mk/lifecycle.test
PASS rumiai-os/mk/refinement.test
PASS rumiai-os/mk/project-dependency.test
PASS rumiai-os/mk/requirement.test
PASS 5 / FAIL 0 / SKIP 0 / ERROR 0
```

In this run the real managed-Node provisioning path also succeeded on macOS, so the previous intermittent Node.js distribution HTTP-403 blocker did not prevent macOS execution. This does not establish that the upstream 403 condition is permanently resolved.

The temporary hosted-development workflow was removed after evidence collection.

Formal `rumiai-validate` validation remains unclosed. The current disposable validation target model does not provision a managed/default Node runtime into the fresh target clone, and required SKIP is not PASS under `TESTING.md`. This work unit did not change validation/package provisioning merely to manufacture formal evidence.

## Current state

The current version-2 lifecycle model is:

```text
declarative project intent
+ selected profile
+ project dependencies
+ currently observable context/state
+ reachable external facility requirements
    -> partially resolved structured plan
    -> recursive child-project lifecycle
    -> execute ready local work
    -> observe result/output/state/external provider state
    -> refine
    -> continue
```

The current baseline deliberately excludes:

```text
incremental fingerprints/cache
parallel scheduling
remote execution
watch/hot-update session semantics
public generic provider/plugin registration
request-wide exactly-once/de-duplication semantics
automatic requirement/provider installation
project-specific persistent provider bindings
requirement types outside pkg facilities
```

## Working design — incremental fingerprints

PoC 019 is active under:

```text
rumiai-dev-PoCs/pocs/019-mk-incremental-fingerprints/
```

The experiment has fixed the following candidate direction but it is not yet promoted contract:

- incremental behavior is explicit per operation through an `incremental` object;
- `incremental.inputs` is a named map whose first candidate sources are `path`, `collection` and another operation's named `output`;
- existing named `outputs` remain the output identity surface; an incremental operation must have declared outputs;
- an output input creates a data dependency and therefore must not require duplicate `prerequisites` declaration;
- freshness is SHA-256/content based and excludes mtime;
- a reusable success requires both the same effective fingerprint and current declared outputs matching the recorded successful output snapshots;
- a verified hit is represented as `up-to-date` and must satisfy prerequisites, collection `after` barriers and downstream output/data evidence in the current request;
- failed executions never create reusable freshness state;
- the candidate persistent metadata location is the user-scoped `state-path user sys mk cache` area, isolated by canonical-project-root hash and operation identity;
- cache state is non-authoritative: missing/corrupt/unsupported state is a miss, never a false success;
- `--plan` may read freshness state but must not write it;
- project dependencies remain recursively delegated; the child owns its own incremental decisions;
- the first baseline is freshness metadata only, not artifact storage/restoration, shared cache, watch/session behavior or request-wide dependency de-duplication.

The candidate fingerprint includes operation/action definition, effective execution environment, observable executable identity, resolved requirement-provider concrete identities and resolved named input snapshots.

Before promotion, reconcile the exact meaning of cached success with current result/output observation semantics. In particular, a cache hit must provide verified current-request success/output evidence without claiming that the action executed in the current request.

## Next action

Use **incremental execution / input-output identity and fingerprints** as the next concrete `mk` stress case.

Start from concrete project scenarios and determine the smallest identity/freshness contract needed before introducing cache state. Keep incremental state distinct from requirement/provider resolution and from the already-fixed project dependency semantics.

Do not introduce watch/session behavior merely to implement incremental one-shot execution; long-running ownership remains a later separate stress case.

## Open questions

- what explicit input/output identity is minimally sufficient for deterministic incremental execution?
- what state must be persisted through the canonical `state-path` boundary versus remaining derivable from current project files?
- how should project dependency requests participate in later incremental freshness without adding request-wide exactly-once semantics implicitly?
- where should long-running/watch behavior live relative to operation/action versus session/scheduler semantics?
- formal validation still lacks managed-Node provisioning inside the disposable `rumiai-validate` target.
