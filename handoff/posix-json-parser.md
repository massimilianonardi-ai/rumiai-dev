# POSIX JSON command

Status: Active
Updated: 2026-11-03

## Goal

Evolve the standalone POSIX `bin/sys/json` utility into a genuinely useful JSON **query** command, with `jq` as CLI/filter-language reference. Strict JSON parsing/validation is an underlying correctness obligation, not the product's primary purpose. The originally published validator/compactor is an implemented starting point, not an accepted final user workflow.

## Current repository revisions

- `rumiai-dev`: `b85844662af1474e5dee3e03c1633a2af1f769e8` (before this design checkpoint)
- `rumiai-os`: `220b2b1d564845f3b0cb90e972ca59ce1dfbfef0` (`bin/sys/json` blob `f7cb24574f473565245fc8ba3757d4c5bb7f5f74`, unchanged)
- `rumiai-tests`: `04b684a83277e1c5a30d731e7c6a56b90835bdc7`
- `ryncsn/poorjson.sh`: `1bf9a1894b99732ac03d64ef0a2b645166cfb2d5`
- `pystardust/jsp`: `94e7b4a371b823786cc60431af7ddb68caf6a68b`
- `jqlang/jq`: `5c001b18d7237cce1fdba63608732163f978dd23`

Verify fresh HEADs before future work; these are only the revisions used for this comparison.

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `specifications/README.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`
- `specifications/rumiai-os/DIAGNOSTICS.md`
- `specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md`

## Fixed task-local choices

- The user has explicitly corrected the product goal: `json` must query JSON, not merely validate/compact; CLI design must use `jq` as the primary reference and account for `poorjson.sh` and `jsp`.
- Command path/identity remains `bin/sys/json`, native `#!/bin/sh`, pure POSIX implementation requirement from original request.
- Strict JSON parsing and UTF-8 checks remain important underlying protections; the existing dedicated `lib/sys/sh/json.lib.sh` is a different, specialized extraction API and was not changed.
- No new query CLI, options, filter language or output semantics have yet been accepted as canonical. The existing `json -c` means check, conflicting with `jq -c` compact; treat this as a migration/design mismatch requiring explicit resolution rather than a durable contract.

## Acceptance scenarios

- Extract a nested value from stdin or a file using an intuitive filter, e.g. `.user.name`.
- Select array elements/indexed values and obtain multiple query results, with JSON output or raw string output for shell pipelines.
- Distinguish missing keys, empty results, invalid JSON, malformed queries and I/O failures; quoted/escaped Unicode keys must match semantically.
- Keep robust UTF-8/grammar validation, deep nesting behavior and standalone POSIX execution through the real public command.

## Working design

Current comparison proposes (NOT PROMOTED) a jq-shaped CLI:

```text
json [options] [filter] [file ...]
json --check [file ...]      # local extension, rather than old -c
```

Candidate compatibility priorities: `.`, `.key`, `.[index]`, `.["escaped key"]`, chained selectors, `.[]`, optional access, `|`, `,`; multiple JSON results; `-r` raw strings, `-c` compact JSON, `-e` output-based status, `-f` filter source, ordinary stdin/files and `--` termination. jq's `-s`, `-n`, `-R`, `--arg`, `--argjson`, predicate/select, comparison and function language require explicit feature-boundary decisions; do not claim full jq compatibility for a subset. A default `.` identity and pretty output are candidate jq-aligned defaults. The current single-document, all-or-nothing staging model may need revision to support multi-document streams and pipeline usability. Query keys require actual Unicode escape decoding and duplicate-key selection semantics must be defined. Existing shell library does not currently cover these general querying semantics.

The analysis and CLI comparison are complete enough to discuss and choose the bounded supported language; no product changes authorized by this design step were made.

## Completed
- 2026-11-03: Compared current upstream `jq`, `ryncsn/poorjson.sh` and `pystardust/jsp` CLI/source against current published `json`; reproduced specific shell escape, array, malformed-input and missing-key differences; identified the user-goal mismatch. Analysis only, no product/manual/test changes in this response.

