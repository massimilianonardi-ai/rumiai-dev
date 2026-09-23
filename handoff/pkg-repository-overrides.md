# Package repository override model

Status: Active
Updated: 2026-09-23

## Goal

Refactor the package repository-adapter model so each repository `type` remains a complete, standalone implementation while selected artifact-resolution responsibilities can be overridden through typed, reusable handlers. Use current repository adapters as evidence, promote only abstractions demonstrated by real cases, and reduce package-specific adapter duplication without weakening the canonical artifact-descriptor/download contract.

## Current repository revisions

```text
rumiai-dev      ba0b7dce41fd7757f81a17f5490d0cffb5043976  (pre-checkpoint HEAD before this synchronization)
rumiai-os       92f0d459225ee4117f3c2cb32aa1b8aa9f17ec90
rumiai-tests    63a7c475cc96a0ff694c1061ccbada90f0826aef
rumiai-dev-PoCs 4c2e43644f6b5c42c542bf37fd07ab7caaae03bd
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

## Fixed task-local choices

- Repository `type` remains a complete and independently usable adapter.
- Overrides are optional and replace exactly one owned responsibility while all non-overridden behavior remains supplied by `type`.
- The current override dimensions are `download/` and `metadata/`, each with its own typed closed schema.
- Override implementations are trusted RumiAI code; catalog data does not embed shell, callbacks, arbitrary expressions or executable parsing logic.
- Existing `digest_type` remains the integrity algorithm selector and is not reused as an override-handler identity.
- The final artifact resolver continues to emit the existing canonical descriptor consumed by generic `pkg-download`; generic download code remains provider-agnostic.
- Repository-specific types may internally reuse the same typed mechanisms without requiring an explicit catalog override.

## Promoted current model

- Download handler `template-url`: deterministic `name-template` using `{version}`, and `url-template` using `{version}`/`{name}`.
- Metadata handlers:
  - `checksum-sidecar`
  - `checksum-manifest`
  - `sourceforge-rss`
- NetBeans and Node.js now use `type=github` plus download/metadata overrides; their dedicated repository adapters are removed.
- GeoServer remains `type=geoserver` because its strict numeric X.Y.Z ordering and exact-version semantics are genuinely different, while its RSS metadata parsing is now delegated to the shared SourceForge handler.
- Temurin remains custom: its name and download API mapping do not fit the current template handler without adding unsupported generalization.

## Completed

- Full current repository-adapter mechanism matrix reviewed.
- Added `pkg-repository-artifact.lib.sh` with typed download/metadata handlers and operational manual.
- Integrated independent artifact overrides into the generic GitHub Releases adapter while preserving its no-override behavior.
- Added `sourceforge-rss` as a reusable metadata mechanism and realigned GeoServer to reuse it internally.
- Migrated all NetBeans and Node.js catalog streams to `type=github` with closed typed overrides.
- Removed the superseded NetBeans and Node.js product adapters.
- Replaced their repository-specific permanent tests with generic artifact-handler coverage plus GitHub composition coverage.
- Canonical package-model realignment is part of this checkpoint.

## Current state

Implementation, catalog and permanent-test surfaces have been structurally realigned to the promoted model. No live external/package-install validation has yet been obtained for the new revisions in this task. The execution container cannot resolve github.com and is therefore not being treated as live validation evidence.

## Next action

Perform the final consistency pass: inspect current diffs/references for superseded NetBeans/Node.js repository types and stale override API names, validate library/manual visibility consistency, run the strongest available real validation path, and classify any remaining failure before closing the task.

## Blockers / open questions

- No architectural blocker remains in the baseline override model.
- Broader handler types (for example Apache digest-only sidecars or Temurin API-specific mapping) should be added only when a current package supplies concrete evidence for a genuinely reusable mechanism rather than by speculative generalization.
