# documentation-language-normalization

Status: Active
Updated: 2026-09-17

## Goal

Normalize the current canonical RumiAI development documentation to English so the active knowledge base has one maintenance language and does not mix languages across documents.

The work must translate current canonical documents in place. It must not create parallel translated copies or a second documentation authority.

## Current repository revisions

```text
rumiai-dev  c075f9e8151c6e1a5640196ba7e4eaf6c2b6ccf1  (pre-task HEAD)
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

- English is the target language for current canonical development documentation in `rumiai-dev`.
- Translation is performed in place; no side-by-side translated documents are created.
- Technical identifiers, command names, literal paths, code, protocol tokens and externally defined terminology remain unchanged unless a separate current contract requires a change.
- Translation must preserve normative force and semantics; `MUST`/`SHOULD`-level meaning must not be weakened or strengthened accidentally.
- If translation exposes stale text that conflicts with current canonical sources, apply the normal authority hierarchy and realign the stale text instead of faithfully translating a superseded claim.
- Product/user-facing localization is a separate concern and is not established by this task.

## Completed

- The current `rumiai-dev` tree was inspected.
- Mixed-language current documentation was confirmed.
- Known Italian current documents include at least:

  ```text
  TESTING.md
  RUNNER.md
  TEST-PATTERNS.md
  specifications/rumiai-os/RESOURCE-MODEL.md
  specifications/rumiai-os/LANG-BOOTSTRAP.md
  ```

- `TESTING.md` also exposed at least one stale repository-role description that still refers to old `decisions` / `architecture` organization; the normalization pass must not preserve such superseded wording.

## Current state

The task is active. The complete current tree must be audited so no current canonical Markdown document remains unintentionally Italian or mixed-language after completion.

## Next action

Audit every current canonical documentation file, translate the Italian/mixed-language documents to English in place, realign any stale wording exposed by the translation, then run the documentation consistency gate and close this handoff through the normal final-snapshot/delete lifecycle.

## Blockers / open questions

None.
