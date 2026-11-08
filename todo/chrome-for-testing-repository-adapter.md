# Chrome for Testing repository adapter

## Intent

Implement the missing `chrome-for-testing` repository adapter for the catalog’s `chromium/linux-arm64` stream, including exact and Stable-latest artifact resolution.

## Why pending

Pinned `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442` declares `repository/type=chrome-for-testing` for `chromium@153.0.8010.12` on Linux ARM64, but `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d` has no matching adapter. The other five Chromium streams use the separate `chromium` repository type. CfT exposes exact and stable-channel URLs; Cloud Storage provides size and base64 MD5 headers that the adapter must safely convert and validate.

## Scope

- `m-os` repository adapter, manual and isolated public install validation
- The single existing `chromium/linux-arm64` CfT stream; do not migrate other streams

## Evidence

- `pkg-catalog/v1/pkg/chromium/linux-arm64` at `0b69223a` (`n0001=153.0.8010.12`)
- [Official Chrome for Testing API documentation](https://github.com/GoogleChromeLabs/chrome-for-testing)
- [Official Stable latest-version metadata](https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json)
- [Google Cloud Storage XML response headers](https://cloud.google.com/storage/docs/xml-api/reference-headers)
