# Standalone Python evaluation

Status: Active
Updated: 2026-09-27

## Goal

Evaluate how RumiAI can obtain a Python runtime that is genuinely portable and relocatable under the current platform and ownership contracts, comparing the two already identified upstream candidates without presupposing adoption:

- https://github.com/scc-tw/standalone-python
- https://github.com/astral-sh/python-build-standalone

The task should establish what each candidate actually guarantees, where host/platform coupling remains, what validation is required, and whether either approach should be adopted or rejected for a concrete RumiAI responsibility.

## Current repository revisions

```text
rumiai-dev       40b4353a87daa83abf59c75e00201703233d0f78
rumiai-os        51d0cba5696a94caaf5ae39e2e476a31598a0ae1
rumiai-dev-PoCs  204f1fe2dd73b6d07b6d786f8ce01593967c3efa
pkg-catalog      168d9bfc5ffebb4ea480a8a9f96c6e394d33fe17
rumiai-tests      287577204412cef46cae83157547dbe9ac28d2f8

upstream evidence inspected:
scc-tw/standalone-python             3528f5677e7b6b70bd52c191dc1468a347025b68
astral-sh/python-build-standalone    8750017c954b01979121ea4717f99985912eeb70
mamba-org/micromamba-releases        346bb1cf50c51a92d58dd4c3063e7c70b78a8246
conda-forge/python-feedstock          bec19c59feecacae3cf6f4471446f22ab7241903
pypa/installer                         ba622422bc1c458d8cb82f08085a807cf2146d7a
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
- For the concrete CPython provider responsibility evaluated by this task, use `python-build-standalone` as the implementation candidate to carry forward. The tested Linux/macOS artifacts passed the required relocation/provider experiments; the scc-tw design remains a Linux/musl reference rather than the selected cross-platform provider source.
- Keep pip/PEP 517 as build-to-wheel machinery; do not fork or replace the complete pip resolver/build frontend.
- Use PyPA `installer` as the candidate final wheel-materialization engine with a narrow RumiAI destination specialization for POSIX `#!/usr/bin/env python` command generation/rewriting and executable mode.
- Route generated Python bytecode to package/build state rather than immutable provider/consumer roots; `PYTHONPYCACHEPREFIX` is the proven mechanism to carry into contract design.
- Preserve normal Python site semantics for consumer-owned package trees. Bare `PYTHONPATH` is insufficient for generic wheel semantics because it does not process consumer `.pth` files; the strongest current mechanism is a static provider-side hook using `site.addsitedir()` on a live consumer-site projection.
- Model the tested CPython minor compatibility with one interpreter facility requirement, not a generic-Python facility plus an independently selected CPython-ABI facility. Existing dotted facility levels and dependency constraints can enforce pure/range, `abi3` range and CPython-minor exact compatibility. The final public facility identity/name remains open.

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

Hands-on evidence from PoC 039 (`rumiai-dev-PoCs/pocs/039-python-build-standalone-provider`):

- Hosted Linux run `36269289831` passed at PoC revision `e311db990ebae3d8674b90cdc53c4f082c16463d` using the pinned `python-build-standalone` CPython 3.13.15 install-only artifact and exact `rumiai-os` revision `7d71de0de59120fb85236f087f0298c6dc637d71`.
- The standalone runtime started before and after direct movement; `sys.prefix` and the tested `sysconfig` include path followed the live runtime location, and a CPython native extension built successfully only after the runtime had already moved.
- The moved standalone runtime then acted as the real selected Python facility provider for the PoC 038 pure/native consumer model. The complete disposable RumiAI root, including provider and consumers, moved again without rewriting consumer scripts; the tested managed old-prefix scan was clean.
- The corrected cross-host rerun `36270231418` at PoC revision `00da3691eab956902a4b8a7303f62d7e3d0a1b93` passed both Ubuntu 24.04 and macOS 14 Apple Silicon. On both hosts CPython 3.13.15 survived direct runtime movement, the tested `sysconfig` include path followed the live runtime prefix, a native extension built after relocation, the standalone runtime integrated as the real RumiAI Python provider, pure/native consumers ran through `#!/usr/bin/env python`, the whole managed root moved again, and the managed old-prefix scan was clean.
- The earlier macOS run `36269415163` was a harness pathname-equivalence defect (`/var/...` versus physical `/private/var/...`), not negative runtime evidence.

Hands-on comparison PoC 040 (`rumiai-dev-PoCs/pocs/040-micromamba-python-prefix-relocation`):

