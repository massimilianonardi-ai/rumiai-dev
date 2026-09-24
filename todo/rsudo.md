# rsudo

## Intent

Establish `rsudo` as a dedicated future task. Define its intended semantics and ownership first, then align specifications, implementation, operational documentation and permanent tests as applicable.

## Why pending

`rsudo` has been explicitly identified as known work, but its contract and implementation are intentionally not being defined in the current work unit.

## Scope

- the applicable `m` command/runtime and privilege or remote-execution surfaces, to be determined during activation;
- `rumiai-dev`, `rumiai-os` and `rumiai-tests` as required by the resulting contract.

## Evidence

- The current `rumiai-os` tree contains `rsudo` command/library implementation, but its intended semantics, ownership, operational documentation and permanent validation remain intentionally deferred to the dedicated task.
- Local maintenance corrections to the existing implementation do not by themselves activate or define that broader task.
