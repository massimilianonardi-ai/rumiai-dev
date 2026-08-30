# RumiAI package manager — `@package` schema v0

Data: 2026-08-30

Stato: **design decision — System Field Format schema v0 fissato**

Questa specifica mantiene invariato il modello logico e sostituisce la precedente rappresentazione JSON.

---

# 1. Header

Required:

```text
kind	package
schema	1
```

Unknown field non previsto dallo schema v0 è errore.

Duplicate field-name è errore di System Field Format.

---

# 2. Logical identifiers

Valori logical-id:

```text
[a-z][a-z0-9-]*
```

per dependency slot, resource ID, command ID, capability name/resource key.

Questi identificatori restano field-value; non vengono incorporati nei field-name.

---

# 3. Identity

Required:

```text
identity_name	netbeans
identity_version	26
identity_revision	1
identity_platform	any
identity_architecture	any
identity_display_name	NetBeans 26
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

# 4. Release

```text
release_order	123
```

Positive integer, family-local, non identity.

---

# 5. Integrity

Required:

```text
integrity_method	1
integrity_algorithm	sha256
integrity_root_inventory	@integrity-root.tsv
integrity_root_files	1
integrity_root_directories	2
integrity_root_links	0
integrity_root_manifest_digest	...
integrity_run_default_inventory	@integrity-run-default.tsv
integrity_run_default_files	0
integrity_run_default_directories	1
integrity_run_default_links	0
integrity_run_default_manifest_digest	...
```

Inventory filename v0 deve coincidere con i nomi canonici fissati.

I due inventory usano System Field Format `kind=integrity`, non una seconda grammatica TSV a cinque campi.

---

# 6. State

Presence marker required:

```text
state_present	true|false
```

Se true:

```text
state_compatibility_version	1
state_scope	shared
state_mapping_count	1
state_mapping_1_path	etc
state_mapping_1_area	conf
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

# 7. Package Interface file/directory resources

Collections obbligatorie anche quando vuote:

```text
interface_file_count	N
interface_directory_count	N
interface_command_count	N
interface_provide_count	N
```

File:

```text
interface_file_1_id	launcher
interface_file_1_path	bin/netbeans
```

Directory:

```text
interface_directory_1_id	home
interface_directory_1_path	.
```

---

# 8. Structured reference pattern

Una reference usa un prefix di schema e field condizionali.

Self:

```text
<prefix>_source	self
<prefix>_resource_type	file
<prefix>_resource	launcher
```

Dependency:

```text
<prefix>_source	dependency
<prefix>_slot	jdk
<prefix>_resource_type	directory
<prefix>_resource	home
```

State:

```text
<prefix>_source	state
<prefix>_area	home
```

Literal:

```text
<prefix>_source	literal
<prefix>_literal	-jar
```

Non esiste mini-language persistita nei value.

---

# 9. Command

```text
interface_command_1_id	netbeans
interface_command_1_executable_source	self
interface_command_1_executable_resource_type	file
interface_command_1_executable_resource	launcher
interface_command_1_arg_count	0
```

Executable può essere self executable file o dependency command resource.

Args è ordered collection; ogni indice produce un argv element, mai una shell command string.

Literal argv contenente TAB/CR/LF/NUL è non rappresentabile e viene rifiutato nel v0.

---

# 10. Capability provide

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

Capability identity = name + contract.

---

# 11. Requirements

Capability target:

```text
requirement_count	1
requirement_1_slot	jdk
requirement_1_target	capability
requirement_1_capability	java-development-kit
requirement_1_contract	1
requirement_1_constraint	>=17 <22
```

Package target:

```text
requirement_1_slot	engine
requirement_1_target	package
requirement_1_package	specific-engine
```

Optional exact upstream `requirement_<i>_version` per package-target; no generic upstream range v0.

Tutti i requirements sono mandatory nel v0.

---

# 12. Capability constraint grammar

Field-value constraint:

```text
constraint = comparator *(SP comparator)
operator   = = | > | >= | < | <=
```

No OR, wildcard, caret, tilde, provider name o implicit latest.

---

# 13. Environment

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
1 System Field Format parse UTF-8
2 field-name/duplicate/kind/schema validation
3 required/unknown field validation
4 canonical count + contiguous indices
5 logical IDs
6 pathname identity agreement
7 platform vocabulary
8 integrity metadata syntax
9 integrity inventory + physical tree verification
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
WRONG_FILE_KIND
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
PS-01 @package schema v0 = strict System Field Format kind=package
PS-02 duplicate/unknown field rejected
PS-03 collection usa count + contiguous 1..N
PS-04 software version opaque string
PS-05 identity platform/architecture orthogonal to runtime requirements
PS-06 integrity inventories esterni usano lo stesso System Field Format
PS-07 resource reference strutturata via field prefix
PS-08 command argv-based, no shell string
PS-09 capability = name + contract + compatibility version
PS-10 requirements mandatory
PS-11 environment ordered operation collection
PS-12 absolute host paths absent from descriptor
```
