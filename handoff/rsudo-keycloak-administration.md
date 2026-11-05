# rsudo Keycloak administration — K04 authentication

Status: Active
Updated: 2026-11-05

## Goal

Complete and validate K04 Keycloak authentication and authenticated transport through the existing rsudo SSH/sudo boundary, without modifying unrelated rsudo/APISIX behavior, before proceeding to K05 general Admin REST requests.

## Current repository revisions

- rumiai-dev: 042343774bf6c29065fbc520431ca3decced83c4 (before this checkpoint)
- rumiai-os: b8e93e7cf297792330990b20528b1f5a9e1eed8d
- rumiai-tests: 0c3694375eae649d0f3a6db8c1a2b051df8d7432 (concurrent unrelated APISIX change after K04 tests at 22ddf02805b24f6fed7931475ae8deb9b3c90b79)

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
  - rsudo-keycloak transport + legacy, ubuntu-26.04-arm, test revision d17cb9b63e7029c44fb79645349098c77d2a5df1, same product revision, run 42029136452 (macOS job was queued at this checkpoint).
- The earlier RS256/384/512 rsudo-keycloak transport/legacy validation run 42029136452 completed PASS on both macOS and Ubuntu ARM64 for product 7c41b9c65a2b0521cb635640ffd18719ffecfd81 and suite d17cb9b63e7029c44fb79645349098c77d2a5df1.
- Implemented RSA-PSS PS256/PS384/PS512 through the existing private-key-jwt authenticator with explicit algorithm selection, remote RSA key/certificate verification, OpenSSL PSS MGF1 and digest-sized salt, preserved remote credential boundaries, RS256 default and fail-closed unsupported selections (product b8e93e7cf297792330990b20528b1f5a9e1eed8d).
- Inspected Keycloak 26.7.3 Java API PS256/PS384/PS512 client signature verifiers and independently tested OpenSSL PSS signing and verification. API evidence alone was not treated as live server certification.
- Realigned the canonical RSUDO-KEYCLOAK.md and product module manual. Added direct real-server PS256/384/512 acquisition, introspection and wrong-algorithm rejection on Keycloak 26.7.3 and 26.8.1; PS256 additionally exercised password Direct Grant, protected refresh and explicit revocation. Expanded the composed SSH/sudo and isolated HTTPS tests.
- RSA-PSS focused GitHub-hosted ubuntu-26.04-arm validation completed PASS/VALIDATED on the frozen product b8e93e7cf297792330990b20528b1f5a9e1eed8d:
  - rsudo-keycloak-live: suite 8260aaece23bee0666fa80c518ef624579400052, run 42032373697.
  - rsudo-keycloak-composed: suite 22ddf02805b24f6fed7931475ae8deb9b3c90b79, run 42032409528.
  - rsudo-keycloak isolated transport/legacy: suite d788a371ccd5e05c21c7eb41e03cf66fec0ea188, run 42032313358, Ubuntu ARM64 PASS; macOS job remained queued as last observed.
- No physical host validation was performed; GitHub-hosted ARM test environments and isolated Docker SSH/sudo compose are not physical validation.

## Current state

RSA private-key-jwt RS256/384/512 and RSA-PSS PS256/384/512 are implemented and documented, and the new RSA-PSS subset passed the isolated Linux transport, actual Keycloak and composed SSH/sudo tests on the frozen pairs above. This is an incremental K04 result, not closure of K04. K05 general Admin REST request and K06 typed conveniences remain unimplemented. The RSA-PSS transport workflow's macOS job was still queued and is not counted as PASS.

## Next action

Recheck rsudo-keycloak run 42032313358's queued macOS job and any HEAD movement; then examine the next still-pending K04 authenticator or grant family against actual Keycloak 26.7.3/26.8.1 capabilities and its trust prerequisites before extending the existing module. Keep K05/K06 gated until independently implemented and validated.

## Blockers / open questions

- EC/EdDSA, mTLS/X509 sender-constrained and federated JWT authenticators remain unimplemented; they need their own verified Keycloak client/server configuration and tests.
- The current RSA-PSS transport macOS validation job remains pending; only the earlier RSA (RS256/384/512) cross-platform transport scope has full PASS evidence.
- Full K04 authenticated Admin REST transport, non-service-account grant families and multi-host physical validation are still pending.
