# Runtime stream injection across shell and other interpreters

Status: Active — investigation and working-design proposal; no product implementation authorized
Updated: 2026-11-17

## Goal

Restore the end-to-end ability to transport and execute explicitly selected application code and dependencies entirely through a stream on a remote host without requiring the remote m/RumiAI source tree. Address the regression introduced during the separation of `m-os`, reusable first-party packages, and generalized `context` library selection.

The scope is intentionally broader than restoring one `rsudo` command or one shell menu. **The operator explicitly requires considering the same source/dependency streaming capability for other interpreter ecosystems, notably Node.js and Python, when the relevant interpreter may already be installed on the remote host.** Those language designs are not assumed to be identical to POSIX shell loading and must be evaluated on their own execution/module semantics.

Produce an accepted design, implement only when specifically authorized, align current specifications/manuals, and validate the real composed workflows.

## Current repository revisions

Source-inspected reference heads on 2026-11-17 (refresh all involved remote HEADs before resumption or writes):

- `rumiai-dev/main`: `13f71375e08e676715f63568e2173b685485e01c` (pre-handoff).
- `m-os/master`: `6014adf353f18df44a359f1c1f86c1521069a355`.
- `m-rsudo/main`: `f17e3826d5eb115cfafeeae7bdb292d53656531d`.
- `m-term/main`: `d75098655e24ee14e17789a0241a1781386dd75d`.
- `m-core/main`: `fb28e38fb478d0de01f379f6b4b5596c65921b2a`.
- Frozen source/evidence references, read-only: `rumiai-os/main@6a4b1023147331da91a737135a33398fc7c58c26`; `rumiai-tests/main@906d9890d5a408753631b33c7f411f5e5cb60b37`.
- These references record evidence, not pins and not proof that the installed package/catalog revision has the same content.

## Applicable canonical sources

- `README.md`; `RULES.md`; `CONSISTENCY-GATE.md`; `specifications/README.md`; `TESTING.md`; `handoff/README.md`.
- `specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md`, `LIBRARY-INTERFACES.md`, `COMMAND-ENTRYPOINTS.md`, `FILESYSTEM-NAMING.md`, `DOCUMENTATION-MODEL.md`.
- `specifications/rumiai-os/RSUDO.md`, `PACKAGE-MODEL.md`, `PYTHON-RUNTIME.md` and the relevant current `context`/platform specifications when designing interpreter integration.
- Adjacent active responsibilities: `handoff/rsudo-injection-menu.md` and `handoff/menu-injected-into-ssh-session-without-files.md` for the historical shell/remote-menu scenario; `handoff/rumiai-os-source-composition.md` for standalone component/package composition; `handoff/m-os-completion-orchestration.md` for broader integration.
- This new handoff independently owns **cross-component, cross-interpreter stream-injection restoration and design**. The older menu/rsudo handoffs are evidence and narrower scenario owners, not parallel authorities for this new work. Do not duplicate their task state or rewrite their history.

## Fixed task-local choices

Only the following are operator instructions or existing canonical constraints; the candidate architecture below is **not yet approved**:

1. The loss of stream injection must be analyzed and a restoration path proposed before product edits.
2. The proposal already presented to the operator must be preserved here, with its alternatives and tradeoffs.
3. Design must explicitly include Node.js and Python as potential remote interpreters **already installed on the target host**, and must not assume the remote system has m, the selected packages, or a matching local interpreter environment.
4. Keep the distinction between transporting code/dependencies and granting remote identity, privilege, credentials or contextual authority.
5. Current POSIX-shell contracts and established `rsudo` source-injection behavior remain authoritative unless a deliberate, approved specification change is made.
6. A new handoff is explicitly requested. Creating it does **not** authorize changing product implementations, promoting a design to normative specifications or altering frozen repositories.

## Detailed problem and verified evidence

### What remains in the autonomous shell core

The current `m-os/m` directly dot-sources `lib/sys/sh/core.lib.sh` as the bootstrap exception. That core defines the filesystem-backed `loadlib`, loads `sys/sh/base` and then `sys/sh/context`. `base.lib.sh` defines `loadsyslib` by delegating to `loadlib "sys/sh/<reference>"`. `context.lib.sh` uses `loadsyslib` to load its owned shell-library dependencies.

Therefore **`loadlib` and `loadsyslib` were not removed from the current autonomous `m-os`**. The failure is more specific: the integrated stream producer, package-owned import style and installed component composition no longer provide a reliable common source-injection path. Do not assert an unproven historical causal sequence solely from the current trees.

