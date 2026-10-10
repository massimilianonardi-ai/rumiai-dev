# RumiAI OS — Diagnostics and observability

Status: **Current / normative**  
Updated: 2026-10-10

This specification defines the current diagnostic, failure-status and observability contract for `m`- and RumiAI-owned code.

Its purpose is to make failures locatable rather than merely detectable, preserve enough operational evidence to debug non-fatal inconsistencies before they surface as larger failures, and prevent distinct control-flow branches from being flattened into indistinguishable status codes or log messages.

## 1. Scope

This contract applies to `m`- and RumiAI-owned commands, libraries and other runtime code whenever they:

- return or exit because a distinct failure branch was taken;
- emit `fatal`, `error`, `warn`, `info`, `debug` or `trace` diagnostics;
- propagate a failure from a called function, command, process or external capability;
- deliberately omit logging from a significant operational path.

It defines semantic rules independent of one implementation language. POSIX-shell status constraints are stated explicitly where relevant.

Localization remains owned by `LANG-BOOTSTRAP.md`. A localized message is presentation data for a diagnostic identity; localization does not define the identity or failure semantics.

## 2. Failure-branch identity and local status codes

Success status is:

```text
0
```

Within one callable — for example one function, command entrypoint or deliberately status-bearing subprocess boundary — each distinct handled failure branch MUST have a distinct local non-zero status code unless another explicit contract requires preservation of an external status.

For a newly designed callable, local failure codes are allocated incrementally beginning at `1`:

```text
first distinct failure branch     1
second distinct failure branch    2
third distinct failure branch     3
...
```

The purpose is diagnostic branch identity, not semantic categorization. Two different failures MUST NOT be assigned the same status merely because both are, for example, invalid input, filesystem failures or execution failures.

### Stability after allocation

Allocation order applies when a code is first assigned. Once a status has become part of the implementation/API observed by callers, tests, manuals or diagnostics, it MUST NOT be renumbered merely to keep source-order numbering contiguous.

If a new failure branch is later inserted between existing branches, it receives the next unused local code rather than shifting established codes.

A deliberate change to an established status is an interface change and requires all affected callers, tests and operational documentation to be realigned in the same authorized work unit.

### Local mapping of child failures

A caller that invokes another callable normally assigns its own local status to the branch:

```text
child callable failed here
```

rather than blindly forwarding the child's numeric status.

For example, in shell:

```sh
child_operation || return 7
```

is normally preferable to:

```sh
child_operation || return $?
```

when `7` identifies the caller's own branch. The child status SHOULD be retained as diagnostic context when it materially helps investigation.

Direct status preservation is valid only when the current contract intentionally defines the caller as a transparent/pass-through status boundary or when an external protocol/API requires that exact status.

### Exhaustion and externally defined statuses

Do not wrap, silently reuse or compress local failure identities when the available status space becomes insufficient.

For POSIX-shell command/process statuses, if a callable would approach exhaustion of the usable `1..255` space, stop incremental allocation and design a specific representation for that callable before adding further failures.

Statuses whose meaning is imposed externally — including intentionally preserved child-command statuses or signal-related process statuses — are not automatically part of the callable's local sequential allocation. Their interaction with local diagnostic statuses must be explicit when ambiguity is possible.

## 3. Diagnostic identity

A logged diagnostic is identified by the current `log` identity pair:

```text
<domain>.<message-id>
```

Distinct logged failure branches MUST have distinguishable diagnostic identities.

A broad message such as:

```text
execution.execution-failed
```

MUST NOT be reused for multiple semantically distinct failure branches merely by varying a generic field such as `reason` when that reuse prevents the emitting branch from being identified directly.

The diagnostic identity MUST describe the semantic operation and exact failure condition precisely enough to locate the owning failure branch. For example:

```text
srv.start.state-publish-failed
srv.start.provider-resolution-failed
srv.start.exited-during-start
```

This can be represented through domain/message-id boundaries appropriate to the current logging facility; the important invariant is semantic uniqueness and locatability, not one fixed dot partition.

Diagnostic identities are semantic and stable. Source line numbers, transient implementation positions or other unstable coordinates MUST NOT be used as the primary identity.

## 4. Diagnostic message and fields

The localized diagnostic message MUST be concise, clear and specific enough to explain the failure represented by its identity.

Structured fields carry occurrence-specific context. A diagnostic MUST include the information materially needed to investigate the failure when that information is available and safe to expose, such as:

```text
operation / phase
object or service identity
path
provider/backend
requested value
effective value
child status
host capability
relevant state identifier
```

A diagnostic MUST NOT require a developer to infer which branch emitted it solely from a generic message plus trial-and-error reproduction when the code can provide a branch-specific identity.

Fields complement the diagnostic identity; they do not substitute for it.

Secrets, passwords, authentication material, private keys, tokens and other values whose disclosure would violate their security boundary MUST NOT be logged. Sensitive inputs must be omitted, redacted or represented only by non-sensitive metadata when useful.

## 5. Severity semantics

The current severity hierarchy is:

```text
fatal
error
warn
info
debug
trace
```

Their semantic responsibilities are:

```text
fatal
    an unrecoverable failure at the current command/process boundary;
    the operation terminates after emitting the diagnostic

error
    an operation failed, but the current layer may return control,
    aggregate the failure or continue through another valid path

warn
    an anomaly, degradation, fallback or recovered inconsistency occurred;
    execution can continue but the condition is operationally significant

info
    a significant normal operational/lifecycle transition occurred

debug
    an internal decision, resolved value, selected provider/backend,
    fallback choice or other state useful for debugging was established

trace
    detailed execution flow, important boundary entry/exit, branch selection
    and status propagation needed to reconstruct how execution reached a state
```

