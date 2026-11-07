# workflow-optimization

Status: Active
Updated: 2026-11-07

## Goal

Maintain a long-lived meta-workstream for continuously evaluating and improving the RumiAI development workflow: retrieval, documentation organization, Project Instructions, handoffs, deferred-work visibility, specification promotion, command/library manual consistency, parallel work, repository coordination, testing/validation workflow and other mechanisms that affect how work is performed and resumed.

## Current repository revisions

```text
rumiai-dev     dc494708e68ab445d78ca95626fa70026b6a451f  (verified remote HEAD before this checkpoint write)
ai-workflow    5d4ff7cb31de61902795a15354b5428904b5a944  (user-supplied cmd-02 observation committed as non-independent result)
rumiai-os      7d439e961f7bbadd226794ac029e98bdab51d5c2  (remote HEAD checked for comparison)
rumiai-tests   1e9e47f622bb28d5bbc2aa487fc538507b34cb16  (remote HEAD checked for comparison)
pkg-catalog    f0cdadb09ced5ca26c7745b5996de89cab24f7c1  (older checkpoint, not re-verified for this step)
```

Verify remote HEADs before every future write. `ai-workflow` now contains an
accepted **experimental candidate** with a real bootstrap document, but it is
not installed, empirically validated, or a replacement for RumiAI contracts.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
DEVPLAN.md
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

- 2026-11-07 operator acceptance: implement the first isolated `ai-workflow` candidate with lowercase `bootstrap.md` (keeping the preexisting `README.md`), exact `!aw` command namespace, multi-label/open-set natural-language routing, progressive disclosure, separate workflow and state documents, and a tiny test fixture. Lowercase naming is a **phase-local preference**, not a new global naming rule. Publication does not authorize activating it in RumiAI or any ChatGPT Project.

- The operator approved an opt-in planning-only command `devplan`; its durable contract is in `DEVPLAN.md`, not duplicated here.

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


- The user has disabled GitHub chat mirroring and explicitly selected **Google Drive** as the opt-in remote mirror destination. Preserve the existing GitHub transcript as a legacy, non-authoritative archive but never append new chat turns to it.
- The active per-chat Google Drive folder is `ChatGPT/chats/2026-10-14-chat-mirror/` (Drive folder ID `1giqQeQ0wAHKM8dVTrDiOaTSSP2FIP4Ro`); its stable Markdown mirror is `chat.md` (Drive file ID `10D-cAJNqPvquHsmk94n6nt0SFb9h8Pwj`), with media in the same folder (current PNG ID `19jFplZPhSvqe-dU7Mh2GSFu91-dvIa14`).
- **`attiva chat mirror`** and **`disattiva chat mirror`** activate or deactivate *both* the Google Drive Markdown mirror and the user-delivered cumulative Markdown attachment for that chat. They do not configure an always-on global feature or create a background process.
- **Current chat state (2026-10-15, 12:28 Europe/Rome): OFF.** The user explicitly requested `disabilit il mirror`; stop both per-turn outputs immediately: no new attachment version and no Google Drive Markdown/media update for this deactivation exchange or later turns until explicit reactivation. Existing snapshots and Drive archive remain untouched. Resume at `0009` only if explicitly reactivated.
- Keep increasing attachment filenames: `rumiai-chat-20261014-0001.md` through `0008.md` have been prepared locally; `0009.md` is next. The previous failed `0007` Drive update was reconciled by an in-place verified update to `0008` during the 2026-10-15 turn. Each response also reoffers previously generated images as downloads and includes links to them in Markdown.
- Maintain one live `chat.md` file in Google Drive, updating its existing Drive ID in place using `mcp__Google_Drive__update_file` with a generated file reference. The Library `overwrite=true` upload path was tested and is not supported for Google Drive; do not use it to update the same file. Initial creation and colocated PNG upload via the files Library/Google Drive path succeeded.
- Markdown plus linked media is the accepted format. Google Drive is remote persistence and chat attachments are explicit delivered versions; no hidden buffering, periodic synchronization or PDF. Report separate per-destination successes/failures without silently treating them as equivalent.
- **Scheduled Drive → GitHub archive copy: discontinued.** The user reports the hourly scheduled copy did not work and explicitly deleted it on 2026-10-15. Do not treat this automation as installed, active or reliable, and do not recreate it without a new explicit request. This is separate from the already-disabled per-turn chat mirror. The attempted copy had targeted the public `massimilianonardi-ai/rumiai-dev` repository; the previous configuration is historical task context only, not a current workflow.
- Chat archive content is non-normative RumiAI history. The old GitHub transcript includes earlier activation-era messages, but the Drive/attachment series begins with the numbered snapshot 0001; do not assert complete retroactive migration of the earlier turns.
- **2026-10-30 operator clarification — conversation/thought boundary:** Everything discussed or written in a chat remains an independent exploration, including critical Markdown reviews of several chats. Chats are free to challenge any premise, choice or current decision without thereby changing project authority. No summary, retrospective, recommendation, apparently accepted idea or archival write automatically becomes a project decision, rule, contract or implementation authorization. Moving a finding into the project requires an **explicit decision after its expected benefit and consequences have been assessed**; then update only the appropriate current project surface through the existing governance process. Retain the original reflection and its provenance without treating it as normative.

