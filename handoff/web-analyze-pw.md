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

- rumiai-dev: 3415282226aee77cbfa5daf87927014c05d534cf (pre-checkpoint HEAD)
- rumiai-os: 153866bdb07a24dc3ecbc198018a8ec2f3c304c8
- rumiai-tests: 70a0cc7e1e1c7f43f27d7723ace2a85d400630f8
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
- Post-change Git diff inspection confirmed removal of `bin/sys/web-analyze-pw` and `res/sys/manual/web-analyze-pw` while preserving the library/manual. Code was parsed successfully with the isolated V8 JavaScript evaluator. GitHub Actions workflow has been created for real Chromium fixture and supplied ChatGPT URL, but its run is still queued.

## Current state

Source and permanent test changes are published. Mechanical structural/diff and isolated JavaScript parse checks were performed; no successful composed `nodejs + m-managed playwright + Chromium` run has been observed. GitHub Actions is queued, not PASS evidence. No actual captured result from the provided ChatGPT URL is available.

## Next action

Run the current library through the exact two-operand `nodejs` invocation on a real host with `playwright` available on PATH, inspect the generated logs/captures, then correct any runtime integration issues forward. Check the queued GitHub Actions build and report only actual completed evidence.

## Blockers / open questions

The assistant's local runtime does not provide the user-installed `m` Playwright/Chromium environment; external GitHub Actions work is queued. Real Ubuntu 26.04 ARM64 validation of this NEW library is outstanding.
