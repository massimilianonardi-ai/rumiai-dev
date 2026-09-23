# mk tool development

Status: Active
Updated: 2026-09-23

## Goal

Continue development of `mk` as the `m` project development-lifecycle orchestrator, extending the promoted version-2 model from concrete project needs while preserving subsystem boundaries.

## Current repository revisions

```text
rumiai-dev       54be82eae3e9781b8ee1b10795de1505d79b86a4  (pre-synchronization HEAD)
rumiai-os        c3c51e6f070c774c103eeb7f71c759e3ebfda4ec
rumiai-tests     dd33d9d8c69d053c49f2d521efaf568e965d0842
rumiai-dev-PoCs  7195c53517dc3bd3b4c3244fbb9458670ebb5213
pkg-catalog      da7507439b71737cf4a40d85cac059824e4b9a63
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

Add other current subsystem specifications only when a later mk work unit crosses their boundary.

## Current promoted mk model

Version 2 currently promotes and implements:

- contextual file collections;
- trusted operation providers;
- declarative conditions and result/output/state observation;
- named outputs and iterative refinement;
- recursive project-to-project dependency delegation;
- named external facility requirements resolved through `pkg`;
- first-class named operation input identity;
- opt-in content-based incremental freshness for ordinary configured operations and derived `map-process` members;
- shared-local verified artifact publication/restoration for incremental declared outputs, with project-scoped freshness metadata and fingerprint-shared artifact bytes;
- long-running `--watch` execution using resolver-owned trigger identity and fresh one-shot lifecycle cycles.

Project `dependency`, operation `prerequisite`, external `requirement`, operation `input`, incremental reuse policy and watch/session semantics remain distinct.

The current baseline still excludes:

```text
remote/network artifact transport
cross-user artifact sharing/trust
artifact eviction/garbage collection and abandoned-staging reclamation
parallel scheduling
remote execution
public generic provider/plugin registration
request-wide exactly-once/de-duplication
```

## Watch work unit

PoC evidence is preserved under:

```text
pocs/020-mk-watch-session
pocs/021-mk-watch-trigger-snapshot
pocs/024-mk-recursive-watch-trigger
pocs/025-mk-watch-transient-invalid-config
pocs/026-mk-watch-trigger-composition
pocs/027-mk-watch-fresh-bootstrap
pocs/028-mk-public-watch-baseline
```

in `rumiai-dev-PoCs`. Durable semantics are promoted in current `MK.md` and `CURRENT-MODEL.md`; the handoff does not duplicate those contracts.

Current watch implementation was introduced in `rumiai-os` by:

```text
db3bf21ee6a62437ed7d59078bbcca091143148c
    implement mk watch execution mode

886adf2825077568dd48900d4f01a372bc499fc1
    handle asynchronous mk watch failures

b98a322faa86cc51adeadc24bb4357cb24af11a9
    support asynchronous mk execution
```

Current product manuals were realigned in this work unit:

```text
4ae71be59af18780e31b449f86406c482dc187c4
    res/sys/manual/mk

48bd93440ef78b809b6b952429cc4f8b9ea7a523
    res/sys/manual/mk.lib.js
```

The public launcher remains `bin/sys/mk`, and the JS library continues to expose only `mkMain`; watch helpers remain private implementation.

## Permanent watch regression

New permanent executable:

```text
tests/rumiai-os/mk/watch.test
```

Final behavior revision:

```text
rumiai-tests 1bc56753ecb0eba231454e16547e699a1b09ddbd
```

It protects the promoted watch contract through the real public `bin/sys/mk` path, including:

- version-2-only `--watch` and incompatible introspection/planning options;
- no public polling-interval option;
- initial cycle and mandatory post-cycle baseline;
- unchanged/mtime-only stability;
- declared path input trigger identity;
- executable identity trigger;
- exclusion of ordinary non-incremental unconsumed output bytes;
- recursive active-child trigger propagation;
- temporary invalid root/child configuration pause and unchanged/changed recovery;
- failed lifecycle cycle report-and-wait behavior;
- SIGTERM termination while a one-shot lifecycle child is active.

Two harness corrections were required before permanent validation:

1. the failure-cycle scenario originally changed its input as soon as the initial action trace appeared, racing the supervisor's mandatory post-cycle baseline; the test now allows that infrastructure step to settle before introducing the next trigger;
2. the signal scenario originally used an infinite process-action grandchild, accidentally testing process-tree termination that CURRENT-62 does not specify and retaining workflow streams after the one-shot child was signalled; the action is now finite while still keeping the one-shot lifecycle child active long enough to verify supervisor termination.

These were test-observability corrections, not product semantic changes.

## Watch validation evidence

Task scope:

```text
validation/mk-watch.conf

