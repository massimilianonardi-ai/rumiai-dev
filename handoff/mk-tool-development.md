# mk tool development

Status: Active
Updated: 2026-09-23

## Goal

Continue development of `mk` as the `m` project development-lifecycle orchestrator, extending the promoted version-2 model from concrete project needs while preserving subsystem boundaries.

## Current repository revisions

```text
rumiai-dev       737701533e58f5f9888ba8665fd826cb7fe10fb9  (pre-synchronization HEAD)
rumiai-os        533095820ea4f22446510a0f7b338253d908d018
rumiai-tests     58fba497a00bd66452b4e8ce36eddbc117eda337
rumiai-dev-PoCs  0efd2066878dac2cb41bcf762b643e6234bc7017
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
- verified local artifact restoration for incremental declared outputs;
- long-running `--watch` execution using resolver-owned trigger identity and fresh one-shot lifecycle cycles.

Project `dependency`, operation `prerequisite`, external `requirement`, operation `input`, incremental reuse policy and watch/session semantics remain distinct.

The current baseline still excludes:

```text
shared/remote artifact cache
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

## Current state

Watch is no longer working design. It is a promoted, implemented and permanently tested version-2 execution mode.

The current lifecycle architecture is conceptually:

```text
declarative project/model
+ profile
+ project dependencies
+ requirements
+ declared operation inputs
+ observable state
    -> iterative one-shot lifecycle

optional incremental policy
    -> freshness reuse for eligible ordinary operations

optional --watch execution mode
    -> resolver-owned trigger identity
    -> fresh one-shot lifecycle on relevant change
```

## Next action

Use **cross-checkout/shared artifact identity** as the next concrete incremental-cache stress case, starting with a PoC rather than changing the current local store.

The first question is whether artifact bytes can be keyed by verified content/effective operation identity independently from canonical project-root metadata while preserving the current local project-scoped freshness contract.

Stress at least:

```text
same project copied/moved to another canonical root
same effective operation/input/output identity across two independent checkouts
different operation definitions producing byte-identical outputs
corrupt/incomplete shared candidate
permission/mode identity
provider-derived member identity
no false reuse across incompatible fingerprints
```

Do not introduce network transport, remote service/API, eviction/GC, parallel execution or project-dependency exactly-once semantics in the first experiment. Establish artifact identity/reuse semantics before choosing distribution transport.

## Blockers / open questions

- can verified artifact bytes become content-addressed/reusable across canonical project roots while freshness metadata remains project-scoped?
- which identity tuple prevents false cross-project reuse when output bytes happen to match but operation/fingerprint semantics differ?
- should a future shared artifact store remain user-local first, with remote transport layered later?
- formal `rumiai-validate` for Node-backed mk scopes still needs current evidence before it can be called closed.