- Hosted run `36271204228` at PoC revision `2bb78d88eab49ab43749a9b8647ffc04b369fc8c` passed on Ubuntu 24.04 and macOS 14 Apple Silicon with micromamba 2.9.0-0 and conda-forge Python 3.13.15.
- The interpreter itself moved successfully on both hosts: `sys.prefix` followed the new environment location, `python -m pip` still worked and micromamba could still list the moved prefix.
- The generated `pip` command remained bound to the original environment through an absolute shebang and failed after the raw move (status 127 on Linux, 126 on macOS).
- Conda's package cache exposed explicit relocation metadata: 207 prefix-placeholder entries across 7058 path entries on Linux and 206 across 7014 path entries on macOS; 12 placeholder entries belonged to the Python package on each host.
- A raw move left the old installation prefix embedded in 654 files on Linux and 163 files on macOS.
- The result therefore distinguishes "the Conda CPython interpreter can discover a moved prefix" from "the materialized Conda environment is permanently location-independent". The former worked; the latter did not.

Hands-on evidence from PoC 041 (`rumiai-dev-PoCs/pocs/041-relocated-standalone-python-sdist-build`):

- Initial hosted run `36271127218` proved that, after moving the standalone runtime, its bundled pip could execute isolated PEP 517 builds with pinned setuptools/wheel for both a pure-Python sdist and a CPython C-extension sdist on Linux and macOS. Both resulting wheels materialized with `#!/usr/bin/env python`, ran successfully before a second runtime move and still ran after that second move.
- That first run then exposed a separate mutation surface: pip/build execution populated hundreds of `.pyc` files inside the standalone runtime, and those generated files retained the previous runtime prefix after the second move (489 hits Linux, 493 macOS).
- Follow-up run `36271484958` at PoC revision `abdfe2664cedb8efb8f0c846f3363b42d9a5ba38` externalized build-time bytecode through `PYTHONPYCACHEPREFIX` and passed on both hosts. The standalone runtime's three pre-existing bytecode files remained unchanged, the pure/native wheels built successfully, materialized consumers ran before and after the second move, build outputs contained no old runtime prefix and the twice-moved runtime old-prefix scan reported zero hits.
- This strongly supports keeping an existing pip/build frontend for resolve/build-to-wheel responsibilities while treating bytecode-cache ownership and final wheel materialization as separate concerns.

Hands-on evidence from PoC 042 (`rumiai-dev-PoCs/pocs/042-python-bytecode-state-cache`):

- Final hosted run `36271759567` at PoC revision `4aa6b4f2a29237021dc6da4d312254b6ebf695a6` passed on Ubuntu 24.04 and macOS 14.
- `PYTHONPYCACHEPREFIX="$HOME/.cache/python"` kept runtime `__pycache__` completely out of the immutable consumer root and generated 18 `.pyc` files under consumer state on each host.
- After the complete disposable RumiAI root moved, the old state cache remained harmless, the relocated source acquired the structurally correct new cache path, and deleting the complete cache followed by rerun regenerated it successfully.
- The final test re-resolves state after relocation and uses `importlib.util.cache_from_source()`; earlier failures were harness mistakes rather than negative mechanism evidence.
- This establishes state-owned bytecode as a stronger candidate than globally disabling bytecode.

Hands-on evidence from PoC 043 (`rumiai-dev-PoCs/pocs/043-python-consumer-package-visibility`):

- Hosted run `36303162645` at PoC revision `9187bb195831b8b62934a9db1fa584dd72407ab0` passed on Ubuntu 24.04 and macOS 14.
- Bare `PYTHONPATH` made the consumer package importable but did not process its `.pth` import line or relative path entry.
- A `sitecustomize` bridge calling `site.addsitedir()` and a `PYTHONUSERBASE` layout both processed the tested `.pth` semantics and survived whole-root relocation.
- `PYTHONUSERBASE` exposed platform/interpreter-specific layout: `lib/python3.12/site-packages` on the Linux CPython 3.12 runner versus `lib/python/site-packages` on the macOS CPython 3.14 runner. This makes it less attractive as a provider-independent consumer materialization contract.

Hands-on evidence from PoC 044 (`rumiai-dev-PoCs/pocs/044-python-wheel-compatibility`):

- Hosted run `36272360551` at PoC revision `7bf64e8c2612166a3f86e47cefd090b55395077e` passed on Linux and macOS.
- `py3-none-any` imported under CPython 3.12 and 3.13; `cp38-abi3-<platform>` imported under both; `cp312-cp312-<platform>` was accepted under 3.12 and rejected by pip under 3.13.
- The minimal PoC 038 materializer intentionally accepted an incompatible `cp312-cp312` wheel and import then failed under 3.13. Therefore compatibility-tag validation is a separate trusted boundary that must happen before or during final materialization.

Hands-on evidence from PoC 045 (`rumiai-dev-PoCs/pocs/045-pypa-installer-env-python`):

