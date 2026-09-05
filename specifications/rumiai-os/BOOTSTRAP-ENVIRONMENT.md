# RumiAI OS — Bootstrap Runtime Environment

Status: **Normative specification**  
Date: 2026-08-28  
Updated: 2026-09-05

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
m_SRC_DIR=$m_ROOT/src
```

`m_LIB_DIR` is the only RumiAI environment variable exported for the library tree. Runtime-specific library directories are derived from it and do not receive additional environment variables merely as aliases. In particular, variables such as `m_LIB_SH_DIR` or `m_LIB_JS_DIR` are not part of the contract.

`m_SRC_DIR` identifies the ignored local development workspace. It is not a runtime dependency root and does not participate in `PATH`.

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

ext             third-party, platform-independent
ext-<osarch>    third-party, platform-specific
ext-osarch      relative symlink to active ext-<osarch>
```

The canonical `<osarch>` identifier is:

```text
<platform>-<architecture>
```

Current tokens accepted by `osarch-update` are:

```text
platform:     linux | macos | windows
architecture: arm64 | x86_64
```

Examples:

```text
sys-macos-arm64
ext-macos-arm64
sys-linux-x86_64
ext-linux-x86_64
```

Reusable host detection and normalization is implemented by:

```text
lib/sh/osarch.lib.sh
```

Sourcing this library establishes and exports readonly:

```text
m_OSARCH_OS
m_OSARCH_ARCH
m_OSARCH
```

Known host spellings are normalized to the canonical tokens above; an unrecognized value remains available to the consumer as detected data. A consumer that uses the result to create RumiAI-controlled filesystem names must apply the vocabulary/policy appropriate to that operation before using it as a pathname.

The explicit platform-layout updater is:

```text
bin/sys/osarch-update
```

It sources `osarch.lib.sh`, verifies that the detected OS and architecture belong to the updater's supported vocabulary, creates `sys-<osarch>/` and `ext-<osarch>/` when absent, and updates `sys-osarch` and `ext-osarch` as relative symlinks. It does not duplicate native host detection and does not overwrite a non-symlink object occupying either active-link pathname.

Detection and updater failures use the catalog identities:

```text
system.osarch-detection-failure
system.osarch-update-failure
```

These identities exist in every current product language catalog.

`osarch-update` is not invoked automatically by the bootstrap. Any future automatic lifecycle invocation requires a separate decision.

Current implementation reference for this separation and its catalog messages:

