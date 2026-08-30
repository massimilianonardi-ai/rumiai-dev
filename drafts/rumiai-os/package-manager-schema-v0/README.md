# RumiAI package manager — `@package` schema v0

Data: 2026-08-30

Stato: **design decision — SCF dot-notation schema v0 fissato**

Questa specifica mantiene invariato il modello logico e fissa la serializzazione `@package` nel System Configuration Field Format v0.

---

# 1. Base

Required:

```text
kind	package
schema	1
```

Unknown field non previsto dallo schema v0 è errore.

Duplicate field-name è errore.

Scalar/namespace collision è errore.

---

# 2. Logical identifiers

Logical ID values:

```text
[a-z][a-z0-9-]*
```

per dependency slot, resource ID, command ID, capability name/resource key.

Questi identificatori restano field-value.

---

# 3. Identity

Required:

```text
identity.name	netbeans
identity.version	26
identity.revision	1
identity.platform	any
identity.architecture	any
identity.display_name	NetBeans 26
```

Platform:

```text
any linux macos windows
```

Architecture:

```text
any arm64 x86_64
```

Pathname identity e descriptor identity devono coincidere.

---

# 4. Release

```text
release.order	123
```

Positive integer, family-local, non identity.

---

# 5. Integrity metadata

Required:

```text
integrity.method	1
integrity.algorithm	sha256
integrity.root.inventory	@integrity-root.tsv
integrity.root.files	1
integrity.root.directories	2
integrity.root.links	0
integrity.root.manifest_digest	...
integrity.run_default.inventory	@integrity-run-default.tsv
integrity.run_default.files	0
integrity.run_default.directories	1
integrity.run_default.links	0
integrity.run_default.manifest_digest	...
```

I due inventory sono System Tabular Data esterni con header esatto:

```text
type	mode	digest	target	path
```

Inventory filename v0 deve coincidere coi nomi canonici fissati.

---

# 6. State

Presence marker required:

```text
state.present	true|false
```

Se true:

```text
state.compatibility_version	1
state.scope	shared
state.mappings.count	1
state.mappings.1.path	etc
state.mappings.1.area	conf
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

Se false, gli altri field `state.*` sono vietati.

---

# 7. Package Interface resources

Collection obbligatorie anche quando vuote:

```text
interface.files.count	N
interface.directories.count	N
interface.commands.count	N
interface.provides.count	N
```

File:

```text
interface.files.1.id	launcher
interface.files.1.path	bin/netbeans
```

Directory:

```text
interface.directories.1.id	home
interface.directories.1.path	.
```

---

# 8. Structured reference pattern

Self:

```text
<prefix>.source	self
<prefix>.resource_type	file
<prefix>.resource	launcher
```

Dependency:

```text
<prefix>.source	dependency
<prefix>.slot	jdk
<prefix>.resource_type	directory
<prefix>.resource	home
```

State:

```text
<prefix>.source	state
<prefix>.area	home
```

Literal:

```text
<prefix>.source	literal
<prefix>.value	-jar
```

Non esiste mini-language persistita nei value.

---

# 9. Command

```text
interface.commands.1.id	netbeans
interface.commands.1.executable.source	self
interface.commands.1.executable.resource_type	file
interface.commands.1.executable.resource	launcher
interface.commands.1.args.count	0
```

Executable può essere self executable file o dependency command resource.

Args è ordered array; ogni indice produce un argv element.

Literal argv contenente TAB/CR/LF/NUL è non rappresentabile nel v0.

---

# 10. Capability provide

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

Capability identity = name + contract.

---

# 11. Requirements

Capability target:

```text
requirements.count	1
requirements.1.slot	jdk
requirements.1.target	capability
requirements.1.capability	java-development-kit
requirements.1.contract	1
requirements.1.constraint	>=17 <22
```

Package target:

```text
requirements.1.slot	engine
requirements.1.target	package
requirements.1.package	specific-engine
```

Optional exact upstream `requirements.<i>.version` per package-target; no generic upstream range v0.

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

# 14. Field-name rules

Named segment:

```text
[A-Za-z_][A-Za-z0-9_]*
```

Index segment:

```text
[1-9][0-9]*
```

Arbitrary IDs stay in values.

Esempio corretto:

```text
requirements.1.id	default-java
```

Non:

```text
requirements.default-java...
```

---

# 15. Environment precedence

```text
1 inherited/sanitized Host Base Environment
2 RumiAI Base Environment
3 Resolved Integration Profile environment
4 Package Environment Specification
5 Command-specific environment overlay
6 explicit invocation override
```

---

# 16. Validation order

```text
1 SCF UTF-8/framing parse
2 dot-notation grammar + duplicate/scalar-namespace validation
3 kind/schema
4 required/unknown field validation
5 count + contiguous indices
6 logical IDs
7 pathname identity agreement
8 platform vocabulary
9 integrity metadata syntax
10 integrity TSV header/rows + physical tree verification
11 state mappings
12 Package Interface physical target validation
13 capability contract validation
14 requirements
15 environment/reference validation
16 cross-reference validation
17 Physical Platform Validation
```

---

# 17. Error classes

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

# 18. Invarianti

```text
PS-01 @package = strict SCF kind=package
PS-02 dot notation rappresenta namespace/object/array
PS-03 duplicate/unknown/scalar-namespace collision rejected
PS-04 array = count + contiguous 1..N
PS-05 software version opaque string
PS-06 identity platform/architecture orthogonal to runtime requirements
PS-07 integrity inventories esterni sono TSV tabellari con header
PS-08 resource reference strutturata via dotted namespace
PS-09 command argv-based, no shell string
PS-10 capability = name + contract + compatibility version
PS-11 requirements mandatory
PS-12 environment ordered operation array
PS-13 absolute host paths absent from descriptor
PS-14 arbitrary IDs remain values
```
