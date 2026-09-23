# mk tool development

Status: Active
Updated: 2026-09-23

## Goal

Continue development of `mk` as the `m` project development-lifecycle orchestrator, extending the current promoted model from concrete project needs while preserving subsystem boundaries.

This handoff stores only current task state and revision-specific evidence. Durable lifecycle semantics belong in the current canonical specifications.

## Current repository revisions

```text
rumiai-dev       88644da801a60484995fa90157af2bee1a3763e2  (pre-synchronization HEAD)
rumiai-os        e82f68ba7862e11d52c01aa2f421881f86c37dd4
rumiai-tests     895aaf54ade8da4fb23e62f23f18c41c27aad2eb
rumiai-dev-PoCs  8bec42ffa657d22aac4641af2bb2c98217625554
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
specifications/rumiai-os/PACKAGE-MODEL.md
handoff/README.md
```

Retrieve additional subsystem specifications only when the active work crosses their boundary.

## Current checkpoint

The previously active cross-checkout/shared-artifact work unit is complete at the development-evidence level.

PoC evidence:

```text
rumiai-dev-PoCs/pocs/031-mk-cross-checkout-artifact-identity/
rumiai-dev-PoCs/pocs/032-mk-concurrent-shared-artifacts/
```

PoC 031 hosted run:

```text
35846792755
Ubuntu PASS
macOS  PASS
```

PoC 032 hosted run:

```text
35854778813
Ubuntu PASS
macOS  PASS
```

The settled contract is promoted in current `MK.md` and `CURRENT-MODEL.md`; do not reconstruct it from this handoff.

Promotion commits:

```text
rumiai-dev
e845f2894b2d2e4b5bf74805de0e8316fa433db6
    MK.md

54be82eae3e9781b8ee1b10795de1505d79b86a4
    CURRENT-MODEL.md
```

Product behavior implementation:

```text
rumiai-os
699c77923cda2cd5fd58844f29a6dc9e175d760b
    lib/sys/js/mk.lib.js
```

Manual alignment:

```text
276cc837babaec38489ee40d080cef4953f9ed87
    res/sys/manual/mk

c3c51e6f070c774c103eeb7f71c759e3ebfda4ec
    res/sys/manual/mk.lib.js
```

Permanent-test changes:

```text
10a27b32e0adce996b74622d8cad6e61241e1069
    artifact-restoration.test shared-local realignment

096bdcd9e701f328509925433dac14f1453ecfc3
    shared-artifact-concurrency.test

a520387658ca9efa34331ba1639ebfe066a82c27
    incremental.test corrupt-freshness expectation realignment

609158df06efe08b594be9174ad37a150fa6c5a6
    incremental.test earlier-fingerprint/profile expectation realignment
```

The two `incremental.test` corrections remove pre-shared-artifact assumptions from the permanent regression; they are not product semantic fixes.

Task validation scope:

```text
rumiai-tests/validation/mk-shared-artifacts.conf

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
35856233217

exact rumiai-os
    c3c51e6f070c774c103eeb7f71c759e3ebfda4ec

exact rumiai-tests behavior revision
    609158df06efe08b594be9174ad37a150fa6c5a6
```

GitHub-hosted Ubuntu auxiliary result:

```text
PASS lifecycle.test
PASS refinement.test
PASS project-dependency.test
PASS requirement.test
PASS incremental.test
PASS inputs.test
PASS provider-incremental.test
PASS watch.test
PASS artifact-restoration.test
PASS shared-artifact-concurrency.test

PASS 10 / FAIL 0 / SKIP 0 / ERROR 0
```

The macOS job in the same final run did not reach the tests because real `pkg install nodejs` received HTTP 403 from the Node.js distribution endpoint. This is provisioning/upstream evidence, not an `mk` behavior failure.

PoC 032 independently exercised the concurrency protocol on GitHub-hosted Ubuntu and macOS before product promotion. That experimental macOS evidence does not substitute for permanent-test execution against the final product revision.

Diagnostic hosted runs:

```text
35855864496
    exposed stale incremental.test expectation around corrupt local freshness

35856077678
    exposed stale incremental.test expectation around returning to an earlier
    effective profile fingerprint
```

Both were test-contract realignments, corrected forward.

The temporary hosted workflow has been removed.

Formal `rumiai-validate` evidence for this Node-backed scope has not been re-established; hosted evidence must not be relabelled as formal validation.

No physical stable-reference-host validation was performed in this work unit.

## Completed maintenance-safety experiments and promotion

PoC 033:

```text
rumiai-dev-PoCs/pocs/033-mk-shared-artifact-reclamation/
hosted run 35859604116
Ubuntu PASS
macOS  PASS
```

