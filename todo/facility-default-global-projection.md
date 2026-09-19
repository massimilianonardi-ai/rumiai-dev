# Facility default global projection

## Intent

Define and implement the global command/environment projection owned by the selected facility default, so a facility default can publish its provider surface outside a consumer-specific package launch.

## Why pending

The current package contract requires the facility default to ultimately own the global projection but deliberately leaves the exact global `bin` publication mechanism undefined. The current implementation applies declarative facility projections to launched consumers and does not yet implement that separate global publication responsibility.

## Scope

- `rumiai-dev/specifications/rumiai-os/PACKAGE-MODEL.md`
- `rumiai-os` package provider/default/integration/runtime surfaces as required by the future contract
- `pkg-catalog` facility projection metadata where needed
- `rumiai-tests` permanent coverage

## Evidence

- `specifications/rumiai-os/PACKAGE-MODEL.md` states that the facility default must ultimately own the global command/environment projection while the exact global publication mechanism remains outside the current contract until defined separately.
- Current `lib/sys/sh/pkg/pkg-provider.lib.sh` stores provider selection and current `lib/sys/sh/pkg/pkg-launch.lib.sh` applies projections in consumer launch context; neither defines the missing global publication mechanism.