## Working design

### Thematic critical reviews of archived conversations — exploratory

The operator identified a valuable future use for the public per-topic chat archives: revisit multiple conversations on the same subject and produce a source-linked Markdown **critical retrospective**, not a synthesized replacement for the original data. Inspect overlooked details, contradictions between conversations, premature rejections, alternative approaches that became relevant later, optimization opportunities and connections that were invisible when the discussions happened. Compare against *separately retrieved* current project sources when appropriate, distinguishing historical reasoning from actual current contracts.

This is a proposal for future analysis, **not an authorized automatic review pipeline and not a specification or decision-making mechanism**. Keep resulting reflections separate from authoritative project material; preserve original citations/data. New action, policy, architecture or implementation changes require a deliberate explicit decision supported by an assessed benefit and the existing project process. It must remain possible to reconsider everything during a chat without implicitly altering the project.

### Chat mirror pilot — Google Drive and downloadable Markdown

**When explicitly active (currently OFF):** at each assistant response, the assistant captures the visible user prompt and assistant answer in the cumulative Markdown, delivers it under a new progressive filename, and updates the persistent Drive `chat.md` in place. Generated image assets remain downloadable, are linked from Markdown and, when possible, are uploaded in the same Drive folder. Every remote write must be checked; a failure must be disclosed. No background monitor or automatic operation outside an assistant turn is implied.

**Real observed Drive test (2026-10-14):** an existing `ChatGPT` Google Drive folder was found, and `chats/2026-10-14-chat-mirror` was created underneath it. Uploads of `chat.md` and `workflow-attuale-001.png` succeeded, both files were verified through Google Drive metadata, and `chat.md` was subsequently replaced in place using a generated exported file reference and the Drive file update action while keeping the same file ID. After the failed `0007` transfer, the current turn generated `rumiai-chat-20261014-0008.md`, uploaded a short-lived copy into the existing Drive chat folder, retrieved its connector file reference and updated the stable Drive `chat.md` in place. A fresh fetch verified version `0008`, the previous pending turn, the current prompt and answer, and both image links. The transient copy was then deleted successfully. The following attachment should use `0009`. A subsequent turn exposed a missed Drive sync after a generated infographic: live Drive text was still at `0005`, so the user prompt and resulting PNG were recovered, uploaded as `workflow-attuale-google-drive-002.png` (ID `1nHSBdK0lUMBz0vyvGDCRo1rO27e8hRVN`), and `chat.md` was updated and re-fetched successfully at `0006`. This confirms a missed assistant-turn update can still occur; do not claim autonomous reliability. Images must be re-offered with each attachment.

**Migration boundary:** The user explicitly rejected the GitHub mirror because its delivery had proved unreliable. This does not mean GitHub itself is unavailable for RumiAI development documentation: GitHub remains authoritative for `rumiai-dev` rules and this handoff. The prior `rumiai-dev/chats/2026-10-14-github-chat-mirror/chat.md` is a frozen legacy archive; it is not the active chat mirror and must not be modified by ordinary future replies. Do not delete that earlier evidence automatically, or claim full older-history import into Drive. Revisit legacy archive retirement only if separately requested.

**Open checks:** consecutive-turn accuracy, attachment filename monotonicity, remote Markdown updates and downloadable image integrity, Drive link rendering (relative media links inside a Drive-hosted Markdown preview may not behave like GitHub), handling disconnected Drive accounts, and avoiding duplicates on retry. Real session-local tests are still required before advertising robust unattended or always-on behavior.

**Previously supplied Mac exporter scripts:** `chatgpt-export-v3(1).sh` launches ChatGPT Electron with CDP enabled; `chatgpt-export-v3(1).py` captures one selected conversation snapshot via a renderer/debugger hook and writes a one-time export. The canonical `WEB-CONTROL.md` supports rendered HTML/text/screenshot capture, not generic access to ChatGPT internals; a specialized exporter remains an optional separate investigation, not a dependency of this Drive pilot.

### ChatGPT native conversation sharing (exploratory, not implemented)

On 2026-10-15 the user asked whether an ordinary chat prompt can trigger the native ChatGPT **Share** action. Current assistant tools expose no native action for creating an official `chatgpt.com/share/` link; the user can use the ChatGPT interface's **Share → Create/Copy link**. An authenticated `web-control` browser interaction may be investigated as a separate site-specific automation, but has not been implemented or tested. For personal ChatGPT accounts, shared conversations are snapshots that require an explicit **Update link** to include subsequent messages. This is not equivalent to the Google Drive Markdown archive and does not change mirror activation or destination.

### Pending enforcement design — end-of-turn mirror gate

