# python-env facility

Status: Complete
Updated: 2026-09-29

## Goal

Define, validate and implement the provider-independent `python-env` facility, with `micromamba` as the first concrete provider, without exposing micromamba-specific CLI semantics to consumers.

## Current repository revisions

```text
rumiai-dev       fce8f9ea3ae9ba473f62d5f6e103d7c693498904
rumiai-dev-PoCs  9f9ae728a89250c9ca9a888483c958e6f98ae03a
pkg-catalog      d63f87d2be67288ef57f4a5812fabbc3f0b24a0d
rumiai-os        bc4fd2f1ac0f2169c725a6dd2b97edd71f17a63b
rumiai-tests     12a22021fadf49250464f053700e48bcec9ad012
```

The task implementation revisions are recorded below; later unrelated/concurrent revisions do not relabel earlier validation evidence.

## Applicable canonical sources

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/STATE-MODEL.md
specifications/rumiai-os/PYTHON-RUNTIME.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
```

## Fixed task-local choices

No task-local design choice remains authoritative only through this handoff. The durable `python-env =1` contract and generic same-provider facility-command delegation rules are promoted to the current specifications.

## Completed

- Activated the former `todo/python-env-facility.md` item into this task.
- Added PoC 053 for a real micromamba 2.9.0-0 provider adapter.
- PoC run `36350610261` passed on Ubuntu 24.04 and macOS 14, proving target protection, Python/pip creation, argv preservation, stdin/stdout/stderr and child-status propagation, caller-shell isolation, remove, and Python 3.12 -> 3.13 rebuild.
- Promoted the provider-independent `python-env =1` create/run/remove contract and canonical Python-version grammar to `PYTHON-RUNTIME.md`.
- Promoted generic `facility-cmd` same-provider ordinary-package-command delegation to `PACKAGE-MODEL.md`.
- Implemented the generic delegation in `rumiai-os` commit `52068dcfc01409231c673c48291ff18147fc1056`, with affected library manuals realigned in the same commit.
- Added `facility/python-env/1` and micromamba provider realizations for Linux arm64/x86_64 and macOS arm64/x86_64 in `pkg-catalog` commits `7dcf90f1ac685e0d66d760a0c63d33f7e160ed78` and `d63f87d2be67288ef57f4a5812fabbc3f0b24a0d`.
- Added the provider-specific ordinary adapter command `micromamba-python-env`; only the facility exposes the provider-independent command `python-env`.
- Added permanent conformance, integration and live-provider tests plus focused validation scopes/workflow in `rumiai-tests` through commit `3c89e92c2a3455dc3c1e68a383d1a73ed421dc73`.
- Formal workflow run `36352268420` validated generic contract behavior on Linux x86_64, Linux arm64 and macOS and validated the real micromamba provider end-to-end on Linux x86_64.
- Final workflow run `36352612365`, attempt 2, completed successfully with the canonical Python-version grammar: all three generic contract hosts passed and the Linux x86_64 live-provider test passed against `rumiai-tests` `3c89e92c2a3455dc3c1e68a383d1a73ed421dc73` and `rumiai-os` `52068dcfc01409231c673c48291ff18147fc1056`.
- Earlier live attempts exposed HTTP 403 during unauthenticated GitHub-backed package preparation before the test ran. This is the already-known repository-authentication limitation tracked separately by `todo/github-package-repository-authentication.md`, not a `python-env` failure.
- Rechecked later `rumiai-os` provider changes through current revision: the subsequent provider modification concerns global facility-environment enumeration/status preservation and does not alter the `facility-cmd` same-concrete path validated by this task.
- Recorded the pre-existing installed-concrete metadata refresh limitation as separate deferred generic package work.

## Current state

`python-env =1` is a current provider-independent facility contract.

Its public command surface is:

```text
python-env create <environment> <python-version>
python-env run <environment> -- <command> [<arg>...]
python-env remove <environment>
```

The first provider is micromamba on the four currently published POSIX catalog streams (Linux arm64/x86_64 and macOS arm64/x86_64). Windows provider realization was not added or claimed by this task.

## Next action

None for this task.

## Blockers / open questions

None.
