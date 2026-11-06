# RumiAI Development Knowledge Base

Status: **Current**  
Updated: 2026-11-06

`rumiai-dev` is the authoritative entrypoint for current RumiAI development knowledge. The current branch describes the current project; Git history preserves superseded material without making it current authority.

## 1. Mandatory workflow

For every RumiAI task, in order:

1. Verify the current remote HEAD of every involved repository.
2. Read this README, `RULES.md` and `CONSISTENCY-GATE.md`.
3. Read `specifications/README.md` and retrieve the smallest complete set of applicable current specifications.
4. Read the relevant active handoff, if one exists.
5. Inspect current implementation and permanent tests when behavior, interfaces or validation evidence matter.
6. Perform the authorized task within the applicable contracts.
7. Complete the required validation, handoff synchronization and final consistency gate before reporting completion.

`CONSISTENCY-GATE.md` defines the detailed preflight, task-specific mandatory sources and completion checks. Do not replace current repository retrieval with conversation memory, summaries, historical commits or assumptions. If required sources or checks are unavailable, report the limitation rather than claiming completion.

## 2. Authority

In descending order:

1. Explicit current user instructions and corrections.
2. `RULES.md` and `CONSISTENCY-GATE.md`.
3. Applicable current subsystem specifications.
4. Active handoff, solely for task state and fixed task-local choices.
5. Current implementation and permanent tests, as factual/mechanical evidence.

Lower-priority evidence cannot silently override a higher-priority contract. Historical commits, completed handoffs, chat archives, drafts and superseded specifications are not current authority.

## 3. Source routing

Read specialized sources only when relevant, in addition to the mandatory workflow.

| Responsibility | Canonical entrypoint |
| --- | --- |
| Project-wide rules, repository roles and Git discipline | `RULES.md` |
| Preflight, validation and consistency | `CONSISTENCY-GATE.md` |
| Current subsystem specifications | `specifications/README.md` |
| Development workspace and bootstrap | `DEVELOPMENT.md` |
| Testing and validation | `TESTING.md` |
| Test runner | `RUNNER.md` |
| Physical validation | `PHYSICAL-TESTING.md` |
| Test-authoring patterns | `TEST-PATTERNS.md` |
| Explicit planning-only `devplan` mode | `DEVPLAN.md` |
| External-product evaluations | `products/README.md` |
| Active task ownership, resumption and lifecycle | `handoff/README.md` |
| Known work intentionally deferred | `todo/README.md` |
| Operator-requested shared-link chat exports | `chats/README.md` |

The exact standalone lowercase token `devplan` at the beginning of a current user message invokes `DEVPLAN.md` after the normal preflight; incidental mentions do not. Each specialized entrypoint owns its detailed rules and further routing.

## 4. Documentation ownership

Maintain each current contract in exactly one canonical location:

- `RULES.md`: project-wide development rules.
- `CONSISTENCY-GATE.md`: mandatory consistency process.
- `specifications/`: promoted current subsystem contracts.
- `handoff/`: active, resumable task state, not duplicate project rules.
- `todo/`: concrete deferred work, not active task state.
- `rumiai-tests`: permanent tests and revision-specific validation evidence.
- Git history: superseded material and historical rationale, not current contracts.

Update canonical sources when an accepted contract changes; do not create parallel patch layers or duplicate normative rules. Current canonical development documentation in `rumiai-dev` is maintained in English, preserving technical identifiers and externally defined tokens. Maintain documentation when changes or evidence require it, rather than on a fixed calendar.

This README routes work to canonical sources; it is not a second rulebook.