The user observed that the assistant can simply omit one or both mirror outputs on a turn, especially when image generation ends the response. The requirement is to make *both* the progressively numbered chat attachment and the Google Drive Markdown/media update mandatory for every opted-in turn. A text-only Project Instruction is not a deterministic execution guard; keep the authoritative RumiAI workflow in this handoff rather than duplicating it in Project Instructions.

Candidate procedural gate: construct the exact user prompt / intended visible assistant response and all available media; create the next cumulative Markdown attachment; update all missing Drive media, then update the existing Drive `chat.md` ID in place; fetch back and validate that the new turn and media are really present; verify the local download file and all linked image paths; only *claim success* with evidence for both outputs. Failure of either channel must be explicitly disclosed. This reduces risk, but cannot technically suppress ChatGPT's native UI response, and a generated-image-only reply may bypass the intended process. Do not claim hard enforcement from prompting alone.

Stronger candidate: a separate deterministic ChatGPT-specific adapter/observer using existing `web-control` browser observation and capture facilities (after checking actual provider capabilities and security), detecting completed user/assistant turns, reconciling against Drive with idempotent turn identities, retries and durable status. An observer *after* UI publication can detect/repair misses, but cannot prevent a response being displayed; a strict pre-publication guarantee would require a controlled user-interface or serving pipeline, outside currently exposed native ChatGPT controls. This design is unimplemented and unvalidated, not a current product contract.

Observed on 2026-10-15: local cumulative attachment `rumiai-chat-20261014-0007.md` was generated and verified (13,401 bytes), but two attempts to stage the bytes for Google Drive through Files returned `container_session_expired`. Current Drive `chat.md` remained at `0006`. The assistant must not claim the remote `0007` has been stored. This is concrete failure evidence for the proposed gate and requires retry when file transfer is functional.

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

### Workflow redesign from first principles — operator directive (2026-11-07)

**Accepted operator decision:** For substantial tasks, a proportionate early check of actual outcome, intended operational use and high-impact architecture assumptions is mandatory. The assistant must actively escalate unresolved choices that could redirect the work, including at the beginning; interruptions for routine implementation progress are not the goal. A special extended/uninterrupted execution behavior remains opt-in, not the ordinary default. Execution autonomy does not confer authority to redefine the mission or architectural boundaries.

**Redesign directive:** Reconsider the complete behavior/bootstrap and decision process from first principles rather than incrementally patching current preflight, `devplan`, handoff, tests or consistency gate. The operator reports `devplan` failed significantly in the Keycloak/rsudo episode: work units and tests appeared to progress while the requested rsudo-based operator outcome was not delivered and major assumptions were wrong. Treat this as a critical observed operator report requiring source- and revision-grounded reconstruction, not a claim that every individual implementation/test result was false.

**Provisional redesign scope (not promoted policy):** Explicitly model mission/outcome validation, discoverable versus operator-owned decisions, decision impact and reversibility, first meaningful end-to-end outcome, autonomous execution and recovery, truthful evidence classification, feedback from both implementation failures and wrong goals, handoff minimality and context-aware lessons with provenance. Evaluate current requirements before choosing the eventual documents, gates or modes. Backtest competing models on Keycloak/rsudo and at least one contrasting routine/low-risk task. No patch-layer to canonical rules, no automatic adoption of Hindsight, and no product/runtime changes from this investigation alone.

**Next design deliverable:** A comparative diagnosis of the present workflow and concrete failure mechanisms, followed by alternative end-to-end protocols with costs, operator interrupt policy, falsifiable acceptance scenarios and migration/validation strategy. Only then seek the architectural decision for a coherent replacement and promote minimal settled contracts to their canonical owners.

### Experimental agent-agnostic bootstrap and contextual workflow repository — operator direction (2026-11-07)

**Operator-approved direction (architectural intent, implementation still exploratory):** Move the future AI workflow/bootstrap out of `rumiai-dev` into an independent, separately testable repository. One tiny configurable bootstrap pointer in a ChatGPT Project, an individual chat or another compatible agent should resolve the new repository's root document. Keep the current RumiAI bootstrap and canonical authority intact for baseline work; allow deliberate opt-in/shadow tests of the experimental bootstrap in a separate ChatGPT Project or explicitly selected RumiAI chat. Initially store experimental context/project examples under one subdirectory in the same new repository; consider separating them into their own repositories only once the mechanism and costs have been validated. The operator reports already changing ChatGPT Project bootstrap instructions; this report is not independent verification of the live setting.

**The central architectural question:** Build a general agent behavior/context/retrieval system, not a more elaborate RumiAI README, a ChatGPT-specific permanent contract, or a Hindsight clone. The file tree is storage; concepts such as project, task, chat, session, research, environment or agent are **parameterized contextual attributes/relationships**, not fixed directory levels or mandatory nested categories. A single item may be relevant to more than one context; physical path depth must not define authority, inheritance or retrieval priority. Keep model/provider adapters separate from general semantics.