Severity is not a substitute for diagnostic identity. Different branches remain distinguishable even when they use the same severity.

## 6. Observability is part of implementation

Logging is part of the implementation contract for non-trivial operational flows; it is not optional instrumentation added only after a failure becomes difficult to reproduce.

A non-trivial flow MUST provide enough proportional `info`, `debug` and `trace` events that, at the appropriate enabled log level, a developer can reconstruct the significant lifecycle transitions, decisions, fallback/degradation choices and failure propagation that led to an outcome, unless a concrete omission allowed by section 7 applies.

This does not require logging every statement or every function call. Logging volume must remain proportional and useful.

In particular:

- significant externally meaningful transitions belong at `info` when their routine visibility is useful;
- hidden choices and resolved internal state that materially affect behavior belong at `debug`;
- detailed path reconstruction and propagation boundaries belong at `trace`;
- an unexpected condition that is recovered or degraded rather than failed belongs at `warn`.

Debug/trace filtering is the normal way to keep detailed diagnostics out of ordinary output. The mere fact that a diagnostic is verbose is not sufficient reason to omit it from the implementation.

## 7. Deliberate logging omissions

A significant operational path may omit otherwise useful logging only for a concrete reason.

Valid reasons can include:

- bootstrap execution before the logging facility is safely available;
- implementation of `log` itself or a recursion-sensitive logging dependency;
- a demonstrated hot-path performance constraint where logging cost is material;
- a protocol/output boundary whose correctness would be violated by the emission;
- a security/privacy boundary that prevents safe diagnostic disclosure.

The omission MUST be deliberate, explicit and reviewable. Its concrete reason MUST be recorded near the affected code when it is implementation-specific, or in the applicable current specification when it is a durable subsystem-wide constraint.

Implementation convenience, generic fear of verbosity, or the existence of an error return by itself is not sufficient justification.

Where the normal `log` facility is unavailable, a bootstrap/fallback diagnostic may be written directly to standard error. It must still be as specific as the available bootstrap context permits.

## 8. Logging ownership and failure propagation

One underlying failure MUST NOT produce redundant equivalent `error`/`fatal` messages at every stack or call layer.

The preferred model is:

```text
status
    transports failure between call boundaries

debug / trace
    may record propagation and boundary context

error / fatal
    is emitted at the layer that owns enough semantic context
    to diagnose the failure meaningfully
```

A lower-level helper may return a distinct status without logging when it does not own enough context for a useful diagnostic.

A caller may emit a new error diagnostic when it introduces a new semantic failure boundary or adds materially useful context. It MUST NOT merely repeat the same diagnostic under another generic message.

When useful, propagation diagnostics include the child/cause status as a field rather than replacing the caller's own branch identity with it.

## 9. Operational documentation and testing

Publicly observable command/library statuses and diagnostic behavior are part of the normal implementation/manual consistency obligation when they are relevant to operators or callers.

Permanent tests SHOULD protect diagnostic properties proportionally, including where applicable:

- distinct representative failure branches return the intended stable statuses;
- representative failure branches expose distinguishable diagnostic identities;
- context fields needed for diagnosis are present without leaking protected values;
- severity filtering preserves the intended event visibility;
- debug/trace paths expose critical decisions or propagation behavior where that observability is itself material.

Tests should prefer stable diagnostic identity and structured fields over localized prose, timestamps or incidental formatting unless those are themselves the contract.

A passing success-path test does not establish diagnostic quality for failure paths that were not exercised.

## 10. Child-process log-level transformation

This specification does not currently define automatic attenuation, amplification or depth-based transformation of the effective log level across child processes.

Do not infer such a mechanism from historical implementations. Any future child-process log-level policy requires an explicit current design based on present logging semantics and process boundaries.

Ordinary environment inheritance of the currently configured log level remains a separate implementation fact until such a contract is promoted.

## 11. Invariants

```text
DIAG-01  success status is 0
DIAG-02  distinct handled failure branches within one callable use distinct local non-zero statuses unless an explicit pass-through/external-status contract applies
DIAG-03  new local failure statuses are initially allocated incrementally from 1
DIAG-04  established statuses are stable and are not renumbered merely to preserve source-order contiguity
DIAG-05  local status exhaustion is handled by a specific design; codes are not wrapped or silently reused
DIAG-06  distinct logged failure branches have distinguishable stable diagnostic identities
DIAG-07  generic message identities plus a varying reason field do not replace branch-specific diagnostic identity
DIAG-08  diagnostic fields preserve materially useful, non-sensitive investigation context
DIAG-09  fatal/error/warn/info/debug/trace have distinct semantic responsibilities
DIAG-10  proportional observability is part of non-trivial implementation, including useful info/debug/trace coverage
DIAG-11  significant logging omissions require a concrete performance, bootstrap, protocol/output or security reason
DIAG-12  equivalent failure messages are not redundantly emitted at every propagation layer
DIAG-13  child failures are normally mapped to the caller's local branch status; exact downstream status propagation is explicit
DIAG-14  diagnostic output never exposes secrets merely to improve observability
DIAG-15  automatic child-process log-level transformation is not currently specified
```
