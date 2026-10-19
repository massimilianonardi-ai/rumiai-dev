# Centralized TLS certificate trust

Status: Active
Updated: 2026-10-19

## Goal

Design and deliver explicit m-managed TLS CA trust decisions reusable across browser providers and other managed TLS clients, without per-package/release/profile authorization. Keep host/native trust and client-specific adapters distinct, preserve certificate verification and account/service isolation, and make removal/revocation behavior explicit.

## Current repository revisions

- rumiai-dev: `567f82ffcc91b3659dd741a7937c562a7a27a9b8` (pre-write HEAD checked for this design checkpoint)
- rumiai-os: `f7f35e2ccd56e9c21530f94e28ee9eb5e6d82e0a`
- rumiai-dev-PoCs: `33e8ff3bfff09770164a9a2a5c7cb44f5a5b4897`
- rumiai-tests: `6523644e7c7e4932910f22ca64ec718b2a8bfb74`
- pkg-catalog: `4b9ff477b28841e1b7f4367978b3023147969566`
- electron-web-control: `077eb502f1d68235b4e5c9c28e4a7560795bce17`
- pwc-web-control: `2e1759e994f52000975c6383b8cc7b229cd1b425`


## Applicable canonical sources

- `specifications/rumiai-os/PYTHON-RUNTIME.md`, `BOOTSTRAP-ENVIRONMENT.md`, `RESOURCE-MODEL.md` when evaluating other client integrations.
- `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/WEB-CONTROL.md`
- If implementing m commands/libraries: `COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md` and the applicable library specifications.

## Fixed task-local choices

- Do not disable certificate verification as a substitute for CA trust.
- Do not share browser cookies, authentication profiles, private keys or unrelated application HOME state to centralize CA trust.
- No TLS trust implementation, trust-store-sharing topology or public CLI shape is yet promoted.

## Acceptance scenarios

1. An operator explicitly authorizes a corporate root CA once for the applicable trust scope; independent managed Chromium and Electron Web providers can reach an HTTPS site signed by it without per-profile CA import by the operator.
2. The same providers reject the site before authorization and again after explicit trust removal, including after provider restart; an unrelated untrusted issuer remains rejected throughout.
3. Changing provider release or browser profile does not require repeating the authorization. Normal browser profiles and service identities remain isolated.
4. An already populated local browser certificate database or system trust store is not silently replaced or overwritten.
5. Managed Node.js and supported Python/pip, native HTTPS clients or Java applications can consume the same approved CA decision without being forced into NSS; ordinary public CA verification is preserved.

## Working design

