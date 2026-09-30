# pkg dependency resolution and recursive install

Status: Active
Updated: 2026-09-30

## Goal

Complete and validate the promoted recursive `pkg install` model built around the public read-only `pkg depend` dependency planner, while continuing the extraction/catalog cleanup already in progress.

## Current repository revisions

- rumiai-dev: ab7d2f7c10b62adfe27c19887e5a0ed8f7d1cfd8 (pre-checkpoint HEAD)
- rumiai-os: 736489eb5d431dd21e4befd7ed1220f12354478d
- rumiai-tests: 7e11b8c00329f4ff8fbc1f6f0fa87bb905beeef6
- pkg-catalog: d63f87d2be67288ef57f4a5812fabbc3f0b24a0d

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md

## Fixed task-local choices

- `pkg depend <package-spec>...` is read-only and returns only recursive dependency concrete identities, in dependency-first order.
- Explicit requested roots are omitted from `pkg depend` output unless the same concrete is also selected as a dependency node of another request.
- `pkg install <package-spec>...` calls `pkg depend` for the original requests, prepends the returned dependency concretes to the untouched original request list, then installs the resulting sequence.
- Dependency operands are exact concrete identities; original roots retain their original package-spec form and are resolved by installation when reached.
- Dependency/provider planning still collects constraints by effective provider-selection bucket before provider concretization.
- Consumer binding precedes facility default. Without either selector, compatible planned providers precede compatible installed providers; catalog fallback is allowed only when the compatible provider package is unambiguous.
- Multiple compatible provider packages remain an error rather than a ranking opportunity.
- `pkg-common.lib.sh` owns package identity grammar only.
- `pkg-catalog.lib.sh` owns catalog snapshot/navigation/request/concrete resolution.
- `pkg-depend.lib.sh` owns dependency discovery/planning.
- `pkg-install.lib.sh` owns installation orchestration only.
- The user has deliberately deferred further cleanup of `_pkg_install_init` / `_pkg_install_end` and catalog/workspace lifecycle until a later review of `pkg`.
- `extract2` and `pkg-extract2.lib.sh` remain temporary filenames; their internal namespaces already match the future promoted `extract` / `pkg-extract` identities.

## Acceptance scenarios

- `pkg depend geoserver` returns only the concrete Java provider dependency (plus any recursive provider dependencies), not the GeoServer root.
- A dependency-free requested root produces empty successful `pkg depend` output.
- If one explicit root is also selected as a dependency of another root, that concrete still appears in `pkg depend` output.
- `pkg install geoserver` installs dependency concretes first and then installs the original GeoServer request.
- Multiple original requests preserve their original order after all dependency concretes are prepended.
- `pkg install` does not duplicate dependency-resolution logic internally; it consumes `pkg depend`.
- Invalid dependency/provider closure fails before permanent requested-root installation.
- Already-installed compatible dependency concretes may satisfy dependency nodes without reinstallation.

## Current implementation state

`pkg_catalog_request_resolve <concrete-variable> <target-variable> <catalog> <package-spec> <default-target>` now centralizes package-spec to concrete resolution for catalog-backed callers.

`pkg-depend.lib.sh` still builds the full internal concrete graph so roots can contribute dependency declarations and provider constraints, but final output is filtered to concretes present in provider selections. This preserves recursive ordering while omitting pure requested roots.

`pkg-install.lib.sh` now:

```text
save original request argv
→ pkg_depend(original requests)
→ prepend returned dependency concretes
→ initialize install workspace/catalog
→ resolve/install each resulting operand in order
```

`pkg_install_one` accepts a normal package-spec and resolves it through `pkg_catalog_request_resolve` before concrete installation. This lets dependency concretes and original unresolved roots share one install path.

Permanent coverage added/updated:
- `tests/rumiai-os/pkg/depend.test` now expects dependency-only output, including dependency-free roots and the root-also-dependency case.
- `tests/rumiai-os/pkg/catalog.test` covers `pkg_catalog_request_resolve`.
- `tests/rumiai-os/pkg/install-dependency-order.test` verifies that dependency concretes are passed to installation before untouched original requests.

The assistant execution environment has no mounted local RumiAI checkout, so checkout-level test execution must use repository workflows or a user/local checkout. No pass claim is recorded yet for the new revisions.

## Next action

Run the permanent package tests against rumiai-os 736489eb5d431dd21e4befd7ed1220f12354478d, fix any runtime defects, then reproduce `pkg install geoserver` end to end and confirm that GeoServer itself is installed after its Java dependency.

## Deferred

Further simplification of package/catalog temporary-directory lifecycle, including whether `pkg_catalog_init` should own its cleanup trap and whether `_pkg_install_init` / `_pkg_install_end` should disappear, is intentionally deferred until the user's next review of `pkg`.
