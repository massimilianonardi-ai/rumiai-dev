# Letta Code

Status: **External product evaluation / non-normative**  
Evaluated: 2026-09-28

## Identity

Product/project: Letta Code  
Upstream repository: https://github.com/letta-ai/letta-code  
License: Apache-2.0, as declared upstream  
Evaluated upstream revision: `c864f1532b328aab4bb76cc68a86d5f014de27b8`

This record is a revision-specific external-product evaluation. Upstream terminology does not define RumiAI architecture.

## Upstream purpose

Letta Code describes itself as a stateful agent harness for agents with memory, identity and experience over time. The active source moved from the older `letta-ai/letta` repository to `letta-ai/letta-code`; the older repository now points to this implementation and retains retired V1 source separately.

Agents can run interactively or continuously and can rewrite their own memory, skills, prompts and, through mods, parts of the harness. The project supports local and cloud backends, multiple user channels, subagents, scheduling, permissions and remote computers.

## Mechanisms relevant to RumiAI study

Particularly relevant mechanisms are:

- explicit persistent agent identity rather than conversation-only state;
- memory blocks that agents can rewrite;
- skill learning and agent-scoped skills;
- MemFS, where context including memory blocks is tracked through Git;
- subagents and agent-to-agent invocation;
- hooks, permissions, heartbeats and schedules;
- the separation between local execution and cloud-persisted agent state;
- long-horizon "dreaming"/sleep-time work.

This makes Letta materially different from a memory engine such as Hindsight: memory is embedded in the lifecycle and identity model of the agent itself.

## RumiAI evaluation

### Reuse

Useful for experimentation when the question is specifically long-lived, self-modifying agents. Direct reuse would import a substantial agent model, so it should remain experimental unless RumiAI independently converges on compatible requirements.

### Integration

Potentially valuable as an external agent runtime. Integration should expose only an independently defined RumiAI boundary; Letta concepts such as memory blocks, MemFS or dreaming must not become RumiAI primitives by convenience.

### Reference

Very high reference value for persistent identity, self-modifying context, learned skills, long-horizon execution and the distinction between an agent as a transient process and an agent as a durable entity.

## Risks and architectural cautions

Self-modification is both the most interesting mechanism and the largest risk. Mutable prompts, memory, skills and harness behavior raise provenance, rollback, trust, permission and audit questions.

MemFS uses Git as a memory/context mechanism. RumiAI must not confuse such history with its own development authority model: historical state can be evidence or agent memory without becoming current canonical truth.

The optional cloud path also differs from RumiAI's local-first sovereignty goals; local behavior and cloud-dependent features must be evaluated separately.

## Current assessment

Letta Code is a strong **reference and experimentation target** for agent identity and continual adaptation. It should be studied alongside Hindsight precisely because they place the memory boundary differently: Hindsight externalizes a memory subsystem, while Letta makes evolving memory part of the agent model.

## Verification notes

This evaluation is based primarily on the upstream repository and current README at the revision recorded above. Runtime behavior, security properties, performance claims and operational characteristics have not been independently validated by RumiAI testing in this work unit.
