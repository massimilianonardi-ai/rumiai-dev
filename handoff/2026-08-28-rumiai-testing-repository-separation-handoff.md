# Handoff — RumiAI testing repository separation

Date: 2026-08-28
Status: **testing architecture consolidated; `rumiai-tests` repository creation pending external repository-create capability**

## Canonical repository roles

The development workflow now distinguishes four repositories:

```text
rumiai-dev       rules, specifications, decisions, architecture and development memory
rumiai-os        stable product/runtime
rumiai-dev-PoCs  experimental laboratory and proof-of-concept work
rumiai-tests     permanent test and validation suite
```

PoCs and permanent tests are intentionally separate because they have different lifecycle and quality contracts.

## Canonical testing rules

Created and consolidated:

```text
rumiai-dev/TESTING.md
```

Initial creation commit:

```text
88a17310bd8c2bc1d50a56ae0ed1053a8e597db7
```

Repository-separation consolidation commit:

```text
03aa6b4bb975a9cbe0b52863decfe1a67e6a0a12
```

`TESTING.md` now defines:

- scope of permanent tests;
- separation between product, PoCs and permanent tests;
- local `.dev/` workspace model;
- initial `rumiai-tests` structure;
- public runner name `rumiai-test`;
- one-property-per-test principle;
- determinism;
- test statuses `0 PASS`, `1 FAIL`, `2 SKIP`, `3 ERROR`;
- portability and no host-specific hardcoded paths;
- isolation and cleanup;
- concise failure diagnostics;
- external-tool capability testing only where RumiAI depends on the property;
- development run versus validation run;
- validation-session metadata;
- permanent sessions under `rumiai-tests/sessions/`;
- promotion from PoC/manual validation/bug reproduction to permanent regression tests.

## Runner name

Canonical runner name:

```text
rumiai-test
```

The name `test` is explicitly rejected because it collides with the POSIX `test` utility.

## `RULES.md` alignment

`rumiai-dev/RULES.md` was updated to define all four repository roles and the new development workflow.

Commit:

```text
3f8eccae7119d109c2c37143553e7556959b6c15
```

## PoC repository alignment

`rumiai-dev-PoCs/README.md` was updated so that this repository is explicitly experimental and no longer represents the permanent validation suite.

Commit:

```text
14fa61cf3a754bd25f1ad912b0298e9627bd23cf
```

A `tests/` directory inside an individual PoC remains allowed for PoC-local experimental checks; it is not the permanent RumiAI regression suite.

## Local development workspace in `rumiai-os`

The user explicitly approved the `.dev/` workspace model.

Added:

```text
rumiai-os/.dev/.gitignore
```

with:

```text
*
!.gitignore
```

Product commit:

```text
4d1250b02a25050ff60da2b9818519026523d6b0
```

This keeps `.dev/` as a tracked workspace anchor while ignoring all operational local clones and files below it.

Canonical local placement:

```text
$RumiAI_ROOT/.dev/rumiai-tests/
```

Optional when experimental work is needed:

```text
$RumiAI_ROOT/.dev/rumiai-dev-PoCs/
```

Neither is a submodule or runtime dependency of `rumiai-os`.

## Initial `rumiai-tests` structure

When the repository is created, initialize it minimally as:

```text
rumiai-tests/
├── README.md
├── rumiai-test
├── lib/
│   └── test.lib
├── tests/
│   ├── rumiai-os/
│   │   ├── bootstrap/
│   │   ├── command/
│   │   ├── i18n/
│   │   ├── log/
│   │   └── shell/
│   └── external/
└── sessions/
```

Do not invent runner CLI complexity before it is specified and validated.

## Repository-creation blocker

At the time of this handoff, the connected GitHub capability exposes file/branch/commit/PR operations on existing repositories but does **not** expose creation of a new GitHub repository. A plugin search for an installable repository-creation capability returned no result.

A search confirmed that `massimilianonardi-ai/rumiai-tests` does not currently exist.

Therefore repository creation itself remains the only pending manual/external step. Once an empty `massimilianonardi-ai/rumiai-tests` repository exists and is accessible to the connector, populate it according to `TESTING.md` without re-deciding the architecture.

## Next work

1. Create the empty GitHub repository `massimilianonardi-ai/rumiai-tests`.
2. Populate its minimal structure and README according to `TESTING.md`.
3. Define the minimal `rumiai-test` runner contract before implementation.
4. Convert the already physically validated Phase 1 macOS/Ubuntu matrix into the first permanent regression suite.
5. Add deliberate negative-path tests for bootstrap/CLI statuses `1..10` where deterministic and practical.

On resume, as always, read the newest file in `rumiai-dev/handoff/` rather than assuming this filename is still current.
