# Handoff — macOS logger pass

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

## Previously passed on physical macOS

- phase 0 after replacing `realpath -e --` with `realpath --` plus explicit validation;
- explicit readable non-executable source without shebang;
- canonical `/tmp -> /private/tmp` path behavior;
- direct executable source using `#!/usr/bin/env rumiai-os`;
- structural runtime exposure through `bin/rumiai-os -> ../rumiai-os`;
- preservation of arguments and status propagation.

## Logger physical test passed

With the product `bin/` directory already in `PATH`:

```text
command -v log
    -> /tmp/rumiai-os-test/bin/log

realpath "$(command -v log)"
    -> /private/tmp/rumiai-os-test/bin/log
```

Valid logger call:

```sh
log info bootstrap language-fallback requested test selected en_US
```

Observed localized Italian output and:

```text
VALID_LOG_STATUS=0
```

Validation statuses observed exactly as designed:

```text
INVALID_SEVERITY_STATUS=12
INVALID_DOMAIN_STATUS=13
INVALID_MESSAGE_ID_STATUS=14
INVALID_FIELDS_STATUS=15
INVALID_LEVEL_STATUS=16
```

Filtered debug event at default `info` level produced no log record and returned:

```text
FILTERED_DEBUG_STATUS=0
```

No partial log record was observed for invalid structured fields.

## Linux utility evidence already recorded

User physically tested Ubuntu 26.04 and reported:

```text
realpath -e   supported
readlink -e   supported
```

The runtime intentionally remains on the smaller demonstrated cross-host contract:

```sh
realpath -- "$pathname"
```

followed by explicit object validation.

## Immediate next physical macOS test

Run the no-argument product entrypoint:

```sh
./rumiai-os
```

and validate:

- interactive Rumi shell starts rather than returning;
- Bash is selected by default;
- Rumi-specific prompt is visible;
- `RumiAI_ROOT`, `RumiAI_BIN_DIR`, `RumiAI_LANGUAGE`, `RumiAI_TEXT_ENCODING` are exported correctly;
- `command -v rumiai-os` and `command -v log` resolve inside the Rumi environment;
- logger works from inside the Rumi shell;
- exit returns cleanly to the host shell.

After the Bash path passes, test the configured POSIX `sh` fallback and remaining phase-0/path/symlink cases before full Ubuntu product validation.
