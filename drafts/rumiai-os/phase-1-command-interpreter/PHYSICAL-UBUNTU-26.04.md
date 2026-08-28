# RumiAI OS — Physical Ubuntu 26.04 validation

Date: 2026-08-28  
Status: **first Phase 1 physical validation cycle complete — PASS**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Tested product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

No product change was required during the Ubuntu validation cycle.

## Reference host

Physical/VM host evidence supplied by the user:

```text
Ubuntu 26.04 LTS (Resolute Raccoon)
Linux 7.0.0-30-generic
aarch64
/bin/sh -> /usr/bin/dash
bash -> /usr/bin/bash
realpath -> /usr/bin/realpath
readlink -> /usr/bin/readlink
env -> /usr/bin/env
```

## Clone, modes and syntax — PASS

The repository cloned at the expected product commit with a clean worktree.

Structural runtime exposure:

```text
bin/rumiai-os -> ../rumiai-os
```

Git index modes:

```text
100755 bin/log
120000 bin/rumiai-os
100755 rumiai-os
```

The runtime, libraries and `bin/log` passed syntax checking under both:

```text
sh -n              # host sh is dash
bash --posix -n
```

## Native canonicalization utilities — PASS

Observed:

```text
realpath -e pathname -> success, status 0
realpath -- pathname -> success, status 0
readlink -e pathname -> success, status 0
```

The product intentionally uses the smaller cross-host form:

```sh
command -p -- realpath -- "$pathname"
```

followed by explicit RumiAI object validation.

## Explicit source — PASS

A readable, non-executable source without a shebang produced:

```text
SOURCE_OK
ROOT=/tmp/rumiai-os-ubuntu-test
COMMAND=/tmp/rumiai-source-test
ARG1=hello world
ARG2=second
STATUS=23
```

This confirms explicit-source interpretation, canonical source identity, positional argument preservation and exact status propagation under the host POSIX shell environment.

## Direct `#!/usr/bin/env rumiai-os` execution — PASS

With the RumiAI `bin/` directory prepended to PATH:

```text
RUNTIME_IN_PATH=/tmp/rumiai-os-ubuntu-test/bin/rumiai-os
RUNTIME_REAL=/tmp/rumiai-os-ubuntu-test/rumiai-os
```

A direct executable source beginning with:

```text
#!/usr/bin/env rumiai-os
```

produced:

```text
DIRECT_OK
ROOT=/tmp/rumiai-os-ubuntu-test
COMMAND=/tmp/rumiai-direct-test
ARG1=hello direct
ARG2=second
DIRECT_STATUS=24
```

This validates the host shebang profile, `/usr/bin/env` PATH resolution, structural runtime exposure, argument forwarding and exact status propagation.

## Public logger — PASS

Observed statuses:

```text
valid log           -> 0
invalid severity    -> 12
invalid domain      -> 13
invalid message-id  -> 14
invalid fields      -> 15
invalid log level   -> 16
filtered debug      -> 0
```

The valid event was localized through the Italian catalog. A debug event filtered at the default `info` threshold emitted no record and returned success.

## Interactive Bash Rumi shell — PASS

Default `./rumiai-os` entered Bash with the configured RumiAI prompt.

Observed:

```text
$0=bash
RumiAI_ROOT=/tmp/rumiai-os-ubuntu-test
RumiAI_BIN_DIR=/tmp/rumiai-os-ubuntu-test/bin
RumiAI_LANGUAGE=it_IT
RumiAI_TEXT_ENCODING=UTF-8
command -v rumiai-os -> /tmp/rumiai-os-ubuntu-test/bin/rumiai-os
command -v log       -> /tmp/rumiai-os-ubuntu-test/bin/log
realpath rumiai-os    -> /tmp/rumiai-os-ubuntu-test/rumiai-os
realpath log          -> /tmp/rumiai-os-ubuntu-test/bin/log
log status            -> 0
shell exit status     -> 0
```

No unexpected startup output was emitted.

## Interactive POSIX sh / dash Rumi shell — PASS

With temporary:

```text
conf/shell/default = sh
```

RumiAI entered the POSIX shell branch with:

```text
[RumiAI] $
```

Observed:

