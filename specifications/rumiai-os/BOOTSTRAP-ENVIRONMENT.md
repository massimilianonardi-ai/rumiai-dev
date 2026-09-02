# RumiAI OS — Bootstrap Runtime Environment

Status: **Normative specification**  
Date: 2026-08-28  
Updated: 2026-09-02

## 1. Scope

This specification defines the runtime environment established by the root `rumiai-os` bootstrap after successful root discovery.

It describes the current contract fixed after the bootstrap optimization cycle. The behavioral reference at the time of consolidation is:

```text
massimilianonardi-ai/rumiai-os@77051580f489b9243b45145e9791f2cf4ace90ed
```

The product may receive light implementation optimizations without reopening these semantics. A behavior change requires a new explicit decision.

## 2. Environment-variable namespace

Every RumiAI-owned environment variable uses:

```text
m_*
```

This rule is limited to environment variables and MUST NOT be generalized to functions, local variables, commands, APIs or filesystem names without a separate decision.

Standard environment variables keep their standard spelling.

## 3. Fundamental exported state

Phase 0 establishes:

```text
m_BOOTSTRAP_BIN
m_ROOT
```

Current Phase-1 semantic roots include:

```text
m_BIN_DIR=$m_ROOT/bin
m_BIN_SYS_DIR=$m_BIN_DIR/sys
m_BIN_SYS_OSARCH_DIR=$m_BIN_DIR/sys-osarch
m_BIN_EXT_DIR=$m_BIN_DIR/ext
m_BIN_EXT_OSARCH_DIR=$m_BIN_DIR/ext-osarch
m_LIB_DIR=$m_ROOT/lib
m_CONF_DIR=$m_ROOT/conf
m_LANG_DIR=$m_ROOT/lang
```

Language/encoding state includes:

```text
m_LANGUAGE_FALLBACK=en_US
m_TEXT_ENCODING=UTF-8
m_LANG_CURRENT_DIR=$m_LANG_DIR/current
m_LANG_FALLBACK_DIR=$m_LANG_DIR/en_US
```

The current logger level variable is:

```text
m_LOG_LEVEL
```

When a command/source file is being interpreted, the canonical pathname is exported as:

```text
m_COMMAND_BIN
```

Variables whose value must not change after bootstrap initialization SHOULD be readonly in the bootstrap shell.

## 4. Executable-directory model

`bin/` is a container. It is NOT itself added to `PATH`.

Canonical layout:

```text
bin/
├── sys/
├── sys-<osarch>/
├── sys-osarch -> sys-<osarch>
├── ext/
├── ext-<osarch>/
└── ext-osarch -> ext-<osarch>
```

Roles:

```text
sys             RumiAI executables/symlinks, platform-independent
sys-<osarch>    RumiAI executables/symlinks, platform-specific
sys-osarch      relative symlink to active sys-<osarch>

ext             third-party executables/symlinks, platform-independent
ext-<osarch>    third-party executables/symlinks, platform-specific
ext-osarch      relative symlink to active ext-<osarch>
```

Example platform directory:

```text
sys-macos-arm64
ext-macos-arm64
```

The exact `<osarch>` detection/update utility and its invocation policy are not yet specified.

## 5. PATH initialization

Exact precedence:

```text
$m_BIN_SYS_OSARCH_DIR
$m_BIN_SYS_DIR
$m_BIN_EXT_OSARCH_DIR
$m_BIN_EXT_DIR
inherited host PATH
```

Conceptual form:

```sh
PATH=$m_BIN_SYS_OSARCH_DIR:$m_BIN_SYS_DIR:$m_BIN_EXT_OSARCH_DIR:$m_BIN_EXT_DIR${PATH:+:$PATH}
export -- PATH
```

This order is part of the runtime contract.

Libraries, configuration and language data are addressed through their semantic roots and MUST NOT be inserted into `PATH` merely for convenience.

## 6. Internal runtime exposure

The portable/activated environment exposes the physical root bootstrap as:

```text
bin/sys/rumiai-os -> ../../rumiai-os
```

The symlink target MUST be relative so moving the entire RumiAI root preserves the relationship.

This entry exists so that direct command files using:

```text
#!/usr/bin/env rumiai-os
```

can resolve the active portable runtime through the RumiAI `PATH`, even when no host-global `rumiai-os` is installed.

It is not a multicall mechanism and carries no command routing semantics.

No RumiAI-managed entry named `rumiai-os` in a higher-precedence directory may accidentally shadow this canonical runtime exposure.

## 7. Language selection

The bootstrap does NOT read a language preference from `conf/` and does NOT select language from host locale variables.

The selected language is represented by a relative symlink:

```text
lang/current -> <language_TERRITORY>
```

Available language catalogs are ordinary directories under `lang/`, for example:

```text
lang/en_US/
lang/it_IT/
```

Fallback is fixed to:

```text
en_US
```

The utility that presents available languages and updates `lang/current` remains to be specified.

## 8. Text encoding

The runtime text encoding currently supported and selected is fixed:

```text
UTF-8
```

There is no bootstrap `text-encoding` preference file and no bootstrap encoding negotiation/fallback algorithm.

## 9. `lang` and logger boundary

The bootstrap language resolver/API is named:

```text
lang
```

`i18n` is superseded terminology and is not retained as an alias by default.

After the language primitive exists, the normal logger may resolve presentation text through `lang` while retaining canonical event identity and structured fields.

## 10. Interactive shell

When `rumiai-os` is invoked with no operands:

```text
SHELL set and non-empty → execute $SHELL
otherwise               → execute sh
```

RumiAI does not automatically prefer Bash and does not use `conf/shell/default` to choose the shell.

The launched interactive RumiAI shell must receive the RumiAI environment and must ultimately have access to the RumiAI functions intended for interactive use.

Environment variables are inherited normally. The cross-shell function-loading mechanism remains to be specified separately.

## 11. Command/source entry

When operands are present, the first operand identifies a command/source file. After successful canonicalization and validation, its pathname is exported as:

```text
m_COMMAND_BIN
```

The source pathname is removed from positional parameters and the file is sourced in the already initialized bootstrap shell.

Directly executable RumiAI command files retain:

```text
#!/usr/bin/env rumiai-os
```

## 12. Superseded bootstrap mechanisms

The following are no longer part of the current bootstrap contract:

```text
RumiAI_* environment-variable namespace
bin/ itself prepended to PATH
cmd/ command shadow root
bootstrap language preference file
host LC_ALL / LC_MESSAGES / LANG language selection
bootstrap text-encoding preference file
configurable bootstrap text encoding
bootstrap API name i18n
automatic Bash preference
conf/shell/default shell selection
multicall command routing
```

Historical documents and validation evidence remain in Git and remain evidence for their exact historical revisions only.

## 13. Open design items

Not yet fixed:

1. `<osarch>` detection and `sys-osarch` / `ext-osarch` link updater;
2. when that updater runs;
3. language-selection utility for `lang/current`;
4. cross-shell loading of RumiAI functions.

These items must be solved without contradicting the fixed behavior above.
