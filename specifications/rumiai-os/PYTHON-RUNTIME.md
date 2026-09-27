# Python runtime integration

Status: **Current / canonical**  
Updated: 2026-09-27

This specification defines the current RumiAI / `m` integration policy for software that requires Python.

General implementation-language selection remains governed by `RULES.md`. Python is not a preferred language for new RumiAI-owned development, but external software and concrete technical requirements may require it.

## 1. General application model

The current general model for externally sourced Python applications is a **private application environment managed with micromamba / Conda**.

RumiAI does not require those applications to consume a shared, late-bound Python interpreter facility.

The application environment owns the complete Python execution set required by that application, including as applicable:

```text
Python interpreter
standard library
Python packages
native Python extensions
runtime libraries
generated Python command launchers
application-managed optional packages/plugins
```

The application or its upstream installation/runtime logic may install requirements, update Python packages, install plugins or otherwise mutate that private environment when its normal behavior requires it.

RumiAI must not redirect those arbitrary mutations into another application's environment, a shared Python runtime, or an immutable package payload.

A Python `venv` is not required on top of the micromamba environment merely to satisfy the RumiAI model. If an upstream application explicitly expects or creates a venv, that venv remains part of the application's private environment/state responsibility.

## 2. State and relocatability boundary

A Python application environment is **mutable, application-owned, reconstructible state**.

It does not create a second Python-specific state tree. Its mutable paths must use the existing `STATE-MODEL.md` scopes, owners, identities and areas:

- an upstream environment that is intentionally part of the application's compatibility HOME may live under package `home`;
- an environment payload may use `cache` only when it is genuinely non-authoritative and can be deleted and recreated from authoritative information;
- authoritative application choices needed to reconstruct runtime packages or plugins belong in the appropriate existing `conf` or `data` state rather than being recoverable only from a disposable environment.

It is not part of the immutable package payload and is not required to remain byte-for-byte runnable after its installation prefix changes.

This boundary is deliberate. Real Python/Conda environments may contain absolute installation prefixes in generated launchers, package metadata, native artifacts or other files. RumiAI therefore does not attempt to rewrite or normalize every arbitrary environment mutation in order to manufacture a stronger relocation property than the upstream ecosystem provides.

When a RumiAI installation moves and an application's Python environment is no longer valid at the new prefix, the supported recovery model is:

```text
detect/reject stale environment
    -> recreate the private environment at the live location
    -> reinstall the application's declared/runtime requirements
    -> continue from the reconstructed environment
```

The exact existing state area(s) and lifecycle command used by an individual application remain owned by that package/application integration unless and until a generic current contract is promoted. Consumers must use `state-path` and must not duplicate the physical state-tree layout.

## 3. Python-version changes

Changing the Python version used by an application invalidates the populated Python environment as a reusable compatibility unit.

The normal model is therefore:

```text
change Python version
    -> create/recreate application environment
    -> reinstall Python packages for that interpreter/environment
```

RumiAI does not attempt to preserve a populated application's `site-packages` across Python-version changes by classifying and selectively reusing pure-Python, `abi3` and CPython-minor-specific artifacts.

This keeps interpreter/package compatibility in the application environment manager and upstream Python packaging ecosystem rather than turning `pkg` into a second Python environment manager.

## 4. Provider/default/binding boundary

The normal external-application Python model does **not** use `pkg` facility default/binding as a live Python-version switch for an already-populated application environment.

A package/provider facility may still be appropriate for another independently justified capability, but the existence of the `pkg` provider mechanism does not imply that arbitrary Python applications must share or late-bind their interpreter.

No current contract requires a public shared Python/CPython facility for general external Python applications.

## 5. Retained standalone-runtime engineering result

The standalone/shared-interpreter investigation produced useful technical results and is intentionally retained even though it is not the adopted general Python-application model.

Detailed executable evidence remains in `rumiai-dev-PoCs`; the findings below are a stable engineering index so they are not rediscovered from scratch.

### PoC 038 — environment late binding

`pocs/038-python-environment-late-binding`

- ordinary venv/pip-generated commands can embed absolute interpreter paths and fail after movement;
- `#!/usr/bin/env python` can follow the existing `pkg` provider/default/binding PATH projection without rewriting the consumer command;
- CPython native-extension compatibility is a separate concern from interpreter selection;
- runtime bytecode can mutate package roots and retain source paths unless explicitly redirected.

### PoC 039 — python-build-standalone provider

`pocs/039-python-build-standalone-provider`

A pinned `astral-sh/python-build-standalone` CPython artifact was validated on Linux and macOS for:

- direct runtime movement;
- live `sys.prefix` relocation;
- tested `sysconfig` path relocation;
- SSL, SQLite and ctypes use;
- native-extension build after movement;
- RumiAI provider/consumer execution;
- complete managed-root movement without retaining the tested old prefix.

