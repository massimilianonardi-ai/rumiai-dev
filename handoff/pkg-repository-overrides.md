# Package repository override model

Status: Complete
Updated: 2026-09-23

## Goal

Refactor the package repository-adapter model so each repository `type` remains a complete, standalone implementation while selected artifact-resolution responsibilities can be overridden through typed, reusable handlers, with the same handlers reusable internally by complete repository types.

## Current repository revisions

```text
rumiai-dev      7370281779b5248f7620bcc2dbe94b6e36668ef9  (pre-completion-snapshot HEAD)
rumiai-os       b98a322faa86cc51adeadc24bb4357cb24af11a9
validated os    605e9e0e12b6907d0958bbd72d7f3bab79db6d2e
rumiai-tests    4c77fa4832f3999d9fc828ff8ec5c16a62bb70b2
pkg-catalog     da7507439b71737cf4a40d85cac059824e4b9a63
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `specifications/README.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`
- `TESTING.md`
- `TEST-PATTERNS.md`

## Completed

- Promoted the repository override/composition model to the canonical package specification.
- Added shared artifact mechanisms:
  - download `template-url`;
  - metadata `checksum-sidecar` with `digest-name` and `digest-only`;
  - metadata `checksum-manifest`;
  - metadata `sourceforge-rss`.
- Generic GitHub repository handling supports independent download and metadata overrides while retaining complete default behavior.
- NetBeans and Node.js were migrated to `type=github` plus closed typed overrides; their dedicated adapters were removed.
- GeoServer remains a complete custom type for its genuine version/exact-release semantics while reusing shared SourceForge RSS metadata handling.
- Apache Maven remains a complete custom type for its release/index semantics while reusing shared template URL and digest-only sidecar handling.
- Other current adapters remain custom where no sufficiently clean shared mechanism is yet evidenced.
- Fixed POSIX-shell validator variable leakage by isolating download/metadata validators in subshells.
- Added/updated permanent tests, manuals and the dedicated task validation scope `validation/pkg-repository-overrides.conf`.

## Final validation

Ubuntu x64 formal task validation:

```text
scope               pkg-repository-overrides
rumiai-tests        4c77fa4832f3999d9fc828ff8ec5c16a62bb70b2
rumiai-os           605e9e0e12b6907d0958bbd72d7f3bab79db6d2e
platform            Linux/x86_64
isolation           session
audit-status        CLEAN
aggregate-status    0
scope result        VALIDATED
```

All selected groups passed:

```text
rumiai-os/pkg-repository-artifact       PASS
rumiai-os/pkg-repository-github         PASS
rumiai-os/pkg-repository-apache-maven   PASS
rumiai-os/pkg-repository-geoserver      PASS
```

Published validation record:

```text
validation/20260923T101152+0200-308989
```

with child sessions:

```text
20260923T101153+0200-310466
20260923T101156+0200-311083
20260923T101200+0200-312585
20260923T101209+0200-314042
```

The current `rumiai-os` branch advanced after the validated commit. Comparison from `605e9e0e12b6907d0958bbd72d7f3bab79db6d2e` to current `b98a322faa86cc51adeadc24bb4357cb24af11a9` changes only `bin/sys/mk` and `lib/sys/js/mk.lib.js`; no package-repository file validated by this task changed. The validation evidence remains attributed only to the exact validated revision.

## Current state

The task outcome is complete. Durable architecture is in the canonical package specification, implementation/tests/manuals are aligned, revision-specific evidence is published in `rumiai-tests`, and no task-local unresolved design remains.

## Next action

None.

## Blockers / open questions

None.
