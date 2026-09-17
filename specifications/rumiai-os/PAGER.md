# RumiAI OS — Terminal pager

Status: **Current / normative**  
Updated: 2026-09-17

This specification defines the current host-neutral terminal paging facility provided by `m`.

## Ownership

The public command is:

```text
pager
```

`pager` belongs to the technical `m` substrate and is located at:

```text
bin/sys/pager
```

It is bootstrap-integrated and uses:

```sh
#!/usr/bin/env m
```

The purpose of `pager` is to keep host-specific pager selection and behavior out of consumers such as `manual`.

## Public interface

The current interface is:

```text
pager <file>
```

Exactly one file operand is accepted.

The operand must resolve to an existing readable regular file. `pager` resolves the pathname through the existing runtime path-resolution primitive before passing it to an external viewer.

## Output destination

`pager` owns the terminal/non-terminal distinction for normal paged presentation.

When standard output is not associated with a terminal, `pager` copies the selected file directly to standard output. This keeps pipelines and redirections deterministic and non-interactive.

When standard output is associated with a terminal, `pager` selects the host backend described below.

Consumers that explicitly require direct output may bypass `pager`; for example, `manual --no-pager` writes the selected manual topic directly.

## Interactive behavior target

The preferred interactive behavior is the conventional bidirectional pager model:

- forward and backward navigation are available;
- reaching end-of-file does not itself terminate the viewer;
- the viewer remains active until the user explicitly exits.

The abstraction exists because a host utility named `more` cannot be assumed to provide that behavior uniformly even where a POSIX `more` utility exists.

## Host backend policy

The current backend policy is deliberately small and explicit.

### Linux

On Linux, `pager` uses:

```text
less
```

The reason is observed divergence of the common util-linux `more` implementation from the preferred interactive behavior, including automatic exit at end-of-file in its normal host configuration.

`less` is not a POSIX baseline utility. On Linux it is therefore a required host capability of `pager`, hidden behind the abstraction rather than exposed to consumers. If `less` is unavailable, interactive paging fails explicitly; `pager` does not fall back to the anomalous `more` behavior it exists to normalize.

When `less` is selected, `pager` does not inherit `LESS`, `LESSOPEN` or `LESSCLOSE` behavior from the caller; those variables are neutralized for the viewer invocation so caller configuration does not silently change the paging contract.

### Other hosts

On other current POSIX/POSIX-compatible hosts, `pager` delegates to:

```text
more
```

A host-specific adapter is added only when real host evidence shows that the backend does not provide the required operational behavior or when another concrete requirement justifies it.

Host detection uses the existing `m` os/architecture normalization responsibility rather than creating a second platform detector.

## Configuration boundary

The first implementation does not expose:

```text
PAGER
pager backend configuration
user-selected pager commands
arbitrary pager command strings
```

Backend selection is an implementation responsibility of `pager`, not a shell-evaluated configuration surface.

## Exit status

```text
0  success
1  file resolution/access, required-backend availability or presentation failure
2  invalid invocation
```

`pager` does not make backend-specific exit statuses part of its public contract.

## Relationship with `manual`

Normal `manual` topic presentation delegates to `pager`.

`manual` therefore owns documentation lookup and `--no-pager`, while `pager` owns normal presentation destination and host backend selection.

This separation prevents documentation lookup code from accumulating Linux/macOS/vendor-specific pager logic.

## Invariants

```text
PAGER-01  pager belongs to m and is exposed as bin/sys/pager
PAGER-02  pager accepts exactly one file operand
PAGER-03  non-terminal output is copied directly and remains non-interactive
PAGER-04  pager owns host backend selection; consumers do not select more/less directly
PAGER-05  Linux uses less and fails explicitly if the required less capability is unavailable
PAGER-06  other current hosts use more until a concrete host divergence requires an adapter
PAGER-07  less remains a host-specific capability hidden behind pager, not a POSIX baseline primitive
PAGER-08  pager backend selection is fixed policy, not caller-supplied shell configuration
PAGER-09  manual normal presentation delegates to pager
```
