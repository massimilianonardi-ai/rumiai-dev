# RumiAI OS — `mk` development lifecycle

Status: **Current / normative**  
Updated: 2026-09-22

## 1. Role

`mk` is the technical subsystem of `m` responsible for management and orchestration of the development lifecycle of a project.

It coordinates declarative project configuration, profiles, project dependencies, lifecycle goals, operation prerequisites, development requirements, execution and development outputs.

`mk` does not replace compilers, interpreters, external build engines or `pkg`; it orchestrates external tools and technical facilities through modular boundaries.

## 2. Ownership and subsystem boundary

`mk` belongs to the general-purpose technical substrate `m`.

It MUST NOT semantically depend on the branded RumiAI layer.

`pkg` remains a distinct `m` subsystem. `mk` owns project development-lifecycle orchestration; `pkg` owns package management, provider/facility resolution and package integration.

A project may depend on another project through the `mk` project model. This project-dependency relation is distinct from:

```text
operation prerequisite
    ordering/work relation inside an operation graph

requirement
    capability/tool/runtime/environment condition needed by a project or operation

pkg dependency/facility
    package/runtime dependency contract owned by pkg
```

The terms are intentionally not interchangeable.

## 3. Runtime and configuration format

The broader `mk` lifecycle engine is implemented in **JavaScript**.

The public command remains the bootstrap-integrated:

```text
bin/sys/mk
```

and therefore uses:

```sh
#!/usr/bin/env m
```

The command entrypoint is a thin POSIX-shell launcher. The lifecycle engine itself is JavaScript and is executed with the current RumiAI-managed Node.js runtime supplied through the `nodejs` package integration. `mk` does not depend on a host Python runtime and does not automatically install its runtime as a side effect of a lifecycle request.

Project configuration is structured declarative **JSON**. It MUST NOT be shell-sourced, `eval`ed or otherwise treated as executable configuration.

The project-root configuration file is:

```text
mk.json
```

JSON was selected as the current configuration representation for deterministic structured data and potentially complex project/operation graphs. JavaScript source is implementation; JSON project configuration remains data.

## 4. Project discovery and selection

Without `--project`, `mk` starts at the current working directory and searches that directory and then each parent directory for:

```text
mk.json
```

The first match determines the project root.

With:

```text
--project <path>
```

`<path>` selects the project root explicitly and `mk` reads:

```text
<path>/mk.json
```

A valid project root must exist as a directory and contain a readable regular `mk.json`.

Project discovery does not modify the filesystem.

## 5. Core lifecycle model

Projects and profiles are first-class concepts.

The current conceptual distinction is:

```text
goal
    externally addressable requested outcome

operation
    orchestratable unit of work

prerequisite
    relation in which one operation must be satisfied before another may proceed

dependency
    relation between projects

requirement
    external capability/tool/runtime/package/environment condition

input/output
    data/resource/state consumed or produced
```

A goal selects one or more root operations. Operations form a prerequisite graph.

`mk` MUST support different levels of orchestration granularity:

```text
delegated case
    one opaque operation invokes Maven/CMake/another suitable engine

fine-grained case
    mk sees and orchestrates the detailed operation graph directly
```

The two cases use the same lifecycle model. Delegation is not a separate lifecycle architecture.

Lifecycle goal names are project data rather than a fixed global set. Names such as `build`, `test`, `run`, `clean`, `docs` or `watch` are conventions only and MUST NOT be intrinsically hard-coded as mandatory goals.

### Declarative economy and contextual resolution

`mk.json` describes project intent and the information that cannot be derived reliably from the project/runtime context. It MUST NOT require duplication of facts that are already implied by an intentionally declared project structure or another authoritative input.

For example, when a project declares a source collection rooted at a directory whose ordinary meaning is "all applicable sources in this directory/tree", the concrete file membership is resolved from the current filesystem state rather than copied into `mk.json` merely to enumerate it. Explicit include/exclude/enumeration remains appropriate when the intended set differs from the derivable default, including profile-specific subsets.

This principle applies generally:

```text
declarative intent
+ selected profile
+ current observable project/runtime state
    -> resolved model
```

The exact schema for source collections, selectors, providers/builders or other derivation mechanisms is not selected by this contract merely by establishing this rule.

Derived details may appear in a resolved plan even when they are absent from `mk.json`.

## 6. First-delivery JSON model

The first implemented `mk.json` schema has version:

```json
{
  "version": 1
}
```

The accepted top-level members are:

```text
version
environment
goals
operations
profiles
```

Unknown members are rejected so configuration mistakes are not silently ignored.

### 6.1 Names

Project-defined goal, operation and profile names use the controlled-name shape:

```text
[a-z0-9][a-z0-9._-]*[a-z0-9]
```

with one-character alphanumeric names also valid.

### 6.2 Goals

`goals` is a JSON object whose keys are goal names and whose values are arrays of root-operation names.

Example:

```json
{
  "goals": {
    "build": ["maven-build"]
  }
}
```

A goal may select more than one root operation.

### 6.3 Operations

`operations` is a JSON object whose keys are operation names.

An operation may define:

```text
prerequisites
action
```

`prerequisites` is an array of operation names. An operation may also be an aggregation node with prerequisites and no action.

The first implemented action type is:

```text
process
```

Its form is:

```json
{
  "action": {
    "type": "process",
    "command": "mvn",
    "args": ["package"],
    "cwd": ".",
    "env": {
      "NAME": "value"
    }
  }
}
```

For a process action:

- `command` is a required non-empty executable/tool name or pathname;
- `args` is optional and contains string arguments;
- `cwd` is optional; absent means project root, relative values resolve from the project root, and absolute values remain explicit caller/project data;
- `env` is optional and overlays the resolved project/profile environment;
- execution does not implicitly invoke a shell.

This action shape is an extensible action boundary, not a claim that every future operation must be a process invocation.

### 6.4 Profiles

The base project model may define:

```text
environment
goals
operations
```

`profiles` is an optional object of named overlays.

A selected profile may define:

```text
environment
goals
operations
```

Profile composition in the first delivery is intentionally simple:

- environment entries from the profile replace same-named base entries;
- goal entries from the profile replace same-named base goals and may add new goals;
- operation entries from the profile replace same-named base operation definitions and may add new operations;
- absent entries inherit the base project value;
- no implicit deletion syntax exists.

No profile is selected unless the caller supplies `--profile <profile>`.

## 7. Resolution, planning and runtime refinement

For a request, `mk` resolves conceptually:

```text
declarative project intent
+ selected profile
+ currently observable context/state
→ currently resolvable goals/operations/conditions
→ execution plan
```

Resolution is not required to produce a completely fixed graph before execution begins.

Some facts are derivable immediately, such as the current members of a declared source directory. Other decisions may depend on results that exist only after earlier operations run, such as:

```text
attempt one dependency/version
    if unusable -> select a fallback

produce an artifact
    if size < threshold -> one compression path
    otherwise           -> another compression path
```

Therefore the lifecycle model MUST support plans containing conditional alternatives whose selection may remain unresolved until the required evidence exists. Execution may refine the currently resolved plan as operation results, outputs or other permitted runtime observations become available.

This does not make project configuration executable code. Conditions, selectors and graph-producing mechanisms remain declarative inputs interpreted by trusted `mk` functionality or trusted extension boundaries.

For every portion of the plan that is currently concrete, planning MUST preserve these properties:

- missing referenced goals/operations are rejected when their references are resolved;
- prerequisite cycles are rejected in the resolved graph;
- the same concrete operation is not redundantly scheduled within one resolved execution path;
- a concrete prerequisite is satisfied before the operation that requires it.

Multiple goal operands represent one requested set. They do not establish semantic left-to-right sequencing between otherwise independent goals.

The first implementation executes a fully resolved static plan sequentially. That implementation is narrower than the general lifecycle contract above: contextual derivation, conditional branches and runtime plan refinement are not implemented yet.

Incremental fingerprints, caching, remote execution, watch/hot-update triggers, project dependency execution and declarative requirement resolution also remain unimplemented. Those capabilities may be added only through the same general model rather than language/tool-specific hard-coding.

## 8. Public command line

The first lifecycle CLI is:

```text
mk [options] [--] <goal> [<goal> ...]
mk [options] --goals
mk [options] --show-goal <goal>
```

Options:

```text
--project <path>
    select a project root explicitly

--profile <profile>
    select a named profile

--plan
    resolve and print the execution plan without executing project operations

--goals
    list available goals in lexical order

--show-goal <goal>
    resolve one goal and print its roots and operation plan as JSON
```

`--plan` requires at least one goal operand.

Plan inspection resolves everything that can be determined from declarative configuration and the currently observable context without executing project operations. Facts that are derivable now, such as current membership of a declared source collection, belong in the displayed resolved plan even when they are not enumerated in `mk.json`.

