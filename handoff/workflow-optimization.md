# workflow-optimization

Status: Active
Updated: 2026-10-15

## Goal

Maintain a long-lived meta-workstream for continuously evaluating and improving the RumiAI development workflow: retrieval, documentation organization, Project Instructions, handoffs, deferred-work visibility, specification promotion, command/library manual consistency, parallel work, repository coordination, testing/validation workflow and other mechanisms that affect how work is performed and resumed.

## Current repository revisions

```text
rumiai-dev    3ce3ddb53fec4c0bac726101ed5e95dd0979ae4e  (pre-handoff HEAD with code-maintainability rule and gate)
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


- The user has disabled GitHub chat mirroring and explicitly selected **Google Drive** as the opt-in remote mirror destination. Preserve the existing GitHub transcript as a legacy, non-authoritative archive but never append new chat turns to it.
- The active per-chat Google Drive folder is `ChatGPT/chats/2026-10-14-chat-mirror/` (Drive folder ID `1giqQeQ0wAHKM8dVTrDiOaTSSP2FIP4Ro`); its stable Markdown mirror is `chat.md` (Drive file ID `10D-cAJNqPvquHsmk94n6nt0SFb9h8Pwj`), with media in the same folder (current PNG ID `19jFplZPhSvqe-dU7Mh2GSFu91-dvIa14`).
- **`attiva chat mirror`** and **`disattiva chat mirror`** activate or deactivate *both* the Google Drive Markdown mirror and the user-delivered cumulative Markdown attachment for that chat. They do not configure an always-on global feature or create a background process.
- **Current chat state (2026-10-15, 12:28 Europe/Rome): OFF.** The user explicitly requested `disabilit il mirror`; stop both per-turn outputs immediately: no new attachment version and no Google Drive Markdown/media update for this deactivation exchange or later turns until explicit reactivation. Existing snapshots and Drive archive remain untouched. Resume at `0009` only if explicitly reactivated.
- Keep increasing attachment filenames: `rumiai-chat-20261014-0001.md` through `0008.md` have been prepared locally; `0009.md` is next. The previous failed `0007` Drive update was reconciled by an in-place verified update to `0008` during the 2026-10-15 turn. Each response also reoffers previously generated images as downloads and includes links to them in Markdown.
- Maintain one live `chat.md` file in Google Drive, updating its existing Drive ID in place using `mcp__Google_Drive__update_file` with a generated file reference. The Library `overwrite=true` upload path was tested and is not supported for Google Drive; do not use it to update the same file. Initial creation and colocated PNG upload via the files Library/Google Drive path succeeded.
- Markdown plus linked media is the accepted format. Google Drive is remote persistence and chat attachments are explicit delivered versions; no hidden buffering, periodic synchronization or PDF. Report separate per-destination successes/failures without silently treating them as equivalent.
- **Scheduled Drive → GitHub archive copy: discontinued.** The user reports the hourly scheduled copy did not work and explicitly deleted it on 2026-10-15. Do not treat this automation as installed, active or reliable, and do not recreate it without a new explicit request. This is separate from the already-disabled per-turn chat mirror. The attempted copy had targeted the public `massimilianonardi-ai/rumiai-dev` repository; the previous configuration is historical task context only, not a current workflow.
- Chat archive content is non-normative RumiAI history. The old GitHub transcript includes earlier activation-era messages, but the Drive/attachment series begins with the numbered snapshot 0001; do not assert complete retroactive migration of the earlier turns.

## Working design

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

## Completed

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

The original GitHub chat mirror is now disabled at the user's explicit request. Its pre-existing transcript is retained only as a non-authoritative, frozen archive; the active current chat mirror has moved to Google Drive under `ChatGPT/chats/2026-10-14-chat-mirror/`. Google Drive Markdown and the PNG asset were uploaded and verified; the local cumulative chat snapshot progressed to `0005`, with `0006` next. No unattended updates, PDF or invisible intermediate buffers are authorized. Evaluate multi-turn reliability and image rendering from real use.

The new code-maintainability and scope gate is current canonical workflow; it must be exercised on future implementation tasks rather than treated as a claim that legacy code already complies.

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
14. apply the code-maintainability and scope gate to upcoming implementation tasks and verify that ordinary small changes stay locally understandable.
15. keep the per-chat Google Drive + downloadable attachment mirror disabled following the user's explicit instruction; on a later authorized reactivation, evaluate update reliability, image links, ordering, retry semantics and latency. Do not consider always-on behavior without real observations.

## Blockers / open questions

The mirror was explicitly deactivated for this conversation on 2026-10-15; no `0009` snapshot or new Drive update should be generated until reactivation. The user separately confirmed that the periodic Drive→GitHub copy did not work and was deleted; that scheduled copy is discontinued and must not be silently recreated. The earlier automation inspection already showed no active archive task. Neither change alters the retained archive files.

The opt-in chat mirror targets Google Drive and progressive response attachments. The temporary failure to upload `0007` (`container_session_expired`) was resolved in the following interaction: Drive `chat.md` was re-fetched and verified at `0008`, including both the missed and current user prompts. The next response attachment should be `0009`. Monitor reliability across future turns; this successful recovery does not prove a mandatory system-level per-turn gate. The previous turn with the Google Drive infographic was not synchronized at the time; the subsequent status check found this lapse and recovered that turn plus the latest user question into the Drive Markdown. The user's earlier request to delete the legacy GitHub mirror file was not executed; the old file remains frozen and its removal is a pending action, notwithstanding the separately deactivated mirror. A first in-place Drive update of `chat.md` and an image upload have been confirmed; multi-turn failure recovery and Drive-hosted Markdown image rendering remain to be observed. The former GitHub chat archive is frozen rather than deleted, to preserve historical transcript content not included in the later attachment series. PDF, polling/background synchronization and site-specific exporter implementation remain out of current scope.

None blocking current workflow use. The adaptive cooperation model remains deliberately non-canonical while it is exercised on real cases; the six-point core is the candidate for later joint review/promotion. Current command/library manual backfill belongs to `handoff/rumiai-os-man-documentation.md`; legacy library API visibility realignment is represented by `todo/library-api-visibility-realignment.md`. Diagnostic legacy migration is represented by `todo/diagnostic-observability-realignment.md`; subprocess log-level propagation/reduction remains an analysis item in `todo/log-level-child-propagation-analysis.md`.
