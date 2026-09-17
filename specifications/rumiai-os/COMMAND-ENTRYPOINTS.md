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

`read-key` is a current example of an explicitly standalone utility.

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
```
