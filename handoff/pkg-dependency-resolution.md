# pkg dependency resolution usability and install preflight

Status: Active
Updated: 2026-09-30

## Goal

Realign the package dependency/provider model and reconstruct the install orchestration through an experimental `install2` path that leaves the current `pkg install` behavior intact until the replacement model is settled, validated and deliberately promoted.

## Current repository revisions

- rumiai-dev: b37337c73e1d89a97fdbee06b5ff9aea722b1c57 (pre-checkpoint HEAD)
- rumiai-os: 1e0f7fb56b488de4d5d5d97d0e824ebf92484bb1
- pkg-catalog: d63f87d2be67288ef57f4a5812fabbc3f0b24a0d
- rumiai-tests: 72ed95b574a7fdc897627ab1b0ea60b38ea2d472

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md

## Fixed task-local choices

- Current canonical `pkg install` does not auto-install missing dependency providers and remains unchanged while `install2` is experimental.
- Public `pkg depend <package-spec>...` is now the read-only dependency planner. It resolves explicit requests and recursive facility dependencies against one catalog snapshot and prints a deduplicated dependency-first concrete plan.
- Experimental `install2` reuses the public `pkg_depend` entry function itself, captures its concrete output, and installs those exact concrete identities. It does not call a separate public planning API or share hidden snapshot state with `pkg depend`.
- Do not silently choose among multiple compatible provider packages.
- An explicit consumer binding remains highest precedence.
- A configured facility default remains explicit preference.
- Without binding/default, planning first reuses a compatible provider already present in the plan, then an unambiguous compatible installed provider, and only then an unambiguous compatible catalog provider package. Multiple compatible versions of one installed provider package may be disambiguated by that package's normal provider/default selection; multiple compatible provider packages remain ambiguous.
- Missing dependency providers may enter a `pkg depend` plan only as concrete identities; planning performs no download, extraction, integration or package-store mutation.
- Installation must not require runtime provider selection to already be configured or currently satisfiable.
- Dependency/provider diagnostics must expose the facility, constraints and resolution reason rather than only a generic failure code.

## Acceptance scenarios

- A syntactically invalid `pkg install2` invocation fails before catalog/state resolution and performs no package installation.
- All explicit requests are resolved against installed state and one catalog snapshot before installation; if any explicit request cannot be satisfied, nothing is installed.
- Dependencies of the resolved requests are discovered recursively, their constraints are unified, and the complete dependency closure is resolved against installed state and the same catalog snapshot; an unavailable, conflicting or ambiguous closure fails before installation.
- When the complete request/dependency graph is satisfiable, already-installed compatible concretes satisfy graph nodes without reinstallation and remaining concretes are installed in dependency order.
- The existing `pkg install` path remains available and behaviorally unchanged while `install2` is being reconstructed.

## Working design

The current experimental flow is:

```text
pkg_depend(explicit requests)
    → its own catalog snapshot
    → explicit concrete resolution
    → recursive dependency discovery
    → constraint collection by effective provider-selection bucket
    → provider concretization
    → repeat until closure stabilizes
    → concrete graph cycle check / topological order
    → exact concrete list

install2
    → call pkg_depend
    → capture exact concrete list
    → initialize install workspace/catalog as needed
    → install those exact concretes dependency-first
```

`pkg_depend` validates request syntax before its own catalog initialization and owns explicit request resolution plus dependency closure. `install2` relies on that public boundary instead of duplicating validation or calling an alternate resolver. Explicit requests are graph nodes too: one explicit request may satisfy or depend on another explicit request, and the same concrete may be reached through both explicit and dependency paths.

Requirements sharing the same effective implicit or selector bucket are accumulated before provider selection. Different consumer bindings may therefore intentionally create different buckets for the same facility. The planner rebuilds the active concrete contexts from roots plus current provider decisions until the decision set stabilizes, then derives one deduplicated concrete graph and dependency-first order.

