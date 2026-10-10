# Web-control provider split

Status: Active
Updated: 2026-10-10

## Goal

Maintain the verified Playwright/Chrome browser provider, with the concrete project/package identity `pwc-web-control`, and develop `electron-web-control` independently behind the same provider-neutral `web-control` facility. Firefox with an extension remains a possible later experiment.

## Current repository revisions

- `rumiai-dev`: 87d6cbac57b0d0163fc6265837a00281e71ebcf5 (before this handoff update; verify HEAD on resume).
- `pkg-catalog`: 7b52152dfcf68856acd5ed914092f956bc88fb17.
- `pwc-web-control`: 8ed3ab888ecdc4970d90a6f14f0d7b7b93fce122.
- `electron-web-control`: repository created, empty at verification (no commit HEAD).
- `rumiai-os`: 382369cfde55b158bdf9bb8c7c7ba352fb00ca5e.
- `rumiai-tests`: 345ef3837e3184058453789e78b46344b2a665b9.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `handoff/README.md`
- `specifications/rumiai-os/WEB-CONTROL.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`, `specifications/rumiai-os/SERVICE-LIFECYCLE.md`, `specifications/rumiai-os/STATE-MODEL.md`
- Read further current command, package, test and manual contracts as required by each implementation step.

## Fixed task-local choices

- Playwright/Chrome provider project and concrete package: `pwc-web-control`.
- Alternative Electron project: `electron-web-control`. No Electron package until a real suitable release and conformance evidence exist.
- Portable command, service and facility: `web-control`.
- Preserve earlier `rumiai-web-control` package data for installed old versions and original named release artifacts; changing package identity must not silently repoint or mutate authenticated profile state.

## Acceptance scenarios

1. A legacy installation of `rumiai-web-control` retains access to its original package-owned profile and published release artifact.
2. A new `pkg install pwc-web-control` installation can use the `web-control` facility after an explicit provider selection and exercise `web-control status` / `srv start web-control` unchanged. New package-owned state is separate unless explicitly migrated.
3. The Electron project can evolve and be validated independently, without prematurely advertising a working package.

## Completed

- User renamed the GitHub repository `rumiai-web-control` to `pwc-web-control` and created `electron-web-control`; both repository identities verified through GitHub. The Electron repository was empty.
- GitHub releases `v0.1.0`–`v0.1.3` verified on the renamed Playwright repository, with original `rumiai-web-control-v…-all.tar.gz` artifact names.
- `pkg-catalog@7b52152`: added the `pwc-web-control/all` package with matching release range metadata, dependency and `web-control` command/service facility realization. Kept `pkg/rumiai-web-control` for legacy installs and pointed its upstream repository descriptor at the renamed GitHub repository. Provider-neutral `facility/web-control` untouched.
- `rumiai-dev@87d6cba`: updated canonical `WEB-CONTROL.md` current concrete provider identities.
- Structural catalog/metadata and remote GitHub release checks completed, and committed diff reviewed. Physical `pkg install pwc-web-control` / service execution is **not yet validated**.

## Current state

Catalog alignment and canonical specification naming are complete. The existing Playwright provider source under its renamed repository still uses the old `rumiai-web-control` package.json, release/archive directory naming and README; existing test files and workflows still refer to the legacy package. These are an explicit **pending realignment**, not evidence that a new-named release has been built.

Changing the package name changes its managed package HOME/state identity. The catalog retains the old package; it does not migrate sessions automatically.

## Next action

1. Within a separately authorized provider-source phase, align Playwright source/release/test/documentation naming with `pwc-web-control`; use new artifact patterns only for actually published future releases.
2. Validate the newly declared catalog package via the public `pkg install pwc-web-control` path on a real RumiAI OS host, then verify facility binding, `srv` lifecycle and provider state preservation/migration options before retiring any legacy path.
3. Initialize `electron-web-control` with an independent implementation and conformance tests; publish a package only once it has actual compatible artifacts.

## Blockers / open questions

- Public-path install/service validation has not been run from this chat (no local RumiAI OS checkout / VM process access).
- The Playwright source/tests still contain old provider naming; this is outside the catalog-only work unit and requires forward realignment.
