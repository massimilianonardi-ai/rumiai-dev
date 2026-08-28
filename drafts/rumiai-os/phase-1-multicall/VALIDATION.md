# Multicall draft local validation

Date: 2026-08-28
Status: **ad hoc local validation, not formal PoC certification**

The current code proposal was exercised locally under:

```text
dash
bash --posix
busybox sh
```

The temporary test tree used the accepted conceptual shape:

```text
rumiai-os
bin/log -> ../rumiai-os
bin/foo -> ../rumiai-os
cmd/foo
lib/i18n.lib
lib/log.lib
conf/bootstrap/language
conf/bootstrap/text-encoding
lang/en_US/...
lang/it_IT/...
```

## Successful forms

All three shells successfully exercised:

```text
rumiai-os log ...
bin/log ...
bin/foo ...
```

The private `cmd/foo` process received the expected exported environment including:

```text
RumiAI_ROOT
RumiAI_COMMAND=foo
```

## External alias tests

An external directory outside the RumiAI root was created with aliases resolving to the canonical front controller.

Relative alias with registered basename:

```text
external/log -> ../rumiai-install/rumiai-os
```

Result:

```text
accepted
RumiAI_COMMAND=log
RumiAI_ROOT remained the physical RumiAI installation root
status 0 for valid log call
```

Absolute alias with registered basename:

```text
external/foo -> /physical/rumiai-install/rumiai-os
```

Result:

```text
accepted
RumiAI_COMMAND=foo
private cmd/foo invoked
RumiAI_ROOT remained the physical RumiAI installation root
status 0
```

External front-controller alias:

```text
external/rumiai-os -> /physical/rumiai-install/rumiai-os
```

Result:

```text
accepted as normal front-controller form
first operand selected the command
```

External alias with unregistered basename:

```text
external/log-abs -> /physical/rumiai-install/rumiai-os
```

with no matching official `bin/log-abs` registration.

Result on all three shells:

```text
bootstrap.invalid-multicall
status 7
```

## Bootstrap preference integration

The integrated draft also exercised real one-line files:

```text
conf/bootstrap/language      = it_IT
conf/bootstrap/text-encoding = UTF-8
```

The effective values were selected through `i18n.lib`, and logging used the Italian catalog.

The draft no longer depends on the former hardcoded `RumiAI_LANGUAGE` / `RumiAI_TEXT_ENCODING` integration shortcut.

## Limits

This validation is not reference-host certification and does not yet establish:

- final multicall product implementation;
- behavior on every target host/filesystem;
- final command-local-to-CLI error-status mapping;
- final `exec` versus child-process dispatch policy;
- final advanced transcoding behavior.
