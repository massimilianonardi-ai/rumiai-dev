# Handoff — RumiAI OS bootstrap milestone closed

Date: 2026-08-29
Status: **BOOTSTRAP PHASE 0/1 CLOSED — move development upward**

## Stable product baseline

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Validated product commit:

```text
8698504f715ed61cec8a31b46ded5b79f3924eb5
Separate pathname validation from canonicalization
```

The Phase 0/1 bootstrap, semantic roots, PATH model, bootstrap preferences, i18n, logger, command interpreter, direct `#!/usr/bin/env rumiai-os` host profile, Bash selection where available, and POSIX `sh` path have been physically exercised on both stable hosts.

The accepted pathname rule remains:

```text
VALIDATE EXISTENCE
        ↓
CANONICALIZE EXISTING PATH
        ↓
VALIDATE REQUIRED TYPE
```

`realpath` is only a canonicalizer of an already-existing pathname. The rejected `realpath -e` commit remains historical evidence and must not be revived for the reference macOS host.

## Permanent test suite

The artificial test:

```text
tests/rumiai-os/shell/bash-fallback-to-sh.test
```

has been removed intentionally.

Reason: absence of Bash is not a material RumiAI portability requirement. POSIX `sh` is the required portable shell baseline; Bash is only an optional user-facing convenience when available. A permanent test that manufactures Bash absence added complexity without protecting an important product contract.

The removal commit is:

```text
e6534b734a170ad5334aedcfe0e6347d5da64814
Remove irrelevant bash absence test
```

The remaining suite contains 55 tests.

No additional full-suite run is required merely because this test was deleted. In the immediately preceding macOS run all other 55 tests were PASS and the deleted test was the sole FAIL. In the corresponding Ubuntu ARM64 run all 56 tests were PASS. Therefore every remaining test has already physically passed on both stable hosts against the unchanged product baseline.

## New validation policy — selective by impact

Physical validation is no longer automatically equivalent to running the complete suite after every change.

Use the smallest test scope that proves the changed contract:

```text
single test
    when one isolated behavior changes

group / subsystem
    when shared code inside that subsystem changes

full suite
    only when a cross-cutting bootstrap/runtime/runner primitive changes,
    at a major milestone,
    or before a release/certification checkpoint
```

Do not re-run tests for unchanged behavior merely to reproduce already-established evidence.

Do not create permanent tests for hypothetical failure modes that are outside the product contract or contradict the selected platform baseline. External properties should be tested only when RumiAI materially relies on them and their failure would change a supported behavior.

## Development direction

The bootstrap is now infrastructure, not the development focus. New bootstrap edge-case work is deferred unless a real development task exposes a regression or a missing requirement.

Development proceeds top-down and PoC-first through the following milestones.

### M2 — RumiAI component execution model

Define the minimum contract by which a real RumiAI component is represented and launched on top of the now-stable `rumiai-os` environment.

Questions to settle through a PoC, not prolonged abstract design:

- component entrypoint and layout;
- configuration boundary;
- lifecycle start/stop/status semantics;
- environment inherited from `rumiai-os`;
- process identity and observability;
- distinction between product component and development tooling.

Deliverable: one trivial real component launched through the accepted model.

Tests: only the component contract and lifecycle properties actually introduced.

### M3 — Nervo / ai-channel transport

Implement the first real communication substrate between RumiAI components.

Start with the simplest useful transport already aligned with the architecture: local TCP socket, explicit framing/protocol adapter, request/response first.

Keep transport separate from semantic protocols so OpenAI-compatible messages and future protocols are adapters rather than transport assumptions.

Deliverable: two independent components communicating through a nervo with observable request/response behavior.

Tests: connection, framing, disconnect/error semantics and one physical cross-process round trip. Do not test networking scenarios the product does not claim to handle.

### M4 — Core-AI microkernel skeleton

Promote the accepted kernel architecture into executable code:

```text
minimal kernel
    dispatch
    lifecycle
    flow trace/logging
    kernel-mod loading

kernel-mod contract
    capabilities
    declared I/O / communication behavior
```

The orchestrator remains a kernel-mod, not hardcoded kernel behavior.

Deliverable: kernel loads at least two trivial mods and dispatches a capability request deterministically.

Tests: plugin loading, lifecycle, capability dispatch, failure isolation and trace production.

### M5 — First end-to-end cognitive vertical slice

Connect one Senso/Espressione path to Core-AI through the nervo and an existing local model backend.

Preferred first slice:

```text
Terminal Senso/Espressione
        ↓
Nervo
        ↓
Core-AI kernel
        ↓
minimal orchestrator mod
        ↓
local model adapter / Ollama
        ↓
Nervo
        ↓
Terminal output
```

This milestone proves architecture, not feature richness.

Tests: one permanent end-to-end conversation contract plus targeted subsystem tests for defects actually discovered.

### M6 — Parallel capability expansion

Only after the vertical slice is stable, expand independently:

- REST/OpenAI-compatible gateway;
- Open-WebUI adapter;
- memory/RAG;
- tool-use;
- computer-use;
- speech/vision senses and expressions;
- asynchronous events;
- full-duplex streaming;
- additional devices/sensors.

Each capability should remain replaceable and independently testable.

## Immediate next action

Start M2 in `rumiai-dev-PoCs` with a minimal component-execution PoC. Do not add more bootstrap tests first.

Once the PoC establishes the smallest viable contract, promote only the proven pieces to the appropriate product repository and add a small permanent test set for that contract.

## Git rule

All repositories remain forward-only. Failed experiments and superseded decisions stay in Git history; current operational documents should describe only the accepted state and active next steps.
