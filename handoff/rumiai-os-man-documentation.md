# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and use the same task to establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design is a separate architecture problem whose build orchestration belongs to `mk`.

## Current repository revisions

```text
rumiai-dev   a3f20663141fe09a573157e86ea1bf57ec988752  (canonical manual lookup contract checkpoint before this handoff update)
rumiai-os    36c29d8412a523f722fd90004b78a07fdf0b06c8  (current remote HEAD inspected; no product change made by this task)
rumiai-tests 298931c1dca03d44755893d64b9b3a7c0058b7ea  (last inspected while checking current mk coverage)
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

The active `handoff/mk-tool-development.md` is relevant only to the cross-task state of the future documentation-build capability.

## Fixed task-local choices

- The first-delivery work is split into distributed operational-documentation files/storage and an access/viewing utility.
- Operational pages use the global `manual` resource class under `res/<owner>/manual/<topic>` for current global owners `sys` and `ai`.
- Initial topic files are human-readable UTF-8 text and have no filename extension.
- The public access utility is named `manual`.
- The explicit paging-disable option is `--no-pager`.
- Normal first-delivery presentation delegates to the POSIX `more` utility.
- `--no-pager` bypasses `more` and writes the selected topic directly to standard output.
- No generic RumiAI `pager` utility, `less` dependency, `$PAGER` contract or host-specific pager adapter is introduced in the first delivery. A generic pager abstraction requires a later concrete reusable need that POSIX `more` does not satisfy.
- Unqualified lookup uses `manual [--no-pager] <topic>` and searches all materialized `res/*/manual/<topic>` candidates.
- An unqualified topic is selected only when exactly one owner-local match exists. No owner has implicit precedence.
- An unqualified lookup with multiple matches fails as ambiguous and reports the owner-qualified alternatives on standard error, for example `manual sys pkg` and `manual ai pkg`.
- Explicit owner resolution uses `manual [--no-pager] <owner> <topic>` and resolves only `res/<owner>/manual/<topic>` with no cross-owner fallback.
- Unqualified discovery follows the generic `res/*/manual/` shape and must not hard-code semantic dependence on the owner name `ai`.
- Per-command `--help`/`-h` is not part of the first-delivery direction.
- The long-term multi-channel documentation model has a build step and that build responsibility belongs to `mk`.
- Documentation generators/renderers are build-time concerns; generated operational pages must not require Python, Ruby or another documentation framework merely to be read at runtime.
- Exact long-term source schema, AST, renderer/toolchain and `mk` documentation-build CLI/configuration remain open.

## Completed

- Documentation ownership and the simple terminal-first versus long-term multi-channel split were established in the canonical documentation specification.
- Sphinx, Asciidoctor and Pandoc were identified as the primary existing-toolchain candidates for the long-term track, with dependency/runtime profile treated as a major criterion.
- The user fixed the first-delivery resource class/layout, extensionless page naming and public utility name.
- The user fixed `mk` as the owner of the long-term documentation build mechanism.
- Concurrent `mk` work advanced during this task: `specifications/rumiai-os/MK.md` is now the current high-level lifecycle contract and `MK-SOURCE-MATERIALIZATION.md` is subordinate to it.
- Current `mk` implementation was rechecked: it still exposes only `mk materialize`; no documentation build behavior exists yet.
- Current permanent `mk` coverage was rechecked: `tests/rumiai-os/mk/materialize.test` covers the implemented materialization baseline; no documentation-build test exists yet.
- The paging design was resolved against the current POSIX portability contract. The first delivery reuses POSIX `more` rather than creating a new host abstraction; POSIX `more` already pages terminal output and copies input unchanged when standard output is not a terminal.
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md` fixes `--no-pager`, POSIX `more` as the normal presentation mechanism, and the absence of a first-delivery generic `pager` abstraction.
- Topic lookup and owner qualification are now fixed in `DOCUMENTATION-MODEL.md`: unique unqualified lookup, explicit ambiguity reporting, and exact owner-qualified resolution without fallback.
- No `rumiai-os` or `rumiai-tests` product/test modification has been made by this documentation task.

## Current state

Storage identity, command name, paging baseline and topic/owner lookup semantics are fixed.

For normal viewing, `manual` delegates the selected topic to POSIX `more`; `--no-pager` provides explicit direct output. Topic resolution is independent from presentation: unqualified lookup succeeds only for a unique cross-owner match, while `manual <owner> <topic>` selects an exact owner-local topic.

The remaining first-delivery design is zero-argument behavior, command executable ownership/location, exact diagnostics and numeric exit statuses, followed by proportional permanent tests. Those must be fixed before implementing `manual` in `rumiai-os`.

The current high-level `mk` contract already owns complete lifecycle/build orchestration. The documentation-build requirement is therefore a concrete `mk` build/output responsibility rather than a separate documentation-specific build subsystem.

## Next action

Continue the first-delivery interface design in this order:

1. fix zero-argument `manual` behavior;
2. fix command executable ownership/location and exit-status behavior, including topic-not-found, ambiguity and `more` execution failure;
3. define proportional permanent tests for storage, unique lookup, ambiguity, owner-qualified lookup, normal `more` presentation and `--no-pager` direct output;
4. only then implement `manual` and initial pages in `rumiai-os`.

In parallel, continue the long-term build-tool comparison as input to `mk` lifecycle design. Do not invent a documentation-specific build subsystem outside `mk`.

## Blockers / open questions

- Zero-argument `manual` behavior.
- `manual` executable owner/location and exit-status contract.
- Exact diagnostic wording/layout and numeric status for topic-not-found and ambiguity.
- Failure mapping when the POSIX `more` invocation itself fails.
- Which of Sphinx, Asciidoctor, Pandoc or another toolchain best fits the future `mk`-driven documentation build.
- Exact source representation and generated artifact set for documentation model 2.
