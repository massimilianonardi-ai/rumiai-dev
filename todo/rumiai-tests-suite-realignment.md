# rumiai-tests-suite-realignment

## Intent

Audit the current permanent test suite and realign only the evidence-confirmed legacy tests with the current authenticity, shared-infrastructure, minimality and complete-replica contracts.

## Why pending

The current suite still contains legacy tests that duplicate target/fixture infrastructure inline or reconstruct partial targets even though current testing guidance provides shared libraries and treats inline copying/artificial reconstruction as exceptions. A deliberate suite-wide audit is needed; it is not appropriate to assume that every existing test requires modification.

## Scope

```text
rumiai-tests
affected target repositories only where current behavior/evidence must be checked
```

## Evidence

```text
TESTING.md
TEST-PATTERNS.md
rumiai-tests@298931c1dca03d44755893d64b9b3a7c0058b7ea:lib/rumiai-os-target.lib
rumiai-tests@298931c1dca03d44755893d64b9b3a7c0058b7ea:lib/rumiai-os-fixture.lib
rumiai-tests@298931c1dca03d44755893d64b9b3a7c0058b7ea:tests/rumiai-os/command/active-runtime-selection.test
rumiai-tests@298931c1dca03d44755893d64b9b3a7c0058b7ea:tests/rumiai-os/srv/lifecycle.test
```