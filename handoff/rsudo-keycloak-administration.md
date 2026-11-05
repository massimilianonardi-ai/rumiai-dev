# rsudo Keycloak administration — K04 authentication

Status: Active
Updated: 2026-11-05

## Goal

Complete and validate K04 Keycloak authentication and authenticated transport through the existing rsudo SSH/sudo boundary, without modifying unrelated rsudo/APISIX behavior, before proceeding to K05 general Admin REST requests.

## Current repository revisions

- rumiai-dev: bbbba67e21775e1c2aadda6060e17b37f662c5bd (before this checkpoint; Keycloak canonical contract remains at b46ad0ef808c837ad3d17e8e456e00e0204b0372)
- rumiai-os: 461f4baf8c6f010a2891d104f0a58a0a69e06abf (Keycloak manual safety clarification; no implementation change)
- rumiai-tests: 63a8703a25d6c19b39006e9b937a2ab27ded58ed (real Keycloak self-signed RFC 8705 registration/provider evidence, validated run 42090626130)

Recheck all live remote HEADs and reconcile forward before each write/validation.

## Applicable canonical sources

- README.md; RULES.md; CONSISTENCY-GATE.md; TESTING.md
- specifications/README.md
- specifications/rumiai-os/RSUDO.md
- specifications/rumiai-os/RSUDO-KEYCLOAK.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- specifications/rumiai-os/DIAGNOSTICS.md

## Fixed task-local choices

- Preserve the existing 16 legacy Keycloak forwarding operations and their compatibility boundary.
- Reuse the single existing Keycloak rsudo module; private credentials remain on the sudo target and are not carried as argument values, stdout or logs.
- Never infer a server, grant or client authenticator or silently change the explicitly selected JWT signing algorithm.
- Continue K04 incrementally; do not present K05 or K06 as implemented.

## Acceptance scenarios

- An operator with a registered confidential Signed JWT client and protected matching remote key/certificate can acquire, inspect, refresh when issued and revoke a token through rsudo while selecting an explicitly supported signing algorithm.
- Wrong algorithm, untrusted certificate, mismatched key, unsafe paths or failed server authentication fail closed without credential disclosure or unintended store replacement.
- The same public flows pass against real isolated Keycloak 26.7.3 and 26.8.1, including composed SSH/sudo where applicable; evidence identifies exact product/suite revisions.

## Completed

- Existing K04 code supports confidential-client Basic/Post, HS256/384/512 secret-signed assertions and RSA RS256 private-key assertions; operator-authenticated direct grant, refresh, revoke and introspection subsets exist.
- Current remote preflight completed on 2026-11-05, with project/specification retrieval and inspection of the relevant module, manual, transport tests and real-server tests.
- Unrelated concurrent advances to rumiai-dev, rumiai-os and rumiai-tests were reconciled forward without overwriting their changes.
- Implemented explicit RSA RS384 and RS512 client assertion support alongside existing RS256 in the same Keycloak rsudo module, preserving protected remote key/certificate handling, no secret value in argv, verified JWT audience and algorithm fail-closed behavior (rumiai-os 7c41b9c65a2b0521cb635640ffd18719ffecfd81).
- Realigned the module manual and canonical RSUDO-KEYCLOAK.md, and added targeted permanent transport, actual Keycloak and composed SSH/sudo Keycloak scenarios.
- The initial live and composed tests found an overly strict new assertion that the introspection active field must be true; Keycloak returned exit 0 with a valid boolean result. The new tests were corrected to the already-established boolean-field contract.
- Focused validation PASS/VALIDATED on actual Keycloak 26.7.3 and 26.8.1, ubuntu-26.04-arm:
  - rsudo-keycloak-live, test revision 9a397c34e0b54e73b9d2ce1d366decae3806876a, product 7c41b9c65a2b0521cb635640ffd18719ffecfd81, run 42029919807.
  - rsudo-keycloak-composed, test revision 568f11ecad918b0ae4213c429a37fd39ffd92bf2, same product revision, run 42029948367.
  - rsudo-keycloak transport + legacy, ubuntu-26.04-arm and macOS PASS, suite d17cb9b63e7029c44fb79645349098c77d2a5df1, same product revision, run 42029136452.
