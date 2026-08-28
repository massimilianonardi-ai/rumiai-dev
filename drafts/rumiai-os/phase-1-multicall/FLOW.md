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
semantic roots + PATH + i18n + log.lib

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

Validation checks:

```text
realpath(dirname(RumiAI_INVOKED_BIN))
    == realpath(RumiAI_BIN_DIR)

realpath(RumiAI_BIN_DIR/log)
    == RumiAI_BOOTSTRAP_BIN
```

Then:

```text
RumiAI_COMMAND = log
```

and the same in-process `log "$@"` branch is used.

## 3. Generic public command backed by a private executable

Provisional tree:

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
validate official multicall link
    ↓
RumiAI_COMMAND=foo
    ↓
$RumiAI_COMMAND_DIR/foo arg1 arg2
```

The child receives exported RumiAI semantic environment variables.

If the child is POSIX shell it does not automatically inherit the `log()` shell function. It may either:

```text
source the canonical log library explicitly
```

or use the public process interface:

```text
log info foo event ...
```

The latter resolves `bin/log` through the RumiAI-prepended PATH and therefore re-enters the canonical bootstrap.

## 4. Arbitrary external symlink — rejected by first proposal

Example:

```text
/usr/local/bin/log -> /opt/rumiai/rumiai-os
```

Invocation directory:

```text
/usr/local/bin
```

Canonical RumiAI bin directory:

```text
/opt/rumiai/bin
```

They differ, so the first draft rejects the invocation as an invalid multicall alias.

This is a policy choice, not yet a decision. A later design could permit external aliases by validating that the invoked basename corresponds to an official RumiAI `bin/<name>` entry even when the caller reached it through another symlink.

## 5. Why basename alone is insufficient

If phase 0 keeps only:

```text
RumiAI_INVOKED_AS=log
```

and immediately canonicalizes:

```text
bin/log -> rumiai-os
external/log -> rumiai-os
```

both become indistinguishable after `realpath`.

Therefore the draft preserves the pre-realpath invocation pathname in:

```text
RumiAI_INVOKED_BIN
```

and separately stores the final physical entrypoint in:

```text
RumiAI_BOOTSTRAP_BIN
```

## 6. Status propagation

For in-process `log`:

```text
log returns N
    ↓
rumiai-os exits N
```

For a private external command:

```text
private command exits N
    ↓
rumiai-os exits N
```

Bootstrap/front-controller errors may occur before command execution and therefore share the same external status channel. This is why bootstrap-reserved status values must not collide with command meanings if numeric status alone is expected to identify an exact failure.
