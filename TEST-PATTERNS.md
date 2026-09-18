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

Copying files or fragments from the system under test must not be used to reconstruct its behavior artificially. Individual tests do not create target replicas for isolation; formal isolation is supplied by `rumiai-validate` according to `TESTING.md`.

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

## 6. Pattern: supplied validation environment

A permanent `.test` must use the target and process environment it receives. It does not create a second `rumiai-os` tree, a replacement `HOME`, or another private runtime/package environment merely to isolate itself.

Direct development execution therefore observes the real ambient target/environment. Formal execution through `rumiai-validate` observes the independent disposable clone and isolated mutable user-state roots prepared by the launcher. The same `.test` logic is used in both cases.

Scenario-specific files, processes and external-boundary fixtures remain legitimate when they are part of the property being exercised. They must be created inside or against the supplied environment and must not replace RumiAI-owned target components whose behavior is claimed by the test.

The historical `lib/rumiai-os-fixture.lib` replica mechanism is not a current authoring pattern under this contract; existing consumers must be realigned as part of the active suite-realignment task rather than copied into new tests.

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

## 9. Pattern: outbound-network bridge for an isolated auxiliary host

Use this pattern when the real test target can run on an auxiliary host, such as the ChatGPT-provided Linux VM, but that host has no usable outbound Internet access and the property requires real external repository/API/artifact data.

The goal is to preserve the real target execution path while replacing only the unavailable **external network transport boundary**.

### Capture and transfer

Use an Internet-enabled GitHub Actions runner as the capture/transport side of the bridge:

1. checkout every required repository at an exact revision;
2. fetch the required external API responses and artifacts from their real upstream endpoints;
3. verify available upstream integrity metadata such as size and digest before packaging;
4. record a small manifest containing the exact target revision(s), upstream identity, URL, size and digest relevant to the replay;
5. upload the repository snapshots, captured responses, artifacts and manifest as a workflow artifact;
6. download that workflow artifact into the isolated auxiliary host through the connected GitHub artifact interface.

The transferred target must be the exact real revision under test, not a reconstructed subset of files. Repository archives should preserve execution-relevant file modes and symlinks, and their hashes should be checked again on the receiving host when integrity matters.

### Repository/cache boundary

When the product already supports a validated local cache or offline fallback for an external Git repository, prefer that real product path rather than intercepting Git internals.

For example, a package-catalog cache may be populated with a real checkout whose branch, origin URL and working-tree state satisfy the product's normal cache validation. The product must still execute its normal refresh/fallback logic. A failed refresh followed by an explicitly supported cached-snapshot fallback remains a real product path.

Do not redefine the product function that owns the repository snapshot merely to make the test pass.

### HTTPS replay boundary

For upstream HTTPS calls that the product itself must perform:

1. start a temporary local HTTPS server on the isolated host;
2. serve the captured upstream response bytes and artifact bytes at the paths expected by the real target;
3. map only the required upstream hostname(s) to the local server with a temporary `/etc/hosts` entry;
4. create a temporary local CA and server certificate valid for those exact hostname(s);
5. add that CA to the host trust store for the duration of the test;
6. keep normal TLS verification enabled;
7. execute the real public target command unchanged.

The target should therefore still call its normal canonical HTTPS URL and traverse its real HTTP client, repository adapter, downloader, digest verifier, extractor/materializer, integrator and other components belonging to the claimed behavior. The replay server represents only the unavailable external service boundary.

Do **not** use this pattern to replace target functions, executables, adapters, catalogs, downloaders, extractors, integrators or other product logic with test doubles when the test claims to validate their composed behavior.

### Cleanup

The bridge is temporary host infrastructure. After the run:

- stop the local HTTPS server;
- restore `/etc/hosts` exactly to its prior state;
- remove the temporary CA/server certificates and any trust-store installation made for the test;
- remove temporary captured material that is not intentionally retained as revision-specific evidence;
- leave product repositories and normal host networking semantics unchanged.

A failed test must attempt the same cleanup.

### Evidence classification

A successful replay run proves that the real target path handled the exact captured external inputs on the exercised host. It is useful for bug reproduction, POSIX/host validation and development of permanent tests.

It does **not** by itself prove that the live upstream still returns the same data later. When live-upstream behavior is material, complement replay evidence with a real Internet-enabled run, typically the same permanent test on GitHub Actions using the exact committed target and suite revisions.

The two forms of evidence are complementary:

```text
isolated-host HTTPS replay
    real target + exact captured external inputs + otherwise unavailable host

Internet-enabled GitHub Actions
    real target + live external services + clean hosted environment
```

The replay mechanism should be promoted into a shared `rumiai-tests` helper only when multiple permanent tests actually need the same infrastructure responsibility. Until then, this documented pattern is sufficient and avoids creating an abstraction without demonstrated reuse.

## 10. Rule for new tests

Before adding infrastructure code to a `.test`, check in this order:

1. can the behavior be exercised through the real entrypoint required by the contract?
2. is the test using the target/environment supplied by its caller rather than creating a replacement environment?
3. do any fixtures/fakes represent only allowed external inputs or boundaries rather than replacing behavior claimed as verified?
4. does a library under `lib/` already provide the same responsibility?
5. is there an existing documented pattern?
6. is the additional logic genuinely specific to the property under test?
7. does the new test protect a property distinct from those already covered?
8. is future maintenance cost proportional to the risk?

If the answers point to reuse or merging, do not create a new copy or a new test merely for formal isolation.

When a property is common across multiple hosts, prefer the same real `.test` on those environments rather than host-specific copies. Necessary differences should remain in infrastructure or abstractions already provided by the contract, not duplicate test semantics.