**First-principles hypotheses to evaluate, not yet current rules:**

1. **Minimal universal entrypoint:** A versioned root document declares the applicable bootstrap protocol, lookup/route index, source-trust semantics, context/authority resolution and fallback when remote retrieval is unavailable. It should not force all topic rules into every prompt. A plain URL/pointer is not an execution environment: a client must actually be able to fetch the repository and interpret the protocol; test this assumption on each target ChatGPT/agent configuration.
2. **Context graph and selective routing:** Stable context identifiers with metadata (e.g. kinds/tags/relationships, applicability predicates, source links, validity) and references to further knowledge/policy documents. Resolve an applicable context set from explicit user intent, entry configuration and current task evidence, not from folder placement. Distinguish routing to relevant material from permission to treat it as authoritative. LLM-assisted semantic retrieval may propose matches; explicit authority/precedence and ambiguity handling must not be silently delegated to a semantic score.
3. **Separation of concerns:** (a) source facts and immutable/revision-pinned evidence, (b) authoritative current constraints, (c) active task/session state, (d) derived experiences/observations/hypotheses with provenance and invalidation, and (e) execution tools/agent-adapter capability. Derived memory remains advisory; never displace fresh current contracts or user corrections.
4. **Adaptive decision protocol:** For substantial work, validate user/operator outcome and critical assumptions before committing to architecture; distinguish unknowns that can be investigated autonomously from high-impact choices requiring user decision. A user can delegate extensive implementation autonomy without delegating changes to mission, security, trust boundary, interface or foundational responsibility. Interruptions are useful for material architectural ambiguity and not for routine sequential execution or mere chat/context limits; explicit prolonged execution is an optional mode.
5. **Outcome-coupled execution:** First representative finished-product interaction and early end-to-end proof before proliferating research/test units. Maintain a visible distinction between discovered fact, designed target, implemented path, independently tested property, and demonstrated operator outcome. Continue independently executable work while a separate branch awaits an operator decision.
6. **Evidence-oriented learning:** Study Hindsight's retain/recall/reflect separation, scoped banks/tags, hybrid retrieval, source-linked observations and temporal correction, plus progressive disclosure of Agent Skills; start as reference concepts or PoC rather than a mandatory service. Preserve evidence versus inference, record correction/invalidation and prevent historical memory from becoming higher authority than current source.
7. **Test the method, not only its prose:** Run clean-chat or separate-Project opt-in pilots against the existing RumiAI bootstrap, without modifying old current contracts. Replay the Keycloak/rsudo failure from only the information available at the time, plus contrasting unambiguous, simple, multi-repo and high-impact ambiguous cases. Measure missed critical questions, unnecessary interruptions, wrong-assumption rework, actual usable end-to-end results, context/latency cost, retrieval accuracy, and resumability. Claim observed behavior only, not native enforcement or unattended runtime where absent.
8. **Safe transition:** Keep the new bootstrap and RumiAI original isolated. Do not install external agents or memory engines, change root Project Instructions, create a new GitHub repository, or re-promote policy merely because a proposal is recorded here. The initial name, concrete manifests, inheritance/override/conflict rules, security boundary and migration policy are to be designed and validated rather than guessed.

**Provisional pilot storage sketch (conceptual, not a fixed schema):**

```text
<workflow-repository>/
  README.md                   # minimal entrypoint, routing and authority
  protocols/                  # general decision/execution protocols
  indexes/                    # route/context descriptors
  contexts/                   # experimental scoped data, including RumiAI
  evaluations/                # reusable evaluation cases and measured results
  adapters/                   # agent-specific integration notes, optional
```

Treat "project", "task" and "chat" as names that describe certain context entities, not required ancestors in these folders. Use references/metadata rather than nesting to express cross-cutting relationships. Separate contexts into different repositories later only if the evidence justifies it.

**Next concrete design step:** Draft and compare at least two end-to-end routing/authority protocols (simple hierarchical progressive disclosure versus a typed context graph/overlay model) with the same example prompts, startup paths, costs, conflict resolution and failure behavior. Identify which aspects can be deterministic and which rely on model judgment. Only after selecting a testable pilot contract, establish a new dedicated repository and separate experimental ChatGPT Project. Preserve RumiAI current behavior unless independently authorized for an explicit test.

### Explicit separation of workflow behavior from contextual state — operator clarification (2026-11-07)

**Operator clarification, binding design intent for the experimental redesign:** The system must strictly separate (1) relatively stable workflow/behavior documents that define the general reasoning/decision/execution method, changed only when globally/conceptually changing that method, from (2) mutable, structured context/state documents (e.g., active handoffs, project or task specifications, task checkpoints) that define *what* the agent is dealing with, *where* to resume and which particular constraints/evidence apply. The phrase "separate reasoning from context" refers here to separation of the external decision/workflow **method** from its per-instance **inputs/state**; it does not require disclosure or storage of private model chain-of-thought.