- Implemented RSA-PSS PS256/PS384/PS512 through the existing private-key-jwt authenticator with explicit algorithm selection, remote RSA key/certificate verification, OpenSSL PSS MGF1 and digest-sized salt, preserved remote credential boundaries, RS256 default and fail-closed unsupported selections (product b8e93e7cf297792330990b20528b1f5a9e1eed8d).
- Inspected Keycloak 26.7.3 Java API PS256/PS384/PS512 client signature verifiers and independently tested OpenSSL PSS signing and verification. API evidence alone was not treated as live server certification.
- Realigned the canonical RSUDO-KEYCLOAK.md and product module manual. Added direct real-server PS256/384/512 acquisition, introspection and wrong-algorithm rejection on Keycloak 26.7.3 and 26.8.1; PS256 additionally exercised password Direct Grant, protected refresh and explicit revocation. Expanded the composed SSH/sudo and isolated HTTPS tests.
- RSA-PSS focused GitHub-hosted ubuntu-26.04-arm validation completed PASS/VALIDATED on the frozen product b8e93e7cf297792330990b20528b1f5a9e1eed8d:
  - rsudo-keycloak-live: suite 8260aaece23bee0666fa80c518ef624579400052, run 42032373697.
  - rsudo-keycloak-composed: suite 22ddf02805b24f6fed7931475ae8deb9b3c90b79, run 42032409528.
  - rsudo-keycloak isolated transport/legacy: suite d788a371ccd5e05c21c7eb41e03cf66fec0ea188, run 42032313358, Ubuntu ARM64 and macOS PASS.
- Extended the same private-key-jwt branch to ECDSA ES256/ES384/ES512 with exact P-256/P-384/P-521 key-curve validation, RSA-vs-EC key-family rejection, OpenSSL ECDSA signing and local signature verification, and DER-to-fixed-width JWS signature conversion using the remote Python 3 standard library; default remains RS256. Key/certificate protected remote boundaries and absence of algorithm fallback are preserved (product 158f0dde31e2dc3d1665fb88312a3c8bf52815ff).
- Realigned the canonical Keycloak spec and owner-local module manual; added isolated independent P1363/DER HTTPS verification and wrong-curve/key-family failure tests; created and registered real Keycloak ECDSA clients with curve-matching certificates for both 26.7.3 and 26.8.1; composed tests exercised the actual SSH/sudo path with remote protected EC keys.
- Focused ECDSA validations on frozen product 158f0dde31e2dc3d1665fb88312a3c8bf52815ff:
  - rsudo-keycloak-live PASS/VALIDATED on Ubuntu ARM64: suite fc65bc8b8648842dad30d4ff26ba20d1c1be7e34, run 42035686734.
  - rsudo-keycloak-composed PASS/VALIDATED on Ubuntu ARM64: suite 51eac214eb6a878b6f96a857ca16ee425e86b8ea, run 42035769812.
  - First isolated scope failed due an existing RSA-local Python import shadowing the new EC fixture verifier's Path symbol; corrected the test fixture without modifying product behavior. rsudo-keycloak isolated transport plus legacy PASS/VALIDATED on Ubuntu ARM64 and macOS: suite 6a64dffee92cb788d41702333f2ce3dbd46f7d58, run 42036835777.
