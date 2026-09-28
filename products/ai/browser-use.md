# Browser Use

Status: **External product evaluation / non-normative**  
Evaluated: 2026-09-28

## Identity

Product/project: Browser Use  
Upstream repository: https://github.com/browser-use/browser-use  
License: MIT, as declared upstream  
Evaluated upstream revision: `4cbe921673b48a488f5415d9159249afd12a625b`

This record is a revision-specific external-product evaluation. Upstream terminology does not define RumiAI architecture.

## Upstream purpose

Browser Use provides an open-source browser agent plus CLI and hosted browser/agent services. The local library can drive a local or cloud browser with a selected model, while the CLI can expose browser capability to an existing coding/agent environment.

The project therefore spans both an agent implementation and a browser interaction harness/infrastructure boundary.

## Mechanisms relevant to RumiAI study

Relevant mechanisms include:

- browser state perception and action loops;
- reuse of an existing user's browser from an external agent;
- local versus hosted browser separation;
- browser profiles/session continuity;
- structured output and custom tools;
- model-specific optimization for browser interaction;
- a distinct browser harness that can be consumed by other agents.

The most interesting architectural question is how much browser-specific abstraction should exist between a capable model and the real browser.

## RumiAI evaluation

### Reuse

Useful for experiments and potentially for an external browser capability. Reusing the library would currently bring Python into the external dependency path, which is acceptable under RumiAI rules but should remain replaceable.

### Integration

Plausible behind a browser/computer-use provider boundary if RumiAI later defines one. Local-browser operation is particularly relevant.

### Reference

High for studying the evolving boundary between general model reasoning and specialized browser affordances, including when abstractions help and when they constrain increasingly capable models.

## Risks and architectural cautions

Browser automation handles credentials, authenticated sessions, downloads, untrusted web content and potentially irreversible actions. Permission, confirmation, data-exfiltration and prompt-injection boundaries are therefore central.

Hosted stealth/CAPTCHA/proxy features are product-specific and should not shape a general RumiAI browser contract.

## Current assessment

Browser Use is a strong **computer-use/browser reference and experimentation target**. The architectural value lies in its harness and local/cloud separation rather than adopting its complete agent stack.

## Verification notes

This evaluation is based primarily on the upstream repository and current README at the revision recorded above. Runtime behavior, security properties, performance claims and operational characteristics have not been independently validated by RumiAI testing in this work unit.
