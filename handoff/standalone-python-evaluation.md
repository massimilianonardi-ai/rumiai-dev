# Standalone Python evaluation

Status: Complete
Updated: 2026-09-27

## Goal

Evaluate standalone/relocatable Python approaches for RumiAI, determine whether a shared provider model is appropriate, and preserve the resulting engineering evidence.

## Current repository revisions

```text
rumiai-dev-PoCs  04b17182392c323f13a53b9fffa6917ff9823cec
pkg-catalog      168d9bfc5ffebb4ea480a8a9f96c6e394d33fe17
```

The final `rumiai-dev` completion commit is the commit containing this snapshot.

## Applicable canonical sources

```text
RULES.md
CONSISTENCY-GATE.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/STATE-MODEL.md
specifications/rumiai-os/PYTHON-RUNTIME.md
```

## Fixed task-local choices

No task-local design choice remains authoritative only through this handoff. Durable current policy has been promoted to `specifications/rumiai-os/PYTHON-RUNTIME.md`.

## Completed

- Compared `scc-tw/standalone-python` and `astral-sh/python-build-standalone`.
- Validated a relocatable `python-build-standalone` CPython runtime on hosted Linux and macOS.
- Validated `#!/usr/bin/env python` with the existing `pkg` provider/default/binding mechanism in a controlled consumer model.
- Validated post-relocation pure/native wheel build, state-owned bytecode, normal consumer site semantics, wheel compatibility classes, a narrow PyPA `installer` command adapter and a provider-side consumer-site hook.
- Demonstrated that a naive two-facility Python/CPython split is structurally wrong and that one CPython-runtime facility can model the tested compatibility classes.
- Measured a real micromamba/Conda Python prefix and demonstrated that interpreter relocatability does not make the complete mutable environment prefix-independent.
- Preserved the standalone/shared-interpreter engineering findings and PoC index in `specifications/rumiai-os/PYTHON-RUNTIME.md`.
- Adopted the current general external-Python-application model: private micromamba/Conda environment, mutable/reconstructible application state, rebuilt after incompatible prefix or Python-version changes.
- Confirmed that no `rumiai-os` or `pkg-catalog` shared Python-provider implementation was added by this evaluation.

## Current state

The evaluation is closed.

For general external Python applications, RumiAI uses the micromamba/private-environment model defined in `PYTHON-RUNTIME.md`. The standalone/shared-interpreter design is retained as validated engineering evidence but is not current general architecture.

## Next action

None for this evaluation.

## Blockers / open questions

None.
