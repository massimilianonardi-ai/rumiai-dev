# RumiAI package manager — `@package` descriptor model

Data: 2026-08-30

Stato: **design decision — modello logico + JSON v0 fissati**

`@package` è il descriptor dichiarativo immutabile della Package Instance.

Serializzazione normativa:

```text
JSON UTF-8 secondo RumiAI JSON standard v0
```

Non è codice eseguibile e non richiede una directory `env/`.

---

# 1. Sezioni logiche

```text
schema
identity
release
integrity
state
interface
requirements
environment
```

---

# 2. Identity

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

I campi canonici:

```text
name
version
revision
platform
architecture
```

devono concordare con:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

`version` è upstream semanticamente opaca.

`display-name` è human-readable e non entra nel pathname.

Platform descrive i vincoli propri del contenuto; Java/JDK/JRE/Python sono requirements, non platform.

---

# 3. Release

```json
{
  "release": {
    "release-order": 123
  }
}
```

`release-order` è un intero positivo monotono nella stessa logical provider/package family.

Non fa parte dell'identity e non è comparabile fra family differenti.

---

# 4. Integrity

`@package` contiene metadata dei due inventory esterni:

```json
{
  "integrity": {
    "method": 1,
    "algorithm": "sha256",
    "root": {
      "inventory": "@integrity-root.tsv",
      "files": 120,
      "directories": 24,
      "links": 3,
      "manifest-digest": "..."
    },
    "run-default": {
      "inventory": "@integrity-run-default.tsv",
      "files": 8,
      "directories": 4,
      "links": 0,
      "manifest-digest": "..."
    }
  }
}
```

Il bulk inventory non viene inserito nel JSON.

Ogni inventory TSV usa record canonici:

```text
type<TAB>mode<TAB>digest<TAB>target<TAB>path
```

con `path` ultimo.

`manifest-digest` verifica i byte canonici dell'intero relativo TSV.

---

# 5. State

Quando presente:

```json
{
  "state": {
    "compatibility-version": 1,
    "scope": "shared",
    "mappings": [
      { "path": "etc", "area": "conf" },
      { "path": "cache", "area": "cache" }
    ]
  }
}
```

Scope:

```text
shared
platform
architecture
platform-architecture
```

State areas:

```text
conf
data
home
cache
log
run
tmp
```

Ogni writable island appartiene esattamente a una state area.

---

# 6. Package Interface

Resource v0:

```text
file
directory
command
```

`file` e `directory` sono path relativi sotto `root/`.

`command` è una Launch Template, non necessariamente un executable pathname diretto.

Esempio:

```json
{
  "interface": {
    "files": [
      { "id": "launcher", "path": "bin/netbeans" }
    ],
    "commands": [
      {
        "id": "netbeans",
        "executable": {
          "source": "self",
          "resource-type": "file",
          "resource": "launcher"
        },
        "args": []
      }
    ]
  }
}
```

---

# 7. Provides / Execution Capability

Una capability è identificata da:

```text
capability name + contract version
```

Compatibility version resta separata.

Esempio:

```json
{
  "interface": {
    "provides": [
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
    ]
  }
}
```

---

# 8. Requirements

Requirements descrivono ciò che serve, non provider selection.

Esempio NetBeans:

```json
{
  "requirements": [
    {
      "slot": "jdk",
      "target": "capability",
      "capability": "java-development-kit",
      "contract": 1,
      "constraint": ">=17 <22"
    }
  ]
}
```

Non appartengono a `requirements`:

```text
latest/newest
provider preference
fallback
user pin
resolved provider
```

---

# 9. Environment Specification

Environment è una lista ordinata di operazioni dichiarative:

```text
set
set-if-unset
unset
prepend
append
```

Type:

```text
scalar
path
path-list
```

Esempio:

```json
{
  "environment": [
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
}
```

Non sono ammessi shell snippet, `eval`, `source`, command substitution o absolute host paths persistiti.

---

# 10. Cosa NON vive in `@package`

```text
resolved provider
Selection Policy corrente
absolute RUMIAI_ROOT
Materialized Process Environment
State Instance contents
run/ target concreti
logs/cache/PID/tmp
Integration Profile corrente
```

---

# 11. Revision rule

Qualunque modifica semantica a:

```text
identity
release
integrity metadata/inventories
state mappings
Package Interface
provides
requirements
environment
Launch Template
```

produce una nuova RumiAI package revision.

---

# 12. Invarianti

```text
PD-01 @package è JSON dichiarativo e immutabile
PD-02 schema esplicito
PD-03 pathname identity == descriptor identity
PD-04 display-name non entra nel pathname
PD-05 release-order è selection metadata
PD-06 integrity bulk vive nei due TSV inventory esterni
PD-07 state descrive contract/mappings, non contenuto mutabile
PD-08 Package Interface resource = file|directory|command
PD-09 capability identity = name+contract
PD-10 requirements descrivono bisogno, non policy
PD-11 environment è dati dichiarativi, non shell code
PD-12 absolute pathname non vengono persistiti
PD-13 semantic change => new package revision
PD-14 JSON è il formato strutturato v0
```
