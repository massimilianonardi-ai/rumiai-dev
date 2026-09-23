# mk tool development

Status: Active
Updated: 2026-09-23

## Goal

Continue development of `mk` as the `m` project development-lifecycle orchestrator, extending the promoted version-2 model from concrete project needs while preserving subsystem boundaries.

## Current repository revisions

```text
rumiai-dev       de4fb4e607168db135c320ab63bb3f8e3b69bf6c  (pre-synchronization HEAD)
rumiai-os        48bd93440ef78b809b6b952429cc4f8b9ea7a523
rumiai-tests     ed402975b831a642c08297288c7763abdb619c59
rumiai-dev-PoCs  e3219701e3fcda182909a518f3edd2ffa5514fa0
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
- opt-in content-based incremental freshness for ordinary configured operations;
- long-running `--watch` execution using resolver-owned trigger identity and fresh one-shot lifecycle cycles.

Project `dependency`, operation `prerequisite`, external `requirement`, operation `input`, incremental reuse policy and watch/session semantics remain distinct.

The current baseline still excludes:

```text
artifact storage/restoration
shared/remote artifact cache
provider-level incremental templates
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

Use **provider-level incremental templates for derived `map-process` members** as the next concrete stress case.

The current contract explicitly limits incremental freshness to ordinary configured operations. A fine-grained provider may derive many structurally similar process operations, making provider-level reuse the smallest next incremental gap with direct project-lifecycle value.

Start with a PoC. Determine the minimum declarative/template semantics needed for each derived item to acquire stable input/output identity and incremental eligibility without:

- introducing arbitrary executable provider code;
- duplicating the ordinary operation incremental model;
- coupling cache identity to unstable collection enumeration order;
- weakening the existing provider aggregate/prerequisite/collection semantics.

Do not introduce artifact storage, parallel scheduling or remote execution merely to solve provider-level freshness.

## Blockers / open questions

- what stable derived-operation output identity is sufficient for a `map-process` item when output paths normally depend on the item?
- should provider template data reuse the ordinary operation `inputs` / `outputs` / `incremental` shapes directly, or require only a narrowly derived subset?
- how should item substitution interact with path/output input declarations while preserving the trusted-provider boundary?
- formal `rumiai-validate` for Node-backed mk scopes still needs current evidence before it can be called closed.
