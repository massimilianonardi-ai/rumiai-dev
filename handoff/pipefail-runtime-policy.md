# Pipefail runtime policy

Status: Active
Updated: 2026-09-29

## Goal

Adopt POSIX.1-2024 `pipefail` deliberately across RumiAI shell code without
turning it into an unsafe mechanical global switch.

The active strategy is staged:

1. make pipeline-failure reasoning a project-wide shell-development rule;
2. use pipefail or an equivalent explicit structure now where correctness
   requires upstream pipeline failure to be visible;
3. harden pipelines whose successful early-closing consumers can create
   upstream SIGPIPE under pipefail;
4. preserve explicit exceptions where the rightmost stage is contractually
   authoritative or where buffering/staging provides stronger semantics;
5. validate the resulting product broadly;
6. only after that validation promote pipefail into the normal `m` bootstrap
   runtime policy and separately establish the policy for generated/injected
   shell programs.

No TODO represents this work. It is active now.

## Current repository revisions

```text
rumiai-dev    022b37697ba6c8fbeb39e9f58d1df214d76a36ca  (pre-checkpoint HEAD)
rumiai-os     62a91eb3c18ebcd2595fe646b2f14170eea74126
rumiai-tests  71b6523b93d64a48e45f3f713306f6d59fb2f401
```

These revisions are resumption markers only. Fresh HEAD retrieval remains
mandatory.

## Applicable canonical sources

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/RSUDO.md
specifications/rumiai-os/SSH.md
```

## Fixed task-local choices

- POSIX.1-2024 / Issue 8 remains the platform baseline; pipefail is a legitimate
  baseline shell feature.
- Do not enable pipefail globally in the root `m` bootstrap yet.
- During the staged phase, every newly written or modified shell pipeline must
  explicitly account for failure of all pipeline stages.
- Where failure of an earlier stage matters and the surrounding shell has not
  already established pipefail, use a safely capability-probed pipefail scope or
  an equivalent explicit status-preserving structure.
- Do not use pipefail mechanically where a successful consumer is intentionally
  allowed to stop reading early or where a current contract deliberately makes
  the rightmost command status authoritative.
- Do not remove buffering, staging, rollback, sequencing or newline-preservation
  mechanisms merely because pipefail is available.
- The non-interactive rsudo stdin-to-`ssh_auth` transport must continue to
  propagate the SSH/remote result rather than a feeder SIGPIPE.
- No public/exported `m_PIPEFAIL` variable is introduced.
- Standalone `#!/bin/sh` utilities remain a separate boundary.
- Generated `loadlib_inject_stream` programs remain a separate shell boundary;
  their eventual policy must be established explicitly rather than assumed from
  the local `m` bootstrap.

## Current implementation target list

### Priority A — correctness depends materially on upstream failure visibility

`lib/sys/sh/enc.lib.sh`
: **Local adoption complete; focused validation pending.** The
  `decode | vsed | encode` edit path now establishes pipefail in a private
  capability-checked subshell and refuses the edit if that capability is not
  available. Existing atomic temp/checksum/rename behavior remains mandatory.

`lib/sys/sh/pkg/pkg-extract.lib.sh`
: The `cpio -it | awk` validator already establishes local pipefail. Permanent
  focused coverage now requires producer failure to be observed even after cpio
  emits syntactically valid paths. Focused validation is pending.

`lib/sys/sh/rsudo/rsudo-mod-fs.lib.sh`
: **Local adoption complete and validated.** get/put preserve producer and
  consumer status explicitly through private FIFO streaming rather than
  depending on host-shell pipefail. Staging/promotion/rollback and cleanup
  remain mandatory; du/df producer status is observed before finite parsing.

`bin/sys/manual`
: **Local adoption complete; focused validation pending.** Discovery/search and
  ambiguity candidate production now completes and has its status checked before
  sorting. No pipefail dependency is required for this finite enumeration.

`bin/sys/testlab`
: **Local adoption complete; focused validation pending.** Scenario/context
  enumeration now completes and is status-checked before sorting, preserving
  compatibility with shells that do not provide pipefail.

`lib/sys/sh/pkg/pkg-provider.lib.sh`
: **Local adoption complete; focused validation pending.** Global environment
  file enumeration now completes and is status-checked before sorting. The
  earlier local pipefail dependency for this finite enumeration was removed.

`bin/sys/srv`
: Host/account discovery pipelines such as `getent | awk`, `dscl | sed` and
  `ls | awk` should not treat a parser success as proof that the producer
  succeeded.

`lib/sys/sh/term.lib.sh`
: terminal capability/byte conversion pipelines such as
  `tput | od | tr` and `dd | od` should surface failures in any required
  stage.

### Priority B — useful but lower-risk parsing/transform pipelines

