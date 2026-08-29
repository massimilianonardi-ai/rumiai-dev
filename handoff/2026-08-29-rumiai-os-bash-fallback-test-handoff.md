# Handoff — RumiAI OS bash fallback test isolation

Date: 2026-08-29
Status: **product unchanged; deterministic fallback-test candidate awaiting cross-host validation**

## Stable product baseline

The product remains:

```text
massimilianonardi-ai/rumiai-os@8698504f715ed61cec8a31b46ded5b79f3924eb5
Separate pathname validation from canonicalization
```

That exact product commit is already physically validated with the 53-test baseline on both stable hosts:

```text
PASS   53
FAIL   0
SKIP   0
ERROR  0
TOTAL  53
```

No product change has been made while diagnosing the shell fallback test.

## Shell block

The shell block added:

```text
tests/rumiai-os/shell/sh-selection.test
tests/rumiai-os/shell/bash-fallback-to-sh.test
tests/rumiai-os/shell/unsupported-fallback-to-sh.test
```

`sh-selection.test` and `unsupported-fallback-to-sh.test` have passed physically on both macOS and Ubuntu ARM64 throughout the investigation.

Only:

```text
rumiai-os/shell/bash-fallback-to-sh.test
```

has remained host-sensitive.

## Attempt 1 — PTY plus starved PATH

Suite commit:

```text
c15cb2aaaaa0a7d209f6437f529b22840e4f1b98
Add interactive sh fallback tests
```

The test simulated unavailable `bash` by replacing the child PATH with only the isolated fixture `bin` directory and then drove the fallback `sh -i` through the interactive PTY reference.

Physical result:

```text
macOS:              PASS 55 / FAIL 1
Ubuntu 26.04 ARM64: PASS 56 / FAIL 0
```

This fixture changed two independent variables at once:

1. `bash` was not resolvable;
2. the interactive shell inherited an artificially starved PATH.

That design was rejected as too invasive for a focused test.

## Attempt 2 — PTY plus filtered inherited PATH

Suite commit:

```text
620c0620c01e7b182d4783225406211db738d585
Isolate bash absence without starving PATH
```

The test preserved the inherited PATH, removed only directories containing an executable `bash`, prepended the fixture `bin`, and asserted the bash-unavailable precondition before entering the PTY.

Physical result remained:

```text
macOS:              PASS 55 / FAIL 1
Ubuntu 26.04 ARM64: PASS 56 / FAIL 0
```

Therefore the PTY-level fallback test was still coupling two contracts unnecessarily. This did not provide evidence of a product failure because:

- direct `bash` selection passes on both hosts;
- direct `sh` selection through a real PTY passes on both hosts;
- unsupported-shell fallback to real `sh` through a PTY passes on both hosts;
- the full pre-existing 53-test product baseline remains green on both hosts.

## Stable test decomposition

The accepted test-design rule is now:

```text
branch / fallback decision
        !=
interactive shell / PTY behavior
```

Each permanent test should own one material contract unless the combination itself is the behavior under test.

The real interactive `sh` behavior remains covered by:

```text
tests/rumiai-os/shell/sh-selection.test
```

The `bash`-unavailable branch is now tested separately without PTY prompt matching.

## Current candidate

Current `rumiai-tests/main`:

```text
bc96f4843ea2b95a3dd53f85af2dd6ef723f3cd5
Separate bash fallback from PTY behavior
```

`bash-fallback-to-sh.test` now:

1. creates an isolated RumiAI OS fixture;
2. sets `conf/shell/default` to `bash`;
3. gives the child a controlled PATH containing only the fixture `bin`, and explicitly proves `command -v bash` fails;
4. runs the unchanged product;
5. feeds `exit 0` to the selected standard `sh -i` through stdin rather than through a PTY;
6. requires status 0;
7. requires the structured `shell.fallback` event;
8. requires `requested="bash"` and `selected="sh"` fields.

Product utilities deliberately resolved with `command -p` (`realpath`, `date`, `awk`, standard `sh`) remain independent of that controlled caller PATH.

The test remains executable (`100755`).

## Next physical gate

Run the complete suite on both stable hosts against unchanged product `8698504f...` and test suite `bc96f484...`.

Required result:

```text
PASS   56
FAIL   0
SKIP   0
ERROR  0
TOTAL  56
```

Only after both hosts pass should the shell block be declared closed and the general test-design lesson be promoted into `TEST-PATTERNS.md`.

## Forward-only rule

All failed test candidates and physical outcomes are preserved as historical evidence. No commit or validation result is rewritten.
