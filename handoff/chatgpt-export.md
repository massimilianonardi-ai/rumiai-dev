# ChatGPT conversation snapshot exporter — JavaScript and Chromium CDP

Status: Active
Updated: 2026-10-19

## Goal
Maintain the faithful JavaScript port of the supplied Python exporter. The direct invocation now launches Chromium, navigates to a user-supplied HTTP(S) URL through a temporary loopback CDP TCP session, then runs the existing breakpoint/snapshot/forensic export pipeline.

## Current repository revisions
- rumiai-dev: 717d81b928722eb7013de9f26e5ac29aeec3c9ed (before this checkpoint)
- rumiai-os: 5dc11ec8484f9d26b39b69377d1723e30b661288
- rumiai-tests: 15fcc8f6cc2bbefd20e12c6aca2b1772f12f9897

## Applicable canonical sources
README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md, specifications/README.md, specifications/rumiai-os/CURRENT-MODEL.md, FILESYSTEM-NAMING.md, LIBRARY-INTERFACES.md, DOCUMENTATION-MODEL.md, DIAGNOSTICS.md, WEB-CONTROL.md, COMMAND-ENTRYPOINTS.md, handoff/README.md.

## Fixed task-local choices
- Source: rumiai-os/lib/sys/js/chatgpt-export.lib.js. Manual: res/sys/manual/chatgpt-export.lib.js. No new standalone m command.
- Direct invocation: node <path-to-lib> <url> <analisys-dir> (user-selected spelling). Creates the directory and missing parents.
- New exportChatgptUrl(url, analysisDir, options={}) starts PATH-resolved Chromium in a new temporary profile, with --remote-debugging-port=0 and loopback TCP; discovers the browser-selected port, attaches to about:blank, navigates to the URL, waits for page loading, then uses the prior script discovery/breakpoint pipeline. Closes owned browser and deletes temporary profile after success or handled error.
- chatgptExport(host, port, options={}) remains a backward-compatible Electron/CDP library API; exportChatgptSnapshot remains the browser-independent converter.
- Script URL scanning now includes HTTP(S) scripts, but discovery still requires the original mergeActiveBranch function and snapshot argument semantics. No network-response/DOM scraping fallback was introduced.
- No Playwright, Python, TLS-verification bypass or browser-sandbox bypass.

## Acceptance scenarios
1. Running the two-operand direct invocation against an HTTP(S) URL creates the analysis folder, starts Chromium and CDP automatically, and navigates to that URL.
2. If the page offers a compatible applicator and snapshot, the previous breakpoint, capture and RAW/transcript/audit/checksum/ZIP export execute unchanged.
3. Incompatible pages, browser startup and navigation errors produce distinct failures without claiming successful export, and owned resources are cleaned up.
4. The original host/port API remains supported for the Electron client.

## Completed
- Updated the library and manual in rumiai-os, commits 57bc712eac82ba407876c85749d522669af87116, 4d15ce817c33d87385525972089fb11a181eb345, 5dc11ec8484f9d26b39b69377d1723e30b661288.
- Extended permanent contract test in rumiai-tests commit 15fcc8f6cc2bbefd20e12c6aca2b1772f12f9897, for new API, argument errors, executable failure and profile cleanup. The published test itself has not been executed under the official runner in this work unit.
- Node v22 --check passed. Local snapshot-converter smoke test passed for RAW decompression, transcript and ZIP.
- Local invalid URL/directory tests passed. Real Chromium 144 launched and exposed its ephemeral local CDP port. Simulated missing-browser executable failed as expected and removed its temporary profile.
- Real Chromium HTTP fixture and file fixture navigations were both blocked by this environment with net::ERR_BLOCKED_BY_ADMINISTRATOR, so no full successful real-browser export was observed.
- GitHub source byte content matched the locally produced JS at publication; forward-only writes preserved unrelated concurrent work.

## Current state
Library/manual/test updated and committed. Local revised artifact at /mnt/data/chatgpt-export.lib.js. The repository preflight, focused code checks and proportional local tests have been performed, but live ChatGPT share snapshot compatibility is not validated.

## Next action
Run the direct command on a host where Chromium may visit the requested ChatGPT share page. Check whether the share bundle actually exposes mergeActiveBranch and the expected snapshot argument before claiming full export. Run the committed permanent test in the real RumiAI test runner when available.

## Blockers / open questions
Local Chromium is prevented from navigating to test URLs by an administrator policy; live web-share JavaScript/snapshot compatibility is unverified.
