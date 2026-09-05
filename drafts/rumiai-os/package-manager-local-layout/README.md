# RumiAI package manager — Local package and command layout

Data: 2026-08-30

Stato corrente: **Superseded as current design by `decisions/rumiai-os/2026-09-05-package-manager-current-and-run-model.md`**  
Stato storico al 2026-08-30: **design decision — layout locale v0 fissato**

> **Nota di supersession:** il contenuto seguente è conservato come lineage/input storico. In particolare `bin/@platforms`, `bin/` direttamente nel `PATH`, la precedente grammatica obbligatoria delle Package Instance, il version-token e lo stato di integrazione a generations non appartengono più al runtime/package-manager corrente. Il layout executable autorevole è `bin/sys*` / `bin/ext*`; per `pkg` valgono le decisioni Accepted successive.

Questo documento riguardava esclusivamente il lato locale del confine progettato al 2026-08-30:

```text
software già prodotto/normalizzato
        ↓
Package Instance locale
        ↓
integrazione / utilizzo / rimozione
```

Discovery remota, `rumiai-store`, download e build erano fuori scope del design qui conservato.

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

`platform` e `architecture` descrivono soltanto vincoli propri del contenuto.

Java/JDK/JRE/Python e altri runtime/interpreti/SDK necessari sono Execution Requirements.

---

# 2. `bin/` fisica e namespace `@platforms`

`RUMIAI_ROOT/bin/` resta directory fisica.

Binding `platform = any`:

```text
RUMIAI_ROOT/bin/
```

Binding platform-specific:

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

`@platforms` è reserved sotto `bin/`.

---

# 3. Bootstrap PATH

Il bootstrap determina current native host target e usa:

```text
RUMIAI_ROOT/bin/@platforms/<current-platform>-<current-architecture>
RUMIAI_ROOT/bin
<inherited PATH>
```

Native specialization ha precedence sulla variante `any` soltanto quando la relazione è dichiarata nel resolved integration state.

---

# 4. Nessuna generalizzazione preventiva di `@platforms`

Il pattern può essere applicato altrove soltanto se emerge un requisito reale.

State Instance mantiene qualificazione platform/architecture indipendente.

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
version-token canonical reversible upstream-version encoding
revision      RumiAI packaging revision
platform      any | linux | macos | windows
architecture  any | arm64 | x86_64
```

`@` è separatore strutturale riservato.

---

# 6. Package name e revision

Package name:

```text
[a-z0-9][a-z0-9._-]*
```

Lowercase canonico.

Revision:

```text
@r1@
@r2@
...
```

intero positivo base 10.

---

# 7. Version token — decisione v0

La software version upstream resta semanticamente opaca.

Il token usa canonical byte-wise percent encoding definito in:

```text
drafts/rumiai-os/package-manager-version-token-v0/README.md
```

Safe literal set:

```text
[a-z0-9._+-]
```

Ogni altro byte UTF-8 viene encoded:

```text
%hh
```

con hex lowercase.

Esempi:

```text
21.0.8+9      -> 21.0.8+9
8u462         -> 8u462
2.0-beta-3    -> 2.0-beta-3
1.0-RC1       -> 1.0-%52%431
1@2           -> 1%402
100%          -> 100%25
é              -> %c3%a9
```

Vengono sempre encoded, fra gli altri:

```text
uppercase ASCII
%
@
space
/
\\
Windows-reserved punctuation
non-ASCII UTF-8 bytes
```

Il token è ASCII, reversible, canonical e case-insensitive-safe.

Safe byte percent-encoded non è canonico; uppercase hex non è canonico.

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

Il parser pathname non dipende da `@package`.

Version-token viene validato/decoded secondo Version Token v0 e deve round-trip con:

```text
@package identity.version
```

---

# 9. Path identity vs descriptor identity

Ridondanza intenzionale:

```text
identity(pathname) == identity(@package)
```

Una divergenza è integrity error.

---

# 10. Anti-ghost inventory

Ogni immediate child di `pkg/` deve classificarsi:

```text
HEALTHY
RECOVERABLE
IDENTITY_MISMATCH
UNKNOWN
```

`RECOVERABLE` = pathname parseable ma descriptor mancante/corrotto.

Una Package Instance recuperabile resta visibile/rimovibile/riparabile ma non entra automaticamente in nuove resolution.

`pkg/` è physical truth; indici/cache sono rebuildable.

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

Perdita/corruzione `bin/` è riparabile dalla active generation.

---

# 12. Cross-platform content + native runtime requirement

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

Stessa Package Instance `any-any`, provider runtime nativo differente.

---

# 13. Native content

Se il contenuto stesso richiede platform/CPU, l'identity la rappresenta anche con runtime requirement.

```text
Java app + required JNI Linux ARM64

Package Instance:
    linux-arm64

Requirement:
    java-runtime
```

---

# 14. Invarianti storici

```text
LL-01 tutte le Package Instance locali vivono sotto un unico pkg/
LL-02 pathname = <name>@<version-token>@r<revision>@<platform>-<architecture>
LL-03 platform v0 = any, linux, macos, windows
LL-04 architecture v0 = any, arm64, x86_64
LL-05 JVM/JRE/JDK/Python non sono platform token
LL-06 any-any = contenuto OS/CPU-independent fisicamente validato
LL-07 bin/@platforms usa native host platform-architecture
LL-08 native specialization precede cross-platform binding solo con relazione esplicita
LL-09 @platforms è reserved sotto bin/
LL-10 version-token usa canonical percent encoding v0
LL-11 pathname identity e descriptor identity devono concordare
LL-12 ogni immediate child di pkg/ è classificabile
LL-13 pkg/ è physical truth; bin/ è derived view
```

Questi identificatori sono conservati esclusivamente come riferimento al design storico del 2026-08-30; non costituiscono l'elenco degli invarianti correnti di `pkg`.
