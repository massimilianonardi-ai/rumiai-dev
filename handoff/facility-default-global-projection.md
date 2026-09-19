# Facility default global projection

Status: Complete
Updated: 2026-09-19

## Goal

Define and implement facility-default global command publication while preserving package-default semantics, consumer-specific provider overrides and the technical `m` bootstrap boundary, with `facility-env` remaining consumer-launch-only.

## Current repository revisions

```text
rumiai-dev       08e081763f125a38a5deea41abe6cb169094127d
rumiai-os        7e2a4bfe519ac3ee87dab9c820a50bbcdfa2303f
rumiai-tests     7273b6d304c0312046da91543effb00a93fec31e
pkg-catalog      bd06488d3c67160e820c04d13067f852c8861c32
rumiai-dev-PoCs  cb8c5d636ce65e6cb00626ed08947fe25a25988e
```

The recorded `rumiai-dev` revision is the current canonical state immediately before this final completion snapshot.

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

No task-local semantic choices remain. Durable behavior is promoted to `specifications/rumiai-os/PACKAGE-MODEL.md`.

## Completed

- Facility defaults now reconcile owned commands into `bin/ext` and `bin/ext-<osarch>`.
- Unversioned selectors publish through provider package-default selectors; pinned selectors target pinned concretes.
- Provider package-default transitions reconcile command-set additions/removals and class disappearance/reappearance.
- Consumer-specific bindings do not affect global command publication.
- Unrelated external-command collisions reject the mutation and preserve authoritative selector/projection state.
- `facility-env` remains a consumer-launch projection and is not injected into ambient `m`/shell state.
- Public library interfaces and manuals are aligned with the current grouped package-library layout.
- Permanent regression coverage exists in `tests/rumiai-os/pkg/facility-default-global.test`.
- Structural validation run `35429901025` PASS on `rumiai-os@7e2a4bfe519ac3ee87dab9c820a50bbcdfa2303f` and `rumiai-tests@7273b6d304c0312046da91543effb00a93fec31e`, including provider config, late binding, no install-time binding, unversioned follow, command-set reconciliation, pinned selectors, collision rollback, binding independence, class-presence reconciliation, ambient facility-env absence and consumer runtime projection/precedence.
- Live validation run `35429765096` attempt 2 PASS on the same product/catalog revisions with `rumiai-tests@3809d5854a5c9349786de463a5a803d39e29613c`: Linux Temurin, GraalVM, coexistence, Maven and Keycloak; macOS Temurin ARM64/Intel and GraalVM ARM64.
- The five live-test file blobs are identical between `rumiai-tests@3809d5854a5c9349786de463a5a803d39e29613c` and final `rumiai-tests@7273b6d304c0312046da91543effb00a93fec31e`.
- Final-suite live run `35429958951` passed every case except GraalVM macOS ARM64; that case failed only on upstream HTTP 403. A dedicated exact-revision retry `35430034548` reproduced the same upstream 403 before package integration.
- The GitHub-backed repository rate-limit/reliability issue is intentionally deferred in `todo/github-package-repository-rate-limits.md`.

## Current state

The facility-default global projection contract and implementation are aligned. Permanent structural coverage passes on the final product/test revisions. Real live provider/consumer behavior is validated; the only final-suite live failure is an external GitHub 403 on GraalVM macOS ARM64, separately tracked as deferred repository-adapter reliability work.

## Next action

None for this task.

## Blockers / open questions

None for facility-default global projection.
