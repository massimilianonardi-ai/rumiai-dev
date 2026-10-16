# web-page-analyze

## Intent

Extract the reusable page-evidence collection developed by PoC 068 into a general deterministic web-page analysis capability, analogous in purpose to `pkg-analyze`: collect broad observable evidence first so later analysis can select the information relevant to its context without guessing the page's representation in advance.

## Why pending

PoC 068 is still using direct shared-page capture to discover the actual ChatGPT share representation. The general capability should be derived only after that evidence-gathering approach has been physically validated and its useful observation surfaces are known.

## Scope

- deterministic web-page evidence collection above the current common `web-control` capability;
- rendered DOM/HTML/text and element/attribute inventories;
- browser/CDP structural evidence where supported by the current `web-control` contract;
- resource, image, document, SVG/canvas/media and accessibility evidence;
- durable diagnostics suitable for later AI or human interpretation;
- keep generic observation separate from site-specific adapters and from RumiAI sense/cognitive interpretation.

## Evidence

- `rumiai-os/bin/sys/pkg-analyze` is the current analogous analyzer pattern: broad deterministic inspection/probing first, interpretation/use later.
- `specifications/rumiai-os/WEB-CONTROL.md` defines the deterministic browser observation/control layer beneath such a capability.
- `specifications/rumiai-os/SENSE-MODEL.md` requires deterministic observation mechanisms to remain distinct from AI/sense interpretation.
- `handoff/chatgpt-shared-link-export.md` and PoC 068 `capture-share-reference.mjs` are the current experimental source of reusable page-observation techniques.
