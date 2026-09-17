# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design is a separate architecture problem whose build orchestration belongs to `mk`.

## Current repository revisions

```text
rumiai-dev   4e680859b8f16f37690ff2107674e23f584c1505  (canonical manual discovery-order contract checkpoint before this handoff update)
rumiai-os    36c29d8412a523f722fd90004b78a07fdf0b06c8  (current remote HEAD inspected; no product change made by this task)
rumiai-tests 298931c1dca03d44755893d64b9b3a7c0058b7ea  (last inspected while checking current mk coverage; not involved in this documentation-only checkpoint)
```

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/RESOURCE-MODEL.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/MK.md
specifications/rumiai-os/MK-SOURCE-MATERIALIZATION.md
handoff/README.md
```

The promoted first-delivery storage, lookup, discovery, paging and long-term build-ownership contracts live in `DOCUMENTATION-MODEL.md` and `RESOURCE-MODEL.md`; they are not duplicated here.

The active `handoff/mk-tool-development.md` is relevant only to the cross-task state of the future documentation-build capability.

## Completed

- Documentation ownership and the terminal-first versus long-term multi-channel split were established in the canonical documentation specification.
- The first-delivery resource class/layout, extensionless topic naming and public utility name were promoted.
- `mk` was established as the owner of long-term documentation build orchestration.
- The paging design was resolved against the POSIX portability contract: first delivery uses POSIX `more`, with `--no-pager` for direct topic output and no generic first-delivery pager abstraction.
- Topic lookup and owner qualification were promoted: unique unqualified lookup, explicit ambiguity reporting and exact owner-qualified resolution without fallback.
- Zero-argument discovery is promoted: bare `manual` enumerates every materialized topic and always writes each result as `<owner> <topic>`, even when the topic name is globally unique.
- Discovery output ordering is promoted: ascending lexical order by owner and then topic, using controlled identifier spelling rather than locale-specific collation.
- Zero-argument discovery does not present a topic and therefore does not invoke the topic pager.
- `DOCUMENTATION-MODEL.md` was realigned with the current specification-promotion gate: unresolved toolchain candidates, active decision backlog and task sequencing were removed from the current specification rather than kept as pseudo-contract.
- The stale statement that the broader `mk` lifecycle was still being defined was corrected; current `MK.md` owns that lifecycle contract.
- No `rumiai-os` or `rumiai-tests` product/test modification has been made by this documentation task.

## Current state

The first-delivery documentation storage, command identity, qualified and deterministically ordered discovery, topic lookup/owner qualification and paging semantics are promoted current contract.

The remaining first-delivery design before implementation is command executable ownership/location plus exact diagnostic and numeric exit-status behavior. Permanent-test scope should then be fixed and product implementation can follow only under the applicable product-modification authorization.

## Working design state

The long-term source representation and documentation build toolchain remain intentionally unresolved active design. Sphinx, Asciidoctor and Pandoc have been considered as existing build-time candidates; this comparison is task working state, not current specification content.

The generated operational artifacts should remain usable without requiring the documentation-generation framework at runtime; that runtime/build separation is already promoted in `DOCUMENTATION-MODEL.md`.

## Next action

Continue the first-delivery interface design in this order:

1. fix `manual` executable ownership/location;
2. fix exact diagnostics and numeric exit-status behavior for invalid invocation, topic-not-found, ambiguity and `more` execution failure;
3. define proportional permanent tests for storage, qualified ordered discovery, unique lookup, ambiguity, owner-qualified lookup, normal `more` presentation and `--no-pager` direct output;
4. only then implement `manual` and initial pages in `rumiai-os` under explicit product authorization.

## Blockers / open questions

- `manual` executable owner/location.
- Exact diagnostic wording/layout and numeric exit statuses.
- Failure mapping when the POSIX `more` invocation itself fails.
- Long-term documentation source representation and external build toolchain.