**Operator-specified state header:** Each contextual state document should use a predefined format with front-loaded **shortcuts/references to the applicable workflow documents** and to **other relevant state/context documents**, before its actual content. The agent should be able to begin from a narrowly targeted state node and retrieve the right workflow and dependency context without loading all materials, without a fixed project/task/chat directory hierarchy and without copying global rules into each state. Contextual documents may describe project-level requirements/specifications or task-level execution state, but their content must not implicitly rewrite the general workflow protocol.

**Design consequences and tradeoffs to evaluate (provisional, not fixed schema):**

- Workflow = stable, reusable behavioral protocol; context/state = task/project/chat-specific facts, constraints, decisions, evidence, current status, blockers and next action. Domain specifications may be binding **within their declared scope** yet are still context sources, not global agent-method rules.
- A context document header could carry a stable ID, contextual type(s)/tags and applicability; `workflow_refs` (applicable protocol pointers), `state_refs` (relevant contextual relationships), source/authority designation and revision pins or current-ref semantics. These example field names are exploratory; do not promote them into a schema before testing.
- Resolve header references from the entrypoint; detect cycles, stale references and conflicts, and preserve provenance. Cross-context relevance and authority precedence are separate concerns. Filesystem nesting alone never establishes type, authority or inheritance.
- The resolution protocol must define what to load first and when to stop, what to do if a required document cannot be fetched, how to select amongst competing references, and how to handle cross-project references and concurrent updates. Avoid dynamic redefinition of behavior through arbitrary task-state content.
- A workflow revision should be an intentional conceptual/global change, assessed and tested separately from normal frequent state updates. Test whether workflow references should be pinned, versioned or resolved via a selected channel (e.g., stable/current) without silently changing a resumed task's interpretation.
- Minimal pilot must compare a workflow-from-root + state-header route with alternatives for both direct targeted-state resumption and fresh unscoped prompts. Verify that rerunning from a clean chat loads only necessary sources and has correct interruption/decision behavior.
- Do not confuse mutable *task-specific acceptance criteria* and *project technical specifications* with globally fixed agent workflow. "Fixed" is relative to a scope and change-control procedure, not the same as immutability of facts.

**Next experiment:** Propose a small, explicit header format and a separate behavior-document protocol, then run routing/resumption examples (including Keycloak/rsudo) while measuring misrouting, stale state, duplication and unnecessary workflow reload. Do not turn this example into current RumiAI normative requirements or add a second metadata system to `rumiai-dev` yet.

### Experimental repository created by operator (2026-11-07)

The operator reports creation of `massimilianonardi-ai/ai-workflow`. Connected GitHub metadata independently confirms this repository exists, with default branch `main` and repository size 0 at inspection. It is the designated **separate experimental repository** for the proposed agent-agnostic bootstrap, reusable workflow protocols and parameterized contextual state documents. No working experimental bootstrap or agreed document schema exists there yet; do not infer activation, completeness or current RumiAI authority from repository creation.

The next safe milestone is designing a minimal executable bootstrap route and a structured state-document header with explicit workflow/state references; validate direct-state resumption, routing, authority precedence, missing-source behavior and opt-in isolation before asking the operator to point a real ChatGPT Project bootstrap to it. Preserve current RumiAI canonical workflow unchanged for baseline.

### `bootstrap.md` dispatcher pilot — accepted for isolated implementation (2026-11-07)

The operator accepted the preceding design proposals for an **isolated first
implementation**; this is not activation in any ChatGPT Project, replacement
of current RumiAI authority, or promotion of a new global rule. In this experimental phase
`README.md` retains its existing name, while proposed additional files,
including `bootstrap.md`, use lowercase names; this is a task-local drafting
preference only, not a documented/general naming contract.

Current design topic: the first bootstrap dispatch should distinguish
explicit commands from natural-language input. Its route must also respect
platform-native modes (which a text-only document may not receive or
control); host slash commands such as the historical ChatGPT `/agent`
are not portable, so any experimental textual command prefix should be
unambiguous and non-conflicting. Accepted for the experimental pilot: `!aw` with an exact leading prefix,
registered verbs, explicit context options and a `--` payload delimiter.
Platform-native modes remain distinct; host compatibility must still be
validated through actual independent runs.

For natural language, evaluate a **multi-dimensional, multi-intent, open-set**
classification: user goal/interaction, task operation (research, design,
implement, reflect, review, verify, operate, resume, etc.), input/output
modality (including image generation vs image understanding), scope/state,
side effects/authorization and uncertainty. Avoid a single mutually
exclusive taxonomy or promoting a retrieved source's relevance to authority.
Recognize compound requests and unknown categories. Keep complete routing
catalogs outside the minimal bootstrap; retrieve progressively.

The operator accepted an initial **C — two-stage selective-disclosure**
implementation while comparative evaluation against alternatives remains
open. The bootstrap uses a compact dispatch and conditional registry fetch;
actual routing efficiency still requires observed real-client trials. Research input used for
this proposal includes current platform command references, open-world/
multi-label intent-detection papers and progressive-disclosure skills
documentation; these are evidence inputs, not imported authority.

