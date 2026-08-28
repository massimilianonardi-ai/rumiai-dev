# RumiAI OS — Command Entrypoints

Status: **Normative specification**  
Date: 2026-08-28

## 1. Scope

This specification defines the initial command-entry model used after the RumiAI bootstrap environment has been established.

RumiAI command files are interpreted through the active `rumiai-os` runtime selected from `PATH`.

The canonical first line is:

```text
#!/usr/bin/env rumiai-os
```

This specification supersedes the earlier multicall/symlink + `cmd/` shadow proposal.

## 2. Command file identity

The command file itself is the implementation entrypoint.

There is no mandatory second implementation file and no mandatory command shadow tree.

A command may live in any semantically appropriate executable-command directory.

Examples:

```text
bin/log
package-a/bin/foo
package-b/bin/foo
```

Two commands may have the same basename when their pathnames differ:

```text
package-a/bin/foo
package-b/bin/foo
```

The runtime MUST preserve the command pathname supplied by the host rather than reducing command identity to the basename.

## 3. Interpreter selection

A directly executed RumiAI command file MUST begin with:

```text
#!/usr/bin/env rumiai-os
```

The host environment MUST provide:

```text
/usr/bin/env
```

and `rumiai-os` MUST be resolvable through the inherited `PATH`.

The `rumiai-os` selected from `PATH` is the active RumiAI runtime for that invocation.

This is intentional. The command file does not pin itself to a colocated RumiAI installation.

## 4. Host-profile requirement

The `#!` convention and the exact `/usr/bin/env` pathname are not guaranteed by POSIX.1-2024.

RumiAI therefore adds the following explicit host-profile requirements beyond the abstract POSIX contract:

1. executable scripts with `#!` are supported;
2. `/usr/bin/env` exists and is executable;
3. `#!/usr/bin/env rumiai-os` causes `env` to resolve `rumiai-os` through `PATH`;
4. the command-file pathname is passed to `rumiai-os` as its first command operand;
5. after bootstrap, the reference `/bin/sh` implementations can source the RumiAI command file with the initial `#!` line treated compatibly with the chosen profile.

These requirements MUST be verified on each reference host before host certification and before stable product promotion.

## 5. Bootstrap/runtime separation

`rumiai-os` remains responsible for establishing the RumiAI runtime environment.

Conceptual flow:

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

The root of the RumiAI runtime is derived from the physical `rumiai-os` interpreter, not from the command-file pathname.

## 6. Command body

The initial command-body contract is POSIX shell code sourced by `rumiai-os` after bootstrap.

Example:

```sh
#!/usr/bin/env rumiai-os

log info example started
```

Because the command body is sourced into the initialized bootstrap shell, it has direct access to sourced RumiAI libraries and exported environment state.

For example:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

uses the already loaded `log()` shell function and does not recursively invoke the public `log` command.

A command that delegates to another runtime MAY use POSIX shell as a thin adapter, for example conceptually:

```sh
#!/usr/bin/env rumiai-os
exec some-runtime ...
```

The exact language/runtime capability model is outside this initial specification.

## 7. Positional arguments

When `rumiai-os` is entered as the interpreter, the first operand identifies the command file.

Before sourcing the command body, `rumiai-os` removes this command-file operand from its positional parameter list.

The sourced command therefore observes `$@` as the arguments originally supplied by the user to the command.

The command pathname is exposed separately through a canonical RumiAI variable; the initial proposed name is:

```text
RumiAI_COMMAND_BIN
```

`RumiAI_COMMAND_BIN` MUST be the absolute physical/canonical pathname of the command file after successful resolution.

## 8. Symbolic links and renamed aliases

A command may be invoked through a symbolic link with a different basename.

Example:

```text
/usr/local/bin/my-log -> /opt/rumiai/bin/log
```

The external alias name is not the command identity.

`rumiai-os` canonicalizes the command-file operand and executes the resulting command file.

Therefore alias renaming does not require registration or basename mapping.

Relative and absolute symbolic-link targets MUST be supported when the host's canonicalization primitives can resolve them successfully.

## 9. Multiple RumiAI runtimes

Because the interpreter is selected through `PATH`, this is valid:

```text
command file from location A
        ↓
PATH selects rumiai-os from environment B
```

The command is interpreted in runtime B.

This behavior is intentional and follows the active-environment model.

Future compatibility/version/capability checks MAY constrain which command files a runtime accepts. No version-pinning mechanism is introduced in the bootstrap now.

## 10. Direct invocation of `rumiai-os`

The public CLI behavior of invoking `rumiai-os` directly with no command-file operand or with future front-controller options remains a separate contract.

The command-interpreter path MUST be distinguishable from future front-controller CLI syntax by validating that the interpreter operand resolves to a command file before it is sourced.

The initial draft treats an existing regular command-file operand as interpreter mode and leaves other direct front-controller syntax unresolved.

## 11. Failure handling

Failure to resolve or validate the command file MUST NOT cause the command file to be sourced.

After logger activation, command-entry failures SHOULD be reported through the logger.

The exact numeric status assignments for command-entry failures remain to be consolidated with the shared bootstrap status namespace before product implementation.

## 12. Security model

Sourcing a RumiAI command file executes it with the privileges and environment of the current RumiAI process.

This mechanism does not constitute a sandbox.

A command file passed to the RumiAI interpreter is executable code and must be trusted according to the same policy as any other command the user chooses to execute.

Privileged/set-user-ID execution is outside the current command-entry contract.

## 13. Rejected model

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
