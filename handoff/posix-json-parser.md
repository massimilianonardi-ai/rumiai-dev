# POSIX JSON command

Status: Active
Updated: 2026-11-03

## Goal

Implement a standalone, strictly POSIX `#!/bin/sh` JSON parser command in `rumiai-os/bin/sys/`, independently rewritten with RFC 8259 / ECMA-404 syntax coverage, permanent tests and the matching operational manual.

## Current repository revisions

- `rumiai-dev`: `e2980759d37a8ea0369922745d99321839ebc57d`
- `rumiai-os`: `ff5156443a7d900bac4f1342480fbafc42e0a503`
- `rumiai-tests`: `324da93d6c69125770f0e7fd2338de7368dee4d3`

These revisions were checked after concurrent unrelated branch advancement. Fresh HEAD retrieval remains required before each write.

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

- Verified the involved remote HEADs; read the current canonical repository contracts and inspected current JSON library/test and command/manual layout.
- Analysed the two shell implementations and JSONTestSuite taxonomy.
- Implemented an auxiliary local prototype; 56 handcrafted positive/negative cases, 300 generated JSON documents, nesting depth 10,000 and a 1 MB string passed in the auxiliary Linux environment.

## Current state

The prototype is present only in an auxiliary workspace, not yet committed to `rumiai-os`. Final portability review, permanent tests, operational manual, publication and final consistency gate remain.

## Next action

Refine/validate the standalone command, add the command + manual to `rumiai-os`, then commit permanent JSON conformance tests to `rumiai-tests`; run final consistency review and synchronize this handoff.

## Blockers / open questions

No operator decision is currently required. Complete JSONTestSuite execution and cross-host validation have not yet been evidenced.
