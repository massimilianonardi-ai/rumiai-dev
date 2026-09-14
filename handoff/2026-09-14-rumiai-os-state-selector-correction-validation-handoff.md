# Handoff — state selector correction validation

Date: 2026-09-14  
Status: implementation and permanent tests aligned; physical validation pending

## Authority

This handoff is non-normative. The current normative correction is:

```text
decisions/rumiai-os/2026-09-14-semantic-state-selectors-and-global-user-binding.md
```

The frozen `2.0.0` checkpoint and its historical validation evidence remain unchanged.

## Work-unit revision inputs

Immediately before this handoff was added, the authoritative decision, product, and test/config revisions for this work unit were:

```text
rumiai-dev   63716aa7634c2248426dac99c58eb028a0afbc20
rumiai-os    9d7b6d23e540abfbb5542d77282df23e51796192
rumiai-tests 77d634fa08c6513414a24990f0ffe152835f903c
```

Relevant implementation/test commits in this forward-only work unit:

```text
rumiai-dev   63716aa7634c2248426dac99c58eb028a0afbc20  Simplify state selectors after 2.0.0
rumiai-os    1a4d76281e8bf1835497bb2c1d30eeab8a6ed8df  Simplify state selector resolution
rumiai-os    5bee446375c89445e1855c2b877a6dd9a7c8a88b  Restore bootstrap newline trimming
rumiai-os    9d7b6d23e540abfbb5542d77282df23e51796192  Align state README with current binding contract
rumiai-tests 74588652a47b8167eb70eeaec15fa4bf64142418  Align state selector tests
rumiai-tests 77d634fa08c6513414a24990f0ffe152835f903c  Configure validation for state selector correction
```

## Current contract exercised

The implemented contract is:

```text
m_STATE_DIR      = $m_ROOT/state
m_STATE_SYS_DIR  = $m_STATE_DIR/system/current
m_STATE_USER_DIR = $m_STATE_DIR/user/current
```

Bootstrap exports these semantic pathnames without resolving or validating selectors and performs no host-id/UID user discovery.

For `state-path user ...`:

```text
state/user/current is a symlink -> preserve state/user/current as the semantic root
otherwise                    -> use state/user/default
```

`state-path` remains a pure resolver. System package `var/<area>` links continue to follow `state/system/current`.

## Verification completed in this work unit

A local execution fixture was reconstructed from exact GitHub blob contents for the relevant current product and permanent-test files. Git blob hashes were checked against the blobs referenced by the remote commit trees before execution.

The following permanent tests from `rumiai-tests@74588652a47b8167eb70eeaec15fa4bf64142418` passed against exact product blobs from `rumiai-os@5bee446375c89445e1855c2b877a6dd9a7c8a88b`:

```text
tests/rumiai-os/bootstrap/semantic-roots.test
tests/rumiai-os/bootstrap/semantic-roots-export.test
tests/rumiai-os/bootstrap/runtime-state-ignore.test
tests/rumiai-os/bootstrap/system-profile-selector.test
tests/rumiai-os/state-path/contract.test
tests/rumiai-os/pkg-launch/contract.test
```

The first execution attempt of the central tests was blocked by Git `safe.directory` ownership on the synthetic checkout. After correcting only that local fixture precondition, the unchanged tests passed.

The exact `pkg-state.lib.sh` blob (`aaddd7320c10bd2c1ff343f8d12589d1272f23a5`) was also exercised with the exact `m`/`state-path` blobs in a targeted isolated gate. The gate verified:

```text
var/conf and var/data target ../../../state/system/current/...
root -> var -> selected system profile state
switching state/system/current changes the state observed through package root links
switching back restores main-profile state
state-path system returns the semantic state/system/current pathname
system var materialization does not populate state/user/default
```

This targeted gate passed.

These checks are proportional mechanical evidence, not a formal validation session. They were executed from a synthetic fixture reconstructed from exact blobs rather than from a clean checkout whose HEAD is the target commit. No validation ref or frozen evidence was created from them.

No GitHub Actions workflow run exists for the relevant `rumiai-os` or `rumiai-tests` commits, so CI cannot substitute for the required physical validation.

## Permanent validation configuration

`rumiai-tests@77d634fa08c6513414a24990f0ffe152835f903c` configures:

```text
rumiai-os-commit	9d7b6d23e540abfbb5542d77282df23e51796192
selection	rumiai-os
```

The full `rumiai-os` group is intentional because the changed permanent tests span bootstrap, `state-path`, package launch, and package state.

## Remaining action

Run the normal launcher from clean checkouts on the reference hosts:

```text
./rumiai-validate
```

Required reference-host evidence remains at least:

```text
macOS ARM64
Ubuntu 26.04 ARM64
```

The launcher must self-update `rumiai-tests`, fast-forward the target, verify clean working trees and the configured exact target commit, execute the configured `rumiai-os` selection, and publish each completed session under its normal `validation/<run-id>` ref.

Do not relabel or modify any `2.0.0` validation evidence. Do not consider this post-2.0.0 correction physically validated until revision-specific sessions for the configured pair have been produced on the required reference hosts.
