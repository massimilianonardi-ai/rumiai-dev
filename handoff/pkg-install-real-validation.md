# pkg install real validation

Status: Active
Updated: 2026-09-17

## Goal

Replace artificial permanent coverage of the public `pkg install` behavior with authentic coverage of the real composed command path, debug any product/catalog defect exposed by that path, and leave revision-specific validation claims limited to evidence actually executed.

## Current repository revisions

```text
rumiai-dev   b131c1c63a7c47e3605432177a8843ad0bd586f6
rumiai-os    8b0c7991e8242dac73b0a350530a5100385294f3
rumiai-tests 9eb8c7d2aadebde2cb7671ab84a2a3b313364119
pkg-catalog  94f58995cbd487b17f3b82bc2724c70540927b88
```

The task was repeatedly reconciled forward as repository HEADs advanced. Changes observed in `rumiai-dev` and `rumiai-os` after task activation were confined to the manual/documentation workstream and did not alter the package/testing contract or `pkg install` implementation.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
handoff/README.md
todo/README.md
```

The current `rumiai-tests/AUTHORING.md` and the shared `lib/rumiai-os-target.lib` / `lib/rumiai-os-fixture.lib` helper contracts were also applied to the test realignment.

## Fixed task-local choices

- The original TODO was activated into this handoff and removed in the same activation commit; the TODO and active handoff do not coexist.
- Permanent behavioral evidence for `pkg install` must use the real public command and real composed package pipeline. Replacing catalog, repository adapter, download, extraction or integration logic inside such a test is not acceptable evidence for that claim.
- Same-suite target discovery and complete isolated `rumiai-os` materialization use the current shared helpers when their contracts match.
- `tests/rumiai-os/pkg/install.test` owns public command/lexical-prevalidation behavior that can be proven without network-backed installation.
- `tests/external/nodejs/install-live.test` owns the real composed end-to-end installation evidence: public `pkg install nodejs`, real catalog, repository adapter, artifact download, extraction and integration on an isolated runnable `rumiai-os` replica.
- Component-specific package properties remain in their focused permanent tests; the public install test must not reconstruct those components to duplicate coverage.

## Implemented realignment

`rumiai-tests` commit `9eb8c7d2aadebde2cb7671ab84a2a3b313364119` (`Realign pkg install coverage`) changes only two files:

- `tests/rumiai-os/pkg/install.test`
  - removed direct sourcing of `pkg-install.lib.sh`;
  - removed the synthetic repository adapter and catalog fixture;
  - removed replacements for catalog snapshot, download, extraction, integration and default-selection behavior;
  - retained only public `bin/sys/pkg` contract and lexical/prevalidation checks on the real target checkout;
  - uses the shared target-discovery helper.
- `tests/external/nodejs/install-live.test`
  - retained the real public `pkg install nodejs` path and all existing live installation assertions;
  - replaced historical inline copies of target/fixture helper logic with the current shared helper libraries, matching the current authoring contract.

No `rumiai-os` or `pkg-catalog` implementation change has been made. Static inspection of the current public install path did not expose a product defect; any product/catalog correction remains contingent on a failure of the real composed execution.

## Validation evidence obtained

- `sh -n` passed for the exact two changed shell-test contents before the `rumiai-tests` commit. This is syntax-only evidence.
- The committed diff from `298931c1dca03d44755893d64b9b3a7c0058b7ea` to `9eb8c7d2aadebde2cb7671ab84a2a3b313364119` was re-read and contains only the two intended test files.
- Both committed test files were re-read from `9eb8c7d2aadebde2cb7671ab84a2a3b313364119`.
- A repository search found no remaining `pkg-repository-fixture` marker in `rumiai-tests`.
- The current `rumiai-os` install implementation was re-read after concurrent HEAD movement; the subsequent `rumiai-os` delta to `8b0c7991e8242dac73b0a350530a5100385294f3` changes only manual resources and does not touch the package path.
- The current Node.js catalog still declares all six supported streams: Linux/macOS/Windows on ARM64 and x86_64.
- `n0001=v26.8.2`, including `digest_type` and `env`, exists in all six supported Node.js streams at `pkg-catalog` revision `94f58995cbd487b17f3b82bc2724c70540927b88`; the live test's catalog anchor is therefore current for every declared target.
- The current canonical consistency-gate/testing sources were rechecked after concurrent documentation changes.

## Current state

The artificial permanent `pkg install` pipeline has been removed and the existing Node.js live test remains the authentic composed-path proof surface. The task is intentionally still Active because the required revision-specific live execution has not yet been obtained.

The auxiliary Linux container available in this chat cannot resolve `github.com`, so it cannot execute the network-backed live installation. Repository inspection and writes are available through the connected GitHub interface, but no executable CI/workflow route suitable for this live test was established in this session. Therefore no claim is made that `tests/external/nodejs/install-live.test` passes at the current revisions.

## Next action

On a current approved network-capable execution host, run the normal test/validation path for:

```text
tests/rumiai-os/pkg/install.test
tests/external/nodejs/install-live.test
```

Use the then-current repository revisions and runner contract. If the real composed Node.js installation fails, debug the actual failing product/catalog component and realign implementation, catalog and tests under the canonical package contract. If both tests pass and the final consistency gate is clean, update this handoff to `Status: Complete`, commit that state, then remove the completed handoff in a separate forward commit as required by the handoff contract.

## Blockers / open questions

- Revision-specific live execution on an approved network-capable host remains outstanding.
- No product/catalog defect is currently established; static inspection and catalog consistency checks alone are not substitutes for the live run.
