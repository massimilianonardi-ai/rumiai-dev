# Handoff — RumiAI OS minimal i18n and log event model

Date: 2026-08-28
Status: **active design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product boundary

Phase 0 in `rumiai-os` remains complete and consolidated.

No phase-1 product implementation has been authorized or performed yet. Current work remains design/specification in `rumiai-dev`.

## Accepted bootstrap environment

```text
RumiAI_BIN_DIR  = $RumiAI_ROOT/bin
RumiAI_LIB_DIR  = $RumiAI_ROOT/lib
RumiAI_CONF_DIR = $RumiAI_ROOT/conf
RumiAI_LANG_DIR = $RumiAI_ROOT/lang
```

Bootstrap interaction preferences:

```text
$RumiAI_CONF_DIR/bootstrap/language
$RumiAI_CONF_DIR/bootstrap/text-encoding
```

Canonical variables:

```text
RumiAI_LANGUAGE
RumiAI_TEXT_ENCODING
```

Initial/fallback values:

```text
en_US
UTF-8
```

Catalogs and internal controlled text are UTF-8. Catalog identity does not include the codeset.

## Minimal i18n event identity

A localizable event uses:

```text
domain
message-id
structured fields
```

Stable combined notation:

```text
domain.message-id
```

Example:

```text
bootstrap.language-fallback
```

## Minimal catalog layout

```text
lang/<language>/<domain>/<message-id>
```

Examples:

```text
lang/en_US/bootstrap/language-fallback
lang/it_IT/bootstrap/language-fallback
```

Each bootstrap message object is static UTF-8 data and is never sourced as shell code.

Resolution order:

```text
selected language
    ↓
en_US
    ↓
domain.message-id
```

Missing translations should therefore normally be non-fatal.

## Logger API direction

Preferred public syntax:

```sh
log warn bootstrap language-fallback requested "$requested" selected "$selected"
```

Conceptual structure:

```text
log severity domain message-id [field-name field-value]...
```

Preferred over public `log_warn`, `log_info`, etc.

Severity dispatch must be explicitly validated (for example using `case`) rather than blindly constructing a function name from arbitrary input.

Canonical initial levels:

```text
fatal
error
warn
info
debug
trace
```

`fatal` is severity only and does not imply `exit`.

## Static messages and structured fields

Accepted bootstrap rule:

- localized bootstrap text is static;
- no placeholders are required in bootstrap catalogs;
- no shell variable names inside catalog strings;
- no `eval`;
- dynamic values remain structured fields.

Example canonical event:

```text
severity:   warn
domain:     bootstrap
message-id: language-fallback
requested:  xx_YY
selected:   en_US
```

The user renderer may append the structured fields after the translated static message.

## Future interpolation

Both flexibility and bootstrap simplicity are preserved by allowing a future advanced renderer to interpolate the same structured fields into localized templates.

This does NOT change the event API:

```text
bootstrap:
static text + fields

advanced:
static text OR template(fields) + fields
```

The placeholder syntax is deliberately not chosen yet.

Fields remain canonical event data even if their values are also inserted into translated prose.

## Canonical material

```text
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/I18N-BOOTSTRAP.md
architecture/rumiai-os/PHASE-1.md
decisions/rumiai-os/2026-08-28-i18n-message-fields.md
decisions/rumiai-os/2026-08-28-phase-1-bootstrap-environment.md
decisions/rumiai-os/2026-08-28-text-encoding-boundary.md
```

## Immediate next work

Before product implementation:

1. make the logger core/event pipeline concrete;
2. define log level configuration and filtering;
3. define safe rendering/escaping of structured field values;
4. define the minimal stderr/user sink;
5. then evaluate whether the resulting phase-1 bootstrap is small enough to implement directly or warrants a PoC first.