rumiai-os-commit 48bd93440ef78b809b6b952429cc4f8b9ea7a523
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
rumiai-os/mk/project-dependency.test
rumiai-os/mk/requirement.test
rumiai-os/mk/incremental.test
rumiai-os/mk/inputs.test
rumiai-os/mk/watch.test
```

Successful hosted development run:

```text
GitHub Actions run 35838254578

exact rumiai-os
    48bd93440ef78b809b6b952429cc4f8b9ea7a523

exact rumiai-tests behavior revision
    1bc56753ecb0eba231454e16547e699a1b09ddbd
```

Both GitHub-hosted Ubuntu and macOS completed:

```text
PASS rumiai-os/mk/lifecycle.test
PASS rumiai-os/mk/refinement.test
PASS rumiai-os/mk/project-dependency.test
PASS rumiai-os/mk/requirement.test
PASS rumiai-os/mk/incremental.test
PASS rumiai-os/mk/inputs.test
PASS rumiai-os/mk/watch.test

PASS 7 / FAIL 0 / SKIP 0 / ERROR 0
```

The macOS Node.js upstream 403 occurred on earlier diagnostic runs but did not occur in the successful final run.

The temporary hosted workflow was removed after evidence collection.

Formal `rumiai-validate` status has not been re-established by this hosted run; hosted GitHub evidence must not be relabelled as formal validation.

## Provider incremental work unit

PoC 029 is preserved under:

```text
rumiai-dev-PoCs/pocs/029-mk-provider-incremental/
```

It validated the provider-level model that is now promoted in current `MK.md` / `CURRENT-MODEL.md` and implemented in current `rumiai-os/lib/sys/js/mk.lib.js`:

```text
map-process provider template
    + ordinary shared inputs
    + ordinary declared outputs
    + incremental: {}

trusted derivation
    -> one ordinary derived incremental operation per collection item
    -> private $item path input
    -> ordinary per-operation freshness/cache record
```

There is no provider-level aggregate cache record. Derived identity is item-based rather than enumeration-position-based.

This continuation discovered two consistency gaps after that behavior had already been promoted/implemented:

1. the current `mk` manuals still described provider incremental templates as absent;
2. the permanent test suite had no dedicated regression for MK-69 through MK-75 / CURRENT-63 through CURRENT-66.

Manual realignment:

```text
53f089aa6d528709ed59d3d6f5728331b3a4c84e
    res/sys/manual/mk

5f01f0bccef37020057195c98809ba492f02443c
    res/sys/manual/mk.lib.js
```

New permanent executable:

```text
tests/rumiai-os/mk/provider-incremental.test
```

introduced at:

```text
248a4b066022d246d692f0d7f8f489126e6b8e74
```

It protects through the real public `bin/sys/mk` path:

- private derived `$item` input;
- `${item}` substitution in provider path inputs and output paths;
- initial per-member execution and independent `up-to-date` reuse;
- mtime-only stability;
- selective invalidation from mapped-item content, templated path input and declared-output tampering;
- add/remove collection membership without invalidating unchanged item identities;
- non-incremental provider templates remaining non-reusable;
- rejection of provider `incremental: {}` without outputs;
- rejection of provider legacy `incremental.inputs`;
- rejection of project-configured `$item`.

Task scope:

```text
validation/mk-provider-incremental.conf

rumiai-os-commit 5f01f0bccef37020057195c98809ba492f02443c
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
rumiai-os/mk/project-dependency.test
rumiai-os/mk/requirement.test
rumiai-os/mk/incremental.test
rumiai-os/mk/inputs.test
rumiai-os/mk/provider-incremental.test
rumiai-os/mk/watch.test
```

Hosted evidence uses exact behavior revisions:

```text
rumiai-os    5f01f0bccef37020057195c98809ba492f02443c
rumiai-tests 248a4b066022d246d692f0d7f8f489126e6b8e74
```

Useful runs:

```text
35841398987
    Ubuntu: all 8 scope tests PASS.
    macOS: Node provisioning blocked by upstream HTTP 403 before tests.

35841585093
    macOS: all 8 scope tests PASS after managed Node provisioning succeeded.
    Ubuntu: provider-incremental and preceding mk tests PASS; watch.test produced
            an intermittent test-infrastructure ERROR.

35841978004
    Ubuntu diagnostic rerun of unchanged watch.test: PASS.
    macOS provisioning again blocked upstream before the diagnostic test.
