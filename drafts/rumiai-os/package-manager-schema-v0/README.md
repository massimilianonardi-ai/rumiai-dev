# RumiAI package manager — `@package` schema v0

Data: 2026-08-30

Stato: **design decision — schema concreto v0 fissato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-package-descriptor/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-state-model/README.md
drafts/rumiai-os/package-manager-platform-vocabulary-v0/README.md
drafts/rumiai-os/package-manager-capability-contracts-v0/README.md
```

---

# 1. Top-level

```text
schema          required scalar
identity        required table
release         required table
integrity       required table
state           optional table
interface       required table
requirements    optional ordered array-of-table
environment     optional ordered array-of-table
```

```toml
schema = 1
```

Unknown structural key nello schema v0 è errore.

---

# 2. Logical identifiers

```text
logical-id = [a-z][a-z0-9-]*
```

Usato per:

```text
dependency slot
file/directory/command resource id
capability name
capability resource key
```

Lowercase canonico; ID unico nel proprio namespace.

---

# 3. Identity

```toml
[identity]
name = "netbeans"
version = "26"
revision = 1
platform = "any"
architecture = "any"
display-name = "NetBeans 26"
```

Required:

```text
name
version                  non-empty upstream opaque string
revision                 positive integer
platform                 any | linux | macos | windows
architecture             any | arm64 | x86_64
display-name             non-empty UTF-8 human-readable string
```

I campi canonici devono concordare con:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

`platform`/`architecture` descrivono esclusivamente vincoli propri del contenuto della Package Instance.

Runtime/interpreti/SDK necessari, inclusi Java/JDK/JRE/Python, sono requirements/capability e non platform token.

`any-any` è la forma canonica per contenuto realmente OS/CPU-independent dopo Physical Platform Validation.

---

# 4. Release

```toml
[release]
release-order = 123
```

Positive integer monotono nella stessa provider/package family; non identity e non comparabile fra family differenti.

---

# 5. Integrity

```toml
[integrity]
method = 1
algorithm = "sha256"
```

Required:

```text
integrity.root
integrity.run-default
```

Ogni tree contiene:

```text
files            non-negative integer
directories      positive integer including root
links            non-negative integer
manifest-digest  digest string
records          canonical multiline literal string
```

Record v0:

```text
D<TAB><mode><TAB><relative-path>
<digest><TAB>F<TAB><mode><TAB><relative-path>
<digest-target><TAB>L<TAB><relative-path><TAB><relative-target>
```

Esempio TOML illustrativo:

```toml
[integrity.root]
files = 1
directories = 2
links = 0
manifest-digest = "..."
records = '''
D\t0500\t.
D\t0500\t./bin
abc...\tF\t0500\t./bin/tool
'''
```

Nel file reale i separator fra campi sono TAB reali; `\t` sopra è solo visualizzazione documentale.

Canonical rules:

```text
records contiene una riga per entry
LF canonico fra record
LF finale obbligatorio
nessuna riga vuota extra
record in canonical order
counts concordano con record e tree fisico
manifest-digest = digest del blocco records canonico decodificato
```

La grammatica pathname/escaping canonica appartiene a `integrity.method`.

---

# 6. State

`[state]` optional.

Assenza:

```text
nessuna State Instance propria
nessun runtime mapping
nessuna state reference nel package environment
```

Presenza:

```toml
[state]
compatibility-version = 1
scope = "shared"
```

Scope:

```text
shared
platform
architecture
platform-architecture
```

Mappings:

```toml
[[state.mappings]]
path = "etc"
area = "conf"
```

Area:

```text
conf data home cache log run tmp
```

Mapping rules:

```text
canonical relative path
no leading slash
no ..
unique
no ancestor/descendant overlap
root/<path> = validated relative symlink to ../run/<path>
run-default/<path> exists
```

State platform/architecture qualification è indipendente dalla Package Instance identity e descrive i vincoli dello state.

---

# 7. Interface files/directories

```toml
[[interface.files]]
id = "launcher"
path = "bin/netbeans"

