# RumiAI package manager — capability contracts v0

Data: 2026-08-30

Stato: **design decision — capability registry v0 fissato per reference cases**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-schema-v0/README.md
drafts/rumiai-os/package-manager-integration-schema-v0/README.md
```

Questo documento fissa il principio che una Execution Capability ha due versioni distinte:

```text
contract version
compatibility version
```

---

# 1. Capability identity

Una capability reference v0 contiene:

```text
name
contract
```

Esempio:

```text
name = java-runtime
contract = 1
```

`contract` è un intero positivo che versiona la **forma e semantica del capability contract**.

Non è la versione del runtime/software fornito.

---

# 2. Compatibility version

Il provider dichiara inoltre una compatibility version:

```text
java-runtime
contract = 1
version = 21
```

Il consumer richiede:

```text
java-runtime
contract = 1
constraint = >=17 <22
```

Quindi:

```text
contract
    versione del protocollo/contratto RumiAI

version / constraint
    livello di compatibilità funzionale del provider
```

---

# 3. Matching v0

Nel v0 un Requirement capability può essere soddisfatto soltanto da un provider con:

```text
same capability name
same contract version
compatible capability version
```

Non esiste conversione o negoziazione automatica fra contract version differenti.

Un futuro contract `2` può definire esplicitamente eventuale backward compatibility, ma il v0 non la presume.

---

# 4. Contract evolution

Una modifica backward-compatible che non cambia la semantica obbligatoria del contract può restare nello stesso `contract` quando riguarda soltanto chiarimenti/documentazione o nuove informazioni opzionali ignorabili secondo il contract.

Una modifica che cambia:

```text
required resource key
resource type di una key
version scheme
semantica fondamentale della capability
```

richiede una nuova contract version.

---

# 5. `java-runtime` contract 1

Identity:

```text
name = java-runtime
contract = 1
```

Compatibility version scheme:

```text
positive decimal integer
canonical no leading zero
ordering numerico crescente
```

Esempi:

```text
8
11
17
21
```

Required resource keys:

```text
command   -> command resource
home      -> directory resource
bin       -> directory resource
```

Semantica:

```text
command
    Java application launcher compatibile con la feature release dichiarata

home
    JAVA_HOME semantic root del runtime

bin
    directory che contiene i command runtime da anteporre eventualmente a PATH
```

---

# 6. `java-development-kit` contract 1

Identity:

```text
name = java-development-kit
contract = 1
```

Compatibility version scheme:

```text
same feature-release integer scheme di java-runtime contract 1
```

Required resource keys:

```text
java    -> command resource
javac   -> command resource
home    -> directory resource
bin     -> directory resource
```

Semantica:

```text
java
    runtime launcher

javac
    Java compiler

home
    JDK/JAVA_HOME semantic root

bin
    executable directory
```

Un provider JDK che soddisfa anche `java-runtime` deve dichiarare **esplicitamente entrambi i provides**.

Il v0 non introduce capability inheritance implicita:

```text
java-development-kit does NOT automatically imply java-runtime
```

Questo mantiene il grafo/contratto dichiarativo e verificabile.

---

# 7. `python-runtime` contract 1

Identity:

```text
name = python-runtime
contract = 1
```

Compatibility version scheme:

```text
<major>.<minor>
```

con:

```text
major/minor = non-negative decimal integer
canonical no unnecessary leading zero
ordering lexicografico numerico per tuple (major, minor)
```

Esempi:

```text
3.11
3.12
3.13
```

Required resource keys:

```text
command   -> command resource
home      -> directory resource
bin       -> directory resource
```

Semantica:

```text
command
    Python interpreter launcher della compatibility version dichiarata

home
    runtime installation semantic root

bin
    runtime command directory
```

Il contract non impone `PYTHONHOME`; è il consumer/package Environment Specification a decidere se usare o meno quella variabile.

---

# 8. Serialization changes required

Ogni `provides` v0 deve contenere:

```toml
capability = "java-runtime"
contract = 1
version = "21"
```

Ogni capability `requirement` deve contenere:

```toml
capability = "java-development-kit"
contract = 1
constraint = ">=17 <22"
```

Ogni Desired Integration capability selector deve contenere:

```toml
capability = "java-runtime"
contract = 1
constraint = ">=17"
```

Ogni resolved selector/dependency edge conserva il `contract` exact usato.

---

# 9. Registry authority

I capability contract standard RumiAI sono definiti/versionati dal progetto RumiAI, non dai singoli provider package.

Un provider può dichiarare di implementare un contract noto, ma non ridefinirne localmente la semantica.

Un package non può usare una capability name/contract sconosciuta al registry v0, salvo futura estensione esplicita per contract namespaced/custom.

Il v0 non introduce ancora capability custom non registrate.

---

# 10. Contract validation

Admission/descriptor validation verifica:

```text
capability name conosciuta
contract version conosciuta
compatibility version canonicale secondo contract
required resource key presenti
nessuna duplicate key
resource type compatibile con contract
resource target esistente nella Package Interface
```

Requirement validation verifica:

```text
capability/contract conosciuti
constraint parser compatibile col version scheme del contract
```

Resolution verifica:

```text
provider capability name/contract exact match
provider version soddisfa constraint
```

---

# 11. Invarianti

```text
CC-01 capability identity = name + contract version
CC-02 capability compatibility version != contract version
CC-03 resolver v0 richiede exact contract version match
CC-04 version scheme appartiene al capability contract
CC-05 resource key/type appartengono al capability contract
CC-06 provider non ridefinisce il contract
CC-07 java-runtime c1 version scheme = positive feature integer
CC-08 java-development-kit c1 version scheme = positive feature integer
CC-09 python-runtime c1 version scheme = numeric major.minor
CC-10 capability inheritance implicita non esiste nel v0
CC-11 provides/requirements/selectors persistono contract = positive integer
CC-12 capability custom non registrate sono fuori dal v0
```
