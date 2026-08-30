# RumiAI package manager — `@package` descriptor model

Data: 2026-08-30

Stato: **design decision — modello logico + System Field Format v0 fissati**

`@package` è il descriptor dichiarativo immutabile della Package Instance.

Serializzazione normativa:

```text
RumiAI System Field Format v0
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

Le sezioni logiche vengono flattenate in field-name POSIX-safe; strutture ripetibili usano count + indici contigui `1..N`.

---

# 2. Identity

```text
kind	package
schema	1
identity_name	netbeans
identity_version	26
identity_revision	1
identity_platform	any
identity_architecture	any
identity_display_name	NetBeans 26
```

I campi canonici:

```text
identity_name
identity_version
identity_revision
identity_platform
identity_architecture
```

devono concordare con:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

`identity_version` è upstream semanticamente opaca.

`identity_display_name` è human-readable e non entra nel pathname.

Platform descrive i vincoli propri del contenuto; Java/JDK/JRE/Python sono requirements, non platform.

---

# 3. Release

```text
release_order	123
```

`release_order` è un intero positivo monotono nella stessa logical provider/package family.

Non fa parte dell'identity e non è comparabile fra family differenti.

---

# 4. Integrity

`@package` contiene metadata dei due inventory esterni:

```text
integrity_method	1
integrity_algorithm	sha256
integrity_root_inventory	@integrity-root.tsv
integrity_root_files	120
integrity_root_directories	24
integrity_root_links	3
integrity_root_manifest_digest	...
integrity_run_default_inventory	@integrity-run-default.tsv
integrity_run_default_files	8
integrity_run_default_directories	4
integrity_run_default_links	0
integrity_run_default_manifest_digest	...
```

Il bulk inventory non viene inserito in `@package`.

Ogni inventory esterno usa anch'esso System Field Format v0 a due campi, con collection separate per directory/file/link.

`manifest_digest` verifica i byte canonici dell'intero relativo inventory.

---

# 5. State

Quando presente:

```text
state_present	true
state_compatibility_version	1
state_scope	shared
state_mapping_count	2
state_mapping_1_path	etc
state_mapping_1_area	conf
state_mapping_2_path	cache
state_mapping_2_area	cache
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

Se `state_present=false`, i field `state_*` ulteriori sono vietati e `state_mapping_count` non compare.

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

```text
interface_file_count	1
interface_file_1_id	launcher
interface_file_1_path	bin/netbeans

interface_directory_count	0

interface_command_count	1
interface_command_1_id	netbeans
interface_command_1_executable_source	self
interface_command_1_executable_resource_type	file
interface_command_1_executable_resource	launcher
interface_command_1_arg_count	0
```

---

# 7. Provides / Execution Capability

Una capability è identificata da:

```text
capability name + contract version
```

Compatibility version resta separata.

Esempio:

```text
interface_provide_count	1
interface_provide_1_capability	java-runtime
interface_provide_1_contract	1
interface_provide_1_version	21
interface_provide_1_resource_count	3
interface_provide_1_resource_1_key	command
interface_provide_1_resource_1_resource_type	command
interface_provide_1_resource_1_resource	java
interface_provide_1_resource_2_key	home
interface_provide_1_resource_2_resource_type	directory
interface_provide_1_resource_2_resource	home
interface_provide_1_resource_3_key	bin
interface_provide_1_resource_3_resource_type	directory
interface_provide_1_resource_3_resource	bin
```

---

# 8. Requirements

Requirements descrivono ciò che serve, non provider selection.

Esempio NetBeans:

```text
requirement_count	1
requirement_1_slot	jdk
requirement_1_target	capability
requirement_1_capability	java-development-kit
requirement_1_contract	1
requirement_1_constraint	>=17 <22
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
environment_count	2

environment_1_name	JAVA_HOME
environment_1_operation	set
environment_1_type	path
environment_1_value_source	dependency
environment_1_value_slot	jdk
environment_1_value_resource_type	directory
environment_1_value_resource	home

environment_2_name	PATH
environment_2_operation	prepend
environment_2_type	path-list
environment_2_value_source	dependency
environment_2_value_slot	jdk
environment_2_value_resource_type	directory
environment_2_value_resource	bin
```

Non sono ammessi shell snippet, `eval`, `source`, command substitution o absolute host paths persistiti.

Field-value contenenti TAB/CR/LF/NUL non sono rappresentabili nel v0 e rendono il descriptor non ammissibile.

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
PD-01 @package usa System Field Format ed è dichiarativo/immutabile
PD-02 kind=package + schema esplicito
PD-03 pathname identity == descriptor identity
PD-04 display-name non entra nel pathname
PD-05 release-order è selection metadata
PD-06 integrity bulk vive nei due inventory esterni System Field Format
PD-07 state descrive contract/mappings, non contenuto mutabile
PD-08 Package Interface resource = file|directory|command
PD-09 capability identity = name+contract
PD-10 requirements descrivono bisogno, non policy
PD-11 environment è dati dichiarativi, non shell code
PD-12 absolute pathname non vengono persistiti
PD-13 semantic change => new package revision
PD-14 collection usa count + indici contigui
PD-15 structured reference viene flattenata senza mini-language nei value
```
