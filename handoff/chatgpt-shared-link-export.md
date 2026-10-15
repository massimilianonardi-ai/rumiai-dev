# ChatGPT shared-link export

Status: Active
Updated: 2026-10-15

## Goal

Archive user-authorized ChatGPT shared-link conversations completely and readably, including multimedia, without duplicated turns or DOM-window heuristics, using the normal common web-control facility and Node.js.

## Current repository revisions

- rumiai-dev: 4a6bb65b9ada2a291021c934e010509cc993f7db (pre-checkpoint HEAD)
- rumiai-dev-PoCs: 3fc76222582d633cee149de45484d89c530ff779 (page-context shared JSON fetch; no event domains)
- pwc-web-control: 403f4fa9bbea419715e9c834e847c6f2b60ae421 (released v0.1.6)
- electron-web-control: 077eb502f1d68235b4e5c9c28e4a7560795bce17 (released v0.1.6)
- pkg-catalog: 7cd9b7585b9343a153e516c9c47b6fb92b7330e0 (facility web-control 3 and both provider realizations)

## Applicable canonical sources

- README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md, handoff/README.md
- specifications/README.md, specifications/rumiai-os/WEB-CONTROL.md
- specifications/rumiai-os/DIAGNOSTICS.md
- handoff/web-control-debug-sessions.md (separate implementation/release lifecycle)

## Fixed task-local choices

- The original user-provided 33,346-byte macOS Python CDP snapshot exporter remains byte-for-byte unchanged at PoC 068 reference/chatgpt-export-v3.py. Its structural snapshot capture and mapping/current_node active-branch traversal are the reference behaviors.
- User explicitly wants Node.js and the common web-control interface. The active Node entrypoint is export-share.mjs and consumes compatibility-3 web-control debug sessions. It never opens a raw browser debugger TCP port, launches a parallel browser or depends directly on Playwright/Electron internals. The separate Python export-share-cdp.py adapter and legacy DOM-based export.mjs are retained for reference only and are not the accepted entrypoints.
- Never assume the native app:// mergeActiveBranch hook or a complete mapping/current_node object exists on the shared browser page. The user must not be given a fabricated or partial transcript as a complete export.
- Preserve the full message objects, branch identities, technical/non-text parts, and failure diagnostics. Preserve successive immutable exported versions. Do not commit user conversation content or signed asset URLs.
- Multimedia object metadata is NOT image binary data. Real images, SVG/canvas charts and ChatGPT-faithful HTML are separate downstream acceptance requirements, not yet demonstrated by the structured snapshot PoC.

## Acceptance scenarios

1. Starting with only a shared URL and destination directory, the user runs one Node.js command through the installed web-control provider; no internal page IDs, Chrome debug ports, provider-specific commands or Python are needed.
2. On an actually observed valid renderer snapshot, all visible current-branch messages are exported without repetition, with complete raw audit and multimodal references.
3. Each export writes a unique new directory and ZIP, never overwriting previous evidence.
4. On a shared site without a compatible snapshot, the command exits nonzero and preserves a numbered privacy-reduced diagnostic, never reporting successful completeness.
5. Eventually export images, graphic assets and readable HTML where browser-visible; missing media remains explicit, not silently omitted.

## Working design

The active Node adapter uses the compatibility-level-3 web-control session only as a common privileged CDP command transport because the public web-control contract has no general page-eval command. After navigating the shared page and allowing its normal browser/profile state to establish, Runtime.evaluate performs a same-origin fetch for the structured share JSON, first from /backend-anon/share/<id> and then /backend-api/share/<id> as a fallback. The page-context code returns only a structurally valid mapping/current_node snapshot plus privacy-safe source/status attempt metadata. The active path does not enable Network or Debugger event domains, consume debug session events, discover bundle scripts, install breakpoints or monkeypatch page fetch/XHR. Inline application/json remains diagnostic fallback only.

