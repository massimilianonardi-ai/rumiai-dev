# pkg dependency resolution and recursive install

Status: Active
Updated: 2026-09-30

## Goal

Complete and validate the promoted recursive `pkg install` model built around the public read-only `pkg depend` dependency planner, while continuing the extraction/catalog cleanup already in progress.

## Current repository revisions

- rumiai-dev: b2287177c5e6297527b8f0f7555fe777e2d5c453 (pre-checkpoint HEAD)
- rumiai-os: d98615a4b9b1d6008c23c2c8edb1f973ebf7103e
- rumiai-tests: 4ddfd7f2d3939081d18b217c8dbb200318ed357b
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
- `tests/rumiai-os/pkg/install-dependency-order.test` verifies that dependency concretes are passed to installation before untouched original requests and that an already-installed exact dependency concrete is reused without catalog resolution.
- `tests/external/geoserver/install-dependency-live.test` explicitly verifies that `pkg depend geoserver@3.0.1` includes Temurin but excludes the GeoServer root, then verifies that `pkg install geoserver@3.0.1` installs both packages.

Revision-coupled validation evidence:
- GeoServer workflow run 36768364000 tested rumiai-os 736489eb5d431dd21e4befd7ed1220f12354478d.
- `external/geoserver/install-dependency-live.test` PASS on Ubuntu.
- `external/geoserver/install-dependency-live.test` PASS on macOS.
- The later `external/geoserver/service-live.test` failed in that workflow, so the overall GeoServer scope is NOT VALIDATED; that failure occurred after the dedicated recursive-install test had passed and is not evidence against the install result.
- rumiai-os d98615a4b9b1d6008c23c2c8edb1f973ebf7103 adds only the early reuse path for an already-installed exact dependency concrete; permanent coverage exists for that delta, while the full health workflow is still running at this checkpoint.

The assistant execution environment has no mounted local RumiAI checkout, so checkout-level execution uses repository workflows rather than a local checkout.

## Next action

Investigate the separate GeoServer `service-live` failure only if it remains relevant after the package-install work unit; the reported recursive-install defect itself is reproduced and fixed. Continue package cleanup from the current promoted `pkg install` implementation when the user resumes review.

## Deferred

Further simplification of package/catalog temporary-directory lifecycle, including whether `pkg_catalog_init` should own its cleanup trap and whether `_pkg_install_init` / `_pkg_install_end` should disappear, is intentionally deferred until the user's next review of `pkg`.
