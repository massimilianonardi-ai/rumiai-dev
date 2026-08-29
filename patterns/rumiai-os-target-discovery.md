# Test pattern — RumiAI OS target discovery

Date: 2026-08-29
Status: **physically validated reference pattern**

## Problem

Permanent tests for `rumiai-os` must locate the product checkout without assuming a host-specific absolute path and without requiring the runner to discover the target for them.

The operator-facing physical test contract remains:

```text
cd <rumiai-os>
git pull --ff-only
cd <rumiai-tests>
git pull --ff-only
./rumiai-test <selection>
```

All target discovery belongs inside each autonomous `.test`.

## Level-2 reference implementation

Canonical reference implementation:

```text
massimilianonardi-ai/rumiai-tests@5af68cbff09ce979df3dff91e398e287eadd48b7:lib/rumiai-os-target.lib
```

The implementation is intentionally an authoring reference, not a mandatory runtime dependency of permanent tests.

Tests that need the primitive should normally copy the required functions inline and preserve the immutable provenance comment.

## Discovery contract

The primitive supports two paths.

### Explicit override

If:

```text
RUMIAI_TEST_RUMIAI_OS_ROOT
```

is non-empty, that pathname is validated as the requested checkout.

An invalid explicit override is a test failure rather than a silent fallback to another checkout.

### Structural discovery

Without an override, the primitive starts from a caller-supplied directory and walks upward through its physical ancestors.

A candidate is accepted only when:

- `<candidate>/rumiai-os` is a regular file;
- `git` can inspect the candidate repository;
- `remote.origin.url` identifies `massimilianonardi-ai/rumiai-os` using one of the accepted HTTPS/SSH forms;
- the candidate directory can be canonicalized physically.

The returned value is therefore a physical absolute checkout root, not merely a pathname that happens to contain a file named `rumiai-os`.

## Why Git identity is part of validation

The tests repository normally lives below:

```text
<rumiai-os>/.dev/rumiai-tests
```

but the primitive must not encode that layout as an unquestioned identity rule.

Walking ancestors finds structural candidates; checking the Git origin distinguishes the intended product checkout from an unrelated directory containing a similarly named executable.

This is discovery of the local target under test, not network access and not remote-state verification.

## Status mapping

The reference implementation distinguishes:

```text
0  target found
1  no target checkout found
2  explicit override supplied but invalid
3  discovery infrastructure error
```

Individual tests map these statuses to their own PASS/FAIL/SKIP/ERROR contract.

## Physical validation

The self-test:

```text
tests/rumiai-tests/lib/rumiai-os-target-reference.test
```

and the first seven permanent bootstrap tests were executed as part of the complete `rumiai-tests` suite at:

```text
fd9d56cb24d1eb0a01b3ce8903569566d980ad40
```

Observed on both stable hosts:

```text
PASS   16
FAIL   0
SKIP   0
ERROR  0
TOTAL  16
```

Hosts:

- macOS;
- Ubuntu 26.04 ARM64.

This closes the validation gate for `rumiai-os-target.lib@5af68cbf...` and makes that immutable version a canonical source for new inline copies until superseded by a separately validated version.

## Promotion status

This capability remains **level 2**.

It is a general test-authoring facility, but there is currently no demonstrated product-runtime requirement for `rumiai-os` itself to discover a development checkout by Git origin. Promotion to a product tool would therefore mix development infrastructure into the runtime without a concrete architectural need.
