# python-env facility

Status: Active
Updated: 2026-09-27

## Goal

Define, validate and implement the provider-independent `python-env` facility, with `micromamba` as the first concrete provider, without exposing micromamba-specific CLI semantics to consumers.

## Current repository revisions

```text
rumiai-dev       c36e1038244c4f242947727d6ffd592a5ffe6485
rumiai-dev-PoCs  8c0b66656c0ed8386bdefe3fd1bc45d5849e9976
pkg-catalog      168d9bfc5ffebb4ea480a8a9f96c6e394d33fe17
rumiai-os        8900544a720be8254214a13092f979f2da255662
rumiai-tests     a005991b9694eac988ce116e38b6e1a02c47feee
```

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

- Facility identity is exactly `python-env`.
- `python-env` is environment management, not a Python interpreter and not Python stdlib `venv`.
- `micromamba` is the first concrete provider.
- Python version/package selection belongs to the consumer environment definition, not the facility compatibility level.
- Initial public command contract is intentionally minimal: `create`, `run`, and `remove`.
- The consumer supplies the environment pathname; the facility does not invent state placement.
- Requirements/plugin/package policy stays with the consumer application.
- A Python-version change rebuilds the environment rather than migrating populated site-packages.

## Working design

- Implement the promoted generic `facility-cmd` `package-command<TAB><command>` realization without adding another typed part.
- The micromamba provider-specific ordinary adapter command is `micromamba-python-env`; the facility-visible command remains `python-env`, avoiding package-default/facility-default command collision.
- Publish the initial micromamba `python-env` provider only for Linux/macOS catalog streams until another platform has equivalent behavioral evidence.
- Existing installed micromamba concretes created from an older catalog snapshot are not automatically reintegrated by the current package model; this task will not invent an unrelated package-metadata migration mechanism.

## Completed

- Performed fresh preflight for all involved repositories.
- Confirmed current facility typed parts are `cmd`, `env`, and `service`.
- Confirmed the current `cmd` part can publish a provider-independent public command name but its realization currently targets an executable under provider useful root.
- Confirmed the service typed part already demonstrates same-provider delegation to an ordinary package command.
- Added PoC 053 for a real micromamba 2.9.0-0 provider adapter.
- GitHub Actions run 36350610261 passed on Ubuntu 24.04 and macOS 14. The PoC proved target protection, Python/pip creation, argv preservation, stdin/stdout/stderr and child-status propagation, caller-shell isolation, remove, and Python 3.12 -> 3.13 rebuild.
- Promoted `python-env =1` and the generic same-concrete package-command facility-cmd realization into the current specifications.

## Current state

The behavioral contract is promoted and PoC-validated. Product, catalog and permanent-test implementation are the remaining active work.

## Next action

Implement the generic facility-command delegation in `rumiai-os`, publish the micromamba `python-env` provider in `pkg-catalog`, add permanent generic and live-provider tests, then run focused Linux/macOS validation.

## Blockers / open questions

- Permanent Linux/macOS implementation validation remains.
- Windows provider realization is outside the evidence established by PoC 053 and must not be claimed by this task without additional validation.
