# RumiAI package manager — Package Admission v0

Data: 2026-08-29

Stato: **draft di design — proposta da discutere prima della promozione a specifica normativa**

Questo documento formalizza il primo confine del nuovo package manager RumiAI OS: il problema di acquisire o produrre i binari resta fuori scope; il package manager comincia quando esiste già un payload eseguibile candidato all'inclusione nel `rumiai-store`.

---

## 1. Confine del problema

Il software richiesto dall'utente o dal sistema può essere ottenuto in modi molto diversi:

```text
binario precompilato scaricato da una fonte esterna
sorgenti scaricati e compilati localmente
sorgenti già locali compilati localmente
altro processo di produzione
```

La discovery, il download dei binari, il download dei sorgenti, la scelta della toolchain e la compilazione sono problemi importanti, ma appartengono all'altro lato del confine e verranno ripresi separatamente.

Il package manager v0 assume invece:

```text
HO GIÀ UN PAYLOAD ESEGUIBILE
            ↓
è ammissibile nel rumiai-store?
            ↓
dove e come lo rappresento?
            ↓
quali dipendenze runtime possiede?
            ↓
come potrà essere integrato, usato e rimosso?
```

Storicamente la separazione concettuale resta coerente con:

```text
src/
    software/sorgenti nel dominio della produzione

pkg/
    software già prodotto e gestito da RumiAI
```

Il significato fisico definitivo di queste directory non è ancora deciso.

---

## 2. Principio centrale: RumiAI Execution Closure

Un package eseguibile può essere ammesso nel `rumiai-store` solo se la sua intera closure runtime è conoscibile e controllabile.

La **RumiAI Execution Closure** di una Package Instance è l'insieme di tutto ciò che è necessario affinché il suo software possa essere eseguito correttamente.

Nel v0 ogni elemento necessario all'esecuzione DEVE appartenere a uno e un solo insieme ammesso:

```text
1. file contenuti nella Package Instance stessa

2. altre Package Instance RumiAI dichiarate come Execution Dependency

3. elementi esplicitamente ammessi dal Platform Baseline della piattaforma
```

Formalmente:

```text
ExecutionClosure(P)
    ⊆
Content(P)
∪ ResolvedPackageDependencies(P)
∪ PlatformBaseline(P.platform)
```

Qualunque requisito runtime esterno a questi insiemi rende il package **non ammissibile nel v0**.

Esempi inizialmente NON ammessi:

```text
"deve essere installato libfoo con apt"
"richiede una libreria presente in /usr/local/lib"
"richiede Homebrew"
"richiede una DLL installata globalmente da un MSI"
"al primo avvio scarica il runtime mancante"
"funziona solo se l'utente ha già configurato una variabile host non dichiarata"
```

Il fatto che RumiAI sia tecnicamente in grado di rendere funzionante un software non implica che quel software sia ammissibile nel `rumiai-store`.

---

# 3. Execution Platform Identifier

## 3.1 Significato

Ogni Package Instance DEVE avere un **Execution Platform Identifier**.

L'identificatore descrive il dominio minimo di esecuzione richiesto dal payload, non il formato dell'archive da cui proviene e non necessariamente la piattaforma fisica del computer.

Esempi di piattaforme native:

```text
linux-arm64
linux-x86_64
macos-arm64
macos-x86_64
windows-x86_64
```

La nomenclatura canonica di OS e architetture verrà specificata separatamente; questi nomi sono esempi del modello.

## 3.2 Piattaforme virtuali / runtime-neutral rispetto all'host

Alcuni payload non dipendono direttamente dall'ABI nativa dell'host, ma da una macchina/runtime portabile.

Il primo caso rilevante è la JVM.

Per bytecode JVM realmente indipendente da OS e architettura si propone:

```text
platform = jvm
```

`jvm` descrive il dominio di esecuzione, non il linguaggio sorgente e non il formato di packaging.

È preferibile a:

```text
java-jar
portable
```

perché:

- un `.jar` è solo un formato/archive e può contenere librerie native;
- bytecode JVM può provenire anche da Kotlin, Scala o altri linguaggi;
- `portable` è troppo generico e non dice quale runtime soddisfa l'esecuzione.

Il modello potrà in futuro essere esteso ad altri domini, ad esempio `wasm-wasi` o altri runtime, ma non vengono definiti nel v0.

## 3.3 Regola JVM v0

Un package può dichiarare:

```text
platform = jvm
```

SOLO se l'intera parte del payload necessaria all'esecuzione è indipendente dall'OS e dall'architettura.

