# enc.lib.sh review

Status: Active
Updated: 2026-09-20

## Goal

Review and realign `lib/sys/sh/enc.lib.sh` function by function, preserving intended behavior while correcting concrete defects, POSIX/portability issues, security gaps, tests and operational documentation as the public API is established.

## Current repository revisions

```text
rumiai-dev   b963551a7a40f1fb8e92a7cd0bad8d6f4e4f2369
rumiai-os    470f36729cf1ff8b64c4a8534e79b0f82d047258
rumiai-tests f384b9da79b467d8cdb6e26482b5ef350d543af4
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
- Payload stdin remains on fd 0. The previous fd remapping was only required because a shell pipeline uses the right-hand command's fd 0; the intended redesign supplies fd 3 directly through a dedicated redirection, avoiding any payload-stdin shuffle.
- Do not rely on `printf` being a shell builtin for secrecy. POSIX specifies `printf` as a standard utility but does not require builtin implementation, so a passphrase must not be passed as a `printf` argument when the contract forbids argv exposure.
- Full `env -i` sanitization is not part of the design: GnuPG/Pinentry legitimately depend on session environment such as HOME/GNUPGHOME and GPG_TTY/TERM/DISPLAY. The supplied passphrase is instead copied into subshell positional state and its source variable is unset before any external process.
- OCB capability selection prefers `--use-ocb-sym`; if absent, `--force-ocb` is used only when independently advertised by `gpg --no-options --dump-options`; otherwise encode fails before consuming plaintext or prompting.

## Working design

- The optional supplied-passphrase shell variable is now fixed as `m_ENC_PASS`. It is intentionally a shell variable and should not be exported; encode/decode still unset their subshell copy before any external process.
- The GnuPG/OpenPGP construction remains AES-256, symmetric OCB AEAD, 64 KiB chunks, iterated-and-salted S2K with SHA-256 at count 65011712, no compression and no symmetric-key cache.
- Interactive passphrase acquisition is now owned by GnuPG/Pinentry. Supplied-passphrase mode uses fd 3 with a here-document; payload stdin remains fd 0.
- Current `decode` intentionally streams; authentication failure may occur after plaintext has already been emitted. Consumers requiring authenticated all-or-nothing data must buffer until status 0.
- Full public/internal API classification and the mandatory `enc.lib.sh` operational manual remain to be completed as this library review proceeds.
- Proposed `encoded_file_import` design: accept exactly one encrypted-source operand; resolve it through the existing public `core.lib.sh` primitive `pathsearch` instead of duplicating PATH traversal. `pathsearch` already handles explicit pathnames, ordered PATH search, empty PATH components as the current directory, no executable-bit requirement and canonicalized result assignment. Normalize path-resolution failure to import status 1. Buffer the complete `decode` output in shell memory and proceed to `eval` only on decode status 0; then return the evaluated source status. No temporary plaintext file and no `command -v`.
- Because `encoded_file_import` is itself a POSIX shell function, it cannot reproduce the caller's outer positional parameters exactly as dot can; the implementation should avoid exposing its own file operand or plaintext buffer as positional parameters to the imported source. Decrypted input is expected to be valid POSIX shell source text; NUL-bearing binary content is outside this API purpose.

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
- Real fd-routing comparison on Debian 13 x86_64 showed that dash, BusyBox sh and Bash POSIX implement both short here-documents and builtin-printf pipelines with a pipe fd; fd0 remained the payload and fd3 carried the supplied secret. A forced external printf exposed the secret in its argv, while the here-document path exposed it in neither child argv nor child environment. This confirms the here-document as the stronger portable design for the passphrase channel.
- `rumiai-os@b83d4f65233f42ffe452c0543b9b8561f53fec2b` implements the settled encode/decode flow: `m_ENC_PASS`, GnuPG/Pinentry interactive mode, supplied passphrase on fd 3 via here-document, fd0 unchanged, `command gpg` to bypass shell-function shadowing, `--use-ocb-sym` preference with verified `--force-ocb` fallback, removal of `_enc_password_read`, removal of stale OpenSSL/ENC1 commentary and explicit partial-ciphertext documentation for encode.
- The same product work realigns `lib/sys/sh/enc.lib.sh` from executable mode 100755 to the required sourced-library mode 100644.
- `rumiai-tests@f384b9da79b467d8cdb6e26482b5ef350d543af4` adds executable permanent tests `gpg-interface.test` and `gpg-roundtrip.test`: the first protects fd3 routing, argv/environment secret exclusion, shell-function shadow resistance, interactive/unattended option separation and OCB option preference/fallback at the external GPG boundary; the second protects real GnuPG OCB round-trip behavior, wrong-passphrase failure, newline-passphrase rejection and argument statuses when a suitable GnuPG is available.
- Auxiliary Debian 13 x86_64 execution of the exact candidate encode/decode logic passed real GnuPG 2.4.7 OCB round trips under dash, BusyBox sh and Bash POSIX using the `--force-ocb` fallback and a passphrase containing spaces and shell metacharacters. Supplied-passphrase fd3 behavior also passed against an external-boundary probe under all three shells. Automated real Pinentry interaction was attempted through a pseudo-TTY but did not complete reliably in the auxiliary environment, so real interactive GnuPG/Pinentry behavior remains unvalidated there.

## Current state

`a2o` and `o2a` are functionally closed for their intended byte/octal contract. `encode`/`decode` are now implementation-complete for the settled streaming and passphrase-routing design and have permanent interface plus real-GnuPG coverage. Remaining closure items are real interactive Pinentry validation on applicable hosts and the library-wide public API/manual completion.

## Next action

Continue with `encoded_file_import`: implement POSIX-dot-style PATH lookup, require successful complete decode before eval, preserve current-shell execution semantics, then add proportional permanent coverage. After the remaining public functions are reviewed, create the mandatory `res/sys/manual/enc.lib.sh` topic and complete library-wide validation.

## Blockers / open questions

- Final library manual/public API completion depends on finishing the function-by-function visibility review.
