# RumiAI OS — Minimal Bootstrap i18n

Status: **Normative specification**  
Date: 2026-08-28

## 1. Scope

This specification defines the minimal i18n resolver required during phase 1 before the advanced configuration and internationalization subsystems are available.

Its purpose is to make the first normal RumiAI diagnostics localizable without introducing a full gettext/template stack into the bootstrap dependency chain.

The minimal resolver is intentionally replaceable by a more advanced implementation after bootstrap.

## 2. Inputs

The resolver consumes the already-established bootstrap state:

```text
RumiAI_LANG_DIR
RumiAI_LANGUAGE
RumiAI_TEXT_ENCODING
```

Catalog source text is always UTF-8.

`RumiAI_TEXT_ENCODING` applies to the interaction boundary and does not alter catalog encoding.

## 3. Catalog identity

A bootstrap message is identified canonically by two independent identifiers:

```text
domain
message-id
```

Combined human/machine notation:

```text
domain.message-id
```

Example:

```text
bootstrap.language-fallback
```

The combined notation is an event/message identifier, not necessarily a filesystem object.

## 4. Minimal catalog layout

The initial resolver uses the filesystem shape:

```text
$RumiAI_LANG_DIR/$RumiAI_LANGUAGE/$domain/$message-id
```

Example:

```text
lang/it_IT/bootstrap/language-fallback
```

English fallback:

```text
lang/en_US/bootstrap/language-fallback
```

Each bootstrap message object contains static UTF-8 presentation text as data.

The bootstrap catalog object MUST NOT be sourced as shell code.

## 5. Bootstrap message constraints

Minimal bootstrap messages are static.

They MUST NOT require:

```text
shell variable expansion
positional placeholder expansion
eval
template execution
expression evaluation
```

Dynamic event data remains outside the localized string as structured fields.

Example canonical event:

```text
severity:   warn
domain:     bootstrap
message-id: language-fallback
requested:  xx_YY
selected:   en_US
```

Possible Italian presentation:

```text
La lingua richiesta non è disponibile; verrà utilizzata la lingua di fallback.
```

The values `xx_YY` and `en_US` remain structured fields rather than being required inside this bootstrap sentence.

## 6. Resolution order

For a requested `(domain, message-id)`, the minimal resolver attempts:

```text
1. $RumiAI_LANG_DIR/$RumiAI_LANGUAGE/$domain/$message-id
2. $RumiAI_LANG_DIR/en_US/$domain/$message-id
3. literal stable identifier: $domain.$message-id
```

Failure to find a requested translation is therefore normally non-fatal.

If the selected language catalog is incomplete but the English message exists, English is used.

If both localized and English messages are unavailable, the stable `domain.message-id` remains renderable.

## 7. Resolver API shape

The preferred minimal API shape is conceptually:

```sh
i18n "$domain" "$message_id"
```

The implementation returns/renders the resolved UTF-8 static message text.

The exact shell implementation must preserve the existing RumiAI POSIX and error-handling rules and must not use `eval`.

## 8. Logger event API

The logger public API uses a single entrypoint with severity as an explicit argument:

```sh
log warn bootstrap language-fallback \
    requested "$requested" \
    selected "$selected"
```

Conceptual argument structure:

```text
log
severity
domain
message-id
[field-name field-value]...
```

The logger MUST validate severity explicitly rather than blindly converting arbitrary input into a function name.

The canonical initial severity set is expected to preserve the established RumiAI/m lineage:

```text
fatal
error
warn
info
debug
trace
```

`fatal` is a severity and does not itself imply process termination.

## 9. Structured fields

Dynamic values belong to structured fields.

The logger/event layer must preserve field name/value pairs independently of localized presentation text.

A user-oriented renderer may initially append a readable representation of fields after the static translated message.

Field rendering/escaping rules must be defined before product implementation so arbitrary field values cannot corrupt line structure or become executable syntax.

## 10. Advanced interpolation compatibility

The bootstrap resolver does not implement placeholders.

A future advanced i18n renderer MAY support localized templates with placeholders, pluralization, gettext-backed catalogs or other capabilities.

If interpolation is later supported:

- placeholder values MUST originate from the same structured fields already present in the canonical event;
- no second dynamic-value API is introduced;
- the public `log` call need not change;
- fields remain part of the canonical event even when rendered inside localized prose;
- catalog content must remain data, not executable shell code.

The future placeholder syntax is intentionally unspecified at bootstrap stage.

## 11. Replaceability

The bootstrap resolver is a primitive, not the permanent i18n architecture.

Expected evolution:

```text
minimal filesystem resolver
        ↓
logger becomes available
        ↓
advanced configuration/i18n initializes
        ↓
advanced resolver becomes authoritative
```

The stable contract to preserve across implementations is:

```text
language
domain
message-id
structured fields
UTF-8 internal representation
```

This allows a future POSIX gettext-compatible backend or another advanced backend to replace the bootstrap resolver without changing callers of the logger.
