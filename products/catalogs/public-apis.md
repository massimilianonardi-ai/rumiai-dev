# Public APIs

Status: **External discovery catalog evaluation / non-normative**
Evaluated: 2026-11-02

## Identity and role

- Upstream: https://github.com/public-apis/public-apis
- Evaluated default branch: `master`, revision `2676ca49d557ef14a0f478311506dae947639028`
- License: MIT for the repository/list; linked API providers retain their own terms.
- Type: community-maintained catalogue of public APIs, with a section for agent-consumable MCP servers; **not an API gateway, unified runtime, or guarantee that entries are free**.

The upstream README categorizes API entries by domain (such as authentication, data, productivity, science and development). Ordinary rows give a short description and coarse Auth / HTTPS / CORS indicators. A separate MCP Servers section reports transport and installation links. The README prominently promotes the APILayer commercial suite; promotion and listed availability are not independent endorsements.

## RumiAI relevance

- Discovery of **specialized external service APIs** when a deterministic site/service adapter is better than browser automation.
- Discovery of potentially agent-usable MCP surfaces; each provider must be assessed individually for permissions, transport, data disclosure and response contracts.
- Broad reference index for identifying alternatives when an operation does not require a full graphical browser or Web agent.
- No direct runtime reuse or general RumiAI architecture implication. In particular, a public list does not define an approved set of tools, connectors, privileges or facility providers.

## Risks and verification boundary

A catalog row does not prove: endpoint uptime, current price/free tier, rate limits, permitted use, privacy/security, geographic availability, schema stability, license compatibility, OAuth/data scopes or SLA. Auth/HTTPS/CORS fields are discovery metadata, not an executable test result. This work did not contact or test individual APIs.

## Assessment

Medium-to-high **discovery/reference** value across domains, low direct integration value for the catalog itself. Assess the particular selected service before assigning it any RumiAI role.