A minor current contract/source mismatch also exists: `core.lib.sh` loads `sys/sh/context` through `loadlib` after base initialization, whereas the current library-interface rule describes `loadsyslib` for ordinary owned-system imports after base, with only the core-to-base `loadlib` bootstrap exception. Review before altering bootstrap order/semantics.

### Lost or split producer/consumer

- `m-os/master` has `loadlib`/`loadsyslib` but no `lib/sys/sh/loadlib-inject-stream.lib.sh` and no matching distributed manual.
- The frozen combined `rumiai-os` retains `lib/sys/sh/loadlib-inject-stream.lib.sh` and `res/sys/manual/loadlib-inject-stream.lib.sh`. The implementation emits an in-memory `loadlib` dispatch, embeds explicitly selected system shell library sources, supports named `--command` and one-shot command source, and appends non-TTY stdin shell source.
- The current normative `LIBRARY-INTERFACES.md` and `RSUDO.md` additionally specify `--library <library-reference> <local-source>` for explicit external/package shell sources. The **legacy generator actually inspected does not implement `--library`**, so merely copying it would not satisfy the current contract.
- `m-rsudo/lib/sys/sh/rsudo/rsudo-mod-exec.lib.sh` begins with `. loadlib-inject-stream.lib.sh || return 1` and then calls `loadlib_inject_stream` before recursively piping the generated source through `rsudo`. The missing source is not supplied by current `m-os` or by that `m-rsudo` source tree. An accidental PATH-based resolution must not be treated as sound installation/composition.
- `m-term/bin/sys/menu` imports `menu.lib.sh` and `menu-command.lib.sh` using POSIX dot lookup. Its `menu.lib.sh` conditionally imports `array.lib.sh`, `map.lib.sh` and `term.lib.sh` via `.` if corresponding functions are absent. `context` exposes selected package `link/lib/sh` directories through PATH, making ordinary local sourcing work but not providing an interchangeable in-memory import backend.
- `m-core` continues to distribute useful independent shell sources such as `array.lib.sh` and `map.lib.sh`. They need not all become globally installed `m-os` libraries.

### Fundamental semantic gap

POSIX `.` is shell syntax/special builtin and cannot be transparently replaced with a custom memory-backed implementation. Once source code directly uses package-local `. filename.lib.sh`, it relies on a suitable filesystem lookup unless that import is avoided, satisfied beforehand, or the source is deliberately adapted. Preloading `menu` dependencies may happen to satisfy its guarded imports, but that alone is not a general solution.

`context` decides which installed package commands/libraries are visible in the *local* shell (including PATH/CLASSPATH projection). It does not bundle the source closure, export remote files, or reconstruct a remote package runtime. A shell stream needs an independent resolution/import mechanism and a deliberately selected payload.

Previous work (see adjacent handoffs) established that executing normal `core.lib.sh` inside an injected runtime could overwrite the injected `loadlib`. The `core`/`base` split exists partly to keep the in-memory loader distinct from normal bootstrap initialization; the new design must preserve that property.

### Validation gap

Existing frozen permanent checks provide reusable starting evidence, not acceptance of the new autonomous composition:

- `rumiai-tests/tests/rumiai-os/bootstrap/library-loading.test`: normal loader, generated stream, argument/command isolation, no omitted-library fallback, direct-system-import checks.
- `rumiai-tests/tests/rumiai-os/rsudo/exec-inject.test`: generator-to-rsudo composition, named/one-shot commands, source continuation and failure propagation.
- `m-os/.github/scripts/context-libraries-test.sh`: actual selected package SH/Java library views using POSIX dot; this **does not prove remote stream injection**.

No cross-component, current-revision end-to-end PASS or tested Node.js/Python injection implementation is claimed.

## Acceptance scenarios (provisional, user-oriented)

