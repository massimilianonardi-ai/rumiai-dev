# RumiAI OS — Terminal pager

Status: **Current / normative**  
Updated: 2026-09-19

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
pager [file ...]
```

With no file operands, `pager` reads its content from standard input. This makes the command suitable for the conventional Unix pager role, including use through environment/configuration surfaces such as a caller's pager command.

With one or more file operands, every operand must resolve to an existing readable regular file. `pager` resolves each pathname through the existing runtime path-resolution primitive before passing the resulting paths to the external viewer.

The command deliberately implements the common pager role rather than attempting to reproduce every option accepted by either `more` or `less`.

## Output destination

`pager` owns the terminal/non-terminal distinction for normal paged presentation.

When standard output is not associated with a terminal, `pager` remains non-interactive:

- with no file operands, it copies standard input directly to standard output;
- with file operands, it concatenates the resolved files to standard output in operand order.

When standard output is associated with a terminal, `pager` selects the host backend described below. With no file operands the backend reads standard input; with file operands it receives the resolved file operands.

Consumers that explicitly require direct output may bypass `pager`; for example, `manual --no-pager` writes the selected manual topic directly.

## Interactive behavior target

The preferred interactive behavior is the conventional bidirectional pager model:

- forward and backward navigation are available;
- reaching end-of-file does not itself terminate the viewer;
- the viewer remains active until the user explicitly exits.

The abstraction exists because a host utility named `more` cannot be assumed to provide that behavior uniformly even where a POSIX `more` utility exists.

The preferred behavior is not a hard availability requirement. When the preferred backend is unavailable, `pager` may deliberately degrade to a less capable baseline viewer rather than fail solely because the richer interaction cannot be provided.

## Host backend policy

The current backend policy is deliberately small and explicit.

### Linux

On Linux, `pager` prefers:

```text
less
```

The reason is observed divergence of the common util-linux `more` implementation from the preferred interactive behavior, including automatic exit at end-of-file in its normal host configuration.

`less` is not a POSIX baseline utility. On Linux it is therefore a preferred host capability of `pager`, hidden behind the abstraction rather than exposed to consumers.

If `less` is unavailable, `pager` falls back to:

```text
more
```

The fallback is intentionally accepted as degraded behavior: availability of paging is preferred over failing only because the richer `less` interaction is unavailable. Consumers remain insulated from the backend choice.

When `less` is selected, `pager` preserves the caller environment rather than neutralizing `LESS`, `LESSOPEN`, `LESSCLOSE` or equivalent caller-supplied pager behavior. Programs such as Git may intentionally set pager environment for their normal presentation semantics; the abstraction must not erase that policy.

### Other hosts

On other current POSIX/POSIX-compatible hosts, `pager` delegates to:

```text
more
```

A host-specific adapter is added only when real host evidence shows that the backend does not provide the required operational behavior or when another concrete requirement justifies it.

Host detection uses the existing `m` os/architecture normalization responsibility rather than creating a second platform detector.

## Configuration boundary

The first implementation does not expose its own backend-selection configuration:

```text
pager backend configuration
user-selected backend commands
arbitrary backend command strings
```

Backend selection remains an implementation responsibility of `pager`, not a shell-evaluated configuration surface.

This does not mean that `pager` scrubs environment inherited from its caller. Environment variables consumed by the selected backend remain part of that backend/caller interaction and are passed through unchanged.

## Exit status

```text
0  success
1  input/file resolution/access or presentation/backend failure
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
PAGER-02  pager accepts zero or more file operands; zero operands means standard input
PAGER-03  non-terminal output is copied directly and remains non-interactive for both stdin and file input
PAGER-04  pager owns host backend selection; consumers do not select more/less directly
PAGER-05  Linux prefers less and falls back to more when less is unavailable
PAGER-06  other current hosts use more until a concrete host divergence requires an adapter
PAGER-07  less remains a host-specific capability hidden behind pager, not a POSIX baseline primitive
PAGER-08  pager backend selection is fixed policy, not caller-supplied shell configuration
PAGER-09  pager preserves caller environment consumed by the selected backend
PAGER-10  manual normal presentation delegates to pager
```