```text
massimilianonardi-ai/rumiai-os@9b5ae94c76b13877d65d8f0dfacf6c7b1d1f7dfa
```

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
PATH="$m_BIN_SYS_OSARCH_DIR:$m_BIN_SYS_DIR:$m_BIN_EXT_OSARCH_DIR:$m_BIN_EXT_DIR${PATH:+:$PATH}"
export -- PATH
```

This order is part of the runtime contract.

Libraries, configuration and language data are addressed through their semantic roots and MUST NOT be inserted into `PATH` merely for convenience.

The canonical internal library layout is runtime-qualified:

```text
$m_LIB_DIR/sh/<library-name>.lib.sh
$m_LIB_DIR/js/<library-name>.lib.js
```

The runtime is intentionally represented both by the immediate directory and by the composed file extension. A consumer must load libraries only from the subtree appropriate to its runtime; for example, POSIX shell code sources libraries from `$m_LIB_DIR/sh/`, not from the generic library root or another runtime subtree.

Shell libraries are sourced non-executable files and do not contain a shebang.

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

Platform-independent RumiAI commands such as `log`, `lang`, `lang-set` and `osarch-update` belong under `bin/sys/`.

## 7. Language selection

The bootstrap does NOT read a language preference from `conf/` and does NOT select language from host locale variables.

The selected language is represented by a relative symlink:

```text
lang/current -> <language_TERRITORY>
```

Available language catalogs are ordinary immediate directories under `lang/`, for example:

```text
lang/en_US/
lang/it_IT/
```

Fallback is fixed to:

```text
en_US
```

The explicit selector is:

```text
bin/sys/lang-set
```

With no arguments it reports the effective current language followed by every available language and the number of regular, non-empty canonical message files in that catalog. With one argument it accepts an exact available-language directory name and updates `lang/current` to a relative symlink to that language. More than one argument or an unavailable language is rejected without changing the existing selection.

If `lang/current` does not identify an available language, the effective current language reported by `lang-set` is `m_LANGUAGE_FALLBACK`, matching the resolver fallback behavior.

The selector never infers a language from the host locale.

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

The public command:

```text
bin/sys/lang
```

is a thin wrapper around the bootstrap `lang` function and does not implement a second resolver.

After the language primitive exists, the normal logger may resolve presentation text through `lang` while retaining canonical event identity and structured fields.

Current catalog domains include:

```text
filesystem
execution
security
system
```

The `system` domain currently includes the OS/architecture messages listed above.

Historical catalog domains such as `bootstrap` are not part of the current product catalog unless reintroduced explicitly by a current decision.

## 10. Interactive shell

When `rumiai-os` is invoked with no operands:

```text
SHELL set and non-empty → execute $SHELL
otherwise               → execute sh
```

RumiAI does not automatically prefer Bash and does not use `conf/shell/default` to choose the shell.

The function:

```text
shell [args...]
```

invokes the selected shell and forwards the received arguments. Its startup semantics are fixed by:

```text
decisions/rumiai-os/2026-09-05-interactive-shell-startup.md
```

The primary RumiAI integration target is the supported interactive non-login shell. In its normal startup path the adapter makes the RumiAI environment, interactive RumiAI functions, RumiAI prompt and `m_SHELL_EXT` available.

Current adapter coverage is:

```text
bash
zsh
sh
dash
ash
```

Other shells are executed directly without a RumiAI startup guarantee; no special adapter is maintained for `ksh` or `mksh`.

Login shells retain their native login startup semantics. RumiAI does not emulate login profiles and does not guarantee or force core/`m_SHELL_EXT` loading through that path. Non-interactive shells do not load `m_SHELL_EXT` through the RumiAI startup path. Native options that bypass normal startup files retain their native meaning and are not counteracted by RumiAI.

`m_SHELL_EXT` is the uniform user hook for initializing the supported RumiAI interactive environment independently of the shell.

For `sh`/`dash`/`ash`, the inherited `ENV` value is saved and treated literally; RumiAI does not reinterpret its shell syntax or expansion semantics. After sourcing a readable saved `ENV`, the adapter intentionally executes `\unalias -a` before loading `core.lib.sh` so aliases cannot alter core parsing.

Bash and Zsh instead preserve user aliases while temporarily disabling alias expansion during core loading. The Bash `shopt` operations and the Zsh `[[ -o aliases ]]` / `unsetopt` / `setopt` operations are approved shell-specific exceptions confined to their respective adapters under the exception mechanism in `RULES.md`; generic shell code remains subject to the POSIX contract.

Zsh startup preserves the exact `ZDOTDIR` state, including the distinction between unset, empty and non-empty values. The RumiAI proxy is retained only as required to reach the interactive non-login `.zshrc`; login startup is handed back through `.zprofile`, and no `.zlogin`/`.zlogout` proxy is maintained.

Current implementation reference:

```text
massimilianonardi-ai/rumiai-os@7b645edf1b5d84c512488b3b69d9f1cd8483061f
```

This current shell revision has not yet received a dedicated current physical-validation pass. Historical shell validation remains evidence only for the revisions and contracts actually exercised at the time.

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

## 12. Development workspace

The canonical local development workspace under a `rumiai-os` checkout is:

```text
src/
```

Its operational contents are ignored by Git and do not belong to the runtime product. When present, independent development repositories are conventionally located as:

```text
src/rumiai-tests/
src/rumiai-dev-PoCs/
```

The previous `.dev/` workspace name is superseded.

## 13. Superseded bootstrap mechanisms

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
.dev/ local development workspace
```

Historical documents and validation evidence remain in Git and remain evidence for their exact historical revisions only.

## 14. Current shell validation status

The former open design item for cross-shell loading of RumiAI functions is resolved by:

```text
decisions/rumiai-os/2026-09-05-interactive-shell-startup.md
```

The permanent shell tests under `rumiai-tests/tests/rumiai-os/shell/` predate the current contract and require realignment before they can be treated as protection of this startup model.
