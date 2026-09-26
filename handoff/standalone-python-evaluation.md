# Standalone Python evaluation

Status: Active
Updated: 2026-09-26

## Goal

Evaluate how RumiAI can obtain a Python runtime that is genuinely portable and relocatable under the current platform and ownership contracts, comparing the two already identified upstream candidates without presupposing adoption:

- https://github.com/scc-tw/standalone-python
- https://github.com/astral-sh/python-build-standalone

The task should establish what each candidate actually guarantees, where host/platform coupling remains, what validation is required, and whether either approach should be adopted or rejected for a concrete RumiAI responsibility.

## Current repository revisions

```text
rumiai-dev       cd6d0d67af214b1714df2d4cb9139cc0f872f828
rumiai-os        b1ec3502b911c414945300df6165385ec0d196ef
rumiai-dev-PoCs  b89d8866413298b29f233a7b23554b764732a7e8
pkg-catalog      565adc534399e5d4759c8eae24fca197aa912ab9
rumiai-tests      17f4c7fc18e079cde37c3dba70a2d5df578ba713

upstream evidence inspected:
scc-tw/standalone-python             3528f5677e7b6b70bd52c191dc1468a347025b68
astral-sh/python-build-standalone    8750017c954b01979121ea4717f99985912eeb70
```

These revisions are task state only; every resumed work unit must re-run the normal remote-HEAD preflight.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/CURRENT-MODEL.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/PACKAGE-MODEL.md
todo/README.md
handoff/README.md
```

Additional specifications, implementation and permanent tests must be retrieved only when the evaluation reaches a concrete responsibility that requires them.

## Fixed task-local choices

- Treat Python as a non-POSIX external capability; accidental host availability is not a portability guarantee.
- Relocatability is a first-class evaluation requirement: a candidate must not depend on personal checkout paths, Homebrew paths, distribution-local paths or another fixed installation location.
- Compare both identified upstream projects before any adoption decision.
- Do not change `rumiai-os` or `pkg-catalog` merely because an upstream project appears promising; product/catalog changes require a concrete adopted use established by the evaluation.
- Use `rumiai-dev-PoCs` for hands-on experiments when documentation and source inspection are insufficient to establish real behavior.
- For Python commands materialized inside RumiAI-managed package/runtime contexts, target `#!/usr/bin/env python` as the relocatable launcher form and let the existing `pkg` provider-selection/PATH machinery own the concrete Python version/provider selection.

## Working design

The evaluation distinguishes at least:

```text
upstream distribution/build model
supported host OS/architecture combinations actually relevant to RumiAI
runtime relocatability after extraction or movement
dynamic-library/runtime-path dependencies
CPython sysconfig/build metadata
stdlib and extension-module behavior
TLS/certificate and other host-resource dependencies
wheel/entry-point installation behavior
venv semantics
ability to add/install Python packages without destroying relocatability
version pinning and update model
artifact integrity/provenance and licensing
fit with the current m package/runtime ownership model
validation required on materially different hosts
```

Current evidence changes the working hypothesis materially:

- Python relocatability is not one `pip` bug. At least four independent surfaces matter: interpreter/loader/library paths, CPython build metadata such as `sysconfig`, installer-generated package entry points, and environment/native-extension/package-specific state.
- `pip` is a major source of post-install non-relocatability for generated `console_scripts` / `gui_scripts`: its current wheel installer uses distlib's `ScriptMaker` and deliberately embeds the target environment interpreter in generated launchers. The internal wheel-install function already has a `script_executable` seam, but that is an internal implementation detail rather than a stable public relocatable-install contract.
- The PyPA `installer` project confirms that wheel materialization is separable from dependency resolution/building: it is a low-level wheel installer with explicit destination and script-generation abstractions. This makes a relocatable-aware final wheel materialization path a plausible candidate without replacing the whole pip resolver/build frontend.
- A likely architecture to test is therefore: resolve/download/build to wheels with an existing frontend; perform final wheel installation through a relocatability-aware materialization step; generate Python command launchers with `#!/usr/bin/env python`; then validate the resulting tree after movement and provider-selection changes.
- For RumiAI-managed execution, `#!/usr/bin/env python` is the intended primary hypothesis rather than an interpreter-identity ambiguity. The current `pkg` runtime model already owns interpreter selection: a package consumer uses its explicit facility binding when present, otherwise the facility default, and the launcher prepends the selected provider's `facility-cmd` directory to the consumer PATH before exec. Therefore `env python` is expected to resolve the Python provider selected by `pkg`, not an arbitrary host Python. Global `m` execution analogously resolves facility-default commands through the controlled `bin/ext-osarch` / `bin/ext` PATH layers.
- This late-binding model is desirable because changing a Python consumer binding, facility default or unversioned provider package default can change the interpreter selected by a subsequently launched command without rewriting that command's shebang or package tree.
- Ordinary `venv` is not a relocatable-runtime solution by itself: its standard model records a `home` relationship and standard installed scripts are designed around environment-specific interpreter paths.

