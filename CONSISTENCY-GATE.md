# RumiAI Development Consistency Gate

Status: **Current / canonical**  
Updated: 2026-11-06

This document defines the mandatory consistency process for RumiAI work. Its purpose is to prevent drift between current rules, current specifications, implementation, tests, operational documentation, deferred work and active task state.

## 1. Mandatory preflight

Follow the mandatory workflow and authority hierarchy in `README.md` before analysing, proposing or modifying RumiAI work. This gate adds the following task-specific source requirements to that preflight:

- For a `m`- or RumiAI-owned directly executable command being created, renamed, removed or modified, read `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`, `specifications/rumiai-os/DOCUMENTATION-MODEL.md` and the affected operational manual topic.
- For a `m`- or RumiAI-owned library or function being created, renamed, removed or modified, read `specifications/rumiai-os/FILESYSTEM-NAMING.md`, `specifications/rumiai-os/LIBRARY-INTERFACES.md`, `specifications/rumiai-os/DOCUMENTATION-MODEL.md` and the affected library manual topic.
- For changes to handled failure branches, return/exit statuses, diagnostics, log severity/level behavior or significant runtime observability, read `specifications/rumiai-os/DIAGNOSTICS.md`.
- Read `todo/README.md` and the relevant TODO item when selecting deferred work, checking an already known deferred issue, activating a TODO or maintaining the pending-work inventory. Unrelated tasks do not require reading `todo/`.

These sources are mandatory whenever their respective conditions apply; they supplement rather than replace the README preflight.

## 2. Extract the applicable invariants

Before writing, identify the fixed constraints that apply to the task, including as relevant:

```text
architecture/layer boundaries
canonical terminology
existing primitives
public interfaces
command/manual consistency
library public/internal visibility and manual consistency
filesystem layout
state/resource/package ownership
POSIX/platform contract
shell/interpreter rules
serialization/data formats
exit statuses and error classes
diagnostic identity, context and observability
permissions/security boundary
transaction/concurrency semantics
testing and evidence requirements
Git workflow
active task-local decisions
explicit current user corrections
```

Reason inside those constraints before choosing an implementation.

### Intent and operability gate

For any public, operator-facing or otherwise user-visible behavior, apply this gate before implementation:

1. state the primary goal in implementation-independent terms;
2. write a small set of realistic normal-path interactions that should accomplish that goal;
3. identify the knowledge boundary: what the caller reasonably knows or deliberately chooses versus what the system can reliably discover or derive;
4. identify any semantic delta that adds caller knowledge, worsens discoverability, adds an avoidable step, changes a default or introduces a surprising restriction;
5. reject an implementation-driven restriction unless it is an explicit current contract decision.

Normal-path scenarios are design constraints, not decorative examples. A design fails this gate when the ordinary goal requires provider-specific, revision-specific or internal knowledge that the system can reliably resolve, except where the caller is deliberately requesting an exact pin, override or similarly explicit advanced choice.

Before reporting user-facing work complete, exercise the primary workflow through the public interface from the perspective of a caller who knows the problem domain but not the implementation. Passing internal/component tests does not compensate for failure of this operability check.

While behavior remains unsettled, keep the acceptance scenarios in the active handoff. Once promoted, express the durable behavior in the applicable current specification rather than maintaining a shadow workflow contract.

### Code maintainability and scope gate

For work that creates, ports or changes code, apply the code-quality contract in `RULES.md` both before implementation and when reviewing the resulting diff:

1. Confirm the design does only the authorized work; a port retains the original model unless a concrete change was explicitly authorized.
2. Identify the responsibility and interface of each changed module/function; reject avoidable mixing of unrelated concerns, duplication and speculative abstraction.
3. Read the code for clarity, not only for behavior: names, control flow and dependencies should be understandable without mentally untangling compressed or opaque constructions.
4. Test changeability by considering one realistic small follow-up modification. A maintainer should be able to find the relevant code and change it without restructuring an unrelated part.
5. If the structural review fails, revise the implementation even when all automated tests pass. Do not implement a deferred TODO as a side effect of the current task.

