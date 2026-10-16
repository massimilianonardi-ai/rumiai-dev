# Package launcher one-shot environment preservation

Status: Active
Updated: 2026-10-16

## Goal
Implement and validate `m_ENV_DO_NOT_OVERRIDE` for one managed package invocation, preserving named inherited environment values at the final exec without changing managed state or privileged service context.

## Current repository revisions
- rumiai-dev: c123ad23ad91e158239e65ac926e672f70a93660 (before this checkpoint)
- rumiai-os: 0d83d044222f271b99d873a403629e7df34ea1c8
- rumiai-tests: 11f62d1dc471ded4968e0b7c06470c3acb0c083d
- pkg-catalog: 003efc67578c3bb8c468917074067edc77ab14dd
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
- Validation harness audit completed on 2026-10-16: the permanent test exercises the real managed `node` command but previously had no declared preparation requirement, so an otherwise preparable missing Node installation could become a test SKIP.
- rumiai-tests `dc406126f1af49ffd47fd24a57b32309f97aa12c` adds `validation/requirements/pkg-launch-environment-preservation.conf`, binding the test selection to real target package `nodejs`.
- rumiai-tests `11f62d1dc471ded4968e0b7c06470c3acb0c083d` adds the dedicated task scope `validation/pkg-launch-environment-preservation.conf`.

- Physical host report (2026-10-12, `admino@vmdev`, checkout `/m/src/git/rumiai-os_TEST` at `rumiai-os` `c3717a8`): after `git pull --ff-only`, `./m node -p 'process.env.HOME'` printed `/m/src/git/rumiai-os_TEST/state/user/default/pkg/nodejs/home`; `m_ENV_DO_NOT_OVERRIDE=HOME ./m node -p 'process.env.HOME'` printed `/home/admino`. This directly validates the baseline and explicit HOME override on that host only.

- User report (2026-10-12): after prior `srv start web-control` failed with `provider-resolution-failed` and `pkg default web-control` did not select the provider, the user reported that the operational workflow works following instructions to select the `web-control` facility provider (`pkg provider default web-control electron-web-control`) and run Amazon Watch wishlist extraction. No structured extractor output was supplied in this report, and the report is not evidence that Electron has integrated `m_ENV_DO_NOT_OVERRIDE` or that NSS certificates are isolated to the consumer HOME.

- Electron provider packaging completed: `electron-web-control` v0.1.5 integrates one-shot HOME preservation at the managed nested Electron launch (`electron-web-control` main `22da3beab20e509cffcbd81866b51253df4e08a9`). GitHub Actions run 38275307984 Linux validation/build/release jobs succeeded; upstream GitHub Release v0.1.5 published with `electron-web-control-v0.1.5-all.tar.gz` targeting that exact commit.
- `pkg-catalog` main `3b80bdf67a723c20ee81a7ebbfa24d2d922e0261` added the v0.1.5 range, preserving `web-control 2` and the existing Electron/Node dependency declarations.
- Independent deferred trust-management work: `todo/browser-certificate-trust-centralization.md`. The user does not have the corporate CA at home and explicitly deferred certificate work; do not ask them to rerun TLS/certificate experiments for this release.

- User-reported physical outcome (2026-10-12): after the assistant supplied direct managed-Node checks for preserving multiple variables with special characters, one-shot behavior across a nested managed invocation, and explicit errors for missing/duplicate variables, the user confirmed that everything worked as expected. No detailed logs were attached to that confirmation; it is user-observed acceptance of those scenarios, not independently collected exhaustive/automated coverage or corporate-CA verification.

## Current state
The launcher implementation, canonical package contract, operational manual and permanent regression test are present. The previously identified validation-harness defect is corrected: formal validation now knows that the environment-preservation test requires the real managed `nodejs` target package, and the task has a dedicated validation scope. Repository consistency review confirmed the new requirement selects exactly `rumiai-os/pkg-launch/environment-preservation.test` and uses the existing package identity `nodejs`.

An attempted autonomous execution of `./rumiai-validate pkg-launch-environment-preservation` on 2026-10-16 could not start because the available auxiliary container could not resolve `github.com` while cloning the exact repositories (`Could not resolve host: github.com`). This is validation-environment failure, not product/test PASS or FAIL. No further test action is requested from the user.

## Next action
Execute the dedicated `pkg-launch-environment-preservation` validation scope when an autonomous maintained environment with GitHub/network access is available. If it passes, perform the final completion snapshot and remove this handoff in the subsequent forward commit. Do not request the user to execute or debug the suite.

## Blockers / open questions
Formal automated execution is currently blocked only by lack of GitHub DNS/network access in the available auxiliary execution environment. The existing user-observed physical acceptance remains valid for the properties it exercised, but must not be relabelled as automated validation. Corporate CA/central trust management remains independent deferred work and is not a blocker for the launcher contract.