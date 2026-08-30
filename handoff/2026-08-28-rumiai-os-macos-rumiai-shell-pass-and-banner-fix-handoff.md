# Handoff — macOS RumiAI shell pass and Bash banner fix

Date: 2026-08-28
Status: **historical physical macOS validation handoff**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Base physical-test commit before shell-banner cleanup:

```text
c245cff5d1bec949f72be9f8b41c77789978342b
```

## Physical macOS RumiAI shell result

Running:

```text
./rumiai-os
```

successfully launched Bash and the configured RumiAI prompt.

Observed inside the shell:

```text
$0=bash
RumiAI_ROOT=/private/tmp/rumiai-os-test
RumiAI_BIN_DIR=/private/tmp/rumiai-os-test/bin
RumiAI_LANGUAGE=it_IT
RumiAI_TEXT_ENCODING=UTF-8
command -v rumiai-os -> /private/tmp/rumiai-os-test/bin/rumiai-os
command -v log       -> /private/tmp/rumiai-os-test/bin/log
```

`log` worked from inside the shell and shell exit propagated status `0`.

This physically validated on macOS at the recorded revision:

- no-argument `rumiai-os` enters the RumiAI shell;
- Bash is selected by default;
- RumiAI-specific bashrc is loaded;
- recognizable `[RumiAI]` prompt is active;
- physical/canonical RumiAI root state is preserved;
- RumiAI `bin/` is available through PATH;
- structural `bin/rumiai-os` exposure works inside the shell;
- `bin/log` works inside the shell;
- language selection is `it_IT`;
- text encoding is `UTF-8`;
- clean shell exit returns `0`.

## macOS Bash banner finding

Before the RumiAI prompt, Apple's bundled Bash emitted:

```text
The default interactive shell is now zsh.
```

This is a host-specific Bash deprecation notice, not a RumiAI functional failure, but it violates the desired clean RumiAI startup experience.

## Product correction

`lib/shell.lib` was updated to set and export:

```text
BASH_SILENCE_DEPRECATION_WARNING=1
```

immediately before launching Bash.

Product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

No shell selection, prompt, rc-file, PATH or fallback logic changed.

The corresponding code proposal was aligned in:

```text
drafts/rumiai-os/phase-1-command-interpreter/shell.lib
```

Validation evidence was updated in:

```text
drafts/rumiai-os/phase-1-command-interpreter/VALIDATION.md
```

## Other macOS passes already established

Physical macOS had also passed:

- explicit readable non-executable source without shebang, status `23`;
- direct `#!/usr/bin/env rumiai-os` source, status `24`;
- structural `bin/rumiai-os -> ../rumiai-os` resolution;
- public logger success and statuses `12..16`;
- logger filtering;
- Italian message catalog.

## Linux capability evidence

On Ubuntu 26.04 the user physically confirmed:

```text
realpath -e   supported
readlink -e   supported
```

## Terminology note

`RumiAI shell` and `RumiAI` are the canonical terms in the current project tree. Conversational abbreviations do not define component names, commands, namespaces or architecture.

Historical commit contents remain unchanged under the forward-only Git rule.