The initial candidate now exists at `ai-workflow@ad76f16966131337e3c61b391d59fdc5108ffe7e`:
`bootstrap.md`, `routing/{commands.md,intents.yaml,index.yaml,resolution.md}`,
`behavior/{intent.md,decisions.md,execution.md,evidence.md}`,
`contexts/example/demo-state.md`, `evaluations/bootstrap-routing.md`, and an
updated `README.md`. This is model-readable documentation and a pilot fixture,
not a deterministic classifier, tested agent runtime, or installed bootstrap.
No ChatGPT Project Instructions or RumiAI canonical documents were changed.

## Completed

- 2026-11-07: Evaluated the user's copied response to the isolated-Project `cmd-02` prompt (`!aw route -- Progetta e implementa un server`). Visible text recognizes the command as diagnostic-only, design+develop primary intents, validation consequent, deployment undecided, significant server/environment/authorization gaps, and claims no execution. The core expected diagnostic behavior is present, but explicit modality and selected workflow-file references are absent, and the generic "GitHub" annotation is not a source-fetch trace. **Outcome: positive partial pass based on user-provided response, not an independent tool-trace-backed end-to-end pass.** Observation preserved in `ai-workflow/evaluations/results/2026-11-07-cmd-02.md` at `ai-workflow@5d4ff7cb31de61902795a15354b5428904b5a944`. No global/bootstrap changes. Next recommended fresh-chat critical case `cmd-05` (reject unknown `!aw deploy` verb).


- 2026-11-07: The operator reported that `!aw help` **works** in the new isolated ChatGPT Project configured with a pinned `ai-workflow@c9d12ce` bootstrap. This is a positive **user-reported smoke result**, not an independently inspected transcript: the actual fetched-file trace, command parser path, absence of side effects, latency and token cost were not observed. Do not score an independently verified pass from this feedback alone. Suggested immediate next case: `!aw route -- Progetta e implementa un server` in a fresh chat; expect design+develop classification and no execution.

- 2026-11-07: Prepared and published a reproducible *specification* for bootstrap validation in `ai-workflow@c9d12ce28f9948fe48625777e4d691dd8b4d5221`: `evaluations/test-cases.json` (45 prompts with expected observable behavior and forbidden actions; 24 critical-boundary cases), `evaluations/test-protocol.md` (fresh-chat isolation, paired baseline limits, 12-case initial pilot, scoring, evidence collection, unknown telemetry reporting), and fictional `contexts/example/{blocked-state.md,untrusted-state.md}` fixtures indexed in `routing/index.yaml`. The new files and README/index changes were remote-read and checked for JSON parseability, unique case IDs, pilot ID coverage, fixture references, required output assertions, historical replay gating and explicit non-execution disclosure. This does **not** represent any observed agent routing, end-to-end outcome, production operation or real historical Keycloak replay. Existing RumiAI bootstrap, specifications and product repositories were not changed.

- 2026-11-07: Implemented and remote-verified the operator-approved isolated bootstrap pilot in `massimilianonardi-ai/ai-workflow`. Published the exact-leading `!aw` textual command grammar (including diagnostic-only `route`), a compact `bootstrap.md`, open multi-intent/multimodal intent catalog, selective resolution and context index, reusable workflow-method documents, and a header-first fictional demo state. Corrected experimental `README.md` to point to the new entrypoint without implying activation. Verified the remote HEAD `ad76f16966131337e3c61b391d59fdc5108ffe7e` and ran 32 static/invariant assertions against remote-retrieved files, all passing (links, command boundary, naming, register/fixture, image generation vs understanding, evidence scope). These checks **do not** prove actual LLM intent classification, fresh-chat routing, platform-native mode support, or historical Keycloak/rsudo replay. No RumiAI live bootstrap or product behavior was modified.

- 2026-11-07: Completed a preliminary, explicitly non-binding routing/authority comparison in the operator-created `ai-workflow` repository. It was empty at preflight; committed a non-active README and `evaluations/routing-protocols.md` with hierarchy vs typed graph, direct-state/fresh-prompt traces, security/authority failures, a provisional header, falsifiable acceptance cases, and validation limits. GitHub readback verified `ai-workflow@4bf39c17c7c09c4435f24255dd640aa86b19f1cd`. This is a **design walkthrough**, not an executed resolver, historical Keycloak replay, provider integration or approved schema. Existing RumiAI rules, specifications and product code were unchanged. Concurrent `rumiai-dev@2d1cdeb` touched a chat export, not the handoff; it was preserved forward-only.


- 2026-11-06: Completed cross-document review of `README.md`, `RULES.md` and `CONSISTENCY-GATE.md`: authority/read-order, normative ownership, gate dependencies and final checklist were compared. Normalized remaining abbreviated specification paths in gate §§8 and 12 (commit `557f81516ab16bc64d7e709ffcba33abafb08993`). No contradictory authority or circular prerequisite was found in the reviewed documents; no implementation or runtime tests were needed for these documentation-only edits.

