# python-env facility

Status: Active
Updated: 2026-09-27

## Goal

Define, validate and implement the provider-independent `python-env` facility, with `micromamba` as the first concrete provider, without exposing micromamba-specific CLI semantics to consumers.

## Current repository revisions

```text
rumiai-dev       8956979552f5fda2dd95cfa925f1d1742313f356
rumiai-dev-PoCs  5bcaa1b6fe1f949b446a32d68d26e486a37c55c2
pkg-catalog      168d9bfc5ffebb4ea480a8a9f96c6e394d33fe17
rumiai-os        c1aa711645b39f36850d35abc02c31d8db916120
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

- Candidate compatibility level: `python-env 1`.
- Candidate command syntax:
  ```text
  python-env create <environment> <python-version>
  python-env run <environment> -- <command> [<arg>...]
  python-env remove <environment>
  ```
- Prefer the existing `cmd` facility typed part over introducing a Python-specific typed part.
- The provider must expose a provider-independent adapter rather than alias the public `python-env` command directly to raw micromamba CLI semantics.
- Current `facility-cmd` realization points to executables inside provider useful root. Evaluate a small generic extension allowing a facility command realization to delegate to a validated ordinary command of the same provider package, analogous to the existing service-start delegation model.
- Validate the adapter first with a focused PoC covering environment creation, `python -m pip`, argument preservation (including option-like arguments), stdin/stdout/stderr, child exit status, non-persistent shell behavior, remove/recreate, and Python-version replacement.

## Completed

- Performed fresh preflight for all involved repositories.
- Confirmed current facility typed parts are `cmd`, `env`, and `service`.
- Confirmed the current `cmd` part can publish a provider-independent public command name but its realization currently targets an executable under provider useful root.
- Confirmed the service typed part already demonstrates same-provider delegation to an ordinary package command.

## Current state

The deferred TODO is activated. No product, catalog or permanent-test implementation has been changed yet.

## Next action

Create and execute the focused `python-env` adapter PoC. If it validates the agreed command contract, promote the contract and implement the generic facility-command delegation plus micromamba provider/catalog and permanent tests.

## Blockers / open questions

- Confirm the exact safe implementation of `run` without shell activation and with exact argv/status/stream behavior.
- Confirm whether the generic package-command realization extension is sufficient without adding a new facility typed part.
