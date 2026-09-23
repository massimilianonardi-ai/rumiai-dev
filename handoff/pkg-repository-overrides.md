# Package repository override model

Status: Active
Updated: 2026-09-23

## Goal

Refactor the package repository-adapter model so each repository `type` remains a complete, standalone implementation while selected artifact-resolution responsibilities can be overridden through typed, reusable handlers. Use current repository adapters as evidence, promote only abstractions demonstrated by real cases, and reduce package-specific adapter duplication without weakening the canonical artifact-descriptor/download contract.

## Current repository revisions

```text
rumiai-dev      ae577be8bd227601132d861704aace77422d7c24  (pre-checkpoint HEAD before this synchronization)
rumiai-os       605e9e0e12b6907d0958bbd72d7f3bab79db6d2e
rumiai-tests    4c77fa4832f3999d9fc828ff8ec5c16a62bb70b2
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
- Ubuntu x64 task validation against `rumiai-os@c2d8d4a0c4503e1de461e72840a13abb0da61c41` produced real FAILs in `pkg-repository-artifact/contract.test` (`checksum-sidecar resolution failed`) and `pkg-repository-github/artifact.test` (`composed download+metadata overrides failed`), while Apache Maven and GeoServer passed.
- Diagnosed both FAILs to one POSIX-shell variable-clobbering bug: `_pkg_repository_artifact_metadata_validate` reused `pkg_repository_artifact_name` as an internal field-name variable, overwriting the caller's resolved artifact name with `url-template`; composed metadata resolution therefore expanded `{name}` incorrectly.
- Fixed the bug by isolating download/metadata validators in subshells so their temporary state cannot mutate the calling resolver. The isolated reproduction of the checksum-sidecar path passes after this change.
- Retargeted `validation/pkg-repository-overrides.conf` to `rumiai-os@605e9e0e12b6907d0958bbd72d7f3bab79db6d2e`.

## Current state

The architecture and implementation are aligned around one shared artifact-mechanism layer usable in two ways: explicit catalog overrides and internal composition by complete repository types. Current evidence supports `template-url`, `checksum-sidecar`, `checksum-manifest` and `sourceforge-rss`; other adapters remain custom rather than being forced into broader handlers.

Ubuntu x64 validation has now exercised the full dedicated task scope. The original revision failed only in the shared artifact metadata path and GitHub composition path; Apache Maven and GeoServer passed. The common failure was diagnosed to validator variable leakage rather than provider semantics or host-specific behavior. The validator-isolation fix is committed in `rumiai-os@605e9e0e12b6907d0958bbd72d7f3bab79db6d2e`, and the validation scope is pinned to that exact revision. Formal rerun evidence for the fixed revision is still pending.

## Next action

On Ubuntu x64, fast-forward `rumiai-tests` and run `./rumiai-validate pkg-repository-overrides`. The launcher will update `rumiai-os`, validate exactly `605e9e0e12b6907d0958bbd72d7f3bab79db6d2e`, and publish evidence. If the task scope passes without required SKIPs, perform the final completion checkpoint and close this handoff forward-only.

## Blockers / open questions

- Runtime validation of the latest revisions is the only remaining completion blocker.
- No unresolved architectural choice remains in the current override/composition model.