Reference-model evidence from Conda/micromamba:

- `micromamba` itself is a statically linked C++ package manager and does not carry a default Python. When an environment requests Python, it installs the Python package supplied by the selected Conda channel into that environment prefix; with conda-forge this is a patched/package-managed CPython build rather than a distinct interpreter implementation.
- A Conda environment is not a Python `venv`: the prefix is a complete package environment containing its own Python executable, native libraries, metadata and other packages. Activation mainly exposes that prefix through PATH/environment changes.
- Conda deliberately makes packages installable into arbitrary prefixes by recording build-prefix occurrences and rewriting them to the chosen installation prefix, while also applying binary relocation such as ELF/Mach-O path fixups. This is relocation-at-materialization, not permanent path independence.
- The resulting Conda environment is explicitly not freely movable after installation. `conda-pack` exists because simply moving the environment can break it; its `conda-unpack` phase performs prefix cleanup at the destination, after which the environment is again tied to that location.
- The reusable ideas for RumiAI are therefore the prefix-oriented environment model, explicit package-level relocation metadata/scanning, and binary-relative-link fixups. The part not to copy is final absolute-prefix substitution as the durable runtime model.
- Standard `venv` remains useful as a behavioral reference for separating `sys.prefix` / environment packages from `sys.base_prefix` / the base interpreter, but its absolute base-interpreter relationship and generated absolute script shebangs conflict with the current RumiAI relocatability/late-binding goal.
- A new issue exposed by this comparison must be tested explicitly: changing the Python provider at runtime is safe only when the consumer's installed Python packages remain compatible with the selected interpreter/ABI. Pure-Python packages and native-extension packages have materially different compatibility constraints; provider late binding must not silently cross an incompatible Python ABI.

Hands-on evidence from PoC 038 (`rumiai-dev-PoCs/pocs/038-python-environment-late-binding`):

- Hosted run `36267854427` passed on Ubuntu 24.04 at PoC revision `b8a61e5215dbdc2ea54e459e4da128428bfeb78b`, testing exact `rumiai-os` revision `b1ec3502b911c414945300df6165385ec0d196ef` with real CPython 3.12 and 3.13 providers.
- The ordinary `venv` + pip control installed both a `console_scripts` entry point and a wheel `.data/scripts` `#!python` script with the absolute venv interpreter pathname. Moving that venv caused the command to fail with status 127.
- A minimal experimental wheel materializer emitted `#!/usr/bin/env python` for both command forms and kept the consumer's `site-packages` physically separate from the interpreter.
- Through the real current RumiAI package launcher, an unbound pure-Python consumer followed facility default A, a consumer binding switched the same installed script to provider B without rewriting it, binding removal restored inheritance, and changing the facility default changed interpreter selection without rewriting the script.
- A CPython extension built for 3.12 loaded under provider A but failed after the same consumer was bound to Python 3.13. The provider switch itself succeeded. This establishes that late binding and binary compatibility are separate concerns: the eventual Python facility/dependency contract must prevent ABI-incompatible selections rather than relying on import failure.
- An intermediate run discovered that ordinary CPython imports wrote `__pycache__/*.pyc` into the consumer package root and that those bytecode files retained the original absolute source pathname. This violates the current immutable-package-root model and creates another relocation surface.
- The final run projected `PYTHONDONTWRITEBYTECODE=1` from the synthetic Python provider as an experimental mitigation; no package-root `__pycache__` was created, the complete disposable RumiAI root moved successfully without consumer-script rewrite, and an old-prefix byte scan of the relocated consumer concretes was clean.
- The PoC used `PYTHONPATH="$pkg_launch_root/python/site-packages"` only as an experimental root-relative visibility probe. Neither `PYTHONPATH` nor the internal `pkg_launch_root` variable is adopted as the final package-environment contract.
- The successful PoC narrows the package-installation problem substantially: a dedicated final wheel-materialization boundary can preserve RumiAI late binding without replacing dependency resolution/download/build-to-wheel. It does not yet choose the standalone CPython distribution or final installer implementation.

