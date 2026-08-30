# RumiAI Development Consistency Gate

Status: **canonical development rule**  
Date: 2026-08-30

This document defines the mandatory consistency gate for changes to already-established RumiAI subsystems.

Its purpose is to prevent implementation drift from decisions, conventions and invariants already recorded in `rumiai-dev`.

`rumiai-dev` remains authoritative. Conversation memory, implementation convenience and newly drafted local terminology never override an existing canonical decision silently.

---

## 1. Authority preflight

Before modifying an established subsystem, the change author must read or retrieve the current authoritative material relevant to that subsystem, including at least:

1. `RULES.md`;
2. the active architecture/specification documents for the touched subsystem;
3. the current remote implementation at the actual branch HEAD;
4. the permanent tests protecting that subsystem when they exist.

A remembered convention is not sufficient when the repository can answer the question.

---

## 2. Change invariant list

Before writing code, the change must identify the invariants that can constrain it.

The list is scoped to the change and includes, when applicable:

```text
names and namespaces
public/private API spelling
file and directory naming
serialization/data formats
filesystem layout and path rules
POSIX/platform contract
exit statuses and error classes
ownership/mode rules
transaction semantics
physical-validation requirements
previous explicit user corrections
```

If a proposed implementation would change one of these invariants, that is a design change, not an implementation detail.

A design invariant must not be changed silently. The change must first be surfaced explicitly and, where the project process requires it, approved before implementation.

---

## 3. Existing primitive first

Before introducing a new helper, alias, namespace, suffix, format or abstraction, search the current subsystem for an existing primitive with the same semantic role.

Rule:

> reuse the established primitive when its contract already matches the requirement.

A new name must not be invented merely to expose an existing function through another spelling.

Example:

```text
existing: RumiAI_path_canonicalize_existing
wrong:    RumiAI_path_canonicalize_existing_api
```

unless a genuinely different contract has first been specified.

---

## 4. Naming consistency

For RumiAI shell code, namespaced functions and variables use the exact project namespace:

```text
RumiAI_*
```

Lowercase alternate namespace:

```text
rumi_*
```

is forbidden.

The lowercase word `rumi` may be the public command/interpreter name; this does not create a lowercase function namespace.

Separately specified unnamespaced interfaces such as the existing `log` and `i18n` entrypoints remain explicit exceptions. An exception does not establish an alternate general naming convention.

---

## 5. Correction propagation rule

When an established invariant is corrected, the same work unit must inspect and, where applicable, update all of:

```text
canonical specification
current implementation
permanent tests
examples/reference descriptors
physical-validation documentation
related active drafts that consume the interface
```

After propagation, the affected subsystem must be scanned for the superseded spelling/pattern.

A correction is not complete when only the file where the inconsistency was noticed has changed.

---

## 6. Minimal-change rule

An implementation change must solve the requested problem without opportunistically introducing unrelated conventions or abstractions.

In particular:

- do not create aliases that are not required;
- do not generalize a physical namespace before a real use case exists;
- do not replace an established mechanism with a locally preferred one without an explicit architectural decision;
- do not reinterpret a previously fixed term as a new concept;
- do not turn implementation convenience into a new project convention.

---

## 7. Post-change consistency scan

Before declaring an implementation complete, perform a subsystem-wide consistency check appropriate to the change.

At minimum verify:

```text
no superseded/forbidden names remain
new public names match the authoritative namespace
call sites and tests use the current names
file modes are correct, especially executable tests/commands
serialization/layout still matches the active specification
no accidental host-specific dependency was introduced
Git history remains forward-only and based on the current remote HEAD
```

Where an invariant is mechanically checkable at reasonable cost, add or update a permanent test so future violations fail automatically.

---

## 8. Physical validation discipline

A semantic implementation change that requires physical validation must be validated on the current stable reference installations according to the testing contract.

Pure naming/documentation corrections should normally be bundled into the next meaningful physical gate rather than imposing repeated operator work, unless the rename itself changes observable execution behavior or prevents the existing tests from exercising the code.

Previously recorded evidence remains evidence for the exact revision/API spelling that was exercised; documentation must not silently relabel old evidence as validation of a later untested revision.

---

## 9. No memory-only continuation

When resuming work on an established subsystem after enough context has accumulated that a convention could be uncertain, retrieve the canonical documents and current HEAD instead of guessing from conversational memory.

This rule applies even when the remembered answer seems likely.

Repository evidence is cheaper than propagating an incorrect assumption through code, tests and documentation.

---

## 10. Completion checklist

A change to an established subsystem is ready to be reported as complete only when the answer to every applicable item is yes:

```text
[ ] authoritative documents were consulted
[ ] current remote HEAD was used
[ ] relevant invariants were identified
[ ] no invariant changed silently
[ ] existing primitives were reused where semantically equivalent
[ ] code follows established naming/layout/format rules
[ ] correction propagated to dependent docs/tests/examples
[ ] stale superseded patterns were scanned for
[ ] executable/file modes were checked
[ ] permanent mechanical guard added when justified
[ ] physical-validation status is stated accurately
[ ] Git changes are forward-only
```

Failure of an applicable item means the work is not complete.
