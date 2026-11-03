# m — standalone POSIX JSON query command

Status: Current / normative
Updated: 2026-11-03

## Purpose and boundary

`bin/sys/json` is an independent, POSIX `#!/bin/sh` JSON query utility for general shell use and early technical `m`/`pkg` workflows before managed runtimes or package providers have been installed. Its primary responsibility is reliable read-only extraction from JSON input. Syntax validation is mandatory for every parsed document; standalone validation is exposed through `--check`.

The command does not depend on `m_ROOT`, JavaScript, `jq`, Python or other non-POSIX runtimes. Its declared POSIX utility dependencies are `od`, `awk`, `mkdir`, `rm`, `rmdir` and `cat`. It is not the existing specialized `lib/sys/sh/json.lib.sh` library and does not redefine that library's interface.

The CLI and the supported subset of filter semantics intentionally follow `jq`. This contract does **not** claim complete compatibility with the jq programming language.

## Invocation

```text
json [-c] [-r] [-e] [filter] [file ...]
json [-c] [-r] [-e] -f filter-file [file ...]
json --check [file ...]
```

- With no filter operand, use the identity filter `.`. A supplied first non-option operand is always a filter, not an input filename.
- Read one or more sequential JSON values from standard input if no input file is specified. File operands are read in order, with each file parsed independently. `-` is the standard-input file operand; `--` terminates CLI option parsing.
- `-f` / `--from-file` supplies the filter as text from a readable file in place of an inline filter operand.
- `-c` / `--compact-output` prints one compact JSON value on each output line. By default, JSON objects and arrays are indented with two spaces.
- `-r` / `--raw-output` prints JSON string results as decoded UTF-8 text without JSON quoting, followed by newline; results of other types follow the JSON formatting mode.
- `-e` / `--exit-status` interprets the final output value: status `0` for non-`false`/non-`null`, `1` for `false` or `null`, and `4` if no result was produced.
- `--check` is a dedicated read-only validation mode: no output; exactly one complete JSON value is required per input stream/file; any invalid input is an error. It does not accept a filter or output/query flags.

The previous implementation's interpretation of `-c` as “check only” is superseded. `-c` is reserved for jq-compatible compact output. Query behavior must never silently change meaning depending on whether the user supplied a filter.

## Supported read-only filter grammar

The implemented subset contains:

```text
.                       identity
.key                    ASCII identifier object key
.["JSON key"]           arbitrary object key, JSON-escaped string syntax
.[0]  .[-1]             zero-based and negative array indices
.[]                     iterate array elements or object values
.foo.bar  .foo[0]       chained selectors
.foo?  .foo[]?          optional access: suppress wrong-type errors
.a, .b                 alternative filters evaluated on the same input
.a | .b                pipe output values through the next filter
```

`|` connects stages; `,` has tighter precedence and evaluates both alternatives against the same stage input. Parentheses, arithmetic, predicates, value construction, mutation, recursion, function definitions and jq built-ins beyond the above selectors are not supported. Unknown syntax is an error, not a silent no-op or approximate fallback.

On objects, missing keys return JSON `null`. On arrays, out-of-range indices return `null`; negative indices count from the end. Null inputs to ordinary key or index selection return `null`; selecting from incompatible non-null types is a runtime error unless the selector has `?`. Applying `.[]` to a non-container is a runtime error unless optional. An empty collection's `.[]` produces no values. Each result is emitted independently, without an enclosing array.

Decoded Unicode object key equivalence is required: literal UTF-8 characters and JSON `\uXXXX` escapes (including surrogate pairs) match the same logical key. Duplicate member names use the last value for query lookup and serialization, preserving the first member's position in object iteration. JSON numeric lexemes are not converted to floating-point values during extraction. A scalar string in JSON output remains a valid JSON string; raw output decodes JSON escapes.

## Correctness and safety

The parser must accept the full JSON grammar of RFC 8259 and ECMA-404, including top-level scalars, and must reject malformed JSON, invalid UTF-8, overlong sequences, raw control characters, malformed numbers, non-JSON whitespace and trailing invalid tokens. Escaped UTF-16 surrogate units remain accepted at the JSON grammar boundary, but raw string output must not emit malformed UTF-8.

The parser must not evaluate untrusted input as shell or awk source. Its implementation must avoid unbounded shell-recursive descent for nested JSON. Validation must reach the end of every supplied input stream before output is published, so an invalid later element does not expose earlier extracted data as if the whole operation succeeded. A private temporary directory is permitted for this atomic publication; its need and cost must be documented. Internal memory and temporary disk use must be proportional to the input and selected outputs, subject to host resource limits.

## Exit statuses and diagnostics

```text
0    Successful operation, or -e final result neither false nor null
1    -e final result false/null
2    Invalid CLI invocation
3    Invalid or unsupported filter syntax
4    -e with no results
7    Private temporary directory creation failure
8    Input or filter file absent/unreadable
9    Input or filter file read failure
10   Malformed JSON lexical token/escape
11   Invalid input UTF-8
12   Malformed JSON structure or not exactly one --check value
13   Invalid query operation on the encountered JSON type
15   Internal byte-stream/parser failure
16   Output write failure
17   Standard-input read failure
18   Filter file absent/unreadable
19   Filter file read failure
20   Filter temporary materialization failure
129+ Termination by handled POSIX signal
```

The pre-query diagnostic codes for JSON lexical/UTF-8/structural errors are superseded by `10`/`11`/`12`; this is an intentional CLI-contract realignment alongside `-e` semantics. Error diagnostics go to stderr and identify the failing operation or input offset without exposing private input values.

## Validation

Permanent tests must protect the query command's normal shell workflow, Unicode-escaped key equivalence, nested array traversal, duplicate-member behavior, wrong-type and missing-value distinction, atomic invalid-input rejection, and CLI/`-e` statuses. The pinned upstream JSONTestSuite `test_parsing` corpus remains the external grammar conformance reference. Its `y_` and `n_` expectations are strict; `i_` inputs have implementation-dependent expectations and must not be counted as strict failures merely because an implementation chooses acceptance or rejection.
