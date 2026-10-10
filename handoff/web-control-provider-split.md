# Web-control provider split

Status: Active
Updated: 2026-10-10

## Goal

Maintain the validated Playwright/Chrome provider under the concrete project/package identity `pwc-web-control`, then develop an independent `electron-web-control` provider behind the same provider-neutral `web-control` facility contract. Firefox plus an extension remains a later possible experiment.

## Current repository revisions

- `rumiai-dev`: 958c3b26bb1664bd2e22f2ce5e301980f3c08838 (before this handoff commit; refresh remote HEAD on resume).
- `pwc-web-control`: `0e7cf38e72145e5e7c85ea7312e30622b73e0baf`.
- `pkg-catalog`: `dc2b47a8f39f2b5130199f8b983e2535a3e5af22`.
- `rumiai-tests`: `5a76290934563224286eea2b14eaca94aeced63e`.
- `rumiai-os`: `382369cfde55b158bdf9bb8c7c7ba352fb00ca5e`.
- `electron-web-control`: created, empty; no Git HEAD as of verification.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `handoff/README.md`, `TESTING.md`, `PHYSICAL-TESTING.md`
- `specifications/rumiai-os/WEB-CONTROL.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`, `specifications/rumiai-os/SERVICE-LIFECYCLE.md`, `specifications/rumiai-os/STATE-MODEL.md`, `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`, `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

- The provider-neutral facility, public command and service remain `web-control`; `srv start web-control` is unaffected.
- Playwright/Chrome provider project/package: `pwc-web-control`. A real renamed release starts at `v0.1.4`; older published artifacts keep the original archive names.
- Preserve the installable legacy `rumiai-web-control` package and its managed package HOME; do not automatically migrate authenticated profiles.
- Direct standalone Playwright runtime keeps its former `~/.rumiai-web-control` HOME fallback and derived Unix socket name to avoid obscuring prior standalone sessions.
- `electron-web-control` is independent and has no installable package until an implemented, released, validated provider exists.

## Acceptance scenarios

1. A previous `rumiai-web-control` installation retains its state and can still resolve original historical release assets.
2. A new `pkg install pwc-web-control` resolves the actual published release, a caller selects it through `pkg provider default web-control`, and `web-control` page/status operations and `srv` service lifecycle work.
3. The Electron provider can be implemented/tested separately against the shared compatibility-level-1 contract.

## Completed

- User renamed the original GitHub repository to `pwc-web-control` and created `electron-web-control`.
- `pwc-web-control@1462d76`: source package identity updated, version advanced to 0.1.4, README/build archive/staging paths/Actions and source test temp directory aligned. Existing standalone profile/socket fallback deliberately preserved.
- `pwc-web-control@0e7cf38`: refreshed Linux validation target to current `rumiai-os`; Actions workflow `38074326700` passed Linux `mk check/test/build`, macOS runtime checks and tests, and published `v0.1.4` with actual asset `pwc-web-control-v0.1.4-all.tar.gz`. Previous `v0.1.0`–`v0.1.3` assets retained original names.
- `pkg-catalog@7b52152`: created the new package family, preserved legacy family and provider-neutral facility contract.
- `pkg-catalog@dc2b47a`: added published v0.1.4 metadata and actual new archive regex to both new and legacy package streams (legacy remains installable even as upstream release versions advance).
- `rumiai-tests@5a76290`: renamed the external public-path integration test to `external/pwc-web-control/install-live.test`, updated package/conf references, validation selection and workflow path filter.
- GitHub Actions formal validation `38074484807` passed on Ubuntu x86_64 and ARM64 with `Scope result: VALIDATED`, including PASS of the real `external/pwc-web-control/install-live.test` on each host (no FAIL/SKIP for that test).
- Re-read the resulting diffs, GitHub release list, catalog range metadata and applicable canonical specifications. No public `web-control` command/service semantic change.

## Current state

Playwright provider rename and released package/catalog integration are complete; GitHub Actions cross-architecture validation passed. User-owned physical VM validation **has not** been executed in this chat and must not be described as physically validated. The new concrete package has its own HOME; legacy authenticated sessions remain untouched and are not automatically available from the new package.

The Electron repository remains empty and no Electron runtime/provider has been implemented. This is the next independent development responsibility.

## Next action

1. Initialize and validate an independent `electron-web-control` PoC/provider using the current `WEB-CONTROL.md` contract; do not infer that Electron eliminates Google authentication restrictions without physical evidence.
2. When the user's reference VM is available, perform physical `pkg install pwc-web-control` / provider / `srv` verification there, with deliberate profile-state separation and no automatic migration of old sessions.
3. Only publish/add an Electron catalog package after it has a real compatible release and suitable conformance evidence.

## Blockers / open questions

- User VM is not directly accessible from the current execution environment; GitHub Actions validation is strong automated evidence, not physical user-host evidence.
