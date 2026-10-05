# Keycloak package state mapping

Status: Active
Updated: 2026-10-05

## Goal

Determine which Keycloak installation-root paths are genuinely mutable state under the current RumiAI package model, identify Keycloak command-line/environment controls that relocate or suppress those writes, and realign the current pkg-catalog `var/` mapping only after empirical evidence.

## Current repository revisions

- rumiai-dev: 94516378d8303683cfa7c33cbe884a35e6800cf8
- rumiai-os: ea2eb22917edca77a44566ee415301f69ca61ad8
- rumiai-tests: 95f2a8568433fa88b7da4e627842b2f3d426d08d
- pkg-catalog: d63f87d2be67288ef57f4a5812fabbc3f0b24a0d
- rumiai-dev-PoCs: e7166a6b69039ab446afbad8a1d81bb276587c80

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/STATE-MODEL.md
- specifications/rumiai-os/PACKAGE-MODEL.md

## Fixed task-local choices

- Use Keycloak `start-dev` for runtime probes; production `start` is out of scope for this investigation because it requires unrelated production hostname/TLS setup.
- Use the cataloged Keycloak 26.7.3 distribution as the primary probe target.
- Treat unresolved state-location conclusions as experimental until dynamic evidence is collected.
- Use `rumiai-dev-PoCs` for the dynamic state-mapping experiment rather than adding a premature permanent test.

## Working design

- Run current `pkg-analyze` against the real upstream Keycloak distribution on an Internet-enabled GitHub Actions runner.
- Supplement pkg-analyze path deltas with content hashes because an implicit Keycloak build may modify existing files without adding/removing pathnames.
- Compare baseline `start-dev` with targeted configuration variants that can materially affect root-local state, especially database persistence and file logging.
- Distinguish runtime-created state from operator-supplied extension/customization directories such as `providers/` and `themes/`.

## Completed

- Confirmed current catalog Keycloak 26.7.3 definitions for all four supported osarch classes.
- Confirmed current catalog mapping: `var/conf -> conf` and `var/data -> data`.
- Confirmed current live test already exercises real Keycloak installation and initializes system conf/data state.
- Confirmed Keycloak supports equivalent CLI and `KC_*` environment forms, with CLI higher precedence.
- Confirmed the auxiliary ChatGPT host is Debian 13 x86_64 without direct Internet/DNS, and current testing guidance explicitly provides GitHub Actions / HTTPS bridge patterns for this case.

## Current state

The dynamic `start-dev` root-mutation experiment is ready to be implemented in `rumiai-dev-PoCs`.

## Next action

Create and run the Keycloak 26.7.3 state-mapping PoC on GitHub Actions, collect root path/hash deltas, then classify candidate `var/<area>` mappings before changing pkg-catalog.

## Blockers / open questions

- Whether `start-dev` mutates paths outside `conf/` and `data/`, especially through its implicit build.
- Whether root-local writes can/should be redirected by supported Keycloak options rather than represented through additional `var/` mappings.
- Whether operator-managed `providers/` or `themes/` require package-state treatment independently from runtime writes.
