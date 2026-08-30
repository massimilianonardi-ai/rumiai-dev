# RumiAI package manager — Local package and command layout

Data: 2026-08-30

Stato: **design decision — layout locale v0 fissato**

Questo documento riguarda esclusivamente il lato locale del confine già fissato:

```text
software già prodotto/normalizzato
        ↓
Package Instance locale
        ↓
integrazione / utilizzo / rimozione
```

Discovery remota, `rumiai-store`, download e build restano fuori scope.

---

# 1. Un solo `pkg/`

Tutte le Package Instance convivono sotto:

```text
RUMIAI_ROOT/pkg/
```

Esempio:

```text
pkg/
├── temurin@21.0.8+9@r1@linux-arm64/
├── temurin@21.0.8+9@r1@macos-arm64/
├── netbeans@26@r1@any-any/
├── java-app@1.0@r1@any-any/
└── native-tool@2.0@r1@linux-x86_64/
```

`platform` e `architecture` descrivono soltanto vincoli propri del contenuto della Package Instance.

Java/JDK/JRE/Python e altri runtime/interpreti/SDK necessari sono Execution Requirements e non compaiono come platform token.

---

# 2. `bin/` fisica e namespace `@platforms`

`RUMIAI_ROOT/bin/` resta una directory fisica.

Binding di Package Instance con contenuto `platform = any` vivono direttamente in:

```text
RUMIAI_ROOT/bin/
```

Binding platform-specific vivono in:

```text
RUMIAI_ROOT/bin/@platforms/<platform>-<architecture>/
```

Esempio:

```text
bin/
├── @platforms/
│   ├── linux-arm64/
│   │   ├── java
│   │   └── ffmpeg
│   └── macos-arm64/
│       ├── java
│       └── ffmpeg
├── netbeans
└── java-app
```

`@platforms` è reserved sotto `bin/` e non può essere un command binding ordinario.

La directory platform-specific viene creata on demand.

---

# 3. Bootstrap PATH

Il bootstrap determina il current native host target e usa:

```text
RUMIAI_ROOT/bin/@platforms/<current-native-platform>-<current-architecture>
RUMIAI_ROOT/bin
<inherited PATH>
```

La specialization native ha precedence sulla variante `platform = any`.

Questa precedence non è un conflict resolver generale: same-name base/specialization deve essere dichiarato dal resolved integration state; collisioni non correlate restano errori.

Esempio generico:

```text
bin/tool
    Package Instance any-any

bin/@platforms/linux-arm64/tool
    specialization linux-arm64
```

Su Linux ARM64 vince la specialization; sugli altri host resta disponibile la variante `any-any` se compatibile e risolta.

---

# 4. Nessuna generalizzazione preventiva di `@platforms`

Il pattern può essere applicato in futuro ad altre aree soltanto se un requisito reale lo richiede.

State Instance ha già una propria qualificazione platform/architecture indipendente e non richiede un albero globale preventivo.

---

# 5. Package Instance pathname

Forma fissata:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

Esempi:

```text
temurin@21.0.8+9@r1@linux-arm64
netbeans@26@r1@any-any
java-app@1.0@r1@any-any
native-tool@2.0-beta-3@r2@linux-x86_64
```

Significato:

```text
name          normalized logical package identity
version-token canonical reversible upstream-version representation
revision      RumiAI packaging revision
platform      any | linux | macos | windows
architecture  any | arm64 | x86_64
```

`@` è il separatore strutturale riservato.

---

# 6. Package name e revision

Package name candidato/fissato come forma conservativa:

```text
[a-z0-9][a-z0-9._-]*
```

Lowercase canonico per evitare collisioni case-insensitive.

Revision:

```text
@r1@
@r2@
...
```

intero positivo base 10.

---

# 7. Version token

La software version upstream resta semanticamente opaca.

Il pathname usa un token:

```text
filesystem-safe
canonical
reversible
senza @
case-insensitive-safe
```

Versioni semplici possono restare letterali, per esempio:

```text
21.0.8+9
8u462
1.130.0
2.0-beta-3
```

Per versioni problematiche resta candidato un encoding tipo:

```text
b32-<base32-lowercase-utf8-senza-padding>
```

Il requisito normativo è canonicalità + round-trip; l'algoritmo finale di encoding resta dettaglio tecnico separato.

---

# 8. Parsing deterministico

Split canonico sui tre `@` strutturali produce:

```text
1 name
2 version-token
3 r<revision>
4 <platform>-<architecture>
```

Platform/architecture sono token controllati dal vocabulary v0.

Il parsing non dipende da `@package`.

---

# 9. Path identity vs descriptor identity

Ridondanza intenzionale:

```text
identity(pathname) == identity(@package)
```

Una divergenza è integrity error, non precedence decision.

---

# 10. Anti-ghost inventory

Ogni immediate child di `pkg/` deve essere classificato:

```text
HEALTHY
RECOVERABLE
IDENTITY_MISMATCH
UNKNOWN
```

`RECOVERABLE` significa pathname parseable ma descriptor mancante/corrotto.

Una Package Instance recuperabile resta visibile e rimovibile/riparabile, ma non viene usata automaticamente per nuove resolution finché i metadata non sono verificati.

Invariante:

> Nessun contenuto fisicamente presente sotto `pkg/` può diventare semanticamente invisibile perché manca un indice o descriptor.

`pkg/` è physical truth della presenza locale; indici/cache sono rebuildable.

---

# 11. `bin/` è derivato

```text
pkg/
    physical truth delle Package Instance

var/pkg/.../generations
    authoritative resolved integration state

bin/
    derived Execution View / command stubs
```

La perdita/corruzione di `bin/` è riparabile dalla active generation.

Uno stale stub non prova che una Package Instance sia installata o attiva.

---

# 12. Cross-platform content + native runtime requirement

Esempio:

```text
netbeans@26@r1@any-any
    requires java-development-kit
```

Su Linux ARM64:

```text
jdk -> temurin@...@linux-arm64
```

Su macOS ARM64:

```text
jdk -> temurin@...@macos-arm64
```

La stessa Package Instance `any-any` può quindi essere usata con provider runtime native differenti senza cambiare identity.

---

# 13. Native content

Se il contenuto stesso richiede una piattaforma/CPU, l'identity la rappresenta anche se esiste contemporaneamente un runtime requirement.

Esempio:

```text
Java app + required JNI Linux ARM64

Package Instance:
    linux-arm64

Requirement:
    java-runtime
```

---

# 14. Invarianti

```text
LL-01 tutte le Package Instance locali vivono sotto un unico pkg/
LL-02 Package Instance pathname = <name>@<version-token>@r<revision>@<platform>-<architecture>
LL-03 platform v0 = any, linux, macos, windows
LL-04 architecture v0 = any, arm64, x86_64
LL-05 JVM/JRE/JDK/Python non sono platform token
LL-06 any-any rappresenta contenuto OS/CPU-independent fisicamente validato
LL-07 bin/@platforms usa native host platform-architecture
LL-08 native specialization precede cross-platform binding ma richiede relazione esplicita
LL-09 @platforms è reserved sotto bin/
LL-10 pathname identity e descriptor identity devono concordare
LL-11 ogni immediate child di pkg/ è classificabile; niente package ghost
LL-12 pkg/ è physical truth; bin/ è derived view
```
