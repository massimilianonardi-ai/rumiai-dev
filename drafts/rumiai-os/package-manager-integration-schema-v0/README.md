# RumiAI package manager — Desired / Resolved Integration State schema v0

Data: 2026-08-30

Stato: **design decision — System Field Format persistence schema v0 fissato**

Desired e Resolved state usano RumiAI System Field Format v0.

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

Header:

```text
kind	profile_desired
schema	1
profile	default
selector_count	0
command_binding_count	0
environment_count	0
```

`profile` usa logical-id v0.

---

# 3. Package selector

```text
selector_1_id	netbeans
selector_1_target	package
selector_1_package	netbeans
selector_1_selection	newest
```

Optional exact upstream:

```text
selector_1_version	26
```

---

# 4. Capability selector

```text
selector_1_id	default-java
selector_1_target	capability
selector_1_capability	java-runtime
selector_1_contract	1
selector_1_constraint	>=17
selector_1_selection	newest
selector_1_provider_count	1
selector_1_provider_1	temurin
selector_1_allow_other_providers	true
```

Capability identity = name + contract.

---

# 5. Pin

```text
selector_1_id	jdk
selector_1_target	capability
selector_1_capability	java-development-kit
selector_1_contract	1
selector_1_constraint	=21
selector_1_pin	temurin@21.0.8+9@r1@linux-arm64
```

Pin non fa fallback.

Nel v0 pin è mutuamente esclusivo con provider preference/fallback selection fields.

---

# 6. Public command binding

Package source:

```text
command_binding_1_id	netbeans-command
command_binding_1_name	netbeans
command_binding_1_selector	netbeans
command_binding_1_source	package
command_binding_1_command	netbeans
```

Capability source:

```text
command_binding_1_id	java-command
command_binding_1_name	java
command_binding_1_selector	default-java
command_binding_1_source	capability
command_binding_1_resource_key	command
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

---

# 8. Native specialization

Same-name collision è ammessa soltanto con relazione esplicita `specializes` fra native e cross-platform binding correlati.

Esempio field opzionale:

```text
command_binding_2_specializes	java-command
```

Collisioni non dichiarate producono:

```text
PUBLIC_BINDING_CONFLICT
```

---

# 9. Desired public environment

```text
environment_1_name	JAVA_HOME
environment_1_operation	set
environment_1_type	path
environment_1_selector	default-java
environment_1_source	capability
environment_1_resource_key	home
```

Nessun absolute RUMIAI_ROOT path persistito.

---

# 10. Desired example

```text
kind	profile_desired
schema	1
profile	default
selector_count	2
selector_1_id	default-java
selector_1_target	capability
selector_1_capability	java-runtime
selector_1_contract	1
selector_1_constraint	>=17
selector_1_selection	newest
selector_1_provider_count	1
selector_1_provider_1	temurin
selector_1_allow_other_providers	true
selector_2_id	netbeans
selector_2_target	package
selector_2_package	netbeans
selector_2_selection	newest
command_binding_count	2
command_binding_1_id	java-default-command
command_binding_1_name	java
command_binding_1_selector	default-java
command_binding_1_source	capability
command_binding_1_resource_key	command
command_binding_2_id	netbeans-command
command_binding_2_name	netbeans
command_binding_2_selector	netbeans
command_binding_2_source	package
command_binding_2_command	netbeans
environment_count	0
```

NetBeans continua a usare la propria private `jdk` dependency definita nel suo `@package`.

---

# 11. Resolution Snapshot

Header/base:

```text
kind	profile_resolved
schema	1
generation	17
profile	default
reason	explicit-update
created	2026-08-30T13:00:00+02:00
selector_count	0
graph_count	0
dependency_count	0
command_binding_count	0
environment_count	0
```

`created` è stringa ISO-8601.

---

# 12. Resolved selector

Package:

```text
selector_1_id	netbeans
selector_1_target	package
selector_1_package	netbeans@26@r1@any-any
```

Capability:

```text
selector_1_id	default-java
selector_1_target	capability
selector_1_capability	java-runtime
selector_1_contract	1
selector_1_satisfied_version	21
selector_1_package	temurin@21.0.8+9@r1@linux-arm64
```

---

# 13. Resolved dependency graph

```text
graph_count	1
graph_1_id	netbeans-graph
graph_1_root_package	netbeans@26@r1@any-any

dependency_count	1
dependency_1_graph	netbeans-graph
dependency_1_consumer	netbeans@26@r1@any-any
dependency_1_slot	jdk
dependency_1_target	capability
dependency_1_capability	java-development-kit
dependency_1_contract	1
dependency_1_constraint	>=17 <22
dependency_1_provider	temurin@21.0.8+9@r1@linux-arm64
dependency_1_satisfied_version	21
```

Nessun edge resolved contiene `latest`, fallback o provider dinamico.

Collection grandi devono essere lette tramite streaming/per-prefix bootstrap, non repeated `rumi_file_get`.

---

# 14. Resolved command binding

```text
command_binding_1_id	netbeans-command
command_binding_1_name	netbeans
command_binding_1_package	netbeans@26@r1@any-any
command_binding_1_command	netbeans
command_binding_1_graph	netbeans-graph
command_binding_1_state	netbeans@s1
```

Capability public binding viene dereferenziato all'exact package/command.

---

# 15. Resolved environment

```text
environment_1_name	JAVA_HOME
environment_1_operation	set
environment_1_type	path
environment_1_package	temurin@21.0.8+9@r1@linux-arm64
environment_1_resource_type	directory
environment_1_resource	home
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

Fuori dallo snapshot immutabile esiste `active`, anch'esso System Field Format:

```text
kind	active
schema	1
generation	17
```

Lo switch atomico del file attiva una generation già completamente validata.

---

# 18. Validation

Desired:

```text
System Field Format/kind/schema
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
System Field Format/kind/schema/generation
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

# 19. Invarianti

```text
IS-01 selector != virtual package
IS-02 Desired dynamic, Resolved exact
IS-03 Desired/Resolved/active usano System Field Format
IS-04 collection usa count + contiguous indices
IS-05 capability identity = name+contract
IS-06 pin non fa fallback
IS-07 private dependency non diventa public
IS-08 resolved graph non contiene dynamic selection
IS-09 resolved env non contiene absolute paths
IS-10 Package Instance any-any può risolvere runtime native
IS-11 active pointer è separato e atomico
IS-12 provenance non influenza launch
IS-13 large resolved collection usa streaming bootstrap
```
