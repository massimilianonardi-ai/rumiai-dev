# Centralized TLS certificate trust

Status: Active
Updated: 2026-10-23

## Goal

Deliver centrally authorized additional TLS CA trust for m-managed browsers and other TLS clients, preserving TLS verification, unrelated trust entries, browser profiles and service isolation.

## Current repository revisions

- rumiai-dev: `607896b7203d4aae1c520120bbbfa0880cb47f00` (pre-handoff update)
- rumiai-os: `5ca07aeb26dbc04c0b38998bb05edacd8587a977`
- rumiai-tests: `02eb2c25221f6d399e6ed22c6d668824fa2a8b9d`
- pkg-catalog: `5842282c1d56eb1e541e50d05ebcd19d8ccc0862`
- electron-web-control: `077eb502f1d68235b4e5c9c28e4a7560795bce17`
- pwc-web-control: `2e1759e994f52000975c6383b8cc7b229cd1b425`
- rumiai-dev-PoCs: `f31ab4f5edbef0eaaa1285e3a6ef0b5cc26df85e`

## Applicable canonical sources

- `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`
- `specifications/rumiai-os/TLS-TRUST.md`
- `specifications/rumiai-os/STATE-MODEL.md`, `PACKAGE-MODEL.md`, `WEB-CONTROL.md`
- `COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md`, `FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DIAGNOSTICS.md` for added and modified commands/libraries.

## Fixed task-local choices

- Initial CA authority and scope, administrative command semantics, Linux NSS projection and launcher integration have been promoted to `TLS-TRUST.md`. This handoff does not redefine them.
- Current user request prioritizes automatic Linux Chrome, Chromium and Electron startup synchronization before broader runtime integration.

## Acceptance scenarios

1. An administrator approves a public CA once, and real managed Linux Chrome/Chromium/Electron launchers reconcile their effective NSS HOME before browser execution.
2. Repeat launches do not duplicate entries; other NSS CA entries and client material survive; a removed CA is deleted at next sync and the restarted browser rejects its TLS chain.
3. Nested Electron packages using `m_ENV_DO_NOT_OVERRIDE=HOME` synchronize the HOME actually passed to Chromium, without sharing Web-control profiles.
4. Malformed CA, absent trusted tools, conflicting NSS nickname/ownership or unsafe state fail explicitly without disabling verification.
5. The system authority is writable only by its authorized POSIX administrator; user and service isolation is enforced in the physical deployment.

## Working design / residual decisions

- Current Linux adapter uses a per-HOME lock, a private owned-entry manifest and fingerprint-named NSS entries. No backend-specific runtime profile copy is required.
- Administrative CA add/remove currently publish/remove individual PEM files without a shared authority lock. Evaluate cross-process registry snapshot consistency and revocation races before claiming concurrent-administrator semantics.
- Host permission ownership and read access to system CA files must be confirmed for the actual service POSIX accounts; same-account execution is not an authorization boundary.
- Actual managed browser HTTP/TLS verification, NSS behavior while a browser is already running, legacy pre-existing DB compatibility and multi-host behavior remain unverified.
- macOS trust integration, Node.js process CA projection, Python/pip/Conda, curl and Java remain additional backend work in the same task.
- The existing NSS and Node PoCs supply isolated backend evidence, not end-to-end product evidence.

## Completed

- Verified current remote HEAD of all involved repositories and read the current authoritative sources before modifications.
- Implemented `bin/sys/tls-ca` with explicit public CA add/remove/list, DER SHA-256 fingerprint identity and input validation.
- Implemented `bin/sys/tls-nss-sync` with Linux NSS path selection, idempotent import/removal, owned-entry validation, no-op when unused and per-HOME Linux flock.
- Added trusted `launcher_nss` to the existing package launcher. Reconciliation happens after regular environment preparation and before exec, using effective final HOME even when inherited through the one-shot nested Electron override.
- Switched current Linux package-catalog command wrappers for chrome, chromium and electron to `launcher_nss`. Non-Linux wrappers remain unchanged.
- Added/updated command and library operational manuals. Updated the canonical TLS trust specification.
- Added permanent Linux `rumiai-os/tls-trust/contract.test` and focused `validation/tls-trust.conf` to exercise real m CA operations and NSS reconciliation, including another unrelated NSS CA.
- Verified Git diff file coverage, executable bits for new m commands and test, Git history forward-only and no unexpected files changed.
- Independently exercised basic `certutil` Linux SQL-NSS commands for empty DB creation, SSL CA trust flags, long fingerprint nickname, DER export and noninteractive deletion in the ChatGPT auxiliary environment. This is **mechanism-level evidence only**, not execution of the new m product commands.

## Current state

**Implementation committed, but NOT yet validated as a working composed m/browser feature.** The auxiliary environment cannot access a complete executable rumiai-os checkout via the available network, so no real `tls-ca`/`tls-nss-sync` run through `m`, no permanent test PASS and no real Chromium/Electron TLS acceptance/rejection have been obtained for these revisions. No corporate CA/physical network test has been performed. Do not report the feature as fully solved.

## Next action

Run focused real-product validation against the committed heads in a disposable rumiai-os environment; repair any observed issues forward. Then validate browser startup paths and end-to-end HTTPS rejection → trust → revocation for Chrome/Chromium/Electron, including nested Electron HOME. Audit concurrent authorization and physical service-account access before declaring this phase complete.

## Blockers / open questions

- An accessible complete target checkout and relevant managed browser binaries are needed to execute the real test and browser integration scenarios.
- Cross-host NSS DB configurations and corporate CA trust cannot be certified in the auxiliary Linux environment.
- Wider backend work remains active; no handoff completion is claimed.
