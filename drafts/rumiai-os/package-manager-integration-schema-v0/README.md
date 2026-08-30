# RumiAI package manager — Desired / Resolved Integration State schema v0

Data: 2026-08-30

Stato: **design decision — JSON persistence schema v0 fissato**

Desired e Resolved state usano JSON UTF-8 secondo lo standard RumiAI v0.

Selector e binding sono nomi logici locali del profilo; non sono virtual package sotto `pkg/`.

---

# 1. Desired vs Resolved

```text
Desired = intention + selection policy
Resolved = exact immutable generation
```

Il launch usa soltanto la generation resolved attiva e non rivaluta selector dinamici.

---

# 2. Desired Profile

```json
{
  "schema": 1,
  "profile": "default",
  "selectors": [],
  "command-bindings": [],
  "environment": []
}
```

`profile` usa logical-id v0.

---

# 3. Package selector

```json
{
  "id": "netbeans",
  "target": "package",
  "package": "netbeans",
  "selection": "newest"
}
```

Optional exact upstream `version`.

---

# 4. Capability selector

```json
{
  "id": "default-java",
  "target": "capability",
  "capability": "java-runtime",
  "contract": 1,
  "constraint": ">=17",
  "selection": "newest",
  "provider-order": ["temurin"],
  "allow-other-providers": true
}
```

Capability identity = name + contract.

---

# 5. Pin

```json
{
  "id": "jdk",
  "target": "capability",
  "capability": "java-development-kit",
  "contract": 1,
  "constraint": "=21",
  "pin": "temurin@21.0.8+9@r1@linux-arm64"
}
```

Pin non fa fallback.

Nel v0 pin è mutuamente esclusivo con provider preference/fallback selection fields.

---

# 6. Public command binding

Package source:

```json
{
  "id": "netbeans-command",
  "name": "netbeans",
  "selector": "netbeans",
  "source": "package",
  "command": "netbeans"
}
```

Capability source:

```json
{
  "id": "java-command",
  "name": "java",
  "selector": "default-java",
  "source": "capability",
  "resource-key": "command"
}
```

`@platforms` resta reserved sotto `bin/`.

---

# 7. Cross-platform vs native binding

Package Instance `any-any` produce normalmente un binding cross-platform sotto:

```text
RUMIAI_ROOT/bin/<name>
```

Package Instance con platform/architecture concreta produce binding native sotto:

```text
RUMIAI_ROOT/bin/@platforms/<native-platform>-<architecture>/<name>
```

La runtime requirement del package non determina questo scope.

Quindi un'app Java/Python `any-any` resta cross-platform anche se il resolver le associa un runtime native.

---

# 8. Native specialization

Same-name collision è ammessa soltanto con relazione esplicita `specializes` fra native e cross-platform binding correlati.

Collisioni non dichiarate producono:

```text
PUBLIC_BINDING_CONFLICT
```

---

# 9. Desired public environment

```json
{
  "name": "JAVA_HOME",
  "operation": "set",
  "type": "path",
  "selector": "default-java",
  "source": "capability",
  "resource-key": "home"
}
```

Nessun absolute RUMIAI_ROOT path persistito.

---

# 10. Desired example

```json
{
  "schema": 1,
  "profile": "default",
  "selectors": [
    {
      "id": "default-java",
      "target": "capability",
      "capability": "java-runtime",
      "contract": 1,
      "constraint": ">=17",
      "selection": "newest",
      "provider-order": ["temurin"],
      "allow-other-providers": true
    },
    {
      "id": "netbeans",
      "target": "package",
      "package": "netbeans",
      "selection": "newest"
    }
  ],
  "command-bindings": [
    {
      "id": "java-default-command",
      "name": "java",
      "selector": "default-java",
      "source": "capability",
      "resource-key": "command"
    },
    {
      "id": "netbeans-command",
      "name": "netbeans",
      "selector": "netbeans",
      "source": "package",
      "command": "netbeans"
    }
  ],
  "environment": []
}
```

NetBeans continua a usare la propria private `jdk` dependency definita nel suo `@package`.

---

# 11. Resolution Snapshot

```json
{
  "schema": 1,
  "generation": 17,
  "profile": "default",
  "reason": "explicit-update",
  "created": "2026-08-30T13:00:00+02:00",
  "selectors": [],
  "graphs": [],
  "dependencies": [],
  "command-bindings": [],
  "environment": []
}
```

`created` è stringa ISO-8601, non un tipo speciale.

---

# 12. Resolved selector

Package:

```json
{
  "id": "netbeans",
  "target": "package",
  "package": "netbeans@26@r1@any-any"
}
```

Capability:

```json
{
  "id": "default-java",
  "target": "capability",
  "capability": "java-runtime",
  "contract": 1,
  "satisfied-version": "21",
  "package": "temurin@21.0.8+9@r1@linux-arm64"
}
```

---

# 13. Resolved dependency graph

```json
{
  "graphs": [
    {
      "id": "netbeans-graph",
      "root-package": "netbeans@26@r1@any-any"
    }
  ],
  "dependencies": [
    {
      "graph": "netbeans-graph",
      "consumer": "netbeans@26@r1@any-any",
      "slot": "jdk",
      "target": "capability",
      "capability": "java-development-kit",
      "contract": 1,
      "constraint": ">=17 <22",
      "provider": "temurin@21.0.8+9@r1@linux-arm64",
      "satisfied-version": "21"
    }
  ]
}
```

Nessun edge resolved contiene `latest`, fallback o provider dinamico.

---

# 14. Resolved command binding

```json
{
  "id": "netbeans-command",
  "name": "netbeans",
  "package": "netbeans@26@r1@any-any",
  "command": "netbeans",
  "graph": "netbeans-graph",
  "state": "netbeans@s1"
}
```

Capability public binding viene dereferenziato all'exact package/command.

---

# 15. Resolved environment

```json
{
  "name": "JAVA_HOME",
  "operation": "set",
  "type": "path",
  "package": "temurin@21.0.8+9@r1@linux-arm64",
  "resource-type": "directory",
  "resource": "home"
}
```

Al launch la reference exact/relocatable viene trasformata nel current absolute RUMIAI_ROOT pathname.

---

# 16. State binding

State Instance exact:

```text
<pkg-name>[@<platform>-<architecture>]@sN
```

Il qualifier usa l'host/state scope quando necessario e resta indipendente dalla Package Instance platform.

---

# 17. Active generation

Fuori dallo snapshot immutabile esiste `active`, contenente semanticamente soltanto:

```text
g17\n
```

Lo switch atomico del pointer attiva una generation già completamente validata.

---

# 18. Validation

Desired:

```text
JSON/schema
profile/id grammar
selectors
capability contract/constraints
pin/policy
binding references
public names/specialization
environment
resolution full closure
state derivation
public conflict validation
candidate snapshot
```

Resolved:

```text
JSON/schema/generation
exact Package Instance health
selector consistency
graph closure
capability satisfaction
State Instance compatibility
resource/environment references
Execution View materializability
immutable generation commit
atomic active switch
```

---

# 19. Invarianti

```text
IS-01 selector != virtual package
IS-02 Desired dynamic, Resolved exact
IS-03 JSON è il persistence format strutturato
IS-04 capability identity = name+contract
IS-05 pin non fa fallback
IS-06 private dependency non diventa public
IS-07 resolved graph non contiene dynamic selection
IS-08 resolved env non contiene absolute paths
IS-09 Package Instance any-any può risolvere runtime native
IS-10 active pointer è separato e atomico
IS-11 provenance non influenza launch
```
