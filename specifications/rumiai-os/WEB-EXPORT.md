# RumiAI OS — Standalone web export

Status: **Current / normative**
Updated: 2026-11-08

`web-export` creates a local, directly openable HTML snapshot of a rendered HTTP(S) page. It consumes the current `web-analyze` browser acquisition and emits no required local server.

## User contract

```text
web-export <http(s)-url> <new-export-directory>
```

The command captures the rendered page after a bounded passive scroll sweep and creates a new private export directory containing `index.html`, `manifest.json` and `assets/`. An existing destination is refused and is never overwritten. The output is opened directly from disk; it does not require a server or network access to render.

The captured DOM is retained as a visual/content snapshot. Only archived, digest- and size-verified visual resource bodies are copied. References are rewritten to local assets. Active CSSOM source may supply a missing CSS HTTP body, but the manifest identifies that provenance and does not call it the original response body. Ambiguous or unavailable resources are omitted and counted rather than associated speculatively.

The generated document has a restrictive no-network content policy. HTTP error/redirect responses, empty non-stylesheet bodies and resources whose saved digest or size does not match their index are rejected and counted. Subresource references outside HTTP(S) are removed except embedded `data:` values and document fragments. Executable site scripts, inline event handlers, frames, embedded objects, refresh navigation, hyperlink ping requests and form submission are removed or disabled. Hyperlinks remain navigation links and can open their original destinations when a reader deliberately follows them. Application behavior that needs JavaScript, a backend/API, authentication, a frame, or other removed state is outside the offline snapshot contract.

When source resource elements carry cross-origin, integrity or referrer-policy metadata, that source-fetch metadata is removed from the rewritten local reference so it cannot prevent the local asset from loading or validate bytes that have changed during CSS rewriting.

The exporter embeds one generated local-interaction script whose SHA-256 content hash is the only script source authorized by the document policy; no script file needs to load. It restores captured non-zero document/nested scroll offsets and preserves safe local controls: copy buttons copy text from their nearby code block, table or conversation article; controls with `aria-expanded` toggle their captured panel when present and always update their local expanded state; and buttons labelled accept/reject/dismiss/close remove a nearby cookie/consent/privacy notice. These handlers run locally and do not invoke the source page's removed event handlers or backend. Native `<details>` controls remain native. A disclosure whose content was not captured cannot be reconstructed; its control remains operable and the manifest counts it as unavailable. The manifest also reports counts of preserved controls and helper presence.

The manifest records the output document and asset digests, source kind for each asset, counts of unavailable/ambiguous references, supported local interactions, and these behavioral limits. The export is private local content and uses restrictive directory/file permissions. Temporary raw browser evidence is not included in the export.

## Deterministic boundary

Given one completed capture and the same exporter revision, resource resolution is based on exact normalized HTTP(S) URLs (query retained, fragment removed for lookup). Non-CSS asset paths use the verified source-body digest; stylesheet paths also include a source-URL disambiguator because rewritten CSS references depend on their base URL. The manifest digest for a stylesheet covers its final rewritten bytes, while `sourceSha256` records the verified pre-rewrite body when those bytes differ. Distinct body digests for the same URL are ambiguous unless one active CSSOM source provides a unique stylesheet body. The export describes that captured state; independently repeated page navigations can produce different DOM, assets, personalized content or lazy-loaded results.

“Standalone” means that opening the exported file requires no local server and triggers no remote subresource loads. It does not mean that every live interaction can be recreated offline or that every requested resource was successfully captured. The manifest is the completeness record.

## Invariants

```text
WEBEXPORT-01  the export opens directly from index.html without a local server
WEBEXPORT-02  rendered-page subresources in the output resolve to local files or inline data
WEBEXPORT-03  output loading is blocked from network access by a restrictive content policy
WEBEXPORT-04  only verified captured resource bodies or identified active CSSOM sources are used
WEBEXPORT-05  ambiguous/unavailable resource references are omitted and counted
WEBEXPORT-06  site scripts, frames and backend-dependent behavior are not claimed as offline functionality
WEBEXPORT-07  export creation never overwrites an existing destination
WEBEXPORT-08  temporary raw capture data and private browser state are excluded from the export
WEBEXPORT-09  each retained HTTP(S) subresource resolves to a local file; embedded data and fragments remain inline
WEBEXPORT-10  non-HTTP(S) subresource schemes cannot make the local export read source-host files or opaque resources
WEBEXPORT-11  only the SHA-256-authorized exporter-generated local-interaction helper may execute; no site script is retained
WEBEXPORT-12  source CORS, integrity and referrer metadata cannot prevent rewritten local resources from loading
WEBEXPORT-13  exporter-generated copy, disclosure-toggle and consent-dismissal controls work without source scripts or network
WEBEXPORT-14  absent disclosure content is reported and never fabricated
```
