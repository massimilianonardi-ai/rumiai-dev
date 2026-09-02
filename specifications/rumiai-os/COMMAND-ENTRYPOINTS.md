# RumiAI OS — Command Entrypoints

Status: **Normative specification**  
Date: 2026-08-28  
Updated: 2026-09-02

## 1. Scope

RumiAI supports two top-level forms:

```text
rumiai-os
    enter the interactive RumiAI shell

rumiai-os file [args...]
    interpret/source the explicitly supplied file
```

A RumiAI command file that is directly executable by the host uses:

```text
#!/usr/bin/env rumiai-os
```

The command file is its own implementation body. The old multicall + `cmd/` shadow model remains superseded.

## 2. Directly executable command

A directly executed RumiAI command MUST use:

```text
#!/usr/bin/env rumiai-os
```

and satisfy the host's executable-file requirements.

The host profile must support `/usr/bin/env`, executable shebang scripts, PATH-based interpreter resolution and forwarding of the command pathname to `rumiai-os`.

The `#!` convention remains an explicit host-profile extension rather than an abstract POSIX guarantee.

## 3. Explicit source operand

A file invoked through:

```text
rumiai-os file [args...]
```

already names the interpreter and therefore:

- need not contain a shebang;
- need not have the executable bit;
- must resolve to a readable regular file.

The runtime does not require a shebang merely because the same file could also be directly executable.

## 4. Active runtime and portable exposure

For direct execution, `/usr/bin/env` selects `rumiai-os` from the current `PATH`.

Inside an activated/portable RumiAI environment, the canonical runtime is exposed as:

```text
bin/sys/rumiai-os -> ../../rumiai-os
```

and `bin/sys` participates in the RumiAI `PATH` before the inherited host path.

Therefore direct shebang commands can resolve the active portable runtime without mandatory host-global installation and without accidentally preferring another host runtime.

This symlink is not multicall routing.

## 5. Command/source identity

The runtime canonicalizes the supplied source pathname and exposes the successful result as the RumiAI-owned environment variable:

```text
m_COMMAND_BIN
```

`m_COMMAND_BIN` is the absolute physical/canonical pathname of the source file being interpreted.

The command identity is the pathname, not only its basename. Renamed symbolic-link aliases therefore do not require a basename registry.

## 6. Positional arguments

Before sourcing the command body, `rumiai-os` removes the source-file operand from its positional parameters.

The body observes `$@` as the arguments originally supplied after the source pathname.

## 7. Execution model

The current command body contract is POSIX shell sourced in-process after the bootstrap has initialized the RumiAI environment, `lang` and logger.

Example:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

Because the file is sourced in the initialized runtime process, it can directly call RumiAI shell functions already present in that process.

A command body may delegate to another approved runtime when the future capability/profile contract permits it.

## 8. Root semantics

The RumiAI root is derived from the physical active `rumiai-os` interpreter, not from the command-file pathname.

A command file physically located elsewhere is interpreted inside the active runtime selected by the invocation environment.

## 9. Symbolic links and aliases

A command file may be reached through a symbolic link with a different basename. The runtime canonicalizes the source operand before execution, so the external alias name does not define implementation identity.

## 10. No-argument shell behavior

When `rumiai-os` receives no operands, it launches:

```text
$SHELL if set and non-empty
sh otherwise
```

The previous Bash-preferred / `conf/shell/default` selection policy is superseded.

The RumiAI shell must inherit the RumiAI environment and ultimately expose the intended RumiAI functions. The portable cross-shell function-loading mechanism remains a separate open design item.

## 11. Superseded environment names

References in older command-entry documents to:

```text
RumiAI_ROOT
RumiAI_BOOTSTRAP_BIN
RumiAI_COMMAND_BIN
```

are superseded by the current environment-variable namespace, including:

```text
m_ROOT
m_BOOTSTRAP_BIN
m_COMMAND_BIN
```

## 12. Failure handling

Failure to resolve or validate a source file MUST prevent sourcing.

After logger activation, command-entry failures SHOULD use the normal logger. Numeric external status consolidation remains a separate contract unless explicitly fixed by a current specification.

## 13. Security boundary

Sourcing a RumiAI command executes trusted code with the privileges and environment of the current RumiAI process. This mechanism is not a sandbox.
