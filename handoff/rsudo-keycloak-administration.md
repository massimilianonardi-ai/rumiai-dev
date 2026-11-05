# rsudo Keycloak administration — K04 authentication

Status: Active
Updated: 2026-11-05

## Goal

Complete and validate K04 Keycloak authentication and authenticated transport through the existing rsudo SSH/sudo boundary, without modifying unrelated rsudo/APISIX behavior, before proceeding to K05 general Admin REST requests.

## Current repository revisions

- rumiai-dev: 0fc4f906344ea7c3666b1575b3e9c162b7a26a1f (pre-handoff)
- rumiai-os: ea73873adf75cfbcd54fc46dd4ef31280127b222
- rumiai-tests: 8c7f84a7db7e4244917f193619c90ecffb4906bf

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
- Unrelated concurrent advances to rumiai-dev and rumiai-tests were detected and their changed paths checked; no current Keycloak source conflicts were identified.

## Current state

The RSA private-key-jwt implementation and tests currently support RS256 only. K04 remains partial. Prior test evidence refers to earlier frozen revisions and does not validate any future change.

## Next action

Extend the protected RSA private-key-jwt assertion path to RS384 and RS512 without changing its trust and storage boundaries; update its public contract, manual and permanent isolated/real-server tests; run proportionate formal validation before accepting the extension. Then address remaining K04 authenticator families separately.

## Blockers / open questions

- No live server validation exists yet for any new RSA algorithm at the revisions to be changed.
- Remaining asymmetric families, sender-constrained mTLS/X509 and federated JWT authenticators, and enterprise trust/host validation remain outside this immediate RSA increment.