- Hosted run `36272471386` at PoC revision `a370909b65d01e6d89b6e128761c9bc743e6e65d` passed on Ubuntu 24.04 and macOS 14 using PyPA `installer` 1.0.1.
- Stock `SchemeDictionaryDestination` generated absolute-interpreter shebangs for both `console_scripts` and wheel `.data/scripts`.
- A small destination subclass changed only POSIX Python command materialization and produced `#!/usr/bin/env python` for both command forms, ensuring executable mode for rewritten wheel scripts.
- Relocated commands continued to run and the payload old-prefix scan was clean while upstream installer retained wheel traversal, placement, RECORD generation and structural validation. This is direct evidence against a RumiAI-owned full wheel installer.

Hands-on evidence from PoC 046 (`rumiai-dev-PoCs/pocs/046-python-provider-consumer-site-hook`):

- Hosted run `36272865870` at PoC revision `71d28ecdab8a2fe2c5107213de86e167dd54adfb` passed on Ubuntu 24.04 and macOS 14 with the pinned `python-build-standalone` CPython 3.13.15 artifacts.
- A static provider-side startup hook containing no installation path reads a live consumer-site projection and calls `site.addsitedir()`.
- Direct provider Python, `#!/usr/bin/env python` consumer commands, consumer `.pth` relative paths/import side effects and child Python processes all saw the same consumer site.
- Provider and consumer relocated together successfully and the static hook/command old-prefix scan was clean.

Hands-on evidence from PoC 049 (`rumiai-dev-PoCs/pocs/049-python-facility-compatibility`):

- The first two-facility shape deliberately tried independent generic-Python and CPython facilities, both exposing a command named `python`. Run `36303903347` failed consistently on Linux/macOS when the second facility default attempted to publish the same global command. This also exposed the selector-coherence risk of splitting one interpreter identity across independently selected facilities.
- The revised single-facility experiment run `36304011616` at PoC revision `e19c5109774760a8f9995b8123d76298c77ed04d` passed on Ubuntu 24.04 and macOS 14.
- With facility levels 3.12 and 3.13, pure-like `>=3.12 <3.14` and abi3-like `>=3.8 <3.14` consumers rebound from the 3.12 provider to 3.13 and followed a changed facility default.
- A CPython-3.12-specific `=3.12` consumer was rejected during dependency resolution before target execution when bound to 3.13 and when the facility default changed to 3.13; restoring the 3.12 default restored execution without rewriting/reinstalling the consumer.
- This proves the existing `pkg` dotted compatibility levels and dependency constraint language are sufficient for the tested CPython-minor compatibility classes. Platform/osarch and wheel-tag acceptance remain separate trusted materialization concerns.

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

### Provenance and licensing

- The inspected `python-build-standalone` source repository is MPL-2.0, but a produced Python distribution is not governed by that single license: it contains CPython and bundled dependencies with their own license inventory.
- Current upstream licensing documentation states that modern builds use libedit instead of GPLv3 readline and disable `_gdbm` to avoid linking GDBM; releases before 2023 may have different GPL exposure.
- Distribution metadata exposes SPDX-style license information and produced archives include license texts; any adopted package definition must preserve that inventory and pin/verify upstream artifact digests.
- PyPA `installer` is MIT-licensed. The inspected scc-tw source project is MIT-licensed.
- Licensing/provenance therefore does not currently block the preferred composition, but binary-distribution license metadata must be carried as artifact evidence rather than reducing the distribution to the build project's MPL license.

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
- Created and passed the Linux form of PoC 039 with an actual `python-build-standalone` CPython provider, including runtime movement before native-extension build and a second movement after provider/consumer integration.
- Extended PoC 039 to macOS, identified the first hosted macOS failure as a harness physical-path canonicalization defect after the runtime itself had already relocated successfully, and committed the canonicalized-path correction for hosted revalidation.
- Created PoC 040 to measure a real micromamba/conda-forge Python prefix against the stronger RumiAI relocation goal instead of relying only on Conda documentation.
- Completed cross-host PoC 039 validation: the tested python-build-standalone artifact passed direct relocation, post-relocation native build, RumiAI provider integration and whole-root relocation on Linux and macOS.
- Completed cross-host PoC 040: conda-forge CPython itself followed a raw prefix move, while generated pip launchers and hundreds of environment files remained tied to the original prefix.
- Created and completed PoC 041: an ordinary relocated `python -m pip wheel` + isolated PEP 517 + setuptools/wheel build path produced working pure/native wheels on Linux and macOS; externalizing build bytecode kept the standalone provider tree unchanged and the second-move prefix scan clean.
- Completed PoC 042 cross-host validation: `PYTHONPYCACHEPREFIX` routed bytecode into relocatable/disposable consumer state while the immutable package root remained clean.
- Completed PoC 043: direct `PYTHONPATH` does not provide normal `.pth` site semantics; `site.addsitedir()` and `PYTHONUSERBASE` do.
- Completed PoC 044: pure, `abi3` and CPython-minor wheel classes require distinct compatibility handling and incompatible tags must be rejected before/during materialization.
- Completed PoC 045: current PyPA `installer` can be specialized narrowly to emit relocatable POSIX `#!/usr/bin/env python` commands without replacing its wheel-install machinery.
- Completed PoC 046: a path-free provider-side `site.addsitedir()` hook preserves consumer `.pth` semantics, child-process behavior and provider/consumer relocation.
- Completed PoC 049: a naive two-facility Python/CPython split collides on the shared global `python` command, while one CPython runtime facility with existing dotted compatibility levels correctly supports range/exact rebinding and blocks incompatible CPython-minor execution.
- Rechecked upstream HEADs on 2026-09-27; the inspected revisions for both standalone-Python candidates, PyPA `installer`, micromamba releases and conda-forge Python remained current.

