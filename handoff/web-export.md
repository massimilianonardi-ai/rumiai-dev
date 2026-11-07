# Standalone web export — `m web-export`

Status: **Complete**
Updated: 2026-11-07

## Goal and contract

Deliver `m web-export <http(s)-url> <new-export-directory>` as a directly openable `file://` snapshot with no required server. The normative contract is [`specifications/rumiai-os/WEB-EXPORT.md`](../specifications/rumiai-os/WEB-EXPORT.md). The manifest records missing or ambiguous references, unverified bodies, source provenance and whether scroll restoration was generated.

## Implemented

- Added the exporter, command manual, pinned GitHub Actions workflow, and permanent real-Chromium fixture test.
- Export uses rendered `web-analyze` DOM and only digest/size-verified archived bodies or clearly labelled CSSOM stylesheet sources. HTTP errors, empty visual bodies, mismatched digests, ambiguous body versions, and non-HTTP(S) subresources are not silently treated as valid assets.
- Site scripts, frames, executable handlers, remote form submission and ping notifications are removed. Source `crossorigin`, integrity and referrer-policy attributes are removed from local resource elements so the standalone `file://` document can load rewritten files. A content-addressed exporter-owned local helper restores captured non-zero scroll offsets; its presence is recorded in the manifest and the CSP permits only local file scripts.
- Output uses private directory/file permissions, refuses existing destinations, includes SHA-256/size metadata and removes temporary capture data.
- The test invokes the public `m web-export` path with `m_ROOT` and `m_LIB_DIR` unset, captures a real local HTTP fixture through Chromium, opens output through Chromium `file://`, verifies no source-server requests on reopening, validates asset/document digests and permissions, and exercises missing, ambiguous, conflicting, tampered-body, CSSOM-fallback and capture-failure cases.

## Revisions

- Product worktree: `rumiai-os/.worktrees/web-export-os`, branch `work/web-export-20261107`, based on `5e33345b7e75c051255fb382ae30e6589d997863`.
- Tests worktree: `rumiai-tests` branch `work/web-export-20261107`; latest pushed test commit `bc17fa15c7cbc35d922833e6a4839c8ebda2b8b0`. Product workflow pins this exact revision.
- Docs worktree: `.worktrees/web-export-dev`, branch `work/web-export-20261107`, fast-forwarded to `rumiai-dev@7772a70cfac35235f8c3d02d572c168f150e3f93` before final edits.
- Existing base checkouts have not been modified. Repository changes are forward-only on task branches.

## Validation completed

- Local permanent test passed on Ubuntu 26.04.1 ARM64 with Node.js 26.13.0 and Chromium 157.0.8103.38, including the new assertion that only the exporter-owned scroll-restoration script remains and executes from a local file.
- `node --check` passed for exporter, analyzer and test support; `sh -n` passed for the shell test; `git diff --check` passed on the final product/test revisions.
- The provided ChatGPT shared page succeeded once with the public command on the pre-final CORS/readiness revision: 32 assets including the local scroll helper, document and all asset digests validated, no ambiguous or unverified bodies. The manifest reported 388 unavailable HTML references and 71 unavailable CSS references. Chromium `file://` rendered the conversation with the captured scroll restored. Other attempts returned `web-analyze.document-not-observed` (exit 11); each failure was safely propagated as exporter status 8 and left no output. Repeated page capture is therefore page-dependent/intermittent, not guaranteed. The successful run's 459 unavailable references mean that export was not a complete copy of every referenced page resource. The exact final revision is validated by the local and hosted fixture suites, but could not be re-captured on the live page after those final fixes.
- The post-`crossorigin` fix is covered by a passing local real-Chromium fixture using a source stylesheet with valid SRI and `crossorigin=anonymous`; the output removes fetch metadata and the test confirms Chromium reports no local stylesheet CORS block.
- Hosted GitHub Actions run [42409949351](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/42409949351) for product SHA `bb5349d47b26d326e1a96cdc2017d66f09f991d3` and pinned tests `bc17fa15c7cbc35d922833e6a4839c8ebda2b8b0` completed **SUCCESS** on Ubuntu 26.04 x64 with Node 22.23.4 and hosted Chromium. It exercises the permanent command fixture and CSSOM/conflict/synthetic failure paths. The earlier run failures (`42409698931`, target remote normalization; `42409776647`, readiness-event race) were corrected forward and remain accurately classified as failed intermediate runs.

## Completion and limits

- Current product, test and documentation remotes were rechecked. Product main remains `5e33345b7e75c051255fb382ae30e6589d997863`, tests main is `b49653e41813b08249e5ea5345c9f86028b0fbd8`, and dev main advanced to `7772a70cfac35235f8c3d02d572c168f150e3f93`; the docs task branch was safely fast-forwarded because its local changes did not overlap the remote commits.
- The public workflow is `m web-export <http(s)-url> <new-export-directory>`; it writes `index.html`, `manifest.json` and local assets and refuses an existing destination. The final review covered current routing, applicable command/documentation/diagnostics/platform and export specifications, implementation, manual, pinned test and workflow. Product, test and documentation changes are forward-only on `work/web-export-20261107`. Task-created private `/tmp` exports, screenshots, profiles and raw capture evidence were removed.
- Static behavior limits remain intentional: site JavaScript, backend/API operations, login state and removed frames are not reconstructed. Missing resources remain listed in the manifest; no universal completeness claim is made.
