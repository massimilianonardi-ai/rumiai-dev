# pkg install real validation

Status: Active
Updated: 2026-09-17

## Goal

Rebuild `pkg install` validation from authentic execution of the public command on a real auxiliary Debian host, after first auditing the current implementation and catalog. Remove package-install tests that do not provide trustworthy composed-path evidence, debug real product/catalog defects exposed by execution, and keep validation claims limited to properties actually exercised.

## Current repository revisions

```text
rumiai-dev   cd106beb8cc5241d2f19b395a184109cf3935258
rumiai-os    b18ae4439519bfe4081035a7d6d0a29423a81709
rumiai-tests ceca7ec2cff6d537860cc9344d7beb8eb99c4c9e
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
```

Concurrent `rumiai-dev` changes after the latest retrieval concern documentation/pager work. Concurrent `rumiai-tests` changes from `d59a05417e91a97a10424f6dbc25047f9bfee383` to `ceca7ec2cff6d537860cc9344d7beb8eb99c4c9e` concern only the `read-key` tests. They do not alter the package-install work described here.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
```

The current `pkg install` implementation and current package definitions are factual/mechanical evidence after those sources.

## Current explicit user corrections

- Target-specific package catalog directories must be named directly as `<os>-<arch>` under each package; the `catalog-` prefix is unnecessary and must not remain.
- Existing tests that purport to validate `pkg install` are not trusted as evidence and are to be eliminated rather than incrementally preserved.
- Test work must restart from real execution on the ChatGPT-provided Debian VM: first audit the implementation for defects and expected behavior, then execute `pkg install` for real on that VM.
- If the VM has no direct Internet access, use an explicit transport workaround rather than replacing the package pipeline with mocks or stubs.

These current user corrections supersede the previous task-local choice that assigned permanent proof responsibilities to `tests/rumiai-os/pkg/install.test` and `tests/external/nodejs/install-live.test`.

## Implemented changes

### pkg-catalog

Commit `dd96a82e9022fb7c6f926d2b4b81f4718e824bb6` removes the `catalog-` prefix from every target-specific stream directory across the current package set. The change was performed by reusing the existing Git subtree SHAs. GitHub compare reports the catalog files as renames with zero additions/deletions of file content.

Examples now use:

```text
nodejs/linux-x86_64/...
jq/linux-x86_64/...
```

rather than `catalog-linux-x86_64`.

### rumiai-os

The current `pkg install` audit confirmed the composed path:

```text
catalog snapshot
-> target stream/range selection
-> repository adapter
-> version/artifact resolution
-> download
-> size/digest verification
-> extraction/materialization
-> integration
```

The generic installer still built target stream paths as `catalog-$pkg_install_target`. This was realigned to `$pkg_install_target`.

Two forward commits were produced because the first full-file write accidentally changed an unrelated catalog-branch validation variable. The immediately following correction restored that line. The net comparison from the pre-change baseline `8c69d50bf675f6fab7ab447b71542c7808c988a8` to current `b18ae4439519bfe4081035a7d6d0a29423a81709` contains only the intended one-line semantic change:

```text
catalog-$pkg_install_target
->
$pkg_install_target
```

No product defect beyond the obsolete target-stream spelling has yet been established by real execution.

## Debian auxiliary VM state

The available auxiliary host was detected as Debian 13 x86_64. Direct outbound connectivity is unavailable; the failure is not limited to DNS, so the VM cannot directly clone GitHub or download upstream package artifacts.

This environment is still useful under `TESTING.md`, provided it executes the real public command and real target components. Network unavailability must be solved at the transport boundary, not by replacing installer/catalog/adapter/download/extraction/integration logic.

## Repository archive transfer work

The user requested transferring the full repository archive into the VM rather than reconstructing a reduced target by hand.

Direct binary archive download through the available VM/web path is blocked. A temporary branch was therefore created in `rumiai-os`:

```text
tmp/pkg-install-vm-transfer-20260917
```

The branch is based on exact product revision:

```text
b18ae4439519bfe4081035a7d6d0a29423a81709
```

and currently points to temporary workflow commit:

```text
f9c374098abe95577bc1dd75cfb436460e0cb782
```

The workflow `.github/workflows/vm-transfer-rumiai-os.yml` checks out exactly `b18ae4439519bfe4081035a7d6d0a29423a81709`, verifies the checked-out SHA, produces both:

```text
rumiai-os-b18ae4439519bfe4081035a7d6d0a29423a81709.zip
rumiai-os-b18ae4439519bfe4081035a7d6d0a29423a81709.tar
```

plus SHA-256 files, and uploads them as one GitHub Actions artifact.

The TAR is intended for execution because the repository contains Git symlinks (for example `bin/sys/m`, mode `120000`) and executable modes; TAR is the safer faithful materialization format even though ZIP is also produced as requested.

The initial branch push did not start a workflow run. The connected GitHub interface can inspect/re-run existing Actions runs but does not expose an action for starting `workflow_dispatch`, so the artifact has not yet been produced or transferred into the VM. The workflow now declares `workflow_dispatch` so a manual GitHub UI start is possible if no fully autonomous trigger becomes available.

## Test state

The current user instruction is to remove the existing package-install proof tests and rebuild from observed real execution rather than preserve their current assertions. They have not yet been deleted in this task checkpoint; deletion and replacement should follow the real Debian execution path so the new permanent test is derived from actually observed behavior.

Component tests for distinct package responsibilities are not automatically in this removal scope merely because they concern the package subsystem; the explicit removal target is tests claiming `pkg install` behavior without trustworthy real execution.

## Validation evidence obtained in this phase

- All involved remote HEADs were refreshed before writes.
- Current `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `specifications/README.md` and `PACKAGE-MODEL.md` were re-read.
- The complete current `pkg install` source path relevant to target stream selection and composed installation was inspected.
- `pkg-catalog` rename diff was reviewed as content-preserving renames.
- `rumiai-os` net diff from the pre-change baseline was re-read and contains only the target-stream path correction.
- Debian host identity and lack of outbound network were observed directly.
- No end-to-end `pkg install` execution has yet succeeded on Debian; no PASS claim exists for the current product/catalog revisions.

## Next action

Obtain a faithful full `rumiai-os` snapshot inside the Debian VM. Preferred prepared path: start the temporary `vm-transfer-rumiai-os` workflow, download its artifact through the connected GitHub interface, materialize the TAR/ZIP into the VM, verify SHA-256 and exact target revision, and use the TAR-extracted tree as the executable target.

Then solve the external package/network boundary without replacing any `pkg install` component, execute the public `pkg install` command manually on Debian, inspect every real failure, and only after the real path is understood remove/rebuild the permanent package-install tests.

## Blockers / open questions

- The Debian VM has no outbound Internet connectivity.
- The GitHub connector currently exposes no method to initiate a new `workflow_dispatch` run; the temporary workflow is prepared but not executed.
- The full repository archive is therefore not yet present in the VM.
- End-to-end `pkg install` behavior at the current revisions remains unvalidated.