The original Python script used a native app:// renderer and its validated mergeActiveBranch breakpoint remains reference behavior only; it is no longer the active shared-link acquisition mechanism. The failed DOM-based attempts used scrolling and window merging, produced repeated content, missing images/graphics and an immobile page in user physical tests; do not regress to those approaches.

## Completed

- Built legacy PoC 068 with immutable revision capture, JSON/Markdown, styled DOM HTML, attempted remote/data image download; user physical tests rejected its scrolling/duplication and media behavior.
- Preserved the user-supplied original Python macOS CDP exporter unchanged and built a separate experimental standalone-Chromium Python shared-link adapter. CI showed structural tests, NOT real shared-site support.
- Coordinated with the separate web-control debugger session task; published both Chromium provider releases v0.1.6, facility compatibility 3 and common open/send/events/close protocol.
- Converted Python structural capture and export to Node.js in PoC 068: snapshot-acquire.mjs, snapshot-export.mjs and export-share.mjs. Uses only the common web-control CLI/session commands; restores active branch traversal, non-text message objects, raw gzip, Markdown, JSONL, audit, SHA256, and a Node-native DEFLATE ZIP. No Python or shell zip needed for the new entrypoint.
- Tests include mocked provider session network capture and persistent paused frame resume, hook detection and URL validation, immutable artifact output and ZIP decompression, cyclic/gapped mapping failures and multimedia preservation. At exact PoC revision 7df999257366577eec418b4813a35bef57635611, GitHub Actions run 38744593125 passed 28/28 Node tests and 7/7 retained Python reference tests, including Node syntax check. Hosted mocked/fixture results must not be presented as physical ChatGPT URL acceptance.

## Current state

The user's VM initially had electron-web-control v0.1.4 selected. After installing/selecting v0.1.6, a direct physical `web-control debug session open page-1` returned `{"session":"debug-1","page":"page-1"}`, so the compatibility-level-3 persistent debugger path is now physically reachable on that host. An earlier `unknown method: debug.session.open` observation is no longer the active blocker; the exact runtime transition that cleared it was not independently recorded.

The next physical exporter run produced diagnostic 0005 with phase `initial-navigation`, operation `debug session events`, and provider diagnostic `debug.events-overflow: events were discarded; reopen or resynchronize the session`. This establishes that page creation, debugger open and domain enables completed, and that the bounded event stream overflowed during initial navigation before any response body, script hook or JSON shape could be inspected.

PoC revision d192ef3a6315ec68e2a0764d18a04aa872990d28 corrected the consumer side without changing web-control: both initial and breakpoint reload navigation use `Page.navigate` through the existing persistent session with an event reader already active. The reader drains any preexisting backlog, requests the level-3 maximum batch of 128 events, advances only to the last delivered event and starts the next event request before processing the current batch. GitHub Actions run 38774900291 passed for that revision.

The user's physical rerun on d192ef3a6315ec68e2a0764d18a04aa872990d28 produced diagnostic 0006. Overflow still occurred in `initial-navigation` at `debug session events`, but the adapter progressed farther: `inspectedResponses=2` and one privacy-reduced JSON shape with top-level key `integrations` were observed before loss. This proves the pre-navigation drain improved acquisition but did not keep the bounded buffer below its retention threshold under the physical ChatGPT load.

PoC revision a1f1e6c2d98f38651ac141b769844b7550db830a narrowed the event-producing domains by acquisition phase. Initial navigation enabled only `Network`; `Runtime.evaluate` was used without `Runtime.enable`; after initial network/embedded-JSON inspection, `Network` was disabled before `Debugger.enable`. GitHub Actions run 38776369694 passed for that revision.

The user's physical rerun on a1f1e6c2d98f38651ac141b769844b7550db830a produced diagnostic 0007. The failure remained `debug.events-overflow` in `initial-navigation` even with Network as the only enabled event domain; one response was inspected before loss. This isolates the pressure to the Network stream itself and demonstrates that prompt consumer draining cannot guarantee complete delivery for this real ChatGPT load under the current compatibility-level-3 bounded buffer.

