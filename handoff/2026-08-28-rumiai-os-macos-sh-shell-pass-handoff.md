# Handoff — macOS POSIX sh Rumi shell pass

Date: 2026-08-28
Status: **physical macOS validation in progress**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Current tested product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

## Physical macOS POSIX sh shell — PASS

The shell selector was temporarily changed:

```text
conf/shell/default: bash -> sh
```

Running:

```text
./rumiai-os
```

entered the POSIX sh Rumi shell with:

```text
[RumiAI] $
```

Observed state:

```text
$0=/bin/sh
RumiAI_ROOT=/private/tmp/rumiai-os-test
RumiAI_BIN_DIR=/private/tmp/rumiai-os-test/bin
command -v rumiai-os -> /private/tmp/rumiai-os-test/bin/rumiai-os
command -v log       -> /private/tmp/rumiai-os-test/bin/log
log status            -> 0
```

The public logger remained available and produced the expected localized Italian record from inside the sh branch.

After exit, the tracked configuration was restored:

```text
git status --short -> empty
conf/shell/default -> bash
```

Therefore both currently supported interactive Rumi shell branches are physically validated on this macOS host:

```text
bash -> PASS
sh   -> PASS
```

The Bash branch also includes the previously validated Apple deprecation-banner suppression from product commit `4f311d1fb5b35a722cf9575d890a9fa616040199`.

## Non-RumiAI zsh messages

Two later errors of the form:

```text
zsh: no such file or directory: .../bin/rumiai-os
zsh: no such file or directory: .../bin/log
```

were caused by literal expected-output/example lines being pasted into zsh as commands. They do not indicate a RumiAI defect.

## macOS validation passed so far

- native `realpath --` compatibility after removing `-e`;
- explicit readable/non-executable source without shebang, status `23`;
- direct `#!/usr/bin/env rumiai-os` execution, status `24`;
- structural `bin/rumiai-os -> ../rumiai-os` exposure;
- public logger and statuses `12..16`;
- Italian catalog and filtering;
- Bash Rumi shell, clean prompt, environment and PATH;
- POSIX sh Rumi shell, prompt, environment and PATH.

## Ubuntu 26.04 capability evidence

The user physically reported:

```text
realpath -e   supported
readlink -e   supported
```

Full product execution on Ubuntu/Linux remains pending.

## Immediate next macOS work

Run the phase-0 pathname and symlink matrix against the current product:

1. relative invocation;
2. absolute invocation;
3. PATH invocation;
4. relative symlink;
5. absolute symlink;
6. symlink chain;
7. intermediate symlink component;
8. pathname containing spaces.

Use an explicit source test body for these cases so each invocation terminates automatically rather than opening an interactive shell. After phase-0 coverage, test locale fallback and sourced-command lifecycle, then move the full product matrix to Ubuntu/Linux.
