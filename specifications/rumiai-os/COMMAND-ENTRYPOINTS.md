# RumiAI OS — Command Entrypoints

Status: **Normative specification**  
Date: 2026-08-28

## 1. Scope

This specification defines the initial command/source-entry model used after the RumiAI bootstrap environment has been established.

RumiAI supports two distinct forms:

```text
rumiai-os
    enter the interactive Rumi shell

rumiai-os file [args...]
    interpret/source the explicitly supplied file
```

A file that should additionally be executable directly by the host uses:

```text
#!/usr/bin/env rumiai-os
```

This specification supersedes the earlier multicall/symlink + `cmd/` shadow proposal.

## 2. Executable command versus explicit source

The distinction is normative.

### Directly executable RumiAI command

A file invoked directly by the host, for example:

```text
./foo arg1 arg2
```

MUST use the canonical RumiAI interpreter declaration:

```text
#!/usr/bin/env rumiai-os
```

and MUST satisfy the host's normal executable-file requirements.

### Source explicitly passed to RumiAI

A file invoked as:

```text
rumiai-os foo arg1 arg2
```

is already being explicitly supplied to the RumiAI interpreter.

It therefore:

- MUST NOT be required to contain a shebang;
- MUST NOT be required to have the executable permission bit;
- MUST resolve to a readable regular file.

The shebang is a host direct-execution mechanism, not part of the RumiAI source-language validity contract.

## 3. Command/source file identity

The file itself is the implementation body.

There is no mandatory second implementation file and no mandatory command shadow tree.

A directly executable command may live in any semantically appropriate executable-command directory.

Examples:

```text
bin/log
package-a/bin/foo
package-b/bin/foo
```

Two directly executable commands may have the same basename when their pathnames differ:

```text
package-a/bin/foo
package-b/bin/foo
```

When a file reaches `rumiai-os`, the runtime preserves and canonicalizes the supplied pathname rather than reducing identity to the basename.

## 4. Interpreter selection for direct execution

A directly executed RumiAI command file MUST begin with:

```text
#!/usr/bin/env rumiai-os
```

The host environment MUST provide:

```text
/usr/bin/env
```

and `rumiai-os` MUST be resolvable through the inherited `PATH`.

The `rumiai-os` selected from `PATH` is the active RumiAI runtime for that direct invocation.

This is intentional. The command file does not pin itself to a colocated RumiAI installation.

Explicit invocation through:

```text
rumiai-os file
```

already names the interpreter and therefore does not depend on the source file containing a shebang.

## 5. Host-profile requirement

The `#!` convention and the exact `/usr/bin/env` pathname are not guaranteed by POSIX.1-2024.

RumiAI therefore adds the following explicit host-profile requirements for direct executable command files:

1. executable scripts with `#!` are supported;
2. `/usr/bin/env` exists and is executable;
3. `#!/usr/bin/env rumiai-os` causes `env` to resolve `rumiai-os` through `PATH`;
4. the command-file pathname is passed to `rumiai-os` as its first source operand;
5. after bootstrap, the reference `/bin/sh` implementations can source a directly executable RumiAI command file with the initial `#!` line treated compatibly with the chosen profile.

These requirements MUST be verified on each reference host before host certification and before stable product promotion.

They do not apply to the existence of a shebang in a file explicitly passed through `rumiai-os file`.

## 6. Bootstrap/runtime separation

`rumiai-os` remains responsible for establishing the RumiAI runtime environment.

Direct executable flow:

```text
command file
    ↓ #!/usr/bin/env rumiai-os
active rumiai-os from PATH
    ↓
phase 0: resolve physical RumiAI runtime root
    ↓
phase 1: semantic roots + bootstrap preferences + i18n + logger
    ↓
canonicalize command-file pathname
    ↓
source command file
    ↓
propagate command status
```

Explicit source flow:

```text
rumiai-os file args...
    ↓
phase 0
    ↓
phase 1 + i18n + logger
    ↓
canonicalize file
    ↓
source file
    ↓
propagate source status
```