Candidate-specific evidence:

### scc-tw/standalone-python

- Its current Linux design is aggressive: build/bundle a musl runtime and numerous shared dependencies, use a statically linked C launcher, locate the installed tree from the launcher at runtime, invoke the shipped musl loader directly, and rewrite ELF RPATHs to `$ORIGIN`-relative locations.
- It rewrites CPython build-time `/opt/shared_libraries` references to a sentinel and expands that sentinel from the live `sys.prefix` through a startup `.pth` hook.
- Because the static launcher hides normal musl interpreter information from packaging, the same startup hook monkey-patches private `pip` / `packaging` musl-tag internals so wheel selection sees the bundled musl version.
- Its packing-time shebang rewrite fixes scripts already present in the distribution, but it does not establish a general contract that arbitrary future `pip install` entry points remain valid after the whole tree is moved again.
- The launcher relies on Linux-specific mechanisms such as `/proc/self/exe` and the shipped musl loader. The latest inspected release artifacts are x86 and x86_64 only; the repository still carries an ARM/AArch64 support gap.
- This approach reduces dependence on host glibc but increases owned compatibility/security surface by bundling libc and many libraries and by relying on private packaging internals.

### astral-sh/python-build-standalone

- Its design is broader and more platform-aware: CPython/path-discovery patches plus ELF `$ORIGIN` / Mach-O `@rpath` fixups make the runtime binaries and bundled libraries movable.
- It explicitly documents that raw distributions still contain build-time absolute paths in `_sysconfigdata_*.py`, config Makefiles and metadata. Consumers such as `uv` fix these to the actual installation location.
- It rewrites Python helper-script shebangs into relative launcher logic, but one current open issue demonstrates that the implementation's use of an external `realpath` command is not valid on every macOS version the binary itself may otherwise run on.
- It deliberately omits Windows `pip.exe` launchers because that launcher construction is not portable and recommends `python.exe -m pip`.
- Historical and current issues show that relocatability is intertwined with `sysconfig`, extension building, musl wheel tagging, venv/libpython behavior and toolchain/linker details; this is evidence against reducing the problem to pip shebangs alone.
- The project has substantially broader target coverage and validation than scc-tw, but correspondingly maintains a large patch/build matrix and does not claim that an unpacked raw distribution contains no location-sensitive build metadata.

These are evaluation findings and candidate design state, not adopted RumiAI subsystem contracts.

## Completed

- Performed the mandatory RumiAI preflight against current remote repository state.
- Reviewed the full current TODO inventory for Python/portable/relocatable/standalone-runtime work.
- Confirmed that `todo/standalone-python-evaluation.md` was the only current TODO dedicated to this Python topic and activated it into this handoff.
- Retrieved the current architecture, POSIX portability and package-model contracts needed to start the evaluation.
- Inspected the current upstream HEADs, build logic and relocatability mechanisms of both identified standalone-Python projects.
- Inspected current pip wheel-install behavior and confirmed the interpreter-embedding behavior of generated entry-point launchers.
- Inspected PyPA's lower-level `installer` abstraction as evidence that wheel materialization can be separated from resolver/build responsibilities.
- Rechecked the current `m` bootstrap and `pkg` runtime-provider contracts after the user correction: global facility commands are exposed through controlled external PATH layers, while a launched package consumer gets the selected provider's facility command directory prepended to PATH after resolving explicit binding before facility default.
- Verified the current `rumiai-os` implementation: `_pkg_launch_provider_apply` prepends the selected provider's `facility-cmd/<facility>` directory to `PATH`, and `_pkg_launch_dependencies_apply` resolves the effective provider at each launch before exec.
- Verified permanent tests in `rumiai-tests`: `pkg-launch/contract.test` proves an unbound consumer follows the facility default, an explicit binding switches provider at runtime without reinstalling the consumer, removing the binding restores inheritance, and changing the facility default is observed by the same installed consumer. `pkg/dependency.test` separately proves late binding and provider-package-default changes.
- Identified the main non-relocatability surfaces and narrowed the most promising intervention point to final package materialization rather than a wholesale pip replacement.
- Created PoC 038 in `rumiai-dev-PoCs` and validated the environment/interpreter separation hypothesis with the real RumiAI package launcher on hosted Ubuntu.
- Verified experimentally that pip/venv absolute shebang generation breaks after movement, while `#!/usr/bin/env python` plus current `pkg` late binding follows facility defaults and per-consumer bindings without rewriting the installed consumer.
- Verified the ordinary CPython ABI boundary with a 3.12 native extension rebound to a 3.13 provider and discovered the independent `.pyc` absolute-source-path/package-root-mutation surface.
- Verified one provisional bytecode mitigation (`PYTHONDONTWRITEBYTECODE=1`) and clean whole-root relocation/old-prefix scan; this mitigation remains experimental rather than contractual.

