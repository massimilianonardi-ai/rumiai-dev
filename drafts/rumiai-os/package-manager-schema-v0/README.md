# RumiAI package manager — `@package` schema v0

Data: 2026-08-30

Stato: **design draft — schema concreto v0 formalizzato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-package-descriptor/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-state-model/README.md
```

Obiettivo: fissare i campi e le regole di validazione del descriptor `@package` senza ancora implementare il parser/package manager.

---

# 1. Top-level

Sezioni v0:

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

Top-level TOML:

```toml
schema = 1
```

Nel medesimo `schema = 1`, una key strutturale sconosciuta è errore.

---

# 2. Identificatori logici

Per i namespace interni v0 si usa una grammatica conservativa ASCII:

```text
logical-id = [a-z][a-z0-9-]*
```

Si applica a:

```text
dependency slot
resource id
command id
capability name
```

Gli identificatori sono case-sensitive ma canonici lowercase.

Namespace distinti possono riusare lo stesso token senza collisione:

```text
resource:java
command:java
capability:java-runtime
```

All'interno dello stesso namespace un ID deve essere unico.

Il package `name` continua a seguire la grammatica pathname/package già fissata e non viene ristretto retroattivamente da `logical-id`.

---

# 3. `identity`

Required:

```toml
[identity]
name = "netbeans"
version = "26"
revision = 1
platform = "jvm"
architecture = "any"
display-name = "NetBeans 26"
```

Regole:

```text
name             required string, canonical package name
version          required non-empty string, upstream semantic opaque
revision         required positive integer
platform         required canonical platform token
architecture     required canonical architecture token
display-name     required non-empty human-readable UTF-8 string
```

I primi cinque campi canonici devono concordare con il package pathname secondo le regole version-token già fissate.

---

# 4. `release`

Required:

```toml
[release]
release-order = 123
```

`release-order`:

```text
positive integer
monotono nella stessa logical provider/package family
non identity
non confrontabile fra famiglie differenti
```

A parità di release-order, il resolver può usare la RumiAI `revision` più alta quando la policy chiede la più recente revision della medesima release.

---

# 5. `integrity`

Required:

```toml
[integrity]
method = 1
algorithm = "sha256"
```

Sub-table required:

```text
integrity.root
integrity.run-default
```

Entrambe contengono:

```text
files            non-negative integer
directories      positive integer, include root entry
links            non-negative integer
manifest-digest  digest string secondo algorithm
records          ordered array of canonical record strings
```

Esempio:

```toml
[integrity.root]
files = 1
directories = 2
links = 0
manifest-digest = "..."
records = [
  "D\t0500\t.",
  "D\t0500\t./bin",
  "abc...\tF\t0500\t./bin/tool",
]
```

Validation:

```text
record count/type concorda con counts
records in canonical order
manifest digest concorda con canonical LF-joined records
physical tree concorda con records
```

La grammatica pathname/escaping canonica appartiene a `integrity.method`.

---

# 6. `state`

`state` è optional.

Assenza di `[state]` significa:

```text
Package Instance non richiede State Instance propria
nessun runtime mapping package-local
nessuna state reference ammessa nel suo Environment Specification
```

Quando presente:

```toml
[state]
compatibility-version = 2
scope = "shared"
```

Required fields:

```text
compatibility-version  positive integer
scope                  enum
```

Scope enum:

```text
shared
platform
architecture
platform-architecture
```

Mappings optional ordered array:

```toml
[[state.mappings]]
path = "etc"
area = "conf"
```

Area enum:

```text
conf
data
home
cache
log
run
tmp
```

Regole mapping:

```text
path relativo canonico
nessun leading slash
nessun `..`
nessuna coppia di mapping ancestor/descendant
ogni path unico
root/<path> deve essere safe relative symlink verso ../run/<path>
run-default/<path> deve esistere come default physical counterpart
```

Una Package Instance può avere `[state]` senza mappings quando usa State Instance soltanto tramite environment/launch references.

---

# 7. `interface.files`

File resource optional:

```toml
[[interface.files]]
id = "launcher"
path = "bin/netbeans"
```

Required:

```text
id      logical-id unico nel file resource namespace
path    canonical relative pathname sotto root/
```

La physical target deve esistere ed essere regular file nel tree integro.

Un file resource non implica executable semantics.

---

# 8. `interface.directories`

Directory resource optional:

```toml
[[interface.directories]]
id = "home"
path = "."

