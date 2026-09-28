# E2B

Status: **External product evaluation / non-normative**  
Evaluated: 2026-09-28

## Identity

Product/project: E2B  
Upstream repository: https://github.com/e2b-dev/E2B  
License: Apache-2.0, as declared upstream  
Evaluated upstream revision: `ccaf9fc0ffe6ac39c7ec786af7608ab1de19467b`

This record is a revision-specific external-product evaluation. Upstream terminology does not define RumiAI architecture.

## Upstream purpose

E2B is open-source infrastructure for running AI-generated code inside isolated cloud sandboxes. Its SDKs create and control sandbox environments and the current product surface also includes code-interpreter and desktop/computer-use APIs.

Upstream provides a self-hosting path through a separate infrastructure repository, currently centered on Terraform-supported cloud deployment.

## Mechanisms relevant to RumiAI study

Relevant mechanisms include:

- short-lived isolated execution environments;
- programmatic process/command execution;
- sandbox templates/snapshots;
- filesystem and runtime isolation;
- code-interpreter APIs;
- desktop mouse/keyboard/screenshot/application control;
- lifecycle control of remote execution environments;
- infrastructure separated from agent reasoning.

This is useful because sandboxing is treated as infrastructure, not as an agent feature.

## RumiAI evaluation

### Reuse

Potentially useful where remote disposable execution is acceptable. It is less directly aligned with a zero-cloud local baseline unless the self-hosted infrastructure can meet RumiAI's locality and deployment requirements.

### Integration

A replaceable execution-environment provider is conceptually plausible. E2B could be one implementation for remote sandbox workloads without defining the higher-level agent contract.

### Reference

High for understanding what a serious agent sandbox needs beyond "run a container": lifecycle, templates, filesystem/process APIs, desktop interaction and infrastructure control.

## Risks and architectural cautions

The default user journey is cloud/API-key oriented. The current self-hosting guide lists AWS and GCP support while general Linux-machine support is not listed as available in the evaluated README, which is a significant mismatch with a local-first system.

Isolation/security claims require independent threat-model validation before executing untrusted model-generated code.

## Current assessment

E2B is a strong **sandbox architecture reference** and a possible optional remote execution provider, but it is not presently a natural default for RumiAI's sovereign local execution path.

## Verification notes

This evaluation is based primarily on the upstream repository and current README at the revision recorded above. Runtime behavior, security properties, performance claims and operational characteristics have not been independently validated by RumiAI testing in this work unit.
