# Handoff — macOS direct shebang pass

Date: 2026-08-28
Status: **physical macOS validation in progress**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Tested product commit:

```text
c245cff5d1bec949f72be9f8b41c77789978342b
```

This is the macOS-compatible product using:

```sh
command -p -- realpath -- "$pathname"
```

plus explicit object validation.

## macOS explicit-source test

Already passed with a readable non-executable source without shebang:

```text
SOURCE_OK
ROOT=/private/tmp/rumiai-os-test
COMMAND=/private/tmp/rumiai-source-test
ARG1=hello world
ARG2=second
STATUS=23
```

## macOS direct shebang test — PASS

Caller PATH was extended with:

```text
/private/tmp/rumiai-os-test/bin
```

The shell reported:

```text
RUNTIME_IN_PATH=/tmp/rumiai-os-test/bin/rumiai-os
RUNTIME_REAL=/private/tmp/rumiai-os-test/rumiai-os
```

A directly executable file using:

```text
#!/usr/bin/env rumiai-os
```

was invoked with two user arguments.

Observed result:

```text
DIRECT_OK
ROOT=/private/tmp/rumiai-os-test
COMMAND=/private/tmp/rumiai-direct-test
ARG1=hello direct
ARG2=second
STATUS=24
```

Physically confirmed on macOS:

- `/usr/bin/env` resolves `rumiai-os` through PATH;
- `bin/rumiai-os -> ../rumiai-os` is a valid structural runtime exposure;
- the host passes the direct script pathname to `rumiai-os` as required;
- runtime and source are physically canonicalized;
- original arguments survive interpreter handoff;
- source return status propagates unchanged.

## Ubuntu 26.04 evidence

The user physically verified on Ubuntu 26.04 that:

```text
realpath -e   supported
readlink -e   supported
```

This is host capability evidence only. The product remains on `realpath --` plus explicit validation as the smaller demonstrated cross-host contract.

## Next macOS tests

1. direct `bin/log` / `log` invocation and logger status contract;
2. `rumiai-os` with no operands enters the Rumi shell;
3. Bash selection and prompt/configuration;
4. `command -v rumiai-os` and `command -v log` inside the Rumi shell;
5. phase-0 relative/absolute/PATH/symlink/path-space edge cases;
6. then full Ubuntu/Linux product validation.
