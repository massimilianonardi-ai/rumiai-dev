# Phase 1 i18n + logger drafts

Status: **draft / non-normative / not product code**  
Date: 2026-08-28

This directory contains near-code drafts for the phase-1 bootstrap i18n resolver and logger.

The purpose is to make the accepted architecture concrete enough to review before deciding:

- final product paths;
- exact library/script boundaries;
- how `rumiai-os` loads or invokes them;
- whether a dedicated PoC is required before product implementation.

Nothing in this directory is automatically promoted to `rumiai-os`.

## Accepted contracts represented here

```text
RumiAI_LANGUAGE
RumiAI_TEXT_ENCODING

conf/bootstrap/language
conf/bootstrap/text-encoding

lang/<language>/<domain>/<message-id>
```

Catalogs are UTF-8 and contain static bootstrap messages.

Canonical event shape:

```text
severity
domain
message-id
structured field name/value pairs
```

Preferred public logger call:

```sh
log warn bootstrap language-fallback \
    requested "$requested" \
    selected "$selected"
```

`fatal` is a severity only; it does not imply `exit`.

## Files

```text
i18n.lib
    draft minimal filesystem resolver

log.lib
    draft logger entrypoint, level filtering and stderr renderer

lang/
    tiny example catalogs used to make lookup behavior concrete
```

## Intended draft pipeline

```text
log severity domain message-id fields...
        ↓
validate severity / map priority
        ↓
filter by RumiAI_LOG_LEVEL
        ↓
i18n domain message-id
        ↓
selected-language catalog
        ↓ fallback
en_US catalog
        ↓ fallback
domain.message-id
        ↓
render one stderr line
        ↓
append escaped structured fields
```

## Deliberately unresolved

These drafts MUST NOT be treated as decisions on the following points:

1. final physical location of `i18n.lib` and `log.lib` in `rumiai-os`;
2. whether they remain separate sourced libraries or are composed differently;
3. exact initialization call sequence from the `rumiai-os` front controller;
4. final `RumiAI_LOG_LEVEL` configuration source and default policy;
5. final timestamp/context schema;
6. final field serialization/escaping format;
7. whether bootstrap catalog messages are permanently restricted to one physical line;
8. advanced i18n backend and placeholder syntax;
9. final transcoder API for non-UTF-8 interaction boundaries.

## Important draft simplifications

The current `log.lib` contains a deliberately simple stderr renderer. Its escaping function is suitable for inspecting the architecture but is not yet the final byte-preserving structured-log serialization contract.

The canonical structured field values are still passed separately to `log`; escaping affects only their user-facing stderr representation.

No `eval` is used.
