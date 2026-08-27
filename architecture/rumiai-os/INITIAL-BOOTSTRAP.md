# RumiAI OS — Initial Bootstrap Architecture

Status: **Initial accepted architecture**  
Date: 2026-08-27

## 1. Scope

This document defines only the first stable bootstrap boundary of `rumiai-os`.

It deliberately excludes package management, software capability resolution, container/image/device deployment and the future complete OS architecture.

The goal is to establish a minimal relocatable system root and a stable entrypoint from which those subsystems can later be loaded.

---

## 2. Repository root contract

The root of `rumiai-os` contains only two files plus directories:

```text
rumiai-os/
├── rumiai-os
├── README.md
└── <directories>
```

`rumiai-os` is the unique primary entrypoint.

`README.md` is the root-level human documentation entrypoint.

No additional regular file is introduced at repository root without a new architectural decision.

---

## 3. Entrypoint responsibility

The root `rumiai-os` script is a **front controller**, not the implementation of the system.

Its responsibilities are limited to:

1. run under `#!/bin/sh`;
2. determine the RumiAI OS root according to the accepted bootstrap contract;
3. export the semantic root variable;
4. load/delegate to the internal bootstrap implementation;
5. propagate the resulting process exit status.

It must not accumulate package-manager, deployment, application, AI, or host-specific logic.

---

## 4. Root variable

The semantic root exposed by the entrypoint is:

```text
RUMIAI_ROOT
```

All paths managed by the system must ultimately derive from this root or from semantic roots explicitly configured by the system.

The initial bootstrap must not infer external resources from host-specific conventional paths.

---

## 5. Initial invocation contract

Supported:

```text
./rumiai-os
/path/to/rumiai-os
PATH=/path/to/repository:$PATH rumiai-os
```

The result must not depend on the caller current working directory.

Not initially supported:

```text
/path/to/symlink -> /actual/repository/rumiai-os
```

Symlink invocation must fail clearly until its semantics are separately specified and tested.

---

## 6. Internal delegation boundary

After root discovery, the entrypoint delegates to code located below the repository root.

Conceptually:

```text
rumiai-os
   │
   ├─ discover RUMIAI_ROOT
   │
   └─ delegate
          │
          ▼
   internal bootstrap
          │
          ├─ environment initialization
          ├─ command dispatch
          └─ future subsystems
```

The exact internal directory names are intentionally not fully frozen by this document.

Only directories justified by concrete subsystem boundaries should be introduced.

---

## 7. POSIX portability layer

Reusable low-level helpers are governed by:

```text
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
```

The portability layer is intentionally minimal.

It is not a Bash compatibility library and is not a general recreation of GNU utilities.

A primitive is added only when required by the architecture and after its contract can be tested.

---

## 8. Data-output baseline

The initial foundation may provide safe output primitives equivalent to:

```sh
printf '%s' "$value"
printf '%s\n' "$value"
```

These exist to standardize exact data emission where a reusable helper adds value.

They must not become wrappers that obscure normal POSIX behavior unnecessarily.

---

## 9. Static checks

Portable-core shell code must be eligible for automated static checks derived from the canonical rules and portability specification.

The initial enforcement prototype is validated by:

```text
rumiai-dev-PoCs/pocs/002-posix-bootstrap-foundation/
```

The stable repository should eventually contain or invoke an equivalent project check, but the exact development-tool placement is not fixed by this bootstrap architecture.

---

## 10. Promotion rule

Code from PoC 002 is a validated design candidate, not an automatic copy source.

Before entering `rumiai-os`, the stable implementation must:

1. preserve the accepted behavior;
2. comply with the canonical rules;
3. remain minimal;
4. avoid test-only behavior in the production entrypoint;
5. maintain the front-controller boundary.

---

## 11. Next architectural boundary

Once the stable bootstrap exists, the next subsystem to define should be the environment/package foundation recovered conceptually from the historical `m` project.

That work must keep separate:

```text
system definition
package resolution
package materialization/integration
deployment backend
```

so that hosted, container, image and device deployments can eventually share one logical system model without duplicating installation logic.
