# External product evaluations

Status: **Current reference material**  
Updated: 2026-09-28

This directory records evaluations of external software that may be useful to RumiAI through reuse, integration or technical study.

It exists to preserve durable product research without promoting that research into RumiAI architecture or specifications.

## Authority boundary

Files under `products/` are **non-normative reference material**.

They may contain:

- upstream facts observed at a specific revision or date;
- technical analysis;
- possible reuse or integration paths;
- useful architectural mechanisms and design ideas;
- risks, mismatches and unresolved questions;
- a current RumiAI-oriented assessment.

They do **not** establish a RumiAI contract, architecture, dependency, provider, API, component name or adoption decision.

A favorable evaluation means only that a product is worth the stated level of consideration. Any RumiAI contract derived later from the research must pass the normal specification promotion gate and be written to the appropriate canonical source.

## Evaluation modes

A product can be relevant in one or more independent modes:

`reuse`
: use the external product substantially as provided.

`integration`
: connect RumiAI to the external product across an explicit boundary while keeping the product independently replaceable where the RumiAI contract requires that property.

`reference`
: study mechanisms, tradeoffs or implementation patterns without adopting the product.

These labels describe evaluation perspectives, not approved architecture.

## Revision discipline

External products evolve independently and often rapidly. Every product record must identify the upstream source and the revision/date on which factual observations were based when a revision is available.

A record is therefore a durable evaluation snapshot, not a promise that every upstream fact remains current indefinitely.

Before relying on a product record for a new implementation or architectural decision:

1. verify the current upstream state relevant to the decision;
2. distinguish unchanged observations from upstream changes;
3. re-evaluate material compatibility with current RumiAI authority;
4. promote only genuinely settled RumiAI contract through the normal specification process.

Do not silently reinterpret an old product snapshot as current upstream behavior.

## Content shape

A product record should normally cover, when relevant:

- identity and upstream source;
- evaluated revision/date;
- purpose and upstream model;
- deployment and dependency characteristics;
- externally exposed integration surfaces;
- capabilities relevant to RumiAI;
- `reuse`, `integration` and `reference` relevance;
- strengths and useful mechanisms;
- risks, constraints and architectural mismatches;
- RumiAI-specific assessment;
- open verification work, if any.

Vendor benchmark, performance, adoption or security claims must be identified as upstream claims unless independently verified.

## Categories

Current categories:

```text
ai/
    a2a.md
    ag-ui.md
    browser-use.md
    deepseek-harness.md
    e2b.md
    ecc.md
    google-ax.md
    hindsight.md
    hydradb.md
    langgraph.md
    letta.md
    litellm.md
    llama-cpp.md
    localai.md
    openhands.md
    openllmetry.md
    orca.md
    paperclip.md
    sglang.md
    univer.md
```

Add a category only when it creates a useful retrieval boundary. Do not duplicate one product record across categories merely because a product spans multiple topics.

## Retrieval

`products/` is deliberately **not** part of the mandatory read order for every RumiAI task.

Read it when:

- evaluating an external product;
- deciding whether to reuse or integrate a product already recorded here;
- looking for previously studied external mechanisms relevant to an active design question;
- refreshing an existing product evaluation.

Current RumiAI rules and specifications remain authoritative over every product evaluation.
