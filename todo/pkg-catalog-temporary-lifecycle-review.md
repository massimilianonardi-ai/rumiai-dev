# Package/catalog temporary lifecycle review

## Intent

Review the ownership and necessity of package install/catalog temporary workspaces and their cleanup responsibilities, without changing the public package semantics or the successful P2 failure-cleanup guarantees.

## Why pending

P2 verified source and real hosted failure cleanup, but deferred a broader simplification review until the next operator-directed `pkg` maintenance pass. No current defect establishes a need to remove working init/end helpers merely for brevity.

## Scope

- `m-os/lib/sys/sh/pkg/pkg-install.lib.sh` and `pkg-catalog.lib.sh`
- Related operational library manuals and proportional failure-path tests if a change is justified

## Evidence

- Current `m-os/master` `_pkg_install_init` installs the `_pkg_install_end` trap and invokes `pkg_catalog_init`.
- `rumiai-dev/specifications/rumiai-os/PACKAGE-MODEL.md` requires bounded installation state and real cleanup on failures.
- P2 full-public corrupt-artifact CI [run 42197729661](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42197729661) passed both hosted platforms at merged `m-os/master@a08f473...`.