- 2026-11-06: Cross-reviewed README/RULES/CONSISTENCY-GATE ownership and clarified the diagnostics specification path in the gate (commit `0ed4e728ae6f85c9979832ef64e720f0b7436e69`). Other abbreviated specification references remain for subsequent incremental cleanup.

- 2026-11-06: Further consolidated `CONSISTENCY-GATE.md` §14 scope, proportional validation, diff integrity and handoff ownership/synchronization completion checks, retaining explicit obligations (commit `cdde0c4dbd6a80915f852768d220a56a97d3912b`).

- 2026-11-06: Continued `CONSISTENCY-GATE.md` §14 optimization by grouping behavior, diagnostics and command/library manual completion checks while retaining their individual requirements (commit `6b897ced53ecf4c214166f5097678a115c61440d`).

- 2026-11-06: Began incremental simplification of `CONSISTENCY-GATE.md` §14 by merging five preflight completion items without removing their obligations (commit `54c4cc5f882dcd45011033bdd4a35a773359cc5f`). Remaining checklist consolidation is still open.

- 2026-11-06: Optimized `CONSISTENCY-GATE.md` §§11–12: consolidated post-change review into six grouped checks and documentation consistency into six source-linked checks; normative requirements and specialized gates remain in force (commits `957cba903bb96fe73ba46cdc6c0953b019957d46`, `643ad8f89ca6aeb36b5bd333a5ad45f7d757fbcd`).

- 2026-11-06: Optimized `CONSISTENCY-GATE.md` §13 into six verification checks, preserving TODO activation, handoff ownership/synchronization and closure requirements while delegating lifecycle definitions to `todo/README.md` and `handoff/README.md` (commit `5364c5cf95eef1f52dcebc4c87424379db25b243`).

### Root README routing consolidation — 2026-11-06

- The operator confirmed that ChatGPT Project Instructions should remain a single bootstrap instruction pointing to the current `rumiai-dev/README.md`.
- Replaced the root README with a four-section routing entrypoint (mandatory workflow, authority, source routing, documentation ownership), preserving preflight and final consistency obligations and delegating specialized procedures to their canonical sources.
- README update commit: `e133db42a6c8be44b88ed490f5706ea97b50bc68`. No product/runtime changes.



### Opt-in `devplan` procedure — 2026-11-04

The exploratory executable-planning proposal was promoted into the dedicated root `DEVPLAN.md` current workflow contract, including exact opt-in activation, source-first insufficiency verdicts, progressively detailed work units, dependency/parallelism rules, clean-chat validation and planning-only authorization. The root router and `RULES.md` reference that single normative owner. This documentary change does not prove future assistant behavior.

### First `devplan` insufficiency smoke test — 2026-11-04

A separate project chat invoked `devplan astronave`. The assistant recognized the exact opt-in token, retrieved current RumiAI authority including `DEVPLAN.md`, and returned `Specifiche insufficienti` without inventing a spacecraft architecture or presenting executable work units. This is one observed conversational example, not a deterministic parser test, a proof of behavior across all clean chats, or validation of the sufficient-specification/agent-ready planning path.

### Code maintainability and scope gate

The explicit user correction that working code must also be readable, bounded in responsibility, easy to modify, extensible and reusable was promoted as a completion criterion into `RULES.md`. `CONSISTENCY-GATE.md` now requires pre-implementation and post-change human review of those properties and of strict adherence to the authorized scope. No product code or deferred bootstrap TODO was changed.

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

- `cmd-02` now has a **single, user-supplied response observation**: correct core routing and uncertainty handling, missing explicit workflow ref and modality reporting, retrieval/side-effect trace unavailable. See `ai-workflow/evaluations/results/2026-11-07-cmd-02.md`. More cases should be observed before modifying the router.


- New ChatGPT Project smoke observation: operator reports `!aw help` working under pinned experimental bootstrap; detailed trace/evidence still unavailable. Proceed with isolated multi-intent routing dry-run next.


- The experimental bootstrap has a now-published **evaluation plan**, but remains unvalidated: 45 documented cases, 24 marked critical, a first 12-case pilot, and test-only missing-dependency/untrusted-state fixtures. `historical-01` remains a nonrunnable placeholder until original dated sources are retrieved. The test plan itself has been statically checked; independent model/client trials and RumiAI baseline comparisons have not been performed.

- The opt-in `ai-workflow` bootstrap pilot is now **published**, not activated. Entry: `ai-workflow/bootstrap.md` at `ad76f169`. Its commands and routing catalog are experimental; all 32 static checks passed and no real clean-chat route has yet been observed. The next action is an independent agent/client test and historical Keycloak replay, not more speculative taxonomy expansion.

