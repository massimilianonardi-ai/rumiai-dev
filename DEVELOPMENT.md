# RumiAI development environment bootstrap

`setup-dev.sh` creates the canonical local workspace used to develop and validate RumiAI.

The script is intentionally independent from the product runtime. It lives in `rumiai-dev`, clones the product repository first, and then places development-only repositories under the ignored `.dev/` workspace of `rumiai-os`.

## Layout

With the default destination the resulting layout is:

```text
./rumiai-os/
├── ...                         rumiai-os working tree
└── .dev/
    ├── rumiai-tests/           independent Git repository
    └── rumiai-dev-PoCs/        independent Git repository
```

The nested repositories are normal independent Git repositories. They are not submodules and are not runtime dependencies of `rumiai-os`.

## Direct execution

From a checkout of `rumiai-dev`:

```sh
./setup-dev.sh
```

The default `RumiAI_ROOT` is:

```text
$PWD/rumiai-os
```

A different destination can be supplied as the only positional argument:

```sh
./setup-dev.sh /path/to/rumiai-os
```

## `curl | sh`

The bootstrap is designed to be usable without first cloning `rumiai-dev`:

```sh
curl -fsSL https://raw.githubusercontent.com/massimilianonardi-ai/rumiai-dev/main/setup-dev.sh | sh
```

A custom destination can be passed to the shell:

```sh
curl -fsSL https://raw.githubusercontent.com/massimilianonardi-ai/rumiai-dev/main/setup-dev.sh \
    | sh -s -- /path/to/rumiai-os
```

Interactive input is read from `/dev/tty`, not standard input. This is necessary because in the piped form standard input contains the script itself.

On Windows this form assumes a POSIX-compatible shell environment such as Git Bash. WSL is detected as Linux and uses the Linux credential policy.

## Git identity

The bootstrap assumes that Git may have been freshly installed and therefore does not assume any pre-existing global author identity.

Before cloning repositories, `setup-dev.sh` checks the explicit global values:

```text
user.name
user.email
```

A usable name must contain at least one non-whitespace character and must not contain angle brackets. A usable email must have a minimal `local@domain` form and must not contain whitespace, angle brackets or multiple `@` characters. This is deliberately a conservative operational validation rather than a complete RFC email parser.

If either value is missing or unusable, the script requests the replacement through `/dev/tty`. It then displays the complete proposed identity:

```text
name <email>
```

and requires explicit confirmation before writing any newly requested identity value to global Git configuration. This prevents an accidental pasted shell command from silently becoming `user.name` or `user.email`.

The bootstrap also configures:

```text
user.useConfigOnly=true
```

This prevents Git from silently synthesizing an author or committer identity from the local operating-system username and hostname. A development environment is not considered correctly configured if Git cannot construct both `GIT_AUTHOR_IDENT` and `GIT_COMMITTER_IDENT` from the explicit configuration.

A usable `$HOME` is therefore required because the bootstrap intentionally verifies and, when necessary, writes global Git configuration.

The script does not impose unrelated global preferences such as `init.defaultBranch`, editor choice, pull strategy or line-ending policy. Those settings are not prerequisites of the RumiAI development workspace.

## Repository handling

The bootstrap uses HTTPS clone URLs for new clones:

```text
https://github.com/massimilianonardi-ai/rumiai-os.git
https://github.com/massimilianonardi-ai/rumiai-tests.git
https://github.com/massimilianonardi-ai/rumiai-dev-PoCs.git
```

If a destination already exists, the script requires it to be a Git working tree whose `origin` identifies the expected repository. Existing HTTPS or SSH origins are accepted.

New `git clone` processes receive standard input from `/dev/null`. This is intentional: in the `curl | sh` form standard input contains the bootstrap itself and must never be consumed by a child Git process.

The script does not automatically run `git pull`, merge branches, reset working trees, discard local changes, create commits or push changes.

This makes repeated execution safe with respect to existing development state.

## Push capability check

After the repositories are available, the script checks whether the current Git authentication can perform a push.

The check uses:

```text
git push --dry-run
```

toward a temporary, non-created branch ref. The check therefore exercises push authorization without creating a branch or changing remote repository state.

Interactive credential prompts from Git, SSH and Git Credential Manager are disabled during this probe so that the script can first determine whether credentials are already usable.

A successful generic dry-run confirms that the current credentials can perform that push operation. Repository rules or branch protection can still impose additional restrictions on particular refs or operations.

## Access token setup

If push access is unavailable for one or more repositories, the script asks whether the developer wants to configure a GitHub personal access token.

A fine-grained personal access token is recommended. It should grant access only to the repositories the developer needs and should include:

