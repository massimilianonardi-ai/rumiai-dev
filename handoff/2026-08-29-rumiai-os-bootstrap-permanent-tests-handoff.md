# Handoff — RumiAI OS permanent bootstrap tests

Date: 2026-08-29
Status: **PASS 40 validated; Phase 1F portability defect isolated; stable canonicalization fix awaiting cross-host validation**

## Repositories

Product:

```text
massimilianonardi-ai/rumiai-os
```

Tests:

```text
massimilianonardi-ai/rumiai-tests
```

Canonical physical invocation remains:

```text
cd <rumiai-os>
git pull --ff-only
cd <rumiai-tests>
git pull --ff-only
./rumiai-test
```

## Last fully validated baseline

Product:

```text
4d1250b02a25050ff60da2b9818519026523d6b0
```

Suite:

```text
9b0c5a6d42b3f8e07d372862f11907a76441d532
```

Both macOS and Ubuntu 26.04 ARM64 produced:

```text
PASS   40
FAIL   0
SKIP   0
ERROR  0
TOTAL  40
```

## Phase 1F suite

Current test suite:

```text
c259b2805377bb33d9bb70c9758d6af60a27a9e2
```

It adds command-interpreter, direct `#!/usr/bin/env rumiai-os` host-profile and initial no-argument shell tests, bringing the complete suite to 53 tests.

## First PASS-53 attempt — portability defect discovered

Against product `4d1250b0...`:

macOS:

```text
PASS   53
FAIL   0
SKIP   0
ERROR  0
TOTAL  53
```

Ubuntu 26.04 ARM64:

```text
PASS   52
FAIL   1
SKIP   0
ERROR  0
TOTAL  53
```

Only:

```text
rumiai-os/command/resolution-failure.test
```

failed on Ubuntu.

The product was calling optionless:

```sh
realpath -- "$RumiAI_COMMAND_ENTRY"
```

on an unchecked missing pathname.

GNU/Linux accepted the missing final component and returned a canonical pathname, producing later status 9. macOS rejected it during canonicalization, producing status 8.

This demonstrated that RumiAI was depending on precisely the optionless missing-final-component behavior that POSIX.1-2024 says portable applications must not depend on.

## Rejected attempted fix — commit 01db051c

An attempted product fix changed both canonicalization calls to:

```sh
realpath -e -- "$path"
```

Commit:

```text
01db051c8bcaac840ce1eda9a9f5339ef1198388
Require existing paths during canonicalization
```

This commit is **rejected as a portability solution**.

It contradicted already-recorded physical evidence from 2026-08-28:

```text
macOS /bin/realpath -e pathname -> illegal option -- e
```

and the normative compatibility correction already recorded in:

```text
handoff/2026-08-28-rumiai-os-macos-realpath-compatibility-handoff.md
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
```

Physical result against `01db051c...` and suite `c259b280...`:

macOS:

```text
PASS   19
FAIL   34
SKIP   0
ERROR  0
TOTAL  53
```

Ubuntu 26.04 ARM64:

```text
PASS   53
FAIL   0
SKIP   0
ERROR  0
TOTAL  53
```

This is preserved as historical evidence and MUST NOT be rewritten or presented as a viable candidate.

## Stable decision — validation and canonicalization are separate

The accepted portability rule from this point onward is:

```text
VALIDATE EXISTENCE
        ↓
CANONICALIZE EXISTING PATH
        ↓
VALIDATE REQUIRED TYPE
```

`realpath` is used only as a canonicalizer. It is never used to decide whether an unchecked pathname exists.

The product now defines one internal primitive:

```text
RumiAI_path_canonicalize_existing
```

Its contract is:

1. require exactly one pathname;
2. require `[ -e "$pathname" ]` before invoking `realpath`;
3. invoke only `command -p -- realpath -- "$pathname"`;
4. require successful status;
5. require an absolute result;
6. require the canonical result still resolves to an existing object;
7. let the caller separately validate the required object type/readability.

This means RumiAI defines no behavior and has no dependency on:

```text
realpath -- missing-path
```

`realpath -e` and `realpath -E` are not required by the current reference-host profile.

The primitive is reused for both:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_COMMAND_BIN
```

so there is no second canonicalization policy to drift independently.

Current candidate product commit:

```text
8698504f715ed61cec8a31b46ded5b79f3924eb5
Separate pathname validation from canonicalization
```

Normative specification commit:

```text
1bc4b4f204a2448f0bac229146aac6afe94e0ca0
Separate pathname validation from realpath semantics
```

The normative specification explicitly supersedes both earlier incorrect assumptions:

1. requiring `realpath -e` merely because Issue 8 defines it;
2. passing an unchecked pathname to optionless `realpath` and validating only afterwards.

## Why `realpath` is retained

RumiAI does not currently reintroduce a hand-written symbolic-link resolver.

The problematic cross-host variability was in using `realpath` as an existence/error-policy mechanism. For an already-resolved existing pathname, RumiAI uses only the common canonicalization operation physically available on both reference hosts and verifies the result independently.

A future replacement of this primitive is allowed, including a RumiAI-owned path tool, but it must demonstrate a concrete improvement over this restricted contract and pass the complete pathname matrix on all reference hosts before promotion.

## Regression evidence already in the suite

The existing Phase 1F tests deliberately remain unchanged.

In particular:

```text
rumiai-os/command/resolution-failure.test
```

requires a missing source pathname to produce status 8 on every host.

Together with the existing absolute/relative/PATH/symlink/canonical command tests, this prevents either of the two bad simplifications from silently returning:

- adding mandatory `realpath -e` breaks the macOS suite;
- removing the pre-existence gate breaks the Linux missing-path regression.

## Canonical level-2 test-authoring references

```text
interactive TTY:
massimilianonardi-ai/rumiai-tests@7eed87d7cba441d248ae68de82762b73b2320f77:lib/interactive.lib

target discovery:
massimilianonardi-ai/rumiai-tests@5af68cbff09ce979df3dff91e398e287eadd48b7:lib/rumiai-os-target.lib

isolated RumiAI OS fixture:
massimilianonardi-ai/rumiai-tests@251ec2bde45a197590ec7dc23b8b41e60a79543f:lib/rumiai-os-fixture.lib
```

All three are already physically validated on macOS and Ubuntu ARM64.

## Next physical gate

Run the unchanged complete suite `c259b280...` against product candidate `8698504f...` on both stable hosts.

Required result:

```text
PASS   53
FAIL   0
SKIP   0
ERROR  0
TOTAL  53
```

Only after both hosts pass may the new pathname-canonicalization contract be marked physically validated.

## Forward-only rule

All repository updates remain forward-only. Rejected commits and failed physical results remain part of the historical evidence; they are corrected by later commits, never rewritten.