- Current managed package launching deliberately assigns distinct `HOME` values; `m_ENV_DO_NOT_OVERRIDE=HOME` already addresses a nested Electron HOME mismatch, but is not centralized CA management.
- On Linux, Chromium uses an NSS shared certificate database. Chromium's current Linux certificate-management documentation reports that M146 moved the default from `$HOME/.pki/nssdb` to `$HOME/.local/share/pki/nssdb`, while continuing to use an existing legacy database. Source: https://chromium.googlesource.com/chromium/src/+/main/docs/linux/cert_management.md .
- Candidate model, **not yet approved as current contract**: one authoritative scope-appropriate set of explicitly authorized public CA certificates and trust decisions under m-managed `conf` state, with non-authoritative runtime-specific projections. This is not a universal certificate database API nor an OS root-store replacement.
- Strong provisional preference: on Linux use independent NSS projections per effective package HOME/trust boundary, update only when the approved-CA set changes, and keep Chromium web profiles separate. A single writable NSS DB shared by unrelated packages/users is risky because NSS DBs may also carry client certificates and private keys. A per-profile import or unconditional full copy at every launch is unnecessary: Chromium Linux uses NSS Shared DB keyed by HOME. Investigate pre-existing NSS entries, concurrent access, rollback, ownership and both old/new NSS lookup paths before implementation.
- Linux Chromium documentation states M146 defaults to `$HOME/.local/share/pki/nssdb` but retains `$HOME/.pki/nssdb` when it exists; backend discovery must not assume one version-independent path. See https://chromium.googlesource.com/chromium/src/+/main/docs/linux/cert_management.md .
- Node.js v26 offers additive `NODE_EXTRA_CA_CERTS` at process startup and optional system trust with `NODE_USE_SYSTEM_CA`; runtime `ca` overrides can bypass both. `NODE_EXTRA_CA_CERTS` is not a Chromium/Electron certificate-trust mechanism. See https://nodejs.org/api/cli.html .
- Python is application-private through the current `python-env`/micromamba contract. pip >=24.2 on Python >=3.10 uses system certificates plus certifi by default; Requests recognizes `REQUESTS_CA_BUNDLE`; explicit CA file options commonly override defaults, so a managed PEM-only file could drop public roots. Investigate additive host trust versus merged bundles and per-application exceptions. See https://pip.pypa.io/en/stable/topics/https-certificates/ and https://requests.readthedocs.io/en/stable/user/advanced/ .
- Additional concrete m catalog clients requiring investigation: npm (Node), micromamba/Conda, m-owned `http-fetch`/curl and pkg download transport, Java/JSSE applications (Maven, Keycloak, GeoServer, NetBeans, DBeaver, Temurin/GraalVM) and other native clients (e.g. Ollama/Podman). These are runtime-specific consumers, not additional trust authorities. Java default `cacerts` and managed extensions must be merged if a derived truststore is used; do not modify immutable package payloads.
- Avoid blanket `SSL_CERT_FILE`, `REQUESTS_CA_BUNDLE` or equivalent global overrides until their replacement/addition semantics and affected consumers have been verified. Prefer native additive mechanisms where available, preserve normal public CA trust and fail explicitly when a provider cannot honor trust safely.
- Revocation in persistent services may require synchronization and restart of existing TLS runtimes, because several engines read trust only at startup. Removing an m-managed CA does not revoke the same certificate when it remains independently trusted by the host or upstream application; this limitation must be observable.
- Treat user, system-hosted service and POSIX account access separately. `state-path` user identity is not a security principal; do not infer security boundaries merely from state scope.
- Evaluate Linux NSS separately from macOS host trust and any non-Chromium backends; do not assume `SSL_CERT_FILE` configures Chromium.
- Investigate trusted integration at the package/provider boundary, keeping provider-specific behavior out of the generic package dispatcher. Normal callers should not need to know browser-release-specific NSS paths.
- Require explicit CA enable/disable, a reproducible trust list, no private-key import, safe ownership/permissions and clear handling of pre-existing database state.
- Isolated NSS projection through two independent browser databases passed repeated import, deletion and preservation of an unrelated pre-existing CA using real `certutil` and temporary self-signed roots. The experimental script and its limitations are in `rumiai-dev-PoCs/pocs/browser-certificate-trust/`; this does not demonstrate browser TLS behavior.
- An isolated exploratory local CA/HTTPS probe was attempted with actual Chromium 144 and NSS certutil. NSS database initialization/import succeeded, but this auxiliary Linux Chromium exited with `GPU process isn't usable` before TLS verification; therefore it produced **no** end-to-end browser trust evidence. No corporate CA or corporate endpoint was available for physical validation.

## Completed

- Fresh HEAD preflight and current canonical source retrieval.
- Verified current package-catalog runtime inventory and upstream Chromium, Node.js, pip, Requests, curl, Java, npm and Conda trust mechanisms; research only, not live behavior validation.
- Inspected both first-party Web providers, package launch environment preservation and relevant permanent launcher test.
- Confirmed upstream Chromium NSS database path change and identified the missing trust-owner/integration contract.
- Activated the dedicated task from `todo/browser-certificate-trust-centralization.md`.
- Committed an NSS projection experiment in `rumiai-dev-PoCs`, run with real NSS tools and OpenSSL in the auxiliary Linux environment.

## Current state

The NSS projection experiment passed but no integrated TLS trust lifecycle has been implemented. User explicitly expanded the investigation beyond Chromium-based browsers to Node.js, pip/Python and other managed clients. Runtime-specific integration remains provisional; nothing has been changed in product code, catalog or permanent tests. The trust problem is not yet solved.

## Next action

Settle the scope/authority and projection topology across Chromium NSS and non-browser TLS clients (Node, Python/pip, native HTTPS, Java), and select the first implementation slice based on genuine launch boundaries. Then implement tested, minimal adapters without broad TLS environment overrides; validate positive/negative/revocation behavior and the corporate-network case when available.

## Blockers / open questions

- Which scope/authority owns shared CA decisions and how POSIX service-account isolation is enforced; whether user/system sets compose or remain distinct.
- Exact per-runtime adapter entrypoints and which clients natively accept additive anchors versus replacing their full baseline CA set.
- How pre-existing custom trust, external host trust, and restart-required revocation should be reported without implying complete revocation of independent trust.
- Common NSS database versus independent derived NSS projections, including pre-existing DB safety, running-browser revocation and concurrent writers. The PoC confirms one isolated projection mechanism but does not settle the production design.
- Full browser TLS validation blocked in auxiliary environment by Chromium GPU process failure; physical corporate CA verification not yet performed.
