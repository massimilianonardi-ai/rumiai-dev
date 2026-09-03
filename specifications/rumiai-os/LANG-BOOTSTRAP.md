# RumiAI OS — Minimal Bootstrap `lang`

Status: **Normative specification**  
Date: 2026-09-02  
Updated: 2026-09-03

## 1. Scope

This specification defines the minimal language-message resolver and the public language commands available in the RumiAI bootstrap/runtime environment.

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

Domains SHOULD describe reusable semantic areas rather than the component that happens to emit a message when the condition can be shared across components.

Current domains include:

```text
filesystem
execution
security
system
```

The `system` domain currently contains the OS/architecture identities:

```text
system.osarch-detection-failure
system.osarch-update-failure
```

Both identities MUST exist in every current product language catalog.

Examples of other reusable identities include:

```text
filesystem.path-non-existent
filesystem.path-is-readonly
filesystem.execution-bit-not-set
filesystem.file-is-not-executable
execution.command-not-found
security.command-requires-root-privileges
```

## 4. Catalog layout

Canonical shape:

```text
lang/<language_TERRITORY>/<domain>/<message-id>
```

Examples:

```text
lang/it_IT/filesystem/path-non-existent
lang/en_US/security/command-requires-root-privileges
lang/en_US/system/osarch-detection-failure
```

Catalog objects are UTF-8 data and MUST NOT be sourced or evaluated as shell code.

The historical product catalog domain `bootstrap` is superseded for current messages. Historical revisions and evidence remain historical data and are not rewritten.

## 5. Resolution order

For `(domain, message-id)`, `lang` resolves in this order:

```text
1. m_LANG_CURRENT_DIR/<domain>/<message-id>
2. m_LANG_FALLBACK_DIR/<domain>/<message-id>
3. literal domain.message-id
```

Failure to find a localized message is therefore normally non-fatal.

A missing/broken `lang/current` selection naturally falls through to `lang/en_US` when the fallback catalog exists.

## 6. API and public command

Canonical shell API:

```sh
lang "$domain" "$message_id"
```

On success it emits exactly the resolved message text followed by the API's normal line terminator.

The domain and message identifier are controlled identifiers; validation may reject malformed names before filesystem lookup.

The public command is:

```text
bin/sys/lang
```

It uses the standard RumiAI command entry and delegates directly to the already initialized shell API:

```sh
lang "$@"
```

It MUST NOT duplicate catalog resolution logic.

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

## 9. Language-selection command

The canonical selector is:

```text
bin/sys/lang-set
```

It does not infer language from `LC_ALL`, `LC_MESSAGES`, `LANG` or any other host locale source.

### 9.1 Available languages

An available language is an immediate directory under:

```text
m_LANG_DIR
```

`current` is excluded because it represents selection state rather than a catalog.

Selection is by exact directory-name match. `lang-set` does not introduce aliases, fuzzy matching or host-locale normalization.

### 9.2 Query form

With no arguments:

```text
lang-set
```

outputs:

```text
current<TAB><language>
<language><TAB><non-empty-message-count>
...
```

The first row identifies the effective current language. A valid `lang/current` target takes precedence; otherwise the effective current language is `m_LANGUAGE_FALLBACK`, matching resolver behavior.

Each following row represents one available language. Its count includes only regular, non-empty files at canonical message depth:

```text
m_LANG_DIR/<language>/<domain>/<message-id>
```

Directories, empty files and objects outside that depth are not counted.

### 9.3 Set form

With one argument:

```text
lang-set <language>
```

`<language>` MUST exactly match an available language directory.

On success the command updates:

```text
lang/current -> <language>
```

The symlink target MUST be relative.

If `lang/current` exists as a non-symlink object, the command MUST refuse to overwrite it.

An unavailable language or an argument count other than zero or one MUST fail without changing an existing valid selection.
