# Handoff — RumiAI OS command interpreter via `/usr/bin/env`

Date: 2026-08-28
Status: **active design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product boundary

`rumiai-os` product code has NOT been modified by the command-interpreter design work.

The product still contains the previously accepted phase-0 implementation and does not yet implement phase 1 or the new command model.

Promotion to `rumiai-os` still requires explicit authorization.

## Current command-entry decision

RumiAI command files use:

```text
#!/usr/bin/env rumiai-os
```

`rumiai-os` must already be resolvable through the caller environment's `PATH` before the command starts.

The command file is its own implementation entrypoint. There is no mandatory public/private launcher split.

After bootstrap, `rumiai-os` canonicalizes and sources the command file in the initialized shell.

Example:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

Because `lib/log.lib` is already sourced by the bootstrap, this calls `log()` in-process.

## Superseded multicall model

The previous model:

```text
bin/<command> -> ../rumiai-os
cmd/<command>
```

is superseded.

`cmd/` and:

```text
RumiAI_COMMAND_DIR
```

are no longer accepted semantic roots.

Historical reasoning and code remain preserved under:

```text
decisions/rumiai-os/2026-08-28-multicall-command-layout.md
drafts/rumiai-os/phase-1-multicall/
architecture/rumiai-os/COMMAND-ENTRYPOINT-EVOLUTION.md
```

## Why multicall was abandoned

The design progressively required:

- pre-realpath invocation identity;
- basename registration;
- validation of external symlink aliases;
- special handling for renamed aliases;
- collision handling for identical basenames in different command paths;
- a sparse `cmd/` shadow tree;
- additional front-controller mapping and dispatch.

The accepted interpreter model makes the command pathname an operand of the runtime and removes those routing problems.

## Current semantic roots

```text
RumiAI_BIN_DIR  = $RumiAI_ROOT/bin
RumiAI_LIB_DIR  = $RumiAI_ROOT/lib
RumiAI_CONF_DIR = $RumiAI_ROOT/conf
RumiAI_LANG_DIR = $RumiAI_ROOT/lang
```

`RumiAI_BIN_DIR` is prepended to PATH after bootstrap.

Important: this phase-1 PATH update cannot satisfy the shebang's initial interpreter lookup; the caller/activation/install environment must already expose `rumiai-os` in PATH.

How installation/activation provides this pre-bootstrap PATH entry remains an installation/environment design question.

## Command interpreter state

Proposed canonical variable:

```text
RumiAI_COMMAND_BIN
```

After successful command resolution it is the absolute physical/canonical pathname of the command file.

Conceptual execution:

```text
command args...
    ↓
/usr/bin/env rumiai-os command-file args...
    ↓
phase 0
    ↓
phase 1 + i18n + logger
    ↓
realpath(command-file)
    ↓
validate exact RumiAI shebang
    ↓
shift command-file operand
    ↓
export + readonly RumiAI_COMMAND_BIN
    ↓
. "$RumiAI_COMMAND_BIN"
    ↓
propagate command status
```

The sourced command sees only the original user arguments in `$@`.

## Alias and duplicate-name behavior

Renamed symlink aliases naturally work because routing does not depend on the alias basename:

```text
/usr/local/bin/my-log -> /opt/rumiai/bin/log
```

`rumiai-os` canonicalizes the command-file operand and sources `/opt/rumiai/bin/log`.

Duplicate basenames also require no special registry:

```text
package-a/bin/foo
package-b/bin/foo
```

The pathname selected/executed by the caller reaches the runtime directly.

## Active runtime semantics

`/usr/bin/env` selects the interpreter from PATH.

Therefore:

```text
command file from installation A
PATH selects rumiai-os from installation B
```

means runtime B interprets command file A.

This is accepted as the active-environment semantic. Future version/capability compatibility checks may constrain it when needed; no pinning is introduced now.

## Deliberate host-profile exception

POSIX.1-2024 remains the baseline for shell code and standard utility semantics, but it does not guarantee the general `#!` execution convention and does not guarantee `/usr/bin/env` at that exact pathname.

The accepted RumiAI host profile therefore additionally requires validation of:

```text
/usr/bin/env exists and is executable
#! executable scripts are supported
#!/usr/bin/env rumiai-os resolves rumiai-os through PATH
the command-file pathname is forwarded as the first runtime operand
the reference /bin/sh can source the command file compatibly with its #! first line
```

This is an explicitly approved and documented implementation-profile exception under `RULES.md`, not an accidental host dependency.

## Bootstrap/i18n/logger state retained

Accepted primitives:

```text
conf/bootstrap/language
conf/bootstrap/text-encoding
```

Language request order:

```text
conf/bootstrap/language
LC_ALL
LC_MESSAGES
LANG
en_US
```

Initial/fallback text encoding:

```text
UTF-8
```

Bootstrap catalogs are UTF-8 static messages with structured fields separate. Advanced interpolation may later use the same structured fields.

Logger public API direction remains:

```sh
log warn domain message-id field value ...
```

`fatal` is severity only and does not imply `exit`.

## Error statuses

Accepted phase-0 design numbering:

```text
1  PATH resolution failure
2  realpath/canonicalization failure
3  invalid bootstrap binary
4  invalid/inaccessible RumiAI root
```

Current interpreter draft tentatively uses:

```text
5  i18n library load failure
6  log library load failure
7  command-entry resolution failure
8  invalid command entry
```

The old multicall draft meanings formerly assigned to 7..9 are superseded and were never promoted to product/public CLI contracts.

The general command-local return-code versus external CLI status policy is still open.

## Current code proposal

```text
drafts/rumiai-os/phase-1-command-interpreter/
├── README.md
├── FLOW.md
├── VALIDATION.md
├── rumiai-os.draft
├── bin/
│   └── log.draft
└── examples/
    └── foo.draft
```

The previous i18n/logger near-code remains under:

```text
drafts/rumiai-os/phase-1-i18n-log/
```

with new command-entry diagnostic catalog messages added.

## Local evidence

Local ad hoc validation confirmed:

- `#!/usr/bin/env rumiai-os` forwards command pathname + user args in the expected shape;
- renamed command symlink aliases work after canonicalization;
- duplicate basenames in distinct directories remain distinct;
- PATH selects between two different `rumiai-os` runtimes;
- `dash`, `bash --posix` and BusyBox `sh` source the command file compatibly with the first-line shebang.

This is not reference-host certification.

## Canonical material

```text
decisions/rumiai-os/2026-08-28-command-interpreter-shebang.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
architecture/rumiai-os/PHASE-1.md
architecture/rumiai-os/COMMAND-ENTRYPOINT-EVOLUTION.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/I18N-BOOTSTRAP.md
```

## Immediate next work

1. review the new `rumiai-os.draft` line-by-line against the intended semantics;
2. decide how an installation/activation exposes `rumiai-os` in PATH before any command shebang runs;
3. decide lifecycle rules for sourced commands (`return`, `exit`, traps, signal handling);
4. finalize exact shared versus command-local error-status mapping;
5. run a formal cross-host PoC for `/usr/bin/env rumiai-os` before product promotion;
6. do not modify `rumiai-os` until explicit product implementation authorization.
