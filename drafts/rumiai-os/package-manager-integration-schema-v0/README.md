# RumiAI package manager — Desired / Resolved Integration State schema v0

Data: 2026-08-30

Stato: **design decision — SCF persistence schema v0 fissato**

Desired e Resolved state usano RumiAI System Configuration Field Format v0 con dot notation.

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

```text
kind	profile_desired
schema	1
profile	default
selectors.count	0
command_bindings.count	0
environment.count	0
```

`profile` usa logical-id v0.

---

# 3. Package selector

```text
selectors.1.id	netbeans
selectors.1.target	package
selectors.1.package	netbeans
selectors.1.selection	newest
```

Optional exact upstream:

```text
selectors.1.version	26
```

---

# 4. Capability selector

```text
selectors.1.id	default-java
selectors.1.target	capability
selectors.1.capability	java-runtime
selectors.1.contract	1
selectors.1.constraint	>=17
selectors.1.selection	newest
selectors.1.providers.count	1
selectors.1.providers.1	temurin
selectors.1.allow_other_providers	true
```

Capability identity = name + contract.

---

# 5. Pin

```text
selectors.1.id	jdk
selectors.1.target	capability
selectors.1.capability	java-development-kit
selectors.1.contract	1
selectors.1.constraint	=21
selectors.1.pin	temurin@21.0.8+9@r1@linux-arm64
```

Pin non fa fallback.

Nel v0 pin è mutuamente esclusivo con provider preference/fallback selection fields.

---

# 6. Public command binding

Package source:

```text
command_bindings.1.id	netbeans-command
command_bindings.1.name	netbeans
command_bindings.1.selector	netbeans
command_bindings.1.source	package
command_bindings.1.command	netbeans
```

Capability source:

```text
command_bindings.1.id	java-command
command_bindings.1.name	java
command_bindings.1.selector	default-java
command_bindings.1.source	capability
command_bindings.1.resource_key	command
```

`@platforms` resta reserved sotto `bin/`.

---

# 7. Cross-platform vs native binding

Package Instance `any-any` produce normalmente binding cross-platform:

```text
RUMIAI_ROOT/bin/<name>
```

Package Instance native produce binding:

```text
RUMIAI_ROOT/bin/@platforms/<native-platform>-<architecture>/<name>
```

Runtime requirements non determinano questo scope.

---

# 8. Native specialization

Same-name collision è ammessa soltanto con relazione esplicita `specializes`.

Esempio:

```text
command_bindings.2.specializes	java-command
```

Collisioni non dichiarate:

```text
PUBLIC_BINDING_CONFLICT
```

---

# 9. Desired public environment

```text
environment.1.name	JAVA_HOME
environment.1.operation	set
environment.1.type	path
environment.1.selector	default-java
environment.1.source	capability
environment.1.resource_key	home
```

Nessun absolute RUMIAI_ROOT path persistito.

---

# 10. Desired example

```text
kind	profile_desired
schema	1
profile	default
selectors.count	2
selectors.1.id	default-java
selectors.1.target	capability
selectors.1.capability	java-runtime
selectors.1.contract	1
selectors.1.constraint	>=17
selectors.1.selection	newest
selectors.1.providers.count	1
selectors.1.providers.1	temurin
selectors.1.allow_other_providers	true
selectors.2.id	netbeans
selectors.2.target	package
selectors.2.package	netbeans
selectors.2.selection	newest
command_bindings.count	2
command_bindings.1.id	java-default-command
command_bindings.1.name	java
command_bindings.1.selector	default-java
command_bindings.1.source	capability
command_bindings.1.resource_key	command
command_bindings.2.id	netbeans-command
command_bindings.2.name	netbeans
command_bindings.2.selector	netbeans
command_bindings.2.source	package
command_bindings.2.command	netbeans
environment.count	0
```

NetBeans continua a usare la propria private `jdk` dependency definita nel suo `@package`.

---

