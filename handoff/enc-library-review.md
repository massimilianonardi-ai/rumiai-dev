# enc.lib.sh review

Status: Active
Updated: 2026-09-20

## Goal

Review and realign `lib/sys/sh/enc.lib.sh` function by function, preserving intended behavior while correcting concrete defects, POSIX/portability issues, security gaps, tests and operational documentation as the public API is established.

## Current repository revisions

```text
rumiai-dev   34fb1c0ada45bf99a8e9a2d212767eed6417470f
rumiai-os    794d0d60900cdd1aa25cbc4e541819ba6c853b22
rumiai-tests e31641259396b6ce503df1283fed4a5b186e5596
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
- Two concrete octal-helper defects were established: `a2o` can emit `*` because `od` lacks `-v`, and `o2a` currently splits only on newline instead of all POSIX shell whitespace.

## Current state

No product/test modification for the octal helpers has yet been committed in this task.

## Next action

Correct `a2o` and `o2a`, add proportional permanent regression coverage, run targeted validation, then continue with `encode`/`decode`.

## Blockers / open questions

- Final library manual/public API completion depends on finishing the function-by-function visibility review.