## Current state

The package-environment side of the hypothesis is now experimentally validated on one Linux host against the current RumiAI launcher. A Python consumer can keep its package environment separate from the interpreter, use `#!/usr/bin/env python`, and follow current `pkg` facility-default / consumer-binding selection without reinstalling or rewriting the command. Whole-root movement also works for the tested consumer once runtime bytecode writes are prevented from mutating the immutable package root.

This does **not** mean that arbitrary Python-provider rebinding is safe. The native-extension test proves that interpreter selection and consumer compatibility are independent: a provider can be selected correctly yet be ABI-incompatible with already-materialized native extensions. A future Python facility/consumer contract must make incompatible selections mechanically unsatisfiable.

The experiment also strengthens the case against replacing all of pip. The remaining package-installation problem appears narrow enough to center on controlled final wheel materialization plus validation, while an existing frontend can continue to resolve/download/build wheels. The exact materializer implementation remains open.

The largest unresolved half is now the Python runtime itself. Neither standalone-Python upstream has been adopted. The next evidence should compose the successful package-environment model with a genuinely relocatable standalone CPython artifact and test its runtime/sysconfig/native-build behavior before any product/catalog integration.

## Next action

Extend the hands-on evaluation rather than changing product repositories:

1. create a PoC using the current `python-build-standalone` artifact as an actual relocatable Python provider, first on Linux and then on macOS where materially different loader/path behavior exists;
2. move the standalone runtime itself before and after consumer materialization and validate interpreter startup, stdlib, SSL/TLS, ctypes/dynamic libraries, package imports and generated `#!/usr/bin/env python` commands;
3. layer the PoC 038 consumer environment/materializer over that provider so the interpreter and consumer tree are both genuinely relocated rather than delegating to host CPython;
4. test source-distribution -> wheel building after runtime relocation, including `sysconfig` and a native extension, and scan build/install outputs for behaviorally significant old-prefix references;
5. compare environment-visibility mechanisms without promoting one prematurely: the current experimental `PYTHONPATH` probe, a generic declarative root-relative package environment projection, and Python-native alternatives if they preserve provider independence;
6. compare bytecode-cache policies: disabled writes versus cache-as-derived-state outside the immutable package root, including behavior after whole-root movement;
7. determine the minimum Python compatibility dimensions required by `pkg` from real wheel/native evidence (language/runtime version, implementation and ABI/wheel-tag constraints) before defining any facility compatibility level;
8. after those results, decide whether final wheel materialization should configure/extend an existing installer, use a narrow pip/installer patch, or become an owned `m` package responsibility.

The scc-tw candidate remains useful as a contrasting Linux/musl design, but the broader `python-build-standalone` candidate is the next practical artifact to exercise because it directly covers both Linux and macOS paths relevant to the current evaluation.

## Blockers / open questions

- The POSIX-side managed Python command launcher direction is supported by PoC 038: use `#!/usr/bin/env python` with controlled `pkg` provider projection. Cross-host validation is still required before promotion.
- The final mechanism that exposes a consumer-owned Python package tree to the selected provider is still open; PoC 038's `PYTHONPATH` use is evidence only.
- Bytecode-cache ownership is open. Runtime `__pycache__` in the immutable package root is unacceptable under the current package model; disabling bytecode writes worked experimentally, but routing discardable cache to state may be preferable and needs evidence.
- Python compatibility semantics are open. Pure-Python version compatibility, CPython implementation/minor compatibility, stable `abi3`, ordinary CPython ABI tags and platform/native dependencies must not be collapsed into one vague "Python version" requirement.
- The acceptable policy for source distributions and editable installs remains open. The strongest current boundary is "sdist may be built to a wheel in a controlled build phase; final runtime materialization consumes wheels", while editable installs may be incompatible with an immutable relocatable runtime by construction.
