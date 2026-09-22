# RumiAI OS — Command entrypoints

Status: **Current / normative**  
Updated: 2026-09-17

This specification defines directly executable command/runtime classes in the current `m` + RumiAI model.

## Technical root bootstrap

The technical root runtime is:

```text
$m_ROOT/m
```

It is a standalone POSIX-shell bootstrap and uses exactly:

```sh
#!/bin/sh
```

## Bootstrap-integrated commands

A command that belongs to `m` or RumiAI and depends on runtime facilities initialized by `m` uses:

```sh
#!/usr/bin/env m
```

This includes commands that consume `m_*` environment roots, `log`, `lang`, internal libraries, `m_COMMAND_BIN`, `state-path` context or other bootstrap facilities.

The command body remains subject to POSIX-shell rules when implemented in shell.

The classification follows runtime dependency, not physical directory alone.

## Standalone shell utilities

A directly executable shell utility may use:

```sh
#!/bin/sh
```

only when independence from `m` is intentional and documented by its current specification.

A standalone utility must not depend on:

```text
m_* runtime variables
m_COMMAND_BIN
log/lang bootstrap facilities
libraries sourced from the m runtime
bootstrap-created PATH semantics
```

A later dependency on those facilities requires reclassification to the integrated-command model unless a new explicit contract says otherwise.

`read-key`, `readpass` and `pager` are current examples of explicitly standalone utilities. `readpassv` is bootstrap-integrated because its contract depends on the `m` runtime to resolve the RumiAI-owned `readpass` command.

## Shell command structure best practice

RumiAI-owned shell command entrypoints SHOULD normally separate definition/loading from operational execution by defining their functions first and invoking one `main "$@"` function as the final top-level command:

```sh
#!/usr/bin/env m

helper()
{
    ...
}

main()
{
    ...
}

main "$@"
```

The same structural practice applies to standalone `#!/bin/sh` commands; the shebang/runtime class does not change the recommendation.

This is a best practice rather than a mandatory entrypoint invariant. A very small command whose complete logic is clearer as direct top-level shell code may deliberately omit `main`. The exception should remain proportional to the command's simplicity rather than becoming an alternative structural convention for larger commands.

The pattern provides a clear load/run boundary, minimizes operational code executed while the command file is still being loaded, and makes long-running or interactive commands easier to reason about.

For `#!/usr/bin/env m` commands the pattern additionally improves robustness during concurrent code replacement. The `m` bootstrap sources the command file into the current shell. When all function definitions have been read before the final `main "$@"` call, execution after entry into `main` uses those already-loaded shell function definitions. Replacing the command file afterward therefore normally affects a later invocation rather than redefining the functions used by the invocation already in progress.

This is not a general hot-update atomicity guarantee. In particular:

- replacement while the command file is itself still being sourced remains a race/case-limit outside this practice;
- executables, configuration, resources or other dependencies resolved/read later during execution may reflect newer filesystem state;
- standalone `#!/bin/sh` commands do not gain the `m` sourcing property merely by following the same `main` structure.

The intent is invocation robustness and a clear command structure, not live code reloading.

## Branded root entrypoints

The branded root entrypoints are:

```text
$m_ROOT/rumiai-os
$m_ROOT/rumiai-os-sh
```

They are product entrypoints rather than technical-runtime identity. They bootstrap/delegate to `m` and activate the RumiAI executable layer.

Their current shared shell-oriented implementation baseline does not establish the eventual GUI architecture of `rumiai-os`.

## Public command naming

Public executable names describe semantic function and do not expose implementation language through suffixes such as `.sh`, `.py` or `.js`.

Multiword public command names normally use lowercase hyphen-separated names.

## Operational manual coverage

Every RumiAI-owned directly executable command identity covered by this command-entrypoint model MUST have a corresponding operational manual topic under the owner-specific `manual` resource tree defined by `DOCUMENTATION-MODEL.md`.

This includes:

```text
the technical root command m
bootstrap-integrated m commands
bootstrap-integrated RumiAI commands
standalone RumiAI-owned command utilities
branded root entrypoints
```

The requirement follows semantic command identity, not the number of physical executable paths. An exposure/symlink of the same command identity does not require a duplicate manual topic. For example, `$m_ROOT/m` and its `bin/sys/m` exposure are one command identity and therefore one manual topic.

RumiAI-owned command coverage does not extend to package-owned external executables merely because they become reachable through package integration.

Creating, renaming, removing or changing a command must obey the manual-consistency lifecycle defined by `DOCUMENTATION-MODEL.md` and the project consistency gate.

## Internal libraries are not entrypoints

Files under:

```text
lib/sys/<runtime>/
lib/ai/<runtime>/
```

are imported libraries, not directly executable commands. Shell libraries have `.lib.sh`, no shebang and no executable bit.

## Invariants

```text
ENTRY-01  m is the technical bootstrap identity
ENTRY-02  root m uses #!/bin/sh
ENTRY-03  bootstrap-integrated commands use #!/usr/bin/env m
ENTRY-04  standalone #!/bin/sh utilities require a deliberate current contract
ENTRY-05  rumiai-os and rumiai-os-sh are branded entrypoints, not the m runtime
ENTRY-06  public command names do not expose implementation-language suffixes
ENTRY-07  internal libraries are not executable entrypoints
ENTRY-08  every RumiAI-owned directly executable command identity has an operational manual topic
ENTRY-09  shell command entrypoints should normally define functions before a final main "$@" call; simple commands may omit that structure when direct top-level code is clearer
```