No permanent package-store mutation should occur until `pkg depend` has produced the complete satisfiable ordered concrete list. That list, not a shared snapshot object, is the boundary between planning and installation. A later install snapshot may differ if the catalog advances; the installer must still attempt the exact concretes from the list rather than re-resolving them to different versions.

The following planning policy is now fixed for `pkg depend`:
- all constraints in one effective provider-selection bucket must be satisfied by the selected concrete;
- compatible planned providers precede installed providers, which precede catalog fallback;
- catalog fallback is allowed only when the compatible provider package is unambiguous;
- multiple compatible provider packages are an error rather than a ranking opportunity;
- configured binding/default intent remains authoritative and does not silently fall through to another provider package;
- graph cycles fail rather than producing a partial order.

Still-open install2 policy is limited to promotion/operational questions rather than dependency-discovery mechanics: the canonical `pkg install` path still does not automatically install the transitive plan until deliberate promotion.

Each install2 stage communicates through a shell-safe quoted argument list written to standard output. Every element is emitted with the existing `quote` contract and elements are separated by spaces, so the caller may capture the result and reconstruct the exact positional arguments with `eval "set -- $result"`. This makes each stage a simple argv→quoted-argv transformation, preserves spaces and literal metacharacters in elements, and allows stage functions to remain subshell-isolated. Arrays/maps may still be used internally by a resolver when useful, but they are not the inter-stage contract. No temporary files are used for intermediate lists.

The first `install2` scaffold is present in rumiai-os `835aeaae9150dad734b1544f21ebd655357fdb61` with separate validation, explicit resolution, dependency resolution and per-package installation functions. It is scaffolding only; current repository dispatch still exposes the canonical `pkg install` surface unless/until `install2` is deliberately wired and documented.

## Completed

- Implemented package-consumer implicit installed-provider resolution with explicit binding/default precedence and detailed failure reasons in rumiai-os `10db3ea43fd654c5e5bcf0f13cb64e2d4fa455fa`.
- Decoupled package integration from runtime dependency satisfiability, added pre-download dependency-metadata validation and install-time unresolved-dependency warnings in rumiai-os `42e542d24d380c91ed30369a24553f43099a0e3a`.
- Removed provider-index mutation from integration/deintegration; installed concrete facility metadata now drives provider discovery, so stale legacy index markers are inert.
- Added internal support for public `pkg requirement list <package-spec>` catalog queries without artifact download.
- Global `pkg requirement resolve` now reports unconfigured, unresolvable and incompatible facility-default failure reasons instead of failing silently.
- `pkg install` now emits unresolved dependency warnings before artifact transfer rather than after integration, while continuing the install.

- Reproduced that Keycloak declares only `java =25`.
- Confirmed current tests deliberately require failure when a compatible provider is installed but no binding/default exists.
- Confirmed current installation checks dependency resolution only late inside `pkg_integrate`.
- Confirmed stale provider-index state can block provider installation with a generic `provider-index-failed`.

## Current state

The previous dependency/provider realignment remains implemented on the canonical `pkg install` path. A new experimental `pkg-install2.lib.sh` scaffold now exists for reconstructing installation without breaking the old path.

The new design has not been promoted into `PACKAGE-MODEL.md`; in particular, recursive dependency auto-installation would intentionally differ from current PKG-18 and must remain isolated in `install2` until its policies and acceptance behavior are settled.

The current scaffold intentionally contains placeholders. Invocation initialization now creates a private work directory and persistent catalog cache, while catalog initialization reads its repository URL from `state-path system sys pkg conf`/`catalog`, updates the cached Git repository, records one exact HEAD and exports that revision into the invocation-private catalog work directory with `git archive`. The main system profile now supplies that configuration with the canonical HTTPS URL for `massimilianonardi-ai/pkg-catalog`.