The root of the RumiAI runtime is derived from the physical `rumiai-os` interpreter, not from the source-file pathname.

## 7. Command/source body

The initial body contract is POSIX shell code sourced by `rumiai-os` after bootstrap.

Directly executable example:

```sh
#!/usr/bin/env rumiai-os

log info example started
```

Explicit-source-only example:

```sh
log info example started
```

Both may be interpreted by:

```text
rumiai-os file
```

Because the body is sourced into the initialized bootstrap shell, it has direct access to sourced RumiAI libraries and exported environment state.

For example:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

uses the already loaded `log()` shell function and does not recursively invoke the public `log` command.

A body that delegates to another runtime MAY use POSIX shell as a thin adapter, for example conceptually:

```sh
#!/usr/bin/env rumiai-os
exec some-runtime ...
```

The exact language/runtime capability model is outside this initial specification.

## 8. Positional arguments

When `rumiai-os` interprets a source file, the first operand identifies that file.

Before sourcing the body, `rumiai-os` removes this source-file operand from its positional parameter list.

The sourced body therefore observes `$@` as the arguments originally supplied after the source path.

The canonical source pathname is exposed through:

```text
RumiAI_COMMAND_BIN
```

`RumiAI_COMMAND_BIN` MUST be the absolute physical/canonical pathname of the source file after successful resolution.

The current name is retained for compatibility with the accepted command-entry terminology; a future naming refinement may be considered only before public stabilization.

## 9. Symbolic links and renamed aliases

A directly executable command may be invoked through a symbolic link with a different basename.

Example:

```text
/usr/local/bin/my-log -> /opt/rumiai/bin/log
```

The external alias name is not the command identity.

`rumiai-os` canonicalizes the source-file operand and executes the resulting file.

Therefore alias renaming does not require registration or basename mapping.

Relative and absolute symbolic-link targets MUST be supported when the host's canonicalization primitives can resolve them successfully.

The same canonicalization applies when a symlink pathname is explicitly supplied to:

```text
rumiai-os file
```

## 10. Multiple RumiAI runtimes

For direct shebang execution, the interpreter is selected through `PATH`:

```text
command file from location A
        ↓
PATH selects rumiai-os from environment B
```

The command is interpreted in runtime B.

This behavior is intentional and follows the active-environment model.

Future compatibility/version/capability checks MAY constrain which source files a runtime accepts. No version-pinning mechanism is introduced in the bootstrap now.

## 11. Direct invocation of `rumiai-os`

The no-argument CLI behavior is defined:

```text
rumiai-os
```

MUST bootstrap RumiAI and enter the configured interactive Rumi shell.

The initial shell policy is:

```text
preferred: bash
fallback:  sh
```

with Rumi-specific shell configuration under `RumiAI_CONF_DIR` and a recognizable/customizable Rumi prompt.

When one or more operands are supplied, the first operand is interpreted as the source file under the contract in this specification.

Future front-controller options, if introduced, MUST be designed without making the currently defined no-argument and source-file forms ambiguous.

## 12. Failure handling

Failure to resolve or validate the source file MUST NOT cause it to be sourced.

After logger activation, command/source-entry failures SHOULD be reported through the logger.

The exact numeric status assignments for source-entry and shell-launch failures remain to be consolidated with the shared bootstrap status namespace before product implementation.

## 13. Security model

Sourcing a RumiAI file executes it with the privileges and environment of the current RumiAI process.

This mechanism does not constitute a sandbox.

A source file passed to the RumiAI interpreter is executable code and must be trusted according to the same policy as any other code the user chooses to execute.

Privileged/set-user-ID execution is outside the current command-entry contract.

## 14. Rejected model

The following is no longer the command architecture:

```text
bin/foo -> ../rumiai-os
cmd/foo
```

Nor is `cmd/` a required sparse shadow of command paths.

The reasons for rejection are preserved in:

```text
decisions/rumiai-os/2026-08-28-multicall-command-layout.md
```

and the historical code proposals under:

```text
drafts/rumiai-os/phase-1-multicall/
```
