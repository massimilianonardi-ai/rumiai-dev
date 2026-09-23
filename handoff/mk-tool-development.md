# mk tool development

Status: Complete
Updated: 2026-09-23

## Goal

Complete the current `mk` shared-local-artifact / structural-hygiene work unit, including revision-specific formal and physical validation.

## Final repository revisions

```text
rumiai-dev       85b57a8f7807e87139aae6cb927d931edfbf9331  (pre-synchronization HEAD)
rumiai-os        a15ef6171e614a4862df0e2da4d40a5375eefc45
rumiai-tests     869e92964055ef67c00b7bff9e61f06001a6e35f
rumiai-dev-PoCs  8bec42ffa657d22aac4641af2bb2c98217625554
pkg-catalog      da7507439b71737cf4a40d85cac059824e4b9a63
```

The validation evidence below is revision-specific and intentionally remains attached to the exact validated revisions rather than later repository HEADs.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
PHYSICAL-TESTING.md
specifications/README.md
specifications/rumiai-os/MK.md
specifications/rumiai-os/CURRENT-MODEL.md
handoff/README.md
```

## Completed

The settled `mk` contract for shared local artifacts and structural hygiene is promoted in the current canonical specifications and implemented with aligned manuals and permanent tests.

The dedicated task scope is:

```text
validation/mk-shared-artifacts.conf

rumiai-os
    ec670644237079b6e809aa2efe95cba5ed853b92

target-package
    nodejs@v26.10.0

pkg-catalog
    da7507439b71737cf4a40d85cac059824e4b9a63

11 permanent mk selections
```

Hosted formal run `35869614435` validated the scope on both hosted Ubuntu and hosted macOS for the exact product revision above and the corrected permanent-test behavior revision.

Final physical formal validation was then executed successfully on both physical reference environments with `rumiai-tests` `78c4c770150ce6ef70677b8895c2ab0588395c0f`:

```text
Ubuntu ARM64 reference VM
    aggregate branch validation/20260923T215420+0200-246613
    persisted host identity Linux/aarch64
    target-osarch linux-arm64
    aggregate-status 0
    11 required selections
    user-visible result VALIDATED

macOS ARM64
    aggregate branch validation/20260923T215429+0200-70862
    persisted host identity Darwin/arm64
    target-osarch macos-arm64
    aggregate-status 0
    11 required selections
    user-visible result VALIDATED
```

On both physical runs the launcher recorded `nodejs@v26.10.0`, expected and observed `pkg-catalog` commit `da7507439b71737cf4a40d85cac059824e4b9a63`, and aggregate status 0. The individual user-visible runs reported all 11 selections PASS with no FAIL, SKIP or ERROR.

The Linux validation record does not encode the distribution release; the Ubuntu stable-host classification comes from the operator/reference-environment identity, not from an inferred field in the persisted record.

The temporary hosted workflow used to obtain formal hosted evidence was removed after closure:

```text
rumiai-tests
869e92964055ef67c00b7bff9e61f06001a6e35f
    remove .github/workflows/mk-formal-validation-hosted.yml
```

No product or canonical specification change was required by final physical validation.

## Current state

This work unit is complete. Later `rumiai-os` HEAD changes are unrelated work and are not relabelled as evidence for the validated `ec670644237079b6e809aa2efe95cba5ed853b92` milestone.

The current `MK.md` contract intentionally defines no TTL/LRU policy, cache-size limit, whole-fingerprint eviction or global sweep guarantee. That absence is not treated as unfinished work in this completed work unit.

## Next action

None.

## Blockers / open questions

None.
