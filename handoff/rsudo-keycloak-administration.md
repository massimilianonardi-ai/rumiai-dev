# rsudo Keycloak administration — K04 authentication

Status: Active
Updated: 2026-11-05

## Goal

Complete and validate K04 Keycloak authentication and authenticated transport through the existing rsudo SSH/sudo boundary, without modifying unrelated rsudo/APISIX behavior, before proceeding to K05 general Admin REST requests.

## Current repository revisions

- rumiai-dev: 21be0b6ce45678ea388e4ce1cfca178ec83085bf (before this checkpoint)
- rumiai-os: 7c41b9c65a2b0521cb635640ffd18719ffecfd81
- rumiai-tests: 568f11ecad918b0ae4213c429a37fd39ffd92bf2

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
- No physical host validation was performed; GitHub-hosted ARM test environments and isolated Docker SSH/sudo compose are not physical validation.

## Current state

RSA private-key-jwt RS256, RS384 and RS512 are implemented in the product, documented and validated on the exact frozen product/test pairs listed above. This is an incremental K04 result, not closure of K04. K05 general Admin REST request and K06 typed conveniences are still pending. The rsudo-keycloak macOS transport job was queued at the latest review and is not counted as PASS.

## Next action

Continue K04 with the next verified Keycloak confidential-client authentication subset (for example RSA-PSS algorithms, subject to current upstream capability and exact-policy validation), preserving the existing remote trust and protected credential boundary. Recheck the queued macOS rsudo-keycloak validation result before calling the cross-platform transport scope fully validated. Keep K05/K06 gated until their independent implementation and permanent evidence.

## Blockers / open questions

- RSA-PSS, EC/EdDSA, mTLS/X509 sender-constrained and federated JWT authenticators remain unimplemented; they need their own verified Keycloak client/server configuration and tests.
- The macOS transport validation job is pending; no PASS is claimed until it finishes.
- Full K04 authenticated Admin REST transport, non-service-account grant families and multi-host physical validation are still pending.
