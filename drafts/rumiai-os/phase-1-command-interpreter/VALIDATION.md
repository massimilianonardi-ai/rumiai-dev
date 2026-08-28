# Command-interpreter local validation

Date: 2026-08-28
Status: **local validation complete; reference-host certification pending**

The consolidated candidate was checked before promotion to `rumiai-os`.

## Syntax

The current candidate sources passed syntax checking under:

```text
dash
bash --posix
busybox sh
```

Checked files:

```text
rumiai-os
lib/i18n.lib
lib/log.lib
lib/shell.lib
```

## Explicit source invocation

For a readable, non-executable source file returning status `23`:

```text
rumiai-os source-test value
```

all three reference local shells produced:

```text
status = 23
source argument preserved
RumiAI_ROOT correct
RumiAI_COMMAND_BIN canonical and correct
```

This validates the intended distinction between source interpretation and direct host execution: no shebang or executable bit is required for `rumiai-os file`.

## Direct shebang execution

With the runtime exposed in `PATH` through the RumiAI `bin/` directory, an executable file beginning with:

```text
#!/usr/bin/env rumiai-os
```

was executed successfully and observed the expected original user arguments and RumiAI environment.

## Logger status contract

The cleaned logger candidate was exercised for the distinct validation failures:

```text
invalid severity    -> 12
invalid domain      -> 13
invalid message-id  -> 14
invalid fields      -> 15
invalid log level   -> 16
```

Invalid structured fields are now detected before any log record is emitted, so validation failure does not leave a partial stderr line.

## Previously validated command-entry properties

Local earlier checks also confirmed:

- renamed symlink aliases to command files;
- duplicate basenames in distinct directories;
- active runtime selection by `PATH`;
- sourcing command files whose first line is `#!/usr/bin/env rumiai-os` under `dash`, `bash --posix` and BusyBox `sh`.

## Important limitation

This remains local/ad hoc evidence, not physical reference-host certification.

The next validation gate is execution of the promoted product tree on actual:

```text
macOS
Linux
```

with Cygwin/reference Windows validation to follow when that host profile is addressed.

Physical tests should cover at minimum:

- phase-0 relative/absolute/PATH/symlink cases;
- `/usr/bin/env rumiai-os` behavior;
- portable Rumi shell startup;
- Bash selection and POSIX sh fallback;
- custom Rumi prompt/configuration;
- `bin/rumiai-os` structural symlink;
- `bin/log` direct invocation;
- explicit source without shebang/executable bit;
- language selection and English fallback;
- logger filtering, fields and exact statuses;
- spaces and symbolic links in relevant paths;
- status propagation;
- basic signal/exit behavior of sourced commands.
