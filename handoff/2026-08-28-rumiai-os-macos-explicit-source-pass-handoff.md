# Handoff — macOS explicit-source pass

Date: 2026-08-28
Status: **physical macOS validation in progress**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Current tested product commit:

```text
c245cff5d1bec949f72be9f8b41c77789978342b
```

This commit replaced `realpath -e --` with the cross-host form:

```sh
command -p -- realpath -- "$pathname"
```

followed by explicit RumiAI validation of the resolved object.

## Physical macOS explicit-source test passed

Command:

```sh
./rumiai-os /tmp/rumiai-source-test 'hello world' second
printf 'STATUS=%s\n' "$?"
```

The source file was mode `0644`, contained no shebang, and returned `23`.

Observed result:

```text
SOURCE_OK
ROOT=/private/tmp/rumiai-os-test
COMMAND=/private/tmp/rumiai-source-test
ARG1=hello world
ARG2=second
STATUS=23
```

Confirmed properties:

- phase 0 succeeds on physical macOS after the realpath compatibility fix;
- `/tmp` canonicalizes to `/private/tmp`, as expected on this host;
- explicit `rumiai-os file` does not require a shebang;
- explicit source does not require executable permission;
- source positional arguments are preserved;
- `RumiAI_COMMAND_BIN` is physical/canonical;
- source return status propagates unchanged.

## Ubuntu 26.04 utility capability evidence

The user also physically tested Ubuntu 26.04 and reported:

```text
realpath -e   supported
readlink -e   supported
```

This evidence is recorded in:

```text
drafts/rumiai-os/phase-1-command-interpreter/VALIDATION.md
```

The product remains intentionally on `realpath --` plus explicit validation because this is the smaller common contract demonstrated so far across macOS and Linux utility behavior.

## Next macOS test

Validate direct host execution through:

```text
#!/usr/bin/env rumiai-os
```

using the structural runtime exposure:

```text
bin/rumiai-os -> ../rumiai-os
```

After direct shebang execution passes, continue with:

1. `bin/log` and logger statuses;
2. no-argument interactive Rumi shell;
3. PATH/runtime exposure inside the Rumi shell;
4. remaining phase-0/symlink/path edge cases;
5. then full Linux product validation.
