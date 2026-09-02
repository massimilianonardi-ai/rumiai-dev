# RumiAI OS — Minimal Bootstrap `lang`

Status: **Normative specification**  
Date: 2026-09-02

## 1. Scope

This specification defines the minimal language-message resolver available during the RumiAI bootstrap/runtime initialization.

The subsystem/API name is:

```text
lang
```

The previous bootstrap name `i18n` is superseded.

## 2. Catalog roots

The bootstrap environment provides:

```text
m_LANG_DIR
m_LANG_CURRENT_DIR=$m_LANG_DIR/current
m_LANG_FALLBACK_DIR=$m_LANG_DIR/en_US
m_LANGUAGE_FALLBACK=en_US
m_TEXT_ENCODING=UTF-8
```

`lang/current` is a relative symlink to the selected language directory:

```text
lang/current -> it_IT
```

The resolver does not infer a language from the host locale and does not read a bootstrap language configuration value.

## 3. Message identity

A message is canonically identified by:

```text
domain
message-id
```

Combined notation:

```text
domain.message-id
```

The localized text is presentation data, not canonical identity.

Dynamic event values remain structured fields owned by the logger/event layer.

## 4. Catalog layout

Canonical shape:

```text
lang/<language_TERRITORY>/<domain>/<message-id>
```

Examples:

```text
lang/it_IT/bootstrap/example
lang/en_US/bootstrap/example
```

Catalog objects are UTF-8 data and MUST NOT be sourced or evaluated as shell code.

## 5. Resolution order

For `(domain, message-id)`, `lang` resolves in this order:

```text
1. m_LANG_CURRENT_DIR/<domain>/<message-id>
2. m_LANG_FALLBACK_DIR/<domain>/<message-id>
3. literal domain.message-id
```

Failure to find a localized message is therefore normally non-fatal.

A missing/broken `lang/current` selection naturally falls through to `lang/en_US` when the fallback catalog exists.

## 6. API

Canonical shell API:

```sh
lang "$domain" "$message_id"
```

On success it emits exactly the resolved message text followed by the API's normal line terminator.

The domain and message identifier are controlled identifiers; validation may reject malformed names before filesystem lookup.

No `i18n` compatibility alias is required.

## 7. Message data constraints

Bootstrap catalog contents are static data.

The bootstrap resolver does not execute:

```text
shell expansion
eval
template expressions
catalog-provided code
```

Placeholder/interpolation support is not part of the current bootstrap resolver.

If a future renderer adds interpolation, values must continue to originate from the logger/event structured fields rather than a second dynamic-value API.

## 8. Encoding

Catalogs and RumiAI-controlled text use:

```text
UTF-8
```

No bootstrap encoding negotiation is performed.

## 9. Language-selection utility

The command/script that lets the user choose among existing language directories and atomically/safely updates the relative `lang/current` symlink remains to be designed.

That utility must not reintroduce host-locale inference into the bootstrap selection contract.
