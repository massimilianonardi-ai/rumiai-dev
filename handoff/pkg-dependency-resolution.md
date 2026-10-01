# pkg dependency resolution and recursive install

Status: Active
Updated: 2026-10-01

## Goal

Complete and validate the promoted recursive `pkg install` model built around the public read-only `pkg depend` dependency planner, while continuing the catalog/install resolver cleanup in progress.

## Current repository revisions

- rumiai-dev: e47aa907bdcd4706760a6b418628f73722345166 (pre-checkpoint HEAD)
- rumiai-os: c2f7c739b2ded45eeab6d0027aa2f99cf85d343e
- rumiai-tests: a150d7d020602068b4af809bb440864766a03fe6
- pkg-catalog: d63f87d2be67288ef57f4a5812fabbc3f0b24a0d

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md

## Fixed task-local choices

- `pkg depend <package-spec>...` is read-only and returns recursive dependency concrete identities only, in dependency-first order.
- Explicit requested roots are omitted from `pkg depend` output unless the same concrete is also selected as a dependency node of another request.
- `pkg install <package-spec>...` validates the complete original request list before catalog initialization, dependency planning or installation.
- After validation, `pkg install` initializes one catalog snapshot, resolves every requested root to an exact concrete identity, calls `pkg depend` on those exact concrete roots, prepends the returned dependency concretes, then installs the resulting dependency-first concrete sequence.
- Dependency planning and root installation therefore operate on the same exact root identities selected from the same catalog snapshot.
- No new public `pkg_local_current` API is being introduced at this stage. Per the user's current direction, the simplified install resolver temporarily reuses the existing private `_pkg_local_class_scan` behavior directly.
- The direct cross-library private call is a task-local implementation choice, not a promoted library-interface contract and must not be generalized as public API.
- Further cleanup of `_pkg_install_init` / `_pkg_install_end` and catalog/workspace lifecycle remains deferred until the user's later review of `pkg`.
- `extract2` and `pkg-extract2.lib.sh` remain temporary filenames; their internal namespaces already match the future promoted `extract` / `pkg-extract` identities.

## Acceptance scenarios

- `pkg depend geoserver` returns only the concrete Java provider dependency (plus recursive provider dependencies), not the GeoServer root.
- A dependency-free requested root produces empty successful `pkg depend` output.
- If one explicit root is also selected as a dependency of another root, that concrete still appears in `pkg depend` output.
- Any syntactically invalid request in a `pkg install` batch fails before catalog initialization or dependency planning and prevents all installation.
- `pkg install geoserver` resolves GeoServer to an exact concrete root, plans dependencies from that concrete root, installs dependency concretes first and then installs the GeoServer concrete.
- Multiple requested roots preserve their request order after root concretization and after all dependency concretes are prepended.
- Already-installed compatible dependency concretes may satisfy dependency nodes without reinstallation.
- An unversioned root may reuse the valid installed current/default concrete for the selected package/platform class.
- Malformed managed-store entries must not be accepted as valid already-installed concretes.

## Current implementation state

Current rumiai-os `c2f7c739b2ded45eeab6d0027aa2f99cf85d343e` keeps `_pkg_install_init` before request resolution and implements this flow:

```text
validate complete original request argv
→ initialize install workspace/catalog
→ resolve original requests to exact concrete roots
→ pkg depend(exact concrete roots)
→ prepend dependency concretes to concrete roots
→ pkg_install_one for each concrete
```

The simplified `pkg_install_resolve_one` delegates package-stream selection to `pkg_catalog_stream_resolve` and version selection to `pkg_catalog_version_resolve`, removing duplicated repository-adapter/version-resolution logic.

The previously proposed `pkg_local_current` function does not exist and is no longer assumed. The unversioned-local reuse path now calls:

```sh
_pkg_local_class_scan "$pkg_install_pkg" "$pkg_install_identity_osarch" || exit 5

if [ -n "$pkg_local_class_current_name" ]
then
  printf -- '%s\n' "$pkg_local_class_current_name"
  exit 0
fi
```

This preserves the prior distinction between a valid class with no current concrete and an invalid/corrupt local class state.

The exact-version already-installed shortcut in the simplified resolver still uses only:

```sh
[ -d "$m_PKG_DIR/$pkg_install_concrete" ]
```

and therefore still differs from the previous implementation's explicit `-e/-L` plus real-directory validation for malformed or symlinked managed-store entries. This remains open.

The previous implementation remains temporarily present as `___pkg_install_resolve_one` for comparison and must be removed once equivalence is restored.

A library-interface consistency mismatch remains open: `pkg_install_resolve_one`, `pkg_install_resolve`, and `pkg_install_validate` are currently non-underscore function names and therefore public by the current library-interface contract, but `res/sys/manual/pkg-install.lib.sh` does not expose them. Do not silently resolve this by documenting accidental helpers or renaming callable API without checking intended ownership and consumers; this requires explicit realignment in the continuing pkg work.

The operational manual `res/sys/manual/pkg-install.lib.sh` was realigned in rumiai-os `c2f7c739b2ded45eeab6d0027aa2f99cf85d343e` to describe the current concrete-root-before-dependency-planning flow.

## Permanent-test state

Current rumiai-tests HEAD is `a150d7d020602068b4af809bb440864766a03fe6`.

Relevant existing coverage includes:
- `tests/rumiai-os/pkg/depend.test`
- `tests/rumiai-os/pkg/catalog.test`
- `tests/rumiai-os/pkg/install-dependency-order.test`
- `tests/rumiai-os/pkg/install-live.test`
- `tests/external/geoserver/install-dependency-live.test`

`install-dependency-order.test` still encodes the earlier orchestration shape in which untouched original roots reach the install loop, so it requires realignment to the current concrete-root flow before it can be treated as coverage of the current implementation.

No executable validation was run against rumiai-os `c2f7c739b2ded45eeab6d0027aa2f99cf85d343e` in the assistant environment. The environment has no mounted RumiAI checkout; an attempted fresh Git clone could not resolve github.com, and the available GitHub connector exposes repository reads/writes but no workflow-dispatch action. Older PASS results remain revision-specific evidence only and are not evidence for this revision.

## Next action

1. Restore strict managed-store entry validation in the exact-version shortcut of `pkg_install_resolve_one`.
2. Resolve the public/internal naming mismatch for the resolver/validator helper functions and realign the library manual accordingly.
3. Realign permanent install-order coverage to the concrete-root flow.
4. Remove `___pkg_install_resolve_one` once the simplified implementation is behaviorally equivalent.
5. Run proportional real validation, including the public GeoServer dependency-install path.

## Deferred

Further simplification of package/catalog temporary-directory lifecycle, including whether `pkg_catalog_init` should own its cleanup trap and whether `_pkg_install_init` / `_pkg_install_end` should disappear, remains intentionally deferred until the user's next review of `pkg`.
