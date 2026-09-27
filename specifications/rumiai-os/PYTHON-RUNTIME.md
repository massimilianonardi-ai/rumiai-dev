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

## 5. `python-env` facility contract

The public facility identity for the application Python-environment-management capability is exactly:

```text
python-env
```

`python-env` denotes the provider-independent capability to create, execute within and remove/rebuild an application-private Python environment at a caller-resolved managed-state location.

It does **not** denote a Python interpreter and it is not a synonym for the Python standard-library `venv` mechanism.

### Compatibility level 1

The first public contract level is:

```text
python-env =1
```

Its required typed surface is one `cmd` member named exactly:

```text
python-env
```

The command syntax is:

```text
python-env create <environment> <python-version>
python-env run <environment> -- <command> [<arg>...]
python-env remove <environment>
```

A `<python-version>` token has one of exactly these forms:

```text
<major>.<minor>
<major>.<minor>.<patch>
```

Each component is canonical unsigned decimal (`0` or a non-zero digit followed by decimal digits; no leading zeroes). A major/minor request selects an available patch release in that Python major/minor family. Supplying the patch component selects that exact Python patch release; provider-specific build revisions remain outside this token.

`<environment>` is an absolute pathname supplied by the consumer. The consumer resolves its location through the applicable managed-state contract; `python-env` does not invent another state tree or select an application state location.

For level 1:

- `create` requires an absent target pathname, creates a private environment containing the requested Python version and a usable `python -m pip`, and must not perform persistent caller-shell activation or global environment mutation;
- `run` requires a recognized environment, executes the requested command inside it without persistent caller-shell activation, preserves the argument vector and standard input/output/error streams, and returns the child execution status;
- `remove` requires a recognized environment and removes that environment without deleting an unrelated caller-owned pathname;
- a Python-version change is represented by removing/recreating the environment and reinstalling the consumer's Python packages rather than migrating populated `site-packages`;
- invalid command syntax returns the normal command-usage error class, while invalid/missing environment state or provider execution failure is an operational failure.

The facility contract deliberately does not define:

```text
requirements-file format
dependency resolution policy
plugin/update policy
Conda channels as a consumer-facing interface
GPU/CUDA/ROCm policy
environment migration across Python versions
provider-specific cache/root configuration
```

Those responsibilities remain with the consumer application or concrete provider implementation as applicable.

The Python interpreter version and the Python/package set installed inside an application environment belong to that consumer environment definition. They are not the compatibility level of the `python-env` facility.

The first concrete provider is the `micromamba` package. Its provider realization must expose the provider-independent `python-env` command through a provider-specific adapter rather than exposing raw micromamba CLI semantics as the facility contract. Provider selection therefore chooses the environment-management implementation, not the Python version used inside a populated application environment.

PoC 053 (`pocs/053-python-env-micromamba-adapter`) validated this level-1 behavioral shape with micromamba 2.9.0-0 on hosted Ubuntu 24.04 and macOS 14: create with Python/pip, target protection, argv preservation, stdin/stdout/stderr and child-status propagation, caller-shell isolation, remove and remove/recreate from Python 3.12 to 3.13 all passed. This is Linux/macOS evidence; it does not by itself establish a Windows provider realization.

## 6. Retained standalone-runtime engineering result

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

## 7. Evaluation conclusion

The investigation demonstrated that a **controlled** relocatable CPython provider plus controlled consumer wheel materialization is technically viable for the tested Linux/macOS cases.

It did **not** establish that arbitrary externally developed Python applications can freely mutate their Python environment while that complete environment remains permanently prefix-independent. Achieving that stronger property would require RumiAI to own or intercept too much of pip/venv/Conda/script/native-package behavior.

RumiAI therefore does not adopt the standalone/shared-interpreter design as its general Python application model.

The engineering result remains valid reference material for a future concrete, controlled requirement, but such reuse would require a new explicit task and must not be inferred as current architecture.

## 8. Provenance and licensing note

If `python-build-standalone` is ever reused for a future controlled requirement, its produced Python distribution must be treated as a multi-component binary artifact rather than as merely MPL-2.0 because CPython and bundled libraries retain their own licenses.

Artifact version, digest, bundled-license inventory and included license texts must be preserved according to the normal package provenance requirements.

This licensing point did not block the evaluated standalone composition and is not a reason for the current micromamba application-environment choice.

## 9. Current invariants

```text
PY-01  Python is governed by the project-wide implementation-language preference in RULES.md.
PY-02  General external Python applications use a private micromamba/Conda application environment.
PY-03  That Python environment is mutable, application-owned and reconstructible state under the existing state model, not immutable package payload.
PY-04  Applications may manage their own requirements, optional packages and plugins inside that private environment.
PY-05  The private environment is not guaranteed byte-for-byte relocatable across prefix changes; stale environments are rebuilt.
PY-06  Changing the application's Python version rebuilds the application environment and reinstalls its Python packages.
PY-07  The general external-application model does not use pkg provider default/binding as a live Python-version switch for a populated environment.
PY-08  The public facility identity for application Python-environment management is exactly python-env.
PY-09  python-env compatibility level 1 exposes exactly one required command member named python-env with create/run/remove semantics defined in this specification.
PY-10  python-env denotes environment management, not a Python interpreter and not the standard-library venv mechanism.
PY-11  Python version/package selection belongs to the consumer environment definition, not the python-env facility compatibility level.
PY-12  python-env consumes a caller-resolved absolute environment pathname and never creates a second state-location model.
PY-13  micromamba is the selected first concrete provider and must adapt to the provider-independent command contract rather than expose raw micromamba CLI semantics as that contract.
PY-14  python-env level 1 accepts canonical major.minor or major.minor.patch Python-version tokens with the semantics defined in this specification.
PY-15  requirements, plugin/update policy, channel policy and GPU policy are outside python-env level 1.
PY-16  The standalone/shared-interpreter PoCs remain engineering evidence, not adopted general Python architecture.
```
