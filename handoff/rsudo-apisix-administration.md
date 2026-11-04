# rsudo APISIX and Keycloak module replacement

Status: Active
Updated: 2026-11-04

## Goal

Replace the incomplete existing rsudo APISIX administration module with a safe, complete shell administration API across APISIX deployment modes, while retaining the previous implementation as explicitly named legacy source. Also preserve the existing Keycloak module under a legacy name and reserve the original module name for its new implementation. Keep both responsibilities separate from rsudo SSH/sudo execution.

## Current repository revisions

- rumiai-dev: a42641f66691e41746ef4c22f9452df74bf3b5df (pre-checkpoint)
- rumiai-os: f68c72e875d6c0d7dedfce22c728a8bffc892fe9 (pre-checkpoint)
- rumiai-tests: c82efe4552447105ca4c1e0b8c6294e897470c3e (pre-checkpoint)
- m-os: 31693e814f682690adfd48185da822f7f5007f9e (historical comparison repository, no edits intended)

Fresh HEAD checks remain required before edits/resumption.

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/CURRENT-MODEL.md
- specifications/rumiai-os/RSUDO.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- specifications/rumiai-os/DIAGNOSTICS.md
- TESTING.md
- handoff/README.md

## Fixed task-local choices

- Rename the existing `lib/sys/sh/rsudo/rsudo-mod-apisix.lib.sh` to `rsudo-mod-apisixlegacy.lib.sh` and existing `rsudo-mod-keycloak.lib.sh` to `rsudo-mod-keycloaklegacy.lib.sh`. New development owns the two original leaf names.
- The new APISIX module uses a single shell library and INTERNAL routing, not alternative provider libraries that override common function names.
- APISIX deployment type must be discovered from authoritative effective remote configuration or a safe, verified management surface before operations. Do not silently guess a mode on failed discovery.
- Offer shell access to the complete supported administration capability, plus concise, low-parameter conveniences for common tasks.
- Do not require JSON files for ordinary use. JSON may remain the internal wire representation and may be supplied via shell input/stdin; files are optional, especially for templates.
- Preserve rsudo's SSH/sudo and credential-group behavior; avoid introducing a second transport or requiring remote m installation.
- Preserve user/concurrent changes and forward-only history.

## Acceptance scenarios

1. Operator with existing rsudo credentials can inspect remote APISIX mode with one shell command, without knowing where its config is installed. A fully qualified override may be offered when automatic evidence is genuinely ambiguous.
2. Operator can list/read route, upstream and service resources consistently on a supported mode; provider-specific details are hidden.
3. Operator can create an ordinary upstream, service and route with a few parameters and no temporary JSON file.
4. A caller can express any supported API operation and complex resource payload directly through arguments/stdin, optionally a template; shell source and JSON data remain separate.
5. On standalone API-driven, changing one resource cannot silently replace unrelated resources or publish stale versions. On file-driven, edits do not truncate a live configuration and do not bypass its required full-document validation.
6. Secrets do not appear in logs, normal output, remote command arguments or insecure temporary artifacts. Unsafe/unknown modes fail closed with an actionable diagnostic.
7. The legacy APISIX and Keycloak modules remain explicitly addressable without shadowing the new modules; the new Keycloak module evolves separately.

## Working design

Upstream documentation reviewed on 2026-11-04:
- https://apisix.apache.org/docs/apisix/deployment-modes/
- https://apisix.apache.org/docs/apisix/admin-api/
- https://apisix.apache.org/docs/apisix/installation-guide/

APISIX has at least three materially different administration backends:
- etcd-backed Admin API on traditional or decoupled control-plane nodes: individual resource REST operations.
- standalone file-driven with `config_provider: yaml` or `json`: full local document `apisix.yaml`/`apisix.json`; YAML requires terminal `#END`; staged atomic publication and concurrency/change detection required.
- standalone API-driven with `role: traditional`, `role_traditional.config_provider: yaml`: `GET/PUT /apisix/admin/configs`, resource-type `*_conf_version`, modifiedIndex and full category replacement. `202` is accepted, not proof all workers applied; version/digest/update and concurrent writers need careful design. Official documentation advises against casually using API-driven mode outside its specialized integrations.

A safe implementation must NOT map a single-resource PUT directly onto /configs or assume every standalone node has an Admin API. Mode detection must consider defaulted/effective configuration and runtime options (including custom -c), not grep one hard-coded config path. Prefer reuse of the APISIX-supplied parsing/runtime facilities where appropriate; exact mechanism and tested supported installation layouts are not yet fixed.

The generic shell interface should separate resource operations and all available API endpoints from shortcuts. Plan to use simple positional shortcuts and arbitrary structured payloads on stdin or shell variables, with no mandatory persistent JSON file. Before implementing the transport, prove it does not expose API key via argv or mix target JSON stdin with remote shell source.

Preserve `rsudo apisixlegacy` and `rsudo keycloaklegacy` dispatcher usability when renaming: rsudo maps a module operation to `rsudo_mod_<module>_<operation>`; merely renaming the file is insufficient if its public function prefix stays unchanged. Collision and manual completeness need explicit treatment.

Open sequencing issue: immediately replacing original module leaves users with a partially implemented public interface unless the new implementation is sufficiently complete or work is isolated behind a non-default integration branch. Do not silently break the current workflows for an incomplete scaffold.

## Completed

- Verified remote HEADs and current relevant rules/specifications, current module source and rsudo dispatcher.
- Compared the historical `m-os@fa3a90d` APISIX source with current rumiai-os: identical functional bodies except loader/logging differences; historical code is reference only.
- Verified three APISIX backend families against current upstream documentation.
- Checked current APISIX/Keycloak module manual topics: absent; documentation and permanent mechanical coverage must be realigned with the product changes.
- Confirmed no separate active APISIX module handoff exists; this task has independently resumable implementation/validation boundaries from the broader AI administrative-tools handoff.

## Current state

Design requirements are fixed; detailed backend discovery, safe authenticated transport, resource mutation algorithms and compatibility migration remain to implement. No product change is yet represented by this checkpoint.

## Next action

1. Inspect current production callers and permanent tests for both rsudo modules, and identify breaking public interface risks.
2. Define/test an effective-config and credential resolution strategy against representative traditional, standalone file-driven and API-driven APISIX instances.
3. Implement a safe APISIX core and internal routing with full modeled behavior and concise convenience operations; preserve the old code as two explicitly addressable legacy libraries.
4. Align Keycloak module transition, required operational manuals and permanent tests, run proportional development validation, and update canonical APISIX contract once the design is promoted.

## Blockers / open questions

- Exact safe mode-discovery and authorized runtime-configuration access mechanism across nonstandard install roots and containers.
- Full-document read/modify/write strategy, concurrency and rollback semantics for file-driven and API-driven backends.
- Retaining current Keycloak CLI usability while the new implementation is independently developed and legacy source is kept.
- Concrete supported APISIX version set and authentication representations must be proved rather than guessed.
