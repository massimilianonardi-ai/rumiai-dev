# mk tool development

Status: Active
Updated: 2026-09-23

## Goal

Continue development of `mk` as the `m` subsystem for project development-lifecycle orchestration, extending the promoted declarative lifecycle model from concrete project needs without duplicating responsibilities already owned by `pkg`, state-path or external build tools.

## Current repository revisions

```text
rumiai-dev       f8ad0c2b507200501a7557f6e5a3db54f828b6ce  (pre-synchronization HEAD)
rumiai-os        f2747e16560d0fbbe1cc0fe6e4d5c6c836ef041b
rumiai-tests     a238deb4c54bfd6542da6b29402201b9ce77c2d2
rumiai-dev-PoCs  86d64c9167879076316961e8762bb12963f7a534
pkg-catalog      6a77995d317f2ec08c98585c4462b92557ccfaea
```

Fresh remote HEAD retrieval remains mandatory before later work.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
RUNNER.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/CURRENT-MODEL.md
specifications/rumiai-os/MK.md
specifications/rumiai-os/STATE-MODEL.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
handoff/README.md
```

## Completed model

Version 2 currently promotes and implements:

- contextual file collections;
- trusted operation providers;
- declarative conditions and result/output/state observation;
- named outputs and iterative refinement;
- recursive project-to-project dependency delegation;
- named external facility requirements resolved through `pkg`;
- explicit content-based incremental freshness for ordinary process operations.

Project `dependency`, operation `prerequisite`, external `requirement` and incremental input/data relations remain distinct.

## Incremental freshness work unit

PoC 019 is preserved under:

```text
rumiai-dev-PoCs/pocs/019-mk-incremental-fingerprints/
```

The resulting baseline is already promoted in `MK.md` and `CURRENT-MODEL.md`, implemented in current `rumiai-os/lib/sys/js/mk.lib.js`, documented by current manuals and protected by:

```text
tests/rumiai-os/mk/incremental.test
validation/mk-incremental-freshness.conf
```

The validation scope is pinned to the current product revision:

```text
rumiai-os-commit f2747e16560d0fbbe1cc0fe6e4d5c6c836ef041b
```

Current incremental contract:

- opt-in `incremental.inputs` supports path, collection and named-output sources;
- existing named `outputs` are the reusable output-evidence surface;
- content identity uses deterministic SHA-256-based snapshots and excludes mtime;
- effective action/environment/executable identity and satisfied facility-provider identities participate in freshness;
- reusable state requires both matching effective fingerprint and matching current declared outputs;
- a verified hit is `up-to-date` and satisfies prerequisites, collection `after` barriers and output/data evidence;
- `up-to-date` does not fabricate process-result fields; reachable result observation forces execution;
- successful execution refreshes non-authoritative user-scoped metadata rooted through `state-path user sys mk cache`;
- missing/corrupt/unsupported cache data is a conservative miss;
- `--plan` may read but does not write freshness metadata;
- the baseline stores metadata only, not artifact bytes;
- project dependencies remain recursively delegated and each child owns its incremental decisions.

The previous handoff still described PoC 019 as unpromoted; current specifications, implementation and permanent tests show that statement was stale. This handoff has now been reconciled to the current branch state.

## Current state

The current one-shot lifecycle is:

```text
resolve requested project/dependencies/context/requirements
-> establish verified up-to-date operations where possible
-> execute ready work
-> observe results/outputs/state
-> refresh successful freshness metadata
-> refine
-> complete
```

The current baseline deliberately still excludes:

```text
artifact storage/restoration
shared/remote cache
provider-level incremental templates
parallel scheduling
remote execution
watch/hot-update session semantics
public generic provider/plugin registration
request-wide exactly-once/de-duplication
```

## Working design — watch/hot-update

The next stress case is long-running watch/hot-update behavior.

Initial design question:

Can watch be a **session/supervision layer around complete one-shot mk requests** rather than extending one `_executeV2` invocation indefinitely?

The candidate direction to test is:

```text
watch session
-> run one normal mk request
-> observe declared change triggers
-> on relevant change, start a fresh normal mk request
-> repeat
```

This would preserve the already-promoted one-shot resolver/refinement/freshness semantics and naturally reuse incremental hits. It is not yet a promoted contract.

Questions the PoC must settle before specification changes:

- what exact declared/project-derived surfaces form the watch trigger set;
- whether `mk.json` changes trigger a full fresh reload;
- how collection membership changes are detected without watching generated outputs and causing loops;
- how project dependencies participate without flattening or introducing global session ownership;
- whether the portable baseline should poll content identity rather than depend on host-specific file notification APIs;
- cancellation/signal and failed-cycle behavior;
- whether a watch cycle always runs a fresh child `mk` process or may call the same engine in-process while preserving equivalent isolation.

## Next action

Create and exercise **PoC 020 — mk watch session** in `rumiai-dev-PoCs`.

Start with local-project scenarios only and test the session boundary before changing `MK.md` or `rumiai-os`.

Do not promote a public `--watch` CLI or project schema until the trigger/ownership semantics are sufficiently settled.

## Blockers / open questions

- watch trigger identity and generated-output exclusion;
- recursive project-dependency watch ownership;
- cycle failure/retry semantics and signal handling;
- formal `rumiai-validate` still requires its own managed-Node provisioning solution.
