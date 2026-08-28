# Handoff — macOS Bash Rumi shell pass

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

This commit adds:

```sh
BASH_SILENCE_DEPRECATION_WARNING=1
export BASH_SILENCE_DEPRECATION_WARNING
```

before launching Bash from `lib/shell.lib`.

## Physical macOS Bash shell — PASS

After pulling the product commit, running:

```text
./rumiai-os
```

entered the RumiAI Bash shell directly with no Apple zsh/deprecation banner.

Observed prompt:

```text
[RumiAI] massimilianonardi@MacBook-Air-di-Massimiliano:/tmp/rumiai-os-test $
```

Inside the shell:

```text
$0=bash
```

The earlier full interactive-shell test on the same host had already confirmed:

```text
RumiAI_ROOT=/private/tmp/rumiai-os-test
RumiAI_BIN_DIR=/private/tmp/rumiai-os-test/bin
RumiAI_LANGUAGE=it_IT
RumiAI_TEXT_ENCODING=UTF-8
command -v rumiai-os -> /private/tmp/rumiai-os-test/bin/rumiai-os
command -v log       -> /private/tmp/rumiai-os-test/bin/log
log status            -> 0
shell exit status     -> 0
```

The Apple banner suppression was the only outstanding Bash-shell UX finding. It is now physically confirmed fixed.

## macOS validation already passed

- native `realpath --` compatibility after removing `-e`;
- explicit readable/non-executable source without shebang, status `23`;
- direct `#!/usr/bin/env rumiai-os` execution, status `24`;
- structural `bin/rumiai-os -> ../rumiai-os` runtime exposure;
- public logger and statuses `12..16`;
- localized Italian log record;
- debug filtering with success status;
- interactive Bash Rumi shell, prompt, PATH and environment;
- clean Bash startup after Apple banner suppression.

## Ubuntu 26.04 capability evidence

User physically reported:

```text
realpath -e   supported
readlink -e   supported
```

Full `rumiai-os` Linux testing remains pending.

## Immediate next macOS test

Exercise the POSIX `sh` shell-selection branch by temporarily changing:

```text
conf/shell/default
```

from `bash` to `sh`, entering `./rumiai-os`, validating `$0`, prompt, PATH and commands, then restoring the tracked file with Git.

After that, continue with phase-0 pathname/symlink edge cases before moving the full product matrix to Ubuntu/Linux.
