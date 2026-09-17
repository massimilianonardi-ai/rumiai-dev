# rumiai-tests-suite-realignment

Status: Active
Updated: 2026-09-17 22:48 +02:00

## Goal

Audit and realign the permanent RumiAI test suite so that failures are meaningful evidence about a current property rather than false negatives caused by legacy implementation coupling, artificial target reconstruction, external drift, stale revision binding or defective test logic.

## Current repository revisions

```text
rumiai-dev   97d1c6711658ed8ca4ce0e96b325ebfbd85d532d
rumiai-tests d2c487ecdfb672ac7343019098fda98381f5cf82
rumiai-os    db0b25c20b08247cd68818ef9caea61a1cf02451
```

These revisions were rechecked immediately before this checkpoint. Fresh HEAD retrieval remains mandatory before later writes.

## Current authority used

The current mandatory read order has been re-run. The active audit is governed by current `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `RUNNER.md`, `TEST-PATTERNS.md`, the routed subsystem specifications and current implementation/tests.

Relevant current product specifications include `COMMAND-ENTRYPOINTS.md`, `BOOTSTRAP-ENVIRONMENT.md`, `ENTRYPOINT-ROOT-RESOLUTION.md`, `PACKAGE-MODEL.md`, `LIBRARY-INTERFACES.md`, `SERVICE-LIFECYCLE.md`, `STATE-MODEL.md`, `READ-KEY.md` and `MK-SOURCE-MATERIALIZATION.md` as applicable to the inspected tests.

## Method correction fixed by current user feedback

The user reports repeated cases where permanent tests fail while the exercised product behavior works correctly. Current source inspection confirms that this is not merely anecdotal: the suite contains concrete false-negative mechanisms and over-coupled tests.

The previous realignment method was therefore too conservative where it treated legacy assertions as presumptively valid and mainly replaced duplicated infrastructure. From this checkpoint onward the audit is property-first:

```text
identify the current property claimed by the test
→ determine whether that property is current contract/regression evidence
→ determine the real execution path that proves it
→ classify keep / simplify / merge / remove
→ only then rewrite infrastructure or assertions
```

Existing assertions are not preserved merely because they already exist. A failing test is not evidence of a product defect until the test itself has passed this classification.

## Implemented work already present in rumiai-tests

Twenty-two evidence-confirmed legacy tests have already received infrastructure or behavioral realignment in earlier tranches. They include command/runtime selection, language selection, service lifecycle, shell selection, state-path, read-key, log, digest, http-fetch, JSON and real tar.gz extraction tests.

The latest committed additions beyond the previous handoff checkpoint are:

```text
tests/rumiai-os/http-fetch/backends.test
tests/rumiai-os/http-fetch/cli.test
tests/rumiai-os/json/object-read.test
tests/rumiai-os/json/structure.test
tests/rumiai-os/extract/real-targz.test
```

Those changes centralized target discovery while preserving their prior semantic assertions. This new audit explicitly reopens the validity of prior assertions when current contract evidence does not support them; a test being previously realigned does not exempt it from property-first review.

No `rumiai-os` product implementation has been modified by this task.

## Proven test defects / false-negative mechanisms

### `srv/lifecycle.test` contains a definite parsing bug

The current product prints a successful start line of the form:

```text
srv: <service> started pid=<pid>
```

The current test's first start parses only field 1 with `awk 'NR == 1 { print $1 }'` before removing `pid=`, so the value becomes `srv:` rather than the numeric PID. Its subsequent numeric assertion therefore fails against correct current output. Later code in the same test uses `sed -n 's/.*pid=//p'`, demonstrating the inconsistent parser.

This failure is a test defect, not evidence that `srv` start is broken.

### Full-suite health aggregates unrelated evidence classes

The current repository contains 131 `*.test` files, including 100 under `tests/rumiai-os`. The root `tests/` tree also contains live external package/release tests, `rumiai-dev` tests, runner tests and `rumiai-tests` self-tests.

Per the current runner/validation contract, an unselected full-suite run executes the complete root. A red aggregate session therefore does not by itself mean the RumiAI OS runtime is defective.

### `rumiai-os-health` is revision-specific and currently points far behind product HEAD

Current `validation/rumiai-os-health.conf` pins:

```text
0751add1a59f90d4a0fc19b36db9d4dbda0167ad
```

while current `rumiai-os` HEAD is:

```text
db0b25c20b08247cd68818ef9caea61a1cf02451
```

The current product is 27 commits ahead of that configured health target. This exact-revision behavior is intentional in `rumiai-validate`, but it means a user selecting `0) all tests` is not necessarily testing the current product checkout. Results must be interpreted against the pinned revision rather than against current HEAD.

### Live external/release tests can fail on legitimate upstream/catalog change

The root suite contains live tests for external packages/providers. The shared `lib/package-release.lib` performs real live installation and external/catalog inspection, but the package test files also pin package-catalog tree object IDs. For example the Node.js live test expects a fixed catalog tree SHA; any legitimate catalog edit causes `catalog tree drift` failure even if current `pkg install nodejs` and the installed commands work correctly.

Current `tests/rumiai-os/pkg/install-live.test` similarly fixes a specific external package identity (`jq@jq-1.8.2`). Such tests are useful release/integration evidence for a defined revision but are not timeless indicators of package-manager correctness.

### Several package tests violate the current authenticity boundary

Current `PACKAGE-MODEL.md` explicitly defines `pkg` as the public package command and says composed package behavior traverses real catalog, repository adapter, download, extraction/materialization, integration, binding and launch responsibilities. Tests claiming public/composed behavior must not replace those RumiAI components.

Current legacy package tests inspected during this audit include examples that instead source internal libraries and construct artificial runtimes:

```text
pkg/dependency.test
pkg/default.test
pkg/versions.test
pkg/state.test
pkg-download/contract.test
pkg-extract/contract.test
pkg-integration/contract.test
pkg-launch/contract.test
pkg/catalog-snapshot.test
repository-adapter contract tests such as pkg-repository-apache-maven/contract.test
```

Observed techniques include handwritten `readpathce`/`log`, synthetic `m_*` roots, hard-coded `m_OSARCH`, copied or fake `state-path`, fake RumiAI `http-fetch`, fake RumiAI `extract`, direct calls into package libraries and assertions over private physical symlink/layout details.

These tests may still be useful as narrowly scoped library/adapter unit tests when the directly called interface is a current public library API and their evidence is labelled accordingly. They do not prove failure of the composed public package command when they replace components of that path.

### A current package test directly calls a private library function

`pkg/catalog-snapshot.test` directly invokes and later overrides `_pkg_install_catalog_snapshot_impl`. Current `LIBRARY-INTERFACES.md` makes underscore-prefixed functions implementation-private and explicitly says consumers must not depend on them as callable API.

That test is therefore coupled to a non-contractual private implementation surface and must be redesigned or removed as current permanent contract evidence.

### Private implementation layout is asserted in other tests

`mk/materialize.test` checks for residue matching a hard-coded `.mk-materialize-*` staging prefix. Current `MK-SOURCE-MATERIALIZATION.md` explicitly declares the staging pathname implementation-private. The useful property is cleanup/no unexpected residue, not that private spelling.

Several package tests similarly assert physical link targets and internal managed layout even though `PACKAGE-MODEL.md` states consumers must not assume private integration paths beyond documented contract.

### Exact diagnostic/report prose is overused

A number of tests require exact logging message IDs, prose fragments or report headings in addition to status/effect. Examples exist in language, digest/http-fetch/extract, service lifecycle and package-analysis/release tests.

Where wording/message identity is not itself a current documented interface, this creates false negatives from harmless diagnostic or presentation changes. Assertions should normally protect semantic status, structured fields when contracted, and observable effects.

### Host/timing-sensitive tests need separate flake review

PTY, service process lifecycle, manual paging and GUI/live package tests contain bounded sleeps/timeouts or depend on terminal/session capabilities. Some correctly SKIP missing prerequisites, but these tests need explicit flake/host classification and must not be treated as equivalent to deterministic contract tests.

## Important hypothesis rejected

A suspected issue that integrated commands could fail because `#!/usr/bin/env m` cannot resolve `m` from `PATH="$root/bin/sys:..."` was checked and rejected. Current `bin/sys/m` is the intended symlinked technical bootstrap entrypoint, so this is not a valid general explanation for the failures.

