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

# 1. Execution Platform Identifier

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
jvm-any
python-any
```

I due token restano campi distinti in `@package`.

---

# 2. `platform` include due categorie

Il campo `platform` può identificare:

```text
native host platform
execution domain
```

Native platform v0:

```text
linux
macos
windows
```

Execution domain v0:

```text
jvm
python
```

Un execution domain significa che la Package Instance è realmente indipendente dall'OS/CPU entro il contratto di quel domain e viene eseguita tramite una dependency runtime concreta risolta per l'host corrente.

---

# 3. Architecture vocabulary

Token v0:

```text
arm64
x86_64
any
```

Alias host/vendor come:

```text
aarch64
amd64
x64
```

vengono normalizzati ai token RumiAI canonici e non entrano nel pathname Package Instance.

---

# 4. `any`

`architecture = any` significa che la Package Instance non dipende dalla CPU architecture nel proprio execution platform/domain.

Esempi validi:

```text
linux-any
jvm-any
python-any
```

`linux-any` può rappresentare per esempio software Linux realmente architecture-independent.

Per execution domain v0:

```text
jvm
python
```

la forma normale è:

```text
jvm-any
python-any
```

Se un artifact JVM/Python contiene JNI/native extension o altra dipendenza obbligatoria da OS/architecture, non viene promosso artificialmente come `jvm-any`/`python-any`: viene classificato per la native execution platform appropriata.

---

# 5. Nessun `platform = any` nella Package Instance v0

La Package Instance deve avere un execution platform/domain concreto.

Non viene introdotto nel v0:

```text
any-any
any-arm64
```

come Package Instance target.

Il token `any` può comparire come placeholder platform nella **State Instance qualifier** quando lo state dipende soltanto dall'architecture:

```text
pkg@any-arm64@sN
```

Questo non crea una Package Instance platform `any`.

---

# 6. Native vs execution-domain admission

Una Package Instance native viene ammessa per il proprio exact Execution Platform Identifier tramite Physical Platform Validation.

Una Package Instance execution-domain (`jvm-any`, `python-any`) è ammessa soltanto quando il package producer ha verificato che il software non richiede facilities native fuori dal domain contract e ha completato la Physical Platform Validation richiesta sulle reference installations supportate.

Il suffix `any` non è un'affermazione teorica dedotta dal formato del file; è una proprietà ammessa dopo validation.

---

# 7. Runtime dependency di un domain package

Un package:

```text
netbeans@...@jvm-any
```

può risolvere al launch una dependency native:

```text
jdk -> temurin@...@linux-arm64
```

su Linux ARM64 e una diversa Package Instance native su macOS ARM64.

La Package Instance cross-domain resta la stessa; il Resolved Dependency Graph è specifico dell'execution environment/platform concreta.

---

# 8. State scope usa il native host target

Per una Package Instance `jvm-any` o `python-any`, uno state può comunque essere platform-dependent.

Esempio:

```text
Package Instance:
    foo@...@jvm-any

state scope:
    platform
```

Su Linux ARM64 produce:

```text
foo@linux-any@sN
```

Su macOS ARM64:

```text
foo@macos-any@sN
```

Quindi il qualifier State Instance usa il **native execution host**, non necessariamente `platform` della Package Instance.

---

# 9. `bin/@platforms`

Il namespace:

```text
RUMIAI_ROOT/bin/@platforms/<platform>-<architecture>/
```

usa esclusivamente il current **native host Execution Platform Identifier**:

```text
linux-arm64
macos-arm64
windows-x86_64
```

Non vengono create directory:

```text
@platforms/jvm-any
@platforms/python-any
```

I command binding di domain package vanno nel namespace cross-platform `bin/`, salvo una specialization native esplicita già definita nel modello di integrazione.

---

# 10. Extensibility

Nuovi native platform, architecture o execution domain richiedono aggiunta esplicita al vocabulary/versioned contract.

Non vengono accettati token arbitrari non conosciuti dallo schema corrente.

Candidate future, non v0:

```text
node
wasm
posix
windows-arm64
riscv64
```

La loro aggiunta non modifica il significato dei token v0 esistenti.

---

# 11. Invarianti

```text
EP-01 Execution Platform Identifier = <platform>-<architecture>
EP-02 native platform v0 = linux, macos, windows
EP-03 execution domain v0 = jvm, python
EP-04 architecture v0 = arm64, x86_64, any
EP-05 aarch64/amd64/x64 sono alias input, non identity token
EP-06 execution-domain package normalmente usa architecture any
EP-07 artifact con native requirement obbligatorio non viene classificato domain-any
EP-08 platform=any non è Package Instance target v0
EP-09 State Instance può usare any-<arch> per architecture-only scope
EP-10 bin/@platforms usa native host platform-architecture
EP-11 domain portability deriva da Physical Platform Validation, non da inferenza
```
