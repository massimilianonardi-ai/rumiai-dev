# Handoff — RumiAI OS phase 1 bootstrap environment

Date: 2026-08-28
Status: **active design handoff**

## Handoff rule

The operational handoff source is the most recent file in `rumiai-dev/handoff/`.

## Product boundary

Phase 0 in `rumiai-os` is considered complete and consolidated by the user.

No phase-1 product implementation has been authorized or performed yet. Current work is design/specification in `rumiai-dev`.

## Accepted phase-1 semantic roots

Immediately after phase 0, the accepted minimal semantic roots are:

```text
RumiAI_BIN_DIR  = $RumiAI_ROOT/bin
RumiAI_LIB_DIR  = $RumiAI_ROOT/lib
RumiAI_CONF_DIR = $RumiAI_ROOT/conf
RumiAI_LANG_DIR = $RumiAI_ROOT/lang
```

No generic `share/` or `resources/` directory exists at this stage.

## PATH and libraries

`RumiAI_BIN_DIR` is prepended to the inherited PATH, retaining the inherited host/caller PATH as fallback.

Only executable directories participate in PATH.

Libraries are loaded explicitly from `RumiAI_LIB_DIR`; `lib/`, `conf/`, and `lang/` are not added to PATH.

## Bootstrap primitive principle

RumiAI accepts minimal bootstrap primitives when necessary to break dependency cycles, with the expectation that advanced subsystems become authoritative once initialized.

First concrete primitive:

```text
$RumiAI_CONF_DIR/bootstrap/language
```

This file is data, not sourced shell code.

## Language state

Canonical RumiAI language variable:

```text
RumiAI_LANGUAGE
```

Current language/territory form:

```text
language_TERRITORY
```

Examples:

```text
en_US
it_IT
```

The uppercase territory component is an explicit semantic exception to the generic lowercase filesystem naming convention when used in language path components.

## Language fallback

Accepted preference order:

```text
1. conf/bootstrap/language
2. LC_ALL
3. LC_MESSAGES
4. LANG
5. en_US
```

Host locale variables are fallback input, not authoritative RumiAI language state.

The i18n subsystem owns normalization and should minimize fatal initialization errors; missing requested language data should normally fall back to English when possible.

## Open encoding issue

The only intentionally unresolved issue in this part of the design is whether the codeset/encoding belongs in:

- `RumiAI_LANGUAGE`;
- the language directory name;
- neither, because RumiAI-controlled catalogs use one canonical internal encoding.

Examples under evaluation:

```text
lang/it_IT/
lang/it_IT.UTF-8/
```

POSIX host locale values may have the form `language[_territory][.codeset][@modifier]`, but RumiAI does not have to copy that representation into its own catalog identity.

The next task is to decide the RumiAI internal text/catalog encoding contract and the boundary behavior when the host locale uses another codeset.

## Canonical material

```text
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
architecture/rumiai-os/PHASE-1.md
decisions/rumiai-os/2026-08-28-phase-1-bootstrap-environment.md
```
