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

## 6. Project JSON model

The current parser supports project configuration versions:

```text
1
2
```

Version 1 is the original static lifecycle model and remains supported without changing its existing semantics.

Version 2 extends the same lifecycle model with project dependencies, declarative external requirements, contextual collections, trusted operation providers, declarative conditions, named outputs, incremental freshness and runtime plan refinement.

Unknown members are rejected so configuration mistakes are not silently ignored.

### 6.1 Names

Project-defined goal, operation, provider, collection, dependency, requirement and profile names use the controlled-name shape:

```text
[a-z0-9][a-z0-9._-]*[a-z0-9]
```

with one-character alphanumeric names also valid.

Derived internal operation identities are generated by trusted `mk` code and MUST remain valid controlled names even when collection items contain external/user pathname components.

### 6.2 Version 1

Version-1 top-level members are:

```text
version
environment
goals
operations
profiles
```

A goal maps to an array of root-operation names.

An operation may define:

```text
prerequisites
action
```

An operation with prerequisites and no action is an aggregation node.

The first implemented action type is the shell-free:

```text
process
```

with the existing shape:

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
- `cwd` is optional; absent means project root, relative values resolve from the project root, and absolute values remain explicit project data;
- `env` is optional and overlays the resolved project/profile environment;
- execution does not implicitly invoke a shell.

### 6.3 Version 2 additions

Version 2 accepts these top-level members:

```text
version
environment
goals
operations
collections
providers
dependencies
requirements
profiles
```

A version-2 goal may select root operations or providers.

A version-2 operation retains `prerequisites` and `action` and may additionally define:

```text
requirements
when
outputs
failure
incremental
```

`requirements` is an optional array of named requirement definitions. A selected operation is not ready until all of its current requirements are satisfied.

`when` is a declarative guard. A guarded operation is selected when the condition resolves true, skipped when it resolves false, and remains conditional while required evidence is unavailable.

`outputs` maps controlled output names to declared pathnames:

```json
{
  "outputs": {
    "artifact": {
      "path": "dist/app.bin"
    }
  }
}
```

A relative output pathname resolves from the project root. Output observation is current-request evidence tied to the producing operation: a stale pathname already present before this request is not by itself evidence that the producer created an output in the current request.

`failure` is:

```text
stop
continue
```

and defaults to `stop`. `continue` records a non-zero/signal/spawn result so later conditions may observe that result and lifecycle refinement may continue. Such a failed operation is terminal evidence but does not satisfy an ordinary success prerequisite.

### 6.4 File collections

The first collection type is:

```text
files
```

Its current shape is:

```json
{
  "type": "files",
  "root": "src",
  "suffixes": [".c", ".cpp"],
  "include": ["main.cpp"],
  "exclude": ["old.cpp"],
  "after": ["generate"]
}
```

`root` is required and is resolved from the project root unless absolute project data explicitly says otherwise.

Without `include`, membership is the current recursive set of regular files below the collection root, optionally filtered by `suffixes` and `exclude`. This is the normal form when the declared directory/tree itself defines project intent; configuration does not enumerate the current inventory merely to mirror the filesystem.

`include` supplies an explicit root-relative selection when intended membership differs from default discovery. `exclude` removes exact selected root-relative members. A profile may therefore replace a discovered collection with an explicit subset.

A missing root whose `after` barrier is already satisfied resolves to an empty collection.

`after` is an optional array of operations/providers whose **successful completion in the current request** is required before the collection becomes authoritative. Until then the collection remains pending and `mk` MUST NOT scan an old output tree as if it had been generated by the current request. A skipped or failed dependency does not satisfy an `after` barrier.

### 6.5 Trusted operation providers

Version 2 introduces `providers` as the trusted derivation boundary between declarative project intent and concrete operations.

Project configuration selects a supported provider `type` and supplies declarative provider data. It MUST NOT name, embed or load arbitrary executable JavaScript/resolver code from `mk.json`.

The first provider type is:

```text
map-process
```

A version-2 provider may declare an optional `requirements` array. A provider cannot execute derived work until its current requirements are satisfied.

Its current shape is:

