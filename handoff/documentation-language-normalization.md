# documentation-language-normalization

Status: Complete
Updated: 2026-09-17

## Goal

Normalize the current canonical RumiAI development documentation to English so the active knowledge base has one maintenance language and does not mix languages across documents.

## Current repository revisions

```text
rumiai-dev  37d9855543b11bfc652cf55c825568c243bf0c82  (normalization implementation commit)
```

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
handoff/README.md
```

## Fixed task-local choices

- Current canonical development documentation in `rumiai-dev` is maintained in English; this durable rule is now canonical in `README.md`.
- Translation is performed in place; no side-by-side translated authority is created.
- Technical identifiers, command names, literal paths, code, protocol tokens and externally defined terminology retain their exact spelling unless a separate current contract changes them.
- Translation preserves normative meaning.
- Stale wording exposed by translation is realigned according to current authority instead of being translated as if it were still current.
- Product/user-facing localization remains a separate concern.

## Completed

The current documentation tree was audited and the Italian/mixed-language current documents were normalized to English in one atomic commit:

```text
TESTING.md
RUNNER.md
TEST-PATTERNS.md
specifications/rumiai-os/RESOURCE-MODEL.md
specifications/rumiai-os/LANG-BOOTSTRAP.md
```

The pass also removed current-tree drift exposed by the translation:

- `TESTING.md` no longer describes the pre-reset `rumiai-dev` role in terms of `decisions` / `architecture`; repository ownership now points to the root current router instead of maintaining a stale independent role table.
- revision-specific suite-realignment evidence was removed from `TESTING.md`; such evidence belongs in revision-specific validation mechanisms/history, not in the current testing contract.
- the historical revision reference in `TEST-PATTERNS.md` was removed while preserving the current pattern contract.

Validation performed:

- reviewed the resulting five-file diff;
- re-read representative translated contracts;
- searched the current repository for primary Italian documentation markers (`Questo documento`, `Questa specifica`, `Scopo`) with no remaining results;
- no runtime or physical tests were run because the work unit changed documentation only.

## Current state

The language-normalization work unit is complete. Current canonical development documentation is intended to be English under the policy now recorded in the root `README.md`.

## Next action

None.

## Blockers / open questions

None.
