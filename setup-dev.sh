#!/bin/sh

set -u

GITHUB_HOST=github.com
GITHUB_OWNER=massimilianonardi-ai
RUMIAI_OS_REPO=$GITHUB_OWNER/rumiai-os
RUMIAI_TESTS_REPO=$GITHUB_OWNER/rumiai-tests
RUMIAI_POCS_REPO=$GITHUB_OWNER/rumiai-dev-PoCs

say() {
    printf '%s\n' "$*"
}

warn() {
    printf 'warning: %s\n' "$*" >&2
}

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

have() {
    command -v "$1" >/dev/null 2>&1
}

tty_available() {
    [ -r /dev/tty ] && [ -w /dev/tty ]
}

ask_yes_no() {
    tty_available || return 1
    printf '%s [y/N] ' "$1" >/dev/tty
    IFS= read -r answer </dev/tty || return 1
    case $answer in
        y|Y|yes|YES|Yes) return 0 ;;
        *) return 1 ;;
    esac
}

prompt_text() {
    prompt=$1
    tty_available || return 1
    printf '%s' "$prompt" >/dev/tty
    IFS= read -r REPLY </dev/tty
}

prompt_secret() {
    prompt=$1
    tty_available || return 1
    have stty || return 1
    old_stty=$(stty -g </dev/tty 2>/dev/null) || return 1
    RUMIAI_BOOTSTRAP_STTY=$old_stty
    trap 'stty "$RUMIAI_BOOTSTRAP_STTY" </dev/tty >/dev/null 2>&1 || :' 0
    trap 'stty "$RUMIAI_BOOTSTRAP_STTY" </dev/tty >/dev/null 2>&1 || :; exit 130' HUP INT TERM
    stty -echo </dev/tty || return 1
    printf '%s' "$prompt" >/dev/tty
    IFS= read -r REPLY </dev/tty
    read_status=$?
    printf '\n' >/dev/tty
    stty "$old_stty" </dev/tty >/dev/null 2>&1 || :
    trap - 0 HUP INT TERM
    RUMIAI_BOOTSTRAP_STTY=
    return "$read_status"
}

global_git_value() {
    git config --global --get "$1" 2>/dev/null || printf ''
}

valid_git_name() {
    case $1 in
        *[![:space:]]*) : ;;
        *) return 1 ;;
    esac
    case $1 in
        *'<'*|*'>'*) return 1 ;;
    esac
    return 0
}

valid_git_email() {
    case $1 in
        ''|*[[:space:]]*|*'<'*|*'>'*|@*|*@|*@*@*) return 1 ;;
        *@*) return 0 ;;
        *) return 1 ;;
    esac
}

ensure_git_identity() {
    [ -n "${HOME:-}" ] || die 'HOME is required for Git global configuration'

    git_user_name=$(global_git_value user.name)
    git_user_email=$(global_git_value user.email)
    configure_name=0
    configure_email=0

    if ! valid_git_name "$git_user_name"; then
        if [ -n "$git_user_name" ]; then
            warn 'global Git user.name is not usable as an explicit identity'
        else
            warn 'Git global author identity is incomplete'
        fi
        tty_available || die 'a controlling terminal is required to configure Git user.name'
        prompt_text 'Git user.name: ' || die 'cannot read Git user.name'
        git_user_name=$REPLY
        valid_git_name "$git_user_name" || die 'Git user.name must contain a non-whitespace name without angle brackets'
        configure_name=1
    fi

    if ! valid_git_email "$git_user_email"; then
        if [ -n "$git_user_email" ]; then
            warn 'global Git user.email is not a usable email address'
        elif [ "$configure_name" -eq 0 ]; then
            warn 'Git global author identity is incomplete'
        fi
        tty_available || die 'a controlling terminal is required to configure Git user.email'
        prompt_text 'Git user.email: ' || die 'cannot read Git user.email'
        git_user_email=$REPLY
        valid_git_email "$git_user_email" || die 'Git user.email must have the form local@domain with no whitespace or angle brackets'
        configure_email=1
    fi

    if [ "$configure_name" -eq 1 ] || [ "$configure_email" -eq 1 ]; then
        say ''
        say "Proposed Git identity: $git_user_name <$git_user_email>"
        ask_yes_no 'Use this Git identity globally?' || die 'Git identity configuration cancelled'

        if [ "$configure_name" -eq 1 ]; then
            git config --global user.name "$git_user_name" || die 'cannot configure global Git user.name'
        fi
        if [ "$configure_email" -eq 1 ]; then
            git config --global user.email "$git_user_email" || die 'cannot configure global Git user.email'
        fi
    fi

    # Never allow Git to invent an identity from the local account/hostname.
    git config --global user.useConfigOnly true || die 'cannot require explicit Git identity'

    git_user_name=$(global_git_value user.name)
    git_user_email=$(global_git_value user.email)
    valid_git_name "$git_user_name" || die 'global Git user.name is not usable'
    valid_git_email "$git_user_email" || die 'global Git user.email is not usable'

    git var GIT_AUTHOR_IDENT >/dev/null 2>&1 || die 'Git cannot construct an author identity from the configured values'
    git var GIT_COMMITTER_IDENT >/dev/null 2>&1 || die 'Git cannot construct a committer identity from the configured values'

    say "Git identity: $git_user_name <$git_user_email>"
}

