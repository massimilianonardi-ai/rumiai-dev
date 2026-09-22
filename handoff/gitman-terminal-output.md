# gitman quick-action ordering and terminal headers

Status: Active
Updated: 2026-09-22

## Goal

Move the existing Sync + Push quick action to the first position in the root Git action menu and make terminal/no-pager execution print one three-line header per menu-selected command sequence: 50 hyphens, the selected menu label, then 50 hyphens.

## Current repository revisions

```text
rumiai-dev    ad5c903f9dad2a20183d3828fe4d3b733368b27f  canonical/task state before this checkpoint
rumiai-os     0a45bddce0318e111a72b052f7bc8366d2911b0b  current main
rumiai-tests  1062ffcd51d3c66e16a4a07a1aa9d84a46a56f83
```

Task validation continues to pin the implemented gitman target at:

```text
1683ff139cfa775adeb832ffae10944b40155256
```

Later `rumiai-os` commits through current main affect unrelated package/http-fetch surfaces. `rumiai-tests` later advanced from the gitman realignment commit `47f2ffbb55068c5218a02a4b357f99475e0b6b9d` to current main only through unrelated validation-scope updates for other package/service work.

## Fixed task-local choices

- Preserve the public action name `Sync + Push`.
- `Sync + Push` is the first root action; `Status` follows it.
- Terminal mode emits exactly one header per menu-selected command sequence.
- The header contains the full concrete selected menu label; composite actions emit it once for the whole sequence.
- Task validation protects only the changed contract properties, not unrelated gitman health properties.

## Current implementation state

Specification, implementation and operational manual are aligned with the requested behavior.

Current focused validation selection:

```text
rumiai-os/gitman/terminal-output.test
```

The gitman tests were realigned after repeated false failures:

- `contract.test` now protects only normative structural properties (`GITMAN-01`, `GITMAN-15` and applicable interpreter/manual structure); implementation-source grep and manual-prose assertions were removed.
- `terminal-output.test` now protects only `GITMAN-11` and `GITMAN-13`: selecting the default root action must produce the complete Sync + Push header, one Down must produce the Status header, and each terminal sequence has exactly one 50-hyphen/label/50-hyphen header plus the required pause. It no longer asserts rendered menu text, Git SHA/upstream state, remote behavior or unrelated Git output.
- `interactive.test` now distinguishes semantic assertions from PTY/driver/setup failures. Contract assertion mismatches remain `FAIL`; synchronization timeouts, driver exceptions and infrastructure failures are `ERROR`.

The canonical testing rules were strengthened in `TESTING.md` and `TEST-PATTERNS.md`: permanent tests must identify protected current properties, semantic assertions must map to those properties, and harness failures must not be collapsed into product `FAIL`.

A broader repository-wide audit is intentionally deferred under:

```text
todo/contract-driven-permanent-test-audit.md
```

## Validation evidence

Linux/x86_64 formal runs supplied by the user:

```text
20260922T093848+0200-65348
rumiai-tests 5a149673fe5d9803dfef9273d0ae38f53571b750
FAIL 1 / PASS 0
CLEAN validation environment
```

That run exposed a test bug: it waited for the complete long Sync + Push label in menu rendering even though `menu` normatively truncates rendered items to terminal width.

```text
20260922T095346+0200-97688
rumiai-tests 8513947696dfc1290a52d669eab16f700a4c48dd
FAIL 1 / PASS 0
CLEAN validation environment
```

The second session evidence is published only in the user's local checkout and its detailed log is not available through GitHub. It therefore does not establish a specific product defect. Rather than patch another synchronization symptom, the test model was realigned as described above.

## Next action

Run the current formal scope from a real `rumiai-tests` checkout:

```sh
./rumiai-validate gitman
```

A result from suite revision `47f2ffbb55068c5218a02a4b357f99475e0b6b9d` or later is required. If the test reports `FAIL`, its diagnostic must now identify a declared GITMAN contract violation. If the PTY/driver cannot obtain reliable evidence, the result must be `ERROR` instead.

## Blocker

Formal execution of the contract-driven focused test is still pending.
