# Command-interpreter local validation

Date: 2026-08-28
Status: **ad hoc local validation, not reference-host certification**

The accepted command-interpreter concept was exercised locally using executable files beginning with:

```text
#!/usr/bin/env rumiai-os
```

## Validated behaviors

### Interpreter argv shape

For:

```text
/path/to/foo "a b" c
```

local host behavior was:

```text
rumiai-os argv[1] = /path/to/foo
remaining args     = "a b", c
```

After `shift`, the sourced command body observed the original user arguments unchanged.

### Renamed symlink alias

For:

```text
aliases/my-foo -> ../pkg-a/bin/foo
```

invoking `my-foo` caused `rumiai-os` to receive the alias pathname. Canonicalizing it with `realpath -e` produced the actual command file:

```text
pkg-a/bin/foo
```

The external basename therefore had no routing role.

### Duplicate basenames

Both:

```text
pkg-a/bin/foo
pkg-b/bin/foo
```

were executed correctly and remained distinguishable because the pathname, not basename, reached the runtime.

### PATH-selected runtime

Two independent executables named `rumiai-os` were placed in different PATH directories.

The same command file was successfully interpreted by runtime A or runtime B solely according to PATH order.

This confirms the intended active-environment semantics.

### Sourcing command file with initial `#!`

The command body was sourced successfully under:

```text
dash
bash --posix
busybox sh
```

The initial:

```text
#!/usr/bin/env rumiai-os
```

was treated compatibly with a shell comment in these local implementations and the body received the expected positional parameters.

## Important limitation

This evidence does NOT make the behavior POSIX-guaranteed.

POSIX.1-2024 explicitly leaves general `#!` behavior unspecified for shell command files, and does not guarantee `/usr/bin/env` as a fixed pathname.

Therefore the command-interpreter model remains dependent on an explicit RumiAI host profile and MUST receive formal validation on the actual reference hosts, especially:

```text
Linux reference host(s)
macOS
Cygwin / selected Windows POSIX environment
```

before product implementation is certified.

## Other unresolved validation

Formal PoC should also cover:

- relative and absolute command-file invocation;
- relative and absolute symlink aliases;
- symlink chains;
- command path containing spaces;
- PATH entries with spaces/relative components where relevant;
- missing `/usr/bin/env` classification;
- `rumiai-os` absent from PATH;
- incompatible/multiple runtime selection;
- unreadable command file;
- command file changed between validation and source;
- exact behavior of `return`, `exit`, signals and traps in sourced commands;
- syntax errors in sourced command bodies;
- status propagation.