Un package `jvm` DEVE dichiarare come Execution Dependency il runtime Java/JVM richiesto, per esempio concettualmente:

```text
java-runtime >=17 <22
```

La JVM concreta che soddisfa tale dipendenza sarà a sua volta una Package Instance nativa, per esempio:

```text
java-runtime 21 / linux-arm64
java-runtime 21 / macos-arm64
java-runtime 21 / windows-x86_64
```

Quindi la catena diventa:

```text
application / jvm
        ↓ execution dependency
java-runtime / <native-platform>
        ↓
Platform Baseline della piattaforma nativa
```

## 3.4 JAR con componenti native

La presenza dell'estensione `.jar` NON autorizza `platform=jvm`.

Se l'esecuzione richiede JNI, JNA o qualunque `.so`, `.dylib`, `.dll` o altro componente nativo specifico dell'host, la Package Instance DEVE avere la piattaforma nativa concreta.

Esempio:

```text
foo.jar
└── native/libfoo.so   # necessario

platform = linux-x86_64
execution dependency = java-runtime >=17
```

Analogamente:

```text
foo.jar + libfoo.dylib
→ macos-arm64 o macos-x86_64

foo.jar + foo.dll
→ windows-x86_64
```

## 3.5 Artifact multi-platform con native library incluse

Un singolo artifact upstream può includere librerie native per più piattaforme e selezionarle a runtime.

Nel v0 questo NON produce una Package Instance `portable` o `multi`.

RumiAI rappresenta comunque istanze distinte per piattaforma:

```text
foo / 1.0 / linux-x86_64
foo / 1.0 / macos-arm64
foo / 1.0 / windows-x86_64
```

anche se il payload originario fosse lo stesso archive.

La regola mantiene semplice e verificabile la compatibilità di ogni Package Instance.

## 3.6 Componenti native opzionali

Un componente native opzionale che non è necessario alla corretta esecuzione di base non rende automaticamente il package platform-specific.

La distinzione v0 è:

```text
necessario alla Execution Closure
    → determina la piattaforma

opzionale e non richiesto dal contratto della Package Instance
    → non determina la piattaforma
```

Le capability opzionali verranno formalizzate in seguito.

---

# 4. Package Instance

## 4.1 Definizione

Una **Package Instance** è una rappresentazione concreta, immutabile e già eseguibile di una specifica versione/revisione di software, ammessa nel dominio gestito da RumiAI per uno specifico Execution Platform Identifier.

Non è:

- la richiesta dell'utente;
- un range di versioni;
- il source tree;
- la procedura di build;
- la procedura di download;
- l'archive upstream non ancora qualificato;
- lo stato runtime dell'applicazione;
- l'integrazione attiva nell'ambiente.

È il software **già prodotto**, normalizzato e accettato dal package manager.

## 4.2 Identità logica proposta

Nel v0 l'identità logica di una Package Instance deve distinguere almeno:

```text
package name
software version
RumiAI package revision
execution platform
content digest
```

Esempio concettuale:

```text
name      = java-runtime
version   = 21.0.8
revision  = 1
platform  = linux-arm64
digest    = <content digest>
```

`version` identifica la versione del software.

`revision` permette a RumiAI di correggere o modificare il packaging della stessa versione upstream senza fingere che sia una nuova versione del software.

Il digest verifica il contenuto concreto. Due contenuti differenti NON devono essere accettati silenziosamente come la stessa identità logica.

La sintassi finale dell'identificatore e il layout filesystem NON sono ancora definiti.

## 4.3 Immutabilità

Dopo l'ammissione nello store, il contenuto di una Package Instance DEVE essere trattabile come immutabile.

Qualunque modifica necessaria al payload produce una nuova Package Instance/revision, non una mutazione silenziosa di quella esistente.

Questo include l'auto-update del vendor: una Package Instance ammessa NON deve aggiornare autonomamente i propri eseguibili o librerie.

## 4.4 Relocatability

La Package Instance DEVE poter essere collocata in una directory arbitraria gestita da RumiAI senza richiedere pathname assoluti di installazione predefiniti.

NON è ammissibile nel v0 un payload che richieda necessariamente, per esempio:

```text
/opt/vendor/foo
/usr/local/vendor/foo
C:\Program Files\Vendor\Foo
```

salvo che tali pathname siano puramente interni a un ambiente di encapsulation che diventerà oggetto di un modello successivo.

## 4.5 Stato mutabile

Una Package Instance DEVE poter essere eseguita senza usare la propria directory come storage mutabile indispensabile.

