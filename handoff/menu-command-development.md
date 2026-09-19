# menu command development

Status: Complete
Updated: 2026-09-19

## Goal

Implement the public `menu` command on top of `menu.lib.sh`, covering command-line lists and filesystem browsing, subtree confinement, configurable action keys and configurable multi-selection, while evolving `menu.lib.sh` only through reusable capabilities.

## Current repository revisions

```text
rumiai-dev   c46b6281b0dc39468ad99f098ce6fc66c7fc68df
rumiai-os    1f4a4a8b62ed41042e4178b11f74f54ad291aadb
rumiai-tests 9960eafb4d803211620f2975ffaef703c3fb8625
```

The formal validation used `rumiai-tests` revision `6a493062f315952c8fd63502ce4521b3e5ae5e98`. The final `rumiai-tests` revision above differs from that validated revision only by removal of the temporary GitHub Actions bridge workflow; the permanent menu tests and `validation/menu.conf` are unchanged.

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`
- `specifications/README.md`
- `specifications/rumiai-os/MENU.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

All durable menu semantics have been promoted to `specifications/rumiai-os/MENU.md`. No unpromoted working design remains.

## Completed

- Added the canonical `MENU.md` contract and routed it from `specifications/README.md`.
- Added bootstrap-integrated `bin/sys/menu` with explicit-list and filesystem input modes.
- Evolved `menu.lib.sh` with reusable multi-selection, configurable reserved toggle key, structured multi-value results and provider reload/reset selection semantics.
- Realigned every touched internal `menu.lib.sh` helper to the leading-underscore visibility convention.
- Added required operational manuals for `menu` and `menu.lib.sh`.
- Added permanent `rumiai-tests` coverage for command/library contract, list selection, configurable toggle/action keys, provider-order multi-selection, filesystem browsing, hidden filtering, mixed sorting, subtree confinement and Escape cancellation/TTY restoration.
- Added task validation scope `validation/menu.conf`.
- Removed superseded `###___menu-ext`, `###___menu-ext-adv`, `###___menu-ext-adv-fs`, `menu-ext.lib.sh` and their legacy operational manuals after confirming there were no remaining consumers.
- Used the documented outbound-network bridge pattern: GitHub Actions captured exact Git checkouts with manifests/digests, artifacts were transferred to the isolated Debian auxiliary host, and execution used those real checkouts.
- Final development run against `rumiai-os` `1f4a4a8b62ed41042e4178b11f74f54ad291aadb` and `rumiai-tests` `6a493062f315952c8fd63502ce4521b3e5ae5e98`: 2 PASS, 0 FAIL, 0 SKIP, 0 ERROR.
- Formal `rumiai-validate menu` on Linux/x86_64 against the same exact revisions: 2 PASS, 0 FAIL, 0 SKIP, 0 ERROR; validation environment audit CLEAN; scope result VALIDATED.
- Temporary bridge workflows were removed from the current repository trees after validation.
- Final consistency review confirmed no `menu-ext*` artifact remains, `menu` exposes no command-local `-h/--help`, command/library manuals exist, and public/internal `menu.lib.sh` naming matches the current contract.

## Current state

The menu work unit is complete. Current product state is `rumiai-os` `1f4a4a8b62ed41042e4178b11f74f54ad291aadb`; current permanent-test state is `rumiai-tests` `9960eafb4d803211620f2975ffaef703c3fb8625`.

The formal validation evidence was produced by the real `rumiai-validate` launcher in the isolated Debian auxiliary host. Because that host has no outbound GitHub network access, Git operations used process-local `insteadOf` mappings to exact local mirrors transferred through the documented bridge; evidence publication therefore succeeded to the local redirected mirror rather than to GitHub. No physical-host validation was performed or required for this task.

## Next action

None.

## Blockers / open questions

None.