**2026-11-07 experiment checkpoint:** `ai-workflow` contains an explicitly inactive `README.md` and `evaluations/routing-protocols.md`. Neither candidate routing policy has been selected or tested in an independent clean chat; no executable bootstrap, resolver, source-pinned historical Keycloak/rsudo replay or agent-adapter validation has been completed. The current RumiAI bootstrap remains authoritative for baseline work.

The original GitHub chat mirror is now disabled at the user's explicit request. Its pre-existing transcript is retained only as a non-authoritative, frozen archive; the active current chat mirror has moved to Google Drive under `ChatGPT/chats/2026-10-14-chat-mirror/`. Google Drive Markdown and the PNG asset were uploaded and verified; the local cumulative chat snapshot progressed to `0005`, with `0006` next. No unattended updates, PDF or invisible intermediate buffers are authorized. Evaluate multi-turn reliability and image rendering from real use.

The new code-maintainability and scope gate is current canonical workflow; it must be exercised on future implementation tasks rather than treated as a claim that legacy code already complies.

`workflow-optimization` remains active.

The `devplan` planning-only procedure is now canonical in root `DEVPLAN.md` and routed by `README.md` and `RULES.md`. One separate-chat under-specified invocation (`devplan astronave`) returned the expected gap verdict without fictional design. The positive sufficiency case, independently executable plan quality, and cross-chat agent resumption remain untested.

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

**Immediate next action after first user-observed diagnostics:** Continue the 12-case clean-chat pilot, starting with `cmd-05` unknown-command safety boundary, then the remaining cases; collect actual command/file traces if available. Execute and log the pilot in an isolated, opt-in agent/client setup using `ai-workflow@c9d12ce`. Distinguish host-native interception and image/attachment prerequisites from routing failures. Run only applicable natural-language cases under the unchanged RumiAI baseline, compare observable outcomes/clarifications and source-load costs, and independently score every critical boundary. If no real client execution is available, mark cases `not_run` rather than claiming passes. Expand to the other suite cases after an evidence review. The historical Keycloak/rsudo test is blocked until the original operator prompt, task state and contemporary source revisions have been independently recovered; no current corrected documents may substitute for them. Activation/promotion needs explicit authorization and measured success.

Previously recorded work: next exercise `DEVPLAN.md` on a genuinely well-specified RumiAI software task. Check source-first sufficiency, dependency and work-unit completeness, non-conflicting agent ownership, clean-chat resumability and the planning-only boundary. The under-specified `devplan astronave` conversational smoke test is recorded above; neither case alone proves future agent execution.

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
14. apply the code-maintainability and scope gate to upcoming implementation tasks and verify that ordinary small changes stay locally understandable.
15. keep the per-chat Google Drive + downloadable attachment mirror disabled following the user's explicit instruction; on a later authorized reactivation, evaluate update reliability, image links, ordering, retry semantics and latency. Do not consider always-on behavior without real observations.

## Blockers / open questions

`devplan` has one separate-chat under-specified conversational smoke test but no verified positive-case executable plan or independent agent-resumption test. It is a repository-routed assistant convention, not a native platform command, deterministic parser or background execution trigger.

The mirror was explicitly deactivated for this conversation on 2026-10-15; no `0009` snapshot or new Drive update should be generated until reactivation. The user separately confirmed that the periodic Drive→GitHub copy did not work and was deleted; that scheduled copy is discontinued and must not be silently recreated. The earlier automation inspection already showed no active archive task. Neither change alters the retained archive files.

The opt-in chat mirror targets Google Drive and progressive response attachments. The temporary failure to upload `0007` (`container_session_expired`) was resolved in the following interaction: Drive `chat.md` was re-fetched and verified at `0008`, including both the missed and current user prompts. The next response attachment should be `0009`. Monitor reliability across future turns; this successful recovery does not prove a mandatory system-level per-turn gate. The previous turn with the Google Drive infographic was not synchronized at the time; the subsequent status check found this lapse and recovered that turn plus the latest user question into the Drive Markdown. The user's earlier request to delete the legacy GitHub mirror file was not executed; the old file remains frozen and its removal is a pending action, notwithstanding the separately deactivated mirror. A first in-place Drive update of `chat.md` and an image upload have been confirmed; multi-turn failure recovery and Drive-hosted Markdown image rendering remain to be observed. The former GitHub chat archive is frozen rather than deleted, to preserve historical transcript content not included in the later attachment series. PDF, polling/background synchronization and site-specific exporter implementation remain out of current scope.

None blocking current workflow use. The adaptive cooperation model remains deliberately non-canonical while it is exercised on real cases; the six-point core is the candidate for later joint review/promotion. Current command/library manual backfill belongs to `handoff/rumiai-os-man-documentation.md`; legacy library API visibility realignment is represented by `todo/library-api-visibility-realignment.md`. Diagnostic legacy migration is represented by `todo/diagnostic-observability-realignment.md`; subprocess log-level propagation/reduction remains an analysis item in `todo/log-level-child-propagation-analysis.md`.
