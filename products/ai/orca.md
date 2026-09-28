# Orca

Status: **Current reference snapshot / non-normative**  
Evaluated: 2026-09-28

## Identity

- Upstream: `stablyai/orca`
- Upstream branch: `main`
- Evaluated revision: `6c4625d7ff178badefa38527c3d6e69ea5c8e88e`
- License: MIT as declared by upstream
- Primary implementation: TypeScript
- Discovery context: strong recent GitHub star acceleration; growth is a discovery signal, not adoption evidence.

## Purpose and upstream model

Orca describes itself as an agent development environment for operating a fleet of parallel coding agents. It can run multiple CLI agents side by side, with each task isolated in its own Git worktree and tracked from one environment.

The current upstream surface includes desktop operation on macOS, Windows and Linux, remote worktrees over SSH, a mobile companion, integrated source review and computer-use capabilities.

## Relevant mechanisms

- one worktree per parallel agent/task;
- fan-out of the same task to multiple agents for comparison;
- agent-agnostic CLI execution rather than a single model/provider;
- persistent terminal/workspace state;
- remote execution through SSH;
- review and annotation of agent-generated diffs;
- notifications and human steering;
- CLI control of worktree and UI workflows;
- browser/design-mode and computer-use surfaces.

## RumiAI relevance

### Reuse

Useful as an external developer environment for parallel coding-agent workflows.

### Integration

Possible where RumiAI needs to launch, observe or cooperate with an external coding-agent workspace. Any integration should preserve Orca as a replaceable external product.

### Reference

High for practical multi-agent developer workflow design: task isolation, worktree ownership, remote execution, human review, notifications and coordination of heterogeneous CLI agents.

## Strengths and useful mechanisms

Orca demonstrates a deliberately simple isolation unit for coding work: Git worktrees. It also separates the choice of coding agent from the workspace/control experience, which is useful evidence for provider-independent orchestration.

## Risks and mismatches

- The product is centered on software-development workflows rather than general cognitive-agent orchestration.
- Git worktrees are an excellent coding isolation mechanism but are not a generic agent-state abstraction.
- Computer use, remote SSH and credential/account switching expand the security surface.
- Product UI concepts must not be promoted into RumiAI architecture without an independent requirement.

## Current assessment

```text
reference     strong for parallel coding-agent workflow and isolation
integration   plausible for external development automation
reuse         useful as a developer-facing product
foundation    not a general RumiAI orchestration foundation
```

## Verification notes

Refresh upstream before relying on agent adapters, remote-runtime behavior, worktree lifecycle, telemetry/privacy behavior or computer-use security boundaries.
