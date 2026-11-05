# rsudo Keycloak administration — K04 authentication

Status: Active
Updated: 2026-11-05

## Goal

Complete and validate K04 Keycloak authentication and authenticated transport through the existing rsudo SSH/sudo boundary, without modifying unrelated rsudo/APISIX behavior, before proceeding to K05 general Admin REST requests.

## Current repository revisions

- rumiai-dev: db4ba696eb7007c3961856032cc08ad83e3cf904 (before this checkpoint)
- rumiai-os: 158f0dde31e2dc3d1665fb88312a3c8bf52815ff
- rumiai-tests: 6a64dffee92cb788d41702333f2ce3dbd46f7d58

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
  - First isolated scope failed due an existing RSA-local Python import shadowing the new EC fixture verifier's Path symbol; corrected the test fixture without modifying product behavior, then rsudo-keycloak isolated transport plus legacy PASS/VALIDATED on Ubuntu ARM64: suite 6a64dffee92cb788d41702333f2ce3dbd46f7d58, run 42036835777; macOS job was queued at last review.
- No physical host validation was performed; GitHub-hosted ARM test environments and isolated Docker SSH/sudo compose are not physical validation.

## Current state

RSA RS256/384/512, RSA-PSS PS256/384/512 and ECDSA ES256/384/512 are implemented and documented in the existing private-key-jwt subset. The RSA-PSS increment is now cross-platform validated for isolated transport; the new ECDSA increment is validated on Ubuntu ARM64 for isolated HTTPS, actual Keycloak 26.7.3/26.8.1 and composed SSH/sudo. The new ECDSA isolated macOS job is still queued, and cannot be counted as PASS. This remains partial K04; K05 general Admin REST requests and K06 typed conveniences are not implemented.

## Next action

Recheck new ECDSA rsudo-keycloak run 42036835777's queued macOS result; investigate any platform-specific failure before claiming cross-platform transport validation. Then evaluate a remaining K04 authenticator (for example EdDSA) or grant family against actual Keycloak 26.7.3/26.8.1 support and remote trust prerequisites. Keep K05/K06 gated until independently implemented and validated.

## Blockers / open questions

- EdDSA, mTLS/X509 sender-constrained and federated JWT authenticators remain unimplemented; they need their own verified Keycloak client/server configuration and tests.
- The current ECDSA isolated transport macOS job remains pending; RSA and RSA-PSS earlier transport scopes have completed macOS PASS evidence.
- Full K04 authenticated Admin REST transport, non-service-account grant families and multi-host physical validation are still pending.
