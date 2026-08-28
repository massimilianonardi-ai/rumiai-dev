# Handoff — RumiAI OS CLI alignment

Date: 2026-08-28
Status: **active design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product boundary

`rumiai-os` product code has NOT been modified.

Current changes are design/specification/near-code work in `rumiai-dev` only.

## CLI now explicitly aligned

Defined behavior:

```text
rumiai-os
    bootstrap RumiAI and enter the interactive Rumi shell

rumiai-os file [args...]
    bootstrap RumiAI and source the explicitly supplied file
```

The previous code proposal incorrectly still contained:

```sh
if [ "$#" -eq 0 ]
then
  exit 0
fi
```

and contained obsolete shebang validation for explicitly supplied files.

Both defects have been corrected in:

```text
drafts/rumiai-os/phase-1-command-interpreter/rumiai-os.draft
```

## No-argument branch

The integrated draft now lazily loads:

```text
$RumiAI_LIB_DIR/shell.lib
```

and calls:

```text
RumiAI_shell
```

Current draft shell module is stored as:

```text
drafts/rumiai-os/phase-1-command-interpreter/shell.lib
```

The older standalone `rumi-shell.draft` is retained but marked historical/superseded.

Current shell direction:

```text
preferred: bash
fallback:  sh
```

with Rumi-specific configuration/prompt under `RumiAI_CONF_DIR`.

## Explicit file/source invocation

For:

```text
rumiai-os file arg1 arg2
```

the runtime now:

1. canonicalizes `file` through `realpath -e`;
2. requires a readable regular file;
3. does NOT require executable permission;
4. does NOT inspect or require a shebang;
5. prevents sourcing the runtime file itself;
6. exposes canonical `RumiAI_COMMAND_BIN`;
7. shifts the file operand;
8. sources the file in-process;
9. propagates its status.

This restores the intended interpreter distinction:

```text
./file
    direct host execution
    requires executable semantics and, for RumiAI, #!/usr/bin/env rumiai-os

rumiai-os file
    explicit interpreter invocation
    file need only be readable source code
```

## Shebang scope

Canonical direct-execution shebang remains:

```text
#!/usr/bin/env rumiai-os
```

It is a host execution mechanism, not part of the RumiAI source-file validity contract.

The decision and normative specification were updated accordingly:

```text
decisions/rumiai-os/2026-08-28-command-interpreter-shebang.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
```

## Bootstrap reader clarification

`RumiAI_bootstrap_read_value()` is unrelated to command/source execution.

Its only current role is reading minimal one-value bootstrap configuration files required before the future full configuration subsystem is available, initially:

```text
conf/bootstrap/language
conf/bootstrap/text-encoding
```

The helper enforces the current draft one-value-file contract.

## Current shared draft status sequence

```text
1  bootstrap PATH resolution failure
2  bootstrap realpath/canonicalization failure
3  invalid bootstrap binary
4  invalid/inaccessible RumiAI root
5  i18n library load failure
6  log library load failure
7  shell library load failure
8  explicit source resolution failure
9  invalid explicit source entry
```

These remain pre-stability draft assignments subject to the already accepted append-only rule once published as a stable contract.

## Immediate next work

1. review `rumiai-os.draft` again line-by-line from phase 1B onward;
2. decide whether `RumiAI_bootstrap_read_value()` should stay as-is or be simplified/generalized;
3. finalize shell configuration filenames and prompt behavior;
4. continue sourced-body lifecycle (`return`, `exit`, traps/signals);
5. consolidate shared/bootstrap versus command-local return/exit status policy;
6. run reference-host PoCs before product promotion;
7. do not modify `rumiai-os` until explicit authorization.