```json
{
  "type": "map-process",
  "collection": "sources",
  "prerequisites": ["prepare"],
  "action": {
    "type": "process",
    "command": "tool",
    "args": ["${item}"]
  }
}
```

For each resolved collection item, the provider derives one ordinary process operation from the action template. `${item}` substitution is supported in the process command, arguments, cwd and environment values. No other configuration expression or executable interpolation is evaluated.

A provider acts as an aggregate lifecycle node. It is satisfied only when its collection has resolved, all provider prerequisites are satisfied and all derived item operations are satisfied. Provider prerequisites remain real even when the resolved collection is empty.

The current provider set is an internal trusted registry, not yet a public plugin-registration API.

### 6.6 Conditions and observable operands

Version-2 `when` conditions currently support:

```text
eq
ne
lt
lte
gt
gte
truthy
not
```

Operands may be JSON scalar literals or one of these declarative observable sources:

```json
{"result":{"operation":"attempt","field":"status"}}
{"output":{"operation":"build","name":"artifact","property":"size"}}
{"state":{"path":"marker","property":"exists"}}
```

Result fields are:

```text
status
ok
signal
error
```

Output/state properties are:

```text
exists
size
```

A result operand becomes known only after the referenced operation has a terminal execution result.

An output operand is tied to the current-request result of its declared producer. After producer success the declared pathname may be observed. After producer failure or skip, `exists` resolves false while `size` remains unavailable. A pre-existing stale pathname therefore cannot make a failed/skipped producer appear to have produced the output.

A state operand observes the current project filesystem when the condition is evaluated.

A result/output reference creates an **observation dependency**, distinct from an ordinary success prerequisite. The guarded operation waits for the referenced evidence to become available, but may intentionally react to failure recorded through `failure: "continue"`.

### 6.7 Profiles

Version-1 profiles may define:

```text
environment
goals
operations
```

Version-2 profiles may additionally define:

```text
collections
providers
dependencies
requirements
```

Profile composition remains replacement-by-name:

- profile environment entries replace same-named base entries;
- goal/operation/collection/provider/dependency/requirement entries replace same-named base definitions and may add new entries;
- absent entries inherit the base project value;
- no implicit deletion syntax exists.

No profile is selected unless the caller supplies `--profile <profile>`.

### 6.8 Project dependencies

Version 2 introduces `dependencies` as first-class project-to-project lifecycle relations.

Each dependency is named and currently has this declarative shape:

```json
{
  "project": "../core",
  "goals": {
    "build": ["compile"],
    "check": ["verify"]
  },
  "profile": "release"
}
```

`project` is required. A relative pathname resolves from the declaring project root; an absolute pathname remains explicit project data. The target must resolve to a project root containing `mk.json`.

`goals` explicitly maps requested goals of the parent project to requested goals of the dependent project. An unmapped parent goal does not activate that dependency. When one request contains multiple parent goals that map to the same direct dependency, the mapped child goals are de-duplicated and delegated as one child request.

`profile` is optional and selects a profile explicitly in the child request. The parent project's selected profile is **not** inherited implicitly by a dependent project.

An active dependency is delegated to another `mk` engine process rooted at the dependent project. The child owns its complete lifecycle model, including its own dependencies, operations, providers, collections, conditions and profiles. The parent does not import or flatten the child's internal operation graph.

All active direct project dependencies must complete successfully before the parent executes local lifecycle operations for the requested goals. A child failure fails the parent request; project dependencies do not acquire operation-level `failure: "continue"` semantics.

Recursive delegation carries only the canonical project roots of the active dependency chain as private invocation context. Re-entering a project already in that chain is a project-dependency cycle and is rejected.

Sibling project dependencies have no semantic ordering merely because of declaration or name ordering. The current executor may visit them sequentially.

The baseline intentionally provides no request-wide de-duplication across independent sibling branches. In a diamond such as `A -> B/C -> D`, `B` and `C` may independently request `D`. Exactly-once/session/cache behavior is not implied by the project-dependency relation and remains a separate future concern.

Version-2 plan inspection recursively plans active dependencies without executing their lifecycle work and preserves each child request/plan as nested project structure rather than flattening child operations into the parent plan.

### 6.9 External requirements

