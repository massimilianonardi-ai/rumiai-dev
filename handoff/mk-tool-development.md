# mk tool development

Status: Active
Updated: 2026-09-23

## Goal

Continue development of `mk` as the `m` project development-lifecycle orchestrator, extending the current promoted model from concrete project needs while preserving subsystem boundaries.

This handoff stores only current task state and revision-specific evidence. Durable lifecycle semantics belong in the current canonical specifications.

## Current repository revisions

```text
rumiai-dev       eedb38892322091944d90b2fe90eedd12a3e8707  (pre-synchronization HEAD)
rumiai-os        6a9e2da2c3a91ab1ac29b64c8268dc92030b5599
rumiai-tests     a8befac73543de44f6c451569189ab1a8cc2aa3c
rumiai-dev-PoCs  dfdb0d553ff94f27d6408aa8cdbedf266055cd7e
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

## Completed maintenance-safety experiments

PoC 033:

```text
rumiai-dev-PoCs/pocs/033-mk-shared-artifact-reclamation/
hosted run 35859604116
Ubuntu PASS
macOS  PASS
```

PoC 033 established experimentally that immutable candidate reclamation does not require reader leases when maintenance first removes an unselected candidate from the canonical namespace and restoration remains transactional. It also established that persistent marker-file ownership is safe but not crash-live.

PoC 034:

```text
rumiai-dev-PoCs/pocs/034-mk-artifact-crash-released-coordination/
hosted run 35862288363
exact rumiai-os e07902112ef0075933399d9b3834ea110448a6cc
Ubuntu PASS
macOS  PASS
```

The final run observed on both hosted platforms:

```text
ownership-witness=posix-fifo-open-reader
crash-liveness=stale-fifo-detectable-without-pid-or-timeout
abandoned-staging=reclaimable-after-owner-death
selector-temp=reclaimable-after-owner-death
reader-lease=still-not-required
```

Two preceding PoC 034 hosted attempts failed because of test-driver defects and were corrected forward. The successful run above is the evidence-bearing experiment. The temporary hosted workflow was removed after evidence collection.

No current `MK.md`, `CURRENT-MODEL.md`, product implementation or permanent test has yet been changed by PoC 033/034.

## Active next work unit

Resolve the product-policy boundary for shared-artifact maintenance before promotion.

The coordination/safety mechanism is experimentally settled enough to promote only after the remaining policy choices are made from current subsystem responsibilities:

```text
who owns maintenance behavior
when maintenance runs
what baseline retention/reclamation policy exists
whether any user-facing maintenance control is in scope
```

Do not introduce a public cache-management command merely because safe reclamation is now possible. Keep remote transport, cross-user trust and distributed coordination out of scope unless a concrete current requirement introduces them.

After the policy boundary is settled, apply the specification promotion gate. If promoted, realign the canonical specification(s), `mk` implementation, library/command manuals as applicable, permanent tests and proportional validation in one forward-only sequence.

## Open questions

- Does shared-artifact maintenance remain a private `mk` implementation responsibility, or does an existing current general state/cache responsibility already own it?
- What is the smallest baseline maintenance trigger that avoids unbounded residue without inventing a user-facing policy prematurely?
- Which committed candidates are retained versus reclaimable in the baseline?
- Is whole-fingerprint eviction part of the baseline or only a future policy mechanism?
- Formal `rumiai-validate` evidence for Node-backed `mk` scopes still needs current evidence before the task can be called closed.