Configurazione, dati, cache, log, PID, temporary files e home applicativa devono poter essere:

- esterni alla Package Instance;
- esplicitamente indirizzati verso aree RumiAI;
- oppure non necessari.

Se un software scrive necessariamente nel proprio installation tree e tale comportamento non può essere separato o rediretto, il package non è ammissibile nel v0.

## 4.6 Privilegi e host mutation

Materializzazione, integrazione ordinaria, esecuzione e rimozione di una Package Instance NON devono richiedere:

```text
root
sudo
Administrator
modifica obbligatoria di directory globali host
installazione di package host
```

Il payload non deve auto-installarsi in PATH, `/usr`, `/etc`, registry globale, system library directories o meccanismi analoghi.

L'integrazione è responsabilità di RumiAI.

## 4.7 Offline execution

Una Package Instance ammessa DEVE essere eseguibile offline una volta che le sue Execution Dependency sono già disponibili.

Il first run non può essere usato per:

- scaricare runtime obbligatori;
- recuperare librerie mancanti;
- completare l'installazione del payload.

Network access può naturalmente essere una funzione dell'applicazione durante il suo normale utilizzo; ciò che è vietato è dipendere dalla rete per completare la propria Execution Closure.

---

# 5. Platform Baseline

## 5.1 Definizione

Il **Platform Baseline** è la whitelist minima, esplicita e versionata di primitive/facility esterne al `rumiai-store` che RumiAI considera garantite da una specifica piattaforma nativa supportata.

Non significa:

```text
"tutto quello che normalmente trovo installato su Linux/macOS/Windows"
```

Significa esclusivamente:

```text
"questi precisi elementi fanno parte del contratto host che RumiAI accetta come dipendenza esterna"
```

## 5.2 Proprietà

Un Platform Baseline DEVE essere:

- associato a una piattaforma nativa concreta;
- esplicito;
- documentato;
- versionato;
- sufficientemente stabile da poter essere verificato sui reference host;
- indipendente dal package manager host;
- disponibile senza operazioni di installazione da parte di RumiAI.

## 5.3 Whitelist, non discovery implicita

La presenza accidentale di una libreria sul sistema NON la rende parte del baseline.

Esempio:

```text
/usr/lib/libfoo.so esiste
```

non implica:

```text
libfoo ∈ PlatformBaseline(linux-arm64)
```

Deve essere esplicitamente ammessa dal profilo baseline.

## 5.4 Il baseline è il limite delle dipendenze host

Nel v0 un package nativo può dipendere dall'host solo attraverso il Platform Baseline.

Quindi:

```text
libc / dynamic loader / OS frameworks / system DLL / kernel ABI / altre facility
```

sono utilizzabili solo se la specifica baseline della piattaforma li include esplicitamente.

Questo documento NON decide ancora quali elementi includere nei baseline Linux, macOS e Windows.

In particolare non si assume automaticamente che una specifica glibc, Homebrew library, framework opzionale macOS o runtime Windows appartengano al baseline.

## 5.5 Versione del baseline

La versione del baseline deve essere distinta dall'Execution Platform Identifier.

Esempio concettuale:

```text
platform = macos-arm64
baseline = v0
```

Questo consente di evolvere il contratto host senza cambiare artificialmente il nome della piattaforma.

Un aggiornamento incompatibile del Platform Baseline è un evento di compatibilità esplicito.

## 5.6 Piattaforme virtuali

`jvm` non possiede un baseline host equivalente a `linux-arm64` o `macos-arm64`.

Il runtime JVM NON viene assunto come facility dell'host: deve essere soddisfatto da una Package Instance RumiAI dichiarata come Execution Dependency.

Questa regola evita di dipendere da una Java installata casualmente sulla macchina.

---

# 6. Execution Dependency

## 6.1 Definizione

Una **Execution Dependency** è qualunque requisito necessario all'esecuzione corretta di una Package Instance che non è contenuto nella Package Instance stessa.

Nel v0 ogni Execution Dependency deve essere dichiarata esplicitamente e deve appartenere a una delle due classi:

```text
PACKAGE DEPENDENCY
    soddisfatta da un'altra Package Instance RumiAI

PLATFORM DEPENDENCY
    soddisfatta da un elemento del Platform Baseline
```

Non esiste una terza categoria implicita "presente sul computer".

## 6.2 Package Dependency

Una Package Dependency identifica almeno:

```text
package richiesto
version constraint
```

Esempio concettuale:

```text
pulsar
└── java-runtime >=17 <22
```

Il constraint esprime la compatibilità accettata dal package.

