# gitman quick-action ordering and terminal headers

Status: Complete
Updated: 2026-09-22

## Goal

Move the existing Sync + Push quick action to the first position in the root Git action menu and make terminal/no-pager execution print one three-line header per menu-selected command sequence: 50 hyphens, the selected menu label, then 50 hyphens.

## Final repository revisions

```text
rumiai-dev    0ad47bd6ec8bb650076438b510c6646cbadc0ebc  pre-completion HEAD
rumiai-os     0a45bddce0318e111a72b052f7bc8366d2911b0b  current main
rumiai-tests  1062ffcd51d3c66e16a4a07a1aa9d84a46a56f83
```

The validated task target is:

```text
rumiai-os 1683ff139cfa775adeb832ffae10944b40155256
```

Later `rumiai-os` commits through current main are unrelated to gitman.

## Completed outcome

- `Sync + Push` is the first root Git action and `Status` follows it.
- Terminal mode emits exactly one header per selected command sequence:
  `50 hyphens / concrete selected menu label / 50 hyphens`.
- Composite `Sync + Push` emits the header once for the whole sequence.
- Canonical `GITMAN.md`, implementation and operational manual are aligned.
- The focused task validation protects `GITMAN-11` and `GITMAN-13`.
- Gitman permanent tests were realigned to current contract-driven testing rules.
- `TESTING.md` and `TEST-PATTERNS.md` now require contract-traceable assertions and distinguish product `FAIL` from harness/infrastructure `ERROR`.
- Broader permanent-test cleanup remains intentionally deferred in `todo/contract-driven-permanent-test-audit.md`.

## Final validation

Formal validation succeeded on Linux/x86_64:

```text
scope                 gitman
kind                  task
selection             rumiai-os/gitman/terminal-output.test
rumiai-tests          1062ffcd51d3c66e16a4a07a1aa9d84a46a56f83
rumiai-os target      1683ff139cfa775adeb832ffae10944b40155256
session               20260922T101108+0200-144005
validation            20260922T101107+0200-142553
result                PASS 1 / FAIL 0 / SKIP 0 / ERROR 0
duration              0.95s
environment audit     CLEAN
aggregate status      0 / VALIDATED
```

Published evidence:

```text
validation session commit
5d64f4ff63c6de807100d9c79a70378256a7a86b

validation aggregate commit
4c36787bc7227eb36e382c4e6479262f6433cc32
```

## Current state

Task complete. Durable behavior is in canonical specifications, implementation/manual, permanent tests and immutable validation evidence.

## Next action

None.

## Blockers / open questions

None.
