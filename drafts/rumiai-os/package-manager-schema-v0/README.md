# RumiAI package manager — `@package` schema v0

Data: 2026-08-30

Stato: **design decision — JSON schema model v0 fissato**

Questa specifica sostituisce la precedente rappresentazione TOML senza cambiare il modello logico.

---

# 1. Top-level JSON object

Required members:

```text
schema
identity
release
integrity
interface
```

Optional members:

```text
state
requirements
environment
```

```json
{ "schema": 1 }
```

Duplicate member e unknown structural member sono errori nello schema v0.

---

# 2. Logical identifiers

```text
[a-z][a-z0-9-]*
```

per dependency slot, resource ID, command ID, capability name/resource key.

---

# 3. `identity`

```json
{
  "identity": {
    "name": "netbeans",
    "version": "26",
    "revision": 1,
    "platform": "any",
    "architecture": "any",
    "display-name": "NetBeans 26"
  }
}
```

Platform v0:

```text
any linux macos windows
```

Architecture v0:

```text
any arm64 x86_64
```

Pathname identity e descriptor identity devono coincidere.

---

# 4. `release`

```json
{ "release": { "release-order": 123 } }
```

Positive integer, family-local, non identity.

---

# 5. `integrity`

```json
{
  "integrity": {
    "method": 1,
    "algorithm": "sha256",
    "root": {
      "inventory": "@integrity-root.tsv",
      "files": 1,
      "directories": 2,
      "links": 0,
      "manifest-digest": "..."
    },
    "run-default": {
      "inventory": "@integrity-run-default.tsv",
      "files": 0,
      "directories": 1,
      "links": 0,
      "manifest-digest": "..."
    }
  }
}
```

Required per tree:

```text
inventory
files
directories
links
manifest-digest
```

Inventory filename v0 deve coincidere con i due nomi canonici fissati.

TSV record:

```text
type<TAB>mode<TAB>digest<TAB>target<TAB>path
```

Il parser JSON non interpreta il TSV; integrity validation è una fase separata e streamabile.

---

# 6. `state`

```json
{
  "state": {
    "compatibility-version": 1,
    "scope": "shared",
    "mappings": [
      { "path": "etc", "area": "conf" }
    ]
  }
}
```

Scope:

```text
shared | platform | architecture | platform-architecture
```

Area:

```text
conf | data | home | cache | log | run | tmp
```

Mapping path canonico, relativo, unico, no `..`, no overlap ancestor/descendant.

---

# 7. Package Interface resources

```json
{
  "interface": {
    "files": [
      { "id": "launcher", "path": "bin/netbeans" }
    ],
    "directories": [
      { "id": "home", "path": "." }
    ],
    "commands": [] ,
    "provides": []
  }
}
```

`files`, `directories`, `commands`, `provides` sono optional arrays; `interface` object è required.

---

# 8. Structured reference

Self:

```json
{ "source": "self", "resource-type": "file", "resource": "launcher" }
```

Dependency:

```json
{ "source": "dependency", "slot": "jdk", "resource-type": "directory", "resource": "home" }
```

State:

```json
{ "source": "state", "area": "home" }
```

Literal:

```json
{ "source": "literal", "value": "-jar" }
```

---

# 9. Command

```json
{
  "id": "netbeans",
  "executable": {
    "source": "self",
    "resource-type": "file",
    "resource": "launcher"
  },
  "args": []
}
```

Executable può essere self executable file o dependency command resource.

Args è ordered array; ogni elemento produce un argv element, mai una shell command string.

---

# 10. Capability provide

```json
{
  "capability": "java-runtime",
  "contract": 1,
  "version": "21",
  "resources": [
    { "key": "command", "resource-type": "command", "resource": "java" },
    { "key": "home", "resource-type": "directory", "resource": "home" },
    { "key": "bin", "resource-type": "directory", "resource": "bin" }
  ]
}
```

Capability identity = name + contract.

---

# 11. Requirements

Capability target:

```json
{
  "slot": "jdk",
  "target": "capability",
  "capability": "java-development-kit",
  "contract": 1,
  "constraint": ">=17 <22"
}
```

Package target:

```json
{
  "slot": "engine",
  "target": "package",
  "package": "specific-engine"
}
```

Optional exact upstream `version` per package-target; no generic upstream range v0.

Tutti i requirements sono mandatory nel v0.

---

# 12. Capability constraint grammar

```text
constraint = comparator *(SP comparator)
operator   = = | > | >= | < | <=
```

No OR, wildcard, caret, tilde, provider name o implicit latest.

---

# 13. Environment

Ordered array:

```json
[
  {
    "name": "JAVA_HOME",
    "operation": "set",
    "type": "path",
    "value": {
      "source": "dependency",
      "slot": "jdk",
      "resource-type": "directory",
      "resource": "home"
    }
  },
  {
    "name": "PATH",
    "operation": "prepend",
    "type": "path-list",
    "value": {
      "source": "dependency",
      "slot": "jdk",
      "resource-type": "directory",
      "resource": "bin"
    }
  }
]
```

Operations:

```text
set | set-if-unset | unset | prepend | append
```

Types:

```text
scalar | path | path-list
```

No host absolute literal pathname, shell expansion o eval.

---

# 14. Environment precedence

```text
1 inherited/sanitized Host Base Environment
2 RumiAI Base Environment
3 Resolved Integration Profile environment
4 Package Environment Specification
5 Command-specific environment overlay
6 explicit invocation override
```

---

# 15. Validation order

```text
1 JSON parse UTF-8
2 duplicate-member rejection
3 schema
4 structural fields/types
5 logical IDs
6 pathname identity agreement
7 platform vocabulary
8 integrity metadata syntax
9 TSV inventory + physical tree verification
10 state mappings
11 Package Interface physical target validation
12 capability contract validation
13 requirements
14 environment/reference validation
15 cross-reference validation
16 Physical Platform Validation
```

---

# 16. Error classes

```text
DESCRIPTOR_PARSE_ERROR
UNSUPPORTED_SCHEMA
DESCRIPTOR_SCHEMA_ERROR
IDENTITY_MISMATCH
INTEGRITY_ERROR
STATE_MAPPING_ERROR
INTERFACE_ERROR
CAPABILITY_ERROR
REQUIREMENT_ERROR
ENVIRONMENT_ERROR
REFERENCE_ERROR
PLATFORM_VALIDATION_ERROR
```

---

# 17. Invarianti

```text
PS-01 @package schema v0 = strict JSON object
PS-02 duplicate/unknown structural members rejected
PS-03 software version opaque string
PS-04 identity platform/architecture orthogonal to runtime requirements
PS-05 integrity inventories external TSV files
PS-06 TSV bulk parse separate dal JSON parse
PS-07 resource reference strutturata
PS-08 command argv-based, no shell string
PS-09 capability = name + contract + compatibility version
PS-10 requirements mandatory
PS-11 environment ordered operation array
PS-12 absolute host paths absent from descriptor
```
