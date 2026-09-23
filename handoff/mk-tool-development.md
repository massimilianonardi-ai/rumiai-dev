# mk tool development

Status: Active
Updated: 2026-09-23

## Goal

Continue development of `mk` as the `m` project development-lifecycle orchestrator, extending the current promoted model from concrete project needs while preserving subsystem boundaries.

This handoff stores only current task state and revision-specific evidence. Durable lifecycle semantics belong in the current canonical specifications.

## Current repository revisions

```text
rumiai-dev       74971f7fc6088be79a960e9d5515cd92223c506e  (pre-synchronization HEAD)
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

## Active next work unit

Create **PoC 033 — shared artifact garbage collection/reclamation safety**.

The promoted shared-local artifact publication model deliberately keeps committed candidates immutable and never removes them from the writer path. That leaves a concrete local-maintenance problem which must be solved before automatic eviction/GC can be promoted.

Stress at minimum:

```text
selected candidate must never be reclaimed

reader may hold a previously selected immutable candidate while current advances

unselected recovery candidates become reclaimable only when reader safety is established

abandoned .staging-* paths are never valid candidates but maintenance must not
remove staging owned by a live writer

.current-* selector temporaries may remain after abrupt termination

publication/restoration may race with maintenance

project-scoped freshness metadata may reference fingerprints whose artifact bytes
have been reclaimed; this must remain a conservative execution/restore miss
```

Keep the first PoC local/user-scoped. Do not add remote transport, cross-user trust, distributed locking or a cache-size/retention policy unless the safety model itself requires them.

Do not create a public cache-management command before ownership and reader/writer safety are settled.

## Open questions for PoC 033

- Is explicit reader registration/lease state required to reclaim an unselected candidate safely, or can a simpler local generation/grace protocol prove safety?
- How should maintenance distinguish abandoned staging/selector temporary files from a live writer's in-progress state without relying on non-portable process inspection?
- Is safe reclamation an `mk` responsibility or should a current general state/cache responsibility own it?
- What minimum crash model must be supported for POSIX-local artifact maintenance?
- Formal `rumiai-validate` for Node-backed `mk` scopes still needs current evidence before it can be called closed.
