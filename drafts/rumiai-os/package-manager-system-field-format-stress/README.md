# RumiAI package manager — System Field Format stress test

Data: 2026-08-30

Status: **SUPERSEDED — historical analysis only**

This document path is retained to preserve the forward-only project history, but its previous conclusion is no longer an active design decision.

The analysis originally explored using one two-field format for every `pkg` data file, including integrity inventories. That approach was explicitly rejected after distinguishing hierarchical configuration/metadata from genuine tabular datasets.

The current authoritative split is:

```text
configuration / hierarchical metadata / control state
    System Configuration Field Format v0
    field-name<TAB>field-value
    dot notation

record-oriented homogeneous datasets
    System Tabular Data v0
    required TSV header
    one physical row per logical record

integrity inventories
    System Tabular Data
    type<TAB>mode<TAB>digest<TAB>target<TAB>path
```

Current authoritative documents:

```text
drafts/rumiai-os/system-field-format-v0/README.md
drafts/rumiai-os/system-tabular-data-v0/README.md
drafts/rumiai-os/package-manager-integrity-method-1/README.md
drafts/rumiai-os/system-bootstrap-v0/README.md
```

The former examples using flattened names such as `identity_name` or multi-row-per-file integrity records are historical and must not be used for implementation.

Likewise, the current canonical RumiAI shell namespace is:

```text
RumiAI_*
```

and lowercase `rumi_*` is forbidden as a function namespace. The lowercase name `rumi` is reserved for the logical bootstrap/interpreter command.

No implementation or new specification may derive current behavior from the superseded analysis at this path.