Prima dell'esecuzione concreta deve essere risolto in una Package Instance esatta, per esempio:

```text
java-runtime 21.0.8 revision 1 / linux-arm64
```

Quindi:

```text
constraint
    !=
resolved dependency
```

Il modello di version range e il resolver non vengono ancora specificati.

## 6.3 Platform Dependency

Una Platform Dependency è un requisito verso un elemento esplicitamente elencato nel Platform Baseline applicabile.

Non viene installata, aggiornata o rimossa dal package manager.

Se il requisito non appartiene al baseline, deve essere convertito in una Package Dependency RumiAI oppure il package non è ammissibile.

## 6.4 Dipendenze nascoste vietate

Un package v0 non può possedere dipendenze runtime non dichiarate.

Esempi:

```text
eseguibile linkato a una libreria non inclusa e non baseline
JAR che invoca un comando host non dichiarato
script che presume python/node/java dal PATH host
plugin che richiede una libreria installata globalmente
```

Questi casi devono essere esplicitati come Execution Dependency o rendono il package non ammissibile.

## 6.5 Runtime come Package Dependency

Runtime come Java sono normali Package Dependency.

Questo permette la semantica storicamente importante:

```text
package A → java latest compatibile
package B → java 8
```

senza imporre una sola Java globale.

La futura integration può costruire environment differenti e rendere disponibile la versione risolta corretta per ogni contesto.

## 6.6 Build dependency fuori scope

Una dipendenza necessaria soltanto a produrre i binari NON è una Execution Dependency del package risultante.

Esempi:

```text
compiler
linker
cmake
maven/gradle usati solo in build
source-generation tools
```

Appartengono al dominio di produzione/build posto dall'altro lato del confine.

Se invece uno di questi tool è richiesto anche durante l'esecuzione, allora diventa Execution Dependency.

---

# 7. Package Admission v0

Un payload può diventare una Package Instance del `rumiai-store` per una specifica piattaforma solo se soddisfa TUTTI i requisiti seguenti.

## PA-01 — Execution platform determinabile

Deve essere possibile assegnare un Execution Platform Identifier corretto.

## PA-02 — Execution Closure completa

Tutto ciò che serve all'esecuzione deve appartenere al payload, a Package Dependency dichiarate o al Platform Baseline.

## PA-03 — Nessuna dipendenza dal package manager host

Non può richiedere `apt`, `dnf`, `brew`, Chocolatey, MSI install di runtime o equivalenti per completare l'ambiente runtime.

## PA-04 — Nessuna installazione globale host obbligatoria

Il payload deve poter funzionare senza copiare componenti indispensabili nelle directory globali del sistema.

## PA-05 — Nessun privilegio amministrativo ordinario

Installazione/materializzazione, integrazione ordinaria, uso e rimozione non devono richiedere privilegi elevati.

## PA-06 — Relocatability

La Package Instance deve funzionare quando collocata in una directory arbitraria della root RumiAI.

## PA-07 — Immutabilità del payload

Il software installato deve poter essere trattato come immutabile.

## PA-08 — Stato separabile

Lo stato mutabile necessario deve poter vivere fuori dalla Package Instance in aree gestite da RumiAI.

## PA-09 — Nessun first-run installation

Il package non può completare la propria Execution Closure scaricando o installando componenti al primo avvio.

## PA-10 — Offline-ready

Con le Execution Dependency già presenti, il software deve poter raggiungere uno stato eseguibile senza accesso alla rete.

## PA-11 — No auto-update della Package Instance

Il package non può modificare autonomamente i propri binari/librerie/versione nello store.

## PA-12 — Coesistenza

La presenza di una versione/revision della stessa applicazione non deve richiedere la rimozione fisica di altre Package Instance dal `rumiai-store`.

## PA-13 — Integrazione esterna

PATH, environment, command aliases, launchers e altre forme di attivazione devono poter essere gestiti da RumiAI senza modificare il payload immutabile.

## PA-14 — Rimozione locale

La Package Instance deve poter essere rimossa senza un uninstaller vendor che modifichi lo stato globale dell'host.

## PA-15 — Contenuto verificabile

Deve essere possibile inventariare e verificare il contenuto concreto della Package Instance.

---

# 8. Ammissibilità per piattaforma

L'ammissibilità appartiene alla coppia:

```text
software/release × execution platform
```

non al software in astratto.

È quindi perfettamente valido avere:

```text
pulsar / linux-arm64       ADMITTED
pulsar / linux-x86_64      ADMITTED
pulsar / macos-arm64       ADMITTED
pulsar / windows-x86_64    REJECTED
```

