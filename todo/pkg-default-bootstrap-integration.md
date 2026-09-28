# pkg-default bootstrap integration

## Intent

After the dedicated full `pkg` review, design and integrate application of configured pkg/facility defaults into the execution phase of the technical `m` bootstrap.

## Why pending

The previous implementation loaded `pkg/pkg-provider` and applied `pkg_provider_global_environment_apply` during bootstrap/core initialization, but that placement and mechanism are not accepted. The behavior has been removed completely for now so the bootstrap/core architecture can remain clean while `pkg` is reviewed as a whole.

## Scope

`rumiai-dev` package/bootstrap contracts, `rumiai-os` bootstrap and pkg implementation, and proportional permanent tests. `pkg-catalog` is included only if the later pkg review establishes a catalog-contract change.

## Evidence

Current `specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md` states that the root bootstrap performs no package/provider initialization. Current `specifications/rumiai-os/PACKAGE-MODEL.md` no longer defines bootstrap-global facility-env application. Current `rumiai-os` keeps `pkg_provider_global_environment_apply` as pkg implementation but does not invoke it from `m` or `core.lib.sh`.
