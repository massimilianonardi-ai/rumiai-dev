# RumiAI development environment bootstrap

Status: **Current**  
Updated: 2026-09-17

`setup-dev.sh` prepares the canonical local workspace used to develop and validate RumiAI. It is development infrastructure, not part of the `rumiai-os` runtime.

## Workspace layout

With the default destination:

```text
./rumiai-os/
├── ...                         rumiai-os working tree
└── src/
    ├── rumiai-tests/           independent Git repository
    └── rumiai-dev-PoCs/        independent Git repository
```

Nested repositories are normal independent repositories, not submodules and not runtime dependencies.

`src/` is the product checkout's development anchor; its operational contents are Git-ignored by `rumiai-os`.

## Direct execution

From a `rumiai-dev` checkout:

```sh
./setup-dev.sh
```

Default product destination:

```text
$PWD/rumiai-os
```

Custom destination:

```sh
./setup-dev.sh /path/to/rumiai-os
```

## Piped execution

The bootstrap is designed to work without cloning `rumiai-dev` first:

```sh
curl -fsSL https://raw.githubusercontent.com/massimilianonardi-ai/rumiai-dev/main/setup-dev.sh | sh
```

Custom destination:

```sh
curl -fsSL https://raw.githubusercontent.com/massimilianonardi-ai/rumiai-dev/main/setup-dev.sh \
    | sh -s -- /path/to/rumiai-os
```

Interactive input is read from `/dev/tty`; standard input may contain the script itself.

## Repository handling

New clones use the canonical GitHub repositories required by this development workspace:

```text
massimilianonardi-ai/rumiai-os
massimilianonardi-ai/rumiai-tests
massimilianonardi-ai/rumiai-dev-PoCs
```

An existing destination is accepted only when it is a Git working tree whose `origin` identifies the expected repository using an accepted HTTPS/SSH form.

The bootstrap does not automatically:

```text
git pull
merge
reset/discard local work
commit
push real changes
```

Repeated execution must therefore preserve existing development state rather than silently synchronizing or destroying it.

## Git identity

The environment is not considered ready for development unless Git has an explicit usable author/committer identity.

The bootstrap validates global:

```text
user.name
user.email
```

and requires an explicit identity when they are missing/unusable.

It also configures:

```text
user.useConfigOnly=true
```

so Git does not silently synthesize identity from host/account data.

When new identity values are entered interactively, the complete proposed identity is shown and requires explicit confirmation before persistence.

A usable `$HOME` is therefore required for the global Git configuration intentionally managed by the bootstrap.

## Push capability

After repositories are available, the bootstrap checks current push authorization using a dry-run against a temporary non-created branch ref.

The probe must not create a real branch or mutate repository history.

Interactive credential prompts from child Git/SSH credential mechanisms are suppressed during the initial probe so the bootstrap can first determine whether existing credentials already work.

## Token setup

If push access is unavailable, the bootstrap may offer explicit configuration of a GitHub personal access token.

A fine-grained token should be limited to the repositories and write permissions actually required.

The token:

- is entered with terminal echo disabled;
- is not embedded in remote URLs;
- is not passed as a command-line argument;
- is supplied through the Git credential protocol;
- is cleared from the shell variable after credential approval.

## Credential storage

The preferred persistent credential helper depends on the host and installed facilities.

Current preference order:

```text
macOS
    osxkeychain
    Git Credential Manager

Windows / Git Bash
    Git Credential Manager
    wincred

Linux / WSL
    Git Credential Manager
    libsecret
```

Credential-helper configuration is local to the affected repository rather than an unsolicited global preference change.

`credential.useHttpPath=true` is used so credentials can remain repository-path-specific.

If no supported secure persistent helper exists, plaintext `credential-store` must not be selected silently; it requires explicit operator authorization.

## Security and input rules

Secrets are read from `/dev/tty` with terminal echo disabled when required.

The bootstrap must validate interactive identity input before persisting it and must not allow pasted shell text or malformed identity values to become configuration merely because they are non-empty.

The script must not invoke a package manager or install credential helpers automatically.

## Requirements

Baseline:

```text
POSIX sh
git
uname
usable HOME
```

Interactive secret entry additionally requires:

```text
stty
```

Persistent secure credential storage requires one of the supported helpers for the host.

## Testing and evidence

Permanent behavioral coverage for this bootstrap belongs in:

```text
rumiai-tests/tests/rumiai-dev/setup-dev/
```

Current validation claims must be derived from the exact `rumiai-tests` revision/evidence that exercised the relevant `setup-dev.sh` revision. Historical validation narratives are intentionally not embedded here; Git history preserves them and `rumiai-tests` owns executable/revision-specific evidence.

A documentation statement never upgrades old evidence to a later bootstrap revision.

## Invariants

```text
DEV-01  setup-dev.sh is development infrastructure, not product runtime
DEV-02  local nested repositories live under rumiai-os/src/
DEV-03  nested repositories are independent Git repositories, not submodules
DEV-04  setup does not automatically pull/reset/merge/commit/push real changes
DEV-05  explicit Git author/committer identity is required
DEV-06  user.useConfigOnly=true prevents synthesized identity
DEV-07  push probing is dry-run and non-mutating
DEV-08  secrets are not stored in remote URLs or command arguments
DEV-09  insecure credential-store fallback requires explicit authorization
DEV-10  setup does not install host software/package-manager dependencies automatically
```
