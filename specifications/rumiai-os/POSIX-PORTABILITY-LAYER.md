# RumiAI OS — POSIX portability layer

Status: **Current / normative**  
Updated: 2026-09-17

This specification refines the platform rules in `RULES.md` for the current `m` + RumiAI runtime.

## Platform baseline

RumiAI OS targets:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

A construct is not considered portable merely because it works on Linux, macOS or another common Unix-like host.

## Shell baseline

Portable shell code uses POSIX `sh` unless another runtime has an explicit current contract.

The technical root bootstrap `m` uses:

```sh
#!/bin/sh
```

Bootstrap-integrated commands use:

```sh
#!/usr/bin/env m
```

Standalone shell utilities use `#!/bin/sh` only under the independence contract in `COMMAND-ENTRYPOINTS.md`.

Do not depend accidentally on Bash arrays, `[[ ... ]]`, process substitution, `$RANDOM`, GNU-only options or equivalent unapproved extensions.

## Host-specific capability boundary

A facility that POSIX cannot provide portably may use a host-specific implementation/adapter when the requirement is real and the generic interface remains host-neutral.

The adapter boundary must prevent implementation details such as:

```text
Linux-specific files/APIs
macOS-specific utilities/frameworks
GNU/BSD option differences
host service managers
host package-manager paths
```

from becoming the semantic contract seen by ordinary consumers.

Before introducing a new host abstraction, verify that an existing current facility does not already own the responsibility.

## External tools

Tools not guaranteed by the selected POSIX baseline are capabilities/dependencies, not POSIX primitives.

Examples can include:

```text
git
curl
python
openssl
7z
platform-specific utilities
```

A component that requires one must make that dependency part of its real execution profile instead of treating accidental availability on one host as a platform guarantee.

## Data remains data

Arbitrary external input must not be reinterpreted as shell syntax unless code evaluation is the explicit API purpose.

For arbitrary string output through `printf`, use a constant format operand.

Do not build shell source from untrusted data merely to achieve quoting/path handling.

## Defensive quoting

Follow `RULES.md`: quote expansions/value operands when doing so preserves intended semantics. Internal knowledge that a current value is “safe” is not a reason to leave an expansion structurally unsafe.

## Path handling

RumiAI is relocatable.

Do not hardcode personal checkout paths, Homebrew paths, Linux distribution paths or other machine-local spellings when the value can be derived from semantic roots or resolved through the owning facility.

When an existing object must be canonicalized, validate the applicable existence/type contract and use the established runtime primitive/standard utility contract rather than assuming a GNU-only shortcut such as `readlink -f`.

Invocation through symlinks/PATH must be handled according to the owning entrypoint contract rather than rejected merely because a symlink is present.

## CLI option boundaries

For a tool that really supports `--` as an option terminator, use it before one or more data operands. Do not invent it for a tool without that contract.

## Distribution diversity

Different POSIX/POSIX-compatible hosts are valuable validation points, not nuisances to normalize away in tests.

A Debian development VM can expose accidental Ubuntu assumptions; macOS can expose GNU/BSD differences; other compatible hosts can expose additional portability gaps. Those differences should be absorbed by the correct abstraction where the general RumiAI contract is intended to remain common.

A PASS on one host does not prove another host.

## Testing

Permanent tests should normally express a common semantic property once and execute it on multiple applicable hosts rather than cloning host-specific copies of the same expectation.

Where the property itself is host-specific, the adapter/host contract should be tested explicitly.

See `TESTING.md` and `PHYSICAL-TESTING.md`.

## Invariants

```text
POSIX-01  POSIX.1-2024 Issue 8 is the platform baseline
POSIX-02  shell code is POSIX sh unless explicitly specified otherwise
POSIX-03  m is the current integrated runtime identity
POSIX-04  host-specific behavior stays behind explicit facilities/adapters
POSIX-05  non-POSIX tools are declared capabilities, not assumed primitives
POSIX-06  external data is not reinterpreted as shell syntax
POSIX-07  relocatability forbids accidental local/host path dependencies
POSIX-08  distribution diversity is useful portability evidence
POSIX-09  one-host PASS does not substitute for another applicable host
```
