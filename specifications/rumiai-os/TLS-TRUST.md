# RumiAI OS — Managed TLS CA trust

Status: **Current / normative**  
Updated: 2026-10-23

## Purpose and authority

`m` manages authorization and distribution of **additional public TLS CA trust** for explicitly integrated clients; it does not replace the host operating-system trust store, existing TLS verification or application-specific credentials. The authoritative approval set for each **registered selected system profile** is resolved through `state-path system sys tls conf` under that profile. Selection is validated by the managed context registry/envelope, not by an unchecked `system/current` symlink or a caller's HOME value.

**CA authorization and CA consumption are different responsibilities.** Approval and revocation use the actual POSIX ownership/permissions of the selected protected system configuration. No `context` operand, logical `user` selection, account-preference record or inherited environment value grants permission to add/remove approved CAs. A host service consumes the set associated with its separately registered profile and cannot follow another interactive shell's new profile. There is no implicit `state/user` CA overlay or authentication mapping.

## Trust semantics

- Additional CA trust is explicitly approved, never inferred from an HTTPS failure, downloaded certificate, package installation, browser profile or inherited `HOME`.
- The authority and its projections contain only public CA certificates and authorization metadata, never private keys, client identities, browser cookies or application profiles.
- Certificates must be parsed and checked for CA capability and applicable constraints before approval. A certificate is identified by the fingerprint of its certificate bytes, not by nickname or subject. Reapproval of the same identity can be idempotent; an identity collision or incompatible content must fail. Unsafe filesystem permissions and malformed or key-bearing inputs must not be silently accepted.
- The runtime's normal public CA baseline must remain available. A *replacement* truststore or bundle must not receive only the additional approved CAs.
- Trust integration must not disable HTTPS/TLS verification (`ignoreHTTPSErrors`, `NODE_TLS_REJECT_UNAUTHORIZED=0`, certificate-error bypass flags or permissive verification callbacks).
- Changes and revocations are deterministic, auditable and idempotent. Partially published, stale or tampered projections must not be mistaken for the current authorized revision. Readers and concurrent administrators must not observe a falsely complete registry revision.

## Consumers and security contexts

An explicitly integrated managed client consumes only the approved CA set of its **verified effective system profile**, using `state-path system sys tls conf` from its validated context and the applicable runtime/backend projection. Distinct profiles must not be silently unioned. Host-supervised clients remain bound to their authorized registration profile, not the current profile of an unrelated caller. Clients outside the managed `m` environment are unaffected.

Existing host CA anchors, independent client/trust overrides, TLS validation and package/service State Instance credentials remain separate. Removing an `m`-approved CA cannot revoke that same CA when trusted independently elsewhere. If a backend cannot safely resolve a selected profile, it must reject that launch/synchronization rather than silently trust the global profile.

## Current system CA management interface

The technical `tls-ca` command operates on the selected `system sys tls conf`
authority and has these operations:

```text
tls-ca add <one-public-ca.pem>
tls-ca remove <sha256-fingerprint>
tls-ca list
```

An approved certificate is stored under the existing managed `conf` state by
its lowercase SHA-256 DER fingerprint. Imports validate CA capability and
reject private-key input. A second import of the identical certificate is
idempotent. Removal targets only the specified approved identity; removal
does not imply revocation of independent host trust or running-process caches.

The administrative interface does not confer privilege on its caller:
permission to modify system trust is granted by the actual POSIX security
boundary protecting the selected system-state tree.

## Generalized-context profile consumption boundary

The generalized-context runtime passes its already validated system profile to `state-path`. `tls-ca` reads/writes the corresponding profile's protected `sys/tls/conf/ca` set; `tls-nss-sync` consumes that exact set for the effective browser HOME and verifies its owned NSS projection. Both accept an effective real registered profile root as well as the legacy symlink selector when validated by their owning resolver; direct symlink-only assumptions are not a legitimate reason to reject a selected registered profile.

The CLI is still `tls-ca add`/`remove`/`list`, with host ownership determining who can write. The CA projection does not become an alternate privilege API, and ordinary context activation itself never approves a certificate. On Linux browser consumers, synchronization is requested by the trusted package launcher immediately before exec; no supported Windows/macOS NSS projection is implied. The actual cross-profile browser and protected-authority positive paths require exact-revision validation, not presumption based on a context fixture. Privileged host trust operations remain in `todo/m-os-operator-privileged-validation.md`.

## Derived representations

The managed CA set is one authoritative decision represented in whatever **non-authoritative derived projection** each supported TLS backend requires. Browser profile creation, package version changes and runtime updates must not require repeating CA authorization.

On Linux, Chromium-family browsers use an NSS Shared DB under their effective `HOME`, independently from individual browser navigation profiles. The adapter must identify the browser's effective NSS lookup path (including the modern and legacy lookup rules), preserve unrelated pre-existing NSS entries and private key material, and remove only entries demonstrably owned by the projection. Separate package/service HOMEs must not be coupled by pointing them at one writable shared NSS database.

On Linux, the `chrome`, `chromium` and `electron` package launchers
request `tls-nss-sync` after normal package HOME and environment preparation,
immediately before executing the browser. The sync uses the final effective
`HOME`, including a trusted one-shot override for nested Electron. It maintains
a manifest of only m-owned NSS entries and uses a per-HOME lock; absence of both
approved anchors and past m-owned entries is a no-op. Verification or
reconciliation failure blocks browser launch rather than bypassing TLS.

For Node.js, `NODE_EXTRA_CA_CERTS` is a process-startup mechanism for *additional* PEM trust. Node-specific integration must not silently discard caller/application CA customizations, or assume that Node's extra CA setting automatically configures Chromium/Electron browser TLS. The application may expressly override Node trust through its TLS `ca` option.

Other runtimes, including Python/pip, curl/OpenSSL, micromamba/Conda and Java, require verified, backend-specific integration. Blindly assigning global `SSL_CERT_FILE`, `REQUESTS_CA_BUNDLE` or replacement Java truststores can discard public anchors and is not a valid universal projection. Provider-specific work belongs at the trusted runtime integration boundary, not as one-off logic in the generic `pkg` dispatcher.

## Revocation and lifecycle

Removing an approved CA removes the `m` authorization and requires owned projections to converge while preserving unrelated data. Engines that cache trust at startup may require process restart or browser recreation; a database rewrite alone does not prove an already running process stopped trusting a CA. Such pending restarts and independently held external trust must be observable rather than treated as successful revocation.

`STATE-MODEL.md` remains authoritative for all state path semantics. `PACKAGE-MODEL.md` and `WEB-CONTROL.md` remain authoritative for package launch, HOME, service and profile behavior.