When a future decision depends on evidence that does not yet exist, plan inspection MUST preserve and display the corresponding conditional alternatives rather than pretending one branch is already selected.

The exact future rendering format for conditional plans is not selected yet. The current first implementation prints only a linear fully resolved operation list because it does not yet implement conditional planning.

`--goals` and `--show-goal` are introspection modes and do not execute project operations.

A zero-argument invocation is invalid. No built-in default goal exists in the first delivery.

Examples:

```text
mk build
mk --profile release build
mk test package
mk --plan build
mk --goals
mk --show-goal build
mk --project ../other-project --profile debug build
```

No lifecycle goal name is reserved by this interface.

## 9. Execution behavior

A process action executes with:

```text
command
arguments
resolved cwd
resolved environment
```

The environment starts from the `mk` caller/runtime environment, then applies project environment, selected-profile environment and action environment in that order.

Standard input, standard output and standard error are inherited by the executed process.

A non-zero action result, signal termination, spawn failure, invalid project model, missing runtime requirement or other lifecycle failure stops the first-delivery execution and makes the public command fail.

## 10. Output and exit status

Normal successful execution does not require `mk` to emit additional output beyond the output produced by executed actions.

`--goals` writes one goal name per line in lexical order.

`--plan` writes one operation name per line in planned execution order.

`--show-goal` writes a JSON object containing the selected goal, its root operations and its resolved operation plan.

Public exit statuses are:

```text
0  success
1  project/configuration/resolution/execution/runtime failure
2  invalid CLI invocation
```

## 11. Extension boundaries

General lifecycle orchestration SHOULD remain separate from tool-specific integration.

The architecture may introduce stable extension boundaries for responsibilities such as:

```text
external-engine adapters
reusable/native builders or operation providers
action/executor implementations
requirement/tool resolvers
selectors/triggers
```

These are extension classes, not mandatory first-delivery plugin APIs.

The general model SHOULD minimize tool-, language- and lifecycle-specific behavior in the core. Common project shapes SHOULD remain concise while advanced projects can expose finer orchestration without changing the core model.

Existing standard formats, protocols and tool interfaces SHOULD be preferred when they satisfy the required contract.

## 12. State and outputs

When `mk` introduces managed persistent state, that state MUST use the current `state-path` contract rather than reconstructing the physical state tree.

Development output is distinct from package installation. Executing a project lifecycle does not by itself publish the project as an installed package.

The first lifecycle delivery defined here introduces no persistent `mk` state.

## 13. Documentation build ownership

Documentation generation is a build/output responsibility when a project defines source documentation that must be transformed into distributable or publishable artifacts.

For the RumiAI documentation model, `mk` owns orchestration of documentation builds.

A documentation renderer/generator is not part of the `mk` core merely because `mk` orchestrates it. It remains external/selectable tooling integrated through the same general lifecycle boundary as other build tools.

## 14. Invariants

```text
MK-01  mk belongs to the m technical layer
MK-02  mk owns project development-lifecycle management and orchestration
MK-03  mk project configuration is structured declarative JSON data and is not sourced/evaled as code
MK-04  the current project configuration identity is project-root mk.json
MK-05  the mk lifecycle engine implementation language is JavaScript
MK-06  the current JavaScript execution runtime is the RumiAI-managed nodejs package integration
MK-07  projects and profiles are first-class lifecycle concepts
MK-08  lifecycle goal names are project data rather than a mandatory hard-coded global set
MK-09  goals select root operations and operations relate through prerequisites
MK-10  dependency denotes a project-to-project relation; prerequisite denotes an operation relation; requirement denotes an external need
MK-11  mk supports both delegation to suitable external lifecycle/build engines and direct fine-grained orchestration
MK-12  the first action type is a shell-free process invocation
MK-13  multiple requested goals form one requested set and do not create semantic left-to-right sequencing
MK-14  mk-managed persistent state, when introduced, resolves through state-path
MK-15  RumiAI documentation build orchestration is an mk lifecycle responsibility while rendering tooling remains externally selectable
MK-16  mk.json expresses declarative project intent and does not require duplication of details that can be derived from authoritative current project/runtime context
MK-17  explicit enumeration/selection remains available when intended membership differs from a derivable default, including profile-specific subsets
MK-18  an mk execution plan is not required to be fully fixed before execution; conditional alternatives may remain unresolved until runtime evidence exists
MK-19  plan inspection resolves currently observable facts without executing project operations and preserves future-dependent alternatives as conditional structure
```
