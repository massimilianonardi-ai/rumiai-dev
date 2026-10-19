# Playwright webpage analysis library

Status: Active
Updated: 2026-10-19

## Goal

Implement the directly executable Node.js library `rumiai-os/lib/sys/js/web-analyze-pw.lib.js` for deep inspection of an HTTP(S) page. User-fixed invocation:

```sh
nodejs <path-to-lib> <url> <analysis-dir>
```

The library creates `<analysis-dir>` when missing and accepts an existing directory. The first test target is `https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835`.

## Current repository revisions

- rumiai-dev: 2dc4396b7bb62e8461373de102028932339f70ab (pre-checkpoint HEAD)
- rumiai-os: aaa2afe989ef9c619049698fa5ac2d54eb768af4
- rumiai-tests: 6ee9b70314d4779dbc41df0141eaff5d1f15f85d
- pkg-catalog: 68b576f138400770ce1c1bd69ebf169cccc3c3df (read-only)

Fresh remote HEAD retrieval remains required for subsequent work.

## Applicable canonical sources

README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md, specifications/README.md, specifications/rumiai-os/{CURRENT-MODEL,FILESYSTEM-NAMING,LIBRARY-INTERFACES,DOCUMENTATION-MODEL,COMMAND-ENTRYPOINTS,DIAGNOSTICS,WEB-CONTROL,PACKAGE-MODEL}.md.

## Fixed task-local choices

- **Explicit user correction:** no separate `web-analyze-pw` command or command manual. Run `nodejs <path-to-lib> <url> <analysis-dir>` with exactly two program operands. The source is a non-executable CommonJS `.lib.js` despite direct Node invocation. No fixed path for `playwright` is required.
- Resolve the external literal `playwright` executable via PATH; use a temporary process preload probe to load the matching installed Node Playwright API and its browser-cache location. Do not confuse Playwright's CLI with the full Node automation API.
- Keep this separate from the native-CDP `web-analyze.lib.js` library and the provider-independent `web-control` API. Preserve concurrent edits to those components.
- The analysis directory is created recursively if absent. Each run creates a distinct private `run-*` child within it; never overwrite existing evidence.
- Capture JSONL lifecycle, navigation, network, console/errors, DOM-mutation and scroll/performance events, HTML/PNG checkpoint snapshots, a Playwright trace and best-effort final native MHTML. Avoid automatic capture of secrets/headers/request bodies into JSONL.
- Default Chromium is visible. Automated wheel sweep attempts down/up positions on the dominant scrolling container. Virtualized DOM observations are per checkpoint, not guaranteed complete chat archives.

## Acceptance scenarios

1. `nodejs lib/sys/js/web-analyze-pw.lib.js https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835 ./analysis` discovers Playwright by PATH and writes a new private session directory.
2. Re-running with the same `./analysis` directory works without deleting or overwriting earlier sessions.
3. Navigation/network/errors, DOM mutations and snapshots during wheel scroll are captured, including a nested virtualized scroller.
4. Missing/invalid operands and browser failures produce distinct diagnostics; partial evidence and interruption state are retained.
5. No separate `bin/sys/web-analyze-pw` command exists and the library is documented as a Node invocable module.

## Completed

- Retrieved current remote HEADs and canonical sources; inspected existing JavaScript library/command/manual/testing patterns.
- `rumiai-os@03a22d9ce4a7e7501e1fd0462c6eabe99695d0ea` initially introduced the library with a command and manuals, preserving concurrent native-CDP `web-analyze` additions. `rumiai-os@eb8177cc5e57efb4fe40032c6d953d45bcfd28e0` fixed probe targeting and interruption handling.
- Following user correction, `rumiai-os@153866bdb07a24dc3ecbc198018a8ec2f3c304c8` changed entrypoint to exactly URL + analysis directory, added automatic directory creation/unique run dirs, removed the public command and its manual, updated the library manual and CI.
- `rumiai-tests@70a0cc7e1e1c7f43f27d7723ace2a85d400630f8` updated the permanent structural/API/invalid-argument test to reject the unrequested command.
- Post-change Git diff inspection confirmed removal of `bin/sys/web-analyze-pw` and `res/sys/manual/web-analyze-pw` while preserving the library/manual. The current GitHub Actions run for the environment-correction revision is PASS (see current state).

## Current state

**2026-10-19 physical log from user (Ubuntu 26.04 ARM64):** `pkg install playwright` succeeded; `playwright install chromium` downloaded revision `chromium-1243` to the `playwright` package HOME. A direct `node lib/sys/js/web-analyze-pw.lib.js <url> ./analysis-pw` still failed because Playwright looked for `chromium-1243` under the **nodejs** package HOME. `npx playwright install` installed a separate, newer Playwright 1.64.1/Chromium 1248 in nodejs state and did not resolve the version-coupled mismatch.

**Cause and patch:** The Playwright CLI probe correctly discovers the browser cache, but the library applied `PLAYWRIGHT_BROWSERS_PATH` *after* `require('playwright')`. Playwright initializes browser-registry paths at module load time. `rumiai-os@acbb5ddcafcb73ce4e708ab0599da1fab2544729` applies the probed variable **before** loading the matching module; no additional browser installation is needed if Chromium 1243 is present in Playwright's managed state. `rumiai-os@aaa2afe989ef9c619049698fa5ac2d54eb768af4` introduces an actual Playwright/Chromium cache-isolation regression in CI.

**Validation:** GitHub Actions run `39294248928` for `aaa2afe` is **PASS** for syntax/API, Playwright/Chromium download, a real browser launch with the CLI-owned cache deliberately isolated from Node HOME, and a real local scrollable fixture analysis (seven HTML/PNG checkpoints with down/up scroll). The best-effort ChatGPT shared page test also completed but produced only one initial checkpoint with `scroll=0/0`; it does not demonstrate complete conversation capture. Git diff/readback and JavaScript parsing passed; the library manual remains consistent. No assistant-run verification has been performed on the user's physical Ubuntu host **after** the fix, and the native RumiAI package launcher itself was not exercised by the CI (the CI uses upstream Playwright 1.63.0).

## Next action

On the user's existing RumiAI checkout, pull the forward fix and rerun the same two-operand Node invocation without rerunning `npx` or downloading a different browser. Inspect the new `analysis-pw/run-*/summary.json` and event/screenshot evidence. If the physical RumiAI launcher still selects a wrong browser cache, obtain a fresh diagnostic with the probed `PLAYWRIGHT_BROWSERS_PATH` and investigate that specific provider boundary.

## Blockers / open questions

Real Ubuntu 26.04 ARM64 post-fix run of the RumiAI-installed Playwright package is outstanding. GitHub-hosted analysis of the ChatGPT share had no scrolling extent; its page-content completeness remains unverified independently of the browser-cache fix.