Package request/concrete parsing is now centralized in `pkg-common.lib.sh`. Public `pkg_request_read <name-variable> <version-variable> <osarch-variable> <request>` parses `<package>[@<version>][!<osarch>]`, while `pkg_concrete_read <name-variable> <version-variable> <osarch-variable> <concrete>` requires `<package>@<version>[!<osarch>]`. Both validate caller-selected destination names through the existing `valid_shell_identifier` primitive and assign outputs only after the whole input has been validated. The shared internal parser uses a non-whitespace field separator so omitted request version/osarch fields remain distinguishable. `pkg_install_validate`, `pkg_install_resolve_one`, `pkg_install_one` and the provider concrete parser reuse these shared primitives instead of maintaining local parsing logic. Revision-coupled manuals are aligned and permanent coverage protects both request and concrete parsing. A direct POSIX-shell syntax/behavior check passed for unversioned requests, platform requests, concrete identities, invalid concrete syntax, invalid destination identifiers and duplicate destination names.

The install2 extraction boundary has now been split explicitly. Experimental `extract2 <format> <artifact> <destination>` keeps the same invocation shape as `extract` and owns only raw physical-format extraction/materialization. It supports the legacy physical formats plus `appimage`, `executable` and raw Apple `pkg`; it deliberately does not recognize the package-semantic pseudoformats `flat-pkg` or `dmg-pkg`. `dmg` extracts image contents without interpreting contained objects, and `pkg` expands the installer structure without selecting components or Payloads. `extract2` is only the temporary command filename during evaluation: its internal functions, variables, diagnostic operation identity, state path and temporary names already use the `extract` namespace so validated promotion can replace the current `extract` without an internal rename pass. The command intentionally has no redundant final `exit 0`; the terminal format-dispatch command determines successful completion.

The experimental file `pkg-extract2.lib.sh` owns package-specific interpretation and normalization but is already internally the future `pkg-extract`: its sole public entrypoint is `pkg_extract <artifact> <range-dir> <staging-dir>`, all helpers/variables/work names use the `pkg_extract` / `pkg-extract` namespace, and its terminal normalization command determines success without a redundant final `return 0`. Ordinary package formats delegate once to `extract2`; `flat-pkg` composes `extract2 pkg`; `dmg-pkg` composes `extract2 dmg`, selects the single top-level installer package, then calls `extract2 pkg`. Only `pkg_extract` interprets `component`, `payload-root` and `overlay`, and only it normalizes the useful root. `pkg_install_one` imports the temporary `pkg/pkg-extract2` library but already calls `pkg_extract`; validated promotion therefore requires changing the imported library identity/file rather than renaming the function/API. The legacy `extract`, `pkg_extract` and canonical `pkg install` paths remain unchanged.

Catalog mechanics have now been separated from install orchestration into public `pkg-catalog.lib.sh`. `pkg_catalog_init <catalog-variable> <head-variable> <work-root> <cache-root>` owns configured Git cache/update plus one immutable exported snapshot; `pkg_catalog_stream_resolve <stream-variable> <identity-osarch-variable> <catalog> <package> <target-osarch>` owns target-stream versus `all` fallback; and `pkg_catalog_range_resolve <range-variable> <catalog> <concrete>` owns concrete-to-range lookup, including contiguous range numbering and adapter-defined anchor ordering. `pkg-common.lib.sh` remains limited to package grammar/identity. `pkg-install2.lib.sh` no longer contains `_pkg_install_catalog_init`, direct stream-selection filesystem logic or the nonexistent `_pkg_install_dependency_range_resolve`; both dependency-source discovery and `pkg_install_one` reuse `pkg_catalog_range_resolve` against the same invocation snapshot.

The dependency planner is now separated into public `pkg-depend.lib.sh`. The public command `pkg depend <package-spec>...` owns invocation-private snapshot acquisition and prints one exact concrete identity per line. The internal planner helper is private; there is no second public same-snapshot planning API. Experimental `install2` now calls `pkg_depend "$@"` itself, captures the raw concrete list, then initializes its install workspace and installs those exact identities. The old `pkg_install_resolve_one`, `pkg_install_resolve`, `pkg_install_dependency_resolve`, `_pkg_install_dependency_visit` and nonexistent `_pkg_install_dependency_resolve_one` path have been removed from `pkg-install2.lib.sh`.