```text
Repository permissions -> Contents: Read and write
```

The token is entered with terminal echo disabled. It is never added to a Git remote URL and is never passed as a command-line argument.

The token is handed to Git through the standard credential protocol using:

```text
git credential approve
```

After storage, the shell variable containing the token is cleared and push capability is checked again.

Secure token entry requires `stty`. The script checks for it only when token entry is actually required.

## Credential storage policy

The bootstrap chooses a persistent credential helper according to the host and installed helpers.

Preferred order:

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

The selected helper is configured locally in the affected repository rather than changing the user's global Git credential policy.

`credential.useHttpPath=true` is also configured locally so the stored credential is keyed by the repository path and does not unnecessarily replace credentials for unrelated GitHub repositories.

If no supported secure persistent helper is available, the script does not silently downgrade security. It explains the situation and asks explicitly whether `git credential-store` may be used. That helper stores credentials in plaintext and should only be selected knowingly.

## Physical validation

The bootstrap was physically exercised on the two stable reference hosts on 2026-08-29 using the piped `curl | sh` form and an explicit `RumiAI_ROOT`.

### macOS

Observed successfully:

- clone of `rumiai-os`;
- creation of `.dev/`;
- clone of `rumiai-tests` and `rumiai-dev-PoCs` in the canonical layout;
- dry-run push verification on all three repositories;
- successful completion when existing Git credentials already provide write access.

Because valid credentials were already present, the interactive PAT configuration path and the `osxkeychain` storage path were not exercised in this run.

### Ubuntu 26.04 ARM64

Observed successfully:

- clone of all three repositories in the canonical layout;
- initial detection of unavailable push access;
- interactive confirmation through `/dev/tty` while the script itself was supplied on standard input;
- username and PAT input, including non-echoed token entry;
- detection that no supported secure helper was installed;
- explicit user authorization before falling back to `git credential-store`;
- storage through `git credential approve`;
- successful dry-run push verification for all three repositories after credential configuration;
- successful completion of the bootstrap.

The Ubuntu run validates the explicit insecure-fallback path, not the preferred Git Credential Manager or `libsecret` paths.

### Git identity hardening discovered during validation workflow

A later physical workflow exposed that the original bootstrap had not verified global Git author identity:

- on macOS Git automatically synthesized a committer identity from the local username and hostname and emitted a warning;
- on Ubuntu 26.04 ARM64 a commit failed because neither global `user.name` nor `user.email` was configured.

This showed that clone and push capability alone were insufficient to declare a development environment ready. The bootstrap was therefore hardened to require explicit global identity and `user.useConfigOnly=true` before repository setup.

### Isolated clean-Git-home exercise

The identity bootstrap was then exercised physically on both stable hosts with a temporary empty `$HOME` and a temporary workspace, leaving the real user configuration and canonical repositories untouched.

On both macOS and Ubuntu 26.04 ARM64 the successful run demonstrated:

- an initially empty global Git configuration;
- detection of missing `user.name` and `user.email`;
- interactive collection through `/dev/tty` while the script arrived through standard input;
- persistence of the supplied identity in the temporary global `.gitconfig`;
- `user.useConfigOnly=true`;
- successful `GIT_AUTHOR_IDENT` and `GIT_COMMITTER_IDENT` construction;
- a real temporary Git commit with the expected author and committer;
- successful clone of `rumiai-os`, `rumiai-tests` and `rumiai-dev-PoCs` into the temporary workspace;
- complete cleanup of the isolated test environment.

Because the isolated `$HOME` intentionally hid normal user authentication and the operator declined PAT setup in these runs, the isolated exercise ended in the supported read-only state. The PAT/storage path had already been physically exercised on Ubuntu in the earlier bootstrap validation.

During the first Ubuntu isolated attempt, an operator paste error supplied the shell command `cd /m/src/git/rumiai-os` at the `Git user.email` prompt. The then-current bootstrap accepted any non-empty string, exposing an input-validation gap. A subsequent clean rerun with the intended identity succeeded. The implementation was therefore hardened again to validate the minimal shape of both identity fields and require explicit confirmation of the full proposed identity before persisting newly requested values.

The validation/confirmation hardening must be physically exercised after its publication before this specific input-safety path is considered closed.

## Requirements

The bootstrap requires:

```text
POSIX sh
git
uname
HOME suitable for Git global configuration
```

For interactive secret token input it also requires:

```text
stty
```

For persistent secure token storage it additionally requires one of the supported credential helpers appropriate for the host.

No package manager is invoked automatically and the script does not install system software or credential helpers on behalf of the developer.
