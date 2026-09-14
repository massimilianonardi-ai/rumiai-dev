# Handoff — resource model implementation

Date: 2026-09-14  
Status: implementation complete; physical validation pending

## Authority

This handoff is non-normative.

The authoritative resource contracts are:

```text
specifications/rumiai-os/RESOURCE-MODEL.md
specifications/rumiai-os/LANG-BOOTSTRAP.md
decisions/rumiai-os/2026-09-14-activate-resource-model.md
```

Existing state, package, bootstrap and Model 2.0 contracts remain authoritative where not superseded by the targeted resource-model decision.

## Resource-model documentation baseline

The resource model was introduced in:

```text
rumiai-dev c463f692e9bf2fe138ebf38671ccc97fd7a66639
```

That revision:

- defines `$m_ROOT/res` as the global resource semantic root;
- defines `m_RES_DIR=$m_ROOT/res`;
- ownership-qualifies global resources under `res/sys` and `res/ai`;
- fixes `lang` as the first concrete resource class;
- moves the technical language interface to `m_LANG_DIR=$m_RES_DIR/sys/lang`;
- keeps `lang` technical and `m` semantically independent of RumiAI;
- keeps package resources package-local;
- keeps `current` selectors co-located with global language resources;
- defines global language selection through all materialized `res/*/lang/current` selectors;
- defines `lang-set` query as the selected locale from the technical `sys` selector;
- does not introduce a universal resource resolver, URI, registry, daemon or resource manager.

## Product implementation baseline

The resource implementation was completed through:

```text
rumiai-os cd0e914615d79d3944dafa0456c9b6220f9b550e
```

The implementation chain includes:

```text
dabe40513c57481fc197077a0ff0c37cb6c9cdae  Adopt global resource language layout
8b7a69e55b1e90157640554293e46474f5d2f20d  Restore readpathce newline sentinel handling
cd0e914615d79d3944dafa0456c9b6220f9b550e  Remove unused lang selector helper
```

The intermediate `readpathce` serialization defect introduced while reconstructing `m` was detected by post-change diff review and corrected forward-only before the resource implementation baseline was considered complete.

At the implementation baseline:

```text
m_RES_DIR=$m_ROOT/res
m_LANG_DIR=$m_RES_DIR/sys/lang

res/sys/lang/current -> en_US
res/ai/lang/current  -> en_US
```

The pre-existing technical catalogs were moved without semantic rewriting under:

```text
res/sys/lang/en_US/
res/sys/lang/it_IT/
```

The `ai` language trees are materialized for the same supported locales without inventing branded messages.

`lang-set`:

- discovers participating global language trees generically under `res/*/lang`;
- does not encode an `ai` dependency;
- validates the requested locale and existing selector in every participant before mutation;
- prepares replacement selectors for all participants;
- switches non-`sys` participants before `sys`;
- switches `sys` last as the logical commit observed by the zero-argument query;
- attempts rollback on ordinary handled update failures;
- never visits package resources;
- does not promise filesystem crash-atomicity across multiple symlinks.

## Later concurrent product work

After the resource implementation baseline, an independent `srv` work unit advanced `rumiai-os/main` to:

```text
a5442e527f6bc7a70022f09330ba27770c0b5fb7
```

with commit message:

```text
Harden srv locking and fatal calls
```

That revision descends from the resource implementation baseline and retains the resource-model changes. The `srv` change was not modified as part of this work unit.

## Permanent tests

The main resource test alignment was committed in:

```text
rumiai-tests 6e57616c5011e67900e014299c47a96f362d3338
```

It covers at least:

- `m_RES_DIR` and the new `m_LANG_DIR` value, including child-process export;
- technical fallback under `res/sys/lang/en_US`;
- the public technical `lang` resolver under the new resource tree;
- catalog text remaining data rather than executable shell code;
- absence of the superseded top-level `lang` root;
- presence of the `sys` and `ai` language trees and relative initial selectors;
- zero-argument `lang-set` returning only the selected locale;
- synchronized `sys`/`ai` selection;
- all-owner prevalidation before mutation;
- rejection of unavailable locales and invalid selector objects without partial selection changes;
- package-local language resources remaining untouched.

Final consistency review found the shared test-authoring fixture reference still copying the superseded top-level `lang` root. This was corrected forward-only in:

```text
216e4ffdd9ae31e625fd2c47e27573bdae9c4538  Align fixture reference with resource root
47b5b1083d96aef9919b5092fd21e16aadedf8ee  Check resource root in fixture reference test
```

These commits were applied on top of independent concurrent `srv` test work and do not modify that work.

## Validation status

No physical validation result is recorded by this handoff.

The resource-test commit initially set:

```text
rumiai-validate.conf -> rumiai-os cd0e914615d79d3944dafa0456c9b6220f9b550e
```

After that point, independent concurrent work added a newer `srv` product revision and a corresponding newer permanent test for concurrent start serialization. Therefore the current `rumiai-tests/main` suite contains test material newer than the product revision currently selected by `rumiai-validate.conf`.

The configuration must not be treated as a valid current full-suite validation pair until that concurrent work is deliberately reconciled according to the normal validation-pair process.

This resource work unit does not silently advance the validation target to the later `srv` revision because doing so would absorb an independent user update into this work unit without an explicit integration decision.

## Consistency check

The final resource-specific consistency review established:

- the current product tree has no top-level `lang` root;
- global language resources are under `res/sys/lang` and `res/ai/lang`;
- both initial global selectors are relative `current -> en_US` links;
- the current bootstrap retains `m_RES_DIR=$m_ROOT/res` and `m_LANG_DIR=$m_RES_DIR/sys/lang`;
- the current `lang-set` implementation remains generic across materialized global owners and does not name `ai`;
- package resource ownership remains unchanged;
- no universal resource resolver or other unapproved resource primitive was introduced;
- the shared test fixture reference no longer depends on the superseded top-level `lang` layout;
- older documentation that still describes `$m_ROOT/lang` is governed by the explicit targeted supersession in `2026-09-14-activate-resource-model.md`; historical evidence is not rewritten.

## Remaining action

The remaining closure action is revision-specific physical testing after the current product and test revisions are deliberately paired. Until that happens, the resource model is implemented and permanently covered, but not physically validated by a recorded validation session.