- Implemented explicit EdDSA Signed JWT authentication with Ed25519 key/certificate only in the existing protected remote private-key-jwt path (product c6cf9b57e5e6b9877ea20243aa5217cf87a92c45). The actual public key type is checked before signing; Ed448, RSA and EC are not silently accepted under the EdDSA algorithm. OpenSSL pkeyutl signs and independently verifies the raw JWS message; only the 64-byte Ed25519 signature is encoded in the private temporary client assertion. Original RS256 default, remote file permissions, non-disclosure and no fallback remain unchanged.
- Updated the canonical RSUDO-KEYCLOAK specification and module manual together with the implementation. Added independent HTTPS Ed25519 signature verification and negative key-family coverage, actual Keycloak 26.7.3 and 26.8.1 Signed JWT EdDSA client registration and authentication, and composed real SSH/sudo credential staging and assertion.
- Focused Ed25519 validation on frozen product c6cf9b57e5e6b9877ea20243aa5217cf87a92c45:
  - rsudo-keycloak-live PASS/VALIDATED, Ubuntu 26.04 ARM64, suite f88b258f854262c3997da5819854e4236f540f30, run 42042336408 (service-account acquire/status, Ed448 and RSA-identifier rejection).
  - rsudo-keycloak-live PASS/VALIDATED with additional user-password acquisition, protected refresh, refresh-token revocation and unregistered Ed25519 certificate rejection on both Keycloak versions: suite 1a3b29eee2594911784d59c8a942e2385ae4b5c6, run 42043079201.
  - rsudo-keycloak-composed PASS/VALIDATED through real SSH/sudo, Ubuntu 26.04 ARM64, suite ca7aec56378620b5a206466a2eefb775c5941d8d, run 42042747776.
  - rsudo-keycloak isolated HTTPS/legacy PASS/VALIDATED on Ubuntu 26.04 ARM64 and macOS-latest, suite 83f91cbba375ae54e12c4f64dab451d78c487d70, run 42042536926. The Ed25519 subset is capability-conditional; the published macOS session's test log contained no skipped-Ed25519-backend marker, establishing that Ed25519 was exercised there rather than silently credited from other transport subcases.
- Added explicit X.509 `tls-client-auth` (Keycloak `client-x509`) for client-credentials, enabled Direct Access Grant, online status/introspection, protected refresh and explicit revocation. The remote sudo target verifies certificate/private-key correspondence using OpenSSL before discovery. Remote curl sends only protected certificate and key paths with `--cert`/`--key` on every HTTPS request; no JWT/secret fallback, proxy, redirect or unsafe TLS override (product 0883a781c02f67b080c8ca9f43792ec208c68ebc). The same checked asymmetric keypair logic is reused by private-key-jwt.
- The Keycloak test configuration explicitly enables `https-client-auth=request` with a dedicated mTLS CA truststore; registered confidential `client-x509` clients require the exact subject DN and trust-anchor CA subject DN. The HTTPS server certificate's `--ca-file` remains separate from the OAuth client CA. Keycloak 26.7.3 and 26.8.1 independently accept the expected client and reject a different subject DN; mismatched key/certificate is rejected before authentication.
- Current focused X509 validation, all frozen product 0883a781c02f67b080c8ca9f43792ec208c68ebc:
  - `rsudo-keycloak-live` PASS/VALIDATED Ubuntu ARM64, suite 48d26b99c260c6908ea255d8b9fd661a9053764d, run 42047931155; Keycloak 26.7.3/26.8.1 acquire/status and negative identity/key mismatch.
  - `rsudo-keycloak-live` PASS/VALIDATED Ubuntu ARM64, suite ab45f151ff33214b93d35a09e72377318fd387a0, run 42049404392; additionally enabled password Direct Grant, protected refresh and explicit refresh-token revocation on both Keycloak versions.
  - `rsudo-keycloak-composed` PASS/VALIDATED Ubuntu ARM64, suite 1637405a40e565ccf7b2eb3e5baed9f74de2496f, run 42048292983; actual SSH/sudo, remote certificate/key and real Keycloak 26.7.3/26.8.1, acquisition/status and wrong-subject rejection.
  - `rsudo-keycloak` isolated HTTPS/legacy PASS/VALIDATED Ubuntu ARM64, suite 562a7b06a1303e5a1314ee2af96fe5426bb58cb5, run 42048677854; macOS workflow was queued at last observation.
