# Package launcher one-shot environment preservation

Status: Active
Updated: 2026-10-12

## Goal
Implement and validate `m_ENV_DO_NOT_OVERRIDE` for one managed package invocation, preserving named inherited environment values at the final exec without changing managed state or privileged service context.

## Current repository revisions
- rumiai-dev: 239e6fe6afc4267f91f1874d80824079431dbbef (before this handoff)
- rumiai-os: c3717a8eaab1cb122519156166ac71f47a30af7a
- rumiai-tests: 2e198877323d124049685535ecc438f1ce2bd7ea
- electron-web-control: 7012c364beb3d082754cd1eeb23f904750cde9c0
Recheck remote HEADs at resumption.

## Applicable canonical sources
- README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/STATE-MODEL.md
- specifications/rumiai-os/SERVICE-LIFECYCLE.md
- specifications/rumiai-os/DIAGNOSTICS.md
- rumiai-os/lib/sys/sh/pkg/pkg-launch.lib.sh
- rumiai-os/res/sys/manual/pkg-launch.lib.sh

## Fixed task-local choices
- Explicit, normal or nested, one-shot `m_ENV_DO_NOT_OVERRIDE` with whitespace-separated identifiers.
- Missing variables, duplicates, malformed lists: error. Existing empty values are valid.
- Preservation takes highest precedence only for the final target environment; never changes `state-path`, configuration processing, package identity, provider selection, service context or operating-system principal.
- When absent, old behavior remains unchanged.
- The request and `m_PKG_LAUNCH_CONTEXT` / `m_PKG_LAUNCH_STATE_INSTANCE` cannot be protected or re-propagated as that contradicts consumed control-plane semantics.

## Acceptance scenarios
1. Managed `node` normally receives its package HOME; with `m_ENV_DO_NOT_OVERRIDE=HOME`, the child receives the inherited HOME.
2. Multiple variables, empty values, special characters in values are delivered correctly; the request is not inherited.
3. Malformed, duplicate, missing and control-variable requests fail distinctly without executing the target.
4. Managed service identity and state paths are unchanged.
5. Real Electron/web-control HTTPS navigation uses a CA confined to the intended consuming application context with TLS verification enabled.

## Completed
- Launcher: rumiai-os 69f97b86e751214e723df35dd53139ec92739565.
- Launcher manual: rumiai-os c3717a8eaab1cb122519156166ac71f47a30af7a.
- Canonical contract: rumiai-dev 05e419a5ddbd194158622756a849b8d273c7cb9f.
- Regression test added and made executable: rumiai-tests 23375546a9eae8148e255a808dab9544a410e5c5.

- Physical host report (2026-10-12, `admino@vmdev`, checkout `/m/src/git/rumiai-os_TEST` at `rumiai-os` `c3717a8`): after `git pull --ff-only`, `./m node -p 'process.env.HOME'` printed `/m/src/git/rumiai-os_TEST/state/user/default/pkg/nodejs/home`; `m_ENV_DO_NOT_OVERRIDE=HOME ./m node -p 'process.env.HOME'` printed `/home/admino`. This directly validates the baseline and explicit HOME override on that host only.

- User report (2026-10-12): after prior `srv start web-control` failed with `provider-resolution-failed` and `pkg default web-control` did not select the provider, the user reported that the operational workflow works following instructions to select the `web-control` facility provider (`pkg provider default web-control electron-web-control`) and run Amazon Watch wishlist extraction. No structured extractor output was supplied in this report, and the report is not evidence that Electron has integrated `m_ENV_DO_NOT_OVERRIDE` or that NSS certificates are isolated to the consumer HOME.

- Electron provider packaging completed: `electron-web-control` v0.1.5 integrates one-shot HOME preservation at the managed nested Electron launch (`electron-web-control` main `22da3beab20e509cffcbd81866b51253df4e08a9`). GitHub Actions run 38275307984 Linux validation/build/release jobs succeeded; upstream GitHub Release v0.1.5 published with `electron-web-control-v0.1.5-all.tar.gz` targeting that exact commit.
- `pkg-catalog` main `3b80bdf67a723c20ee81a7ebbfa24d2d922e0261` added the v0.1.5 range, preserving `web-control 2` and the existing Electron/Node dependency declarations.
- Independent deferred trust-management work: `todo/browser-certificate-trust-centralization.md`. The user does not have the corporate CA at home and explicitly deferred certificate work; do not ask them to rerun TLS/certificate experiments for this release.

- User-reported physical outcome (2026-10-12): after the assistant supplied direct managed-Node checks for preserving multiple variables with special characters, one-shot behavior across a nested managed invocation, and explicit errors for missing/duplicate variables, the user confirmed that everything worked as expected. No detailed logs were attached to that confirmation; it is user-observed acceptance of those scenarios, not independently collected exhaustive/automated coverage or corporate-CA verification.

## Current state
Commits are forward-only. A local POSIX shell sanity check verified indirect variable capture and byte-preserving env argv delivery; this was not a run of the actual RumiAI package launcher. After final review, malformed and duplicate override requests use distinct statuses (3 and 7). The baseline/override HOME pair was exercised through real `./m node` on `vmdev`; the user subsequently reported success for the additional multi-variable, nested-call and error-path examples. The full permanent test suite and the corporate-CA Electron HTTPS scenario have not been verified against this revision.

## Next action
Audit the authored regression test for harness defects and incorrect assumptions; refine and execute validation autonomously on an available maintained test environment where feasible. Do not request further tests or test-environment debugging from the user. The original `./m node` HOME output is directly observed; the user also confirmed successful outcomes for later ad hoc checks without supplying logs. The Electron v0.1.5 source, Linux-validated release artifact and package catalog metadata are published. Preserve the remaining general launcher-validation work as developer-owned; the corporate CA/central trust-management topic is deferred under its independent TODO. Physical enterprise TLS evidence must not be claimed for this release.

## Blockers / open questions
The RumiAI GitHub Actions Linux release pipeline succeeded; no direct execution against the user's corporate VM or corporate CA has been performed for Electron v0.1.5. The user explicitly declines running further tests after substantial past time loss debugging test defects rather than product defects. Treat further test authoring/execution/debugging as the development workflow's responsibility; do not require the user to run the test suite. Full automated/physical evidence remains pending and must not be reported as obtained.
