# POSIX JSON command

Status: Complete
Updated: 2026-11-03

## Goal

Deliver a robust, standalone POSIX `bin/sys/json` JSON **query** command suitable for normal shell work and early technical `m/pkg` configuration extraction, with strict JSON parsing and a bounded jq-like read-only filter language.

## Current repository revisions

- `rumiai-dev`: `f7f2866a9555a4ea1d122a4e8a102d5ad52f54a0` (before this final handoff checkpoint)
- `rumiai-os`: `4b0eaf88de089356f5e933c1c605110977f7f126`
- `rumiai-tests`: `5efa367690de9acff9de02326aecbe1616359cad`
- `nst/JSONTestSuite`: `1ef36fa01286573e846ac449e8683f8833c5b26a`

Exact remote HEADs must be rechecked for later work.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`
- `specifications/README.md`
- `specifications/rumiai-os/JSON-QUERY.md` — the promoted query/CLI semantics
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`
- `specifications/rumiai-os/DIAGNOSTICS.md`
- `specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md`

## Fixed task-local choices

All user-accepted query interface choices have been promoted into `specifications/rumiai-os/JSON-QUERY.md`. No separate working-design contract remains here. jq functions and advanced expression processing are deliberately outside the accepted first scope.

## Acceptance scenarios

Primary shell scenarios are now protected through the real command: nested key extraction, array traversal, raw output, multi-file input, optional access, duplicate keys, Unicode escape equivalence, atomic rejection of malformed input, and standalone syntax validation.

## Completed

- Created the initial strict, POSIX `#!/bin/sh` JSON lexer/parser, manual and permanent test.
- Ran original `JSONTestSuite` parsing corpus (95 valid, 188 invalid, 35 implementation-dependent) on the first parser revision.
- Compared the user-supplied `poorjson.sh` and `jsp` query interfaces with upstream `jq`, and revised the user goal from mere validation/compaction to a robust querying utility.
- Promoted standalone JSON query semantics into `specifications/rumiai-os/JSON-QUERY.md`, indexed by `specifications/README.md` (contract commit `300a4a73a9d2c7828a08a54be2dbc8658186a668`).
- Updated real command `bin/sys/json` and operational manual `res/sys/manual/json` (product commits `2c6c0d7a722f6f9499fd5001769c86f410c59fc6` and `4b0eaf88de089356f5e933c1c605110977f7f126`). Implemented documented jq-like selectors and options, explicit nonrecursive JSON/query handling, checked UTF-8, raw text output, Unicode-aware keys, last-duplicate-wins and staged output.
- Updated permanent query test, the opt-in JSONTestSuite runner, and revision-pinned CI workflow in `rumiai-tests` (test commits `1f34d271d1d505fc0fd3f6df27add6e6e52fd270`, `dcfb84dcfd8d1308e078352b84e1719153387c7b`, `5efa367690de9acff9de02326aecbe1616359cad`).
- Actual GitHub-hosted Ubuntu 24.04 conformance run `41621957649` completed **success**, using real product `4b0eaf88...` and suite `5efa367...`. Permanent query command test passed. JSONTestSuite `test_parsing`: `y_ 95/95`, `n_ 188/188`; optional `i_`: 21 accepted, 14 rejected; strict mismatches `0`.
- Auxiliary Debian Linux tests: `sh -n`, real executable permanent regression fixture, selected BusyBox awk behavior, 1000/10000 nesting depths, large strings up to 1 MB, and 500 random small-document filter comparisons with local `jq` (0 discrepancies). These prove only the exercised properties and hosts.
- Post-change consistency: reviewed exact source/manual/spec/test blobs, command shebang and modes, current spec router and changed-path Git commits; preserved concurrent unrelated commits with forward-only expected-HEAD updates. No existing specialized `json.lib.sh` consumers were changed.

## Current state

The requested bounded query utility and its canonical contract, operational documentation, permanent tests and pinned external conformance run are delivered. No product/manual/test mismatch was found in final checks.

Formal revision-bound `rumiai-validate`, stable macOS/Ubuntu ARM64 physical validation, and a comprehensive full-jq language implementation are **not** claimed and were not part of this accepted scope. The future installation of JavaScript or jq through `pkg` is a prospective use case, not an integration implemented in this work.

## Next action

None for this completed query-command work unit. Any future query language extension or `pkg` integration should use the current canonical `JSON-QUERY.md` and relevant package specifications as input.

## Blockers / open questions

None within the accepted first-scope JSON query command.