```

The Ubuntu watch ERROR is not a reproducible contract failure: the same unchanged `watch.test`, target and behavior revision passed in run `35841398987` and in the diagnostic rerun `35841978004`; macOS passed the complete unchanged scope in run `35841585093`.

The temporary provider-incremental hosted workflow has been removed.

Formal `rumiai-validate` evidence is still not re-established by these hosted runs and must not be inferred from them.

## Local artifact restoration work unit

PoC 030 is preserved under:

```text
rumiai-dev-PoCs/pocs/030-mk-local-artifact-restoration/
```

Its final experiment run `35843428637` passed on Ubuntu and macOS and supported the model now promoted as MK-76 through MK-81 / CURRENT-67 through CURRENT-71.

Product implementation and manual alignment are current in `rumiai-os`:

```text
617a1cf22bf5cbe27bf278c744aa9164f9e1e9a9
    implement local mk artifact restoration

e97844988f6c82c6fd7ede6363953923fb184369
    document local mk artifact restoration

533095820ea4f22446510a0f7b338253d908d018
    document mk artifact restoration engine
```

A new permanent executable now protects the promoted contract through the real public `bin/sys/mk` path:

```text
tests/rumiai-os/mk/artifact-restoration.test
```

introduced at `9688e57301045bbbdde447173c43fea53695e844`.

It covers execution-only restoration, read-only planning, regular-file and directory-tree outputs, multiple outputs, output-input consumers, provider-derived members, corrupt-store conservative misses, result-observation forcing actual execution and canonical-root isolation of copied/moved checkouts.

The work unit exposed two stale permanent-test expectations from the pre-restoration baseline and realigned them forward:

```text
9a1ab3fa810ed589fc7a6fac72a2beaac8728bc1
    incremental.test: tampered outputs may be restored without action execution

e8c7fa37a34d34ba0f0a6ae351042580b0bc2c6b
    provider-incremental.test: derived-member outputs use the same restoration path
```

Task scope:

```text
validation/mk-artifact-restoration.conf

rumiai-os-commit 533095820ea4f22446510a0f7b338253d908d018
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
rumiai-os/mk/project-dependency.test
rumiai-os/mk/requirement.test
rumiai-os/mk/incremental.test
rumiai-os/mk/inputs.test
rumiai-os/mk/provider-incremental.test
rumiai-os/mk/watch.test
rumiai-os/mk/artifact-restoration.test
```

Hosted development run `35845891876` exercised the exact target `533095820ea4f22446510a0f7b338253d908d018` and test behavior revision `e8c7fa37a34d34ba0f0a6ae351042580b0bc2c6b`.

Ubuntu completed all nine required tests:

```text
PASS lifecycle
PASS refinement
PASS project-dependency
PASS requirement
PASS incremental
PASS inputs
PASS provider-incremental
PASS watch
PASS artifact-restoration
```

The macOS job in that run and a dedicated retry `35846003232` did not reach tests because real `pkg install nodejs` received HTTP 403 from the Node.js distribution endpoint. This is provisioning/upstream evidence, not an mk behavior failure.

The temporary hosted workflow was removed after evidence collection.

Formal `rumiai-validate` remains unclosed; hosted evidence is not formal validation.

## Shared-local artifact work unit

PoC evidence is preserved under:

```text
rumiai-dev-PoCs/pocs/031-mk-cross-checkout-artifact-identity/
rumiai-dev-PoCs/pocs/032-mk-concurrent-shared-artifacts/
```

PoC 031 established the identity split:

```text
freshness metadata
    canonical project root + operation scoped

artifact bytes
    user-local and keyed by the existing effective operation fingerprint
```

Its corrected hosted run `35846792755` passed on Ubuntu and macOS against exact `rumiai-os` revision `533095820ea4f22446510a0f7b338253d908d018`.

PoC 032 closed the concurrency promotion blocker. GitHub Actions run:

```text
35854778813
```

passed on Ubuntu and macOS against exact `rumiai-os` revision:

```text
446418f1a9bfd31238088b8dee81a29e0c814b14
```

Observed:

```text
publication=immutable-candidate+atomic-selector
equivalent-writers=idempotent-no-global-lock
corrupt-refresh=no-delete-of-committed-candidate
freshness-metadata=project-scoped
```

The validated protocol is:

```text
<mk-cache>/shared-artifacts/<effective-fingerprint>/
    current
    candidates/
        <immutable-candidate>/
            manifest.json
            payload/...
