# pkg install real validation

Status: Active
Updated: 2026-09-17

## Goal

Replace artificial permanent coverage of the public `pkg install` behavior with authentic coverage of the real composed command path, debug any product/catalog defect exposed by that path, and leave revision-specific validation claims limited to evidence actually executed.

## Current repository revisions

```text
rumiai-dev   140ab998bd60feba5b19cf40f07fd92f2d5c82d9
rumiai-os    36c29d8412a523f722fd90004b78a07fdf0b06c8
rumiai-tests 298931c1dca03d44755893d64b9b3a7c0058b7ea
pkg-catalog  94f58995cbd487b17f3b82bc2724c70540927b88
```

`rumiai-dev` and `pkg-catalog` advanced after the first preflight observation. The task was reconciled to the revisions above before activation; the `rumiai-dev` change was confined to `specifications/rumiai-os/DOCUMENTATION-MODEL.md` and did not alter the package/testing contract.

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

## Fixed task-local choices

- This task activates `todo/pkg-install-real-validation.md`; the TODO and active handoff must not coexist after activation.
- Permanent behavioral evidence for `pkg install` must use the real public command and real composed package pipeline. Replacing catalog, repository adapter, download, extraction or integration logic inside such a test is not acceptable evidence for that claim.
- Existing same-suite helpers `lib/rumiai-os-target.lib` and `lib/rumiai-os-fixture.lib` are the normal reusable infrastructure for target discovery and a complete isolated runnable `rumiai-os` replica when their contracts match.
- Existing `tests/external/nodejs/install-live.test` already exercises `pkg install nodejs` through the real public command on an isolated real-runtime replica and therefore must be considered before adding duplicate live coverage.

## Working design

The current `tests/rumiai-os/pkg/install.test` mixes valid public CLI/error checks with artificial reconstruction of install internals: it sources `pkg-install.lib.sh` directly, injects a synthetic repository adapter/catalog, and replaces catalog snapshot, download, extraction and integration behavior. The exact correction is still being selected after comparing its claimed properties with existing lower-level tests and the current Node.js live install test. The preferred direction is to remove duplicate/artificial claims rather than reproduce the same end-to-end installation twice.

## Completed

- Re-ran remote-HEAD preflight for all repositories in scope.
- Re-read the current mandatory RumiAI development/testing sources and package contract.
- Inspected the current `pkg install` permanent test and identified the artificial-path violations.
- Inspected the shared target/isolated-replica helpers.
- Identified existing real composed coverage in `tests/external/nodejs/install-live.test`.

## Current state

No product, catalog or permanent-test implementation has been changed yet. The auxiliary Linux container available in this chat cannot resolve `github.com`, so it cannot clone the repositories or provide network-backed execution evidence. Repository inspection and writes are available through the connected GitHub interface; any execution claim still requires a real executable environment.

## Next action

Inspect the current public `pkg`/install implementation, the current catalog package definitions and validation configuration, then classify each property in `tests/rumiai-os/pkg/install.test` as keep/simplify/merge/remove against existing permanent coverage. Apply the smallest authentic test realignment, fix product/catalog behavior only if the real path exposes a defect, and run the strongest real validation environment available.

## Blockers / open questions

- A network-capable executable environment for the final real install run has not yet been established in this session.
- No package/product defect is assumed before the real composed path is executed.