PoC 033 established that immutable candidate reclamation does not require reader leases when maintenance first removes an unselected candidate from the canonical namespace and restoration remains transactional. Persistent marker-file ownership was race-safe but not crash-live.

PoC 034:

```text
rumiai-dev-PoCs/pocs/034-mk-artifact-crash-released-coordination/
hosted run 35862288363
exact rumiai-os e07902112ef0075933399d9b3834ea110448a6cc
Ubuntu PASS
macOS  PASS
```

Observed on both hosted platforms:

```text
ownership-witness=posix-fifo-open-reader
crash-liveness=stale-fifo-detectable-without-pid-or-timeout
abandoned-staging=reclaimable-after-owner-death
selector-temp=reclaimable-after-owner-death
reader-lease=still-not-required
```

The product-policy boundary was then resolved from current subsystem ownership:

- shared-artifact maintenance remains private `mk` behavior because the store is private `user/sys/mk/cache` state;
- the baseline is structural hygiene, not a retention/eviction policy;
- ordinary hygiene is opportunistic and limited to fingerprint namespaces touched by `mk`;
- the selected candidate is preserved;
- committed unselected candidates and stale crash residue may be reclaimed;
- publication/maintenance liveness uses POSIX FIFO ownership released by kernel descriptor closure;
- no TTL/LRU, cache-size limit, whole-fingerprint eviction, global sweeping guarantee or public cache-management command was introduced.

Canonical promotion:

```text
rumiai-dev
811c9cea97bfcb204ba9ff670735d6d47e202e9b
    specifications/rumiai-os/MK.md

9eb71609664a5b39324a49d41b315e7664004c76
    specifications/rumiai-os/CURRENT-MODEL.md

0f7edcb790c67f29881ae555606f71421f3ad0b0
    MK.md stale pre-shared-artifact scope sentence removed during consistency gate
```

Product/manual implementation:

```text
rumiai-os
4a54c2928ad763097805e44e961b60fca46a5d0c
    lib/sys/js/mk.lib.js

378abdb3d477ff055df697e730529328fb5197fc
    res/sys/manual/mk

ec670644237079b6e809aa2efe95cba5ed853b92
    res/sys/manual/mk.lib.js
```

The implementation adds private attempt/publication/maintenance FIFO leases, stale-owner probing without PID/timeout heuristics, quarantine-first unselected-candidate reclamation, abandoned staging/selector cleanup and opportunistic hygiene before restore/publication. Reader registration is still not required because restoration remains transactional.

Permanent-test changes:

```text
rumiai-tests
c44c01489e14bc86dfb7071aca3040d131d0fdba
    shared-artifact-concurrency.test realigned for post-selector reclamation

e71fb632f040c6123243d756f1d6b4987c57dd30
7aa87fb737e6ffbd14374a828c6c0c364fcba269
    shared-artifact-maintenance.test added and made executable

5764a1897512803703b0fedd205f01529250e5b1
    maintenance test observes the newly created artifact namespace directly

9614d96ab42588be9161e4ab996ed222f7fbd08a
    maintenance crash test kills the actual FIFO-owning Node process
```

Task scope:

```text
validation/mk-shared-artifacts.conf
rumiai-os-commit ec670644237079b6e809aa2efe95cba5ed853b92
11 selections, including shared-artifact-concurrency.test and
shared-artifact-maintenance.test
```

Final auxiliary hosted product run:

```text
35864985781
exact rumiai-os ec670644237079b6e809aa2efe95cba5ed853b92

Ubuntu 24.04 / nodejs v26.10.0
    PASS shared local artifact concurrency
    PASS shared artifact structural hygiene

macOS 26 arm64 / nodejs v26.10.0
    PASS shared local artifact concurrency
    PASS shared artifact structural hygiene
```

This is auxiliary hosted evidence, not formal validation.

Formal `rumiai-validate mk-shared-artifacts` was also exercised in hosted runs. The launcher correctly creates a fresh isolated clone of the configured product revision, but that clone currently has no managed/default Node.js runtime. Consequently Node-backed selections report SKIP and task validation is not positively closed. The final diagnostic formal run was:

```text
35864985930
Ubuntu: validation failure because selections are SKIP
macOS:  validation failure because selections are SKIP
```

Provisioning Node.js in the source/update checkout does not solve this because formal validation intentionally executes a different disposable clone. Per current `TESTING.md`, preparation of such a target runtime belongs to `rumiai-validate`; no workflow-only bypass should be relabelled as formal evidence.

Temporary hosted/formal workflows created for this work unit were removed after evidence collection. No physical stable-reference-host validation was performed.

## Validation target preparation work unit

PoC 035 is now positive on the current experimental revision:

```text
rumiai-dev-PoCs
8bec42ffa657d22aac4641af2bb2c98217625554

pocs/035-validation-runtime-preparation/
hosted run 35866177032
Ubuntu PASS
macOS  PASS
```

The experiment confirmed that a disposable exact-revision `rumiai-os` clone can select the real host platform, install the managed Node.js package through the real public `pkg install` path and recover the immutable `pkg-catalog` revision used by package preparation, without injecting a host Node binary.

The validation-environment contract has been promoted into current `TESTING.md`: formal target preparation selects the host platform through `osarch update`, may install declared target packages inside the disposable target through the real `pkg install` path, and requires an exact expected `pkg-catalog` commit whenever package preparation consumes the catalog.

Current launcher implementation in `rumiai-tests/lib/sh/rumiai-validate.lib.sh` implements that contract. The current `mk-shared-artifacts` scope declares:

```text
rumiai-os-commit ec670644237079b6e809aa2efe95cba5ed853b92
target-package nodejs@v26.10.0
pkg-catalog-commit da7507439b71737cf4a40d85cac059824e4b9a63
11 mk selections
```

The launcher records target package declarations, expected catalog revision, observed target osarch and observed immutable catalog revision in validation evidence and rejects catalog drift before tests run.

A hosted formal-validation workflow is active on the exact current suite revision:

```text
rumiai-tests
132012f4b015e0b41e0d3d1bfc9fa684caef92b9

workflow
.github/workflows/mk-formal-validation-hosted.yml

run
35866953309

Ubuntu: in progress at last observation
macOS:  in progress at last observation
```

This run executes `./rumiai-validate mk-shared-artifacts` directly; its result will determine whether the previous Node-runtime validation blocker is closed.

## Latest formal-validation checkpoint

Hosted formal run `35866953309` reached real Node-backed execution on both hosts.

- Ubuntu completed successfully with all 11 selected `mk` tests PASS.
- macOS reached the same tests but `watch.test` returned infrastructure ERROR at the CURRENT-58 child-trigger observation. A direct rerun of the unchanged revision reproduced the same point, so this was not treated as a random hosted-run interruption.
- The observed failure was classified as test synchronization rather than a product-contract failure: the test used short fixed quiescence windows and exact trace-count equality around an asynchronous polling supervisor.
- `rumiai-tests` commit `25f2b52335484ee063edc47feee00b2644b2fb62` stabilizes `watch.test` by widening observation time, using explicit quiescence windows and accepting `>=` while waiting so an overshoot is not misreported as timeout.
- `rumiai-tests` commit `11449dde82c20559ead0ee23760a087c5abc9ed3` makes the temporary hosted formal workflow run when `watch.test` changes so the corrected test revision is actually exercised.
- Formal hosted run `35869614435` exercises exact `rumiai-os` `ec670644237079b6e809aa2efe95cba5ed853b92` with exact `rumiai-tests` `11449dde82c20559ead0ee23760a087c5abc9ed3`.
- Ubuntu in run `35869614435` completed successfully; its published validation record has aggregate status 0 and all selected tests PASS.
- macOS in run `35869614435` has already published PASS for the corrected `watch.test`; the overall macOS formal job was still running at the latest observation.

No product `mk` implementation or current `MK.md` semantics were changed by this test realignment.

Concurrent IPC work advanced the repository HEADs after the formal `mk` run was started. The intervening `rumiai-os` changes touch only `lib/sys/sh/ipc.lib.sh` and its manual; the intervening `rumiai-tests` change touches only `tests/rumiai-os/ipc/contract.test`. They are orthogonal to the `mk` implementation/test surfaces. Formal `mk` evidence remains revision-specific to `rumiai-os` `ec670644237079b6e809aa2efe95cba5ed853b92` and `rumiai-tests` `11449dde82c20559ead0ee23760a087c5abc9ed3`.

## Active next work unit

Finish observing hosted formal run `35869614435`.

- If the macOS job completes successfully, capture the exact formal validation evidence and perform the final consistency check for the shared-artifact work unit.
- If the macOS job fails after the corrected `watch.test` PASS, diagnose only the newly failing selection/infrastructure path and correct it forward.
- After positive formal evidence is available, resolve whether additional physical stable-reference-host validation is required for this milestone, then either close this work unit or record the remaining validation obligation explicitly.

Whole-fingerprint retention/eviction policy remains a separate future `mk` concern and is not implied by this validation work.

## Open questions

- What is the final aggregate outcome of macOS in hosted formal run `35869614435`?
- After positive formal Node-backed validation is available, does this work unit require physical stable-reference-host execution or is the formal hosted cross-host evidence sufficient for the current milestone?