- Verified all involved remote HEADs and current canonical rules/specifications; reviewed existing specialized JSON shell library, its tests, command layout and manual model.
- Analysed `ryncsn/poorjson.sh`, `pystardust/jsp`, and `nst/JSONTestSuite` as external references.
- Published `rumiai-os/bin/sys/json` with `#!/bin/sh`, mode `100755`, and its operational manual `res/sys/manual/json` in commits `d470d74af83cdb34bed2d285ced5d3575e8f97f0` and `caf001f98e935a3c378be5feafb293f35d103d6d`. Parser Git blob `f7cb24574f473565245fc8ba3757d4c5bb7f5f74`; manual blob `9a76fe91673d1906fa9c9b69168ddd24f59535f6`.
- Published executable permanent test `rumiai-tests/tests/rumiai-os/json/command-conformance.test` in commits `fd0faf6fc8f20f859d7d51a3cd63a83939e22440` and `502bab8beabdfe6c0c0c5c55c37f7ceac0556118`. Test Git blob `541112ffd9399b10974492ed5c74cc7251b33142`.
- Auxiliary Linux exploratory execution: 56 handcrafted accepted/rejected inputs, 300 generated valid documents compared with Python JSON reference, 10,000 nested array levels, 100 KB/1 MB strings, selected malformed UTF-8 cases; all PASS. Executed the same committed parser/test Git blobs through the native command in a temporary target fixture; test returned 0. Shell syntax checks PASS; selected runtime probes passed under dash and BusyBox ash with mawk/BusyBox awk.
- Post-change consistency review: verified remote Git blob SHAs, executable/manual modes, manual/test presence and expected changed paths; compared intervening concurrent commits and preserved unrelated text-editor changes. No current JSON library consumers modified.

- Ran the complete pinned JSONTestSuite `test_parsing` corpus against the actual `rumiai-os/bin/sys/json -c -- <fixture>` entrypoint in GitHub-hosted Ubuntu 24.04 (GitHub Actions run `41605872966`, job `125815422537`, completed success, 2026-11-03). Result: `y_ 95/95 accepted`, `n_ 188/188 rejected`, `i_ 21 accepted / 14 rejected`, strict mismatches `0`, total fixtures `318`. The `i_` group is implementation-defined by the external suite. The runner printed and checked exact source commits. This proves parsing/acceptance classification in check mode, not compaction equivalence for every corpus item.
- Added opt-in reproducible runner `tests/rumiai-os/json/json-testsuite.run` (blob `f06e6de5c7dbe3afea343a9ddd183f58d24f55c5`) and workflow `.github/workflows/json-testsuite.yml` (blob `4cd317966b154ee5adc4e1b11ba3479f5b4e9941`) in `rumiai-tests` commit `0333818b7ab0b90203c6e43ee271bd58b958be0a`. The workflow intentionally pins the product and external corpus revisions for reproducibility; future parser revisions need a deliberate ref update.
- Completed post-change consistency check of added workflow/runner diff, actual remote file blobs, source/man-test identity, real workflow logs and result status; no product code modification was required by the conformance result.

## Current state

Strict parsing is implemented and previously passed all 283 obligatory JSONTestSuite cases (`rumiai-tests` run `41605872966` against parser revision `53bac942...`). Query functionality does **not** exist yet. Current command's `-c` is validation-only, unlike jq.

Comparative source read and auxiliary behavior probes used exact `poorjson.sh` and `jsp` Git blobs verified by `git hash-object`. Observed: `poorjson.sh` provides positional traversal and wildcard but `echo` on dash corrupts JSON backslash escapes and semantically equivalent escaped object keys do not match. `jsp` provides dot-path lookup but gives malformed output for nonempty arrays/escaped quotes and accepts malformed JSON (e.g. trailing comma or invalid escape). This is auxiliary Linux evidence, not a cross-platform certification. No bug in the RumiAI parser grammar was established by this comparison; the critical defect is the missing user-facing query capability.

## Next action

Settle the query CLI/filter-language compatibility boundary and precise observable semantics (options, jq-like filter subset, result cardinality, Unicode keys, duplicate names, stdin/multiple documents, no-match behavior, statuses). Once accepted, promote the contract into the appropriate current `rumiai-dev` specification, then implement it coherently in `bin/sys/json`, realign operational manual and permanent tests, and rerun relevant JSONTestSuite validation.

## Blockers / open questions

- How far to align the pure-POSIX query language with jq: read-only path selectors only, a meaningful jq-like subset including filters/composition, or complete jq language (large separate effort)?
- Whether default output/input-stream behavior and `-e` exit codes should exactly emulate jq, versus retaining some existing single-document/atomic-output semantics. `-c` collision must be resolved deliberately.
