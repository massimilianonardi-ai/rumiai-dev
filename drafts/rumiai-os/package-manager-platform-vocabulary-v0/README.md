# RumiAI package manager — Execution Platform vocabulary v0

Data: 2026-08-30

Stato: **design decision — vocabulary v0 fissato**

Questo documento fissa il significato dei campi:

```text
platform
architecture
```

usati dalla Package Instance identity.

---

# 1. Principio centrale

`platform` e `architecture` descrivono **soltanto i vincoli propri del contenuto della Package Instance**.

Non descrivono il runtime, interprete, SDK o altro software necessario per eseguirla.

Quindi:

```text
JVM / JRE / JDK / Python
    != platform

java-runtime / java-development-kit / python-runtime
    = Execution Requirements / capability
```

Regola fissata:

> La platform/architecture della Package Instance descrive i vincoli del contenuto della Package Instance; i vincoli introdotti da software esterno necessario all'esecuzione sono rappresentati esclusivamente tramite Execution Requirements.

---

# 2. Execution Platform Identifier

Forma canonica:

```text
<platform>-<architecture>
```

Esempi:

```text
linux-arm64
linux-x86_64
macos-arm64
macos-x86_64
windows-x86_64
any-any
linux-any
any-arm64
```

I due token restano campi distinti in `@package`.

---

# 3. Platform vocabulary v0

Token v0:

```text
any
linux
macos
windows
```

Semantica:

```text
any
    il contenuto della Package Instance non dipende da un particolare OS

linux
    il contenuto richiede Linux

macos
    il contenuto richiede macOS

windows
    il contenuto richiede Windows
```

Non sono platform token:

```text
jvm
jre
jdk
java
python
node
wasm runtime
```

Tali tecnologie, quando necessarie, appartengono al dependency/capability model.

---

# 4. Architecture vocabulary v0

Token v0:

```text
any
arm64
x86_64
```

Alias host/vendor come:

```text
aarch64
amd64
x64
```

vengono normalizzati ai token RumiAI canonici e non entrano nel pathname Package Instance.

Semantica:

```text
any
    il contenuto non dipende da una particolare CPU architecture

arm64
    il contenuto richiede ARM64

x86_64
    il contenuto richiede x86-64
```

---

# 5. `any-any`

Una Package Instance realmente indipendente sia dall'OS sia dalla CPU usa:

```text
platform = any
architecture = any
```

quindi:

```text
<name>@<version-token>@r<revision>@any-any
```

Esempio concettuale:

```text
netbeans@26@r1@any-any
```

se il contenuto NetBeans normalizzato non contiene vincoli nativi propri.

La necessità di un JDK viene dichiarata separatamente:

```text
requires java-development-kit
```

Il fatto che una Package Instance contenga JAR, bytecode Python o altro formato interpretabile non è di per sé sufficiente per dichiarare `any-any`: il producer deve aver validato l'assenza di vincoli OS/architecture propri del contenuto.

---

# 6. Specializzazioni parziali

Sono ammesse anche:

```text
linux-any
any-arm64
```

`linux-any` significa che il contenuto è Linux-specific ma architecture-independent.

`any-arm64` significa che il contenuto è OS-independent ma richiede ARM64.

Queste identità devono corrispondere a un vincolo reale e fisicamente validato, non essere usate come scorciatoia per dipendenze esterne.

---

# 7. Runtime requirement separato dalla Package Instance platform

Una Package Instance Java pura può essere:

```text
my-java-app@1.0@r1@any-any
```

con:

```text
requires:
    java-runtime contract 1 >=17 <22
```

Su Linux ARM64 il resolver può scegliere:

```text
temurin@...@linux-arm64
```

Su macOS ARM64:

```text
temurin@...@macos-arm64
```

La Package Instance consumer resta la stessa `any-any`; cambia il provider concreto del Requirement.

Lo stesso principio vale per Python:

```text
my-python-app@...@any-any
    requires python-runtime
```

`python` non entra nella Package Instance identity.

---

# 8. Contenuto con dipendenza nativa propria

Se il contenuto della Package Instance include un vincolo nativo proprio, la Package Instance non è `any-any`.

Esempio Java:

```text
root/
├── app.jar
└── native/libfoo.so
```

Se `libfoo.so` è obbligatoria e Linux ARM64:

```text
platform = linux
architecture = arm64
```

La Package Instance può contemporaneamente dichiarare:

```text
requires java-runtime
```

I due fatti restano ortogonali:

```text
Package content constraint = linux-arm64
Execution Requirement      = java-runtime
```

Analogo per Python con native extension obbligatorie.

---

# 9. Physical Platform Validation

`any` non significa compatibilità teorica dedotta dal formato dell'artifact.

Una Package Instance `any-any`, `linux-any` o `any-arm64` è promossa soltanto dopo le Physical Platform Validation richieste sulle Reference Installation previste dal packaging RumiAI.

Il producer è responsabile di verificare che il contenuto non nasconda vincoli ulteriori non rappresentati dall'identity e dai Requirements.

---

# 10. State Instance qualifier

La State Instance continua ad avere identity indipendente dalla Package Instance platform:

```text
<pkg-name>[@<platform>-<architecture>]@sN
```

Esempio:

```text
Package Instance:
    netbeans@26@r1@any-any
```

può usare:

```text
netbeans@s2
```

se lo state è realmente condivisibile, oppure:

```text
netbeans@linux-any@s2
```

se lo state dipende dal sistema operativo.

Il qualifier dello state descrive i vincoli dello state, non copia automaticamente quelli della Package Instance.

---

# 11. `bin/@platforms`

Il namespace:

```text
RUMIAI_ROOT/bin/@platforms/<current-native-platform>-<current-architecture>/
```

usa il current native host target, per esempio:

```text
linux-arm64
macos-arm64
windows-x86_64
```

I command binding di Package Instance `any-any` normalmente vanno nel namespace cross-platform:

```text
RUMIAI_ROOT/bin/
```

Una specialization native esplicita può prevalere secondo il modello di integrazione già fissato.

Non esistono namespace:

```text
@platforms/jvm-any
@platforms/python-any
```

perché `jvm` e `python` non sono platform.

---

# 12. Extensibility

Nuovi OS platform o architecture richiedono aggiunta esplicita al vocabulary/versioned contract.

Candidate future:

```text
freebsd
windows-arm64
riscv64
```

L'aggiunta non modifica il principio fondamentale:

```text
execution technology/runtime != Package Instance platform
```

---

# 13. Invarianti

```text
EP-01 Execution Platform Identifier = <platform>-<architecture>
EP-02 platform v0 = any, linux, macos, windows
EP-03 architecture v0 = any, arm64, x86_64
EP-04 platform/architecture descrivono soltanto vincoli propri del contenuto Package Instance
EP-05 JVM/JRE/JDK/Python non sono platform token
EP-06 runtime/interpreter/SDK necessari sono rappresentati tramite Execution Requirements/capability
EP-07 any-any è la forma canonica per contenuto realmente OS/CPU independent
EP-08 linux-any e any-arm64 sono ammessi quando rappresentano vincoli reali del contenuto
EP-09 artifact con native content obbligatorio deve esporre il relativo native platform/architecture anche se richiede Java/Python
EP-10 State Instance platform/architecture resta indipendente e descrive i vincoli dello state
EP-11 bin/@platforms usa esclusivamente il current native host platform-architecture
EP-12 `any` deriva da Physical Platform Validation, non da inferenza sul formato dell'artifact
```
