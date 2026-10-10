# workflow-optimization

Status: Active
Updated: 2026-10-10

## Goal

Maintain a long-lived meta-workstream for continuously evaluating and improving the RumiAI development workflow: retrieval, documentation organization, Project Instructions, handoffs, deferred-work visibility, specification promotion, command/library manual consistency, parallel work, repository coordination, testing/validation workflow and other mechanisms that affect how work is performed and resumed.

## Current repository revisions

```text
rumiai-dev    08059aa366adb401341ff453f2379bf2cc0caae4  (pre-correction-gate HEAD after diagnostics contract, TODOs and workflow checkpoint)
rumiai-os     99ff4358104c2abf934a22d0bc186ec72dc43a7d  (current implementation inspected for diagnostic behavior; not modified)
rumiai-tests  8a3c840dce33627cea622f1d147cef97a301bc57  (current log tests inspected; not modified)
pkg-catalog   f0cdadb09ced5ca26c7745b5996de89cab24f7c1  (current remote HEAD; not involved in this correction)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/DIAGNOSTICS.md
specifications/rumiai-os/LANG-BOOTSTRAP.md
todo/README.md
handoff/README.md
```

Subsystem specifications are added only when a concrete workflow question reaches their responsibility.

## Fixed task-local choices

- Stable task identity: `workflow-optimization` / `handoff/workflow-optimization.md`.
- This task is intentionally long-lived across chats while the workflow continues to be evaluated.
- Its handoff is synchronized automatically at meaningful checkpoints according to `handoff/README.md`.
- It governs workflow health and reusable lessons; it must not become a second copy of canonical rules/specifications or a catch-all implementation task.
- Durable workflow rules are propagated to canonical current documentation.
- Known concrete but inactive work belongs under `todo/`; active resumable work belongs under `handoff/`; completed/past state belongs in Git history.
- `specifications/` contains promoted current contract only; unresolved active design belongs in handoff `Working design` until promotion.
- Every RumiAI-owned directly executable command identity requires operational manual coverage regardless of audience.
- Every RumiAI-owned library identity requires exactly one operational manual topic.
- Library public/internal API visibility is explicit in naming: public functions do not begin with `_`; internal functions begin with `_`.
- Library manuals expose the complete public function interface and do not expose internal functions as callable API.
- Command/library lifecycle changes and manual realignment are one development consistency obligation.
- Structural permanent coverage for both command→manual and library→manual completeness is mandatory; absent coverage keeps the corresponding completeness work open.
- Distinct handled failure branches must remain diagnostically distinguishable through local status codes and branch-specific diagnostic identities; logging/observability is part of implementation quality rather than optional after-the-fact instrumentation.
- Significant non-trivial flows require proportional info/debug/trace observability unless a concrete bootstrap, recursion, performance, protocol/output or security constraint justifies omission.


## Working design

### Adaptive human-AI cooperation model

A new workflow-design line is retained here deliberately as working design rather than being compressed immediately into rigid project rules. It emerged from a concrete architecture regression in which a locally convenient implementation choice changed the foundational boundary between the root m bootstrap and core.lib.sh without explicit user approval. The important lesson is broader than that incident and is intended to become a general cooperation model that can later apply beyond RumiAI development, including advanced research work.

The central hypothesis is:

> The appropriate degree of assistant autonomy, rigidity, exploration and escalation should adapt to the semantic/architectural impact of the decision and to the context, not simply to the technical complexity of the work.

High technical complexity does not imply that the user should be interrupted frequently. Once important boundaries are fixed, the assistant may be highly autonomous in carrying out very large, difficult or multi-step work. Conversely, a technically trivial change may require explicit user approval when it changes a foundational boundary, responsibility or model.

A particularly important distinction is:

    execution autonomy != decision autonomy

The user may deliberately grant broad execution autonomy for a difficult task without thereby delegating authority to redefine the foundational architecture underneath that task. The assistant should use its capabilities aggressively inside established boundaries while keeping high-impact boundary decisions visible.

The working model currently evaluates at least these dimensions:

    decision impact
        How widely does the choice change ownership, contracts, architecture,
        shared mechanisms or future work?

    foundationality in context
        Is the affected element foundational to the whole system, foundational
        to a subsystem, or merely internal to one component?

    reversibility
        Can the choice be tested or changed locally and cheaply, or does it
        propagate into many dependent surfaces?

    clarity of intent
        Is the desired outcome already fixed while only the implementation path
        is open, or is the underlying outcome/boundary itself still undecided?

    cost of error
        Would a wrong choice remain local and obvious, or could it contaminate
        specifications, tests and dependent work before being detected?

    value of exploration
        Would autonomous investigation, experimentation or comparison materially
        improve the solution before a decision is required?

    context maturity
        Is the work exploratory, where flexibility is valuable, or is it
        operating inside a mature/foundational contract where uncontrolled
        flexibility is dangerous?

