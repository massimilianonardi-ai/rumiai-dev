# log-level-child-propagation-analysis

## Intent

Analyze whether and how the current `m` logging model should control, preserve or progressively reduce/increase the effective log level across child-process depth, using the historical `m` implementation as concrete design evidence.

## Why pending

The current RumiAI logging path exports and filters `m_LOG_LEVEL` but does not define automatic depth-based child-process log-level transformation. A historical `m` implementation had an explicit subprocess-depth mechanism, but its semantics must be re-evaluated against the current bootstrap, process model, diagnostic contract and debug/trace requirements before any part is restored or redesigned.

This is an analysis task, not authorization to reintroduce the historical mechanism unchanged.

## Scope

```text
rumiai-dev    current diagnostic/logging contract if a new policy is accepted
rumiai-os     m bootstrap/log runtime and child-process environment behavior
rumiai-tests  process-depth/log-level propagation coverage if implemented
```

Historical/reference repositories are evidence only.

## Evidence

Current implementation:

```text
rumiai-os/m
rumiai-os/lib/sys/sh/base.lib.sh
specifications/rumiai-os/DIAGNOSTICS.md
```

Historical reference:

```text
massimilianonardi-ai/m@2a57a29880c2d7a32e18782122062c695fcb1a3a
var/#_os/m/bin/m-log.lib
var/#_os/m/bin/log
```

That implementation used `LOG_SUBPROCESS_LEVEL`, `LOG_SUBPROCESS_LEVEL_STEP`, `LOG_SUBPROCESS_LEVEL_MAX` and `LOG_LEVEL_FORCE`; it incremented subprocess depth, could transform the effective level as a function of depth, bounded/logged depth behavior, and exposed corresponding controls through the historical `log` command. These mechanics are candidates for study, not current authority.