## Current state

The evaluation has now resolved the major technical questions on Linux and macOS.

The preferred implementation composition for the concrete CPython responsibility is:

```text
runtime artifact source
    astral-sh/python-build-standalone

provider selection
    existing pkg facility/default/binding machinery

installed Python command
    #!/usr/bin/env python

source build / dependency frontend
    existing python -m pip / PEP 517 build-to-wheel path

final wheel materialization
    PyPA installer
    + narrow POSIX destination specialization
    + trusted wheel-tag compatibility validation

consumer package visibility
    static provider-side hook
    -> live consumer-site projection
    -> site.addsitedir()

bytecode
    PYTHONPYCACHEPREFIX
    -> package/build state
    -> never immutable provider/consumer roots

runtime compatibility
    one CPython interpreter facility
    dotted major/minor compatibility levels
    ranges for compatible pure/abi3 cases
    exact minor for ordinary CPython-minor ABI
```

The evidence does not support replacing pip wholesale, using ordinary venv as the runtime model, using a raw Conda environment as the relocatable unit, or splitting one interpreter identity into independently selected generic-Python and CPython facilities.

`python-build-standalone` is the selected candidate to carry into an implementation phase for this responsibility. The scc-tw project remains useful comparative evidence but is not selected for the cross-platform Linux/macOS provider role.

The remaining design choice is deliberately narrow: the final public facility identity/name and exact provider-independent contract must be defined before product/catalog implementation. The current evidence establishes CPython major/minor compatibility semantics, but this task must not silently predefine future cross-implementation Python substitution.

No `rumiai-os` or `pkg-catalog` Python implementation has been added yet.

## Next action

The exploratory evidence phase is complete enough to move to contract design, still without silently modifying product/catalog surfaces.

1. Define the provider-independent Python/CPython facility responsibility and choose its final public identity. The design must preserve the proven single-interpreter selection model and must not claim cross-implementation substitutability that has not been established.
2. Define how a Python consumer package declares/materializes its live site root for the provider-side `site.addsitedir()` hook, including the stable ownership/name of the projected runtime value.
3. Define the trusted wheel-selection/materialization boundary: wheel tags are validated first; PyPA `installer` performs materialization through the narrow env-python destination adapter; the resulting package records the compatible CPython facility constraint derived from the selected wheel plus package metadata.
4. Define bytecode state ownership using the normal package-state model and `PYTHONPYCACHEPREFIX`, including build-time cache handling.
5. Once those contracts are promoted, start a separate implementation work unit for the concrete `python-build-standalone` package/provider, facility catalog data, materializer adapter and permanent tests. Preserve upstream artifact digest and license inventory.

The evaluation itself no longer needs additional broad upstream comparison. New PoCs should be added only when contract design exposes a specific unresolved mechanism.

## Blockers / open questions

- Final public facility identity/semantics remain open. The tested model is one CPython runtime facility with major/minor compatibility; the task must not casually equate that with all Python implementations.
- The provider-side consumer-site hook mechanism is proven, but the stable RumiAI-owned runtime projection name/contract feeding that hook is not yet defined.
- Wheel tag validation is proven necessary but its exact owner/API relative to the PyPA `installer` adapter still needs contract definition.
- Editable installs remain outside the validated immutable/relocatable runtime model. The strongest current boundary remains: sdists may be built to wheels in a controlled build phase; final runtime materialization consumes compatible wheels.
- Binary distribution licensing is not a blocker, but an adopted provider package must preserve the upstream multi-license inventory and digest provenance.