These dimensions are intentionally not yet a scoring algorithm. The goal is adaptive judgment, not bureaucracy.

A useful provisional impact scale is:

    local implementation, boundaries unchanged
        strong autonomy is desirable

    significant shared behavior, boundaries mostly unchanged
        autonomous work remains useful, with careful propagation analysis

    foundational mechanism of a subsystem
        make the proposed change explicit, explain motive, benefit and material
        consequences, and obtain explicit authorization before changing that
        foundational model

    foundational mechanism of m/RumiAI or an equivalent top-level architecture
        analysis and proposals may be autonomous, but responsibility/architecture
        changes require explicit authorization before implementation

"Foundational" is contextual rather than global. Changing an internal implementation inside one rsudo module may be local; changing the routing model by which rsudo submodules are selected is foundational to rsudo even though it is not foundational to all of RumiAI; changing the root bootstrap/core responsibility boundary is foundational to m itself.

Another important lesson is that an open question is not implicit decision authority. The assistant may resolve ordinary implementation questions autonomously when they remain inside fixed architecture. If an open question concerns ownership, layering, a foundational mechanism, a public contract or another high-impact boundary, it must be surfaced clearly rather than silently resolved for local convenience.

Local convenience itself is a warning signal when it is purchased by changing surrounding architecture. Before adopting a solution because it makes the immediate task easier, the assistant should ask:

> What complexity or responsibility am I pushing into the surrounding system in exchange for this local simplification?

If the answer is that a foundational boundary must move, the convenience is not sufficient justification and the decision should be escalated.

The desired collaboration is complementary rather than symmetric. The user preserves continuity of vision, meaning and high-impact architectural intent. The assistant can rapidly explore large technical spaces, connect dependencies, compare alternatives, detect consequences and execute substantial work. The workflow should therefore maximize assistant autonomy where that reduces execution cost and expands solution quality, while preserving explicit human control over high-impact decisions that define what is being built.

This same model should remain useful outside software engineering. In research, design, analysis and other complex work, exploration, elaboration and execution may often be highly autonomous while decisions that materially determine objectives, irreversible commitments or foundational models remain explicit.

The model should be refined empirically through real work rather than frozen prematurely. Future incidents should be used as evidence:

    real episode
        ↓
    observed cooperation lesson
        ↓
    working design in workflow-optimization
        ↓
    repeated/contrasting real cases
        ↓
    stable principle
        ↓
    minimal canonical rule

The aim is not to react to one case of excessive initiative by creating excessive caution. A successful model must prevent silent high-impact decisions without turning routine work into repeated permission requests.

### Promotable core — not yet canonical

The following principles appear mature enough to be candidates for later promotion into RULES.md, but remain here until they are jointly reviewed in concise canonical wording:

1. Assistant autonomy is governed primarily by the impact of the decision, not by the technical complexity or amount of work.
2. Inside already-approved boundaries, the assistant should normally exercise strong execution autonomy, including on complex and extensive work.
3. A proposed change to a foundational mechanism of the overall architecture or of the affected subsystem must be made explicit before implementation, with its reason, expected improvement and material consequences, and requires explicit user authorization.
4. An unresolved/open design question does not authorize the assistant to choose silently when the question affects a foundational boundary, ownership or high-impact contract.
5. Local implementation convenience must not silently justify a larger architectural change; the assistant must consider the semantic/architectural blast radius of the decision.
6. Execution autonomy and architectural decision authority are separate; granting the former does not implicitly grant the latter.

These points should later be reviewed together and promoted only in the smallest wording that preserves the behavior. The richer model above should remain available as working-design rationale until enough real cases establish which dimensions are genuinely useful.

## Completed

### Current-only documentation and retrieval model

The documentation was reorganized around:

```text
current branch = present
Git history = past
```

The root `README.md` is the deterministic retrieval router. Current contracts live in one canonical location; historical patch composition is not used to reconstruct current meaning.

### Deferred-work and active-design lifecycle

The current lifecycle separates:

```text
promoted contract       → specifications/
active working design   → handoff/<task>.md / Working design
deferred future work    → todo/
past/completed state    → Git history
implementation/tests    → current mechanical state and evidence
```

A specification promotion gate prevents candidates, postponed decisions and comparison state from being preserved as normative architecture merely for memory retention.

### Command/manual completeness

Every RumiAI-owned directly executable command identity must have an owner-local operational manual topic. Command creation, rename, removal and behavior-affecting changes are coupled to manual realignment; every command modification requires an explicit manual-consistency check. Structural permanent coverage is required to detect missing command topics.

