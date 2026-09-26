# macOS Podman package

Status: Complete
Updated: 2026-09-26

## Goal

Implement a non-invasive RumiAI `pkg podman` for macOS arm64 using the exact official Podman installer payload without installing Podman into the host system.

## Final repository revisions

- rumiai-os: `7e78fc9842d1fd6acd6f83584c3b0a931f8027e7`
- pkg-catalog: `565adc534399e5d4759c8eae24fca197aa912ab9`
- rumiai-tests: `4bad71ec5b75adfb5e6ee1c98d5256e356bef605`
- rumiai-dev-PoCs: `94e2d6a385236a081815b0a700b7c2b2be0c92bd`
- rumiai-dev before this final handoff snapshot: `5990e321bb6909b00da5d54675ca727f48dd0ac6`

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- specifications/README.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- handoff/README.md

## Final design

- Scope is macOS arm64 only; no Linux Podman package was added.
- The official Podman v6.1.2 `podman-installer-macos-arm64.pkg` is used unchanged.
- Generic package materialization now supports `flat-pkg`: a macOS flat installer package is expanded and a selected component Payload is materialized without executing installer scripts or performing installer-owned host integration.
- The Podman package selects component `podman.pkg` and payload root `podman`.
- Podman helper discovery is redirected at runtime through `CONTAINERS_HELPER_BINARY_DIR` to the relocated managed package `bin/`; that directory is also prepended to the package process PATH.
- No Podman binaries are patched.
- Podman repository resolution uses a catalog-pinned provider-specific adapter, following the existing catalog-pinned adapter pattern: version, official release URL and SHA-256 are fixed in `pkg-catalog`, while the adapter validates them and resolves HTTP size. Installation therefore does not depend on the GitHub Releases API or credentials.
- The temporary experiment to authenticate the generic GitHub adapter with `GITHUB_TOKEN` was fully reverted after proving unsuitable for third-party public repositories with repository-scoped Actions tokens.

## Completed implementation

### rumiai-dev

- `PACKAGE-MODEL.md` defines `flat-pkg` alongside `dmg-pkg`.
- Invariants PKG-77 through PKG-81 now cover named component extraction, payload-root selection and the prohibition on executing installer scripts/system integration.

### rumiai-os

- Added direct `flat-pkg` extraction with host `pkgutil --expand-full`.
- Extended package install/integration validation for `flat-pkg` component and payload-root metadata.
- Updated relevant package manuals.
- Added `pkg-repository-podman.lib.sh` and its manual.

### pkg-catalog

Added `pkg/podman/macos-arm64` for Podman v6.1.2 with:

- `format = flat-pkg`
- `component = podman.pkg`
- `payload-root = podman`
- public command `podman`
- runtime helper environment
- official release URL
- official SHA-256 `88def43af7fbe7baf40fc2f12d69267f6d845768020709900fb1b8c3bfe015b3`

### rumiai-tests

Added:

- `rumiai-os/pkg-extract/flat-pkg.test`
- `rumiai-os/pkg-repository-podman/contract.test`
- `external/podman/install-live.test`
- task validation scope `podman`
- macOS GitHub Actions workflow for the Podman task

The flat-pkg fixture includes a postinstall trap and verifies that materialization does not execute it.

## Validation

Dedicated macOS task validation at rumiai-tests `4bad71ec5b75adfb5e6ee1c98d5256e356bef605` against rumiai-os `7e78fc9842d1fd6acd6f83584c3b0a931f8027e7`:

- `rumiai-os/pkg-extract/contract.test`: PASS
- `rumiai-os/pkg-extract/dmg-pkg.test`: PASS
- `rumiai-os/pkg-extract/flat-pkg.test`: PASS
- `rumiai-os/pkg-integration/contract.test`: PASS
- `rumiai-os/pkg-repository-podman/contract.test`: PASS
- `external/podman/install-live.test`: PASS
- task scope result: VALIDATED

The live test recorded:

```text
installed=podman@v6.1.2!macos-arm64
osarch=macos-arm64
version=podman version 6.1.2
machine-init=ok
host-system-integration=absent
```

It exercises the real RumiAI `pkg install podman`, the managed public command, `podman --version`, `podman machine info`, `podman machine init`, `podman machine inspect`, package-owned HOME/state, cleanup/uninstall, and verifies that `/opt/podman`, `/etc/paths.d/podman-pkg` and `/usr/local/etc/man.d/podman.man.conf` remain absent.

The complete health suite was also run on the same product revision. It remains red on both Ubuntu and macOS because of failures outside this task. Comparison with the immediately preceding health run shows no new unrelated FAIL/ERROR introduced by this work: the Ubuntu failure set is unchanged, while macOS Podman changed from FAIL to PASS and the previous `rumiai-os/pkg/install-live.test` failure no longer appears.

## Validation boundary

`podman machine start` and an actual container workload are not claimed as validated here. GitHub-hosted macOS arm64 runners are not treated as evidence for nested-virtualization behavior on a physical Mac. The package/runtime path through machine initialization is validated; physical VM start remains a separate host-dependent validation if required.

## Consistency gate

- Current remote HEADs were rechecked before closure.
- The current package specification contains the implemented `flat-pkg` contract.
- Final diffs were reread across rumiai-os, pkg-catalog and rumiai-tests.
- The temporary GitHub-token path is absent from the final generic GitHub adapter.
- Provider-specific identities/paths remain in package definition/adapter boundaries rather than generic extraction code.
- The official Podman binaries are preserved unchanged.
- Relevant permanent tests and the real live install scenario pass.
- Full-product health failures were not reclassified or hidden; they remain separate revision-specific evidence outside this task.

## Remaining task state

No implementation blocker remains for the macOS arm64 Podman package. The task is complete within the validation boundary stated above.
