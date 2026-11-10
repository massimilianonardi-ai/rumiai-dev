# m-os — operator-privileged host and remote validation

## Intent

At a later operator-authorized stage, validate the `m-os` and independently released `m-rsudo` behaviors that **require the operator's elevated rights, privileged credentials or administration of protected host resources**. This is a separately deferred task, not part of the current nonprivileged `m-os` completion/acceptance plan.

## Why pending

The operator explicitly reserved all work requiring their privileged rights for later. No assistant or autonomous agent may infer authority, solicit/use existing privileged secrets, modify protected host service registrations, change real host CA trust, or operate remote sudo targets as a side effect of the active plan. The current plan must remain executable and closable for its **nonprivileged accepted scope**, while these independently required validations remain clearly untested rather than claimed PASS.

## Scope

- Actual authorized remote SSH/sudo and privileged `rsudo`/`rssh`/`rsudo-admin` operations, including real remote source injection and interactive privilege paths (former active R2). Ordinary local parsing, source injection in a child shell, menu UI and negative behaviors not requiring privileged access remain active.
- Positive or destructive `srv host system` registration, start/restart/stop/removal, system accounts, and other system-level systemd/launchd administration on operator-managed hosts. Unprivileged `srv` and `srv host user` tests on disposable controlled accounts remain active.
- Real system-level CA trust approval/removal or protected browser/NSS/host-profile manipulation that requires the operator's administrative privileges. Disposable test-owned CA and browser/NSS projections that need no operator privilege remain active.
- Public installation acceptance for the Chrome for Testing Linux ARM64 package when it materializes the catalog-declared `setuid_root` sandbox executable. Exact/latest metadata and artifact resolution are separately validated without privilege; completing the real install requires root ownership/mode changes. A local attempt was rejected by `sudo` before authorization or host changes. Do not rerun its install workflow until this privileged validation is explicitly reactivated.
- Only the **privileged portions** of eventual physical/reference-host checks or deployment. Unprivileged real public-command validation on supported reference hosts remains subject to normal access and `PHYSICAL-TESTING.md`; it is not automatically postponed simply because it uses a reference host.

Reactivate only through explicit operator authorization and the normal TODO-to-active-handoff transition. At activation, select specific controlled targets/accounts, least privilege, secret handling, isolation and cleanup with the owning subsystems. This TODO does not authorize work or prescribe new product interfaces.

## Evidence

- `specifications/rumiai-os/{RSUDO,SSH,SERVICE-LIFECYCLE,TLS-TRUST}.md` and `PHYSICAL-TESTING.md` contain the relevant public contracts and host/authority requirements.
- `handoff/{m-os-completion-orchestration,m-autonomous-validation,rumiai-os-source-composition}.md` retain the active **nonprivileged** implementation, CI and acceptance scope; exact older local/hosted observations remain evidence only for their recorded revisions.
