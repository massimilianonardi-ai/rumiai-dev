# Centralized TLS certificate trust

Status: Active
Updated: 2026-10-19

## Goal

Deliver a centrally authorized, securely projected additional TLS CA trust mechanism for managed browser and non-browser clients of `m`, without TLS verification bypass or cross-service/session state sharing.

## Current repository revisions

- rumiai-dev: `a67a59d488adaa1d50b0e49b63ce1ed8d5e98c51` (pre-handoff checkpoint)
- rumiai-os: `f7f35e2ccd56e9c21530f94e28ee9eb5e6d82e0a`
- rumiai-tests: `6523644e7c7e4932910f22ca64ec718b2a8bfb74`
- pkg-catalog: `4b9ff477b28841e1b7f4367978b3023147969566`
- electron-web-control: `077eb502f1d68235b4e5c9c28e4a7560795bce17`
- pwc-web-control: `2e1759e994f52000975c6383b8cc7b229cd1b425`
- rumiai-dev-PoCs: `853391e4b10a71d4f9d77d2134887abb968c18c2`

## Applicable canonical sources

- `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`
- `specifications/rumiai-os/TLS-TRUST.md` — promoted security/authority/trust contract
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/WEB-CONTROL.md`
- `specifications/rumiai-os/PYTHON-RUNTIME.md`
- For command/library development: `COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md`, `FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DIAGNOSTICS.md`.

## Fixed task-local choices

- Authority and initial system-only visibility have been promoted to `TLS-TRUST.md`; do not reinterpret `state-path user` as a POSIX principal.
- Implementation/API names, schema, backend orchestration and package integration are **not** yet promoted.

## Acceptance scenarios

1. One explicit system CA authorization permits independent managed Chromium/Electron and Node clients to establish TLS to a server signed by that CA, while untrusted issuers remain rejected.
2. Removing that authorization causes owned projections and restarted managed clients to reject that server again; unrelated public CA trust and local NSS entries remain intact.
3. Package/release/profile changes do not require operator reauthorization and neither browser profiles nor service credentials become shared.
4. An untrusted service or package cannot modify the system CA authority by virtue of consuming it; unauthorized and malformed imports fail safely.
5. Python/pip and other supported consumers can use an appropriate additive or merged CA projection, not an additional-only file masquerading as a complete default bundle.

## Working design

- Admin interface and persisted registry revision/manifest design remain open. Must verify certificate CA status and private-key absence, safe ownership/writes, collision handling, concurrent writers/readers, atomic publication, restart observation and recovery.
- Linux Chromium NSS: database location changed at M146; existing `$HOME/.pki/nssdb` wins over modern `$HOME/.local/share/pki/nssdb` when present. Project safely within each effective browser HOME, never by blind per-profile copying. Pre-existing NSS entries, concurrent access and revocation while browser runs still need robust implementation.
- Managed `electron-web-control` uses `m_ENV_DO_NOT_OVERRIDE=HOME` on nested Electron runtime launch. Preserve that behavior and do not mistake Node PEM trust for the Chromium browser trust backend.
- Node.js: additive `NODE_EXTRA_CA_CERTS` is read at process startup. An existing application-requested extra CA file cannot be silently overwritten; compose safely or report incompatibility. Actual `pkg`/service integration has not been implemented.
- Other backends: pip/Requests, `http-fetch` and download transport, micromamba/Conda, Java/JSSE and native applications must be evaluated with respect to whether custom CA options add to or replace normal roots. Do not globally export replacement variables.
- macOS host trust is not the same as Linux NSS; platform-specific projection requires validation. External host trust and live process restarts limit what revocation can guarantee.

## Completed

- Verified fresh current remote HEADs and read current canonical contracts and active handoff.
- Promoted `specifications/rumiai-os/TLS-TRUST.md` with system-only CA authority, independent runtime projections, no TLS bypass and explicit revocation semantics. Updated `specifications/README.md` router.
- Confirmed existing NSS projection PoC with two independent certutil databases remains experiment-only.
- Added `rumiai-dev-PoCs/pocs/browser-certificate-trust/tests/node-extra-ca.mjs` and updated its README.
- Ran the corresponding Node/OpenSSL localhost HTTPS test in auxiliary Linux on 2026-10-19: Node 22.16.0 / OpenSSL 3.5.5 PASS for rejection → explicit PEM CA trust → rejection with CA removed; `node --check` also PASS. This tests Node's backend behavior only and does not prove `m` package integration.
- No product code, package catalog definition or permanent `rumiai-tests` test changed in this checkpoint.

## Current state

The authority/visibility boundary is now binding in the current specification. Browser and Node integration are **still not implemented**. NSS experiment and Node TLS experiment provide backend-level evidence; the corporate CA and real browser verification remain untested.

## Next action

Implement the secure authoritative CA registry and explicit administrator-facing interface in `rumiai-os`, with its operational manual and real permanent tests, respecting `TLS-TRUST.md`. Then integrate the smallest complete consumer slice (Node launch and Linux NSS providers), validate full TLS positive/negative/revocation through real managed launch paths, and expand backend coverage deliberately.

## Blockers / open questions

- Registry/admin CLI concrete API, atomic multi-writer implementation and safe permissions enforcement remain to be designed and tested.
- No real browser HTTPS evidence yet: auxiliary Chromium previously exited with `GPU process isn't usable`.
- No physical test with the real corporate CA/network; do not infer corporate validation.
