# mk tool development

Status: Active
Updated: 2026-09-23

## Goal

Continue development of `mk` as the `m` subsystem for project development-lifecycle orchestration, extending the promoted declarative lifecycle model from concrete needs while preserving subsystem boundaries.

## Current repository revisions

```text
rumiai-dev       1de3fbb032201c289538ccfbe4d8b1ea73fee45b  (pre-synchronization HEAD)
rumiai-os        92f0d459225ee4117f3c2cb32aa1b8aa9f17ec90
rumiai-tests     63a7c475cc96a0ff694c1061ccbada90f0826aef
rumiai-dev-PoCs  defccee6b182c161b325a3817a841eee031ed109
pkg-catalog      da7507439b71737cf4a40d85cac059824e4b9a63
```

Fresh remote HEAD retrieval remains mandatory before later work.

The current `rumiai-os` advances only package-repository implementation beyond the mk behavior used by PoC 024; PoC 025 was exercised directly against the current `92f0d459...` target.

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

## Current promoted mk model

Version 2 currently promotes and implements:

- contextual file collections;
- trusted operation providers;
- declarative conditions and result/output/state observation;
- named outputs and iterative refinement;
- recursive project-to-project dependency delegation;
- named external facility requirements resolved through `pkg`;
- first-class named operation input identity;
- opt-in content-based incremental freshness using those shared inputs.

Project `dependency`, operation `prerequisite`, external `requirement`, operation `input` and incremental reuse policy remain distinct.

## Incremental freshness

PoC 019 is preserved under:

```text
rumiai-dev-PoCs/pocs/019-mk-incremental-fingerprints/
```

The resulting incremental baseline remains promoted. Persistent metadata is non-authoritative user-scoped state rooted through:

```text
state-path user sys mk cache
```

A verified hit is `up-to-date`; mtime is not freshness identity; unsupported/corrupt evidence is a conservative miss; artifact bytes are not stored/restored; result-field observation still forces actual execution.

## Watch session experiments

### PoC 020 — session boundary

```text
rumiai-dev-PoCs/pocs/020-mk-watch-session/
```

GitHub Actions run `35824307930` passed on Ubuntu and macOS.

Validated working direction:

```text
thin watch supervisor
-> complete one-shot mk request
-> post-cycle trigger baseline
-> wait for trigger change
-> fresh one-shot mk request
-> repeat
```

The supervisor can own repetition, failed-cycle waiting and SIGINT/SIGTERM forwarding without extending one `_executeV2` invocation indefinitely.

### PoC 021 — internal trigger snapshot

```text
rumiai-dev-PoCs/pocs/021-mk-watch-trigger-snapshot/
```

Corrected GitHub Actions run `35824764421` passed on Ubuntu and macOS against the real current `mk.lib.js` through runtime instrumentation.

It established that an opaque deterministic trigger digest can be derived from the existing trusted mk resolver for already-declared lifecycle influences. It also demonstrated the real semantic gap:

```text
undeclared mutable input of non-incremental operation
    -> invisible to authoritative trigger identity
```

A second watch-specific input namespace was therefore not introduced.

## Shared operation input work unit

### PoC 022 — normalization

```text
rumiai-dev-PoCs/pocs/022-mk-shared-operation-inputs/
```

GitHub Actions run `35825100360` passed on Ubuntu and macOS.

It validated the normalization split:

```text
inputs
    operation data/change identity

incremental
    opt-in reusable freshness policy
```

Compatibility:

```text
legacy incremental.inputs
    -> shared normalized operation inputs + incremental enabled

inputs + incremental {}
    -> same shared normalized operation inputs + incremental enabled

inputs only
    -> shared normalized operation inputs + incremental disabled
```

A non-empty top-level `inputs` map plus a non-empty `incremental.inputs` map is rejected as ambiguous.

### PoC 023 — real resolver integration

```text
rumiai-dev-PoCs/pocs/023-mk-shared-inputs-real-resolver/
```

The experiment transforms the real current `mk.lib.js` in memory rather than copying its resolver.

Diagnostic runs:

```text
35825437879
    PoC source-instrumentation escaping failure; no candidate semantics exercised.

35825511309
    Ubuntu PASS; macOS harness used non-canonical /var/... while mkMain used
    canonical /private/var/..., producing different project cache identity.
```

After canonicalizing the internal-resolver project root exactly as `mkMain` does, final run:

```text
35825649079
Ubuntu PASS
macOS  PASS
```

The real-resolver experiment confirmed:

- legacy `incremental.inputs` and new `inputs + incremental {}` normalize identically inside the candidate engine;
- both use the same current incremental fingerprint machinery;
- both reach `up-to-date` through the normal persistent freshness path;
- `inputs` on a non-incremental operation are observable but do not enable cache reuse;
- output inputs create producer data dependencies without duplicate prerequisites;
- collection inputs use the existing collection reachability machinery;
- ambiguous duplicate declarations fail.

### PoC 024 — recursive watch trigger ownership

```text
rumiai-dev-PoCs/pocs/024-mk-recursive-watch-trigger/
```

Corrected GitHub Actions run:

```text
35827023231
Ubuntu PASS
macOS  PASS
```

against exact `rumiai-os` revision:

```text
fde0ae399da0994e19ff7657605017f809b8fe8e
```

The experiment validated recursive trigger ownership aligned with current project-dependency execution ownership:

```text
parent local trigger identity
+ active direct child request -> opaque child digest
-> parent digest
```

The parent consumes only dependency identity/request data and an opaque child digest. It does not flatten child operations, collections, requirements, inputs or incremental fingerprints.

Verified behavior includes:

- `A -> B -> C` propagation of deep child input changes through opaque child digests;
- mtime-only deep-child changes remain stable under content identity;
- parent/local changes do not mutate child digest identity;
- formatting-only child `mk.json` rewrites preserve digest identity through normalized-model semantics;
- inactive dependencies do not participate;
- explicit child profile selection participates only inside that child request;
- same-named operations across projects do not collide;
- dependency cycles are rejected by canonical project identity;
- in `A -> B/C -> D`, D is resolved independently through both sibling branches, preserving the current no-request-wide-de-duplication semantics.

The first diagnostic run `35826969986` failed only because its fixture mapped a nonexistent parent goal while trying to model an inactive dependency. The current validator correctly rejects that declaration. The fixture was corrected by using a real but unrequested goal; no product change was needed.

Observed result:

```text
child-trigger-identity=opaque-recursive
diamond-downstream-resolution=per-branch
```

### PoC 025 — transient invalid watch configuration

```text
rumiai-dev-PoCs/pocs/025-mk-watch-transient-invalid-config/
```

GitHub Actions run:

```text
35827415176
Ubuntu PASS
macOS  PASS
```

against exact current target:

```text
rumiai-os 92f0d459225ee4117f3c2cb32aa1b8aa9f17ec90
```

The experiment validated a separate trigger outcome for temporarily invalid root/child project configuration:

```text
configuration temporarily unavailable
    -> no lifecycle cycle
    -> retain last valid trigger baseline
    -> retry resolver

fatal trigger resolver failure
    -> terminate watch session
```

The classification belongs inside the trusted mk trigger resolver; the outer supervisor does not parse `mk.json` or reconstruct child dependency semantics.

Startup policy validated by the PoC:

```text
wait for first valid trigger snapshot
-> run initial one-shot request
-> establish post-cycle valid baseline
```

During an established session:

- temporary invalid root or active child configuration keeps the session alive;
- repeated polling while invalid does not busy-loop lifecycle execution;
- restoring identical normalized semantics produces no cycle;
- restoring valid configuration after a declared input changed produces exactly one cycle;
- invalidity is not encoded as an ordinary digest value;
- genuine resolver failure remains fatal.

Observed result:

```text
invalid-config=retry-with-last-valid-baseline
fatal-trigger-error=session-failure
```

Both temporary hosted workflows were removed after evidence collection.

## Promoted shared-input contract

The model was promoted in current `MK.md` and `CURRENT-MODEL.md`.

Current preferred declaration:

```json
{
  "inputs": {
    "source": {"path": "src/input.txt"},
    "sources": {"collection": "sources"},
    "generated": {"output": {"operation": "generate", "name": "artifact"}}
  },
  "incremental": {}
}
```

`inputs` is first-class operation data/change identity.

Declaring `inputs` alone:

- participates in path/collection/output data identity;
- makes referenced collections/producers reachable as appropriate;
- does not assert action purity;
- does not make the operation reusable or `up-to-date`.

Declaring `incremental` opts an ordinary process operation into reusable freshness using that same input map.

The previous form remains valid:

```json
{
  "incremental": {
    "inputs": {
      "source": {"path": "src/input.txt"}
    }
  }
}
```

It is normalized to the same shared operation input map.

Current invariants include MK-44 through MK-57 and CURRENT-49 through CURRENT-55.

## Product implementation

The shared-input implementation was introduced in `rumiai-os/lib/sys/js/mk.lib.js` at:

```text
58d797ac8d286f54420b279713c431ce97c1d53a
```

Manual alignment followed through:

```text
7a996e652016cd5a5edfcfd77963b8e12dc2a81a
a5e4ca011af107b43ad2b1b1f5b135b98ce29ae2
```