Version 2 introduces named `requirements` as declarative external conditions consumed by lifecycle nodes. A requirement is distinct from an operation prerequisite and from a project dependency.

The first requirement type is:

```text
facility
```

with this shape:

```json
{
  "type": "facility",
  "facility": "java",
  "constraints": [">=21", "<26"]
}
```

`facility` is a provider-independent facility identity owned by `pkg`. `constraints` is a non-empty array using the existing package facility-compatibility constraint language.

Operations and trusted providers may reference named requirements through their `requirements` arrays.

Only requirements referenced by currently reachable lifecycle nodes are resolved. Unreachable declarations do not trigger package/provider queries.

Facility requirements are resolved by consuming the package subsystem's existing provider/facility contract. `mk` MUST NOT duplicate compatibility parsing, provider selection, package installation policy or facility conformance logic.

A project is not a package consumer and does not acquire a synthetic package-consumer identity. The first baseline resolves a facility requirement against the configured **system facility default** using normal `pkg` package-class/osarch semantics.

Requirement resolution is read-only. It MUST NOT install packages, create/change provider defaults, create package-consumer bindings or silently select among installed providers.

The package query surface is:

```text
pkg requirement resolve <facility> <constraint>...
```

On success it prints the selected concrete provider identity. Status 1 means the requirement is not currently satisfiable; status 2 means invalid invocation/syntax. The query performs no provider/facility mutation.

A reachable requirement has plan state:

```text
satisfied
unsatisfied
```

and a satisfied facility requirement records the selected provider concrete.

An unsatisfied requirement blocks the operation/provider that references it but does not make plan inspection execute or mutate anything. During execution, requirements are re-resolved during normal runtime refinement. This allows an earlier explicit prerequisite to change relevant external state before a later lifecycle node becomes ready.

If no executable lifecycle work remains and a required reachable requirement is still unsatisfied, the lifecycle request fails before that consuming action executes.

Facility requirements are gates, not a second runtime projection layer. The current `m` bootstrap continues to own globally published facility commands/environment from system facility defaults. Already-running processes are not retroactively mutated by later provider-configuration changes.

### 6.10 Incremental operation freshness

Version 2 supports explicit opt-in incremental freshness for ordinary process-action operations.

The declarative shape is:

```json
{
  "incremental": {
    "inputs": {
      "sources": {"collection": "sources"},
      "config": {"path": "build.conf"},
      "generated": {"output": {"operation": "generate", "name": "artifact"}}
    }
  }
}
```

`incremental.inputs` is a named map. The first supported input source forms are:

```json
{"path": "relative/or/absolute/path"}
{"collection": "collection-name"}
{"output": {"operation": "producer", "name": "output-name"}}
```

An incremental operation MUST have a process action and at least one declared named output. The input map may be empty for an operation whose complete varying identity is otherwise represented by its effective operation/action/environment/requirements.

Relative path inputs resolve from the project root. Absolute path inputs remain explicit project data.

A collection input fingerprints the currently resolved regular-file membership of that collection and each member's supported content identity. Existing collection `after` semantics apply normally.

An output input consumes a named output of another operation and creates a **data dependency** on that producer. The same relation does not need to be duplicated as an ordinary `prerequisites` entry merely to make the producer reachable.

The first incremental baseline is content based. For supported regular files and directories, identity includes logical pathname identity, type, portable mode bits and content. Regular-file content uses SHA-256. Directory identity recursively contains a lexical representation of supported contained directories/files and their corresponding mode/content identity. File modification time is not part of the freshness identity.

The effective operation fingerprint additionally includes:

- the effective operation definition;
- the complete effective environment passed to its process action;
- the resolved executable identity when that executable can be fingerprinted as a supported regular file;
- the resolved concrete provider identity of every referenced satisfied facility requirement;
- every named input's resolved content identity.

All fingerprint serialization is deterministic before SHA-256 is applied.

The first baseline is conservative for unsupported identity. If a required incremental input, declared output or executable identity cannot be represented safely by the supported fingerprint model, that operation is not reusable from persistent freshness state for that request. This produces a cache miss/execution rather than a false success.

A prior successful record is reusable only when:

```text
current effective fingerprint == recorded successful fingerprint
and
every current declared output exists in a supported fingerprintable form
and
every current output fingerprint == recorded successful output fingerprint
```

A reusable operation has plan/runtime state:

```text
up-to-date
```

`up-to-date` is verified current-request success-equivalent evidence for:

- ordinary prerequisite satisfaction;
- collection `after` barriers;
- named output observation;
- downstream incremental output inputs.

It does **not** synthesize an execution result. Existing `result.status`, `result.ok`, `result.signal` and `result.error` operands retain their actual current-request execution-result meaning. If a reachable condition requires one of those result fields from an otherwise up-to-date operation, that producer MUST execute in the current request rather than reuse the freshness hit.

A successful execution refreshes persistent freshness metadata only after the action succeeds and every declared output is present and fingerprintable. Failed execution never creates or refreshes reusable freshness state. If the action succeeds but its declared outputs are absent or unsupported for fingerprinting, the existing operation-success semantics remain unchanged but no reusable record is written.

Incremental correctness depends on the effective fingerprint representing every mutable influence on the action. A cacheable action MUST NOT rely on undeclared mutable external state that is absent from its declared inputs, effective environment, executable identity and requirements.

The first baseline applies to ordinary configured operations. It does not establish provider-level incremental templates for derived `map-process` members.

Persistent freshness metadata is non-authoritative and regenerable. It is rooted through:

```text
state-path user sys mk cache
```

and private `mk` cache layout below that semantic cache area isolates project records by a SHA-256 key derived from the canonical project root and then by operation identity. A copied or moved checkout therefore starts as a cache miss in the first baseline.

Missing, unreadable, corrupt or unsupported cache records are cache misses. They do not make lifecycle execution fail and MUST NOT produce a false `up-to-date` result.

`--plan` may inspect existing freshness state to expose `up-to-date`, but MUST NOT create or refresh persistent freshness metadata.

The first baseline stores freshness metadata only. It does not store, restore or distribute artifact bytes and does not establish a local/remote/shared artifact-cache protocol.

Project-to-project dependency delegation remains recursive. A parent continues to invoke the child `mk` request; the child independently decides which of its own operations are up-to-date. Incremental freshness does not add request-wide exactly-once or sibling-branch de-duplication semantics.

## 7. Resolution, planning and runtime refinement

For a request, `mk` resolves conceptually:

```text
declarative project intent
+ selected profile
+ currently observable context/state
→ currently resolvable lifecycle structure
→ execution plan
```

Resolution is not required to produce a completely fixed graph before execution begins.

Version 2 implements the iterative model:

```text
resolve reachable context
→ establish verified up-to-date work where possible
→ execute one ready operation
→ observe result/output/state changes
→ refresh successful incremental metadata when applicable
→ resolve/refine reachable context again
→ continue
```

Only dynamic collections/providers/requirements reachable from the requested goals are resolved or scanned. Model/schema/reference validation still applies normally; reachability does not make invalid declared structure acceptable.

Immediate context-derived facts, such as current membership of a declared source directory, are resolved during plan inspection. Future-dependent facts remain explicit:

- a collection behind an unsatisfied `after` barrier remains pending;
- a provider depending on a pending collection remains pending;
- a guarded operation whose operand evidence does not yet exist remains conditional;
- a reachable external requirement that cannot currently be satisfied remains unsatisfied and blocks only its consumer nodes.

When execution produces new evidence, the next resolution pass may add derived operations or select/skip conditional alternatives.

Before local version-2 lifecycle execution begins, active project dependencies for the requested goal set are resolved from the selected parent model and delegated recursively. Plan inspection performs the same project-request resolution but asks each child for a plan instead of executing it.

For every currently concrete execution path:

- missing referenced lifecycle nodes are rejected;
- dependency cycles encountered through operations/providers/collections are rejected;
- the same concrete operation is not redundantly scheduled within one path;
- ordinary prerequisites must be satisfied before their consumer;
- provider prerequisites and collection barriers retain their declared semantics even for empty/skipped branches.

Version 1 retains its static fully resolved prerequisite plan and sequential execution behavior.

Artifact storage/restoration, shared/remote caching, provider-level incremental templates, parallel scheduling, remote execution and watch/hot-update triggers remain outside the implemented baseline.

