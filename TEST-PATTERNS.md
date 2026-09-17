# RumiAI Test Authoring Patterns

This document collects reusable patterns and primitives for `rumiai-tests`. `TESTING.md` remains the normative contract.

## 1. Principle

When multiple tests share the same infrastructure responsibility, knowledge must not be duplicated merely to obtain false independence.

Priority order:

```text
1. observable behavior of the real target
2. authenticity of the verified execution path
3. state/order independence between tests
4. reuse of stable common infrastructure
5. minimum amount of test code required
```

## 2. Reuse levels

A reusable technique may live as:

```text
documented pattern
shared rumiai-tests library
general rumiai-os tool, only when also useful to the product
```

Promotion into `rumiai-os` is not automatic.

## 3. Shared libraries

A library under `rumiai-tests/lib/` is appropriate for common responsibilities such as:

- target discovery;
- creation of complete, disposable isolated replicas of the target;
- preparation of external input or fixtures only at boundaries allowed by `TESTING.md`;
- path normalization;
- temporary-resource primitives;
- drivers for interactive programs;
- other infrastructure that is not specific to the property being verified.

Tests may source those libraries directly. The exact `rumiai-tests` revision recorded by validation makes the used library version reproducible.

A shared library must be small, have a clear responsibility and receive proportional tests. A test library must not become an alternative implementation of target behavior.

### Inline copying

Inline copying is no longer the default.

It is allowed only when:

1. the copied primitive is intentionally part of the test-specific semantics; or
2. freezing that version inside the test is materially necessary and the reason is documented in the file.

The desire to avoid a dependency on the same suite revision is not sufficient justification by itself.

Existing historical inline copies should be migrated when they create duplicated maintenance or drift; they do not need to be rewritten all at once when the risk exceeds the benefit, but no new copy should be introduced without justification.

Copying files or fragments from the system under test must not be used to reconstruct its behavior artificially. When isolation is required, use the complete replica defined by `TESTING.md`.

## 4. Test the contract through the real target

To verify behavior, use the real public entrypoint when the contract allows it and observe directly:

- arguments and inputs actually accepted;
- output;
- exit status;
- produced files;
- mode/ownership;
- state transitions;
- other observable effects that belong to the contract.

Fixtures, fakes, stubs or synthetic input may be used only to represent an external boundary explicitly allowed by `TESTING.md`. They must not replace functions, executables, adapters, catalogs, downloaders, extractors, integrators or other target components when the test claims to verify the real composed behavior that traverses them.

Avoid source grep, private function names, line numbers and comparisons of non-canonicalized pathnames when those details are not the contract.

## 5. Pattern: `rumiai-os` target

The current reference implementation is:

```text
lib/rumiai-os-target.lib
```

`rumiai-os` tests that share the normal discovery contract should source this library instead of copying its functions.

A test may use a different strategy only when discovery itself is the property under test or when a different documented requirement exists.

## 6. Pattern: isolated runnable `rumiai-os` replica

The current reference implementation retains the historical name:

```text
lib/rumiai-os-fixture.lib
```

Its correct contract is not to construct a fake `rumiai-os`, but to create an isolated replica of the real runtime/product and separate only the mutable state required by the test.

Tests that need the normal isolated runtime replica should source this library when its contract matches the property being verified. The replica must come from the real revision under test and must contain the real entrypoints and components required by the normal execution path. If the product layout evolves, the shared library must be realigned so the replica remains semantically complete for the properties that use it.

The historical `fixture` name of the library does not authorize tests to replace target parts with artificial implementations. If a test requires the real behavior of a part not present in the replica, the replica is insufficient and must be corrected, or the test must use the appropriate real target directly.

A change to the standard product layout should therefore be realigned once in the shared library and in tests that explicitly verify that layout, rather than in many infrastructure copies.

## 7. Pattern: interactive programs through a TTY

The current reference implementation is:

```text
lib/interactive.lib
```

It drives programs that read from a real TTY/pseudo-terminal without requiring manual interaction.

Current host strategy:

```text
macOS / Darwin: expect(1), explicit wait for the prompt
Linux:          util-linux script(1) with prepared input
```

Dialog format:

```text
<exact prompt><TAB><response>
```

Observed failure modes that must not be reintroduced:

- BSD/macOS `script(1)` is not interchangeable with util-linux for this scenario;
- in Tcl/Expect, `[y/N]` inside double quotes is syntax, not literal text;
- dynamic prompts must be treated as data and matched exactly;
- timeout and EOF must produce useful diagnostics;
- the transcript must remain observable when the test fails.

Changes to this library require proportional tests before relying on the changed behavior.

## 8. Pattern: headless GUI

A GUI may be exercised headlessly when the verified property does not depend on the complete physical desktop.

The correct pattern is to launch the real application with its real toolkit and required real services while providing only non-physical execution infrastructure, for example:

```text
virtual display
session bus
accessibility stack
real application
test input/driver
```

Technologies such as Xvfb, D-Bus and AT-SPI may be used when appropriate for the application and host. They are not themselves target simulation: they are execution infrastructure as long as the application code, GTK and other components that belong to the property remain real.

The test must limit its conclusion to properties actually exercised. A headless environment without GNOME Shell, Mutter/Wayland, portals, keyring, graphics acceleration or another desktop integration cannot validate behavior that depends on those components.

## 9. Rule for new tests

Before adding infrastructure code to a `.test`, check in this order:

1. can the behavior be exercised through the real entrypoint required by the contract?
2. if isolation is needed, is the replica complete and derived from the real target revision?
3. do any fixtures/fakes represent only allowed external inputs or boundaries rather than replacing behavior claimed as verified?
4. does a library under `lib/` already provide the same responsibility?
5. is there an existing documented pattern?
6. is the additional logic genuinely specific to the property under test?
7. does the new test protect a property distinct from those already covered?
8. is future maintenance cost proportional to the risk?

If the answers point to reuse or merging, do not create a new copy or a new test merely for formal isolation.

When a property is common across multiple hosts, prefer the same real `.test` on those environments rather than host-specific copies. Necessary differences should remain in infrastructure or abstractions already provided by the contract, not duplicate test semantics.
