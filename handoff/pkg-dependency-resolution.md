# pkg dependency resolution usability and install preflight

Status: Active
Updated: 2026-09-30

## Goal

Realign the package dependency/provider model and reconstruct the install orchestration through an experimental `install2` path that leaves the current `pkg install` behavior intact until the replacement model is settled, validated and deliberately promoted.

## Current repository revisions

- rumiai-dev: 3ac1a6029810a80da5cabc1c8cbc80f3576d8458 (pre-checkpoint HEAD)
- rumiai-os: 835aeaae9150dad734b1544f21ebd655357fdb61
- pkg-catalog: d63f87d2be67288ef57f4a5812fabbc3f0b24a0d
- rumiai-tests: 099e8ab29e79a089cbca524d5cc649a74ec2ddea

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
- The experimental `install2` design is evaluating recursive dependency closure that may add missing dependencies to the install set; this is working design, not yet promoted package contract.
- Do not silently choose among multiple compatible installed providers.
- An explicit consumer binding remains highest precedence.
- A configured facility default remains explicit preference.
- Without binding/default, package consumers resolve an unambiguous compatible installed provider; multiple compatible versions of one provider package may be disambiguated by that package's default, while multiple provider packages remain ambiguous.
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
validation
    → explicit-request resolution
    → recursive dependency closure / constraint unification / concrete resolution
    → deduplicated full install graph
    → topological order
    → install remaining concretes
```

`validation` is syntax-only. Explicit-request resolution considers installed state and catalog availability but does not yet resolve dependencies. Dependency resolution operates recursively from the resolved explicit requests.

The dependency stage should produce the ordered **full closure**, not merely a dependency list that is later concatenated with the explicit request list. Explicit requests are graph nodes too: one explicit request may satisfy or depend on another explicit request, and the same concrete may be reached through both explicit and dependency paths. One graph and one deduplication/order step avoids duplicate or incorrectly ordered installation.

No permanent package-store mutation should occur until the complete explicit-request/dependency graph has been proven satisfiable and ordered. Exact staging/download timing remains open, but permanent installation belongs after full resolution.

Still-open policy includes:
- how constraints on the same facility/package are unified;
- how an installed compatible concrete competes with a newer/different catalog concrete;
- how provider-package ambiguity is resolved when multiple providers can satisfy one facility;
- the exact auto-install policy for missing dependency providers under `install2`;
- cycle handling beyond baseline failure;
- the concrete intermediate representation used between stages.

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

The current scaffold intentionally contains placeholders, but several mechanical points must be corrected before it becomes executable design:
- stage outputs must not be stored and re-expanded as an unquoted whitespace-separated scalar list; that would lose argument boundaries and would pathname-expand selectors such as a future `@21*`;
- internal stage helpers must use private leading-underscore names unless they are deliberately promoted as public library API;
- per-package installation must receive the resolved concrete explicitly rather than being called with no operand;
- the repository dispatcher does not yet expose `install2`, so the committed library is not yet a public subcommand path.

The global/non-package `pkg requirement resolve` query intentionally remains facility-default-only because it has no package-consumer runtime projection path. Implicit fallback applies to package consumers.

## Next action

Define the intermediate data model and dependency-unification/provider-selection policies for `install2`, then implement the stages incrementally while preserving the current `pkg install` path. Hosted closure of the old path remains validation evidence to retain, but this handoff stays active because the installation redesign is now its current work.

## Blockers / open questions

The dependency-unification/provider-selection policy and the exact `install2` missing-dependency auto-install policy are intentionally unresolved.