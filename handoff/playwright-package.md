# Playwright package distribution

Status: Active
Updated: 2026-10-19

## Goal

Provide an installable `pkg playwright` catalog package that exposes the official Node.js Playwright library/CLI, with version-coupled Playwright-managed Chromium rather than an implicit dependency on the separately packaged Chromium build.

## Current repository revisions

- rumiai-dev: 279c219abcee4634f24fbbe9a90dc5e8bb82c95f (pre-checkpoint HEAD)
- pkg-catalog: 68b576f138400770ce1c1bd69ebf169cccc3c3df
- rumiai-os: f7f35e2ccd56e9c21530f94e28ee9eb5e6d82e0a (read-only implementation reference)
- rumiai-tests: 6523644e7c7e4932910f22ca64ec718b2a8bfb74 (read-only test reference)

Fresh HEAD retrieval is required on resume.

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- specifications/README.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- handoff/README.md

## Fixed task-local choices

- Package identity `playwright` with `all` stream; initial selected version `v1.63.0`, aligned with the active web-analyze workstream's Playwright version.
- Archive contains npm `playwright@1.63.0` and its exact `playwright-core@1.63.0` dependency, plus a `playwright` CLI entrypoint.
- Build/publish the npm dependency tree as an immutable GitHub release asset using the existing GitHub repository adapter. Do not pretend that a raw `playwright` npm tarball is self-contained.
- `nodejs =26` is the catalog dependency. Do not bind an independent `chromium` package because Playwright requires its own version-coupled browser binary for its default launch path.
- Browser installation is an explicit `playwright install chromium` command. Store browsers under the package-specific user HOME through `PLAYWRIGHT_BROWSERS_PATH`.
- Never report a functional package before the GitHub release asset and end-to-end `pkg install` / launch are verified.

## Acceptance scenarios

1. `pkg install playwright` resolves one release, checks the archive's integrity, extracts and integrates a runnable `playwright` command with Node.js dependency.
2. `playwright --version` reports the pinned library release.
3. `playwright install chromium` downloads the version-coupled browser under the package user HOME, without modifying the separately managed Chromium package.
4. Playwright launches its own browser and a JavaScript program can import the packaged module using a supported path/environment setup.

## Completed

- Preflight retrieved current remote heads for rumiai-dev, rumiai-os, rumiai-tests and pkg-catalog and consulted canonical package/testing sources.
- Official Playwright browser documentation verified: Playwright browser binaries are separately installed, selected by a Playwright-version-specific revision; external Chrome/Chromium is an optional explicit launch target.
- Added `pkg/playwright/all` definition, Node.js dependency, CLI launcher, library/browser environment and automated release-build workflow to pkg-catalog in forward commit `68b576f138400770ce1c1bd69ebf169cccc3c3df`.
- Reviewed committed diff (12 added paths). Verified after push that GitHub releases were still empty and no corresponding new Actions run was visible.

## Current state

The catalog entry is published, **but is not yet installable**: the required `playwright-v1.63.0-all.tar.gz` release asset has not appeared. The assistant container cannot reach npm registry (EAI_AGAIN), so no npm-build, browser download or composed `pkg install` validation occurred.

## Next action

Verify workflow registration/execution, fix and run release publication if necessary; then verify release artifact name/digest, perform a genuine `pkg install playwright`, `playwright --version`, `playwright install chromium` and a real browser launch on a supported host. Inspect any resulting integration mismatch and synchronize this handoff.

## Blockers / open questions

- GitHub Actions release build has not yet been observed executing after the catalog commit. GitHub connector currently exposes read APIs for workflow runs but no workflow dispatch in this session.
- End-to-end execution on the user's supported host is pending; module discovery by consumers outside the Playwright launcher needs explicit validation before claiming reusable JS import behavior.