The public composition boundary is now explicit: `pkg install $(pkg depend ...)` is a supported shape because `pkg depend` emits only exact concrete identities valid as package operands. The snapshot used while planning is intentionally not shared with installation. If catalog state advances before installation, the installer still attempts the exact returned concretes and must not silently select different versions. `pkg-install2` follows the same model internally by calling `pkg_depend` before its own install initialization. The former public `pkg_depend_resolve` surface has been removed; the underlying planner helper is private.

Because `pkg depend` stdout is machine-consumable, catalog refresh chatter is now kept off stdout. `pkg_catalog_init` redirects normal `git clone` / `git pull` output to stderr, and permanent `rumiai-os/pkg/depend.test` injects deliberate clone/pull stdout noise while testing the public `pkg_depend` entrypoint so any leakage corrupting the concrete list is detected.

Planning now performs fixed-point dependency discovery. Dependency declarations are parsed through public `pkg_dependency_read` / `pkg_dependency_validate`; compatibility evaluation uses public `pkg_dependency_satisfied`; provider definition lookup uses public `pkg_facility_compatibility_read`; and catalog request version resolution uses public `pkg_catalog_version_resolve`. This keeps `pkg-depend.lib.sh` from depending on private cross-library helpers. Requirements are grouped by effective selector/facility/target bucket before provider selection, so constraints such as `java >=21` and `java =25` from different implicit consumers are evaluated together rather than choosing a provider during first DFS discovery.

Permanent coverage `rumiai-os/pkg/catalog.test` now exercises catalog snapshot initialization with a controlled Git fixture, platform and `all` stream resolution, exact/middle range selection, malformed range numbering, missing streams and invalid output identifiers. A real checkout test run was attempted from the execution environment but GitHub DNS resolution is unavailable there, so this commit has permanent test coverage but no executed checkout-level validation evidence from this session.

Permanent tests were added for the new boundary: `rumiai-os/extract2/contract.test` protects raw `pkg`/DMG behavior, opaque AppImage/executable handling, ordinary tar extraction and rejection of `flat-pkg`/`dmg-pkg`; `rumiai-os/pkg-extract2/contract.test` protects ordinary normalization plus `flat-pkg` and `dmg-pkg` composition, including the required `dmg -> pkg` sequence and overlay application. The current environment could not execute these repository tests and no GitHub workflow runs are configured for the commits, so they are committed coverage rather than executed validation evidence.

Several mechanical/design points still remain before the scaffold becomes executable design:
- stage outputs are shell-safe quoted argument lists produced through `quote`; callers reconstruct them only with deliberate `eval "set -- $result"`, never by ordinary unquoted expansion;
- the repository dispatcher still does not expose `install2`, so the experimental installer library is not yet a public subcommand path;
- the exit trap in `pkg-install2.lib.sh` is still installed before `pkg_install_work` is assigned, so early initialization failure can reach cleanup before that variable has been established;
- `pkg_install_one` still contains further orchestration/API cleanup opportunities unrelated to dependency planning.

The global/non-package `pkg requirement resolve` query intentionally remains facility-default-only because it has no package-consumer runtime projection path. Implicit fallback applies to package consumers.

## Next action

Validate the public compositional path, especially `pkg install $(pkg depend ...)`, and the experimental `install2` path that now invokes the same `pkg_depend` entry function. Fix any runtime defects exposed by that validation, then continue the remaining `pkg_install_one` orchestration cleanup while preserving canonical `pkg install`.

## Blockers / open questions

No dependency-planner design blocker remains. This assistant runtime has no local RumiAI checkout mounted; permanent validation therefore uses repository workflows rather than a local checkout. The latest `rumiai-os-health` run for rumiai-tests 72ed95b574a7fdc897627ab1b0ea60b38ea2d472 is currently in progress, so no pass claim is recorded yet. Canonical `pkg install` promotion remains deliberately separate from the experimental install2 work.