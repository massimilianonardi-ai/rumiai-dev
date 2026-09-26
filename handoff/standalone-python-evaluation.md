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
rumiai-dev       8e60879fd765dc9da837ace3085c9a713e3baabb
rumiai-os        b1ec3502b911c414945300df6165385ec0d196ef
rumiai-dev-PoCs  94e2d6a385236a081815b0a700b7c2b2be0c92bd
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

## Current state

The source-level evaluation is sufficiently advanced to reject the simplistic model "pip is the entire relocatability problem", while confirming that pip-style entry-point generation is one major root cause of relocation breakage after additional packages are installed.

No upstream base-runtime candidate has been adopted yet. The package-command direction is now fixed task-locally: combine a relocatable base Python distribution with a controlled wheel materialization boundary that emits `#!/usr/bin/env python`, while concrete interpreter selection remains dynamically owned by the existing `pkg` facility binding/default and PATH projection model. This further reduces the reason to fork the complete pip dependency resolver/build frontend.

## Next action

Create a focused PoC in `rumiai-dev-PoCs` that tests the materialization hypothesis independently of product integration:

1. install representative pure-Python wheels with console entry points using a minimal wheel-installer path and emit `#!/usr/bin/env python`;
2. run the generated commands under a controlled PATH and verify that changing the selected Python provider changes interpreter resolution without rewriting the scripts;
3. exercise both facility-default selection and a consumer-specific Python binding, verifying that the consumer binding wins through the package launcher's provider command projection;
4. move the entire Python/package tree and verify imports plus every generated command;
5. add a native wheel and a source-built-to-wheel case to expose loader/sysconfig boundaries;
6. scan the moved tree for behaviorally significant references to the original root and classify each source.

Only after this experiment should the task decide whether the required behavior can be obtained by configuring/extending an existing installer, a narrow patch around pip/installer, or a RumiAI-owned materialization responsibility.

## Blockers / open questions

- The POSIX-side Python command launcher form is no longer open for the PoC: test `#!/usr/bin/env python` against the controlled `pkg` PATH/provider-selection semantics. Any failure should be treated as evidence about package/provider projection or installer behavior, not replaced pre-emptively with a self-relative launcher.
- The acceptable policy for source distributions and editable installs remains open. A likely test boundary is "sdist may be built to a wheel in a controlled build phase; final runtime materialization consumes wheels", while editable installs may be incompatible with an immutable relocatable runtime by construction.