The active `rumiai-os-man-documentation` handoff owns the current command-manual backfill rather than duplicating it as deferred work.

### Library interface and manual completeness

The same completeness model has now been extended to RumiAI-owned libraries.

Canonical model:

```text
lib/<owner>/<runtime>/<library-name>.lib.<runtime>
    ↓
res/<owner>/manual/<library-name>.lib.<runtime>
```

Each library has one manual page. Its public API is defined by functions whose names do not begin with `_`; internal functions must begin with `_` and are implementation-private. The manual exposes every public function and does not present internal functions as callable API.

`specifications/rumiai-os/LIBRARY-INTERFACES.md` is now the canonical library-interface contract. `RULES.md`, `CONSISTENCY-GATE.md`, `DOCUMENTATION-MODEL.md` and `specifications/README.md` route and enforce the same lifecycle without creating a second authority.

Current product inspection established that newer/current examples such as `array.lib.sh` and `mk-materialize.lib.sh` already visibly use underscore-prefixed private helpers and unprefixed public functions. Legacy code such as `core.lib.sh` contains unprefixed helper-shaped functions whose intended API visibility cannot safely be inferred from spelling alone.

Therefore the correction was deliberately split:

```text
active manual task
    library manual backfill and structural library→manual completeness

todo/library-api-visibility-realignment.md
    dedicated legacy API classification/rename/caller/test migration where required
```

This avoids both silent breaking renames and documentation that accidentally promotes legacy implementation helpers to public API.

The current `rumiai-os@14e413342261b23df840f40b355166c4d55f1b41` manual tree was rechecked after concurrent pager movement and still contains no mandatory library-identity topics. The `e9cad... → 14e413...` product delta touched only `bin/sys/pager` and `res/sys/manual/pager`, so it did not invalidate the inspected library inventory or library-manual gap.

The final consistency pass also eliminated an obligation-level mismatch: `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md` and `CONSISTENCY-GATE.md` now all make structural library→manual coverage mandatory rather than mixing `SHOULD` and `MUST` language.

### Concurrency evidence

Concurrent `rumiai-dev` movement occurred again during this correction. A write to the active manual handoff was rejected because another chat had changed the same file; the new state was fetched and the library/manual delta was reapplied forward. No concurrent change was overwritten. A later product revision movement was also reconciled into the manual handoff before this checkpoint.

### Product intent and operability

A concrete review of `pkg` exposed a workflow failure: the subsystem could be internally coherent and mechanically tested while still making an elementary user goal impractical by requiring knowledge of provider-specific exact revisions.

The correction was promoted into the canonical workflow rather than retained as package-specific advice:

```text
RULES.md
    product intent and operability are completion constraints for user-visible work

CONSISTENCY-GATE.md
    mandatory primary-goal, normal-path, caller/system knowledge-boundary and
    semantic-delta checks before implementation and after changes

TESTING.md
    representative normal public-path coverage for materially user-facing behavior

handoff/README.md
    concise acceptance scenarios for active tasks that materially change
    user-visible workflows
```

The core lesson is that passing internal/component tests cannot establish product correctness when the normal public workflow does not let a caller achieve the intended goal naturally with information they can reasonably know or deliberately choose.

During this correction, a dedicated `workflow-operability` handoff was created, completed and removed. That routing was unnecessary because `workflow-optimization` already owns this class of reusable workflow lesson; the forward-only history is retained and this handoff now owns the continuing workflow state.

### Active handoff ownership

The routing error above was reviewed and promoted into the canonical handoff workflow.

Current rule:

```text
ownership is determined by resumable responsibility, not topic wording

same responsibility + no materially independent lifecycle
    → reuse the existing active handoff

materially independent goal/state/blockers/validation/completion
    → create a separate handoff
```

Long-lived handoffs are the preferred owners of recurring observations, decisions and improvements within their standing responsibility. A narrower label alone never justifies a parallel task. When independence is unclear, work stays with the existing owner until an autonomous lifecycle becomes concrete.

When a broader handoff legitimately spawns a specialized child task, the child owns operational progress and completion state while the parent keeps only the relationship and reusable broader lesson; active state is not duplicated.

The rule is now canonical in `handoff/README.md`, routed from the root `README.md`, and enforced by `CONSISTENCY-GATE.md`.

### Diagnostics and observability

A recurring implementation defect was confirmed in which extensive defensive checks were flattened onto the same return/exit codes and generic log identities, making failures detectable but difficult to locate. The user explicitly established diagnosability and logging as foundational implementation concerns.

The correction is now canonical in `specifications/rumiai-os/DIAGNOSTICS.md`, routed from `specifications/README.md`, summarized in `RULES.md` and enforced by `CONSISTENCY-GATE.md`. `LANG-BOOTSTRAP.md` was also realigned so language-selection failures no longer normatively collapse distinct branches into generic `execution.invalid-arguments` / `execution.execution-failed` identities.

