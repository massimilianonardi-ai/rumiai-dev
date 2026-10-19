# Centralized browser certificate trust

Status: Active
Updated: 2026-10-19

## Goal

Deliver an explicit, centrally managed TLS trust mechanism for RumiAI-managed browser providers without manual CA import for each package, release, profile or service instance. Preserve normal certificate verification, browser profile isolation, and revocation semantics.

## Current repository revisions

- rumiai-dev: `84eb1a799937d322c8b29abb25880fc14212a1d0` (pre-activation)
- rumiai-os: `be56b6d67d6bedb95696a303288c5620c38a4e10`
- rumiai-tests: `b1f67c7f575c3d5248701bd174f5b02b545227fc`
- pkg-catalog: `4b9ff477b28841e1b7f4367978b3023147969566`
- electron-web-control: `077eb502f1d68235b4e5c9c28e4a7560795bce17`
- pwc-web-control: `2e1759e994f52000975c6383b8cc7b229cd1b425`

## Applicable canonical sources

- `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/WEB-CONTROL.md`
- If implementing m commands/libraries: `COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md` and the applicable library specifications.

## Fixed task-local choices

- Do not disable certificate verification as a substitute for CA trust.
- Do not share browser cookies, authentication profiles, private keys or unrelated application HOME state to centralize CA trust.
- No browser trust implementation or public CLI shape is yet promoted.

## Acceptance scenarios

1. An operator explicitly authorizes a corporate root CA once for the applicable trust scope; independent managed Chromium and Electron Web providers can reach an HTTPS site signed by it without per-profile CA import by the operator.
2. The same providers reject the site before authorization and again after explicit trust removal, including after provider restart; an unrelated untrusted issuer remains rejected throughout.
3. Changing provider release or browser profile does not require repeating the authorization. Normal browser profiles and service identities remain isolated.
4. An already populated local browser certificate database or system trust store is not silently replaced or overwritten.

## Working design

- Current managed package launching deliberately assigns distinct `HOME` values; `m_ENV_DO_NOT_OVERRIDE=HOME` already addresses a nested Electron HOME mismatch, but is not centralized CA management.
- On Linux, Chromium uses an NSS shared certificate database. Chromium's current Linux certificate-management documentation reports that M146 moved the default from `$HOME/.pki/nssdb` to `$HOME/.local/share/pki/nssdb`, while continuing to use an existing legacy database. Source: https://chromium.googlesource.com/chromium/src/+/main/docs/linux/cert_management.md .
- Candidate model, **not yet approved as current contract**: one authoritative scope-appropriate set of explicitly authorized CA anchors under m-managed configuration, with browser-/host-specific trust projections. Investigate whether a common NSS database or synchronized per-package NSS databases better protects isolation, existing local entries, revocation and concurrent access; do not decide by convenience.
- Treat user, system-hosted service and POSIX account access separately. `state-path` user identity is not a security principal; do not infer security boundaries merely from state scope.
- Evaluate Linux NSS separately from macOS host trust and any non-Chromium backends; do not assume `SSL_CERT_FILE` configures Chromium.
- Investigate trusted integration at the package/provider boundary, keeping provider-specific behavior out of the generic package dispatcher. Normal callers should not need to know browser-release-specific NSS paths.
- Require explicit CA enable/disable, a reproducible trust list, no private-key import, safe ownership/permissions and clear handling of pre-existing database state.
- An isolated exploratory local CA/HTTPS probe was attempted with actual Chromium 144 and NSS certutil. NSS database initialization/import succeeded, but this auxiliary Linux Chromium exited with `GPU process isn't usable` before TLS verification; therefore it produced **no** end-to-end browser trust evidence. No corporate CA or corporate endpoint was available for physical validation.

## Completed

- Fresh HEAD preflight and current canonical source retrieval.
- Inspected both first-party Web providers, package launch environment preservation and relevant permanent launcher test.
- Confirmed upstream Chromium NSS database path change and identified the missing trust-owner/integration contract.
- Activated the dedicated task from `todo/browser-certificate-trust-centralization.md` (this commit).

## Current state

Design/implementation is open; nothing has been changed in product code, published package definitions or permanent tests. This is not a solved TLS trust problem yet.

## Next action

Settle the ownership and trust-projection model against current m state/package semantics; then implement the minimal trusted mechanism and package/provider integration, add real permanent regression tests, exercise local TLS-positive/TLS-negative/revocation scenarios and validate on the corporate network when accessible.

## Blockers / open questions

- Which scope/authority owns shared CA decisions and how service-account isolation is enforced.
- Common NSS database versus independent derived NSS projections, including pre-existing DB safety and revocation.
- Full browser TLS validation blocked in auxiliary environment by Chromium GPU process failure; physical corporate CA verification not yet performed.