This is a human design review. It must not be replaced by line-count thresholds or claims that automated checks prove readability.


## 3. Current-source and specification-promotion gate

Verify that the current canonical sources directly express the applicable contracts, following the documentation model in `RULES.md`.

Before accepting a documentation or implementation change:

1. Confirm that each affected contract has one canonical maintenance location.
2. Confirm that the current contract can be understood without composing historical decisions, later corrections or task handoffs.
3. When a contract changes, verify that its canonical specification is updated and superseded current material is removed after durable content is propagated.
4. If implementation and specification disagree, explicitly determine whether implementation requires realignment or an authorized contract change is intended.
5. Before adding content to `specifications/`, verify that it is a settled, binding current contract owned by that specification, not provisional design, an open question or deferred work.
6. If a specification intentionally leaves a dimension unconstrained, verify that this is a stable contractual boundary and does not introduce candidate choices or future planning.
7. Route non-promoted material to the appropriate active handoff, experiment or deferred-work record, without creating competing normative sources.

A failed check must be resolved or reported explicitly; do not silently promote provisional material or infer current authority from historical evidence.

## 4. No silent design changes

If a proposed implementation contradicts a fixed invariant, stop treating the difference as an implementation detail.

A deliberate contract change must be made explicit and propagated to the canonical current specification in the same work unit whenever possible.

Do not reopen an already-settled choice merely because another design is locally convenient.

## 5. Existing responsibility first

Apply the reuse and naming rules in `RULES.md` before introducing a helper, alias, primitive, namespace, component, suffix, format or abstraction:

1. Search the current subsystem for the existing owner of the same semantic responsibility.
2. Compare its contract with the proposed use; reuse it when the contracts match.
3. If a new responsibility is genuinely required, verify that it does not create a competing spelling or duplicate ownership.

## 6. Conversational shorthand has no product authority

Temporary wording, abbreviations and labels used in conversation are not automatically product terminology.

Do not promote them into commands, APIs, namespaces, components, filesystem names, configuration keys or architecture concepts unless the user or a current authoritative source explicitly establishes them.

## 7. Correction propagation

When a fixed invariant changes, inspect all materially dependent current surfaces:

```text
canonical specification
implementation
operational manual/reference
permanent tests
reference descriptors/examples
active handoff
relevant deferred-work TODO
validation scope/configuration
user-facing current documentation
```

Update every surface that belongs to the same authorized work unit. When another repository or validation phase cannot be changed yet, record the pending realignment explicitly in the appropriate current surface.

If the remaining work is concrete but intentionally deferred and is not already active, represent it through the minimal `todo/` lifecycle rather than burying it in a specification, historical note or conversation memory.

If a design choice remains unresolved inside the active task, keep it in the handoff working-design state rather than turning the unresolved choice into a pseudo-contract.

Do not rewrite historical commits or historical validation evidence.

### Diagnostics and observability gate

For every created or modified failure-handling path, apply `DIAGNOSTICS.md` before considering the code complete.

Verify, as applicable:

```text
each distinct handled failure branch has a distinct local non-zero status
new local statuses were allocated incrementally without renumbering established codes
child failures are mapped to the caller's local branch unless exact pass-through is intentional
each logged failure branch has a distinguishable semantic diagnostic identity
the diagnostic includes the non-sensitive context needed to investigate that occurrence
significant lifecycle/decision/propagation state is visible at proportional info/debug/trace levels
logging omissions have a concrete bootstrap, recursion, performance, protocol/output or security reason
one underlying failure is not redundantly emitted as equivalent error/fatal messages at every layer
secrets and protected values are not exposed by diagnostic fields
```

A generic diagnostic identity reused across different branches with only a varying `reason` field fails this gate when the emitting branch cannot be located directly from the diagnostic identity and context.

For established code, do not mechanically renumber public or consumed statuses merely to make legacy code look sequential. Such realignment requires an explicit audit of callers, tests and manuals.

## 8. Command/library manual consistency gate

For each affected `m`- or RumiAI-owned command or library, verify the operational-manual and library-visibility contracts in `RULES.md`, `DOCUMENTATION-MODEL.md` and, for libraries, `LIBRARY-INTERFACES.md`:

1. Confirm that every required command or library manual topic exists at its owner-local location and has the correct identity; independently packaged references remain package-local.
2. For a created, renamed or removed command or library, confirm that its manual topic was created, realigned or removed in the same work unit.
3. For every modified command, compare its documented purpose, invocation, operands, options, output, exit statuses, environment/files, side effects and other observable behavior against the implementation. Update the manual when these change; record that an internal-only change leaves it accurate otherwise.
4. For every modified library, verify public/internal function classification and underscore naming. Confirm that the manual documents the complete public interface, excludes internal functions as callable API, and is updated in the same work unit for any public-function addition, removal, rename or contract change.
5. Verify that permanent tests mechanically protect required command-to-manual and library-to-manual topic presence and identity. These structural checks do not prove semantic correctness of the prose or API descriptions.

If required permanent coverage is missing or out of date, keep the documentation-completeness work explicitly open. Do not report a command or library work unit complete while a required topic is missing, its manual disagrees with implementation, or library visibility and naming disagree.

## 9. Testing authenticity

Verify each behavioral validation claim against the authenticity contract in `TESTING.md`:

1. Identify the exact property claimed and the target execution path that supplies it.
2. Confirm that the test exercises the real target or a complete isolated replica through that path.
3. Identify any mocks, fixtures, stubs or synthetic inputs; verify that each simulated boundary is permitted and that the claim is limited to what was actually exercised.
4. Confirm that automation infrastructure (including GitHub Actions and AI-provided VMs) has not been treated as a substitute for the target or its testing contract.

Do not credit a test with proving a composed behavior when its relevant execution path was replaced.

## 10. Proportional validation

Verify the validation sequence and evidence against `TESTING.md` and `PHYSICAL-TESTING.md`:

1. Confirm that development checks use the fastest real environment capable of materially exercising each claimed property, expanding to clean or multi-host automation where useful.
2. Before physical validation, confirm that earlier evidence makes success the expected outcome and that the required reference-host scope is identified.
3. Attribute every result to the actual host and revision exercised; do not label GitHub-hosted runners, headless GUI sessions or AI-provided VMs as physical validation of a different reference host.
4. If defects repeatedly appear first during physical validation, identify and strengthen the earlier checks that should have exposed them.
5. Confirm that no GitHub required status check or automatic merge gate was introduced without an explicit new decision.

## 11. Post-change diff review

After every modification, reread the resulting diff and verify:

1. **Contract and scope:** the change respects `RULES.md`, applicable current specifications, authorized scope and existing responsibilities; code remains maintainable and a realistic small future change stays understandable.
2. **Behavior and design:** user-visible changes pass the intent/operability gate (§2); changed specifications pass the promotion gate (§3); no obsolete terminology or mechanisms remain in the touched subsystem.
3. **Specialized consistency:** changed diagnostics/observability satisfy their gate; affected commands and libraries pass the manual/visibility gate (§8); documentation changes pass §12.
4. **Validation:** tests are proportional and evidence is limited to what was exercised under `TESTING.md`; physical-validation status is reported accurately for the actual revision and hosts.
5. **Repository integrity:** unrelated or concurrent user changes were preserved and Git history remains forward-only.
6. **Continuity:** unfinished deferred work is recorded once under `todo/` or its active owner; an active handoff is synchronized before the final response when the change is a material checkpoint (§13).

## 12. Documentation consistency checks

When documentation is touched, apply the current-source and specification-promotion gate (§3), the applicable command/library manual gate (§8), the deferred-work and handoff gate (§13), and the diagnostics requirements in `RULES.md` and `DIAGNOSTICS.md`. Additionally verify:

1. Current documents do not assert superseded contracts or rely on historical decisions to establish current meaning; completed handoffs and historical evidence do not compete with current authority.
2. `README.md` and `specifications/README.md` route directly to the correct current owner, and all affected cross-references resolve to paths in the current tree.
3. Repeated normative text is minimized, and no provisional design is promoted into a current specification.
4. Affected operational manuals remain revision-consistent with command/library implementation and public API; required topics, library visibility and structural coverage are checked under §8.
5. Changed failure statuses, diagnostic identities and observability remain consistent with `DIAGNOSTICS.md`, without flattening distinct failure branches.
6. TODOs contain only deferred work and do not duplicate an active handoff for the same responsibility.