## 8. Public command line

The lifecycle CLI remains:

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
    list available goals in lexical byte order

--show-goal <goal>
    resolve one goal and print its roots and plan as JSON
```

`--plan` requires at least one goal operand.

Plan inspection resolves everything that can be determined from declarative configuration and currently observable context without executing project operations.

Version 1 preserves its line-oriented operation plan output.

Version 2 writes a structured JSON plan containing the currently relevant:

```text
version
goals
dependencies
requirements
collections
providers
operations
```

Each active dependency entry identifies the dependency name, canonical child project root, requested child goals, optional explicit child profile and the nested child plan. Reachable requirements identify their type, facility/constraints, current satisfaction state and selected concrete provider when satisfied. Resolved collections expose current items; pending collections expose their blocking `waitingFor` nodes. Providers expose their current state and derived operation identities. Operations expose their current state and, when applicable, observation/condition/derivation information.

Version-2 operation states include:

```text
ready
blocked
conditional
skipped
up-to-date
completed
failed
```

Provider states are:

```text
pending
resolved
completed
```

Collection states are:

```text
pending
resolved
```

`--show-goal` preserves the version-1 `goal`/`roots`/`operations` form for version 1. For version 2 it writes `goal`, `roots` and a structured `plan`.

`--goals` and `--show-goal` do not execute project operations.

A zero-argument invocation is invalid. No built-in default goal exists.

Multiple goal operands form one requested set. They do not establish semantic left-to-right sequencing between otherwise independent goals.

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

Version 1 remains fail-fast: a non-zero action result, signal termination, spawn failure, invalid model, missing runtime requirement or other lifecycle failure stops execution.

Version 2 also defaults to fail-fast. Only an operation explicitly declaring `failure: "continue"` converts its execution failure into observable terminal result evidence and allows refinement to continue. That continued failure still does not satisfy an ordinary prerequisite.

For version 2, active project dependencies are delegated and must complete successfully before local operations execute. Dependency execution uses a fresh `mk` engine process for each active direct dependency request. Parent profile selection is not propagated unless the dependency explicitly selects a child profile.

Reachable facility requirements are queried through the public `pkg requirement resolve` boundary during each refinement pass. Satisfied requirements permit their consumer nodes to become ready; unsatisfied requirements keep those nodes blocked. `mk` does not auto-install or mutate provider-selection configuration.

For an eligible incremental operation whose guard/prerequisites/requirements and data dependencies are currently satisfiable, `mk` compares the current effective fingerprint and current declared outputs with the stored successful freshness record. A verified match establishes `up-to-date` without running the process action. A cache miss leaves the operation ready for ordinary execution.

When actual execution-result evidence is required by a reachable condition, an otherwise matching freshness record is not enough and the producer executes.

The current executor is sequential. This is an implementation property rather than a semantic ordering rule for otherwise independent operations.

## 10. Output and exit status

Normal successful execution does not require `mk` to emit additional output beyond executed-action output.

`--goals` writes one goal name per line in lexical byte order.

Version-1 `--plan` writes one operation name per line in planned execution order.

Version-2 `--plan` writes the structured JSON plan defined in section 8.

`--show-goal` writes the version-appropriate JSON form defined in section 8.

Public exit statuses remain:

```text
0  success
1  project/configuration/resolution/execution/runtime failure
2  invalid CLI invocation
```

## 11. Extension boundaries

General lifecycle orchestration remains separate from tool-specific integration.

The current trusted provider boundary demonstrates graph derivation without hard-coding a language/build tool in the core: `map-process` maps collection members to ordinary process operations.

Future provider/builder/adapter types may be added when concrete lifecycle requirements justify them, but they MUST preserve the declarative configuration boundary. `mk.json` selects trusted runtime capabilities; it is not an arbitrary executable module-loading surface.

Other stable extension responsibilities may include:

```text
external-engine adapters
native/tool-aware builders or providers
action/executor implementations
requirement/tool resolvers
selectors/triggers
```

No public generic plugin-registration API is established merely by the current internal provider registry.

Existing standard formats, protocols and tool interfaces SHOULD be preferred when they satisfy the required contract.

## 12. State and outputs

Managed persistent `mk` state MUST use the current `state-path` contract rather than reconstructing the physical state tree.

Version-2 incremental freshness uses user-scoped technical cache state resolved from:

```text
state-path user sys mk cache
```

This state is non-authoritative and regenerable. Private project/operation record layout below that cache area is an `mk` implementation detail and does not extend the public state-path grammar.

Development output is distinct from package installation. Executing a project lifecycle does not by itself publish the project as an installed package.

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
MK-20  version 1 preserves the original static lifecycle model while version 2 adds contextual collections, trusted providers, conditions, outputs and runtime refinement
MK-21  a version-2 files collection derives current regular-file membership from its declared root unless explicit selection changes that intent
MK-22  a collection after barrier is satisfied only by successful current-request completion of every named operation/provider
MK-23  mk.json may select trusted provider types and declarative provider data but must not name/embed arbitrary executable resolver modules
MK-24  result/output condition references create observation dependencies distinct from ordinary success prerequisites
MK-25  declared output evidence is bound to the producing operation's current-request result; stale pathnames alone are not producer output evidence
MK-26  failure continue exposes terminal failure evidence for refinement but does not satisfy an ordinary prerequisite
MK-27  version-2 plan inspection uses structured output that preserves resolved, pending and conditional lifecycle structure
MK-28  version-2 project dependencies map requested parent goals explicitly to child-project goals and are delegated recursively to another mk engine process
MK-29  child project lifecycle internals remain owned by the child mk instance and are not flattened into the parent operation graph
MK-30  parent profiles are not inherited implicitly across project boundaries; a dependency may select a child profile explicitly
MK-31  project-dependency cycles are rejected from canonical project identity in the active recursive invocation chain
MK-32  multiple parent goals mapped to one direct dependency are delegated as one de-duplicated child-goal request
MK-33  project dependencies must complete successfully before parent local lifecycle work; operation failure-continue semantics do not apply to them
MK-34  version-2 plans preserve active dependent-project requests as nested project plans
MK-35  project dependency semantics do not imply request-wide exactly-once execution or de-duplication across independent sibling branches
MK-36  version-2 requirements are named external conditions distinct from operation prerequisites and project dependencies
MK-37  the first requirement type is pkg facility identity plus existing pkg compatibility constraints
MK-38  operations and trusted providers may reference requirements and only requirements reachable from requested lifecycle nodes are resolved
MK-39  mk consumes pkg provider/facility resolution through the public pkg requirement query and does not duplicate provider selection, compatibility or installation policy
MK-40  project facility requirements use the system facility default and do not create synthetic package-consumer bindings
MK-41  requirement resolution is read-only and does not install packages or mutate provider-selection configuration
MK-42  reachable unsatisfied requirements remain inspectable in plans, block only their consumers and are re-resolved during runtime refinement
MK-43  version-2 plans expose reachable requirement state and the selected provider concrete for satisfied facility requirements
MK-44  version-2 ordinary process operations may opt into incremental freshness through named incremental inputs plus existing named outputs
MK-45  incremental path, collection and output inputs use deterministic content identity; mtime is not part of freshness
MK-46  an incremental output input creates a data dependency on its producer without requiring duplicate prerequisite declaration
MK-47  a reusable incremental success requires both the same effective fingerprint and current declared outputs equal to the recorded successful output fingerprints
MK-48  up-to-date is verified current-request success-equivalent evidence for prerequisites, collection after barriers and output evidence but does not synthesize actual execution-result fields
MK-49  a reachable result-field observation forces actual execution of an otherwise up-to-date producer
MK-50  failed execution never creates reusable freshness state and unsupported/corrupt freshness state degrades conservatively to a miss
MK-51  incremental freshness metadata is user-scoped non-authoritative mk cache state resolved through state-path user sys mk cache
MK-52  --plan may read freshness metadata but does not create or refresh it
MK-53  the first incremental baseline stores freshness metadata only and does not establish artifact storage/restoration, shared/remote cache or provider-level incremental templates
MK-54  project dependency delegation remains recursive; child mk instances own their own incremental decisions and no request-wide de-duplication is implied
```
