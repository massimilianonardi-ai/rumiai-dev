# RumiAI OS — Terminal editor

Status: **Current / normative**  
Updated: 2026-09-21

This specification defines the current host-neutral terminal editor wrapper provided by `m`.

## Ownership

The public command is:

```text
editor
```

`editor` belongs to the technical `m` substrate and is located at:

```text
bin/sys/editor
```

`editor` is intentionally independent from the `m` runtime and uses:

```sh
#!/bin/sh
```

Its responsibility is deliberately narrow: select the preferred available terminal-editor backend and delegate the caller's arguments without adding another editing policy.

## Public interface

The interface is:

```text
editor [argument ...]
```

Zero or more arguments are accepted and passed unchanged, in their original order, to the selected backend.

`editor` does not define or reinterpret editor options. File operands, editor-specific options, diagnostics, terminal interaction and other backend behavior remain the responsibility of the selected editor.

## Backend policy

The backend policy is capability-based and host-neutral:

```text
nano available
    -> nano

nano unavailable, vim available
    -> vim

nano and vim unavailable
    -> vi
```

The choice depends only on command availability through the current command environment; it does not depend on operating-system identity.

`vi` is the final fallback and is invoked directly rather than being pre-probed. If it cannot be executed, the shell's normal execution-failure behavior is observable.

## Delegation model

`editor` is only a backend-selection wrapper.

It does not:

```text
inspect terminal state
resolve or validate path operands
translate editor options
rewrite backend diagnostics
normalize backend exit statuses
define a separate editor configuration variable
interpret arbitrary editor command strings
```

The selected backend receives the caller's standard streams, environment and arguments directly.

## Caller environment

`editor` preserves the caller environment.

Variables consumed by the selected backend are not cleared or rewritten by `editor`.

The first implementation deliberately does not consult `EDITOR` or `VISUAL`; its stable policy is the ordered capability fallback defined above.

## Exit status

`editor` does not define a normalized exit-status layer.

The observable status is the status of the selected backend, or the shell execution-failure status if the selected backend cannot be executed.

## Use by other m components

A component that wants this generic editor-selection policy should invoke `editor` rather than duplicate the `nano` / `vim` / `vi` selection sequence.

A subsystem with materially different editing requirements may define a separate explicit contract rather than silently changing `editor`.

## Invariants

```text
EDITOR-01  editor belongs to m and is exposed as bin/sys/editor
EDITOR-02  editor is a standalone POSIX-sh wrapper and does not depend on the m runtime
EDITOR-03  arguments are forwarded unchanged and in order to the selected backend
EDITOR-04  backend preference is nano, then vim, then vi
EDITOR-05  backend selection is capability-based rather than OS-name-based
EDITOR-06  editor preserves caller streams and environment
EDITOR-07  editor does not reinterpret options, paths, diagnostics or backend status
EDITOR-08  generic m callers use editor rather than duplicating its backend-selection policy
```
