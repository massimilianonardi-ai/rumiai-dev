# Handoff — RumiAI OS phase 1 product promotion

Date: 2026-08-28
Status: **product promoted; physical host validation next**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product authorization and promotion

The user explicitly authorized publication of the cleaned/consolidated code proposal to:

```text
massimilianonardi-ai/rumiai-os
```

Product commit:

```text
b8f7566989470be6a5cc0b1a1347f60d46d93d77
```

Commit message:

```text
Promote phase 1 bootstrap shell and command interpreter
```

Parent:

```text
eff2e96a70c576b1b5dbdb811d74833e9765ddb3
```

The product is now the implementation target for physical macOS/Linux tests.

## Current product layout

```text
rumiai-os
README.md
bin/
    log
    rumiai-os -> ../rumiai-os
lib/
    i18n.lib
    log.lib
    shell.lib
conf/
    shell/
        default
        bashrc
        shrc
lang/
    en_US/
        bootstrap/
        shell/
    it_IT/
        bootstrap/
        shell/
```

Git modes were explicitly preserved/created:

```text
rumiai-os      100755
bin/log        100755
bin/rumiai-os  120000 symbolic link
```

## Current CLI

```text
rumiai-os
```

Bootstraps RumiAI and enters the configured interactive Rumi shell.

Default shell selection:

```text
bash
```

Fallback:

```text
POSIX sh
```

Configuration:

```text
conf/shell/default
conf/shell/bashrc
conf/shell/shrc
```

The supplied default prompt makes the environment visibly recognizable as RumiAI.

Explicit source invocation:

```text
rumiai-os file [args...]
```

The source:

- is canonicalized with `realpath -e`;
- must be a readable regular file;
- does not require executable permission;
- does not require a shebang;
- is sourced in the initialized runtime shell;
- receives the remaining positional arguments;
- exposes canonical `RumiAI_COMMAND_BIN`;
- propagates its final status.

Directly executable RumiAI source files may use:

```text
#!/usr/bin/env rumiai-os
```

The shebang is a host execution mechanism only.

## Runtime exposure

Portable environment exposure is implemented by the structural symlink:

```text
bin/rumiai-os -> ../rumiai-os
```

Phase 1 prepends `RumiAI_BIN_DIR` to `PATH`, so after entering the portable Rumi shell, `/usr/bin/env rumiai-os` resolves without modifying the host.

Optional host-global integration via a separate external symlink remains a later installation/integration task and was not implemented in this promotion.

## Library loading cleanup

The promoted bootstrap uses:

```sh
if ! . "$library"
then
    ...
fi
```

for `i18n.lib`, `log.lib`, and lazily loaded `shell.lib`.

Temporary `RumiAI_load_status` state was removed where only success/failure matters.

Predictable `-f/-r` validation remains before sourcing libraries.

## Logger cleanup

Structured fields are fully validated before output begins, preventing partial log records on invalid fields.

Promoted public logger statuses:

```text
11 invalid argument count
12 invalid severity
13 invalid domain
14 invalid message-id
15 invalid structured fields
16 invalid log level
```

Shared runtime statuses:

```text
1  bootstrap PATH resolution failure
2  bootstrap realpath failure
3  invalid bootstrap binary
4  invalid/inaccessible RumiAI root
5  i18n library load failure
6  log library load failure
7  shell library load failure
8  explicit source resolution failure
9  invalid explicit source entry
10 shell launch failure
```

## Local pre-promotion validation

Syntax passed under:

```text
dash
bash --posix
busybox sh
```

for:

```text
rumiai-os
lib/i18n.lib
lib/log.lib
lib/shell.lib
```

Runtime checks passed locally for:

- explicit source execution under all three shells;
- source arguments and canonical environment variables;
- propagation of source status `23`;
- direct `#!/usr/bin/env rumiai-os` execution with runtime in PATH;
- distinct logger validation statuses `12..16`;
- no partial logger output on invalid fields.

These checks are recorded in:

```text
drafts/rumiai-os/phase-1-command-interpreter/VALIDATION.md
```

## Physical validation next

The next phase is physical testing of the actual promoted `rumiai-os` repository on macOS and Linux.

Minimum matrix:

### Phase 0

- direct relative invocation;
- direct absolute invocation;
- PATH invocation;
- relative symlink;
- absolute symlink;
- symlink chain/intermediate component;
- spaces in external pathname;
- canonical `RumiAI_BOOTSTRAP_BIN` and `RumiAI_ROOT`.

### Rumi shell

- `rumiai-os` enters shell rather than exiting;
- Bash selected when available;
- POSIX sh fallback when Bash is unavailable/disabled;
- `conf/shell/default` behavior;
- Bash and sh Rumi-specific rc files;
- recognizable prompt;
- `bin/` prepended to PATH;
- `command -v rumiai-os` resolves inside the Rumi shell through `bin/rumiai-os`.

### Command interpreter

- `rumiai-os source` with no shebang and no executable bit;
- arguments preserved;
- status propagation;
- direct executable source using `#!/usr/bin/env rumiai-os`;
- renamed symlink to a command file;
- duplicate basenames in distinct paths;
- paths containing spaces.

### i18n/logger

- host locale normalization;
- `it_IT` catalog;
- `en_US` fallback;
- UTF-8 default/fallback;
- log levels and filtering;
- structured fields/escaping;
- exact logger error statuses.

## Important current boundary

The code has been promoted for physical validation, not declared cross-host certified.

Do not redesign the command-entry architecture during the test phase unless physical evidence reveals a concrete defect.
