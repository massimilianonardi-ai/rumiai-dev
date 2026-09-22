# Portable MacGPG package

Status: Active
Updated: 2026-09-22

## Goal

Add a macOS Apple Silicon package definition that installs the MacGPG engine from the official GPG Suite distribution as a relocatable managed package and exposes the `gpg` command without installing GPG Suite system-wide.

## Current repository revisions

```text
rumiai-dev   62d51f54ab720ae858f586dba90515a910571b73
rumiai-os    b3c39830b66e85f4ec63def3f3bcd91af853cbe7
rumiai-tests 80faa275df8c97be088c79419a70d54c7d8131c7
pkg-catalog  64d67a73f4f9485749e1b47712e42f77afb4773e
```

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
handoff/README.md
```

## Fixed task-local choices

- The upstream distribution is GPGTools MacGPG carried inside the official GPG Suite DMG.
- Mutable GnuPG state must use the existing package HOME/state model rather than being stored inside the immutable package root.
- Provider-specific component identity remains catalog data; generic package code must not hardcode `MacGPG2.pkg`.

## Working design

The current package pipeline can extract a DMG but cannot materialize one component payload from a flat installer package embedded in that DMG. The minimal candidate extension is a generic compound package-extraction format for:

```text
DMG -> flat .pkg -> named component .pkg -> Payload
```

The component name would be declarative package metadata. This avoids a GPGTools-specific installer in generic code. The exact metadata spelling and public `pkg_extract` API change still require final consistency review before promotion.

## Completed

- Mandatory preflight completed against the repository revisions above.
- Current package install, extraction and integration paths inspected.
- Existing permanent `pkg-extract` contract test inspected.
- Upstream GPGTools distribution shape and current release source investigated.

## Current state

A catalog-only definition is insufficient for the requested portable MacGPG result because `format=dmg` materializes the installer package rather than the MacGPG payload. A generic compound-extraction capability is required before the package definition can be correct.

## Next action

Finalize the smallest generic compound-extraction contract, promote it to the package specification, implement it in the existing package extraction/integration path with operational documentation and permanent tests, then add the MacGPG catalog definition.

## Blockers / open questions

- Physical macOS validation is not yet available in the current execution environment and must be reported revision-specifically unless an applicable macOS validation path is executed.
