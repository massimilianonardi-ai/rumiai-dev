# RumiAI OS — Phase 1 physical macOS validation

Date: 2026-08-28
Status: **first physical macOS validation cycle complete**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Final tested product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

Relevant physical-test fixes applied during the cycle:

```text
c245cff5d1bec949f72be9f8b41c77789978342b  Fix realpath portability on macOS
4f311d1fb5b35a722cf9575d890a9fa616040199  Silence macOS Bash deprecation banner
```

No additional product change was required after `4f311d1`.

## Host utility finding

The native macOS host exposed:

```text
/bin/sh
/bin/bash
/bin/realpath
/usr/bin/env
```

Observed `realpath` behavior:

```text
/bin/realpath -e pathname -> unsupported, status 1
/bin/realpath -- pathname -> success
/bin/realpath pathname    -> success
/bin/realpath -q pathname -> success
```

The product therefore moved from `realpath -e --` to the smaller physically demonstrated common contract:

```sh
command -p -- realpath -- "$pathname"
```

followed by explicit RumiAI validation of the resolved object.

## Repository integrity and syntax — PASS

The physical clone matched the promoted product commit, had a clean worktree, preserved executable modes and the structural symlink:

```text
bin/rumiai-os -> ../rumiai-os
```

Syntax checks passed under physical macOS:

```text
/bin/sh
/bin/bash --posix
```

for the runtime, libraries and public `bin/log` command.

## Explicit source interpreter — PASS

A readable, non-executable source without shebang was interpreted successfully.

Confirmed:

- no executable bit required;
- no shebang required;
- arguments preserved;
- `RumiAI_ROOT` canonical;
- `RumiAI_COMMAND_BIN` canonical;
- exact source status propagation.

Representative observed status:

```text
23
```

## Direct host execution — PASS

An executable source using:

```text
#!/usr/bin/env rumiai-os
```

executed successfully through the structural runtime exposure in `PATH`.

Confirmed:

- `/usr/bin/env` resolves `rumiai-os` through `PATH`;
- `bin/rumiai-os -> ../rumiai-os` works;
- runtime symlink canonicalization works;
- source identity is canonicalized;
- original user arguments survive;
- exact source status propagates.

Representative observed status:

```text
24
```

## Logger — PASS

Physical public `log` command execution passed.

Observed status contract:

```text
valid log           -> 0
invalid severity    -> 12
invalid domain      -> 13
invalid message-id  -> 14
invalid fields      -> 15
invalid log level   -> 16
filtered debug      -> 0
```

Also confirmed:

- Italian localized catalog output;
- filtered debug emits no record and returns success;
- invalid structured fields do not leave partial log output.

## Interactive Rumi shell — PASS

### Bash branch

Running `rumiai-os` with the default shell configuration entered Bash with the RumiAI prompt and expected environment.

Confirmed:

```text
$0=bash
RumiAI_ROOT=/private/tmp/rumiai-os-test
RumiAI_BIN_DIR=/private/tmp/rumiai-os-test/bin
RumiAI_LANGUAGE=it_IT
RumiAI_TEXT_ENCODING=UTF-8
```

The initial Apple Bash zsh/deprecation banner was treated as a host-specific UX finding and suppressed by exporting:

```text
BASH_SILENCE_DEPRECATION_WARNING=1
```

A physical re-test confirmed clean startup.

### POSIX sh branch

Temporarily selecting `sh` in `conf/shell/default` entered the RumiAI POSIX shell branch with:

```text
$0=/bin/sh
[RumiAI] $
```

The RumiAI environment, `rumiai-os`, `log` and localized logging remained available. The tracked configuration was restored and the worktree returned clean.

## Runtime pathname canonicalization — PASS

Phase 0 was physically exercised through:

```text
relative pathname
absolute pathname
PATH command-name lookup
relative symbolic link
absolute symbolic link
symbolic-link chain
symbolic link in an intermediate component
invocation pathname containing spaces
```

Every case converged to:

```text
RumiAI_BOOTSTRAP_BIN=/private/tmp/rumiai-os-test/rumiai-os
RumiAI_ROOT=/private/tmp/rumiai-os-test
status=0
```

A further test from an arbitrary caller CWD used a relative `PATH` component:

```text
../rumiai-os-test/bin
```

`command -v rumiai-os` returned the relative pathname, while Phase 0 still canonicalized the runtime and root correctly.

## Explicit source pathname canonicalization — PASS

A source pathname containing spaces was executed directly and through:

```text
relative symbolic link
absolute symbolic link
symbolic-link chain
```

All cases converged to the same physical source identity:

```text
/private/tmp/rumiai source space/source file
```

Arguments were preserved and the exact source status `31` propagated in every case.

## i18n and bootstrap configuration — PASS

Physically confirmed language precedence:

```text
bootstrap config > LC_ALL > LC_MESSAGES > LANG > en_US fallback
```

Confirmed cases:

- `it_IT.UTF-8` normalization to `it_IT`;
- `en_US.UTF-8` normalization to `en_US`;
- `C` locale maps to `en_US`;
- unsupported `fr_FR` falls back to `en_US`;
- valid bootstrap language config overrides environment;
- unsupported configured language falls back;
- malformed multi-line language config is rejected and environment selection resumes;
- `utf8` normalizes to `UTF-8`;
- unsupported `ASCII` encoding falls back to `UTF-8`;
- malformed multi-line encoding config is rejected;
- warnings are rendered in the selected/fallback catalog language.

Temporary bootstrap test configuration was removed and the worktree returned clean.

## Sourced-command lifecycle — PASS

Physical lifecycle behavior:

```text
return 41      -> status 41
fall-through false -> status 1
exit 42        -> status 42
SIGTERM self   -> status 143 as observed by zsh
```

Confirmed:

- code after `return` is not executed;
- the final command status is preserved on natural fall-through;
- code after `exit` is not executed;
- a signal terminating `rumiai-os` does not terminate the caller's zsh;
- code after the terminating signal is not executed;
- final repository worktree is clean.

## macOS conclusion

The first physical macOS validation cycle for the promoted Phase 1 runtime is complete.

The tested product physically validates the principal Phase 0/Phase 1 contracts currently implemented:

- relocatable physical runtime discovery;
- pathname and symlink canonicalization;
- explicit source interpretation;
- direct `#!/usr/bin/env rumiai-os` execution;
- portable command exposure through `bin/`;
- logger contract;
- Bash and POSIX sh Rumi shells;
- language and encoding bootstrap behavior;
- source lifecycle/status behavior.

The only product defects found during the cycle were:

1. macOS native `realpath` does not support `-e`;
2. Apple Bash emits a zsh/deprecation banner unless explicitly silenced.

Both were corrected and physically re-tested successfully.

## Linux status

Ubuntu 26.04 capability evidence already supplied by the user:

```text
realpath -e   supported
readlink -e   supported
```

This is host capability evidence only; the product remains on `realpath --` plus explicit RumiAI validation.

Full physical `rumiai-os` Phase 1 validation on Ubuntu 26.04 is the next reference-host gate.
