# Handoff — state selector and `mk` physical validation complete

Date: 2026-09-14  
Status: complete

## Authority

This handoff is non-normative. The active contracts remain:

```text
decisions/rumiai-os/2026-09-14-semantic-state-selectors-and-global-user-binding.md
decisions/rumiai-os/2026-09-14-activate-mk-source-materialization-baseline.md
specifications/rumiai-os/MK-SOURCE-MATERIALIZATION.md
decisions/rumiai-tests/2026-09-14-advance-validation-pair-for-state-selectors-and-mk.md
```

The previous handoff:

```text
handoff/2026-09-14-rumiai-os-state-selector-correction-validation-handoff.md
```

remains a historical snapshot of the state before physical validation. Its pending-validation action is now superseded by this closure handoff and by the completed-validation section of the active validation-pair decision.

## Validated pair

```text
rumiai-os    e9adfd55afdfe1111884a2ee42a8e5a955438119
rumiai-tests d0617fdb3f7d7960e92cfdabef818a626eb22004
selection    rumiai-os
```

## Physical evidence

Ubuntu 26.04 ARM64:

```text
validation/20260914T203239+0200-360494
PASS 78 / FAIL 0 / SKIP 2 / ERROR 0 / TOTAL 80
runner-exit-status 0
```

macOS ARM64:

```text
validation/20260914T203304+0200-24421
PASS 80 / FAIL 0 / SKIP 0 / ERROR 0 / TOTAL 80
runner-exit-status 0
```

Both validation refs are based directly on `rumiai-tests@d0617fdb3f7d7960e92cfdabef818a626eb22004`, whose versioned validation configuration selects the full `rumiai-os` group and requires `rumiai-os@e9adfd55afdfe1111884a2ee42a8e5a955438119`.

## Validated scope

The full current `rumiai-os` permanent-test group was exercised on both reference hosts. This includes the post-2.0.0 semantic state selector/global user binding correction and the initial `mk materialize` baseline, together with the existing bootstrap, command, package, language, logging, shell, resolver, extraction, digest, HTTP and related contracts covered by that group.

The two zsh tests skipped on Ubuntu are host-applicability skips, not failures. The same tests passed on macOS and both validation runners completed with status `0`.

## Closure

No physical-validation action remains pending for this exact pair.

The frozen `2.0.0` checkpoint and its historical evidence remain unchanged.

Future product/test changes are not covered by these refs and require new revision-specific validation when required by the normal testing policy.
