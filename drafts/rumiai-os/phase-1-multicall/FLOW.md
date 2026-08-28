# Multicall draft flows

Status: **draft / non-normative**  
Date: 2026-08-28

## 1. Direct front-controller command

Invocation:

```text
rumiai-os log warn bootstrap language-fallback requested xx_YY selected en_US
```

State transition:

```text
$0 = .../rumiai-os
RumiAI_INVOKED_AS = rumiai-os
RumiAI_INVOKED_BIN = invocation pathname

phase 0
    ↓
RumiAI_BOOTSTRAP_BIN = physical .../rumiai-os
RumiAI_ROOT

phase 1
    ↓
semantic roots
PATH
bootstrap preference reader
i18n normalization/selection
log.lib
LOGGER ACTIVE

normal command selection
    ↓
RumiAI_COMMAND = first operand = log
shift

hybrid dispatch
    ↓
call shell function log "$@"
```

No second logger process is created.

## 2. Official multicall command

Tree:

```text
bin/log -> ../rumiai-os
```

Invocation:

```text
log warn bootstrap language-fallback requested xx_YY selected en_US
```

Possible pre-realpath state:

```text
$0 = /opt/rumiai/bin/log
RumiAI_INVOKED_AS = log
RumiAI_INVOKED_BIN = /opt/rumiai/bin/log
```

After phase 0:

```text
RumiAI_BOOTSTRAP_BIN = /opt/rumiai/rumiai-os
RumiAI_ROOT = /opt/rumiai
```

Registration/target validation:

```text
realpath(RumiAI_BIN_DIR/log)
    == RumiAI_BOOTSTRAP_BIN
```

Then:

```text
RumiAI_COMMAND = log
```

and the same in-process `log "$@"` branch is used.

## 3. Generic public command backed by a private executable

Accepted tree shape:

```text
bin/foo -> ../rumiai-os
cmd/foo
```

Invocation:

```text
foo arg1 arg2
```

Flow:

```text
bin/foo
    ↓
rumiai-os
    ↓
full bootstrap
    ↓
validate official public command registration
    ↓
RumiAI_COMMAND=foo
    ↓
$RumiAI_COMMAND_DIR/foo arg1 arg2
```

`RumiAI_COMMAND_DIR` is:

```text
$RumiAI_ROOT/cmd
```

and is intentionally outside `PATH`.

The child receives exported RumiAI semantic environment variables.

A child POSIX shell does not automatically inherit the `log()` shell function. It may explicitly source `lib/log.lib` or use the public process command `log`, which re-enters the canonical front controller through `bin/log`.

## 4. External symlink alias — accepted when registered

Example absolute target:

```text
/usr/local/bin/log -> /opt/rumiai/rumiai-os
```

Example relative target:

```text
/usr/local/bin/log -> ../../opt/rumiai/rumiai-os
```

In either case `realpath -e` canonicalizes the invoked path to:

```text
/opt/rumiai/rumiai-os
```

so phase 0 derives:

```text
RumiAI_BOOTSTRAP_BIN=/opt/rumiai/rumiai-os
RumiAI_ROOT=/opt/rumiai
```

The directory `/usr/local/bin` does not become part of the RumiAI root.

The alias basename `log` is accepted only if the actual installation also contains an official registration:

```text
$RumiAI_BIN_DIR/log
```

whose canonical target is the same `RumiAI_BOOTSTRAP_BIN`.

Therefore external placement is allowed, but arbitrary names are not.

## 5. Arbitrary external alias — rejected

Example:

```text
/usr/local/bin/log-copy -> /opt/rumiai/rumiai-os
```

If the installation has no official:

```text
/opt/rumiai/bin/log-copy
```

resolving to the same front controller, the invocation fails as `invalid-multicall`.

This makes `bin/` the registry of valid public multicall command names even when aliases are installed elsewhere.

## 6. External symlink named `rumiai-os`

Example:

```text
/usr/local/bin/rumiai-os -> /opt/rumiai/rumiai-os
```

Because the invoked basename equals the physical front-controller basename, this is treated as the normal front-controller form:

```text
rumiai-os <command> ...
```

The first operand selects the command.

## 7. Why invocation identity is preserved

The draft keeps:

```text
RumiAI_INVOKED_AS
RumiAI_INVOKED_BIN
```

before canonicalization and separately stores:

```text
RumiAI_BOOTSTRAP_BIN
```

after physical canonicalization.

`RumiAI_INVOKED_AS` is required for multicall command selection. `RumiAI_INVOKED_BIN` is the path actually canonicalized by phase 0 and remains useful for diagnostics/review of how the entrypoint was reached.

## 8. Bootstrap preference flow

The integrated draft now performs the actual bootstrap sequence:

```text
conf/bootstrap/language
    ↓ if absent
LC_ALL
    ↓
LC_MESSAGES
    ↓
LANG
    ↓
en_US

conf/bootstrap/text-encoding
    ↓ if absent/invalid/unsupported
UTF-8
```

The raw requests are passed to the i18n library, which normalizes/selects the effective values. Non-fatal fallback conditions are remembered until `log.lib` is loaded and are then reported through the logger.

## 9. Shared status sequence

Current shared front-controller statuses:

```text
1  PATH resolution failure
2  canonical realpath failure
3  invalid bootstrap binary
4  invalid/inaccessible root
5  i18n load failure
6  log load failure
7  invalid multicall
8  invalid command
9  private command unavailable
```

The remaining question is the final mapping between command-local/library return statuses and external CLI exit statuses. They must not collide with the shared front-controller meanings if a numeric CLI status is required to identify one exact failure.
