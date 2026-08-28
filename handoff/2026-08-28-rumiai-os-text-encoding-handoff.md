# Handoff — RumiAI OS language catalogs and text encoding

Date: 2026-08-28
Status: **active design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product boundary

Phase 0 in `rumiai-os` remains complete and consolidated.

No phase-1 product implementation has been authorized or performed yet. Current changes are design/specification only in `rumiai-dev`.

## Accepted phase-1 semantic roots

```text
RumiAI_BIN_DIR  = $RumiAI_ROOT/bin
RumiAI_LIB_DIR  = $RumiAI_ROOT/lib
RumiAI_CONF_DIR = $RumiAI_ROOT/conf
RumiAI_LANG_DIR = $RumiAI_ROOT/lang
```

`RumiAI_BIN_DIR` is prepended to the inherited PATH. Libraries are loaded explicitly from `RumiAI_LIB_DIR`.

No generic `share/` or `resources/` directory exists at this stage.

## Bootstrap primitive principle

Minimal bootstrap primitives are allowed when needed to break dependency cycles; advanced subsystems become authoritative once initialized.

Accepted interaction bootstrap primitives:

```text
$RumiAI_CONF_DIR/bootstrap/language
$RumiAI_CONF_DIR/bootstrap/text-encoding
```

They are data, not sourced shell code.

## Language

Canonical interaction-language variable:

```text
RumiAI_LANGUAGE
```

Canonical language identity:

```text
language_TERRITORY
```

Examples:

```text
en_US
it_IT
```

Language fallback order:

```text
1. conf/bootstrap/language
2. LC_ALL
3. LC_MESSAGES
4. LANG
5. en_US
```

The codeset is not part of `RumiAI_LANGUAGE`.

## Text encoding

Canonical interaction text-encoding variable:

```text
RumiAI_TEXT_ENCODING
```

Explicit bootstrap preference:

```text
$RumiAI_CONF_DIR/bootstrap/text-encoding
```

Initial implementation and guaranteed fallback:

```text
UTF-8
```

The variable is configurable because it belongs to the interaction boundary. Additional external encodings may be implemented later.

## Internal invariant

RumiAI-controlled internal text is UTF-8.

The internal control plane uses English + UTF-8.

User payloads and external data may use any language; when represented as internal text they are normalized/transcoded to UTF-8.

## Catalogs

All language catalogs are UTF-8.

Canonical layout:

```text
lang/en_US/
lang/it_IT/
```

No encoding is encoded in the catalog pathname.

Rejected identities:

```text
lang/it_IT.UTF-8/
lang/it_IT/UTF-8/
```

Catalogs are not duplicated per encoding.

## Boundary transcoding

```text
external encoding
    ↓ transcode/decode
internal UTF-8
    ↓ RumiAI processing/catalog rendering
internal UTF-8
    ↓ transcode/encode
external encoding
```

With `RumiAI_TEXT_ENCODING=UTF-8`, no transcoding is required.

Unsupported requested external encoding should normally fall back to UTF-8 when the boundary remains usable, with diagnostics emitted after logger activation rather than making bootstrap fatal unnecessarily.

## Canonical material

```text
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
architecture/rumiai-os/PHASE-1.md
decisions/rumiai-os/2026-08-28-phase-1-bootstrap-environment.md
decisions/rumiai-os/2026-08-28-text-encoding-boundary.md
```

## Immediate next work

Before implementing phase 1 in `rumiai-os`:

1. define the minimal i18n catalog file/API contract;
2. design the logger API and initialization based on the audited `m` logger concepts;
3. keep i18n/logger failures non-fatal where a usable `en_US` + UTF-8 fallback exists.
