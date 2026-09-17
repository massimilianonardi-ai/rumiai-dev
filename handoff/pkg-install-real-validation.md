# pkg install real validation

Status: Active  
Updated: 2026-09-17

## Goal

Rebuild `pkg install` validation from authentic execution of the public command on the ChatGPT-provided Debian host, after auditing the current implementation/catalog. Remove package-install tests that do not provide trustworthy composed-path evidence, fix real product/catalog defects exposed by execution, and keep validation claims limited to properties actually exercised.

## Current repository revisions observed

```text
rumiai-dev   8ea9ce8438edd003b205a77d76eb66cf17292c83
rumiai-os    14e413342261b23df840f40b355166c4d55f1b41
rumiai-tests ae0f41b23ae477bf2f1b13332b4c52bf2df16f2f
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
```

`rumiai-os` advanced from the package-work revision `b18ae4439519bfe4081035a7d6d0a29423a81709` to `14e413342261b23df840f40b355166c4d55f1b41` through five commits affecting only `bin/sys/manual`, new `bin/sys/pager`, and their manual resources. The package implementation is unchanged by that delta.

`rumiai-tests` also advanced concurrently; the observed delta after `ceca7ec2cff6d537860cc9344d7beb8eb99c4c9e` affects digest/http-fetch/json/log tests and does not alter the package-install test files involved in this task.

## Current explicit user corrections

- Target-specific package catalog directories are named directly as `<os>-<arch>` under each package; the `catalog-` prefix must not remain.
- Existing tests that purport to validate `pkg install` are not trusted as evidence and are to be removed rather than incrementally preserved.
- Test work restarts from real execution on the Debian VM: audit implementation first, then execute `pkg install` for real.
- Lack of direct VM Internet access must be solved at the transport boundary, not by replacing package logic with mocks or stubs.

## Implemented changes

### pkg-catalog

Commit `dd96a82e9022fb7c6f926d2b4b81f4718e824bb6` removes the `catalog-` prefix from every target-specific stream directory by reusing the existing subtrees; file content is unchanged.

Examples now use:

```text
nodejs/linux-x86_64/...
jq/linux-x86_64/...
```

### rumiai-os

The audited install path is:

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

The target-stream selector was realigned from `catalog-$pkg_install_target` to `$pkg_install_target`. After an accidental unrelated variable edit in the first forward commit and its immediate forward correction, the net package-related diff from baseline `8c69d50bf675f6fab7ab447b71542c7808c988a8` to `b18ae4439519bfe4081035a7d6d0a29423a81709` contains only that intended one-line semantic change.

No additional product defect has yet been established by real execution.

## Debian auxiliary VM state

The auxiliary host is Debian 13 x86_64. Direct outbound connectivity is unavailable beyond the VM, so it cannot clone GitHub or download upstream package artifacts directly.

### Full repository transfer completed

A temporary `rumiai-os` branch exists only as a transfer bridge:

```text
tmp/pkg-install-vm-transfer-20260917
```

Workflow commit:

```text
f9c374098abe95577bc1dd75cfb436460e0cb782
```

The workflow checks out exact product revision:

```text
b18ae4439519bfe4081035a7d6d0a29423a81709
```

The user started the workflow successfully. GitHub Actions run `35268060605` completed with conclusion `success` and produced artifact `10517940248`.

The artifact was downloaded through the connected GitHub interface into the VM and contains:

```text
rumiai-os-b18ae4439519bfe4081035a7d6d0a29423a81709.zip
rumiai-os-b18ae4439519bfe4081035a7d6d0a29423a81709.zip.sha256
rumiai-os-b18ae4439519bfe4081035a7d6d0a29423a81709.tar
rumiai-os-b18ae4439519bfe4081035a7d6d0a29423a81709.tar.sha256
```

Both archive hashes were recomputed inside Debian and exactly match the workflow-generated SHA-256 values:

```text
ZIP f784d0588ebdd1d7bb71da6c98e8083ef362c0a8b176539169e6c0a1f7e20d04
TAR 0f35d4889cded226595917c11001f1b823538bcb1502a307673b78ce6bcf8130
```

The TAR was extracted at:

```text
/mnt/data/rumiai-os-vm-transfer/extracted
```

The extracted tree preserves executable modes and Git symlinks; specifically `bin/sys/m` is a symlink to `../../m`, and `m` / `bin/sys/pkg` are executable.

Because the subsequent `rumiai-os` main delta to `14e413342261b23df840f40b355166c4d55f1b41` touches only manual/pager surfaces, this snapshot remains suitable for exploratory execution of the unchanged package path. It is not formal evidence for the later overall `rumiai-os` revision.

## Test state

The existing package-install proof tests are still pending removal. They must not be credited as evidence for this task. Replacement tests will be designed only after observing the real Debian execution path.

Component tests for distinct package responsibilities are not automatically in the removal scope; the explicit target is tests claiming `pkg install` behavior without trustworthy composed-path execution.

## Evidence obtained

- RumiAI preflight sources were refreshed and applied before the package work.
- The `pkg-catalog` rename and `rumiai-os` selector correction were diff-reviewed.
- The Debian host identity and lack of outbound network were directly observed.
- The full `rumiai-os` product snapshot was transferred through GitHub Actions rather than reconstructed file-by-file.
- ZIP and TAR integrity were independently checked in Debian.
- TAR extraction preserved the execution-relevant filesystem metadata checked so far.
- No end-to-end `pkg install` execution has yet succeeded on Debian; there is still no PASS claim for composed installation.

## Next action

Solve the remaining external package-data/network boundary without replacing any `pkg install` component. Then execute the real public `pkg install` command against the transferred product tree, inspect every real failure, and only after the real path is understood remove/rebuild the permanent package-install tests.

## Remaining blocker

The Debian VM still has no direct outbound Internet connectivity for catalog refresh, repository API calls or package artifact download. Repository materialization itself is no longer blocked.
