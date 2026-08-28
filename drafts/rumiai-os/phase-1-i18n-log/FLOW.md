# Draft execution flow

Status: **explanatory draft**  
Date: 2026-08-28

This file explains what the near-code drafts currently do. It is not a normative API specification.

## Example call

```sh
log warn bootstrap language-fallback \
    requested "$requested" \
    selected "$selected"
```

Arguments are interpreted as:

```text
severity   warn
domain     bootstrap
message-id language-fallback
field      requested = <value>
field      selected  = <value>
```

## 1. Severity validation

`log` validates the first argument with an explicit `case`:

```text
fatal → 1
error → 2
warn  → 3
info  → 4
debug → 5
trace → 6
```

An unknown severity returns an API error instead of constructing and executing a dynamic function name.

`fatal` does not exit.

## 2. Level filtering

The current draft uses:

```text
RumiAI_LOG_LEVEL=info
```

only as a provisional default.

With `info`, priorities 1 through 4 are emitted and `debug`/`trace` are suppressed.

The source of the final logging configuration is intentionally undecided.

Filtering happens before catalog lookup so suppressed messages do not perform unnecessary i18n work.

## 3. Event identity validation

`domain` and `message-id` are validated as controlled identifiers before being used to construct catalog paths.

Example stable identity:

```text
bootstrap.language-fallback
```

## 4. Structured field validation

All remaining arguments must occur as pairs:

```text
field-name field-value
```

Field names are controlled identifiers. Field values are data and may contain arbitrary shell-string content.

No field value is interpreted as code or as the name of another variable.

## 5. i18n lookup

The logger calls conceptually:

```sh
i18n bootstrap language-fallback
```

For `RumiAI_LANGUAGE=it_IT`, the resolver tries:

```text
lang/it_IT/bootstrap/language-fallback
```

then:

```text
lang/en_US/bootstrap/language-fallback
```

then the literal stable ID:

```text
bootstrap.language-fallback
```

Catalog objects are read as data, never sourced.

The current draft treats a bootstrap catalog object as exactly one newline-terminated physical line. This is a draft simplification, not yet a permanent catalog-format decision.

## 6. User/stderr rendering

The current draft renders one line:

```text
[timestamp] [severity] [domain.message-id] localized text [field="value"] ...
```

Example:

```text
[2026-08-28T10:00:00] [warn] [bootstrap.language-fallback] La lingua richiesta non è disponibile; verrà utilizzata la lingua di fallback. [requested="xx_YY"] [selected="en_US"]
```

The timestamp format and exact line schema are still drafts.

## 7. Field rendering

Structured fields remain canonical separate data in the call/event model.

The current stderr renderer escapes common line-breaking/display characters to keep a single physical log line readable.

Example value:

```text
line1
line2 "quoted"
```

is displayed approximately as:

```text
[value="line1\nline2 \"quoted\""]
```

This display escaping is not yet the final byte-preserving structured serialization format.

## 8. Future advanced renderer

The same call can later feed an advanced renderer:

```text
canonical event
    ↓
advanced i18n
    ↓
optional template interpolation from the SAME fields
```

No new dynamic-value arguments are needed.

For example a future catalog may conceptually render:

```text
La lingua {requested} non è disponibile; verrà utilizzata {selected}.
```

using `requested` and `selected` already present in the event.

The placeholder syntax is not chosen yet.

## 9. Current dependency shape

The drafts currently imply:

```text
i18n.lib
    requires RumiAI_LANG_DIR + RumiAI_LANGUAGE

log.lib
    requires i18n API
    uses RumiAI_LOG_LEVEL draft state
    writes user-oriented output to stderr
```

How these functions will be physically packaged and loaded by `rumiai-os` is intentionally the next design discussion.
