# Package repository override model

Status: Active
Updated: 2026-09-23

## Goal

Refactor the package repository-adapter model so each repository `type` remains a complete, standalone implementation while selected artifact-resolution responsibilities can be overridden through typed, reusable handlers. Use current repository adapters as evidence, promote only abstractions demonstrated by real cases, and reduce package-specific adapter duplication without weakening the canonical artifact-descriptor/download contract.

## Current repository revisions

```text
rumiai-dev      7fdf2ce9f18a24d28ba9e119a86fd8097cbfb969
rumiai-os       f2747e16560d0fbbe1cc0fe6e4d5c6c836ef041b
rumiai-tests    fa5e811b84954e734e1b3fde4b0bb946998fa80e
rumiai-dev-PoCs c16e4b9b66126e5f17f83a84b9584e27b8d9fe71
pkg-catalog     6a77995d317f2ec08c98585c4462b92557ccfaea
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
- Override implementations are trusted RumiAI code with closed schemas; catalog data does not embed shell, callbacks, arbitrary expressions or executable parsing logic.
- Existing `digest_type` remains the integrity algorithm selector and is not reused as an override-handler identity.
- The final artifact resolver must continue to emit the existing canonical descriptor consumed by generic `pkg-download`; generic download code remains provider-agnostic.

## Working design

- Candidate artifact override dimensions are download-location resolution and artifact metadata/integrity resolution.
- A simple download handler should support a closed URL/name template vocabulary based initially on resolved `version` and artifact `name`.
- NetBeans and Node.js demonstrate a shared checksum-text mechanism: fetch one URL, select exactly one record for the resolved artifact name, and validate the digest according to existing `digest_type`.
- SourceForge RSS is broader than a digest-only mechanism because it supplies artifact existence, size and digest; its correct override boundary and naming must be derived from the full adapter matrix.
- Repository-specific types may internally reuse the same typed handlers used by explicit catalog overrides; catalog exposure is not required merely for implementation reuse.
- Handler identities should describe mechanisms rather than vendors whenever the real contract is provider-independent.

## Completed

- Initial current-source preflight completed.
- Current NetBeans, Node.js and GeoServer behavior compared and the typed single-responsibility override direction accepted by the user.

## Current state

No product, test or catalog implementation has yet been changed for this refactor. The next step is to classify every current repository adapter by version/discovery policy, artifact-name resolution, download-location resolution, size source and integrity-metadata source, then derive the minimum non-forced handler set.

## Next action

Build the complete current adapter matrix and identify which existing specialized repository types can be represented by a generic type plus typed overrides without changing observable package semantics.

## Blockers / open questions

- Final stable names and exact schemas for override dimensions/handlers remain unresolved until the full adapter matrix is complete.
