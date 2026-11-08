# Podman repository adapter

## Intent

Implement the missing `podman` repository adapter for the catalog’s macOS ARM64 package stream and validate the installed CLI through the package manager.

## Why pending

Pinned `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442` declares `repository/type=podman` for `podman/macos-arm64`, but `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d` has no matching adapter. The stream pins v6.1.2’s official macOS ARM64 installer, SHA-256, flat-package extraction and `podman` command link. Other platform formats are not represented by this catalog stream.

## Scope

- `m-os` repository adapter, manual and macOS ARM64 package-install validation
- The declared Podman macOS ARM64 stream; other OS/architecture support needs separate catalog and extractor work

## Evidence

- `pkg-catalog/v1/pkg/podman/macos-arm64` at `0b69223a` (`v6.1.2`)
- [Official Podman v6.1.2 release](https://github.com/podman-container-tools/podman/releases/tag/v6.1.2)
- [Official Podman installation documentation](https://podman.io/docs/installation)
