# POSIX JSON command

Status: Active
Updated: 2026-11-03

## Goal

Implement a standalone, strictly POSIX `#!/bin/sh` JSON parser command in `rumiai-os/bin/sys/`, independently rewritten with RFC 8259 / ECMA-404 syntax coverage, permanent tests and the matching operational manual.

## Current repository revisions

- `rumiai-dev`: `34402c8d6566e519b6b8ddaf0b1724bb4fc0d5a0` (before this checkpoint)
- `rumiai-os`: `53bac942ff9552de1770d7439dd2d547017aa9ea` (parser blob unchanged: `f7cb24574f473565245fc8ba3757d4c5bb7f5f74`)
- `rumiai-tests`: `0333818b7ab0b90203c6e43ee271bd58b958be0a`
- `nst/JSONTestSuite`: `1ef36fa01286573e846ac449e8683f8833c5b26a`

All repository HEADs were checked before and after validation. These are task evidence, not a substitute for future fresh retrieval.

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

- Command identity: `json`, source `bin/sys/json`, shebang `#!/bin/sh`.
- Standalone POSIX utility with `od` and `awk` as POSIX utility dependencies, not dependent on `m_ROOT`.
- The existing `lib/sys/sh/json.lib.sh` API and tests remain unchanged.
- Accept JSON documents of any root type, preserve number lexemes, duplicate member names and raw valid UTF-8, reject invalid UTF-8 and non-JSON tokens.
- Use a nonrecursive container parser; stage output so that a malformed document never leaks partial successful output.

## Acceptance scenarios

- Pipe a valid JSON document to `json` and receive an equivalent compact JSON document.
- Run `json -c` to check the whole document without output and distinguish accepted versus rejected documents by exit status.
- Pass an explicitly selected readable file with `json -- file`; reject malformed or unreadable files without output.
- Accept escaped Unicode, UTF-8, large exact numeric lexemes and deeply nested arrays/objects, but reject truncated strings, malformed escapes/numbers, trailing data and illegal UTF-8.

## Working design

The external references are illustrative rather than implementation dependencies: `poorjson.sh`, `jsp`, `nst/JSONTestSuite`. JSONTestSuite `y_` and `n_` groups should be checked where practical; `i_` intentionally leaves some behavior implementation-defined.

## Completed

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

`JSONTestSuite` conformance validation is complete for the exact pinned parser revision: all 283 strict expectations passed; all 35 optional cases were exercised. The actual GitHub-hosted workflow completed successfully. This is a focused external parsing-acceptance check (`-c` mode), not a formal `rumiai-validate` product session, exhaustive proof of all JSON-related behavior, or physical validation on the stable macOS/Ubuntu ARM64 hosts.

## Next action

For future parser modifications, update the workflow pinned parser commit and rerun the corpus. When broader parser closure is authorized, validate the emitted compact JSON values and undertake any required revision-bound `rumiai-validate` / physical host validation. This request's JSONTestSuite parsing check requires no further action.

## Blockers / open questions

None for the requested JSONTestSuite parsing check. Complete cross-host product validation and transform-output equivalence are distinct, unperformed validation levels; no evidence for them is claimed here.
