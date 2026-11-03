# POSIX JSON command

Status: Active
Updated: 2026-11-03

## Goal

Implement a standalone, strictly POSIX `#!/bin/sh` JSON parser command in `rumiai-os/bin/sys/`, independently rewritten with RFC 8259 / ECMA-404 syntax coverage, permanent tests and the matching operational manual.

## Current repository revisions

- `rumiai-dev`: `c2f384fc2ec443b3d31ec6df6cd116cadf0173b5` (before this handoff checkpoint)
- `rumiai-os`: `4ffc3af233c4ff7ceccdb67eb6ac5e21b0be8e9f` (parser committed at `caf001f98e935a3c378be5feafb293f35d103d6d`)
- `rumiai-tests`: `502bab8beabdfe6c0c0c5c55c37f7ceac0556118`

All revisions were freshly checked after concurrent, unrelated branch changes. Recheck current HEADs before any future write.

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

## Current state

The command, its operational manual, and executable permanent test are committed and mutually consistent at the revisions above. Proportional auxiliary Linux tests passed, but no complete JSONTestSuite run, formal `rumiai-validate` revision-bound validation, or real cross-host/physical validation has yet been performed. Do not infer total conformance solely from the exploratory coverage.

## Next action

Run all applicable `nst/JSONTestSuite` `y_`/`n_` inputs against the exact published parser; investigate deviations, update permanent tests where appropriate, and execute formal revision-bound and materially different POSIX host validation if available. Follow the current consistency gate after any correction.

## Blockers / open questions

- Complete JSONTestSuite input corpus was inspected at the taxonomy/list level but not downloaded and executed in this work unit; keep unvalidated cases explicit.
- No operator input currently required.
