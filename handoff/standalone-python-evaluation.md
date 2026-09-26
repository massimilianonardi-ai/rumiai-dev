# Standalone Python evaluation

Status: Active
Updated: 2026-09-26

## Goal

Evaluate how RumiAI can obtain a Python runtime that is genuinely portable and relocatable under the current platform and ownership contracts, comparing the two already identified upstream candidates without presupposing adoption:

- https://github.com/scc-tw/standalone-python
- https://github.com/astral-sh/python-build-standalone

The task should establish what each candidate actually guarantees, where host/platform coupling remains, what validation is required, and whether either approach should be adopted or rejected for a concrete RumiAI responsibility.

## Current repository revisions

```text
rumiai-dev       a6b82217e03df81bb10d24e1e02e16bbe0e29cc5
rumiai-os        477199783c05b22e7588c11f07861b905116c5e4
rumiai-dev-PoCs  94e2d6a385236a081815b0a700b7c2b2be0c92bd
pkg-catalog      565adc534399e5d4759c8eae24fca197aa912ab9
```

These revisions are task state only; every resumed work unit must re-run the normal remote-HEAD preflight.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/CURRENT-MODEL.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/PACKAGE-MODEL.md
todo/README.md
handoff/README.md
```

Additional specifications, implementation and permanent tests must be retrieved only when the evaluation reaches a concrete responsibility that requires them.

## Fixed task-local choices

- Treat Python as a non-POSIX external capability; accidental host availability is not a portability guarantee.
- Relocatability is a first-class evaluation requirement: a candidate must not depend on personal checkout paths, Homebrew paths, distribution-local paths or another fixed installation location.
- Compare both identified upstream projects before any adoption decision.
- Do not change `rumiai-os` or `pkg-catalog` merely because an upstream project appears promising; product/catalog changes require a concrete adopted use established by the evaluation.
- Use `rumiai-dev-PoCs` for hands-on experiments when documentation and source inspection are insufficient to establish real behavior.

## Working design

The evaluation should distinguish at least:

```text
upstream distribution/build model
supported host OS/architecture combinations actually relevant to RumiAI
runtime relocatability after extraction or movement
dynamic-library/runtime-path dependencies
stdlib and extension-module behavior
TLS/certificate and other host-resource dependencies
ability to add/install Python packages without destroying relocatability
version pinning and update model
artifact integrity/provenance and licensing
fit with the current m package/runtime ownership model
validation required on materially different hosts
```

These are evaluation dimensions, not adopted subsystem contracts.

## Completed

- Performed the mandatory RumiAI preflight against current remote repository state.
- Reviewed the full current TODO inventory for Python/portable/relocatable/standalone-runtime work.
- Confirmed that `todo/standalone-python-evaluation.md` is the only current TODO dedicated to this Python topic.
- Confirmed that no active handoff currently owns the same workstream.
- Retrieved the current architecture, POSIX portability and package-model contracts needed to start the evaluation.

## Current state

The deferred Python work is being activated as this task. No upstream candidate has yet been evaluated in the current work unit and no adoption decision has been made.

## Next action

Inspect the current upstream state of both candidate repositories and build a fact-based comparison of their distribution model and relocatability claims against the RumiAI constraints above. Use a PoC only for properties that cannot be established reliably from current upstream documentation/source.

## Blockers / open questions

None at activation time. The concrete RumiAI ownership/integration target remains intentionally open until the candidate evaluation provides evidence.