`bin/sys/digest`
`bin/sys/gitman`
`bin/sys/http-fetch`
`bin/sys/menu`
`bin/sys/pkg-analyze`
`bin/sys/rsudo-admin`
`lib/sys/sh/env.lib.sh`
`lib/sys/sh/menu.lib.sh`
`lib/sys/sh/rand.lib.sh`
`lib/sys/sh/pkg/pkg-download.lib.sh`
`lib/sys/sh/pkg/repository/pkg-repository-apache-maven.lib.sh`
`lib/sys/sh/pkg/repository/pkg-repository-artifact.lib.sh`
`lib/sys/sh/pkg/repository/pkg-repository-chrome.lib.sh`
`lib/sys/sh/pkg/repository/pkg-repository-geoserver.lib.sh`
`lib/sys/sh/pkg/repository/pkg-repository-github.lib.sh`
`lib/sys/sh/pkg/repository/pkg-repository-gpgtools.lib.sh`
`lib/sys/sh/pkg/repository/pkg-repository-graalvm.lib.sh`
`lib/sys/sh/pkg/repository/pkg-repository-podman.lib.sh`
`lib/sys/sh/pkg/repository/pkg-repository-temurin.lib.sh`
`lib/sys/sh/rsudo/rsudo-mod-apisix.lib.sh`
`lib/sys/sh/rsudo/rsudo-mod-keycloak.lib.sh`

These require case-by-case review. Many are finite `printf | parser`
transformations whose producer is already-complete in-memory data, so explicit
local pipefail may add little value. Do not add it merely for syntactic
uniformity.

### Hardening required before pipefail at the affected scope

`lib/sys/sh/enc.lib.sh`
: Replace successful `grep -q` early-close behavior in GPG option detection
  with a draining check.

`lib/sys/sh/menu.lib.sh`
: `_menu_safe_item_text` should preserve first-record output semantics while
  draining remaining input rather than exiting successfully early.

Other successful early-exit consumers should be reviewed during each target
change. Early exit used to report validation failure is not the same hazard.

### Explicit exception / preserve rightmost-stage authority

`lib/sys/sh/rsudo/rsudo.lib.sh`
: The non-interactive feeder pipeline into `ssh_auth` must preserve the
  SSH/remote status as authoritative. A remote target may succeed without
  consuming all stdin, which can legitimately give the local feeder SIGPIPE.

Any local pipefail suppression for this path must be narrowly scoped and itself
safe on an older shell that does not recognize the option.

The interactive password-daemon transport and any other SSH stream pipeline
must be reviewed under the same status-authority principle rather than
mechanically inheriting a rule.

### Stronger mechanisms that must remain

`lib/sys/sh/rsudo/rsudo-mod-exec.lib.sh`
: Complete-source buffering before recursive rsudo protects RSUDO-23 and must
  remain even when pipefail is available.

`lib/sys/sh/enc.lib.sh`
: temp-file creation, checksum recheck and rename protect atomicity/races.

`lib/sys/sh/rsudo/rsudo-mod-fs.lib.sh`
: staging, promotion and rollback protect destination integrity.

Sentinel suffix patterns used to preserve trailing-newline/empty-output behavior
inside command substitution are not pipefail workarounds.

## Working design

During the staged phase, avoid creating a new shared public pipefail API merely
to reduce repetition. First implement and validate the small number of scopes
that materially require all-stage status.

A local scope should use the safe capability pattern conceptually:

```sh
if (set -o pipefail) 2>/dev/null
then
  set -o pipefail
  ...
else
  ...
fi
```

The exact unsupported-shell behavior is part of each local correctness review.
A path that can remain correct without pipefail may degrade; a path whose
correctness fundamentally depends on all-stage status may need an explicit
non-pipeline fallback rather than silently accepting weaker semantics.

After local adoption and broad validation, promote the final runtime contract:

```text
m bootstrap
    safe capability probe
    enable pipefail when supported
    explicit degraded-mode warning otherwise

loadlib_inject_stream output
    independent generated preamble establishing equivalent policy

standalone utilities
    separate review / no implicit inheritance
```

The global bootstrap change is deliberately the final adoption stage, not the
first experiment.

## Plan of action

1. Add the project-wide shell-development rule requiring explicit pipeline
   failure-semantics review.
2. Split pipefail ownership out of `handoff/rsudo-injection-menu.md` into this
   handoff so there is one active owner.
3. Add permanent focused tests for local pipefail semantics before product
   changes, including upstream failure propagation and SIGPIPE/early-consumer
   cases where relevant.
4. Implement Priority A targets incrementally, smallest/riskest semantic units
   first:
   - harden early-success consumers;
   - add local pipefail/status-preserving behavior;
   - preserve all stronger staging/sequencing contracts.
5. Add/extend regression tests for rsudo rightmost-status authority, especially
   remote success with unread stdin.
6. Run focused validation on canonical Linux and macOS after each cluster.
7. Review Priority B pipelines and change only those where all-stage status adds
   a real correctness guarantee.
