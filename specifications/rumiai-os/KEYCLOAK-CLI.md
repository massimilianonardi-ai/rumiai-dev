# Direct Keycloak shell administration command

Status: **Current / normative**
Updated: 2026-11-06

## Scope and ownership

The technical `m` command `bin/sys/keycloak` provides a small,
operator-facing HTTPS administration interface that does not require rsudo,
SSH/sudo, Chromium/CDP, a callback server, a remote agent, or an installed
Keycloak server package. It is invoked as `m keycloak admin ...` from an
uninitialized environment or `keycloak admin ...` after m activation.

The existing installed **Keycloak server package command** uses the same
public basename. To preserve its normal lifecycle and the package launcher
contract, all invocations **without** the literal `admin` subcommand are
delegated unchanged to `$m_BIN_EXT_DIR/keycloak`. This includes
`keycloak start-dev`, `build` and other upstream server operations.
If that package command is absent, a non-admin invocation fails with status 9.
The new direct administration interface must never replace the package's
`cmd/keycloak` or bypass its launcher/state/dependency semantics.

The older `rsudo keycloak` implementation remains an independent,
unchanged compatibility surface. No new work on that interface is implied by
this specification.

## Operator-visible interface

```text
keycloak admin [options] discovery
keycloak admin [options] get|post|put|delete /admin/RESOURCE [--data-file JSON-FILE]
```

Global options precede the action:

- `--server HTTPS-URL`: required server base URL, optionally including a
  reverse-proxy base path; credentials in URL, fragment, query and HTTP
  are rejected.
- `--realm NAME`: required token-issuing realm, not implicitly the target
  administration realm.
- `--username USER` plus `--password-file LOCAL-FILE`: explicitly
  selected Keycloak Direct Access Grant, using `admin-cli` when the client
  ID is omitted. Requires the actual server/client/user grant policy to
  allow the flow. A browser/MFA/IdP login is **not** simulated or bypassed.
- `--client-id ID` and `--client-secret-file LOCAL-FILE`: explicitly
  selected confidential service-account `client_credentials` grant;
  roles and permissions must already be assigned in Keycloak.
- `--token-file LOCAL-FILE`: use an existing bearer value instead of
  any grant. No automatic refresh, token printing or credential downgrade.
- `--ca-file LOCAL-PEM`: explicit CA for curl peer verification.
- `--data-file JSON-FILE`: optional input to POST/PUT, validated as JSON.
- `--help`: display the administration interface help.

Environment equivalents are `KEYCLOAK_SERVER`, `KEYCLOAK_REALM`,
`KEYCLOAK_USERNAME`, `KEYCLOAK_PASSWORD_FILE`,
`KEYCLOAK_CLIENT_ID`, `KEYCLOAK_CLIENT_SECRET_FILE`,
`KEYCLOAK_TOKEN_FILE` and `KEYCLOAK_CA_FILE`.
An explicit option overrides its corresponding environment value. No
password, client secret or bearer is accepted as a command-line value.

`discovery` exposes the requested realm's public OIDC metadata. Other
actions obtain a fresh access token (or consume the caller-selected existing
token) and perform exactly **one** Admin REST operation. The resource path
must begin with `/admin/`; it is resolved relative to the server base.
Queries and resource-specific JSON are caller-selected. The command does
not fabricate provider schemas, role assignments, mutation safety or
success statuses.

## Credentials, transport and output

Secret/token files are local, owner-owned, nonsymlink regular files with
owner-only mode 0400, 0500, 0600 or 0700. Each contains one nonempty
line; an optional final newline is stripped before OAuth form submission.
Secrets and bearer headers are staged as owner-only ephemeral files, read
by curl from files, and removed on exit. No secret values are placed in
ordinary process argv, success output or diagnostic messages.

Transport uses HTTPS with normal peer verification, optional approved CA,
disabled redirect following and HTTPS protocol restriction. `curl` ignores
personal config files for these operations. Non-2xx Admin REST responses
return a nonzero status without printing their response bodies; successful
Admin REST response bodies are sent to stdout as explicitly requested
operator data, which may itself be sensitive. No authentication token is
printed automatically.

The command depends on POSIX shell, `curl`, `jq`, `mktemp` and the
host's compatible file-permission inspection tool. No persistent session
cache, local browser, device grant, PKCE callback, privileged SSH target or
server-side role elevation is implicit.

## Exit status

```text
0   success
1   missing initialized m environment
2   invalid arguments or JSON input
3   required dependency absent
4   local protected credential, CA or temporary-file failure
5   OIDC HTTPS transport failure
6   OIDC endpoint refusal or malformed access-token response
7   Admin REST HTTPS transport/output failure
8   non-success Admin REST HTTP response
9   existing Keycloak package launcher unavailable
```

The revision-matched operator manual is `rumiai-os/res/sys/manual/keycloak`.
Permanent tests exercise `m keycloak admin` through a disposable verified
HTTPS fixture and official isolated Keycloak releases, plus package-command
delegation and denial of unauthorized administrative access. Report
validation results only with their frozen revisions, logs and execution scope.
