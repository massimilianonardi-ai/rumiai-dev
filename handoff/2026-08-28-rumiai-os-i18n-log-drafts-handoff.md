# Handoff — RumiAI OS phase 1 i18n/logger drafts

Date: 2026-08-28
Status: **active design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product boundary

Phase 0 in `rumiai-os` remains complete and consolidated.

No phase-1 product implementation has been authorized or performed yet.

Current work is stored only as design/specification/drafts in `rumiai-dev`.

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

Catalogs and RumiAI-controlled internal text are UTF-8.

## Accepted i18n/log event model

Canonical localizable event:

```text
severity
domain
message-id
structured field name/value pairs
```

Preferred public syntax:

```sh
log warn bootstrap language-fallback \
    requested "$requested" \
    selected "$selected"
```

Public `log_warn`, `log_info`, etc. are not preferred.

Severity is explicitly validated; arbitrary input is not blindly converted into a function name.

Initial severities:

```text
fatal
error
warn
info
debug
trace
```

`fatal` is severity only and does not imply process termination.

## Bootstrap message rendering

Bootstrap catalogs contain static UTF-8 messages.

Dynamic values remain structured fields.

No bootstrap placeholders, shell variable expansion or `eval`.

A future advanced renderer may interpolate the SAME structured fields into localized templates without changing the `log` API.

## Draft implementation location

Near-code drafts are stored at:

```text
drafts/rumiai-os/phase-1-i18n-log/
```

Current files:

```text
README.md
FLOW.md
VALIDATION.md
i18n.lib
log.lib
lang/en_US/bootstrap/language-fallback
lang/en_US/bootstrap/text-encoding-fallback
lang/it_IT/bootstrap/language-fallback
lang/it_IT/bootstrap/text-encoding-fallback
```

These files are explicitly non-normative and are not product code.

## Current draft behavior

### i18n

Conceptual API:

```sh
i18n domain message-id
```

Lookup:

```text
selected language
    ↓
en_US
    ↓
domain.message-id
```

Current draft bootstrap catalog objects are one newline-terminated physical line. This remains a draft simplification, not a final permanent catalog-format decision.

### logger

Current draft flow:

```text
log severity domain message-id fields...
    ↓
validate severity
    ↓
map numeric priority
    ↓
filter against draft RumiAI_LOG_LEVEL
    ↓
resolve i18n text
    ↓
render timestamp/severity/stable ID/static text
    ↓
append escaped structured fields
    ↓
stderr
```

The current provisional default is:

```text
RumiAI_LOG_LEVEL=info
```

The final configuration source/default policy is not decided.

## Local draft validation

The near-code structure was exercised locally under:

```text
dash
bash --posix
busybox sh
```

All three completed the same example flow with status 0 and no stdout.

Validated draft behaviors include:

- Italian catalog hit;
- English catalog fallback;
- stable-ID fallback when a message is absent;
- `info` filtering of `debug`;
- invalid severity status 2;
- incomplete field pairs status 2;
- one-line display escaping of newline/quote/backslash examples.

This is ad hoc local validation only, not reference-host certification or a formal PoC session.

## Canonical material

```text
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/I18N-BOOTSTRAP.md
architecture/rumiai-os/PHASE-1.md
decisions/rumiai-os/2026-08-28-i18n-message-fields.md
decisions/rumiai-os/2026-08-28-phase-1-bootstrap-environment.md
decisions/rumiai-os/2026-08-28-text-encoding-boundary.md
```

## Immediate next design task

Decide physical/module boundaries before product implementation:

1. where `i18n` and `log` implementations should live in the final `rumiai-os` tree;
2. whether they are separate `.lib` sourced libraries or organized differently;
3. exact phase-1 load/call sequence from the `rumiai-os` front controller;
4. whether the logger should be initialized through a dedicated function or by sourcing declarative library state;
5. then decide log-level configuration, timestamp/context schema and final field serialization;
6. only after those decisions decide whether a formal PoC is warranted before product write.
