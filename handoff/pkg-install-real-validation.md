# pkg install real validation

Status: Complete
Updated: 2026-09-18

## Goal

Rebuild and validate `pkg install` through the authentic public command and composed package pipeline, retaining only evidence that exercises the real product path.

## Final repository revisions

```text
rumiai-dev   852139296a4aff6d3ebe8244a2d920a64167bcd9
rumiai-os    5e47a3f0a242a57f8431fece2357532c19342cd9
rumiai-tests b180c43c27db969c61476f02eb230fcc60a6806e
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
```

The final handoff commit itself advances `rumiai-dev`; fresh retrieval remains required for any later task.

## Applicable canonical sources

- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Completed outcome

- Target catalog streams use `<package>/<os>-<arch>`; obsolete `catalog-` target prefixes were removed.
- The generic `pkg` dispatcher remains unchanged and command-library entrypoints follow `pkg_<subcommand>`.
- `pkg_default` is the command entrypoint and `pkg_default_apply` is the lower-level binding operation.
- `pkg install` materializes the concrete package, selects it as current/default and creates the public command binding.
- Slashless command resolution no longer gives implicit CWD objects precedence over `PATH`; a root-level `pkg/` directory cannot shadow the `pkg` command.
- Current-package uninstall correctly clears the selector/bindings before deintegration.
- `pkg install` is best-effort per operand:
  - failed operands emit diagnostics and later independently installable operands continue;
  - a partially successful batch returns status `1`;
  - status `2` is reserved for a globally invalid invocation.
- An already-installed concrete is not replaced or reinstalled and reports:
  - `reason="already-installed"`
  - `already-installed="<concrete>"`
  - `current-default="<concrete|empty>"`
- An invalid-only install returns `1` and does not materialize the package store.
- Operational manuals `res/sys/manual/pkg` and `res/sys/manual/pkg-install.lib.sh` reflect the implemented install behavior.
- The reusable isolated-host outbound-network bridge is documented in `TEST-PATTERNS.md`.

## Final validation

### Internet-enabled regression

GitHub Actions run `35329376338` completed successfully against exact:

```text
rumiai-os    5e47a3f0a242a57f8431fece2357532c19342cd9
rumiai-tests b180c43c27db969c61476f02eb230fcc60a6806e
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
```

It passed all permanent `tests/rumiai-os/pkg/*.test` plus the current `pkg-integration/contract.test` and `pkg-launch/contract.test`.

Live jq evidence:

```text
installed=jq@jq-1.8.2!linux-x86_64
catalog-head=dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
jq=jq-1.8.2
```

### Isolated Debian replay

The final product revision was also exercised on the isolated auxiliary host:

```text
Debian GNU/Linux 13
x86_64
rumiai-os    5e47a3f0a242a57f8431fece2357532c19342cd9
rumiai-tests 85dba298afcc4824604ddad66968b44ad1f3a14f
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
jq artifact sha256 b1c22172dd303f3be49e935aa56aa48a8b7a46e0bc838b4997d3bb451495870f
```

The later test-suite delta from `85dba298...` to `b180c43c...` did not modify `install-live.test`; the final Internet-enabled regression above covered the later current suite.

The Debian host used the canonical `TEST-PATTERNS.md` transport-boundary replay:
- real clean product/test checkouts;
- real clean cached `pkg-catalog` checkout with the canonical origin;
- temporary HTTPS server for the captured real GitHub API response and official jq asset;
- temporary `/etc/hosts` mapping and trusted local CA while normal TLS verification remained enabled;
- unchanged public product commands.

Observed results:

```text
INVALID_ONLY=PASS status=1
INSTALL=PASS jq=jq-1.8.2
ALREADY_INSTALLED=PASS status=1
MIXED=PASS status=1 jq=jq-1.8.2
```

The already-installed diagnostic contained the requested installed/current-default identities. The catalog refresh attempted its canonical GitHub remote, received the replay-boundary failure and followed the product's real validated-cache fallback. API and jq artifact requests used their canonical upstream HTTPS paths.

Replay cleanup was verified:
- temporary `/etc/hosts` entries removed;
- temporary CA removed and trust store refreshed;
- no replay HTTPS listener remained;
- transferred product/test checkouts remained clean.

## Final state

The package-install task has no remaining working design, blocker or next action. Durable behavior is in current canonical specifications/manuals, implementation is in `rumiai-os`, and permanent validation is in `rumiai-tests`.