# 11. Resolution Snapshot

```text
kind	profile_resolved
schema	1
generation	17
profile	default
reason	explicit-update
created	2026-08-30T13:00:00+02:00
selectors.count	0
graphs.count	0
dependencies.count	0
command_bindings.count	0
environment.count	0
```

`created` è stringa ISO-8601.

---

# 12. Resolved selector

Package:

```text
selectors.1.id	netbeans
selectors.1.target	package
selectors.1.package	netbeans@26@r1@any-any
```

Capability:

```text
selectors.1.id	default-java
selectors.1.target	capability
selectors.1.capability	java-runtime
selectors.1.contract	1
selectors.1.satisfied_version	21
selectors.1.package	temurin@21.0.8+9@r1@linux-arm64
```

---

# 13. Resolved dependency graph

```text
graphs.count	1
graphs.1.id	netbeans-graph
graphs.1.root_package	netbeans@26@r1@any-any

dependencies.count	1
dependencies.1.graph	netbeans-graph
dependencies.1.consumer	netbeans@26@r1@any-any
dependencies.1.slot	jdk
dependencies.1.target	capability
dependencies.1.capability	java-development-kit
dependencies.1.contract	1
dependencies.1.constraint	>=17 <22
dependencies.1.provider	temurin@21.0.8+9@r1@linux-arm64
dependencies.1.satisfied_version	21
```

Nessun edge resolved contiene `latest`, fallback o provider dinamico.

Per molte proprietà dello stesso elemento/namespace si usa query namespace in singola scansione, non repeated full-file lookup.

---

# 14. Resolved command binding

```text
command_bindings.1.id	netbeans-command
command_bindings.1.name	netbeans
command_bindings.1.package	netbeans@26@r1@any-any
command_bindings.1.command	netbeans
command_bindings.1.graph	netbeans-graph
command_bindings.1.state	netbeans@s1
```

Capability public binding viene dereferenziato all'exact package/command.

---

# 15. Resolved environment

```text
environment.1.name	JAVA_HOME
environment.1.operation	set
environment.1.type	path
environment.1.package	temurin@21.0.8+9@r1@linux-arm64
environment.1.resource_type	directory
environment.1.resource	home
```

Al launch la reference exact/relocatable viene trasformata nel current absolute RUMIAI_ROOT pathname.

---

# 16. State binding

State Instance exact:

```text
<pkg-name>[@<platform>-<architecture>]@sN
```

Il qualifier usa host/state scope quando necessario e resta indipendente dalla Package Instance platform.

---

# 17. Active generation

Fuori dallo snapshot immutabile esiste `active`, SCF:

```text
kind	active
schema	1
generation	17
```

Atomic replace attiva una generation già completamente validata.

---

# 18. Dot-notation rules

Collection:

```text
<prefix>.count	N
<prefix>.1....
...
<prefix>.N....
```

Arbitrary IDs restano values.

Esempio corretto:

```text
selectors.1.id	default-java
```

Non:

```text
selectors.default-java....
```

---

# 19. Validation

Desired:

```text
SCF framing/dot-notation/kind/schema
profile/id grammar
count + contiguous indices
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
SCF framing/dot-notation/kind/schema/generation
count + contiguous indices
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

# 20. Invarianti

```text
IS-01 selector != virtual package
IS-02 Desired dynamic, Resolved exact
IS-03 Desired/Resolved/active usano SCF dot-notation
IS-04 collection usa count + contiguous indices
IS-05 arbitrary IDs restano values
IS-06 capability identity = name+contract
IS-07 pin non fa fallback
IS-08 private dependency non diventa public
IS-09 resolved graph non contiene dynamic selection
IS-10 resolved env non contiene absolute paths
IS-11 Package Instance any-any può risolvere runtime native
IS-12 active pointer è separato e atomico
IS-13 provenance non influenza launch
IS-14 bulk/tabular data non viene modellato come SCF
```