## Current interpretation

The suite has at least four materially different failure meanings mixed together today:

```text
real current product contract violation
test implementation defect / false negative
legacy/internal-unit expectation drift
live external/host/revision drift
```

The aggregate FAIL status does not distinguish those categories. The user-observed phenomenon "test fails while product works" is therefore structurally plausible and, in at least the current `srv/lifecycle.test`, directly proven by source.

## Validation limits of this audit

The current chat execution environment cannot resolve GitHub for a local clone, so the exact current suite cannot be executed here. The findings above are source/contract analysis. No new runtime PASS/FAIL claim is made.

Current local run logs under `.runs/` are not available through the repository connector, so the exact set of failures observed by the user cannot yet be mapped one-for-one to these causes from this chat alone. This does not block the property-first suite audit.

## Next action

Do not continue mechanical helper-only migration as the main strategy.

Next work should audit the current suite family-by-family, starting with the highest false-negative concentration:

```text
1. repair or replace the proven-broken srv lifecycle test
2. reclassify package/pkg-* tests against PACKAGE-MODEL and LIBRARY-INTERFACES
3. separate composed public-command evidence from legitimate library/adapter unit evidence
4. isolate live external/release checks from ordinary product-contract interpretation
5. remove private-layout/private-function assertions unless a current contract promotes them
6. reduce exact diagnostic/report-string assertions to contracted semantics
7. review host/timing tests for deterministic prerequisite handling and flake risk
8. then finish lower-risk infrastructure deduplication such as remaining target-discovery copies
```

When actual current FAIL logs become available, map each failed test to this classification before considering a product change.

## Blockers / open questions

- No network-capable executable clone of the current repositories is available in this chat, so runtime reproduction is not currently possible here.
- No product modification is authorized or implied by this test-suite audit.
- The separate deferred `library-api-visibility-realignment` work remains distinct; this task must not silently rename product APIs while repairing test evidence.