The canonical web-control level-3 contract explicitly caps event delivery at 128 entries / 4 MiB and requires callers to treat overflow as explicit loss and reopen or resynchronize rather than infer completeness. Therefore this task does not increase provider buffers or silently change the common contract. PoC revision 73f77dd1be358270ae83d7de4e287adc69f8afd1 recovered from initial Network overflow by reopening the session and continuing without claiming the dropped event sequence was complete. GitHub Actions run 38777035127 passed for that revision.

The user's physical rerun on 73f77dd1be358270ae83d7de4e287adc69f8afd1 produced diagnostic 0008. The initial overflow was successfully contained: the adapter reached embedded-json and then hook-discovery. Embedded JSON exposed only a configuration-shaped object (including authStatus, cluster and marketing flags), not a conversation snapshot. Hook discovery then failed with scriptCount=0 and share.snapshot-hook-unavailable. This showed the remaining blocker was the breakpoint/script-discovery strategy itself, not navigation or the initial overflow.

The user explicitly challenged whether the Debugger domain was needed and proposed injecting JavaScript to collect the required data directly. Revision 4b030f8f971034bc0bd45015c7b8c3f1aab5d474 removed Network.enable, Debugger.enable, debugger event polling, script discovery and breakpoints and instead installed a pre-navigation fetch/XHR observer. GitHub Actions run 38778806571 passed for that revision.

The user's physical rerun on 4b030f8f971034bc0bd45015c7b8c3f1aab5d474 produced diagnostic 0009. No debugger overflow or hook failure occurred; the injected observer simply did not see a complete snapshot. The only inline JSON shape remained the same configuration-shaped object seen in 0008. This established that passively intercepting page fetch/XHR as whole JSON is not the right acquisition point.

Current external implementation evidence from a recently maintained public ChatGPT-share exporter identifies the structured share payload as a direct same-origin request to /backend-anon/share/<id>, with /backend-api/share/<id> as fallback, after the shared page is opened so the browser request context has the required cookies/Cloudflare state. Current PoC revision 3fc76222582d633cee149de45484d89c530ff779 adopts that mechanism through Runtime.evaluate in the already-open web-control page. It returns only a structurally valid snapshot and privacy-safe {source,status,...} attempt metadata, and adds sourceAttempts to failure diagnostics. No provider API or web-control contract changed. The first hosted run on implementation revision 532c63b379e71f02806d229bad260a9249ab94f7 exposed only an over-specified source-text assertion in the new fixture; the forward test-only correction 3fc76222582d633cee149de45484d89c530ff779 removed that incidental assertion. GitHub Actions run 38780482303 then passed syntax and the full PoC fixture/reference job. Physical validation of the page-context direct JSON fetch remains pending.

The exporter still reports imagesDownloaded=0 and observationComplete=false even on a structured capture; reconstructing HTML/assets and live-site acceptance remain open.

## Next action

Fast-forward the user's rumiai-dev-PoCs checkout to revision 3fc76222582d633cee149de45484d89c530ff779 or later and rerun the same physical Node command against the already configured electron-web-control v0.1.6 service.

From PoC 068:
node export-share.mjs https://chatgpt.com/share/<id> ./archive

A successful capture should report method page-fetch and produce the normal structured export. If it fails, inspect the next numbered diagnostic and especially sourceAttempts: HTTP status from backend-anon/backend-api now distinguishes endpoint/access failure from snapshot-shape failure without persisting conversation content. There should still be no Network.enable, Debugger.enable or debug session events. Do not increase the common level-3 buffer, return to DOM scrolling, require a separate Chromium browser or expose a raw CDP port.

## Blockers / open questions

- The user's physical web-control instance/profile and actual shared URL renderer data are not accessible through the assistant's hosted CI environment. Physical functional acceptance remains open.
- Real image binary download and faithful graphic/HTML rendering remain open after data acquisition.
- The provider-install integration formal validation passed on both Linux architectures. Electron macOS ARM64 package job was still queued at the last shared-debugger handoff checkpoint; check its current status before making a universal installed-host claim.
