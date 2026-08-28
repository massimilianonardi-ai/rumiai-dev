# Handoff — macOS i18n and bootstrap configuration pass

Date: 2026-08-28
Status: **physical macOS validation in progress**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Current tested product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

## Physical macOS i18n/configuration matrix — PASS

The bootstrap language and text-encoding selection paths were exercised on the physical macOS host with a diagnostic explicit source that printed:

```text
RumiAI_LANGUAGE
RumiAI_TEXT_ENCODING
```

and returned status `0`.

### Language precedence

Observed precedence behavior:

```text
LC_ALL=it_IT.UTF-8, LC_MESSAGES=en_US.UTF-8, LANG=en_US.UTF-8 -> it_IT
LC_ALL empty, LC_MESSAGES=en_US.UTF-8, LANG=it_IT.UTF-8      -> en_US
LC_ALL empty, LC_MESSAGES empty, LANG=it_IT.UTF-8            -> it_IT
LC_ALL=C                                                     -> en_US
```

This confirms the intended environment precedence:

```text
LC_ALL > LC_MESSAGES > LANG > en_US fallback
```

### Unsupported locale fallback

With:

```text
LC_ALL=fr_FR.UTF-8
```

RumiAI selected:

```text
LANGUAGE=en_US
ENCODING=UTF-8
STATUS=0
```

and emitted the expected English fallback warning because the selected catalog language had already fallen back to `en_US`.

### Bootstrap language configuration precedence

A valid bootstrap configuration:

```text
conf/bootstrap/language = it_IT
```

overrode an `en_US` environment and selected `it_IT`, confirming:

```text
bootstrap config > LC_ALL > LC_MESSAGES > LANG > fallback
```

An unsupported configured language:

```text
fr_FR
```

fell back to `en_US` with the expected warning.

A malformed language configuration containing multiple physical lines was rejected, emitted `bootstrap.language-config-invalid`, then correctly continued using the environment language (`it_IT`).

### Text encoding

Configured:

```text
utf8
```

normalized to:

```text
UTF-8
```

Configured unsupported encoding:

```text
ASCII
```

fell back to `UTF-8` and emitted the expected localized `bootstrap.text-encoding-fallback` warning.

A malformed multi-line text-encoding configuration was rejected, emitted `bootstrap.text-encoding-config-invalid`, and continued with `UTF-8`.

### Localization behavior

Warnings were rendered in the currently selected catalog language as expected:

- unsupported `fr_FR` fell back to English catalog messages;
- malformed configuration while `it_IT` was selected produced Italian messages;
- unsupported text encoding while `it_IT` was selected produced Italian messages.

### Cleanup

Temporary `conf/bootstrap` test data was removed after the test.

Observed final repository state:

```text
git status --short -> empty
```

No product change was required.

## macOS validation passed so far

- native `realpath --` compatibility and product fix;
- explicit source execution and exact status propagation;
- direct `#!/usr/bin/env rumiai-os` execution;
- structural runtime exposure;
- logger and validation statuses;
- Bash and POSIX sh Rumi shells;
- runtime pathname/symlink/spaces matrix;
- relative PATH from arbitrary CWD;
- source pathname/spaces/symlink canonicalization;
- language precedence, normalization and fallback;
- bootstrap language configuration precedence and malformed-config handling;
- text-encoding normalization, fallback and malformed-config handling.

## Ubuntu 26.04 evidence

The user physically reported:

```text
realpath -e   supported
readlink -e   supported
```

Full product execution on Ubuntu/Linux remains pending.

## Immediate next macOS work

Run the final sourced-command lifecycle group before moving the full matrix to Ubuntu/Linux:

1. explicit `return` status propagation;
2. natural fall-through status propagation;
3. explicit `exit` from a sourced command;
4. basic signal termination behavior.