[[interface.directories]]
id = "bin"
path = "bin"
```

Required:

```text
id      logical-id unico nel directory namespace
path    canonical relative pathname sotto root/
```

`.` è ammesso esclusivamente per rappresentare `root/` stesso.

La physical target deve esistere ed essere directory nel tree integro.

---

# 9. Resource reference v0

Le reference non sono stringhe composite.

Forme semantiche:

## self resource

```toml
{ source = "self", resource-type = "file", resource = "launcher" }
```

## dependency resource

```toml
{ source = "dependency", slot = "jdk", resource-type = "directory", resource = "home" }
```

## state reference

```toml
{ source = "state", area = "home" }
```

## literal

```toml
{ source = "literal", value = "-J-Xmx2g" }
```

`resource-type` enum:

```text
file
directory
command
```

Validation è context-sensitive: non tutte le source/type sono ammesse in ogni campo.

---

# 10. `interface.commands`

Command resource optional, ID unico:

```toml
[[interface.commands]]
id = "netbeans"
executable = { source = "self", resource-type = "file", resource = "launcher" }
args = []
```

Required:

```text
id          logical-id
executable  executable reference
```

Optional:

```text
args         ordered array of argument reference table
environment  ordered array of environment operation table
```

Executable reference v0 può puntare a:

```text
self file resource con executable mode
dependency command resource
```

Non può essere literal host pathname.

Ogni argomento è strutturato, per esempio:

```toml
args = [
  { source = "literal", value = "-jar" },
  { source = "self", resource-type = "file", resource = "app-jar" },
]
```

Al materialize ogni elemento produce esattamente un argv element; non viene costruita una shell command string.

---

# 11. `interface.provides`

Ogni provide:

```toml
[[interface.provides]]
capability = "java-runtime"
version = "21"
```

Required:

```text
capability  logical-id
version     non-empty capability-version string
```

Resource mapping:

```toml
[[interface.provides.resources]]
key = "command"
resource-type = "command"
resource = "java"

[[interface.provides.resources]]
key = "home"
resource-type = "directory"
resource = "home"
```

`key` è definita dal capability contract, non dal provider.

Validation capability contract verifica:

```text
version scheme
required resource keys
optional resource keys
resource type per key
```

Un provider non può inventare una semantica diversa per una key standard dello stesso capability contract.

---

# 12. `requirements`

Ogni requirement è mandatory nel v0.

## capability requirement

```toml
[[requirements]]
slot = "jdk"
target = "capability"
capability = "java-development-kit"
constraint = ">=17 <22"
```

Required:

```text
slot
 target = capability
capability
constraint
```

## package requirement

```toml
[[requirements]]
slot = "engine"
target = "package"
package = "specific-engine"
```

Optional per package target:

```text
version = exact upstream version string
```

Nel v0 un package-target requirement NON supporta range generici sulla software version upstream.

Se `version` manca, qualsiasi release della logical package family può essere candidata e la Selection Policy/resolver decide la release concreta tramite release-order.

Dependency slot ID deve essere unico nel package.

---

# 13. Constraint grammar v0

Capability constraints v0 rappresentano **solo intersezioni** di comparator.

Grammar concettuale:

```text
constraint  = comparator *( SP comparator )
comparator  = operator version
operator    = "=" / ">" / ">=" / "<" / "<="
version     = token valido secondo il capability version scheme
```

Esempi:

```text
=8
>=17 <22
>=3.11 <3.14
```

Non esistono nel v0:

```text
OR
!=
wildcard
caret
tilde
implicit latest
provider name dentro constraint
```

La validità e comparazione di `version` appartengono al capability contract.

---

# 14. `environment` come sequenza ordinata

L'Environment Specification package-level è un **array ordinato di operazioni**, non una map per variable name.

Questo permette più operazioni sulla stessa variabile, soprattutto `PATH`.

Esempio:

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

Field:

```text
name       required environment variable name
operation  required enum
type       required salvo unset
value      required salvo unset
```

Operation enum:

```text
set
set-if-unset
unset
prepend
append
```

Type enum:

```text
scalar
path
path-list
```

Rules:

```text
unset: nessun value/type richiesto
prepend/append: type deve essere path-list
set/set-if-unset: scalar, path o path-list
```

Un `path` reference deve risolversi a un singolo pathname.

Un `path-list` operation inserisce uno o più pathname come elementi logici; il platform adapter decide il separator della process environment.

---

# 15. Environment variable names

Grammatica portabile v0:

```text
[A-Za-z_][A-Za-z0-9_]*
```

Nel medesimo Environment Specification non possono esistere due nomi che collidono case-insensitively quando il target platform tratta l'environment in modo case-insensitive.

La validazione fisica/platform completa resta platform-specific.

---

# 16. Environment value source rules

`scalar`:

```text
literal ammesso
resource path può essere convertito a scalar pathname solo se semanticamente richiesto
```

`path`:

```text
self file/directory resource
dependency file/directory resource
state area/path
```

`path-list`:

```text
self directory resource
dependency directory resource
state directory/path
```

Un host absolute pathname literal non è ammesso in `@package`.

Environment variable expansion tipo:

```text
$HOME
%PATH%
${VAR}
```

non viene eseguita dal parser descriptor.

---

# 17. Environment precedence v0

La composizione dell'Execution Environment segue dal layer meno specifico al più specifico:

```text
1. inherited/sanitized Host Base Environment
2. RumiAI Base Environment
3. Resolved Integration Profile environment
4. Package Environment Specification
5. Command-specific environment overlay
6. explicit invocation override
```

Ogni layer opera sul risultato del precedente.

Quindi una Package Instance che fa:

```text
set JAVA_HOME = dependency:jdk.directory:home
```

sostituisce eventuale `JAVA_HOME` ereditato dall'host/profile per quel processo senza modificare il profile globale.

`prepend PATH` del package inserisce la dependency privata davanti al PATH già composto.

---

# 18. Command-specific environment

Ogni `interface.commands` può contenere una lista `environment` con la stessa struttura delle operazioni package-level.

Precedence:

```text
package environment
        ↓