1. A caller selects a locally available shell command and its required libraries, generates a stream and runs it under a target POSIX shell **without a remote m tree or transferred source files**. Function loading, arguments, output and status match the declared semantics.
2. Through `rsudo exec inject`, a caller uses the selected local libraries (including package-owned ones) on a remote SSH/sudo host; the command and an optional interactive `menu` work, and missing selected dependencies fail deterministically without remote fallback.
3. A caller selects a Node.js program and its required JavaScript modules; **when compatible Node.js is already present remotely**, the system can run the streamed program without requiring a remote RumiAI installation or persistent source-tree deployment. If Node.js or a required capability/version is unavailable, it reports a clear pre-execution failure instead of silently installing it.
4. A caller selects a Python program and its required Python modules; **when compatible Python is already present remotely**, the system can run it with the same no-remote-m/no-persistent-source-tree goal, without confusing this task with management of application-private Python/Conda environments.
5. For each supported interpreter, named/one-shot operations preserve intentional argument and standard-stream behavior, return the actual status, and prevent unintended source/runtime state leakage according to that interpreter's agreed model. Credentials/privileges are never inferred or transferred from local `context`.
6. A caller can use the source-stream facility with transport other than `rsudo` when it provides equivalent byte, execution and error semantics: stream generation must not hardcode SSH/sudo.

These describe goals, not acceptance of a particular wire format, command grammar, runtime adapter or module implementation.

## Working design — proposal presented to the operator, NOT yet accepted

### Alternatives

**A — Make `loadlib`/`loadsyslib` universal again.** Replace direct `.` imports broadly. Advantages: uniform interception and fewer exceptions. Disadvantages: invasive changes to independently packaged libraries, unnecessary dependency on `m` for otherwise standalone code, potential impact on runtime/path-data sourcing. Avoid an indiscriminate global conversion.

**B — Restore only the old generator.** Smallest nominal port. Disadvantages: the legacy generator lacks current `--library` support, package-local dot imports remain non-interceptable, and installed distribution/`rsudo` composition stays fragile. Insufficient as an overall solution.

**C — Restore a replaceable logical import boundary while preserving legitimate local `.`.** Preferred proposal, **not an approved architecture**. Keep `context` responsible for selecting local concrete package views; keep a distinct loader responsible for resolving explicit library references to local files or injected memory; keep stream generation independent of transport.

### Proposed phased path

1. **Map imports and ownership.** Inventory `m-os`/`m-core`/`m-term`/`m-rsudo` and selected package libraries, distinguishing owned logical references from filesystem/runtime-selected source data. Trace the exact installable `pkg-catalog`/package revisions, not only repository HEADs. Identify which sources must be injection-capable and which may legitimately remain local-only.

2. **Confirm shell-loader contract.** Preserve the existing `loadlib <reference>` and `loadsyslib <system-reference>` surfaces for suitable owned system sources; retain POSIX `.` for genuinely file-path-based/local loads. Evaluate the mapping/namespace for package-owned selected sources so logical references can be resolved independently of local file paths. Avoid injecting `core` when that would replace the injected loader. Reconcile the isolated `core -> context` import mismatch only with explicit contract/validation review.

3. **Restore the stream generator in its appropriate owner.** Preferred placement: technical `m-os`, not `m-rsudo`, because the generator is transport-neutral. Port the existing design rather than rewriting blindly, and implement the missing contractually documented `--library reference local-source` selection. Preserve explicit library selection and ordering, zero-library support, namespaced in-memory dispatch, named command registration, one-shot isolation, optional stdin continuation, and deterministic missing-library failures. Do not implicitly parse dependencies or compute their transitive closure.

4. **Reconnect installed transport integration.** Align `m-rsudo`'s `exec inject` module to a reliably available system generator instead of an accidental PATH lookup. Ensure the distribution/inventory/manual/canonical spec and installation via `pkg` actually compose. Keep stream generation and `rsudo` transport separate; preserve generation failures before invoking remote operations.

5. **Realign injection-capable package libraries.** Begin with real `m-core`, `m-term` and `m-rsudo` scenarios, especially `menu`. Use a substitutable loader for imports that must resolve from an embedded stream. Keep standalone modules free of unnecessary `m` coupling. Do not turn every incidental `.` use into a new public loader API.

6. **Validate shell functionality.** Verify syntax, output/status/argv, selected and missing dependencies, no remote filesystem fallback, isolation, PATH/context selection, end-to-end `rsudo`/PTY/menu, and transport errors against the exact integrated revisions. Adapt the pertinent frozen tests into authorized current permanent coverage rather than silently executing or modifying frozen repositories.

### Cross-interpreter extension: required design work, not an implementation decision

The operator requires the same **capability objective** to be considered for other language runtimes, **specifically Node.js and Python already installed on the remote host**. This is part of the active design, not optional commentary postponed indefinitely.

Do **not** assume the POSIX `loadlib` protocol is the right universal API for other languages. Separate:

- **Selection/composition** on the source host: choose exact code and explicitly declared dependencies, preserving the selected package/concrete context only as local resolution input.
- **Stream representation and transport**: emit reproducible executable payloads without relying on an m filesystem on the destination; evaluate whether a POSIX-shell bootstrap/envelope, language-native stream, or separate adapter per runtime is appropriate. Preserve byte integrity and status.
- **Remote capability check**: discover or explicitly choose a compatible installed `sh`/`node`/`python` interpreter without assuming a fixed path, version or host package name; define clean failure when missing/incompatible. Do not install or modify a remote runtime implicitly.
- **Language-native module loading**: evaluate Node.js CommonJS versus ESM semantics, module identity/cache, relative imports and host built-ins; separately evaluate Python modules/packages, import machinery, package-relative imports, bytecode/cache behavior and interpreter environment. Different source formats/entrypoints may need different memory-backed loaders, not a forced single shell abstraction.
- **Boundaries for dependencies**: define support for source-only modules versus native extensions/addons, compiled assets, external programs and non-code resources. A preinstalled interpreter does not imply preinstalled third-party modules or ABI compatibility. Unsupported dependencies must fail clearly, not trigger hidden installations.
- **Execution semantics**: exact argv and exit status, stdout/stderr, stdin as program source versus stdin as runtime data, subprocesses, reusable named functions/modules, cleanup, signal behavior, errors, and privileged execution.
- **Safety/trust**: executing injected code is an explicit caller-authorized action on a remote target; no hidden propagation of local `context` privileges, credentials, secrets, provider choice, CA authority or package state. No remote filesystem persistence should be required for supported source-only execution; any unavoidable temporary artifacts must be an explicit separate contract.
- **Compatibility with existing Python policy**: `PYTHON-RUNTIME.md` owns external-application private environments; using a preinstalled compatible Python for an explicit injected source task must not silently replace that general contract.

Evaluate small independent PoCs for shell, Node.js and Python in `rumiai-dev-PoCs` if needed. Decide the common abstraction based on those results, not by mechanically porting shell `loadlib` into languages with fundamentally different import machinery.

### Design quality and authorization boundary

The preferred option C and its stages are the assistant's proposal awaiting operator review. They must not be promoted as normative implementation requirements or used to authorize a product change without a specific operator decision. Current canonical specs take precedence where the proposal conflicts; report those conflicts explicitly.

## Completed

- Read current canonical bootstrap/library/entrypoint/rsudo/Python contracts and relevant active handoffs.
- Verified current repository HEADs and inspected the live shell loader, `context` imports, `m-rsudo` generator consumer, `m-term` imports and legacy generator.
- Identified exact missing component, spec/implementation delta for `--library`, cross-repository PATH-based coupling and affected test foundations.
- Captured the operator's additional Node.js/Python remote-interpreter design requirement in this independent active handoff.
- No product code, package catalog, tests or canonical specifications changed as part of opening the handoff.

## Current state

Diagnosis and a preferred **candidate** restoration architecture are documented. No accepted final cross-interpreter protocol, no installed-distribution validation and no implementation authorization exist. The previous shell/menu work provides reusable evidence but does not establish that autonomous `m-os` + packages currently deliver working injection. Respect frozen `rumiai-os` and `rumiai-tests` until their freeze is explicitly lifted.

## Next action

Present/compare the candidate design with the operator's intended approach **before implementation**, then refine the same handoff with accepted boundaries. In particular, resolve the language-neutral payload/transport boundary and the minimal Node.js/Python source-module cases; identify ownership and dependency mapping for `m-core`/`m-term`/`m-rsudo` and the exact installable catalog composition. After operator authorization, promote settled contracts into their canonical specifications and implement with revision-specific permanent and end-to-end validation.

## Blockers / open questions

1. Does the operator accept option C or prefer a different layering/import strategy?
2. What exact semantic library identity should package-owned shell sources expose to an injected `loadlib` without erasing `context`'s selected-concrete semantics?
3. Should a shared stream/container format span shell, Node.js and Python, or should each interpreter use its own language-native stream format behind a common transport contract?
4. How should a target's preinstalled runtime be located/version-checked, and what is the explicit failure/override policy?
5. What source-only module/import capabilities form the initial Node.js and Python acceptance baseline, and where do binary/native dependencies become unsupported or separately packaged?
6. How should data stdin, interactive TTY, isolation and status propagation work per interpreter without corrupting generated-source stdin?
7. Which current revision of `pkg-catalog` and installed first-party packages is the actual composed deployment target for validation?
