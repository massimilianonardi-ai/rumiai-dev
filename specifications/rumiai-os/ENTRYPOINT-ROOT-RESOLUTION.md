# RumiAI OS — Entrypoint and root resolution

Status: **Current / normative**  
Updated: 2026-10-06

This specification defines physical root resolution for the technical bootstrap `m`.

## Fundamental values

After successful bootstrap resolution:

```text
m_BOOTSTRAP_BIN
    absolute physical/canonical pathname of the actual m bootstrap file

m_ROOT
    physical/canonical directory containing m_BOOTSTRAP_BIN
```

Both are exported and readonly only after validation succeeds.

## Invocation pathname

If `$0` contains `/`, it is treated as the invocation pathname. Relative pathnames are therefore interpreted relative to the caller CWD only when the invocation explicitly supplies a pathname such as `./m` or `path/to/m`.

If `$0` contains no `/`, it is a command name and is resolved through `PATH`. The mere existence of an object with the same leaf name in the caller CWD does not take precedence over `PATH`.

The same distinction applies to integrated command resolution: an operand containing `/` is an explicit pathname, while a slashless command operand is resolved through the active command `PATH`.

Invocation through a symbolic link is supported; symlink invocation is not a reason to reject the command.

## Existing-path canonicalization

For an object that must already exist, the semantic order is:

```text
validate selectable/existing path
→ canonicalize the existing object
→ validate required type/properties
```

The current bootstrap uses the established `readpathce` primitive and optionless standard-utility path to canonicalize an existing selected object. Consumers should reuse the established responsibility instead of creating alternate root-resolution spellings.

Do not make GNU `readlink -f` or another host-only shortcut part of the general contract.

## Root derivation

`m_ROOT` is derived from the canonical `m_BOOTSTRAP_BIN`, not from the caller CWD, an external symlink directory or a hardcoded installation prefix.

Moving the complete RumiAI OS tree to another path must not require source modification.

## Command resolution after bootstrap

For a command operand, `m` attempts to resolve and canonicalize the selected pathname to reject recursive execution of the bootstrap. It then executes the original command vector externally; it does not provide a sourced-command identity.

A POSIX shell command obtains its own invocation identity from `$0` and may use established `readpathce` to canonicalize an existing entrypoint. This works with explicit relative/absolute invocation paths, symlinks and PATH-based invocation. Every native command uses the interpreter-appropriate entrypoint identity mechanism.

## Invariants

```text
ROOT-01  m_BOOTSTRAP_BIN identifies the physical m bootstrap
ROOT-02  m_ROOT is derived from the canonical m bootstrap location
ROOT-03  root resolution is independent of a fixed installation path
ROOT-04  supported symlink/PATH invocation resolves to the physical bootstrap
ROOT-05  native commands resolve their own physical identity when needed
ROOT-06  all command operands execute externally without special integrated classification
```
