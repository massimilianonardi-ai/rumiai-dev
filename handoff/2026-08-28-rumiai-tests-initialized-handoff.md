# Handoff — `rumiai-tests` initialized

Date: 2026-08-28
Status: **testing repository separation and initial structure complete**

## Canonical repositories

```text
rumiai-dev       rules, specifications, decisions, architecture, development memory
rumiai-os        stable product/runtime
rumiai-dev-PoCs  experimental laboratory and proof-of-concept work
rumiai-tests     permanent test and validation suite
```

Canonical testing rules:

```text
rumiai-dev/TESTING.md
```

`rumiai-dev/RULES.md` has been aligned with the four-repository model.

## Permanent test repository

Repository:

```text
massimilianonardi-ai/rumiai-tests
```

Current initialized commit:

```text
b666996ad0878685d4905d8f52e6206e11ac9f9f
```

Initial tree:

```text
README.md
rumiai-test
lib/
    test.lib
tests/
    rumiai-os/
        bootstrap/
        command/
        i18n/
        log/
        shell/
    external/
sessions/
```

Empty test/session directories are currently retained with `.gitkeep` markers.

Git modes verified:

```text
100755 rumiai-test
100644 lib/test.lib
```

## Runner name

The public runner is:

```text
rumiai-test
```

The name `test` was explicitly rejected because it would collide with the POSIX `test` utility.

The initial runner is intentionally only a skeleton. Until permanent tests are implemented it prints that no permanent tests are defined and exits with canonical test status:

```text
3 = ERROR
```

No CLI discovery, target selection, test selection or validation-session behavior has yet been invented.

`lib/test.lib` currently defines only the canonical test result statuses:

```text
0 = PASS
1 = FAIL
2 = SKIP
3 = ERROR
```

## Local development workspace

`rumiai-os` now contains the tracked anchor:

```text
.dev/.gitignore
```

with all operational `.dev/` contents ignored.

Current workspace convention:

```text
$RumiAI_ROOT/.dev/rumiai-tests/
$RumiAI_ROOT/.dev/rumiai-dev-PoCs/   optional, only when experimental work is needed
```

`rumiai-tests` and `rumiai-dev-PoCs` remain independent Git repositories and are not submodules or runtime dependencies.

The `rumiai-os` commit introducing the `.dev/` workspace anchor is:

```text
4d1250b02a25050ff60da2b9818519026523d6b0
```

The previously physically validated Phase 1 functional product commit remains:

```text
4f311d1fb5b35a722cf9575d890a9fa616040199
```

## PoC repository

`rumiai-dev-PoCs` remains the experimental laboratory. Its README now explicitly distinguishes PoC-local tests from the permanent regression/validation suite in `rumiai-tests`.

## Immediate next work

Before implementing the Phase 1 regression suite, define the minimal contract of `rumiai-test`:

1. target identification and explicit target override;
2. test naming and discovery;
3. selection of one test, a subtree/group, or the full suite;
4. development run versus validation run invocation;
5. result aggregation and process exit status;
6. concise output format;
7. validation-session metadata and storage format;
8. isolation/sandbox and cleanup primitives shared by tests.

After that contract is fixed, convert the already physically validated Phase 1 macOS/Ubuntu matrix into the first permanent suite.

On resume, read `rumiai-dev/RULES.md`, `rumiai-dev/TESTING.md`, and the newest file in `rumiai-dev/handoff/`; do not assume this filename remains the latest.
