# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and use the same task to establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design is a separate architecture problem whose build orchestration belongs to `mk`.

## Current repository revisions

```text
rumiai-dev   9375ac9f160fd3970e93cf1fb0b4ad4e14df0187  (current remote HEAD inspected before this checkpoint)
rumiai-os    36c29d8412a523f722fd90004b78a07fdf0b06c8  (current remote HEAD inspected; no product change made by this task)
rumiai-tests 298931c1dca03d44755893d64b9b3a7c0058b7ea  (current remote HEAD inspected while checking current mk coverage)
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
- No `rumiai-os` or `rumiai-tests` product/test modification has been made by this documentation task.

## Current state

The storage identity and command name are fixed and are being propagated to the canonical documentation/resource contracts.

The remaining first-delivery design is primarily behavioral: topic lookup/discovery, owner qualification, paging, exit statuses and command executable placement must be fixed before implementing `manual` in `rumiai-os`.

Paging now has a specific portability concern. RumiAI targets POSIX; making `less` an unconditional runtime requirement would require an explicit non-POSIX dependency decision. A promising direction is interactive paging only when stdout is a terminal, with direct stdout for pipes/redirections and a graceful pager fallback policy, but the exact pager contract and disable-option spelling are not fixed yet.

The current high-level `mk` contract already owns complete lifecycle/build orchestration. The documentation-build requirement is therefore a concrete `mk` build/output responsibility rather than a separate documentation-specific build subsystem.

## Next action

Continue the first-delivery interface design in this order:

1. fix `manual` topic lookup/discovery and owner qualification;
2. fix interactive paging semantics, fallback behavior and the explicit no-pager option;
3. fix command executable ownership/location and exit statuses;
4. define proportional permanent tests;
5. only then implement `manual` and initial pages in `rumiai-os`.

In parallel, continue the long-term build-tool comparison as input to `mk` lifecycle design. Do not invent a documentation-specific build subsystem outside `mk`.

## Blockers / open questions

- Exact `manual` lookup/discovery behavior, including zero-argument behavior and ambiguity across owners.
- Whether `manual` should automatically page only for terminal stdout.
- Preferred external pager order and fallback behavior; in particular whether `less` is preferred opportunistically while POSIX `more` and/or direct output provide portability fallback.
- Exact spelling of the no-pager option.
- `manual` executable owner/location and exit-status contract.
- Which of Sphinx, Asciidoctor, Pandoc or another toolchain best fits the future `mk`-driven documentation build.
- Exact source representation and generated artifact set for documentation model 2.
