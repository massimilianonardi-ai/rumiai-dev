# Handoff — macOS realpath compatibility fix

Date: 2026-08-28
Status: **physical macOS validation in progress**

## Physical finding

On the reference macOS host, `/bin/realpath` reports:

```text
realpath -e pathname    -> illegal option -- e, status 1
realpath -- pathname    -> success
realpath pathname       -> success
realpath -q pathname    -> success
```

Therefore the promoted product's use of `realpath -e --` caused phase 0 to terminate with:

```text
RumiAI_BOOTSTRAP_FATAL_REALPATH_ERROR
status 2
```

before explicit source execution could begin.

## Accepted compatibility correction

RumiAI now uses:

```sh
command -p -- realpath -- "$pathname"
```

rather than:

```sh
command -p -- realpath -e -- "$pathname"
```

The required architectural invariant remains the same: obtain an absolute physical/canonical pathname and then validate the required object explicitly.

For the bootstrap runtime, regular-file existence is enforced by:

```sh
[ -f "$RumiAI_BOOTSTRAP_BIN" ]
```

For an explicitly supplied source, validity is enforced after canonicalization by regular-file/readability checks.

The `--` delimiter is retained because physical macOS validation confirmed support for it and Linux implementations are expected to support it as well; Linux physical testing remains required.

## Product update

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Product compatibility-fix commit:

```text
c245cff5d1bec949f72be9f8b41c77789978342b
```

Changed both runtime canonicalization calls in `rumiai-os`:

```text
phase 0 runtime canonicalization
explicit source canonicalization
```

No other product behavior was changed.

## Design/source alignment

Updated current code proposal:

```text
drafts/rumiai-os/phase-1-command-interpreter/rumiai-os.draft
```

commit:

```text
28aa18225e113111ebd6628a47e858477aa1b02e
```

Updated normative phase-0 specification:

```text
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
```

commit:

```text
331bd39b93f729dc5dd481502a524fe0b5eabdf0
```

The normative contract now requires the resulting canonical pathname plus explicit object validation, not use of `realpath -e` itself.

The obsolete multicall reference in the phase-0 internal-state section was also removed while aligning the specification.

## Next physical test

On the existing macOS clone:

```sh
git pull --ff-only
git rev-parse HEAD
./rumiai-os /tmp/rumiai-source-test 'hello world' second
printf 'STATUS=%s\n' "$?"
```

Expected product HEAD:

```text
c245cff5d1bec949f72be9f8b41c77789978342b
```

Expected source behavior:

```text
SOURCE_OK
ROOT=/private/tmp/rumiai-os-test
COMMAND=/private/tmp/rumiai-source-test
ARG1=hello world
ARG2=second
STATUS=23
```

After that succeeds, continue with direct `#!/usr/bin/env rumiai-os` execution, logger, and interactive Rumi shell tests before moving to Linux.
