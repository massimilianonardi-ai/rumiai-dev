# RumiAI package manager — `@package` descriptor model

Data: 2026-08-30

Stato: **design decision — modello logico + SCF v0 fissati**

`@package` è il descriptor dichiarativo immutabile della Package Instance.

Serializzazione normativa:

```text
RumiAI System Configuration Field Format v0
```

Non è codice eseguibile e non richiede una directory `env/`.

---

# 1. Sezioni logiche

```text
kind/schema
identity
release
integrity
state
interface
requirements
environment
```

Le sezioni vengono rappresentate tramite dot notation.

---

# 2. Identity

```text
kind	package
schema	1
identity.name	netbeans
identity.version	26
identity.revision	1
identity.platform	any
identity.architecture	any
identity.display_name	NetBeans 26
```

I campi canonici:

```text
identity.name
identity.version
identity.revision
identity.platform
identity.architecture
```

devono concordare con:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

`identity.version` è upstream semanticamente opaca.

`identity.display_name` è human-readable e non entra nel pathname.

Platform descrive i vincoli propri del contenuto; Java/JDK/JRE/Python sono requirements, non platform.

---

# 3. Release

```text
release.order	123
```

`release.order` è intero positivo monotono nella stessa logical provider/package family.

Non fa parte dell'identity e non è comparabile fra family differenti.

---

# 4. Integrity metadata

`@package` contiene metadata dei due inventory tabellari esterni:

```text
integrity.method	1
integrity.algorithm	sha256
integrity.root.inventory	@integrity-root.tsv
integrity.root.files	120
integrity.root.directories	24
integrity.root.links	3
integrity.root.manifest_digest	...
integrity.run_default.inventory	@integrity-run-default.tsv
integrity.run_default.files	8
integrity.run_default.directories	4
integrity.run_default.links	0
integrity.run_default.manifest_digest	...
```

Gli inventory sono System Tabular Data con header:

```text
type	mode	digest	target	path
```

Il bulk inventory non viene flattenato dentro `@package`.

`manifest_digest` verifica i byte canonici dell'intero TSV, header incluso.

---

# 5. State

Quando presente:

```text
state.present	true
state.compatibility_version	1
state.scope	shared
state.mappings.count	2
state.mappings.1.path	etc
state.mappings.1.area	conf
state.mappings.2.path	cache
state.mappings.2.area	cache
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

Se `state.present=false`, gli altri field `state.*` sono vietati.

---

# 6. Package Interface

Resource v0:

```text
file
directory
command
```

`file` e `directory` sono path relativi sotto `root/`.

`command` è una Launch Template.

Esempio:

```text
interface.files.count	1
interface.files.1.id	launcher
interface.files.1.path	bin/netbeans

interface.directories.count	0

interface.commands.count	1
interface.commands.1.id	netbeans
interface.commands.1.executable.source	self
interface.commands.1.executable.resource_type	file
interface.commands.1.executable.resource	launcher
interface.commands.1.args.count	0
```

---

# 7. Provides / Execution Capability

Capability identity:

```text
capability name + contract version
```

Compatibility version resta separata.

Esempio:

```text
interface.provides.count	1
interface.provides.1.capability	java-runtime
interface.provides.1.contract	1
interface.provides.1.version	21
interface.provides.1.resources.count	3
interface.provides.1.resources.1.key	command
interface.provides.1.resources.1.resource_type	command
interface.provides.1.resources.1.resource	java
interface.provides.1.resources.2.key	home
interface.provides.1.resources.2.resource_type	directory
interface.provides.1.resources.2.resource	home
interface.provides.1.resources.3.key	bin
interface.provides.1.resources.3.resource_type	directory
interface.provides.1.resources.3.resource	bin
```

---

# 8. Requirements

Requirements descrivono ciò che serve, non provider selection.

```text
requirements.count	1
requirements.1.slot	jdk
requirements.1.target	capability
requirements.1.capability	java-development-kit
requirements.1.contract	1
requirements.1.constraint	>=17 <22
```

Non appartengono ai requirements:

```text
latest/newest
provider preference
fallback
user pin
resolved provider
```

---

# 9. Environment Specification

Environment è una sequenza ordinata di operazioni dichiarative:

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

```text
environment.count	2

environment.1.name	JAVA_HOME
environment.1.operation	set
environment.1.type	path
environment.1.value.source	dependency
environment.1.value.slot	jdk
environment.1.value.resource_type	directory
environment.1.value.resource	home

environment.2.name	PATH
environment.2.operation	prepend
environment.2.type	path-list
environment.2.value.source	dependency
environment.2.value.slot	jdk
environment.2.value.resource_type	directory
environment.2.value.resource	bin
```

Non sono ammessi shell snippet, `eval`, `source`, command substitution o absolute host paths persistiti.

Field-value contenente TAB/CR/LF/NUL è non rappresentabile nel v0.

---

# 10. Arbitrary identifiers

Identificatori arbitrari restano nei value.

Non si costruiscono field-name come:

```text
requirements.default-java.constraint
```

se `default-java` è un ID arbitrario.

Si usa:

```text
requirements.1.id	default-java
requirements.1.constraint	...
```

---

# 11. Cosa NON vive in `@package`

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

# 12. Revision rule

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

produce nuova RumiAI package revision.

---

# 13. Invarianti

```text
PD-01 @package usa SCF dot-notation ed è dichiarativo/immutabile
PD-02 kind=package + schema esplicito
PD-03 pathname identity == descriptor identity
PD-04 display-name non entra nel pathname
PD-05 release-order è selection metadata
PD-06 integrity bulk vive nei due TSV tabellari esterni
PD-07 integrity header = type,mode,digest,target,path
PD-08 state descrive contract/mappings, non contenuto mutabile
PD-09 Package Interface resource = file|directory|command
PD-10 capability identity = name+contract
PD-11 requirements descrivono bisogno, non policy
PD-12 environment è dati dichiarativi, non shell code
PD-13 absolute pathname non vengono persistiti
PD-14 semantic change => new package revision
PD-15 array usa count + indici contigui
PD-16 arbitrary IDs restano nei value
PD-17 structured reference usa namespace SCF senza mini-language
```
