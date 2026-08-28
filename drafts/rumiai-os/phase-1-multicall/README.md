# Phase 1 multicall bootstrap proposal

Status: **superseded draft / historical material / not product code**  
Date: 2026-08-28

This directory preserves the multicall/symlink + `cmd/` exploration that preceded the accepted command-interpreter model.

It is intentionally retained because the reasoning exposed important requirements around command identity, external aliases, duplicate basenames, PATH behavior and bootstrap ownership.

The current design is specified by:

```text
decisions/rumiai-os/2026-08-28-command-interpreter-shebang.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
architecture/rumiai-os/PHASE-1.md
```

and the current code proposal is under:

```text
drafts/rumiai-os/phase-1-command-interpreter/
```

## Historical proposal

The explored shape was:

```text
RumiAI_ROOT/
├── rumiai-os
├── bin/
│   ├── log -> ../rumiai-os
│   └── foo -> ../rumiai-os
├── cmd/
│   └── foo
├── lib/
├── conf/
└── lang/
```

It required preserving invocation identity before `realpath`, validating multicall aliases, mapping basenames to commands and eventually considering `cmd/` as a sparse shadow of nested public command paths.

The proposal became increasingly complex when considering:

- renamed aliases such as `my-log`;
- external symlinks;
- two commands with the same basename in different paths;
- package-specific command directories;
- public-path to private-implementation mapping;
- duplicated bootstrap/dispatch concerns.

This exploration led directly to the simpler accepted model:

```text
#!/usr/bin/env rumiai-os
```

where the command pathname is passed to the active runtime and the command file itself contains its implementation body.

## Historical code

The files in this directory remain unchanged unless a clarification is needed to preserve their historical meaning. They MUST NOT be used as the current product implementation reference.