- The earlier X509 isolated workflow 42048677854 completed Ubuntu PASS but macOS FAIL: the actual failure was an existing RS256 request returning TLS status 75 after the HTTPS fixture had begun requesting optional client certificates. The isolated transport test was revised to use separate standard TLS and mTLS listeners; this preserves the ordinary RSA/JWT handshake semantics and subjects only the mTLS cases to certificate requests. The corrected isolated scope PASS/VALIDATED on Ubuntu ARM64: suite 9e01cd9df5e971dc5537a22b9d969caa61092130, run 42052273959; macOS pending at last check.
- Extended only the existing *private* K04 fixed read-only Admin REST probe, not K05, with an explicitly selected `--client-auth tls-client-auth` plus remote `--private-key-file` and `--certificate-file`. The remote sudo target validates file ownership/mode/symlink-free paths and public key correspondence before contacting the issuer; the same certificate is presented for HTTPS OIDC discovery and fixed realm GET via curl file-path arguments. Missing/implicit/mismatched certificate selection fails closed; bearer token and Admin response stay private (product af128698dd6044d00b424f10ff846393fcd32e29, owner-local manual fa0805d2653c0b6c65066060bb47842fd64bd608).
- Added an independent HTTPS fixture endpoint requiring both a selected bearer and the matching mTLS client identity for the private fixed Admin probe. The wrong/missing client cert, key mismatch, and accidental credential selection are rejected, while the original bearer-only path and JWT regressions remain intact. The isolated scope PASS/VALIDATED on Ubuntu ARM64: suite 7ed94e82395ff8c05a243b16928b07e411b7b824, product af128698dd6044d00b424f10ff846393fcd32e29, run 42052944188. The macOS matrix was queued at last check; the previous failure cannot be counted resolved on macOS until this new scope completes.
- Real Keycloak 26.7.3/26.8.1 fixed Admin GET with explicitly selected X509 credentials and an unprivileged service token preserved the expected 403, while a mismatched certificate was rejected locally with status 70: `rsudo-keycloak-live` PASS/VALIDATED Ubuntu ARM64, suite 676ac873d96c942411a48b16567210db47e33409, frozen product c7ff8bdec0c45d0a11513698638d94d76053a0f4, run 42053270583.
- Actual composed SSH/sudo and Keycloak 26.7.3/26.8.1 passed the same protected fixed GET / forbidden response and wrong-certificate proof: `rsudo-keycloak-composed` PASS/VALIDATED Ubuntu ARM64, suite fb8402a3b37f99f276d318a9f6c0f8e871ceabd5, frozen product c7ff8bdec0c45d0a11513698638d94d76053a0f4, run 42053359024.
- Important boundary: neither an optional TLS client cert nor a legitimate HTTP 403 independently proves that the Keycloak Admin REST API enforces `cnf.x5t#S256` certificate-binding for bearer tokens. Real binding enforcement and the general K05 request API remain separate pending work. No physical host validation was performed; GitHub-hosted ARM test environments and isolated Docker SSH/sudo compose are not physical validation.

- Inspected completed rsudo-keycloak diagnostic workflow 42072611910: on macOS the selected native curl 8.7.1 used SecureTransport and LibreSSL 3.3.6. The module's X509 acquire failed with status 75 and an independent real client-certificate HTTPS probe failed with curl 35; Ubuntu ARM64 passed. Curl's documented SecureTransport client identity requires PKCS#12 or keychain, not the separate PEM certificate/key inputs selected by the current K04 module.
- Provisioned an actual OpenSSL-backed Homebrew curl in the GitHub Actions macOS focused scope (rumiai-tests 9a6806a0bcaa819717eff7faf12aced3dbf18d44). Validation 42076121536 completed SUCCESS on macOS and Ubuntu ARM64 against frozen rumiai-os 063d6868c33e43e9a8185cb57d6830031efe364d. Both legacy-modules.test and keycloak-auth-transport.test passed on macOS with real TLS. This evidence is conditional on compatible curl, not native SecureTransport compatibility or physical-host validation.
- Removed the duplicate failure-only HTTPS diagnostic probe while retaining nonsecret selected curl backend provenance in keycloak-auth-transport.test (rumiai-tests fa4b6e96a9d777068f8940d0f5239d670f3d833e). Focused validation 42076656057 later completed SUCCESS on both Ubuntu ARM64 and macOS with OpenSSL-backed curl for the cleaned suite revision.
- Documented the current X509 remote PEM-capable curl prerequisite, SecureTransport limitation and absence of automatic private-key format/keychain export in RSUDO-KEYCLOAK.md (rumiai-dev 1279dd0dac7769be0faec57cc832649857bf8554) and the owner-local manual (rumiai-os 8ae78944ef5e8d6297c50898d856db1a20c6fd9a). No product Keycloak implementation or authentication protocol was changed.

