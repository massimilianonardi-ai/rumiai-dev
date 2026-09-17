# RumiAI OS — Entrypoint and root resolution

Status: **Current / normative**  
Updated: 2026-09-17

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

If `$0` contains `/`, it is treated as the invocation pathname.

If `$0` contains no `/`, the bootstrap may first recognize an existing pathname in the caller CWD and otherwise resolve the command through PATH according to the current bootstrap contract.

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

For an integrated command, `m` resolves the requested command to a physical readable regular file, rejects resolution back to the bootstrap itself, exports readonly:

```text
m_COMMAND_BIN
```

and sources the command body in the initialized runtime.

## Branded entrypoints

`rumiai-os` and `rumiai-os-sh` resolve their own product root and delegate to the root `m` bootstrap. They do not become the technical root identity themselves.

## Invariants

```text
ROOT-01  m_BOOTSTRAP_BIN identifies the physical m bootstrap
ROOT-02  m_ROOT is derived from the canonical m bootstrap location
ROOT-03  root resolution is independent of a fixed installation path
ROOT-04  supported symlink/PATH invocation resolves to the physical bootstrap
ROOT-05  m_COMMAND_BIN identifies the resolved integrated command
ROOT-06  branded entrypoints delegate to m and are not the technical runtime identity
```
