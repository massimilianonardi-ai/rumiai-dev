# RumiAI current specification index

Status: **Current**  
Updated: 2026-09-17

This directory contains **current contracts only**. Historical specifications and superseded decisions are intentionally absent from the current tree and remain available through Git history.

Read only the smallest complete set relevant to the task.

## RumiAI OS / m

| Topic | Canonical current source |
|---|---|
| overall `m` / RumiAI architecture, layer ownership, top-level layout | `rumiai-os/CURRENT-MODEL.md` |
| root bootstrap, environment, PATH, branded activation | `rumiai-os/BOOTSTRAP-ENVIRONMENT.md` |
| physical bootstrap/command root resolution | `rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md` |
| command/runtime classification and shebangs | `rumiai-os/COMMAND-ENTRYPOINTS.md` |
| controlled filesystem naming and internal library naming | `rumiai-os/FILESYSTEM-NAMING.md` |
| POSIX portability and host-specific abstraction boundary | `rumiai-os/POSIX-PORTABILITY-LAYER.md` |
| state scopes, selectors, owners, areas, `state-path`, package HOME/state | `rumiai-os/STATE-MODEL.md` |
| package subsystem ownership, public surface and launch/integration invariants | `rumiai-os/PACKAGE-MODEL.md` |
| static/global resources | `rumiai-os/RESOURCE-MODEL.md` |
| documentation ownership, initial terminal-first operational model, long-term multi-channel target | `rumiai-os/DOCUMENTATION-MODEL.md` |
| technical localization facility `lang` | `rumiai-os/LANG-BOOTSTRAP.md` |
| source materialization through `mk` | `rumiai-os/MK-SOURCE-MATERIALIZATION.md` |
| portable local service lifecycle through `srv` | `rumiai-os/SERVICE-LIFECYCLE.md` |
| standalone terminal key input | `rumiai-os/READ-KEY.md` |

## Testing and development

Testing contracts intentionally remain top-level because they are project-wide and are part of the mandatory preflight for many tasks:

```text
TESTING.md
RUNNER.md
PHYSICAL-TESTING.md
TEST-PATTERNS.md
```

Development workspace/bootstrap:

```text
DEVELOPMENT.md
setup-dev.sh
```

## Reading rules

- A file not listed here is not automatically a current normative source.
- Do not search Git history unless historical rationale/evidence is specifically needed.
- If a current specification conflicts with the current implementation, surface the mismatch; do not silently treat the old implementation as a new contract.
- If a current contract changes, update the canonical file listed here rather than adding a parallel decision document that readers must merge mentally.
- Package definitions themselves live in `pkg-catalog`; implementation details live in `rumiai-os`; permanent mechanical coverage lives in `rumiai-tests`.