8. Run broader product validation with the staged local policy in place.
9. Promote the settled runtime policy into
   `POSIX-PORTABILITY-LAYER.md`, `BOOTSTRAP-ENVIRONMENT.md`,
   `LIBRARY-INTERFACES.md` and RSUDO/SSH contracts where applicable.
10. Enable pipefail in root `m` with graceful capability degradation and add
    the independent generated-stream preamble.
11. Re-run focused, broad, diversity and physical validation as required.
12. Only after the global invariant is proven, review whether any status-only
    workarounds are worth simplifying.

## Completed

- Previous exhaustive current-tree pipeline audit completed.
- Status-only vs stronger behavioral workaround classification completed.
- SIGPIPE hazard from successful early-closing consumers identified.
- rsudo rightmost-status exception identified.
- This workstream activated directly without a TODO.
- Project-wide pipeline failure-semantics rule added to `RULES.md`.
- Pipefail task state removed from `handoff/rsudo-injection-menu.md`; this file
  is now the sole active owner of the pipefail workstream.
- Concurrent rsudo permanent-test updates through
  `rumiai-tests@c076980f20e496cdc740b03ff82ed276fcd49325` were reconciled;
  current contract/fs coverage remains compatible with this plan.
- A concurrent product advance to
  `rumiai-os@249c91cad0e3dd8d5ecb4af712fd4db78b8c6ab9` changed only rsudo
  operational manuals; no audited shell implementation or pipeline target
  changed.
- A later test advance to
  `rumiai-tests@6fe262459033327a14065ebf50dd0382affe4d50` changed only
  `tests/rumiai-os/rsudo/auth-check.test`; it does not alter the pipeline
  targets or planned pipefail coverage.
- Linux rsudo validation exposed that requiring `set -o pipefail` in
  `rsudo-mod-fs.lib.sh` aborts on Ubuntu dash.
- `rsudo-mod-fs.lib.sh` now uses an explicit private-FIFO producer/consumer
  topology for tar transfers and captures both statuses without depending on
  pipefail. du/df producer status is observed before parsing. This preserves the
  stronger streaming/staging/rollback contract and resolves the rsudo-fs
  portability blocker.
- Permanent rsudo-fs coverage now includes an independently successful consumer
  paired with a forced local producer failure.
- The private FIFO/producer lifecycle now has completion and handled-termination
  cleanup; permanent fs coverage also checks that invocation-owned stream
  resources do not remain after the scenario.
- Concurrent cleanup removed the obsolete `lib/sys/sh/host-id.lib.sh`; its
  stale Priority A and early-consumer-hardening entries were removed from the
  current implementation target list.
- `enc.lib.sh` now establishes pipefail only inside the encoded-edit pipeline
  subshell; unsupported shells reject that sensitive edit path instead of
  accepting weaker failure propagation.
- Added `tests/rumiai-os/pkg-extract/pipeline-status.test`, covering a cpio
  producer that emits a valid path and then fails.
- `manual`, `testlab` and `pkg-provider` finite enumeration pipelines were
  refactored to complete/check production before sorting, avoiding both masked
  producer status and unnecessary pipefail dependence.
- No hosted workflow automatically executed for these new commits; their focused
  validation remains pending and must not be inferred from prior sessions.
- A concurrent product advance to
  `rumiai-os@62a91eb3c18ebcd2595fe646b2f14170eea74126` added only
  `res/sys/manual/rssh`; it does not alter any pipefail target or this
  checkpoint's implementation.
- Dedicated Linux/aarch64 `rsudo` validation passed all six tests against
  `rumiai-tests@348a6441991fbd655d7f1559ff64151f808938ca` and
  `rumiai-os@34c158e95bf5f73525cf42653026431b0c5d5551`, with zero failures,
  skips or errors, a CLEAN validation environment and
  `Scope result: VALIDATED` (session
  `20260929T164234+0200-38746`).

## Current state

The task remains active in staged-adoption mode. Product work has begun on
selected Priority A/related targets through concurrent forward commits.

The rsudo-fs local-adoption unit is complete: its required all-stage transfer
status is preserved explicitly without host pipefail support, permanent coverage
protects producer/consumer failure and cleanup semantics, and the complete rsudo
scope has passed dedicated Linux/aarch64 validation.

The enc/manual/testlab/pkg-provider changes and the new pkg-extract focused test
are committed but have not yet received a new formal validation session. Term
already has dedicated pipeline-status coverage in the current suite; srv remains
the main unresolved Priority A implementation target.

Global bootstrap enablement remains intentionally deferred until the remaining
local targets and broader host coverage are complete.

## Next action

Run focused validation for enc, pkg-extract, manual, testlab, pkg/provider and
term against the current revisions. Then continue the remaining Priority A
review with srv and the explicit rsudo rightmost-status regression before
considering bootstrap promotion.

## Blockers / open questions

No architectural blocker.

The exact common shape, if any, for repeating the safe local capability probe is
not yet fixed. Do not invent a public helper before repetition and test evidence
justify one.
