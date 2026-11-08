# Chrome for Testing repository adapter

Status: Hosted exact/latest install acceptance passes on Ubuntu ARM64; public command execution, PR review and other platform coverage remain open
Updated: 2026-11-08

## Goal

Implement and validate the catalog-declared `chrome-for-testing` repository type for its existing `chromium/linux-arm64` stream, preserving the other Chromium streams and shared adapter behavior.

## Current repository revisions

- `m-os/master@a78a24bd37446ac9b7d510af5facc5c110de595d`
- `pkg-catalog/main@0b69223a5ebe7bc042aad50012ee8bc7e4a00442`
- `pkg-catalog/codex/m-os-adapter-runner@7556c8dd85b308474e02e5c54b8c89728d52c44f`
- `rumiai-dev/main@efd2bb7d3ea7c394c5ac4255b504f4d8e1847496`

Refresh all remote heads before the next repository write or validation.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`
- `TESTING.md`, `handoff/README.md`
- Exact pinned catalog `v1/pkg/chromium/linux-arm64` and current m-os Chromium adapter/manual

## Fixed task-local choices

- Limit support to the existing CfT `chromium/linux-arm64` stream anchored at `153.0.8010.12`; preserve the other five `chromium` repository streams.
- Use official Chrome for Testing stable metadata for version/channel identity and platform artifact URL; use Cloud Storage response metadata for positive size and validated MD5 according to the catalog contract.
- Do not add a new catalog stream or mutate the catalog.

## Acceptance scenarios

- Public exact dependency/install for `chromium@153.0.8010.12!linux-arm64` resolves the declared CfT artifact and installs it with integrity validation.
- Public unversioned dependency/install resolves the actual current Stable Linux ARM64 artifact through the same declared stream and exposes the catalog's Chromium command.

## Completed

- Activated the deferred TODO into this handoff after confirming the gap against current exact master/catalog and current source inventory.

## Current state

Draft PR [#16](https://github.com/massimilianonardi-ai/m-os/pull/16) is open and unmerged at `2f2e75bf66ef67ba6661fd51a9af55a05b158905`. On Linux ARM64, official exact `153.0.8010.12` and Stable latest `157.0.8103.38` resolved; exact/latest Cloud Storage metadata yielded object size `195926016` and MD5 `72f3441dd3fde1ccdb2ef2ddcc8d5de0`. The durable fake-transport fixture accepts exact/latest and expected descriptor, rejects wrong object name, zero size, malformed MD5, invalid archive regex and wrong digest type, and passed with its temp base under the checkout. `sh -n` and `git diff --check` pass. Hosted runner job `128738863182` in [run 42483023923](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42483023923) checked out exact adapter `2f2e75bf66ef67ba6661fd51a9af55a05b158905` and catalog `0b69223a5ebe7bc042aad50012ee8bc7e4a00442`; public exact and latest installs succeeded and `pkg versions` showed both `chromium@153.0.8010.12!linux-arm64` and `chromium@157.0.8103.38!linux-arm64`. The aggregate run was red only because an unrelated Podman job received upstream GitHub API HTTP 403; the CfT job itself passed. Chromium command execution, other platform coverage and PR review remain open.

Boundary incident: the first version of the fixture used the system `/tmp` default, and its executor ran it before the path issue was noticed. That script has been corrected to write under the checkout and was rerun with an explicit in-repo temp base. No `/tmp` cleanup or further access was attempted.

## Next action

Add a public `./m chromium --version` assertion to exact-head validation, verify its output against the installed Stable artifact, and obtain PR review. Keep PR #16 open and unmerged; supported platforms beyond Linux ARM64 remain unvalidated.

## Blockers / open questions

- Public exact/latest package install and hosted Linux ARM64 evidence pass; public command execution, other platform coverage and formal PR review remain pending.
- Stable latest and exact metadata were checked against official endpoints at the recorded date; rerun on the hosted workflow rather than assuming these values remain current.
