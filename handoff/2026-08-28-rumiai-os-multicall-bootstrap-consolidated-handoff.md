# Handoff — RumiAI OS multicall bootstrap consolidated design

Date: 2026-08-28
Status: **active design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product boundary

`rumiai-os` product code has NOT been modified by this phase-1/multicall work.

The currently checked-in product phase-0 implementation still contains its older numeric error mapping. The normative design in `rumiai-dev` has now been renumbered and will require an explicit authorized product update before implementation convergence.

## Accepted semantic roots

```text
RumiAI_BIN_DIR     = $RumiAI_ROOT/bin
RumiAI_COMMAND_DIR = $RumiAI_ROOT/cmd
RumiAI_LIB_DIR     = $RumiAI_ROOT/lib
RumiAI_CONF_DIR    = $RumiAI_ROOT/conf
RumiAI_LANG_DIR    = $RumiAI_ROOT/lang
```

Roles:

```text
bin/  public command namespace, prepended to PATH
cmd/  private command implementations, outside PATH
lib/  sourced/imported libraries
conf/ configuration
lang/ UTF-8 language catalogs
```

`cmd/` and `RumiAI_COMMAND_DIR` are accepted, no longer placeholders.

## Bootstrap preferences

Accepted files:

```text
conf/bootstrap/language
conf/bootstrap/text-encoding
```

The integrated code proposal now performs the real bootstrap flow instead of hardcoding values.

Language request order:

```text
conf/bootstrap/language
LC_ALL
LC_MESSAGES
LANG
en_US
```

Text encoding:

```text
conf/bootstrap/text-encoding
UTF-8 fallback
```

The one-line files are data and are never sourced.

`i18n.lib` now contains draft bootstrap normalization/selection helpers. Initial text encoding support remains UTF-8 only.

Non-fatal invalid/unavailable preferences are remembered until the logger is active and are then reported through `log`.

## Multicall model

Official public entries:

```text
bin/log -> ../rumiai-os
bin/foo -> ../rumiai-os
```

Invocation identity preserved before canonicalization:

```text
RumiAI_INVOKED_AS
RumiAI_INVOKED_BIN
```

Physical state after phase 0:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

Both forms converge:

```text
log ...
rumiai-os log ...
```

into:

```text
RumiAI_COMMAND=log
```

`log` is dispatched in-process because `lib/log.lib` is already sourced. Generic commands are invoked explicitly from:

```text
$RumiAI_COMMAND_DIR/$RumiAI_COMMAND
```

## External symlink aliases

External aliases are accepted even when physically outside `RumiAI_ROOT`, and whether their symlink target is written relatively or absolutely does not affect root derivation.

Phase 0 canonicalizes the invoked pathname to the physical `rumiai-os`; therefore `RumiAI_ROOT` is the directory containing the physical target, not the external alias directory.

For an external multicall basename `<name>` to be accepted, the actual RumiAI installation must contain:

```text
$RumiAI_BIN_DIR/<name>
```

and that official public entry must canonicalize to the same:

```text
RumiAI_BOOTSTRAP_BIN
```

Therefore:

```text
/usr/local/bin/log -> /opt/rumiai/rumiai-os
```

is accepted if `/opt/rumiai/bin/log` officially registers `log` on the same front controller.

An arbitrary alias basename without official `bin/<name>` registration is rejected.

An external alias named `rumiai-os` is treated as an alias of the front controller itself and uses `rumiai-os <command> ...`.

## Shared error statuses

Normative phase-0 mapping has been renumbered pre-stability:

```text
1  PATH resolution failure
2  realpath/canonicalization failure
3  invalid bootstrap binary
4  invalid/inaccessible RumiAI root
```

Current integrated front-controller draft continues:

```text
5  i18n library load failure
6  log library load failure
7  invalid multicall invocation
8  invalid command name
9  private command unavailable
```

Assigned numbers are append-only and must not be reused for a different meaning.

Open issue: define how library/command-local return codes map to external CLI exit statuses without colliding with shared front-controller statuses while preserving exact numeric diagnosis.

No global general error catalog is introduced yet.

## Draft material

```text
drafts/rumiai-os/phase-1-multicall/README.md
drafts/rumiai-os/phase-1-multicall/FLOW.md
drafts/rumiai-os/phase-1-multicall/VALIDATION.md
drafts/rumiai-os/phase-1-multicall/rumiai-os.draft
drafts/rumiai-os/phase-1-multicall/foo.draft

drafts/rumiai-os/phase-1-i18n-log/i18n.lib
drafts/rumiai-os/phase-1-i18n-log/log.lib
```

Additional draft catalog messages were added for invalid bootstrap preference files.

## Local validation

The current proposal was exercised under:

```text
dash
bash --posix
busybox sh
```

Validated locally:

- direct `rumiai-os log ...`;
- official `bin/log` multicall;
- private `cmd/foo` dispatch;
- external relative symlink with registered basename;
- external absolute symlink with registered basename;
- external `rumiai-os` alias;
- rejection of an external unregistered basename with status 7;
- actual bootstrap language/text-encoding file reading and i18n selection.

This remains ad hoc local validation, not formal cross-host PoC certification.

## Canonical material

```text
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/I18N-BOOTSTRAP.md
architecture/rumiai-os/PHASE-1.md
decisions/rumiai-os/2026-08-28-multicall-command-layout.md
decisions/rumiai-os/2026-08-28-i18n-message-fields.md
decisions/rumiai-os/2026-08-28-text-encoding-boundary.md
```

## Immediate next design work

1. inspect the updated `rumiai-os.draft` together;
2. finalize exact command-local return-code versus CLI exit-status mapping;
3. decide whether generic private command dispatch should use child invocation or `exec`;
4. finalize logger level/status/field details;
5. decide whether the multicall/bootstrap design warrants formal PoC certification before product implementation;
6. do not modify `rumiai-os` until explicit product implementation authorization.