Current implementation was inspected rather than assumed compliant. Existing primitives such as `pathsearch` and `log` already show distinct local status allocation, while larger legacy flows contain reused statuses and generic diagnostic identities. Product migration is therefore deferred explicitly to `todo/diagnostic-observability-realignment.md` rather than being hidden as current compliance or changed mechanically.

The user also requested recovery of an older `m` logging idea for study. Deliberate historical retrieval found the concrete mechanism in `massimilianonardi-ai/m@2a57a29880c2d7a32e18782122062c695fcb1a3a`, especially `var/#_os/m/bin/m-log.lib` and `var/#_os/m/bin/log`. It tracked subprocess depth and exposed `LOG_SUBPROCESS_LEVEL`, `LOG_SUBPROCESS_LEVEL_STEP`, `LOG_SUBPROCESS_LEVEL_MAX` and `LOG_LEVEL_FORCE`, with depth-dependent effective log-level behavior and switch/restore diagnostics. This remains historical design evidence only; current analysis is captured by `todo/log-level-child-propagation-analysis.md` and automatic child-process log-level transformation is deliberately not specified by the current diagnostics contract.

## Current state

`workflow-optimization` remains active.

The workstream now also retains an adaptive cooperation model as working design. Its central distinction is execution autonomy versus decision autonomy, with escalation driven by semantic/architectural impact and contextual foundationality rather than raw technical complexity. A six-point promotable core has been isolated but intentionally not yet added to RULES.md.

The workflow now has explicit consistency gates for both directly executable commands and libraries:

```text
command identity  → mandatory operational manual
library identity  → mandatory operational manual
library function  → explicit public/internal visibility by leading underscore
```

The legacy library visibility migration is not hidden as current compliance: it is explicit deferred work, while documentation backfill remains owned by the active manual task.

The workflow now also treats primary user goals, normal public paths and caller/system knowledge boundaries as explicit design and completion constraints. The 2026-09-30 pkg episode is the first concrete evidence behind this gate.

Failure handling now has its own current consistency surface: distinct local failure statuses, branch-specific diagnostic identity, useful structured context and proportional info/debug/trace observability are required by the canonical diagnostics contract. Legacy product realignment and child-process log-level policy analysis remain separate deferred work rather than implicit current behavior.

Active task routing now uses resumable responsibility rather than topic labels. Existing long-lived owners are reused for work inside their standing responsibility unless a materially independent lifecycle exists; justified parent/child task splits keep operational state single-owned.

## Next action

Observe the TODO lifecycle, specification promotion gate and command/library manual gates in normal use. In particular:

1. verify every new/modified command retrieves and checks its operational manual;
2. verify every new/modified library retrieves `LIBRARY-INTERFACES.md`, checks function visibility naming and checks its single library manual;
3. verify internal library helpers are not accidentally documented/promoted as public API;
4. verify the active manual task closes command/library topic gaps and adds mandatory structural permanent coverage;
5. verify the legacy visibility TODO is activated as a dedicated product/API migration rather than folded silently into unrelated work;
6. watch for TODO/handoff/specification/manual duplication or taxonomy drift;
7. exercise the adaptive cooperation model on real tasks and collect contrasting evidence about impact, foundationality, reversibility, intent clarity, error cost, exploration value and context maturity;
8. exercise the product-intent/operability gate on real public workflows, beginning with the pkg review, and verify that normal-path acceptance tests expose unusable but internally coherent designs;
9. exercise the new handoff-ownership rule in normal work and watch specifically for false merges into long-lived tasks, unnecessary parallel handoffs and duplicated parent/child state;
10. jointly review the six-point promotable core after additional real use, then promote only the minimal stable rule set to RULES.md if the evidence supports it;
11. exercise the diagnostics gate on new code and verify that distinct failure branches are not flattened back onto shared statuses/generic message identities;
12. activate `todo/diagnostic-observability-realignment.md` as a dedicated product/test audit when that migration is scheduled;
13. analyze the historical subprocess log-level mechanism through `todo/log-level-child-propagation-analysis.md` before deciding whether a modern equivalent belongs in current `m`.

## Blockers / open questions

None blocking current workflow use. The adaptive cooperation model remains deliberately non-canonical while it is exercised on real cases; the six-point core is the candidate for later joint review/promotion. Current command/library manual backfill belongs to `handoff/rumiai-os-man-documentation.md`; legacy library API visibility realignment is represented by `todo/library-api-visibility-realignment.md`. Diagnostic legacy migration is represented by `todo/diagnostic-observability-realignment.md`; subprocess log-level propagation/reduction remains an analysis item in `todo/log-level-child-propagation-analysis.md`.
