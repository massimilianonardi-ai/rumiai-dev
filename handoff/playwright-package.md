# Playwright package distribution

Status: Active
Updated: 2026-10-19 (user host validation)

## Goal

Provide an installable `pkg playwright` catalog package that exposes the official Node.js Playwright library/CLI, with version-coupled Playwright-managed Chromium rather than an implicit dependency on the separately packaged Chromium build.

## Current repository revisions

- rumiai-dev: e7c2b0a4e0d7c9cf541ca00f3d42d95f9ce153ef (pre-checkpoint HEAD)
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
- Reviewed committed diff (12 added paths). Read back all six critical package/workflow files and passed 10/10 static structural consistency checks (launcher identity, Node/Chromium environment, dependency, link, artifact pattern, pinned build and publication command).
- GitHub Actions build `39267417038` completed successfully and release `v1.63.0` now carries the expected asset and SHA-256 digest. Job logs confirm actual npm dependency installation (`added 2 packages in 1s`) and GitHub release creation.
- On 2026-10-19 the user reported an error-free, working installation on Ubuntu 26.04 ARM64; no log was supplied or run directly by the assistant.

## Current state

The catalog entry and required immutable release asset are now published. GitHub Actions build run `39267417038` finished successfully: npm installed 2 packages (Playwright and Playwright Core), checked both version=1.63.0, and published the 4,071,347-byte `playwright-v1.63.0-all.tar.gz` archive (GitHub-reported sha256 `d749d1e4327e9b4ce4b6d7667e2b071d86e10863a59292336de4e4ff8cdad759`). The user reported successful installation of the published Playwright package without errors on a real Ubuntu 26.04 ARM64 host (2026-10-19). This is user-reported host validation, not a test executed by the assistant or an independently inspected run log. The report establishes installation success on that host; it does not separately establish execution of `playwright --version`, `playwright install chromium`, a real browser launch, or external JS module imports.

## Next action

Installation succeeded according to the user's Ubuntu 26.04 ARM64 host report. Remaining distinct checks, if completing the full Playwright/browser integration scope, are `playwright --version`, `playwright install chromium`, an actual browser launch, and import of the package from an external JavaScript program.

## Blockers / open questions

- Release publication blocker resolved, and real Ubuntu 26.04 ARM64 installation success is reported by the user. Full run logs and additional browser/runtime validation are not available.
- Browser launch, browser download and module discovery by consumers outside the Playwright launcher have not been separately validated in evidence available in this conversation.
