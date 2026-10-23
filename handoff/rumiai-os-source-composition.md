# RumiAI OS source composition comparison

Status: Active
Updated: 2026-10-23

## Goal

Investigate two genuinely independent ways to build a complete, clone-ready `rumiai-os` distribution from independently owned first-party component sources:

1. a minimal POSIX shell + Git + filesystem composition script;
2. the existing `mk` engine running with host Node.js and no pre-existing RumiAI OS.

Compare them on the same exact source revisions and target layout before selecting a production path. The intended eventual build combines component-owned runtime files and component-owned bootstrap definitions into the generated technical `m` bootstrap. Do not prematurely promote experimental source/repository placement or descriptor formats into canonical contract.

## Current repository revisions

Last verified:

- `rumiai-dev/main`: `9d2cd51ff023859376f80e1ea1806b39e2f9d386` before this handoff's creation.
- `rumiai-os/main`: `21bfd86728829e83bc7fff81f35dda0f8c2f925a` (advanced during the PoC without a relevant `mk` engine change).
- `rumiai-dev-PoCs/main`: `f31ab4f5edbef0eaaa1285e3a6ef0b5cc26df85e`.
- Experiment branch: `rumiai-dev-PoCs/rumiai-os-composition-comparison`, latest experiment commit `0c8f8fa098e5c74d8e2e15c6552a9c633a383048`.
- Tested `mk` engine source snapshot: `rumiai-os` `5ca07aeb26dbc04c0b38998bb05edacd8587a977` (pinned intentionally; not claimed as current HEAD).
- `rumiai-tests/main`: `02eb2c25221f6d399e6ed22c6d668824fa2a8b9d`; no permanent tests changed.

Reverify all remote heads and the staged native-interpreter migration before any additional work.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `handoff/README.md`.
- `specifications/README.md`; `specifications/rumiai-os/{CURRENT-MODEL,MK,BOOTSTRAP-ENVIRONMENT,ENTRYPOINT-ROOT-RESOLUTION,COMMAND-ENTRYPOINTS,LANG-BOOTSTRAP,STATE-MODEL,RESOURCE-MODEL}.md`.
- `handoff/javascript-command-bootstrap.md` for the separate active native interpreter migration.
- Current `rumiai-os/lib/sys/js/mk.lib.js`, `bin/sys/mk` and `rumiai-tests/tests/rumiai-os/mk/lifecycle.test` as factual implementation/test evidence.

## Fixed task-local choices

- Explore both build paths in parallel and measure them against the same exact source revisions and equivalent output trees.
- Use experiments in `rumiai-dev-PoCs`; do not change `rumiai-os/main` or its published specification merely to demonstrate candidates.
- Keep the POSIX compositor understandable and independent of `mk`, Node.js and installed RumiAI OS.
- Reuse the real `mk` engine through host Node.js for initially supported lifecycle functionality; do not fork or reimplement `mk`.
- Keep package management/integration with `pkg` distinct from project development/build orchestration by `mk`.
- A small seed script may be acceptable for bootstrap; do not select one approach as production contract before comparative evidence.

## Acceptance scenarios

1. Given independent source checkouts at recorded SHAs, an operator can build the same experimental distribution without installing RumiAI OS, via either path.
2. The generated technical bootstrap executes from a relocated physical root and exports contributed `pkg` and `lang` roots.
3. A plan-only `mk` request has no build side effects.
4. An unavailable pinned SHA causes both builders to fail without publishing a completed distribution.
5. Both paths produce equivalent contents and symlink identities under Linux and macOS.

These are experimental acceptance scenarios until a real-component design is promoted.

## Completed

- Added `rumiai-dev-PoCs/pocs/072-rumiai-os-composition` with three independent **local Git repositories generated from deliberately reduced fixtures** (`m`, `pkg`, `lang`), a standalone `build-posix.sh`, independent `mk.json` lifecycle, tests and hosted workflow.
- The builders clone all three repositories, check out the exact same SHAs, concatenate component-owned bootstrap fragments, install commands/resources and publish the tree. Tests compare tree content/modes/symlink identities and execute the resulting bootstrap.
- Real `mk.lib.js` from the pinned `rumiai-os` revision is run directly through host Node.js. No `m` launcher or managed Node installation is used.
- First hosted green run: GitHub Actions `39964211916`, PoC SHA `822555748e052dc6aad871e07046a60293fb21ae`; Ubuntu and macOS jobs passed.
- Expanded experimental tests to explicitly clear inherited `m` environment and reject missing source revisions. Green run `39964558371`, PoC SHA `ec09f5fd890342a1ddda7744d81026c6eafec5af`.
- Early macOS failures revealed actual portability issues in the experiment: BSD `diff -r` traversed a relative locale selector to report a directory loop; physical `/var` path resolution differs from logical temporary paths. Both checks were corrected. Earlier failed runs remain failed evidence, not PASS.

## Current state

The initial small-component comparison is implemented on an isolated PoC branch; the feature branch has not been merged into `rumiai-dev-PoCs/main`. The successful runs validate only the reduced composition scenario, not separation of the real core, `pkg` or `lang` implementation and not full RumiAI OS production builds. There is no product change, production deployment or physical-host validation.

The staged native-interpreter migration is separate; do not merge it or assume it is published as part of this composition experiment.

## Working design / open comparison

- Determine genuine component source boundaries without duplicating current `core.lib.sh`/`base.lib.sh` ownership.
- Establish component-owned bootstrap contributions and their dependency/collision checks using real sources, not new generic APIs invented before evidence.
- Compare incremental rebuilds, error recovery, provenance/pinning, symlink/mode handling and maintenance effort as the real distribution grows.
- `mk` v1 runs autonomously for the constrained graph; its public launcher, `pkg` facility requirements, `state-path` cache and `watch` have further environmental dependencies. Evaluate these rather than claiming all `mk` functionality is already standalone.
- The minimal shell script might remain the final assembler even if `mk` builds individual projects. This remains an option, not a chosen architecture.

## Next action

Expand PoC 072 from reduced fixtures to **real**, revision-pinned `rumiai-os` component content, beginning with a bounded root/bootstrap + `pkg`/`lang` ownership slice. Reconcile the staged native-command migration, make both builders consume identical inputs, and measure the actual complexity/collision and failure behaviors. Only then consider moving source ownership into separate repositories or promoting a production build contract.

## Blockers / open questions

Real component extraction has not been designed or validated; do not represent the small fixture demonstration as a composed full product. No blocker prevents continuing the PoC with existing repositories and pinned revisions.
