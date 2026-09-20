# RumiAI OS — Terminal pager

Status: **Current / normative**  
Updated: 2026-09-20

This specification defines the current host-neutral terminal pager wrapper provided by `m`.

## Ownership

The public command is:

```text
pager
```

`pager` belongs to the technical `m` substrate and is located at:

```text
bin/sys/pager
```

`pager` is intentionally independent from the `m` runtime and uses:

```sh
#!/bin/sh
```

Its responsibility is deliberately narrow: select the preferred available pager backend and delegate input to it without adding a second presentation policy.

## Public interface

The interface is:

```text
pager [file ...]
```

With no file operands, the selected backend reads standard input.

With one or more file operands, `pager` passes those operands to the selected backend unchanged and in the original order.

`pager` does not resolve or validate file operands before delegation. File opening, diagnostics and file-related failure behavior belong to the selected backend.

The command does not define its own pager options or attempt to reproduce the option sets of `less` or `more`.

## Delegation model

`pager` is only a backend-selection wrapper.

It does not:

```text
inspect whether stdin or stdout is a terminal
switch to cat for pipes or redirections
pre-read, concatenate or rewrite input
resolve or validate file paths
normalize backend diagnostics
normalize backend exit statuses
```

The selected backend therefore receives the caller's standard streams and file operands directly. Interactive and non-interactive behavior follows that backend's own semantics.

## Backend policy

The backend policy is capability-based and host-neutral:

```text
less available
    -> less

less unavailable
    -> more
```

`less` is the preferred optional capability. `more` is the POSIX baseline fallback.

The choice depends only on whether `less` is available through the current command environment; it does not depend on operating-system identity.

## Caller environment

`pager` preserves the caller environment.

Environment consumed by the selected backend, including variables such as `LESS`, `LESSOPEN` and `LESSCLOSE`, is neither cleared nor rewritten by `pager`.

The first implementation exposes no separate backend-selection configuration, arbitrary backend command string or user-selected backend mechanism.

## Exit status

`pager` does not define a normalized exit-status layer.

The observable status is the status of the selected backend, or the shell execution failure status if that backend cannot be executed.

## Relationship with `manual`

Normal `manual` topic presentation delegates the selected topic file to `pager`.

`manual` owns documentation lookup and `--no-pager`; `pager` owns only the `less` / `more` backend choice and transparent delegation.

A caller that requires direct output rather than pager semantics bypasses `pager`. For example, `manual --no-pager` writes the selected topic directly.

## Invariants

```text
PAGER-01  pager belongs to m and is exposed as bin/sys/pager
PAGER-02  pager is a standalone POSIX-sh wrapper and does not depend on the m runtime
PAGER-03  zero file operands delegates standard input to the selected backend
PAGER-04  file operands are forwarded unchanged and in order to the selected backend
PAGER-05  pager does not inspect terminal state or substitute direct-output behavior
PAGER-06  every current host prefers less when available and otherwise falls back to more
PAGER-07  backend selection is capability-based rather than OS-name-based
PAGER-08  pager preserves caller environment consumed by the selected backend
PAGER-09  pager does not normalize backend diagnostics or exit statuses
PAGER-10  manual normal presentation delegates to pager
```