A later unrelated package-repository commit advanced the repository; the mk behavior tested below is unchanged in that current descendant.

Implementation details:

- operation parser accepts first-class `inputs`;
- legacy `incremental.inputs` normalizes into the shared map;
- derived `map-process` operations receive an empty shared input map;
- reference validation covers shared collection/output inputs;
- reachability/data dependency traversal is shared by incremental and non-incremental consumers;
- runtime records resolved operation input snapshots independently from incremental fingerprints;
- non-incremental inputs may block on unresolved producer/collection data but never produce `up-to-date`;
- incremental freshness consumes the same shared input resolver;
- structured version-2 operation plan entries expose normalized `inputs`.

Freshness records remain non-authoritative. An engine/schema evolution may conservatively cause old records to miss; preserving old cache hits is not required, while false hits remain forbidden.

## Permanent tests and validation evidence

New permanent executable:

```text
tests/rumiai-os/mk/inputs.test
```

It protects:

- ordinary non-incremental path input declaration;
- no accidental cache reuse from `inputs` alone;
- non-incremental output-input producer data dependency;
- collection input reachability;
- new `inputs + incremental {}` reuse;
- legacy `incremental.inputs` compatibility;
- ambiguous dual declaration rejection.

Task validation scope:

```text
validation/mk-shared-operation-inputs.conf

rumiai-os-commit d50e5f096ea56c1afd4d19a0ae1361e9ce6326b0
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
rumiai-os/mk/project-dependency.test
rumiai-os/mk/requirement.test
rumiai-os/mk/incremental.test
rumiai-os/mk/inputs.test
```

Hosted development validation:

```text
GitHub Actions run 35826099148

exact rumiai-os
    d50e5f096ea56c1afd4d19a0ae1361e9ce6326b0

exact rumiai-tests behavior revision
    2576ed3b4c594f31a7945e00cd326280107a6916
```

Both GitHub-hosted Ubuntu and macOS completed:

```text
PASS rumiai-os/mk/lifecycle.test
PASS rumiai-os/mk/refinement.test
PASS rumiai-os/mk/project-dependency.test
PASS rumiai-os/mk/requirement.test
PASS rumiai-os/mk/incremental.test
PASS rumiai-os/mk/inputs.test
PASS 6 / FAIL 0 / SKIP 0 / ERROR 0
```

The later `inputs.test` commit only corrects an invariant number in a failure diagnostic; executable assertions are unchanged.

The temporary hosted workflows were removed after evidence collection.

Formal `rumiai-validate` remains unclosed because the disposable validation target still lacks a managed/default Node provisioning path; required SKIP is not PASS.

## Current watch design status

Watch/hot-update itself remains **unpromoted and unimplemented**.

The evidence now supports this architecture:

```text
existing mk resolver
    -> authoritative trigger identity from normalized model + declared inputs/
       conditions/requirements/executable/output evidence
    -> opaque deterministic trigger digest

thin long-running supervisor
    -> compare digest
    -> run fresh one-shot mk request when it changes
```

First-class operation inputs remove the local-project undeclared-input gap when the project declares its actual change-driving data, without creating `watch.inputs`.

PoC 024 and PoC 025 now close two previously open design questions:

- recursive project-dependency trigger ownership is child-owned and opaque, without graph flattening;
- transient invalid root/child configuration is a retryable trigger-unavailable state, distinct from fatal resolver failure.

Remaining design questions before a public watch contract:

- exact local trigger composition for reachable non-incremental executable identity, requirements and output evidence without introducing generated-output feedback loops;
- portable polling policy versus optional host notification backends;
- lifecycle-cycle failure policy/options beyond the current PoC 020 continue-wait baseline;
- eventual user-facing representation of temporary trigger-unavailable diagnostics/status.

## Next action

Create **PoC 026 — watch trigger composition**.

Stress the current real resolver and determine the minimum authoritative local digest inputs for all reachable operations, especially:

```text
non-incremental process executable identity
facility requirement provider identity
incremental output validity
producer output used as declared downstream input
generated outputs that must NOT become self-triggering watch inputs
```

Prefer reusing existing trusted `mk` executable/requirement/input/output identity functions. Do not build a second filesystem or provider resolver.

Keep watch as working design. Do not add public `--watch` CLI/session semantics until trigger composition and the remaining session/polling policy are settled.

## Other remaining non-watch boundaries

Still outside the current baseline:

```text
artifact storage/restoration
shared/remote cache
provider-level incremental templates
parallel scheduling
remote execution
public generic provider/plugin registration
request-wide exactly-once/de-duplication
```
