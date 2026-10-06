# RumiAI sense model

Status: **Current / normative**  
Updated: 2026-10-06

This document defines the canonical architectural meaning of a **sense** in RumiAI.

## 1. Definition

A **sense** is a specialized AI capability through which RumiAI perceives, interprets and interacts with a specific domain, using one or more deterministic mechanisms of observation and control beneath it.

A sense therefore belongs to the RumiAI AI/cognitive layer. It is not the low-level observation/control mechanism itself.

Conceptually:

```text
RumiAI
    |
    v
sense
    |
    v
deterministic observation/control mechanism(s)
    |
    v
domain
```

## 2. Sense / control separation

A sense may interpret domain evidence, relate that evidence to the user's goal, choose which deterministic capability to invoke next and compose multi-step domain behavior.

The deterministic mechanisms below a sense perform concrete requested operations and return observable evidence. They do not become senses merely because an AI uses them.

A domain-specific deterministic adapter remains below the AI boundary when it implements a defined repeatable operation. Specificity does not imply AI behavior.

The ownership and implementation layer of a deterministic mechanism are defined by that mechanism's own contract. Using a mechanism beneath a sense does not by itself make that mechanism RumiAI-owned, AI-driven or part of the sense.

## 3. Architectural consequence

The term `sense` MUST NOT be used for a raw driver, protocol binding, browser/debug interface, device-control surface or other purely deterministic mechanism when a distinct AI capability exists above it.

Where a domain requires both layers, name and contract them separately:

```text
<domain sense>        AI/cognitive capability
<domain control>      deterministic observation/control capability
```

The exact control-side name may differ when the domain has a better established term, but the semantic boundary remains the same.

## 4. Scope boundary

A sense is domain-specialized cognition and interaction. It does not, merely by being a sense, own generic scheduling, global task orchestration or unrelated product policy.

Those responsibilities remain with the applicable RumiAI orchestration/scheduling mechanisms unless a separate current contract explicitly assigns them elsewhere.

## 5. Current invariants

```text
SENSE-01   a sense is a specialized AI capability
SENSE-02   a sense is scoped to a domain
SENSE-03   a sense perceives, interprets and may interact with that domain
SENSE-04   a sense uses one or more deterministic observation/control mechanisms beneath it
SENSE-05   deterministic observation/control mechanisms are not senses merely because an AI consumes them
SENSE-06   domain-specific deterministic adapters remain below the AI boundary when their behavior is defined and repeatable
SENSE-07   the ownership of a deterministic mechanism is defined independently from the sense that consumes it
SENSE-08   generic scheduling and global orchestration are not implied sense responsibilities
```
