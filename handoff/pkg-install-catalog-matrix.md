# pkg install catalog matrix validation

Status: Active
Updated: 2026-09-18

## Goal

Validate the real public `pkg install` path against every package currently defined in `pkg-catalog`, including package-specific integration behavior rather than only simple executable installation.

## Current repository revisions

```text
rumiai-dev   d0b4d985475957a754067d68fe90852bb2ad1b6d
rumiai-os    5e47a3f0a242a57f8431fece2357532c19342cd9
rumiai-tests f8514dcabe89626eda4479dbb6866df77f920f25
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`

## Fixed task-local choices

- Exercise every current top-level package definition in `pkg-catalog`.
- Use the real public `pkg install` command and real current catalog/repository adapters.
- Verify package-specific post-install properties exposed by each catalog definition, not only command exit status.
- Correct product, catalog or permanent-test defects discovered by the matrix within this work unit when authorized by the current task.

## Completed

- Mandatory preflight completed.
- Current catalog contains: chrome, chromium, dbeaver, electron, graalvm, jq, keycloak, maven, micromamba, netbeans, nodejs, pulsar.

## Current state

Catalog definitions and current permanent package tests still need classification by provider, artifact format and integration features before constructing the execution matrix.

## Next action

Classify every current package definition and run the first exact-revision Internet-enabled matrix through the public package command.

## Blockers / open questions

None currently.