```text
$0=/usr/bin/sh
RumiAI_ROOT=/tmp/rumiai-os-ubuntu-test
RumiAI_BIN_DIR=/tmp/rumiai-os-ubuntu-test/bin
command -v rumiai-os -> /tmp/rumiai-os-ubuntu-test/bin/rumiai-os
command -v log       -> /tmp/rumiai-os-ubuntu-test/bin/log
log status            -> 0
```

Because `/usr/bin/sh` resolves to dash on this host, this physically validates the `sh` branch under dash.

One interactive paste boundary produced `exitprintf: not found`; this was a terminal-input artifact after the RumiAI checks had already passed, not a product failure. The shell subsequently exited with status `0`, the tracked config was restored to `bash`, and the worktree was clean.

## Runtime pathname / symlink / spaces matrix — PASS

The runtime was invoked through:

```text
relative pathname
absolute pathname
PATH lookup
relative symbolic link
absolute symbolic link
symbolic-link chain
symbolic link in an intermediate pathname component
invocation pathname containing spaces
```

Every case converged to:

```text
BOOTSTRAP=/tmp/rumiai-os-ubuntu-test/rumiai-os
ROOT=/tmp/rumiai-os-ubuntu-test
STATUS=0
```

## Relative PATH from arbitrary CWD — PASS

From `/tmp/rumiai-caller`, PATH contained the relative component:

```text
../rumiai-os-ubuntu-test/bin
```

Observed:

```text
COMMAND_V=../rumiai-os-ubuntu-test/bin/rumiai-os
BOOTSTRAP=/tmp/rumiai-os-ubuntu-test/rumiai-os
ROOT=/tmp/rumiai-os-ubuntu-test
STATUS=0
```

This confirms that runtime identity does not depend on caller CWD or an absolute PATH entry.

## Explicit source with spaces and symlink aliases — PASS

The physical source:

```text
/tmp/rumiai source space/source file
```

was invoked directly and through relative, absolute and chained symbolic links.

All cases converged to:

```text
COMMAND=/tmp/rumiai source space/source file
```

Arguments were preserved and every case propagated:

```text
STATUS=31
```

## i18n and bootstrap configuration — PASS

Observed language precedence:

```text
LC_ALL=it_IT.UTF-8, LC_MESSAGES=en_US.UTF-8, LANG=en_US.UTF-8 -> it_IT
LC_ALL empty, LC_MESSAGES=en_US.UTF-8, LANG=it_IT.UTF-8      -> en_US
LC_ALL empty, LC_MESSAGES empty, LANG=it_IT.UTF-8            -> it_IT
LC_ALL=C                                                     -> en_US
```

This confirms:

```text
bootstrap config > LC_ALL > LC_MESSAGES > LANG > en_US fallback
```

Additional results:

```text
unsupported fr_FR locale          -> en_US + expected English warning
conf/bootstrap/language=it_IT      -> overrides en_US environment
conf/bootstrap/language=fr_FR      -> en_US fallback + warning
malformed language config          -> warning, then environment fallback
conf/bootstrap/text-encoding=utf8  -> UTF-8
unsupported ASCII encoding         -> UTF-8 + warning
malformed text-encoding config     -> UTF-8 + warning
```

All diagnostic invocations returned status `0`. Warning localization matched the selected catalog language exactly as on macOS.

Temporary bootstrap configuration was removed after the tests.

## Explicit-source lifecycle — PASS

Observed:

```text
return 41        -> STATUS=41
final `false`    -> STATUS=1
exit 42          -> STATUS=42
SIGTERM self     -> STATUS=143
```

No statement after `return`, `exit` or SIGTERM executed.

For SIGTERM the host shell printed:

```text
Terminato
```

which is the normal localized host-shell signal diagnostic, not RumiAI output.

## Final repository state — PASS

After all temporary configuration and source files were cleaned up:

```text
git status --short -> empty
```

## Conclusion

The first Phase 1 physical validation cycle is complete and passing on Ubuntu 26.04 LTS/aarch64 with dash as `/bin/sh`.

The tested product commit is unchanged:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

The same principal behavioral matrix has also passed on the physical macOS reference host. The two hosts differ materially in userland and shell behavior — notably macOS native `realpath` lacks Issue-8 `-e`, while Ubuntu supports it; Ubuntu `/bin/sh` is dash — yet the current RumiAI common-subset implementation behaves consistently on both.

This is not a universal portability certification. Later gates still include additional host/architecture coverage and the Windows POSIX-compatible profile (currently expected to use Cygwin).
