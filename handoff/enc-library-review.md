# enc.lib.sh review

Status: Active
Updated: 2026-09-20

## Goal

Review and realign `lib/sys/sh/enc.lib.sh` function by function, preserving intended behavior while correcting concrete defects, POSIX/portability issues, security gaps, tests and operational documentation as the public API is established.

## Current repository revisions

```text
rumiai-dev   128901b65da3b77c41df6240d1aae1e7efc4c010
rumiai-os    6940b3304f8da5b559d0bf91aa37cd5e3ffa2454
rumiai-tests 6a62e876652fa3fc9a9f8e04c50d600407c49232
```

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/README.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
handoff/rumiai-os-man-documentation.md
todo/library-api-visibility-realignment.md
```

## Fixed task-local choices

- Review proceeds function-by-function rather than rewriting the library wholesale.
- `a2o` and `o2a` keep their current byte<->whitespace-separated-octal responsibility and are to be corrected before continuing the encryption helpers.
- `encoded_file_import` is intended to behave like POSIX `.` for pathname resolution: an operand without `/` is searched through `PATH`; decrypted content is executed in the current shell. Use of `eval` is therefore intentional rather than accidental.
- Authentication must still complete successfully before decrypted content is executed by `encoded_file_import`; exact implementation will be reviewed after the primitive helpers.
- For `encode`/`decode`, an unset or empty passphrase variable delegates passphrase acquisition to GnuPG/Pinentry rather than a RumiAI TTY reader; a non-empty supplied passphrase is delivered to GnuPG through fd 3 and never intentionally placed in GnuPG argv or child environment.
- Full `env -i` sanitization is not part of the design: GnuPG/Pinentry legitimately depend on session environment such as HOME/GNUPGHOME and GPG_TTY/TERM/DISPLAY. The supplied passphrase is instead copied into subshell positional state and its source variable is unset before any external process.
- OCB capability selection prefers `--use-ocb-sym`; if absent, `--force-ocb` is used only when independently advertised by `gpg --no-options --dump-options`; otherwise encode fails before consuming plaintext or prompting.

## Working design

- The current private `_enc_password_read` is no longer part of the intended final flow once GnuPG/Pinentry owns interactive passphrase acquisition; removal/realignment will occur with the encode/decode implementation change.
- The exact RumiAI-owned name of the optional supplied-passphrase variable remains to be finalized under the current `m_*` environment-variable namespace rule.
- The GnuPG/OpenPGP construction is mechanically coherent: AES-256, symmetric OCB AEAD, 64 KiB chunks, iterated-and-salted S2K with SHA-256 at count 65011712, no compression, loopback passphrase on a dedicated file descriptor and no symmetric-key cache.
- GnuPG compatibility remains a design point: current `encode` requires `--use-ocb-sym`; older GnuPG releases can support OCB decryption and the legacy `--force-ocb` encryption spelling without exposing `--use-ocb-sym`.
- Current `decode` intentionally streams; authentication failure may occur after plaintext has already been emitted. Consumers requiring authenticated all-or-nothing data must buffer until status 0.
- Full public/internal API classification and the mandatory `enc.lib.sh` operational manual remain to be completed as this library review proceeds.

## Completed

- Current `encode`/`decode` streaming structure and GnuPG option model were reviewed.
- Two concrete octal-helper defects were established: `a2o` could emit `*` because `od` lacked `-v`, and `o2a` split only on newline instead of all POSIX shell whitespace.
- `rumiai-os@a23e81e376bfe28f4f0040ee2b46b9ad42c3c68c` corrects both helpers: `a2o` uses `od -v`; `o2a` tokenizes on space/tab/newline and sets that IFS before joining arguments so behavior is independent of caller IFS.
- `rumiai-tests@db46c6fe980a1433dce6a30d3a272ab66faa79d9` adds executable permanent regression coverage at `tests/rumiai-os/enc/octal.test`.
- Auxiliary Debian 13 x86_64 development checks passed for text and binary round trips, repeated-byte input, NUL and 0xff bytes, mixed POSIX shell whitespace, separate arguments, non-default caller IFS, empty input, and invalid octets with no partial output. Additional exhaustive 0..255 round trips passed under both dash and BusyBox sh. Direct GitHub clone was unavailable in the auxiliary environment because DNS resolution for github.com failed, so this is development evidence rather than formal validation.
- Deep `encode`/`decode` review found the cryptographic/streaming structure sound but identified shell-integration gaps that prevent closure: an exported `ENC_PASS` reaches the external capability probe before it is unset; a pre-exported internal `_enc_password` variable causes the reassigned passphrase to be inherited by the real GPG process; `ENC_PASS` also violates the current RumiAI `m_*` environment-variable namespace rule.
- Current `encode` should document that a runtime failure may leave partial ciphertext already written to stdout, paralleling `decode`'s explicit partial-plaintext warning.
- The current product contains a stale OpenSSL/ENC1/AES-CBC comment block immediately before `_enc_password_read` even though the implementation remains GnuPG/OpenPGP OCB; this is a documentation mismatch to remove in the encode/decode work unit.
- Current `gpg` invocation can be shadowed by a shell function because it is executed as `gpg` after `command -v gpg`; invoking the external dependency through the project-appropriate command form is a hardening candidate.
- Real OCB corruption checks confirmed `decode` returns failure while possibly having emitted one or more authenticated/decrypted chunks already, including full plaintext before a final-tag failure in a near-end corruption case.

## Current state

`a2o` and `o2a` are functionally closed for their intended byte/octal contract and protected by permanent regression coverage; arbitrary binary input is supplied through stdin because shell argument strings cannot contain NUL. `encode`/`decode` are not yet closed: their cryptographic construction is sound, but secret-environment handling, environment-variable naming, compatibility policy, error-output documentation and permanent coverage/manual alignment remain open.

## Next action

Implement the settled encode/decode flow: GnuPG-managed interactive prompting, fd 3 for supplied passphrases, positional-parameter secret storage with source-variable unset before external execution, `--use-ocb-sym` then explicit `--force-ocb` fallback, stale-comment/error-contract realignment and proportional permanent tests; finalize the public `m_*` passphrase variable name in that work unit.

## Blockers / open questions

- Final library manual/public API completion depends on finishing the function-by-function visibility review.
