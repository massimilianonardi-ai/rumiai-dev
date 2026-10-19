# RumiAI OS — Managed TLS CA trust

Status: **Current / normative**  
Updated: 2026-10-19

## Purpose and authority

`m` owns authorization and distribution of **additional public TLS certificate-authority (CA) trust** for managed clients. It does not replace the host operating-system trust store, TLS validation, the existing state model or package-owned application configuration.

The initial authoritative trust scope is **system**. Approved CA certificates and their authorization decisions belong to the technical system configuration resolved by:

```text
state-path system sys tls conf
```

The system profile selector determines which configuration is current. Administrative authorization is enforced by trusted operations and filesystem ownership/permissions, **not** merely by calling the state `system`. Consumers can read the public anchors when authorized by host permissions but do not gain write authority by consuming them. A managed service must not be allowed to modify its trusted CA set simply by being able to use that set.

There is **no implicit user-scope CA overlay** in this initial contract. `state-path user ...` is not an authenticated POSIX identity: neither its default binding nor the `user/current` symbolic link authorizes trust additions. A future per-user authority requires a separately defined authenticated identity and access-control contract.

## Trust semantics

- Additional CA trust is explicitly approved, never inferred from an HTTPS failure, downloaded certificate, package installation, browser profile or inherited `HOME`.
- The authority and its projections contain only public CA certificates and authorization metadata, never private keys, client identities, browser cookies or application profiles.
- Certificates must be parsed and checked for CA capability and applicable constraints before approval. A certificate is identified by the fingerprint of its certificate bytes, not by nickname or subject. Reapproval of the same identity can be idempotent; an identity collision or incompatible content must fail. Unsafe filesystem permissions and malformed or key-bearing inputs must not be silently accepted.
- The runtime's normal public CA baseline must remain available. A *replacement* truststore or bundle must not receive only the additional approved CAs.
- Trust integration must not disable HTTPS/TLS verification (`ignoreHTTPSErrors`, `NODE_TLS_REJECT_UNAUTHORIZED=0`, certificate-error bypass flags or permissive verification callbacks).
- Changes and revocations are deterministic, auditable and idempotent. Partially published, stale or tampered projections must not be mistaken for the current authorized revision. Readers and concurrent administrators must not observe a falsely complete registry revision.

## Consumers and security contexts

An explicitly integrated managed client uses the current `system` approved CA set. This can include regular managed packages and system-hosted package services, subject to real POSIX filesystem access controls. Service State Instances continue to control per-service package `home` and `conf`, and a shared CA set does **not** share their authentication state or client certificates.

Clients that do not participate in this integration and programs launched outside the selected `m` environment are not reconfigured implicitly. Existing host CA trust, upstream runtime-specific CA configuration and explicit application overrides remain distinct authorities. An `m` removal cannot revoke certificates that remain independently trusted elsewhere.

## Derived representations

The managed CA set is one authoritative decision represented in whatever **non-authoritative derived projection** each supported TLS backend requires. Browser profile creation, package version changes and runtime updates must not require repeating CA authorization.

On Linux, Chromium-family browsers use an NSS Shared DB under their effective `HOME`, independently from individual browser navigation profiles. The adapter must identify the browser's effective NSS lookup path (including the modern and legacy lookup rules), preserve unrelated pre-existing NSS entries and private key material, and remove only entries demonstrably owned by the projection. Separate package/service HOMEs must not be coupled by pointing them at one writable shared NSS database.

For Node.js, `NODE_EXTRA_CA_CERTS` is a process-startup mechanism for *additional* PEM trust. Node-specific integration must not silently discard caller/application CA customizations, or assume that Node's extra CA setting automatically configures Chromium/Electron browser TLS. The application may expressly override Node trust through its TLS `ca` option.

Other runtimes, including Python/pip, curl/OpenSSL, micromamba/Conda and Java, require verified, backend-specific integration. Blindly assigning global `SSL_CERT_FILE`, `REQUESTS_CA_BUNDLE` or replacement Java truststores can discard public anchors and is not a valid universal projection. Provider-specific work belongs at the trusted runtime integration boundary, not as one-off logic in the generic `pkg` dispatcher.

## Revocation and lifecycle

Removing an approved CA removes the `m` authorization and requires owned projections to converge while preserving unrelated data. Engines that cache trust at startup may require process restart or browser recreation; a database rewrite alone does not prove an already running process stopped trusting a CA. Such pending restarts and independently held external trust must be observable rather than treated as successful revocation.

`STATE-MODEL.md` remains authoritative for all state path semantics. `PACKAGE-MODEL.md` and `WEB-CONTROL.md` remain authoritative for package launch, HOME, service and profile behavior.

## Implementation status

These are binding trust design constraints, **not proof that any runtime already implements the mechanism**. Integrated support must be established by current product code and real test evidence before it is claimed.
