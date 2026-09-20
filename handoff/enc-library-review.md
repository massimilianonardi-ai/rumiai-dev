# enc.lib.sh review

Status: Active
Updated: 2026-09-20

## Goal

Review and realign `lib/sys/sh/enc.lib.sh` function by function, preserving intended behavior while correcting concrete defects, POSIX/portability issues, security gaps, tests and operational documentation as the public API is established.

## Current repository revisions

```text
rumiai-dev   de144b287b7aecebcc7880e17f89858596903340
rumiai-os    a23e81e376bfe28f4f0040ee2b46b9ad42c3c68c
rumiai-tests db46c6fe980a1433dce6a30d3a272ab66faa79d9
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

## Working design

- Interactive password acquisition for `encode`/`decode` is under review. A previously used private `_enc_password_read` implementation has been supplied by the user; the current tree also has public terminal primitive `term_read_secret`.
- Full public/internal API classification and the mandatory `enc.lib.sh` operational manual remain to be completed as this library review proceeds.

## Completed

- Current `encode`/`decode` streaming structure and GnuPG option model were reviewed.
- Two concrete octal-helper defects were established: `a2o` could emit `*` because `od` lacked `-v`, and `o2a` split only on newline instead of all POSIX shell whitespace.
- `rumiai-os@a23e81e376bfe28f4f0040ee2b46b9ad42c3c68c` corrects both helpers: `a2o` uses `od -v`; `o2a` tokenizes on space/tab/newline and sets that IFS before joining arguments so behavior is independent of caller IFS.
- `rumiai-tests@db46c6fe980a1433dce6a30d3a272ab66faa79d9` adds executable permanent regression coverage at `tests/rumiai-os/enc/octal.test`.
- Auxiliary Debian 13 x86_64 development checks passed for text and binary round trips, repeated-byte input, NUL and 0xff bytes, mixed POSIX shell whitespace, separate arguments, non-default caller IFS, empty input, and invalid octets with no partial output. Direct GitHub clone was unavailable in the auxiliary environment because DNS resolution for github.com failed, so this is development evidence rather than formal validation.

## Current state

`a2o` and `o2a` are corrected and protected by a permanent regression test. Diff review shows only the intended octal-helper changes in `enc.lib.sh`; the new test is mode `100755`. The library manual remains intentionally pending until the ongoing public/internal API review establishes the complete stable surface.

## Next action

Continue with `encode`/`decode`, starting from interactive passphrase acquisition and environment exposure.

## Blockers / open questions

- Final library manual/public API completion depends on finishing the function-by-function visibility review.