expected_origin() {
    printf 'https://%s/%s.git\n' "$GITHUB_HOST" "$1"
}

origin_matches_repo() {
    remote=$1
    repo=$2
    case $remote in
        "https://$GITHUB_HOST/$repo"|"https://$GITHUB_HOST/$repo.git"|\
        "git@$GITHUB_HOST:$repo"|"git@$GITHUB_HOST:$repo.git"|\
        "ssh://git@$GITHUB_HOST/$repo"|"ssh://git@$GITHUB_HOST/$repo.git")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

clone_or_validate() {
    repo=$1
    dest=$2

    if [ -e "$dest" ]; then
        [ -d "$dest/.git" ] || die "$dest exists but is not a Git repository"
        remote=$(git -C "$dest" remote get-url origin 2>/dev/null) || die "$dest has no origin remote"
        origin_matches_repo "$remote" "$repo" || die "$dest origin is '$remote', expected $repo"
        say "using existing $dest"
        return 0
    fi

    parent=${dest%/*}
    [ "$parent" != "$dest" ] || parent=.
    mkdir -p "$parent" || die "cannot create $parent"
    say "cloning $repo -> $dest"
    git clone "$(expected_origin "$repo")" "$dest" </dev/null || die "cannot clone $repo"
}

probe_push() {
    repo_dir=$1
    probe_ref=refs/heads/rumiai-write-check-$$
    GIT_TERMINAL_PROMPT=0 GCM_INTERACTIVE=Never GIT_SSH_COMMAND='ssh -o BatchMode=yes' git -C "$repo_dir" push --dry-run origin "HEAD:$probe_ref" >/dev/null 2>&1
}

git_helper_exists() {
    helper=$1
    if command -v "git-credential-$helper" >/dev/null 2>&1; then
        return 0
    fi
    exec_path=$(git --exec-path 2>/dev/null) || return 1
    [ -x "$exec_path/git-credential-$helper" ]
}

choose_secure_helper() {
    system=$(uname -s 2>/dev/null || printf '%s' unknown)
    CREDENTIAL_HELPER=

    case $system in
        Darwin)
            if git_helper_exists osxkeychain; then
                CREDENTIAL_HELPER=osxkeychain
            elif git_helper_exists manager; then
                CREDENTIAL_HELPER=manager
            elif git_helper_exists manager-core; then
                CREDENTIAL_HELPER=manager-core
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            if git_helper_exists manager; then
                CREDENTIAL_HELPER=manager
            elif git_helper_exists manager-core; then
                CREDENTIAL_HELPER=manager-core
            elif git_helper_exists wincred; then
                CREDENTIAL_HELPER=wincred
            fi
            ;;
        Linux)
            if git_helper_exists manager; then
                CREDENTIAL_HELPER=manager
            elif git_helper_exists manager-core; then
                CREDENTIAL_HELPER=manager-core
            elif git_helper_exists libsecret; then
                CREDENTIAL_HELPER=libsecret
            fi
            ;;
    esac

    [ -n "$CREDENTIAL_HELPER" ]
}

configure_repo_token() {
    repo_dir=$1
    repo=$2
    helper=$3
    username=$4
    token=$5

    git -C "$repo_dir" remote set-url origin "$(expected_origin "$repo")" || return 1

    # Keep the credential policy local to this checkout and key credentials by repo path.
    git -C "$repo_dir" config --local --replace-all credential.helper '' || return 1
    git -C "$repo_dir" config --local --add credential.helper "$helper" || return 1
    git -C "$repo_dir" config --local credential.useHttpPath true || return 1

    {
        printf 'protocol=https\n'
        printf 'host=%s\n' "$GITHUB_HOST"
        printf 'path=%s.git\n' "$repo"
        printf 'username=%s\n' "$username"
        printf 'password=%s\n' "$token"
        printf '\n'
    } | git -C "$repo_dir" credential approve >/dev/null 2>&1
}

show_layout() {
    say ''
    say 'Development environment:'
    say "  RumiAI_ROOT:       $RUMIAI_ROOT"
    say "  rumiai-tests:      $RUMIAI_TESTS_DIR"
    say "  rumiai-dev-PoCs:   $RUMIAI_POCS_DIR"
}

have git || die 'git is required'
have uname || die 'uname is required'

if [ "$#" -gt 1 ]; then
    die 'usage: setup-dev.sh [RumiAI_ROOT]'
fi

ensure_git_identity

if [ "$#" -eq 1 ]; then
    RUMIAI_ROOT=$1
else
    RUMIAI_ROOT=$PWD/rumiai-os
fi

case $RUMIAI_ROOT in
    /*) : ;;
    *) RUMIAI_ROOT=$PWD/$RUMIAI_ROOT ;;
esac

RUMIAI_DEV_DIR=$RUMIAI_ROOT/.dev
RUMIAI_TESTS_DIR=$RUMIAI_DEV_DIR/rumiai-tests
RUMIAI_POCS_DIR=$RUMIAI_DEV_DIR/rumiai-dev-PoCs

clone_or_validate "$RUMIAI_OS_REPO" "$RUMIAI_ROOT"
mkdir -p "$RUMIAI_DEV_DIR" || die "cannot create $RUMIAI_DEV_DIR"
clone_or_validate "$RUMIAI_TESTS_REPO" "$RUMIAI_TESTS_DIR"
clone_or_validate "$RUMIAI_POCS_REPO" "$RUMIAI_POCS_DIR"

show_layout
say ''
say 'Checking push capability (dry-run only)...'

os_write=0
tests_write=0
pocs_write=0
probe_push "$RUMIAI_ROOT" && os_write=1
probe_push "$RUMIAI_TESTS_DIR" && tests_write=1
probe_push "$RUMIAI_POCS_DIR" && pocs_write=1

[ "$os_write" -eq 1 ] && say '  write: rumiai-os' || say '  read-only/unavailable: rumiai-os'
[ "$tests_write" -eq 1 ] && say '  write: rumiai-tests' || say '  read-only/unavailable: rumiai-tests'
[ "$pocs_write" -eq 1 ] && say '  write: rumiai-dev-PoCs' || say '  read-only/unavailable: rumiai-dev-PoCs'

if [ "$os_write" -eq 1 ] && [ "$tests_write" -eq 1 ] && [ "$pocs_write" -eq 1 ]; then
    say ''
    say 'Development environment is ready with push access.'
    exit 0
fi

say ''
warn 'one or more repositories do not currently have verified push access'

if ! tty_available; then
    warn 'no controlling terminal is available; credentials cannot be requested safely'
    warn 'rerun from an interactive terminal if you want to configure a GitHub access token'
    exit 0
fi

if ! ask_yes_no 'Configure a GitHub personal access token now?'; then
    say 'Leaving repositories configured for read access only where push was unavailable.'
    exit 0
fi

if choose_secure_helper; then
    say "Using secure Git credential helper: $CREDENTIAL_HELPER"
else
    warn 'no supported secure Git credential helper was found on this host'
    warn 'recommended helpers: osxkeychain (macOS), Git Credential Manager (Windows/Linux), libsecret (Linux)'
    if ask_yes_no 'Use git credential-store instead? WARNING: it stores the token in plaintext'; then
        CREDENTIAL_HELPER=store
    else
        die 'credential configuration cancelled; install a secure credential helper and rerun'
    fi
fi

prompt_text 'GitHub username: ' || die 'cannot read GitHub username'
GITHUB_USERNAME=$REPLY
[ -n "$GITHUB_USERNAME" ] || die 'GitHub username cannot be empty'

say 'Use a fine-grained token with access to the required repositories and Contents: Read and write.'
have stty || die 'stty is required to enter a GitHub access token securely'
prompt_secret 'GitHub personal access token: ' || die 'cannot read GitHub access token'
GITHUB_TOKEN=$REPLY
[ -n "$GITHUB_TOKEN" ] || die 'GitHub access token cannot be empty'

if [ "$os_write" -ne 1 ]; then
    configure_repo_token "$RUMIAI_ROOT" "$RUMIAI_OS_REPO" "$CREDENTIAL_HELPER" "$GITHUB_USERNAME" "$GITHUB_TOKEN" || die 'cannot store credentials for rumiai-os'
fi
if [ "$tests_write" -ne 1 ]; then
    configure_repo_token "$RUMIAI_TESTS_DIR" "$RUMIAI_TESTS_REPO" "$CREDENTIAL_HELPER" "$GITHUB_USERNAME" "$GITHUB_TOKEN" || die 'cannot store credentials for rumiai-tests'
fi
if [ "$pocs_write" -ne 1 ]; then
    configure_repo_token "$RUMIAI_POCS_DIR" "$RUMIAI_POCS_REPO" "$CREDENTIAL_HELPER" "$GITHUB_USERNAME" "$GITHUB_TOKEN" || die 'cannot store credentials for rumiai-dev-PoCs'
fi

GITHUB_TOKEN=
unset GITHUB_TOKEN

say ''
say 'Re-checking push capability...'
failed=0
if probe_push "$RUMIAI_ROOT"; then
    say '  write: rumiai-os'
else
    say '  unavailable: rumiai-os'
    failed=1
fi
if probe_push "$RUMIAI_TESTS_DIR"; then
    say '  write: rumiai-tests'
else
    say '  unavailable: rumiai-tests'
    failed=1
fi
if probe_push "$RUMIAI_POCS_DIR"; then
    say '  write: rumiai-dev-PoCs'
else
    say '  unavailable: rumiai-dev-PoCs'
    failed=1
fi

if [ "$failed" -ne 0 ]; then
    die 'push access is still unavailable for one or more repositories; check token repository access and Contents permission'
fi

say ''
say 'Development environment is ready with push access.'
