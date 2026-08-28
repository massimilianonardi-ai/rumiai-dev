# Command-interpreter validation

Date: 2026-08-28  
Status: **first physical reference-host validation cycle complete — PASS on macOS and Ubuntu 26.04/aarch64**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Current physically validated product commit:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

Two product corrections were made from physical macOS evidence during the cycle:

```text
c245cff5d1bec949f72be9f8b41c77789978342b  Fix realpath portability on macOS
4f311d1fb5b35a722cf9575d890a9fa616040199  Silence macOS Bash deprecation banner
```

No further product changes were required after `4f311d1`.

## Local pre-promotion validation

Before promotion, the consolidated candidate passed syntax checks under:

```text
dash
bash --posix
busybox sh
```

for:

```text
rumiai-os
lib/i18n.lib
lib/log.lib
lib/shell.lib
```

Local checks also covered:

- explicit readable/non-executable source without shebang;
- exact source status propagation;
- direct `#!/usr/bin/env rumiai-os` execution through RumiAI PATH exposure;
- logger validation statuses `12..16`;
- renamed source symlink aliases;
- duplicate source basenames in different directories;
- active runtime selection by PATH;
- sourcing files whose first line is `#!/usr/bin/env rumiai-os` under dash, Bash POSIX mode and BusyBox sh.

## Physical macOS — PASS

Detailed report:

```text
drafts/rumiai-os/phase-1-command-interpreter/PHYSICAL-MACOS.md
```

Key physical findings and passes:

- native macOS `realpath -e` is unsupported;
- native `realpath -- pathname` works;
- product was corrected to use the smaller common form `command -p -- realpath -- pathname` plus explicit validation;
- explicit source without shebang/executable bit, exact status `23`;
- direct `#!/usr/bin/env rumiai-os`, exact status `24`;
- structural `bin/rumiai-os -> ../rumiai-os` exposure;
- public logger, localized records, filtering and statuses `12..16`;
- default Bash Rumi shell, including clean Apple startup after banner suppression;
- POSIX `sh` Rumi shell;
- runtime invocation via relative path, absolute path, PATH, relative/absolute symlink, symlink chain, intermediate symlink and pathname containing spaces;
- relative PATH component from arbitrary caller CWD;
- explicit source pathname containing spaces and source symlink chains;
- language/config precedence, locale normalization and fallback;
- malformed language and text-encoding bootstrap configuration handling;
- text encoding normalization/fallback;
- source lifecycle: return, fall-through status, exit and SIGTERM;
- clean worktree after tests.

Canonical macOS runtime identity consistently converged to the physical `/private/tmp/...` path as expected for that host.

## Physical Ubuntu 26.04/aarch64 — PASS

Detailed report:

```text
drafts/rumiai-os/phase-1-command-interpreter/PHYSICAL-UBUNTU-26.04.md
```

Reference host:

```text
Ubuntu 26.04 LTS (Resolute Raccoon)
Linux 7.0.0-30-generic
aarch64
/bin/sh -> /usr/bin/dash
```

Key physical findings and passes:

- `realpath -e`, `realpath --` and `readlink -e` all work on this host;
- syntax passes under host `sh` (dash) and `bash --posix`;
- Git index modes are correct: `100755` runtime/logger and `120000` structural symlink;
- explicit source without shebang/executable bit, exact status `23`;
- direct `#!/usr/bin/env rumiai-os`, exact status `24`;
- public logger, localized records, filtering and statuses `12..16`;
- default Bash Rumi shell;
- POSIX `sh` branch physically executing through `/usr/bin/sh` -> dash;
- runtime invocation via relative path, absolute path, PATH, relative/absolute symlink, symlink chain, intermediate symlink and pathname containing spaces;
- relative PATH component from arbitrary caller CWD;
- explicit source pathname containing spaces and source symlink chains;
- language/config precedence and locale fallback behavior identical to macOS;
- malformed language/text-encoding bootstrap config handling;
- text encoding normalization/fallback;
- source lifecycle: `return 41 -> 41`, final `false -> 1`, `exit 42 -> 42`, SIGTERM -> `143`;
- clean final worktree.

## Cross-host result

The same principal Phase 1 behavioral matrix now passes on two materially different POSIX-like reference environments:

```text
macOS physical host
Ubuntu 26.04 LTS / aarch64 / dash
```

The hosts differ in relevant implementation details:

- macOS native `realpath` does not support Issue-8 `-e`;
- Ubuntu 26.04 supports `realpath -e` and `readlink -e`;
- Ubuntu `/bin/sh` is dash;
- macOS bundled Bash required host-specific deprecation-banner suppression for clean UX.

Despite these differences, the current common-subset implementation at product commit `4f311d1` behaves consistently across both tested environments.

## Status-map evidence

Physically observed public/source statuses during this validation cycle include:

```text
0   success / filtered logger event
1   sourced-command natural failure (`false`)
12  invalid logger severity
13  invalid logger domain
14  invalid logger message-id
15  invalid logger fields
16  invalid logger level
23  explicit-source test return
24  direct-shebang test return
31  canonicalization source test return
41  explicit source `return`
42  explicit source `exit`
143 SIGTERM termination
```

The designed bootstrap/CLI status map `1..10` remains defined by the product contract; not every negative bootstrap/error branch has yet been physically forced on both reference hosts.

## Validation boundary

This result closes the **first physical Phase 1 reference-host cycle**, not universal portability certification.

Further validation can still add value for:

- negative bootstrap/error-path forcing, especially statuses `1..10`;
- additional Linux architectures/distributions;
- additional macOS versions/architectures;
- Cygwin / Windows POSIX-compatible host profile;
- automated regression execution of the now-stable physical matrix.