```

A publisher prepares/verifies private staging first. Equivalent writers may converge on the same deterministic candidate. A small `current` selector is replaced atomically and points only to a fully verified immutable candidate. Writers never destructively replace another process's committed candidate.

A corrupt selected candidate is a conservative miss. Refresh publishes another immutable verified recovery candidate and atomically selects it; the prior candidate is not deleted while a reader may still hold its identity.

Committed unselected candidates and abandoned staging are deliberately not reclaimed by the publication path. Safe garbage collection remains a separate future responsibility.

## Promoted shared-local artifact contract

The PoC 031/032 model is promoted in current:

```text
specifications/rumiai-os/MK.md
specifications/rumiai-os/CURRENT-MODEL.md
```

Promotion commits:

```text
e845f2894b2d2e4b5bf74805de0e8316fa433db6
    MK.md shared-local artifact contract

54be82eae3e9781b8ee1b10795de1505d79b86a4
    CURRENT-MODEL.md shared-local artifact contract
```

Current invariants include MK-81 through MK-85 and CURRENT-71 / CURRENT-73 through CURRENT-75.

The promoted contract requires:

- freshness metadata remains canonical-project-root/operation scoped;
- artifact bytes may be reused across canonical project roots by the existing effective operation fingerprint;
- no second operation identity is introduced;
- `--plan` remains non-mutating and never restores outputs or creates receiving-checkout freshness metadata;
- execution may restore without a pre-existing receiving-checkout freshness record;
- successful restore writes and verifies the receiving checkout's own freshness record;
- published candidates are immutable and selected atomically;
- equivalent concurrent publishers are idempotent without a global lock;
- corrupt shared state is a conservative miss and is recovered non-destructively;
- shared-local reuse does not imply remote transport, cross-user trust, GC, distributed locking, parallel scheduling or request-wide exactly-once semantics.

## Product implementation

The shared-local artifact implementation was introduced in:

```text
699c77923cda2cd5fd58844f29a6dc9e175d760b
    lib/sys/js/mk.lib.js
```

Manual alignment followed through:

```text
276cc837babaec38489ee40d080cef4953f9ed87
    res/sys/manual/mk

c3c51e6f070c774c103eeb7f71c759e3ebfda4ec
    res/sys/manual/mk.lib.js
```

The implementation changes only artifact publication/restoration mechanics. Existing operation fingerprints, project-scoped freshness identity, lifecycle resolution, project dependencies, requirements, provider derivation and watch semantics remain unchanged.

The product now:

- stores artifact namespaces below user-scoped `shared-artifacts/<fingerprint>`;
- publishes verified immutable candidates;
- uses an atomic regular-file selector per fingerprint;
- converges equivalent concurrent publishers on one deterministic candidate when possible;
- publishes a uniquely named recovery candidate when a deterministic committed candidate is corrupt;
- never removes committed candidates from the writer path;
- restores from a selected verified candidate without requiring local freshness metadata;
- stages/verifies destination bytes before final replacement;
- writes and reads back receiving-checkout freshness metadata before treating restore as successful;
- falls back conservatively to action execution when restoration or local freshness establishment cannot be verified.

The JS library continues to export only `mkMain`; the new artifact helpers remain private.

## Permanent tests and validation

Existing permanent executable:

```text
tests/rumiai-os/mk/artifact-restoration.test
```

was realigned for the promoted shared-local contract at:

```text
10a27b32e0adce996b74622d8cad6e61241e1069
```

It now protects cross-checkout restore, read-only planning, receiving-checkout freshness establishment and corrupt selected-candidate conservative miss/recovery through the real public `bin/sys/mk` path.

New permanent executable:

```text
tests/rumiai-os/mk/shared-artifact-concurrency.test
```

introduced at:

```text
096bdcd9e701f328509925433dac14f1453ecfc3
```

It protects:

- concurrent equivalent publishers through the real public `mk`;
- one deterministic committed candidate for equivalent concurrent publication;
- concurrent cross-checkout restores without action execution;
- project-scoped freshness records in each receiving checkout;
- corrupt selected-candidate conservative execution/refresh;
- non-destructive immutable recovery;
- no normal staging/selector temporary leakage.

The shared-local promotion exposed two superseded expectations in `incremental.test`:

```text
a520387658ca9efa34331ba1639ebfe066a82c27
    corrupt local freshness must not be treated as up-to-date, but execution may
    recover through separately verified shared artifact state

609158df06efe08b594be9174ad37a150fa6c5a6
    returning from an alternate profile to an earlier fingerprint may restore the
    earlier verified artifact rather than forcing action execution
```

These are test realignments to the promoted freshness/artifact separation, not product fixes.

Task scope:

```text
validation/mk-shared-artifacts.conf

