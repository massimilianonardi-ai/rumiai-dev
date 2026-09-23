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

PoC 020 is preserved under:

```text
rumiai-dev-PoCs/pocs/020-mk-watch-session/
```

The session-boundary experiment is complete. GitHub Actions run `35824307930` passed on both Ubuntu and macOS.

The validated working direction is:

```text
thin watch supervisor
-> run one complete one-shot mk request
-> establish trigger baseline after the cycle
-> wait for trigger identity change
-> run a fresh one-shot mk request
-> repeat
```

The experiment established:

- the supervisor can own repetition without extending one `_executeV2` invocation indefinitely;
- cycle failure can be reported while the watch session waits for a later trigger change instead of busy-looping;
- post-cycle baselining prevents a cycle's own filesystem effects from automatically causing an immediate second cycle;
- SIGINT/SIGTERM ownership can remain at the session layer and be forwarded to an active one-shot child.

This is still working design, not promoted contract.

The unresolved part is authoritative trigger derivation.

Current `mk.lib.js` already owns the relevant resolved identity machinery for incremental path/collection/output inputs, collection barriers, requirement-provider identities, executable/environment identity and current-request output/data evidence.

Therefore the outer watch supervisor must not reconstruct lifecycle trigger identity independently from `mk.json` or by scanning the project tree. The next experiment should derive an opaque deterministic trigger snapshot **inside the existing trusted mk engine** and expose only that snapshot to the session layer.

Open trigger questions include:

- whether project `mk.json` identity is always part of the trigger snapshot;
- how non-incremental reachable operations participate when they do not declare incremental inputs;
- whether executable/requirement-provider identity changes are watch triggers in the first baseline;
- how generated outputs are excluded or represented without feedback loops;
- recursive project-dependency watch ownership without graph flattening;
- portable polling cadence versus future host notification optimizations.

## Next action

Create **PoC 021 — mk internal watch trigger snapshot**.

The experiment should reuse/extract current incremental-resolution primitives rather than duplicate them. It should first target local-project requests and produce one opaque deterministic snapshot suitable for PoC 020's supervisor.

Do not add a public `--watch` CLI or promote watch semantics to `MK.md` until trigger identity is settled.

## Blockers / open questions

- authoritative trigger identity for non-incremental lifecycle work;
- recursive project-dependency watch ownership;
- portable polling policy versus optional host notification backends;
- formal `rumiai-validate` still requires its own managed-Node provisioning solution.
