# Handoff — RumiAI shell e runtime exposure

Date: 2026-08-28
Status: **historical design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

This file preserves the design state from 2026-08-28 with current canonical RumiAI terminology.

## Product boundary at this handoff

At the time of this handoff, `rumiai-os` product code had not yet been modified by this work.

Phase 1, command interpreter and RumiAI shell were design/draft work in `rumiai-dev` pending explicit product implementation authorization.

## Command interpreter decision retained

RumiAI command files used the already-defined runtime entrypoint:

```text
#!/usr/bin/env rumiai-os
```

The command file was its own implementation body and was sourced by the initialized runtime.

No multicall command tree and no mandatory `cmd/` shadow tree were part of the architecture.

## Accepted shell/runtime exposure direction

Direct invocation with no arguments:

```text
/path/to/rumiai-os
```

meant:

```text
bootstrap RumiAI
    ↓
initialize environment/i18n/logger
    ↓
launch interactive RumiAI shell
```

Preferred initial shell:

```text
bash
```

Fallback:

```text
sh
```

Shell configuration belongs under `RumiAI_CONF_DIR`.

Paths considered:

```text
conf/shell/default
conf/shell/bashrc
conf/shell/shrc
```

The RumiAI shell has a recognizable/customizable prompt.

## Runtime availability inside RumiAI shell

The design direction used one structural internal symlink:

```text
$RumiAI_BIN_DIR/rumiai-os -> ../rumiai-os
```

With `RumiAI_BIN_DIR` in `PATH`, `rumiai-os` can be resolved without adding `RumiAI_ROOT` itself to `PATH`.

This symlink exposes the runtime under its canonical name. It is not the superseded multicall routing model.

## Optional host integration

RumiAI may provide a utility/script to create or remove an external symlink to the physical runtime.

The destination host is not fixed to `/bin`.

Initial default proposal:

```text
/usr/local/bin/rumiai-os -> <RumiAI_BOOTSTRAP_BIN>
```

The integration tool should refuse unrelated overwrites, remove only verified links, report permission failures, permit destination override and remain optional.

## Historical `msh` comparison

Historical reference:

```text
massimilianonardi/m cmd/msh
commit e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

Useful ideas retained:

- activation shell as an environment boundary;
- recognizable prompt;
- deterministic shell startup.

Historical implementation details were not copied.

## Code proposal state

The earlier standalone shell-launch draft was superseded by the integrated `shell.lib` proposal/product evolution and is no longer retained in the current tree.

## Relevant decision

```text
decisions/rumiai-os/2026-08-28-rumiai-shell-and-runtime-exposure.md
```

## Terminology rule

The product and environment terminology is `RumiAI`. Conversational abbreviations are not component names and are not promoted into repository paths, commands, APIs or architecture.
