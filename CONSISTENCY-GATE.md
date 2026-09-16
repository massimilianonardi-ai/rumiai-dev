# RumiAI Development Consistency Gate

Status: **canonical development rule**  
Date: 2026-08-30  
Updated: 2026-09-16

This document defines the mandatory consistency gate for work on RumiAI.

Its purpose is broader than preventing one naming mistake: it exists to prevent any implementation, documentation or architectural drift from rules and decisions already fixed in the authoritative project material.

`rumiai-dev` is authoritative. Conversation memory, summaries, implementation convenience, model assumptions and newly drafted terminology never override an existing canonical decision.

---

## 1. Mandatory authority preflight

Before analysing, proposing or modifying an established RumiAI subsystem, the change author MUST retrieve the current authoritative material relevant to that task.

At minimum:

1. current `rumiai-dev/RULES.md`;
2. this `CONSISTENCY-GATE.md`;
3. the active architecture/specification/handoff documents for the touched subsystem;
4. the current remote HEAD of every repository that may be changed;
5. the permanent tests protecting the touched subsystem, when they exist.

This is an execution precondition, not a recommendation.

Remembering a rule is not equivalent to reading the current rule. A conversation summary is not a substitute for repository retrieval when the repository can answer the question.

If the preflight has not been performed, implementation work is not ready to start.

---

## 2. Applicable-rule extraction

After the preflight and before writing, identify the rules and invariants that constrain the specific task.

Depending on the change, these include:

```text
architecture boundaries
product/component terminology
names and namespaces
public/private API spelling
file and directory naming
serialization/data formats
filesystem layout and path rules
POSIX/platform contract
exit statuses and error classes
ownership/mode rules
transaction semantics
Git workflow
physical-validation requirements
testing policy
previous explicit user corrections
```

The purpose is not to restate the entire project. It is to make the relevant constraints explicit before choosing an implementation.

---

## 3. No silent rule changes

If a proposed solution would contradict or modify an established rule or invariant, that is a design change, not an implementation detail.

It MUST NOT be introduced silently.

The conflict must be surfaced before implementation and, where the project workflow requires it, explicitly approved before the established rule is changed.

Local convenience is never sufficient reason to reinterpret an existing decision.

---

## 4. Conversational language has no design authority

Abbreviations, shorthand, temporary labels and informal wording used in conversation are not automatically product terminology.

They MUST NOT be promoted into:

```text
component names
commands
executables
interpreters
namespaces
APIs
filesystem names
configuration keys
architecture concepts
```

unless the user or an authoritative project document explicitly establishes them as such.

When terminology is uncertain, retrieve the canonical project vocabulary instead of inferring a new concept from conversational wording.

The product name is `RumiAI` and existing canonical repository/component names remain exactly as specified by the project.

---

## 5. Existing primitive first

Before introducing a new helper, alias, namespace, suffix, format, component or abstraction, search the current subsystem for an existing primitive with the same semantic role.

Rule:

> reuse the established primitive when its contract already matches the requirement.

A new name must not be invented merely to expose an existing function through another spelling.

Example:

```text
existing: path_canonicalize_existing
wrong:    path_canonicalize_existing_api
```

unless a genuinely different contract has first been specified.

---

## 6. Naming consistency

For RumiAI-owned **environment variables**, the canonical namespace is:

```text
m_*
```

This rule applies only to environment variables. It does NOT establish a general `m_*` namespace for functions, local/internal shell variables, commands, files, APIs, components or other product objects.

Standard host/environment variables such as `PATH` and `SHELL` retain their standard names.

Separately specified unnamespaced shell interfaces currently include:

```text
log
lang
```

The previous bootstrap/API name `i18n` is superseded by `lang`.

No project-wide namespace for RumiAI shell functions is currently fixed. A future function namespace or broader naming convention requires an explicit project decision and MUST NOT be inferred from the environment-variable convention.

---

## 7. Correction propagation

When an established invariant is corrected, the same work unit must inspect and, where applicable, update all of:

```text
canonical specification
current implementation
permanent tests
examples/reference descriptors
physical-validation documentation
related active drafts that consume the interface
handoff/current-state material
```

After propagation, scan the affected active subsystem for the superseded pattern.

A correction is not complete when only the file where the inconsistency was noticed has changed.

Historical Git commits and immutable validation evidence are not rewritten. Current documentation must distinguish historical evidence from current rules without re-promoting obsolete terminology.

When implementation or permanent-test changes require a separate authorized work phase, the current authoritative documentation MUST state that the affected implementation/tests are pending realignment rather than treating their old behavior as current authority.

---

## 8. Minimal-change rule

An implementation change must solve the requested problem without opportunistically introducing unrelated conventions or abstractions.

In particular:

- do not create aliases that are not required;
- do not invent product/component names from shorthand;
- do not generalize a physical namespace before a real use case exists;
- do not replace an established mechanism with a locally preferred one without an explicit architectural decision;
- do not reinterpret a previously fixed term as a new concept;
- do not turn implementation convenience into a project convention;
- do not add defensive checks that duplicate the semantics of the operation they guard unless the extra check has a distinct required contract.

---

