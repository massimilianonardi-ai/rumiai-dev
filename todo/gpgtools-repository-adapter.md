# GPGTools repository adapter

## Intent

Implement the missing `gpgtools` adapter for the catalog’s single `macgpg/macos-arm64` stream and validate installation through public `m` commands on macOS ARM64.

## Why pending

Pinned `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442` declares `repository/type=gpgtools` for `macgpg@2026.1+3633n`, but `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d` has no matching adapter. The official nightlies index confirms the pinned DMG and SHA-256 but exposes no release history sufficient to establish broader chronology; initial support should stay bounded to the catalog’s exact stream and fail closed on changed metadata.

## Scope

- `m-os` repository adapter, manual and macOS ARM64 install validation
- The current `macgpg/macos-arm64` stream; broader platform or historical version discovery requires separate evidence

## Evidence

- `pkg-catalog/v1/pkg/macgpg/macos-arm64` at `0b69223a` (`2026.1+3633n`)
- [Official GPGTools Nightlies / Hotfix index](https://releases.gpgtools.org/nightlies/)
- [GPG Suite 2021.1 release notes](https://gpgtools.org/releases/gpgsuite/2021.1/release-notes.html)
