# Web-control provider split

Status: Active
Updated: 2026-10-10

## Goal

Preserve the proven Playwright/Chrome implementation while establishing independently released alternative browser providers behind the same `web-control` facility contract. Rename the existing `rumiai-web-control` GitHub project and concrete package to `pwc-web-control`, then create a separate `electron-web-control` repository and develop its provider. A possible Firefox-plus-extension provider is an exploratory alternative, not yet an implementation commitment.

## Current repository revisions

- `rumiai-dev`: 8bb2924df929af5031b7bb76926b69e275220fa7 (pre-write; recheck remotely on resume).
- `rumiai-web-control`: 8ed3ab888ecdc4970d90a6f14f0d7b7b93fce122 (pre-rename).
- `rumiai-os`: 382369cfde55b158bdf9bb8c7c7ba352fb00ca5e.
- `pkg-catalog`: 9e1a24277de4f203c9796c50c04d2ad73395b0fa.
- `rumiai-tests`: 345ef3837e3184058453789e78b46344b2a665b9.
- `rumiai-dev-PoCs`: 1c6175959e601d390594400807276f24c7ce21cb.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`
- `specifications/rumiai-os/WEB-CONTROL.md`
- `handoff/README.md`
- Relevant package, command, service, state and test contracts must be reread before implementing their changes.

## Fixed task-local choices

- Concrete Playwright/Chrome provider identity: `pwc-web-control` (user corrected earlier spelling `pwc-webcontrol`).
- New independent Electron provider project: `electron-web-control`.
- Provider-neutral command/service/facility identity remains `web-control`.
- Preserve the current browser provider behavior, Git history and authenticated profile state; do not replace the existing project by a history-discarding copy.
- Electron authentication compatibility must be physically tested, not presumed; preserve manual login/challenge handling and browser sandboxing.

## Acceptance scenarios

1. An existing client can invoke `web-control status`, page operations and `srv start web-control` after selecting the Playwright provider without changing the public command syntax.
2. A developer can identify and install the Playwright project as `pwc-web-control` from the catalog and continue using its persistent default profile.
3. A developer can independently clone `electron-web-control` and develop/test its browser implementation against the same published compatibility-level-1 contract, without affecting the Playwright provider.

## Completed

- Verified original GitHub project and missing destination repository names.
- Confirmed the current canonical contract is provider-independent; no runtime/package/spec renaming has yet occurred.
- Prepared an externally runnable, syntax-checked and mock-tested GitHub CLI administration script for rename followed by repository creation; the script is a session artifact, not committed project source.

## Current state

The connected GitHub tool exposes file/commit changes but **not** repository rename/create administration. Neither GitHub operation has been executed; the old repository and canonical concrete package identity are unchanged. The Electron repository has not been created. No provider runtime was changed.

## Next action

1. Execute the authorized GitHub repository rename/create via an authenticated GitHub CLI/browser administrator (or enable an administrative tool) and verify the two actual remote identities.
2. Reread current repository HEADs and relevant package/catalog/source/test files, then migrate the concrete Playwright package/release/docs and facility mapping forward without disrupting the existing profile.
3. Initialize `electron-web-control` as a separate provider implementation; establish contract conformance and physical behavior tests before considering it usable.

## Blockers / open questions

- Repository administration is unavailable through the connected GitHub operations in this chat. This is the only blocker to the first two repository-admin steps.
