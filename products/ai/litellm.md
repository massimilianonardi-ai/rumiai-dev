# LiteLLM

Status: **External product evaluation / non-normative**  
Evaluated: 2026-09-28

## Identity

Product/project: LiteLLM  
Upstream repository: https://github.com/BerriAI/litellm  
License: Upstream repository metadata does not expose a single SPDX license identifier; licensing must be checked at the exact reuse boundary  
Evaluated upstream revision: `6f5ad78a1f019a340ec5d2e6f6d72ff1bf32e6c2`

This record is a revision-specific external-product evaluation. Upstream terminology does not define RumiAI architecture.

## Upstream purpose

LiteLLM is an AI gateway and SDK that normalizes access to a large number of model providers. It exposes OpenAI-format interfaces while adding routing, virtual keys, spend tracking, guardrails, load balancing and observability.

The project can be used as a Python SDK or deployed as a centralized gateway service.

## Mechanisms relevant to RumiAI study

Relevant mechanisms include:

- provider normalization behind a common API;
- translation across multiple model API families;
- centralized routing and load balancing;
- fallback/retry and provider selection;
- usage/cost accounting;
- virtual credentials and quotas;
- guardrail and observability hooks;
- support for model APIs beyond chat, including embeddings, images, audio and other endpoints.

It is a mature example of the difference between an inference engine and a model-access gateway.

## RumiAI evaluation

### Reuse

Potentially useful as an external gateway when broad hosted-provider compatibility is required. For a sovereign/local default it may be unnecessary overhead if the active model surface is small.

### Integration

Strong technical candidate for optional provider aggregation behind a RumiAI-owned boundary. Service deployment avoids coupling RumiAI-owned code to the Python SDK.

### Reference

High for provider-independent API design, routing/fallback semantics, error normalization, credential separation and cost/usage policy.

## Risks and architectural cautions

A "unified API" necessarily loses or abstracts provider-specific capabilities unless escape hatches exist. RumiAI should not let the least-common-denominator shape its internal model semantics.

The evaluated repository metadata did not provide a single SPDX license identifier, so licensing must be verified before concrete reuse rather than inferred from project popularity or prior knowledge.

## Current assessment

LiteLLM is a valuable **model-gateway reference and possible optional integration**. It should be compared with LocalAI: LiteLLM primarily normalizes access/routing across providers, whereas LocalAI additionally addresses local inference backends and hardware.

## Verification notes

This evaluation is based primarily on the upstream repository and current README at the revision recorded above. Runtime behavior, security properties, performance claims and operational characteristics have not been independently validated by RumiAI testing in this work unit.