## 13. Deferred work and active handoffs

Verify deferred-work and active-task ownership against `todo/README.md` and `handoff/README.md`:

1. Confirm that a TODO describes only concrete, intentionally deferred work with minimal intent, reason, scope and evidence pointers; it must not carry active design or execution state.
2. Before material changes to a substantial, parallel or multi-chat task, identify its active handoff owner. Reuse an existing handoff for the same resumable responsibility unless a genuinely independent goal, state, blockers, validation and completion lifecycle warrants a separate owner. A narrower label alone does not justify splitting work; parent and child must not duplicate operational state.
3. When activating a TODO, verify that its active state moves to a handoff and the TODO is removed in the same authorized work unit, preferably the same commit. Do not leave competing active representations.
4. Treat handoff working design as non-authoritative task state. Before closure, verify that each remaining item is promoted to its canonical specification, deferred to a TODO or discarded.
5. When an active task materially advances, confirm that its handoff is synchronized before the final user-visible response.
6. At task closure, verify durable propagation, resolution of working design, capture of applicable deferred work, and the final consistency gate. Commit a final handoff snapshot marked `Status: Complete`, then remove it in a later forward commit; Git history retains the archive.

## 14. Completion checklist

A RumiAI task is ready to report as complete only when every applicable item is true:

```text
[ ] current remote HEADs were verified before writes; README.md routed retrieval; current RULES.md, CONSISTENCY-GATE.md, relevant specifications, active handoff and implementation/tests were read
[ ] applicable invariants were identified before writing
[ ] for user-visible behavior, the primary goal and realistic normal paths were identified before implementation
[ ] the caller/system knowledge boundary was checked and avoidable implementation knowledge was not pushed onto the caller
[ ] surprising user-visible restrictions or added steps were treated as explicit semantic decisions rather than incidental implementation consequences
[ ] the resulting primary public workflow was exercised from the user/operator perspective when applicable
[ ] changed code was reviewed for clear, bounded module/function responsibilities, readable flow and a realistic small future modification
[ ] code changes stayed within the authorized scope; deferred TODO work and speculative mechanisms were not implemented
[ ] no existing responsibility was duplicated under a new name
[ ] no contract was changed silently
[ ] every statement added to a current specification passed the specification promotion gate
[ ] every affected failure branch has a distinguishable local status unless an explicit pass-through/external-status contract applies
[ ] established status codes were not renumbered merely to preserve source order
[ ] every logged failure branch has a branch-specific diagnostic identity and sufficient non-sensitive context
[ ] significant flows have proportional info/debug/trace observability or a concrete justified logging omission
[ ] failure propagation does not create redundant equivalent error/fatal logs or leak secrets
[ ] every affected command has its required manual and passed a manual-consistency check
[ ] every affected library has its required manual and passed a manual-consistency check
[ ] every affected library function follows the public/internal leading-underscore contract
[ ] each library manual exposes all public functions and no internal function as callable API
[ ] mandatory command/library manual structural coverage is present or the corresponding completeness work remains explicitly open
[ ] tests/evidence claim no more than what was actually exercised
[ ] resulting diff was reread and stale terminology/mechanisms were scanned
[ ] cross-references/current routing remain valid
[ ] user/concurrent repository changes were preserved
[ ] proportional tests were run or correctly classified as unnecessary
[ ] concrete intentionally deferred work is represented once under todo/ when applicable
[ ] no current TODO duplicates an active handoff for the same work
[ ] before creating a new handoff, existing active handoff ownership was checked by resumable responsibility
[ ] no parallel handoff duplicates an existing task lifecycle merely under a narrower or different label
[ ] parent/child handoffs, when justified, do not duplicate active operational state
[ ] active handoff was synchronized for every material checkpoint before the final response
[ ] physical-validation status is stated accurately
[ ] Git changes are forward-only
```

Failure of an applicable item means the work is not complete.
