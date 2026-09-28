# HydraDB

Status: **Current reference snapshot / non-normative**  
Evaluated: 2026-09-28

## Identity

- Upstream: `hydra-db/hydradb`
- Upstream branch: `main`
- Evaluated revision: `6a2fbb192f37f51a93690a2ae2d2f5e27e6e4219`
- License: AGPL-3.0 as declared by upstream
- Primary implementation: Rust
- Discovery context: strong recent GitHub acceleration surfaced it during the AI infrastructure scan; growth is a discovery signal, not adoption evidence.

## Purpose and upstream model

HydraDB is an object-store-native distributed graph database. It stores durable graph state in S3-compatible object storage using SlateDB and separates durable storage from disposable compute/cache nodes.

It supports snapshot-consistent OpenCypher queries, GraphBLAS traversal, Neo4j-compatible Bolt connectivity and an HTTPS API.

## Architecture relevant to RumiAI research

- object storage as durable graph source of truth;
- independent query/data nodes and background indexers;
- disposable memory and local SSD/NVMe caches;
- safe writer handoff using leases plus writer epochs;
- pinned snapshots for consistent queries;
- immutable traversal indexes combined with visible WAL state;
- graph-native indexes and sparse traversal;
- standard-ish client compatibility through Bolt/OpenCypher.

## RumiAI relevance

### Reuse

Potentially useful if a future RumiAI workload genuinely needs a distributed graph database at this scale and the AGPL licensing/deployment implications are acceptable.

### Integration

Possible behind a graph/knowledge-store boundary. There is no current RumiAI contract requiring HydraDB.

### Reference

High for graph persistence and scalable derived-index design; indirect rather than agent-runtime relevance.

## Strengths and useful mechanisms

The strongest idea for RumiAI research is the separation between canonical durable graph records and rebuildable acceleration structures. That distinction is useful when thinking about knowledge/memory systems where indexes, embeddings or traversals must not silently become the authority.

## Risks and mismatches

- AGPL-3.0 requires deliberate licensing review before reuse or distribution decisions.
- The distributed object-storage architecture may be excessive for local personal workloads.
- Rust is acceptable for external software but does not change RumiAI-owned language preferences.
- A graph database storage model must not be mistaken for memory semantics, provenance or epistemic authority.

## Current assessment

```text
reference     strong for graph storage, canonical-vs-derived state and indexing
integration   plausible only if a graph-store requirement emerges
reuse         specialized and licensing-sensitive
foundation    no current basis for making it a RumiAI memory foundation
```

## Verification notes

Before reuse, verify licensing obligations, local/single-node behavior, object-store dependencies, OpenCypher compatibility, operational maturity and benchmark claims independently.