rumiai-os-commit c3c51e6f070c774c103eeb7f71c759e3ebfda4ec
rumiai-os/mk/lifecycle.test
rumiai-os/mk/refinement.test
rumiai-os/mk/project-dependency.test
rumiai-os/mk/requirement.test
rumiai-os/mk/incremental.test
rumiai-os/mk/inputs.test
rumiai-os/mk/provider-incremental.test
rumiai-os/mk/watch.test
rumiai-os/mk/artifact-restoration.test
rumiai-os/mk/shared-artifact-concurrency.test
```

Final successful hosted product run:

```text
GitHub Actions run 35856233217

exact rumiai-os
    c3c51e6f070c774c103eeb7f71c759e3ebfda4ec

exact rumiai-tests behavior revision
    609158df06efe08b594be9174ad37a150fa6c5a6
```

GitHub-hosted Ubuntu auxiliary runner completed all ten required tests:

```text
PASS rumiai-os/mk/lifecycle.test
PASS rumiai-os/mk/refinement.test
PASS rumiai-os/mk/project-dependency.test
PASS rumiai-os/mk/requirement.test
PASS rumiai-os/mk/incremental.test
PASS rumiai-os/mk/inputs.test
PASS rumiai-os/mk/provider-incremental.test
PASS rumiai-os/mk/watch.test
PASS rumiai-os/mk/artifact-restoration.test
PASS rumiai-os/mk/shared-artifact-concurrency.test

PASS 10 / FAIL 0 / SKIP 0 / ERROR 0
```

The macOS job in that final run did not reach tests because real `pkg install nodejs` received HTTP 403 from the Node.js distribution endpoint. This is provisioning/upstream evidence, not an mk behavior failure.

PoC 032 independently exercised the promoted concurrency protocol on macOS and Ubuntu with PASS before product promotion. It is experimental evidence and does not replace the missing macOS permanent-test execution for the final product revision.

Diagnostic product runs before the final green Ubuntu run:

```text
35855864496
    first permanent scope run; incremental.test still encoded the pre-shared
    expectation that corrupt local freshness must force action execution

35856077678
    second run; incremental.test still encoded the pre-shared expectation that
    returning to an earlier profile fingerprint must force action execution
```

Both exposed stale permanent-test expectations rather than product semantic failures and were realigned forward as recorded above.

The temporary hosted workflow was removed after evidence collection.

Formal `rumiai-validate` evidence is not established by these hosted runs and must not be inferred from them.

## Current state

The current version-2 architecture now includes:

```text
declarative project/model
+ profile
+ project dependencies
+ requirements
+ declared operation inputs
+ observable state
    -> iterative one-shot lifecycle

optional incremental policy
    -> project-scoped freshness evidence
    -> shared-local verified artifact reuse by effective fingerprint

optional --watch execution mode
    -> resolver-owned trigger identity
    -> fresh one-shot lifecycle on relevant change
```

The current artifact-sharing boundary is intentionally **local to one user cache root**. It does not yet provide:

```text
remote/network artifact transport
cross-user artifact trust/sharing
artifact eviction/garbage collection
abandoned-staging reclamation
distributed locking
parallel lifecycle scheduling
remote execution
public generic provider/plugin registration
request-wide exactly-once/de-duplication
```

## Next action

Create **PoC 033 — shared artifact garbage collection/reclamation safety**.

Stress the concrete consequences of immutable publication:

```text
selected candidate must never be reclaimed
reader may hold a previously selected immutable candidate while selector advances
unselected recovery candidates may become reclaimable only when reader safety is established
abandoned .staging-* paths are never valid candidates but may require age/liveness policy
.current-* temporary selector files may remain after abrupt termination
multiple mk processes may publish/restore while maintenance runs
project-scoped freshness metadata may still reference fingerprints whose artifacts are absent
```

Determine the smallest safe local maintenance protocol and ownership boundary before adding any public cache-management command or automatic eviction policy.

Do not add remote transport, cross-user trust, distributed locking or cache-size policy in PoC 033 unless the safety model itself requires them.

## Blockers / open questions

- how can shared immutable candidates be reclaimed without deleting a candidate an active reader may still hold after reading `current`?
- is reader registration/lease metadata necessary, or can a simpler generation/grace-period protocol provide deterministic local safety?
- how should abandoned private staging and selector temp files be distinguished from a live writer's in-progress state?
- should cache maintenance be an explicit `mk` command, an internal opportunistic action or a separate general state/cache facility?
- formal `rumiai-validate` for Node-backed mk scopes still requires current evidence before it can be called closed.