## 9. Mechanical enforcement where possible

Rules that can be checked mechanically at reasonable cost should be protected by permanent tests or equivalent deterministic checks.

Mechanical tests are supplements to the authority preflight, not substitutes for it.

Many project rules are semantic and cannot be reduced to a grep pattern. The existence of passing tests never authorizes ignoring the canonical documents.

For behavioral tests, mechanical enforcement must preserve the authenticity of the target required by `TESTING.md`: the test may isolate or replicate the real system, but must not replace components of the system under test and then count the result as validation of the real composed behavior. A test based on an explicitly permitted simulation protects only the property actually exercised through that simulation.

Automation environments, including GitHub Actions or an AI-provided execution VM, must invoke the real permanent tests or the real target path appropriate to the task. They are execution infrastructure, not alternative implementations of the test contract.

---

## 10. Post-change consistency scan

Before declaring work complete, perform a subsystem-wide consistency check appropriate to the change.

At minimum verify:

```text
no superseded/forbidden active terminology remains
new public names match authoritative terminology
call sites and tests use current interfaces, or are explicitly recorded as pending realignment
behavioral tests exercise the real target or a complete isolated replica through real entrypoints/components
permitted simulations do not substitute the target behavior being claimed as validated
auxiliary/hosted execution environments are not mislabeled as required physical-host validation
GitHub Actions, when touched, orchestrates real tests rather than duplicating their semantics
no GitHub required status check or automatic merge gate is introduced without a new explicit decision
physical validation is used as final confirmation rather than routine first-line debugging
file modes are correct, especially executable tests/commands
serialization/layout still matches active specifications
no accidental host-specific dependency was introduced
no already-fixed rule was silently reinterpreted
current remote HEAD was used for every write
Git history remains forward-only
```

If a mismatch is found, the work is not complete.

---

## 11. Physical validation discipline

A semantic implementation change that requires physical validation must be validated on the current stable reference installations according to the testing contract.

When the validation claim concerns observable behavior of a command, subsystem or composed pipeline, the physical test must exercise the real target or a complete isolated replica of the exact target revision through its real execution path. Fixture-only, mocked or partially reconstructed executions do not validate a real path that they replaced.

Physical validation is the final confirmation stage for a work unit that is already expected to be complete and functioning based on the preceding real executions and permanent tests that are materially applicable. Development hosts, auxiliary environments and GitHub-hosted runners should be used earlier when they can discover defects or portability problems without consuming the final physical gate.

The normal expectation is that most physical validations pass on the first attempt. An occasional failure may reveal a property that only the physical host can expose; a recurring pattern in which functional defects are discovered first during physical validation is evidence that the earlier testing model is insufficient and must be strengthened rather than accepted as normal workflow.

A GitHub-hosted runner, an AI-provided Linux VM or a headless GUI environment is not physical validation of a stable reference installation that it did not actually exercise.

Pure naming/documentation corrections should normally be bundled into the next meaningful physical gate rather than imposing repeated operator work, unless the correction itself changes observable execution behavior or prevents existing tests from exercising the code.

Previously recorded evidence remains evidence for the exact revisions that were exercised. Documentation must not silently relabel old evidence as validation of a later untested revision or as evidence for a stronger property than the test actually exercised.

---

## 12. No memory-only continuation

When continuing RumiAI work, repository retrieval is the default whenever a current rule, decision, name, boundary or implementation detail can materially affect the answer.

This applies even when the remembered answer seems likely.

The required sequence is:

```text
retrieve authority
→ extract applicable invariants
→ reason within those invariants
→ implement
→ verify consistency
```

not:

```text
remember approximately
→ implement
→ repair drift later
```

---

## 13. Completion checklist

A change to an established subsystem is ready to be reported as complete only when every applicable item is satisfied:

```text
[ ] current RULES.md was retrieved
[ ] current CONSISTENCY-GATE.md was retrieved
[ ] relevant active specifications/handoffs were retrieved
[ ] current remote HEADs were verified
[ ] relevant permanent tests were inspected
[ ] applicable rules/invariants were identified before writing
[ ] no canonical rule changed silently
[ ] no conversational shorthand was promoted into product terminology
[ ] existing primitives were reused where semantically equivalent
[ ] code follows established naming/layout/format/platform rules
[ ] behavioral tests use the real target or a complete isolated replica and real execution path for the behavior claimed
[ ] simulations/fixtures, when permitted, are confined to the input boundary they actually represent and are not credited as real-path validation
[ ] auxiliary/hosted environments are classified correctly and do not replace required physical-host evidence
[ ] GitHub Actions, when applicable, invokes the real suite/target and is not a required merge gate
[ ] physical validation is reached only after preceding evidence makes success the expected outcome
[ ] repeated physical-only failures trigger review of the preceding test model
[ ] correction propagated to dependent active docs/tests/examples, or pending implementation/test realignment is explicitly recorded
[ ] stale superseded patterns were scanned for
[ ] executable/file modes were checked
[ ] mechanical guard was added where justified
[ ] physical-validation status is stated accurately and does not exceed what the executed tests prove
[ ] Git changes are forward-only
```

Failure of an applicable item means the work is not complete.