[[interface.directories]]
id = "home"
path = "."
```

`path` è relativo a `root/`; `.` è ammesso per root stesso.

Physical target e type devono concordare con l'integrity tree.

---

# 8. Structured references

Self:

```toml
{ source = "self", resource-type = "file", resource = "launcher" }
```

Dependency:

```toml
{ source = "dependency", slot = "jdk", resource-type = "directory", resource = "home" }
```

State:

```toml
{ source = "state", area = "home" }
```

Literal:

```toml
{ source = "literal", value = "-jar" }
```

`resource-type`:

```text
file directory command
```

Le reference non sono mini-language string.

---

# 9. Commands

```toml
[[interface.commands]]
id = "netbeans"
executable = { source = "self", resource-type = "file", resource = "launcher" }
args = []
```

Executable v0:

```text
self executable file resource
dependency command resource
```

No literal host executable pathname.

Args = ordered array di structured reference; ogni elemento materializza esattamente un argv element, mai una shell command string.

Command-specific `environment` può usare le stesse operation package-level.

---

# 10. Capability provides

Ogni provide include capability contract version e compatibility version:

```toml
[[interface.provides]]
capability = "java-runtime"
contract = 1
version = "21"
```

Required:

```text
capability    known capability logical-id
contract      positive known contract version
version       canonical compatibility version secondo contract
```

Resource mapping:

```toml
[[interface.provides.resources]]
key = "command"
resource-type = "command"
resource = "java"
```

Il registry `(capability, contract)` definisce:

```text
compatibility version scheme
required/optional resource keys
resource type per key
contract semantics
```

Provider non può ridefinire il contract.

---

# 11. Requirements

Tutti mandatory nel v0.

Capability requirement:

```toml
[[requirements]]
slot = "jdk"
target = "capability"
capability = "java-development-kit"
contract = 1
constraint = ">=17 <22"
```

Required:

```text
slot
target = capability
capability
contract
constraint
```

Package requirement:

```toml
[[requirements]]
slot = "engine"
target = "package"
package = "specific-engine"
```

Optional exact upstream version:

```toml
version = "1.4"
```

No generic software-version range v0.

---

# 12. Capability constraint grammar

```text
constraint  = comparator *( SP comparator )
comparator  = operator version
operator    = = | > | >= | < | <=
version     = token valido secondo (capability, contract)
```

Esempi:

```text
=8
>=17 <22
>=3.11 <3.14
```

No OR, !=, wildcard, caret, tilde, provider name, implicit latest.

---

# 13. Environment Specification

Ordered operation list:

```toml
[[environment]]
name = "JAVA_HOME"
operation = "set"
type = "path"
value = { source = "dependency", slot = "jdk", resource-type = "directory", resource = "home" }

[[environment]]
name = "PATH"
operation = "prepend"
type = "path-list"
value = { source = "dependency", slot = "jdk", resource-type = "directory", resource = "bin" }
```

Operations:

```text
set
set-if-unset
unset
prepend
append
```

Types:

```text
scalar
path
path-list
```

Rules:

```text
unset => no value/type
prepend/append => path-list
set/set-if-unset => scalar|path|path-list
absolute host path literal forbidden
no variable expansion during descriptor parse
```

Environment variable name:

```text
[A-Za-z_][A-Za-z0-9_]*
```

---

# 14. Environment precedence

Dal meno al più specifico:

```text
1 inherited/sanitized Host Base Environment
2 RumiAI Base Environment
3 Resolved Integration Profile environment
4 Package Environment Specification
5 Command-specific environment overlay
6 explicit invocation override
```

Una package private dependency può quindi sostituire `JAVA_HOME`/prepend `PATH` senza modificare il profile pubblico.

---

# 15. Required/optional summary

```text
schema                         required
identity                       required
release                        required
integrity                      required
state                          optional
interface                      required
requirements                   optional
package environment            optional

interface.files                optional
interface.directories          optional
interface.commands             optional
interface.provides             optional
```

Un `interface.provides` capability richiede sempre:

```text
capability + contract + version
```

Un capability requirement richiede sempre:

```text
capability + contract + constraint
```

---

# 16. Validation order

```text
1 TOML parse
2 schema
3 structural fields/types
4 logical ID grammar/uniqueness
5 pathname identity agreement
6 platform vocabulary validation
7 integrity syntax + physical verification
8 state mappings
9 interface physical resources
10 capability registry/contract validation
11 requirements/constraint validation
12 environment/command references
13 cross-reference validation
14 Physical Platform Validation
```

Parsing, semantic validation, physical verification e dependency resolution restano fasi distinte.

---

# 17. Error classes

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

# 18. Invarianti

```text
PS-01 schema v0 strict + typed
PS-02 logical internal ID lowercase ASCII
PS-03 software version opaque string
PS-04 platform/architecture descrivono il contenuto, non runtime requirements
PS-05 any-any rappresenta contenuto realmente OS/CPU-independent
PS-06 release-order family-local positive integer
PS-07 state absent => no own State Instance
PS-08 resource references by namespace+id
PS-09 command creates argv, never shell string
PS-10 requirements v0 mandatory
PS-11 capability identity = name + contract
PS-12 compatibility version != capability contract version
PS-13 capability constraint is simple comparator intersection
PS-14 package requirement has no generic upstream version range
PS-15 environment ordered operation list
PS-16 PATH semantic path-list, platform separator materialized later
PS-17 absolute host path absent from @package
PS-18 integrity records = canonical multiline line block
PS-19 parser/validation/resolution separate
```

---

# 19. Reference descriptors

Gli esempi architetturali sono in:

```text
drafts/rumiai-os/package-manager-schema-v0/reference-descriptors.md
```
