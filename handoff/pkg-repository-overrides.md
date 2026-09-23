# Package repository override model

Status: Active
Updated: 2026-09-23

## Goal

Refactor the package repository-adapter model so each repository `type` remains a complete, standalone implementation while selected artifact-resolution responsibilities can be overridden through typed, reusable handlers. Use current repository adapters as evidence, promote only abstractions demonstrated by real cases, and reduce package-specific adapter duplication without weakening the canonical artifact-descriptor/download contract.

## Current repository revisions

```text
rumiai-dev      075759fce59a76016575660347c199fef373768a  (pre-checkpoint HEAD before this synchronization)
rumiai-os       c2d8d4a0c4503e1de461e72840a13abb0da61c41
rumiai-tests    5515865dcc574af140db796c80d174c3b4d47483
rumiai-dev-PoCs 3610a24139a309ad15e0172f8758d4347a832042
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
  - `checksum-sidecar`, with closed `record-format` values `digest-name` and `digest-only`;
  - `checksum-manifest`;
  - `sourceforge-rss`.
- NetBeans and Node.js use `type=github` plus download/metadata overrides; their dedicated repository adapters are removed.
- GeoServer remains `type=geoserver` because its strict numeric X.Y.Z ordering and exact-version semantics are genuinely different, while its RSS metadata parsing is delegated to the shared SourceForge handler.
- Apache Maven remains `type=apache-maven` because its version/index semantics are specific, while artifact name/download URL and digest-only SHA-512 sidecar handling are delegated to the same shared artifact mechanisms used by overrides.
- Temurin remains custom: its artifact identity is selected from checksum/API data and its binary endpoint does not fit the current independent template/download + already-resolved-name metadata contract without broadening responsibility boundaries.
- Chrome, Chromium, GraalVM and GPGTools remain custom/default implementations because their current provider metadata or release-asset semantics do not provide evidence for another clean handler under the current responsibility split.

## Completed

- Full current repository-adapter mechanism matrix reviewed.
- Added `pkg-repository-artifact.lib.sh` with typed download/metadata handlers and operational manual.
- Integrated independent artifact overrides into the generic GitHub Releases adapter while preserving its no-override behavior.
- Added `sourceforge-rss` as a reusable metadata mechanism and realigned GeoServer to reuse it internally.
- Migrated all NetBeans and Node.js catalog streams to `type=github` with closed typed overrides.
- Removed the superseded NetBeans and Node.js product adapters.
- Replaced their repository-specific permanent tests with generic artifact-handler coverage plus GitHub composition coverage.
- Extended `checksum-sidecar` with the demonstrated `digest-only` record format while preserving `digest-name`.
- Exposed direct trusted mechanism entrypoints for `template-url` and `checksum-sidecar`, so complete repository types can compose the same mechanisms without catalog overrides.
- Realigned `apache-maven` to reuse both shared mechanisms while preserving its complete type and existing external artifact descriptor.
- Added the missing Apache Maven repository library manual and realigned the artifact-handler manual and canonical package-model specification.
- Permanent artifact-handler coverage now exercises direct template URL reuse, both checksum-sidecar record formats, and direct checksum-sidecar reuse. Existing Apache Maven contract coverage continues to exercise digest-only acceptance plus filename/duplicate/bad-digest rejection through the public Maven adapter.
- Final static consistency review verified public function/manual coverage, absence of the superseded internal checksum-sidecar helper, and agreement between implementation, permanent tests and canonical specification.
- Added dedicated task validation scope `validation/pkg-repository-overrides.conf` covering artifact handlers, GitHub composition, Apache Maven reuse and GeoServer SourceForge reuse against the exact current `rumiai-os` revision.

## Current state

The architecture and implementation are aligned around one shared artifact-mechanism layer usable in two ways: explicit catalog overrides and internal composition by complete repository types. Current evidence supports `template-url`, `checksum-sidecar`, `checksum-manifest` and `sourceforge-rss`; other adapters remain custom rather than being forced into broader handlers.

Manual Ubuntu x64 validation was attempted directly with `rumiai-test --validation`. The correct runner selection namespace is relative to `tests/` (for example `rumiai-os/pkg-repository-artifact`); the earlier `tests/...` and `./tests/...` invocations were invalid. The first correctly selected artifact-handler validation produced a real FAIL. Subsequent direct `--validation` runs were blocked because the first completed validation session made the suite working tree non-clean, which is expected runner behavior; multi-selection task validation belongs to `rumiai-validate`. A dedicated `pkg-repository-overrides` validation scope now exists for that purpose. The exact artifact-handler failure still needs diagnosis from its persisted log before validation can complete.

## Next action

Inspect the persisted log from the failed Ubuntu x64 artifact-handler run, correct the implementation/test mismatch if confirmed, then run `./rumiai-validate pkg-repository-overrides` on a clean Ubuntu x64 checkout. If the task scope passes without required SKIPs, perform the final completion checkpoint and close this handoff forward-only.

## Blockers / open questions

- Runtime validation of the latest revisions is the only remaining completion blocker.
- No unresolved architectural choice remains in the current override/composition model.
