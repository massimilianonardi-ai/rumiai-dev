# Handoff — RumiAI shell e runtime exposure

Date: 2026-08-28
Status: **active design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product boundary

`rumiai-os` product code has NOT been modified by this work.

Phase 1, command interpreter and Rumi shell remain design/draft work in `rumiai-dev` until explicit product implementation authorization.

## Command interpreter decision retained

RumiAI command files use:

```text
#!/usr/bin/env rumiai-os
```

The command file is its own implementation body and is sourced by the initialized runtime.

No multicall command tree and no mandatory `cmd/` shadow tree are part of the current architecture.

## New accepted shell/runtime exposure direction

Direct invocation with no arguments:

```text
/path/to/rumiai-os
```

means:

```text
bootstrap RumiAI
    ↓
initialize environment/i18n/logger
    ↓
launch interactive Rumi shell
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

Initial draft paths:

```text
conf/shell/default
conf/shell/bashrc
conf/shell/shrc
```

Exact config filenames remain reviewable until the shell draft is consolidated.

The Rumi shell should have a recognizable/customizable prompt.

## Runtime availability inside Rumi shell

Rather than putting `RumiAI_ROOT` itself in PATH, the current design direction uses one structural internal symlink:

```text
$RumiAI_BIN_DIR/rumiai-os -> ../rumiai-os
```

Phase 1 already prepends `RumiAI_BIN_DIR` to PATH.

Therefore after starting the portable Rumi shell, `rumiai-os` is resolvable by `/usr/bin/env` and command files using:

```text
#!/usr/bin/env rumiai-os
```

work without modifying the host environment.

This symlink only exposes the runtime under its canonical name. It is NOT the superseded multicall routing model.

## Optional host integration

RumiAI may provide a utility/script to create or remove an external symlink to the physical runtime.

Do not hard-code `/bin` as the default integration directory.

Reasons:

- macOS protects `/bin` through System Integrity Protection;
- locally installed Unix-like software conventionally belongs under `/usr/local`;
- host integration should be optional and configurable.

Initial default proposal:

```text
/usr/local/bin/rumiai-os -> <RumiAI_BOOTSTRAP_BIN>
```

The integration tool should:

- refuse silent overwrite of unrelated existing entries;
- remove only a link verified to target the expected runtime;
- report permission failures cleanly;
- permit destination override;
- remain optional because portable shell activation requires no host modification.

## Historical `msh` comparison

Historical reference:

```text
massimilianonardi/m cmd/msh
commit e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

`msh` already implemented the same conceptual pattern:

- environment-specific PATH;
- no-argument Bash shell;
- custom recognizable PS1;
- Bash launched without normal user startup files.

Useful ideas retained:

- activation shell as an environment boundary;
- recognizable prompt;
- deterministic shell startup.

Historical implementation details NOT copied:

- `ls -ld` symlink parsing;
- adding every immediate subdirectory to PATH;
- assumptions tied to the old `m` layout.

## Current code proposal

New draft:

```text
drafts/rumiai-os/phase-1-command-interpreter/rumi-shell.draft
```

It currently demonstrates:

- `conf/shell/default` one-line shell selection;
- Bash preferred, `sh` fallback;
- Bash Rumi rc file via `--rcfile`;
- POSIX sh Rumi rc file via `ENV`;
- recognizable default PS1 when no rc file exists;
- `exec` replacement of the bootstrap process with the interactive shell.

This is near-code only and remains non-normative.

## Relevant new decision

```text
decisions/rumiai-os/2026-08-28-rumi-shell-and-runtime-exposure.md
```

## Immediate next work

1. review the shell-launch code proposal;
2. decide/finalize exact shell configuration filenames and semantics;
3. decide whether `bin/rumiai-os -> ../rumiai-os` should be made normative;
4. design the optional host-link create/remove command and its exact destination policy;
5. fold no-argument Rumi shell behavior into the command-entry/phase-1 specifications;
6. continue error-status and sourced-command lifecycle design;
7. run formal reference-host PoCs before product promotion;
8. do not modify `rumiai-os` until explicit authorization.