This established `python-build-standalone` as a strong relocatable CPython-runtime candidate for a controlled use case.

### PoC 040 — micromamba / Conda prefix relocation

`pocs/040-micromamba-python-prefix-relocation`

The interpreter itself remained usable after a raw prefix move, but the complete environment retained extensive original-prefix material and generated commands such as direct `pip` launchers were not reliably relocatable.

This evidence is the reason the adopted micromamba model treats the application environment as **reconstructible state**, not as a path-independent immutable package.

### PoC 041 — relocated standalone Python build path

`pocs/041-relocated-standalone-python-sdist-build`

A relocated standalone CPython successfully used the existing pip / isolated PEP 517 build path to produce pure and native wheels on Linux and macOS. Redirecting build bytecode prevented the build from contaminating the runtime with new location-sensitive cache files.

### PoC 042 — bytecode state cache

`pocs/042-python-bytecode-state-cache`

`PYTHONPYCACHEPREFIX` successfully redirected runtime bytecode into disposable state instead of the immutable consumer package root and remained regenerable after relocation.

### PoC 043 — consumer package visibility

`pocs/043-python-consumer-package-visibility`

Bare `PYTHONPATH` did not provide complete normal site-directory semantics because consumer `.pth` processing was missing. `site.addsitedir()` and `PYTHONUSERBASE` processed the tested site semantics, while `PYTHONUSERBASE` exposed interpreter/platform-dependent layout differences.

### PoC 044 — wheel compatibility

`pocs/044-python-wheel-compatibility`

Pure-Python, `abi3` and CPython-minor-specific wheels have materially different interpreter-compatibility requirements. Wheel-tag validation is therefore a required trusted boundary for any future controlled wheel materializer.

### PoC 045 — PyPA installer command materialization

`pocs/045-pypa-installer-env-python`

PyPA `installer` can be specialized narrowly so POSIX Python commands are emitted with:

```text
#!/usr/bin/env python
```

without replacing the upstream wheel traversal, placement, RECORD and structural-install machinery.

### PoC 046 — provider-side consumer site hook

`pocs/046-python-provider-consumer-site-hook`

A static provider-side startup hook can read a live consumer-site projection and call `site.addsitedir()` without embedding provider or consumer installation paths. The tested provider, consumer commands, `.pth` behavior and child Python processes survived relocation.

### PoC 049 — facility compatibility mapping

`pocs/049-python-facility-compatibility`

A naive split into independent generic-Python and CPython facilities was rejected because both attempted to expose the same public `python` command and could select incoherent providers.

A single CPython-runtime facility experiment showed that existing dotted `pkg` compatibility levels and exact/range constraints can model the tested pure/range, `abi3`/range and CPython-minor/exact cases and can reject an incompatible selected provider before target execution.

## 6. Evaluation conclusion

The investigation demonstrated that a **controlled** relocatable CPython provider plus controlled consumer wheel materialization is technically viable for the tested Linux/macOS cases.

It did **not** establish that arbitrary externally developed Python applications can freely mutate their Python environment while that complete environment remains permanently prefix-independent. Achieving that stronger property would require RumiAI to own or intercept too much of pip/venv/Conda/script/native-package behavior.

RumiAI therefore does not adopt the standalone/shared-interpreter design as its general Python application model.

The engineering result remains valid reference material for a future concrete, controlled requirement, but such reuse would require a new explicit task and must not be inferred as current architecture.

## 7. Provenance and licensing note

If `python-build-standalone` is ever reused for a future controlled requirement, its produced Python distribution must be treated as a multi-component binary artifact rather than as merely MPL-2.0 because CPython and bundled libraries retain their own licenses.

Artifact version, digest, bundled-license inventory and included license texts must be preserved according to the normal package provenance requirements.

This licensing point did not block the evaluated standalone composition and is not a reason for the current micromamba application-environment choice.

## 8. Current invariants

```text
PY-01  Python is governed by the project-wide implementation-language preference in RULES.md.
PY-02  General external Python applications use a private micromamba/Conda application environment.
PY-03  That Python environment is mutable, application-owned and reconstructible state under the existing state model, not immutable package payload.
PY-04  Applications may manage their own requirements, optional packages and plugins inside that private environment.
PY-05  The private environment is not guaranteed byte-for-byte relocatable across prefix changes; stale environments are rebuilt.
PY-06  Changing the application's Python version rebuilds the application environment and reinstalls its Python packages.
PY-07  The general external-application model does not use pkg provider default/binding as a live Python-version switch for a populated environment.
PY-08  No current contract requires a shared public Python/CPython facility for general external Python applications.
PY-09  The standalone/shared-interpreter PoCs remain engineering evidence, not adopted general Python architecture.
```
