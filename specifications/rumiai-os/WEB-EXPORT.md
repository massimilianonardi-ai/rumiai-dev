# RumiAI OS — web-export

Status: **Current / normative**
Updated: 2026-11-08

## 1. Purpose

`web-export <http(s)-url> <new-export-directory>` captures a rendered page using the existing `web-analyze` recorder and writes an HTML export that retains the captured document source and its original browser-side behavior. Its conversion is restricted to relinking references to response bodies that were captured and verified by the recorder.

This contract does not promise that every page can render or behave identically in every browser. It requires the exporter not to manufacture alternate page behavior or discard captured source behavior in an attempt to approximate it.

## 2. Source preservation

The captured final DOM document is the source representation. Preserve its HTML text, element order, content, attributes, inline scripts, external script tags, inline event handlers, form behavior, frames, links, controls, placeholders, SVG/icon markup and other browser behavior. Do not sanitize the page, remove executable content, serialize a replacement DOM, or inject local substitute interaction handlers. In particular, do not synthesize clipboard, disclosure, consent, form or navigation behavior.

The generated `index.html` must not contain exporter-added JavaScript, event handlers, CSP restrictions or network-blocking policy. Script elements and script response bodies are preserved; a captured JavaScript response body may be stored as an asset and referenced locally, but its source bytes are not rewritten. External APIs and remote behavior remain at the captured source URLs.

## 3. Permitted resource transformation

A reference may be rewritten to a local file only when its absolute HTTP(S) URL identifies one unambiguous, integrity-verified body from the capture. The body length and SHA-256 must match the recorder metadata. Do not infer a match from a similar path, origin, filename, query, MIME guess or CSSOM coincidence. Ambiguous, missing, failed or unverifiable bodies retain their original reference and are counted in `manifest.json`.

The HTML and CSS reference readers support ordinary quoted/unquoted URL values, HTML character references in attributes, `srcset` candidates, CSS `url()`, `@import`, and quoted URLs in `image-set()`. They skip CSS comments and unrelated string literals. Unsupported or escaped URL syntax is left unchanged; the manifest must not claim it was localized.

Apply this rule to supported HTML resource attributes, `srcset`, resource `<link>` relations, inline `style` attributes, `<style>` content and captured stylesheet bodies. A link `href` is a resource only for relations such as stylesheet, icon, preload or modulepreload; canonical and ordinary navigation links remain unchanged. CSS `url()`, `@import` and `image-set()` references may change only when their exact URL has a verified body. Preserve comments, ordinary CSS string values and all other CSS text. When a captured stylesheet changes, update its manifest digest and supported source integrity digest to match the emitted bytes. Never rewrite script source. Preserve form actions, iframe URLs and other behavior-bearing references.

An uncollected URL may still require a network when the exported page is opened; the exporter must not describe such an export as guaranteed offline. Browser restrictions on `file://`, source site authentication, remote APIs, CORS and server-side state remain environmental limits and are reported rather than hidden.

## 4. Output and evidence

The destination must be new. Output contains `index.html`, `manifest.json` and `assets/`. Keep output files private. Remove the temporary capture after conversion while leaving the source capture untouched.

The manifest records source origin/path, the index digest and size, verified asset digests/sizes/provenance, original stylesheet digests when CSS URLs changed, ambiguity and rejection counts, preserved script/handler counts and rewritten/unmapped-reference counts. It must not report fabricated local interactions or assert complete offline behavior.

## 5. Acceptance

Permanent tests use a controlled local source page and real Chromium. They verify that source scripts and their bytes, inline handlers, button SVGs, placeholder attributes, links, forms, frames and source interactions survive conversion; only verified resource references change; missing resources remain unchanged; and emitted asset digests match the manifest. At least one existing captured page dump should also be converted without a new source acquisition when such a dump is available. A partial source dump must be reported as partial and cannot support a claim of full-page fidelity.