se la variante Windows richiede, per esempio, componenti installati globalmente mentre le altre varianti possiedono una Execution Closure compatibile con il contratto RumiAI.

Il package manager non deve abbassare i requisiti comuni per ottenere artificialmente parità fra piattaforme.

---

# 9. Esempi JVM

## Caso A — JAR puro

```text
artifact: application.jar
contiene: bytecode + resources
native code: none
requires: Java >= 17
```

Proposta:

```text
platform = jvm
execution dependency = java-runtime >=17
```

Ammissibile se tutti gli altri requisiti PA sono soddisfatti.

## Caso B — JAR con JNI Linux

```text
application.jar
native/libfoo.so
```

`libfoo.so` è necessaria all'esecuzione.

Proposta:

```text
platform = linux-x86_64
execution dependency = java-runtime >=17
```

Non è `jvm` anche se l'entrypoint è un JAR.

## Caso C — JAR che usa una Java host casuale

```text
#!/bin/sh
java -jar application.jar
```

senza dipendenza Java dichiarata.

Proposta:

```text
REJECTED
```

La Java deve essere una Execution Dependency RumiAI.

## Caso D — JAR che usa `/usr/bin/foo`

Se `foo` non appartiene al Platform Baseline:

```text
REJECTED
```

oppure `foo` deve diventare una Package Dependency esplicita.

## Caso E — stesso JAR contiene native library per più OS

Il v0 produce Package Instance platform-specific separate, anche se il blob upstream originale è identico.

---

# 10. AppImage, container e altri encapsulation backend

Il v0 NON considera automaticamente portable un software perché distribuito come:

```text
AppImage
container image
Docker/Podman image
VM image
```

Queste tecnologie possono aiutare a chiudere la Execution Closure, ma introducono a loro volta un execution backend e requisiti specifici della piattaforma.

Per ora si distinguono concettualmente:

```text
native/managed Package Instance

vs

encapsulated execution package
```

La seconda categoria verrà studiata separatamente.

In particolare il fatto che Docker su macOS utilizzi un ambiente Linux virtualizzato dimostra che il backend di esecuzione non può essere nascosto dentro un generico identificatore `portable`.

---

# 11. Conseguenze per `integrate` / `deintegrate`

Questo draft non specifica ancora integration e dependency resolution, ma conserva esplicitamente la semantica storica utile:

```text
presenza nel pkg/store
    !=
attivazione nell'ambiente
```

Una Package Instance può esistere nello store senza essere integrata.

`integrate` dovrà poter costruire un contesto di esecuzione che soddisfi le Execution Dependency risolte, per esempio selezionando Java differenti per package differenti.

Esempio storico da preservare come requisito concettuale:

```text
java latest come default generale
java 8 per un package che la richiede
comando java8 esplicito
shell/context in cui `java` risolve a Java 8
```

`deintegrate` deve rimuovere l'attivazione senza necessariamente rimuovere la Package Instance dallo store.

La forma concreta del nuovo integration model viene lasciata al passo successivo.

---

# 12. Definizione condensata v0

> **Una Package Instance RumiAI è una rappresentazione concreta, immutabile, relocatable e verificabile di software già prodotto, ammessa per uno specifico Execution Platform Identifier. Deve poter essere eseguita offline e senza privilegi amministrativi, senza modificare obbligatoriamente l'host e senza dipendenze runtime nascoste. La sua intera Execution Closure deve essere costituita esclusivamente dai file della Package Instance, da Execution Dependency esplicite verso altre Package Instance RumiAI e dagli elementi ammessi dal Platform Baseline applicabile. Lo stato mutabile e l'integrazione devono poter essere gestiti esternamente da RumiAI.**

---

# 13. Questioni aperte successive

Questo draft NON decide ancora:

- layout fisico di `pkg/`;
- sintassi canonica della Package Instance identity;
- grammatica version/range;
- solver delle dipendenze;
- capability/provider alternativi;
- struttura del metadata/manifest;
- modello preciso `integrate` / `deintegrate`;
- environment/view e scoping delle versioni;
- receipt/state dell'integrazione;
- baseline concreti Linux/macOS/Windows;
- verifica automatica della Execution Closure (`ldd`, `otool`, PE inspection, JAR inspection, ecc.);
- package encapsulati tramite AppImage/container/VM;
- produzione/acquisizione dei binari e relazione futura con `src/` e build system.

Il passo successivo corretto è definire il modello di **integration context** sopra queste tre primitive: Package Instance, Platform Baseline ed Execution Dependency.
