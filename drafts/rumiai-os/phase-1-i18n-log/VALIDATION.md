# Draft local validation

Date: 2026-08-28
Status: **ad hoc local validation, not PoC certification**

The near-code drafts were copied into a temporary local tree and exercised without modifying `rumiai-os`.

Shells:

```text
dash
bash --posix
busybox sh
```

For the same example flow, all three produced:

```text
status=0
stdout=0 bytes
stderr=3 lines
```

The tested behaviors were:

1. `it_IT` catalog hit;
2. fallback from missing `fr_FR` catalog to `en_US`;
3. fallback from missing message object to literal `domain.message-id`;
4. default `info` level filtering suppressing `debug`;
5. structured fields appended separately from localized text;
6. invalid severity returning status `2`;
7. odd/incomplete field argument list returning status `2`;
8. newline/quote/backslash display escaping in the draft stderr renderer.

Representative output shape:

```text
[timestamp] [warn] [bootstrap.language-fallback] La lingua richiesta non è disponibile; verrà utilizzata la lingua di fallback. [requested="xx_YY"] [selected="en_US"]
[timestamp] [warn] [bootstrap.language-fallback] The requested language is unavailable; the fallback language will be used. [requested="fr_FR"] [selected="en_US"]
[timestamp] [info] [bootstrap.missing-message] bootstrap.missing-message [foo="a b"]
```

Edge rendering example:

```text
[value="line1\nline2 \"quoted\" \\\\ slash"]
```

## Important limits

This validation does NOT establish:

- reference-host compatibility;
- final output format correctness;
- final byte-preserving field serialization;
- final timestamp semantics;
- final log-level configuration semantics;
- final library placement/loading architecture;
- production readiness.

If the drafts survive the next design review, they can be promoted into a dedicated `rumiai-dev-PoCs` experiment before product implementation if the remaining uncertainties justify it.
