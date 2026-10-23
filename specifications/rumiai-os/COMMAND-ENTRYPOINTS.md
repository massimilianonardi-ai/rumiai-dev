# RumiAI OS — Command entrypoints

Status: **Current / normative**  
Updated: 2026-10-23

This specification defines command execution, interpreter selection, and command identity in the technical `m` runtime.

## Root bootstrap

The technical runtime is `$m_ROOT/m`, a directly executable POSIX `#!/bin/sh` program. It initializes the environment and dispatches requested commands; it is not an interpreter for command source files.

## Native command entrypoints

A command uses its actual interpreter as its shebang. POSIX shell entrypoints use:

```sh
#!/bin/sh
```

Commands written for another declared runtime may use an appropriate native shebang, for example `#!/usr/bin/env node` for Node.js. Public command names do not gain language suffixes.

An `m`-environment-dependent command MUST first reject a missing or empty `m_ROOT` in its native language. The existence of `m_ROOT` is an operational presence check, not a security proof or full environment validation. A caller can invoke the command as `m <command> [args...]` to initialize the environment, or execute the command directly from an already initialized `m` environment. Direct execution from a clean uninitialized shell is not an initialization path.

Each POSIX shell command requiring `m` shell facilities explicitly sources `$m_LIB_DIR/sys/sh/core.lib.sh` after the `m_ROOT` check, and uses the established `loadsyslib` interface for further system libraries. Commands not using shell libraries do not need to load them. The bootstrap does not transfer shell functions to child processes.

## Intentional standalone utilities

A standalone utility without an `m` runtime dependency may run through its native interpreter without `m_ROOT`. `read-key`, `readpass` and `pager` are current examples. Such a utility must not depend implicitly on `m_*` roots, bootstrap functions, `m` libraries or generated PATH state. `readpassv` remains environment-dependent even though its implementation needs no shell library.

## Command identity

The native command process owns its own pathname identity. For a POSIX shell entrypoint, `$0` is the invocation pathname and existing canonical-path functionality, such as `readpathce`, resolves it when a physical identity is required. This includes symlink and PATH invocation forms. The bootstrap never exports a per-command `m_COMMAND_BIN` identity to native commands; a parent command's identity must not leak into its child.

The `pkg` launcher validates the canonical entrypoint obtained from its own shell `$0`; `srv` uses its own canonical invocation path when serializing host supervisor registrations. Other languages use their native entrypoint identity facilities.

## Execution from m

When invoked without command operands, `m` starts the managed shell facility.

With command operands, `m` initializes the technical environment, resolves the requested command when possible to reject recursive invocation of `m` itself, and executes the original command vector externally through its native interpreter. It does not inspect shebang contents, source command files, shift command arguments or install command-local shell state. A command-not-found or execution failure follows normal POSIX external command behavior.

An external executable called through `m` inherits exported environment state. Status and argument vector are preserved.

## Shell source organization

Complex shell command entrypoints SHOULD normally define their functions before invoking one final `main "$@"`. Simple entrypoints may use clear top-level code. This is source-organization guidance and does not confer an implicit bootstrap or sourced-command atomicity guarantee.

## Public naming, manuals, libraries

Multiword public commands normally use lowercase hyphen-separated semantic names, without suffixes identifying their implementation language.

Every `m`- or RumiAI-owned directly executable command identity, including the root `m` and intentional standalone utilities, MUST have the operational manual topic defined by `DOCUMENTATION-MODEL.md`. Package-owned external commands are outside that command-manual requirement.

Owned internal libraries under `lib/sys/<runtime>/` and `lib/ai/<runtime>/` are imported, not executable entrypoints. Shell libraries have `.lib.sh`, no shebang and no executable bit.

## Invariants

```text
ENTRY-01  m is the technical bootstrap identity
ENTRY-02  root m uses #!/bin/sh
ENTRY-03  commands use the native interpreter shebang, not env m
ENTRY-04  environment-dependent commands reject missing or empty m_ROOT
ENTRY-05  native child commands own and resolve their identity, not m_COMMAND_BIN
ENTRY-06  public names do not expose the implementation-language suffix
ENTRY-07  internal libraries are not directly executable entrypoints
ENTRY-08  every owned executable command identity has an operational manual topic
ENTRY-09  shell commands should define functions before a final main "$@" when appropriate
ENTRY-10  m dispatches the original argument vector externally after initialization
```
