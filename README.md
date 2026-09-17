# RumiAI development knowledge base

Status: **Current**  
Updated: 2026-09-17

`rumiai-dev` is the authoritative semantic knowledge base for RumiAI development.

The repository is deliberately organized for deterministic retrieval: the current branch describes the **current project**, while superseded material is preserved by Git history instead of remaining beside current contracts.

## Mandatory read order

For every RumiAI task, use this order before analysis or modification:

1. verify the current remote HEAD of every involved repository;
2. read `README.md` to route the task;
3. read `RULES.md`;
4. read `CONSISTENCY-GATE.md`;
5. read `specifications/README.md` and only the current specifications relevant to the subsystem;
6. read an active file under `handoff/` when the task is represented there;
7. inspect the current implementation and permanent tests of the involved repositories when behavior or implementation state matters.

Do not use conversation memory, old commit content or remembered decisions as a substitute for this retrieval.

## External assistant / Project Instructions bootstrap

External assistant instructions, including ChatGPT Project Instructions, must act only as a **bootstrap into this repository**.

They should contain only the minimum stable rules needed to force fresh retrieval, preserve Git history and prevent memory from becoming authority. They should not duplicate POSIX rules, architecture, naming, testing policy, package semantics, state semantics or other subsystem contracts already maintained here.

The intended external bootstrap is therefore conceptually:

```text
recognize a RumiAI task
→ verify current remote HEADs
→ read this README
→ follow its mandatory read order
→ use the smallest complete current source set
→ perform the task autonomously within those constraints
→ run the final consistency gate
```

If a repository source and an external assistant instruction ever duplicate the same RumiAI contract, the repository is the canonical maintenance location and the external instruction should be simplified rather than creating a second independently editable rule set.

External instructions may additionally require forward-only Git and preservation of concurrent/user changes because those constraints are necessary before repository retrieval itself can safely proceed.

## Authority model

Current authority is intentionally shallow:

```text
explicit current user instruction/correction
    ↓
RULES.md + CONSISTENCY-GATE.md
    ↓
current subsystem specification(s)
    ↓
active task handoff, only for task state and already-fixed task-local choices
    ↓
current implementation and permanent tests as factual/mechanical evidence
```

A handoff does not override project rules or specifications. Implementation does not silently redefine a normative contract. Passing tests do not override a current specification.

Historical commits, old decisions, closed handoffs, chat exports, drafts and superseded specifications are evidence of how the project evolved; they are **not current authority**.

## Current tree

```text
README.md                 this routing entrypoint
RULES.md                  canonical project-wide development rules
CONSISTENCY-GATE.md       mandatory preflight and post-change consistency process
DEVELOPMENT.md            development workspace/bootstrap contract
TESTING.md                canonical testing and validation contract
RUNNER.md                 canonical rumiai-test runner contract
PHYSICAL-TESTING.md       physical-validation discipline
TEST-PATTERNS.md          current test-authoring patterns
setup-dev.sh              development workspace bootstrap

specifications/
    README.md              subsystem/topic routing index
    rumiai-os/             current RumiAI OS / m specifications only

handoff/
    README.md              active-handoff lifecycle and template
    <active-task>.md       only while the task is active
```

Directories previously used for `analysis`, `architecture`, `chat`, `decisions`, `drafts`, historical `handoff` files and old `patterns` are intentionally absent from the current tree after the 2026-09-17 documentation reset.

The complete pre-reset documentation remains recoverable from Git history. The last pre-reset documentation HEAD is:

```text
11103af65669b8d4fbf4bc8ded2f2515a347b9ef
```

That commit is a historical reference, never a default source for current work.

## Documentation lifecycle

The current tree follows these rules:

- **one current contract, one canonical location**: do not keep two current documents that must be mentally merged to know the rule;
- an accepted design correction updates the affected current specification in the same work unit whenever possible;
- a decision document is not used as a permanent patch layer over a stale specification;
- rationale that is no longer needed for normal retrieval remains available through Git history and commit context;
- superseded specifications are removed from the current tree instead of being left beside current ones with warning banners;
- completed handoffs are removed from the current tree after their durable decisions/state have been propagated to the canonical sources;
- revision-specific validation evidence remains in the validation mechanisms/repository that produced it and is not rewritten as current contract text;
- historical evidence is never relabelled as evidence for a later revision.

When a historical explanation is specifically needed, inspect Git history deliberately. Do not pull historical material into ordinary task context by default.

## Repository roles

```text
rumiai-dev
    current rules, workflow and semantic specifications

rumiai-os
    current product/runtime implementation

rumiai-tests
    permanent executable tests, runner and revision-specific validation evidence

rumiai-dev-PoCs
    experiments for questions that are still open

pkg-catalog
    current package definitions/catalog data consumed by the m package subsystem
```

The exact current HEAD of each repository must always be retrieved; no SHA written in documentation should be assumed to still be HEAD.

## Retrieval by topic

For product/runtime questions, start with `specifications/README.md` and follow the smallest applicable set of current specifications.

For testing questions, start with `TESTING.md`; add `RUNNER.md`, `PHYSICAL-TESTING.md` or `TEST-PATTERNS.md` only when the topic requires them.

For a continuing multi-chat task, read the corresponding active handoff after project rules/specifications. The handoff should contain only task state that is not already canonical elsewhere.

For exact behavior of code already implemented, inspect the current source and relevant permanent tests after reading its normative contract. Documentation should define **what must remain true**; implementation and tests establish **what the current revision actually does and mechanically protects**.