- Extended the existing official-container Keycloak live test without modifying product code. It now verifies X509 refresh with a different valid client key/certificate is rejected while leaving the protected token store identical and without a stale refresh lock; it independently verifies that the token endpoint rejects an uncredentialed direct refresh with invalid_client. It also records whether OIDC discovery advertises the distinct RFC 8705 self_signed_tls_client_auth method without treating discovery as runtime certification. Frozen suite 5675ed30e34b6ac795134965a5c8b6b2dd5c88d0, product 461f4baf8c6f010a2891d104f0a58a0a69e06abf, GitHub-hosted Ubuntu ARM64 run 42087913118 PASS/VALIDATED for actual Keycloak 26.7.3 and 26.8.1 (session validation/20261105T184941+0000-6159). Neither version advertised self_signed_tls_client_auth; runtime support remains independently unverified. No physical validation.

- Independently tested RFC 8705 self-signed client registration on official Keycloak 26.7.3 and 26.8.1, retaining the PKI X509 positive path. The test first authenticated an admin principal, inspected the actual loaded client authenticator factories (client-x509 present; self_signed_tls_client_auth absent), and positively registered a standard OIDC client through the same dynamic registration endpoint. An RFC-conformant separate self-signed RSA certificate plus real public JWK (n, e, x5c) with token_endpoint_auth_method=self_signed_tls_client_auth was rejected with HTTP 400 in both versions. The OIDC discovery documents also did not advertise this method. This is runtime evidence that the tested stock configurations do not offer that client authenticator through OIDC registration, not a claim about custom provider extensions or arbitrary deployments. No access-token flow can be certified for a registration that is rejected; the rsudo self-signed mode remains unimplemented. Frozen tests 63a8703a25d6c19b39006e9b937a2ab27ded58ed, product 461f4baf8c6f010a2891d104f0a58a0a69e06abf, GitHub Actions Ubuntu ARM64 run 42090626130 PASS/VALIDATED (session validation/20261105T190903+0000-6310). No product code or manual change, no physical-host validation.

## Current state

K04 remains partially implemented; the 16 legacy operations are preserved. macOS isolated X509 transport is validated with an OpenSSL-backed curl, including the cleaned-suite run 42076656057 (PASS on macOS and Ubuntu ARM64). Real Keycloak 26.7.3 and 26.8.1 emitted JWTs with the expected certificate thumbprint. The selected Admin REST realm GET did not enforce the certificate binding, whereas the OIDC UserInfo endpoint did enforce it. The latter behavior was established with a separately requested openid-scope token. See rsudo-keycloak-live runs 42084364414 (suite ba16f9ea5) and 42085862336 (suite c80b2dab5, product 461f4baf). The canonical Keycloak specification and product manual were clarified in b46ad0ef and 461f4baf. No product module code changed. The real-server K04 X509 wrong-identity and missing-identity refresh rejection paths also PASS on both 26.7.3/26.8.1, with no protected-store replacement. Both stock Keycloak releases also lack a self_signed_tls_client_auth provider in the live client-authenticator registry and reject its fully formed RFC 8705 dynamic client registration (HTTP 400 after a successful standard registration control); self-signed remains unsupported in those exact test configurations, but a custom provider or different configuration is not excluded. K05/K06 and physical reference-host validation remain pending.

## Next action

Continue K04 with a real federated-JWT validation of provider availability, the feature gate CLIENT_AUTH_FEDERATED (observed in upstream Keycloak 26.7.3/26.8.1 source), an isolated external assertion issuer and its actual trust/identity-provider registration. Do not equate source presence or provider listing with a valid grant, and do not implement the module method before a successful and negative real-provider scenario. RFC 8705 self-signed client authentication cannot currently proceed via stock registration on the two tested versions; reassess only with independently confirmed server capability. Preserve the proven distinction between OIDC token binding and Admin REST authorization. Do not describe the existing private Admin GET as sender-constrained; any such protection requires an independently verified resource-side enforcement contract. Keep K05/K06 gated.

## Blockers / open questions

- Ed448, `self-signed-tls-client-auth`, federated JWT, full mTLS certificate-bound Admin REST enforcement proof and other grant families remain pending; they need independently verified Keycloak client/server trust and protocol evidence.
- Native macOS SecureTransport remains incompatible with the selected PEM client-identity path. A compatible curl passed the cleaned macOS test suite 42076656057. Physical reference-host validation remains unperformed.
- Full K04 authenticated Admin REST transport, non-service-account grant families and multi-host physical validation are still pending.