command environment
```

Non è consentito shell/eval/script come operation.

---

# 19. Required/optional summary

```text
schema                         required
identity                       required
release                        required
integrity                      required
state                          optional
interface                      required, può essere vuota solo se il package non espone risorse pubblicabili/usabili
requirements                   optional; se presenti tutti mandatory
environment                    optional

identity.*                     required
release.release-order          required
integrity.method               required
integrity.algorithm            required
integrity.root                 required
integrity.run-default          required
state.compatibility-version    required se state presente
state.scope                    required se state presente
state.mappings                 optional
interface.files                optional
interface.directories          optional
interface.commands             optional
interface.provides             optional
```

---

# 20. Validation order

Un descriptor viene validato per fasi:

```text
1. TOML parse
2. schema version
3. structural schema / required fields / types
4. identifier grammar + uniqueness
5. pathname identity agreement
6. integrity metadata syntax
7. root/run-default physical integrity
8. state contract + writable mapping validation
9. Package Interface physical target validation
10. capability contract validation
11. Requirement syntax/slot validation
12. Environment/command reference validation
13. cross-reference validation
14. admission/platform physical validation already required dal package lifecycle
```

Parsing puro non risolve dependency né State Instance concrete.

---

# 21. Error classes v0

Classi logiche candidate da rendere stabili nell'implementazione:

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

Queste classi descrivono il dominio; messaggi e codici numerici concreti verranno definiti nell'API/CLI implementation contract.

---

# 22. Invarianti schema v0

```text
PS-01 schema v0 è strict e typed
PS-02 logical identifiers interni sono lowercase ASCII logical-id
PS-03 software version resta stringa opaca
PS-04 release-order è positive integer per family ranking
PS-05 state section assente => nessuna State Instance propria
PS-06 resources sono referenziate per namespace+id, non path host
PS-07 command materializza argv, mai shell command string
PS-08 requirements v0 sono mandatory
PS-09 capability constraint v0 è intersezione di comparator semplici
PS-10 package requirement non usa generic upstream version range
PS-11 environment è ordered operation list
PS-12 PATH è semanticamente path-list, separator platform-specific
PS-13 host environment può essere ereditato ma package-specific set/unset può dominarlo
PS-14 absolute host path non vive nel descriptor
PS-15 parser, semantic validation, physical validation e resolution sono fasi distinte
```

---

# 23. Prossimo passo

Lo schema è abbastanza concreto da scrivere **descriptor di riferimento completi** e stressarli senza implementazione:

```text
JDK provider
NetBeans consumer
Python runtime provider
Python application consumer
Pulsar Electron/self-contained
```

Il test deve cercare campi/primitives mancanti e non ottimizzare la sintassi per estetica.

Se i descriptor completi passano senza introdurre nuovi concetti, il passo successivo sarà fissare lo schema del Desired/Resolved Integration State con lo stesso livello di precisione.