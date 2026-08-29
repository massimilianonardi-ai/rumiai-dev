# RumiAI package manager — Package Admission v0

Data: 2026-08-29

Stato: **draft di design — concetti v0 fissati per proseguire con il modello di integration**

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

Discovery, download, scelta della toolchain e compilazione appartengono all'altro lato del confine e verranno ripresi separatamente.

Il package manager v0 assume invece:

```text
HO GIÀ UN PAYLOAD ESEGUIBILE
            ↓
è ammissibile nel rumiai-store?
            ↓
dove e come lo rappresento?
            ↓
quali dipendenze runtime RumiAI deve gestire?
            ↓
come potrà essere integrato, usato e rimosso?
```

La separazione storica resta concettualmente coerente con:

```text
src/
    software/sorgenti nel dominio della produzione

pkg/
    software già prodotto e gestito da RumiAI
```

Il significato fisico definitivo di queste directory non è ancora deciso.

---

# 2. Principio centrale: RumiAI Execution Closure

Una Package Instance deve essere sufficientemente self-contained da poter essere gestita da RumiAI senza trasformare il package manager in un installer del sistema host.

La **RumiAI Execution Closure** di una Package Instance è l'insieme di ciò che serve alla sua esecuzione corretta.

Nel modello v0 distinguiamo:

```text
1. contenuto della Package Instance

2. altre Package Instance RumiAI dichiarate come Execution Dependency

3. facility native dell'host utilizzate dal payload
```

I primi due insiemi sono sotto controllo diretto del package manager.

Il terzo NON viene modellato attraverso una whitelist teorica o una Platform Baseline. La compatibilità con le facility native dell'host viene accettata esclusivamente tramite **validazione fisica su installazioni di riferimento** della piattaforma.

Quindi il criterio operativo è:

```text
Content(P)
+
ResolvedExecutionDependencies(P)
+
ReferenceHostFacilities(P.execution_platform)
        ↓
physical validation
        ↓
ADMITTED oppure REJECTED
```

`ReferenceHostFacilities` non è un catalogo che RumiAI tenta di enumerare. È semplicemente ciò che il sistema operativo/reference installation fornisce realmente durante la validazione.

Questo limite è intenzionale.

RumiAI NON pretende nel v0 di garantire che un package validato su una reference installation Linux funzioni su ogni distribuzione Linux esistente.

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

La nomenclatura canonica verrà specificata separatamente.

Nel v0 un identificatore nativo come:

```text
linux-arm64
```

NON significa:

```text
compatibile con qualunque distribuzione/versione Linux ARM64
```

Significa invece:

```text
questa Package Instance è stata ammessa per il dominio linux-arm64
sulla base dei reference host fisicamente validati dal progetto
```

Le installazioni concrete usate per la validazione devono essere registrate come evidenza di test, ma non sono necessariamente parte dell'identità logica della Package Instance.

Questo è un limite conosciuto e accettato del v0.

## 3.2 Execution domain non nativi

Alcuni payload non dipendono direttamente dall'ABI nativa dell'host ma da una macchina/runtime portabile.

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
- `portable` è troppo generico e non identifica il runtime necessario.

Il modello potrà essere esteso in futuro ad altri execution domain, per esempio WASM/WASI, ma non vengono definiti nel v0.

## 3.3 Regola JVM v0

Un package può dichiarare:

```text
platform = jvm
```

SOLO se l'intera parte del payload necessaria all'esecuzione è indipendente dall'OS e dall'architettura.

Un package `jvm` DEVE dichiarare come Execution Dependency il runtime Java/JVM richiesto, per esempio:

```text
java-runtime >=17 <22
```

La JVM concreta che soddisfa tale dipendenza sarà a sua volta una Package Instance nativa, per esempio:

```text
java-runtime 21 / linux-arm64
java-runtime 21 / macos-arm64
java-runtime 21 / windows-x86_64
```

La catena diventa:

```text
application / jvm
        ↓ execution dependency
java-runtime / <native-platform>
        ↓
physical validation sul reference host nativo
```

## 3.4 JAR con componenti native

La presenza dell'estensione `.jar` NON autorizza `platform=jvm`.

Se l'esecuzione richiede JNI, JNA o qualunque `.so`, `.dylib`, `.dll` o altro componente nativo specifico dell'host, la Package Instance DEVE avere la piattaforma nativa concreta.

Esempio:

```text
foo.jar
└── native/libfoo.so

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

## 3.6 Componenti native opzionali

Un componente native opzionale che non è necessario al contratto di esecuzione della Package Instance non rende automaticamente il package platform-specific.

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

Nel v0 l'identità logica deve distinguere almeno:

```text
package name
software version
RumiAI package revision
execution platform
content digest
```

Esempio:

```text
name      = java-runtime
version   = 21.0.8
revision  = 1
platform  = linux-arm64
digest    = <content digest>
```

`version` identifica la versione del software.

`revision` permette a RumiAI di correggere o modificare il packaging della stessa versione upstream senza fingere che sia una nuova versione del software.

Il digest identifica/verifica il contenuto concreto. Due contenuti differenti NON devono essere accettati silenziosamente come la stessa Package Instance.

La sintassi finale dell'identificatore e il layout filesystem NON sono ancora definiti.

## 4.3 Immutabilità

Dopo l'ammissione nello store, il contenuto di una Package Instance DEVE essere trattabile come immutabile.

Qualunque modifica necessaria al payload produce una nuova Package Instance/revision, non una mutazione silenziosa di quella esistente.

Una Package Instance ammessa NON deve auto-aggiornare i propri eseguibili o librerie.

## 4.4 Relocatability

La Package Instance DEVE poter essere collocata in una directory arbitraria gestita da RumiAI senza richiedere un pathname assoluto di installazione predefinito.

NON è ammissibile nel v0 un payload che richieda necessariamente, per esempio:

```text
/opt/vendor/foo
/usr/local/vendor/foo
C:\Program Files\Vendor\Foo
```

salvo futuri modelli di encapsulation esplicitamente separati.

## 4.5 Stato mutabile

Una Package Instance DEVE poter essere eseguita senza usare la propria directory come storage mutabile indispensabile.

Configurazione, dati, cache, log, PID, file temporanei e home applicativa devono poter essere:

- esterni alla Package Instance;
- esplicitamente indirizzati verso aree RumiAI;
- oppure non necessari.

Se un software scrive necessariamente nel proprio installation tree e tale comportamento non può essere separato o rediretto, il package non è ammissibile nel v0.

## 4.6 Privilegi e host mutation

Materializzazione, integrazione ordinaria, esecuzione e rimozione NON devono richiedere:

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

Una Package Instance ammessa DEVE essere eseguibile offline una volta che le sue Execution Dependency RumiAI sono già disponibili.

Il first run non può essere usato per:

- scaricare runtime obbligatori;
- recuperare librerie mancanti;
- completare l'installazione del payload.

Network access può naturalmente essere una funzione dell'applicazione durante il normale utilizzo; ciò che è vietato è dipendere dalla rete per completare l'ambiente software necessario all'avvio.

---

# 5. Physical Platform Validation

## 5.1 Nessuna Platform Baseline formale

Il v0 NON definisce una whitelist teorica delle facility garantite da Linux, macOS o Windows.

Questa strada viene respinta perché:

- le distribuzioni Linux e le loro versioni sono troppo numerose e differenti;
- le installazioni Windows possono differire sostanzialmente;
- anche fra release della stessa famiglia possono cambiare runtime, loader, librerie e facility disponibili;
- mantenere un catalogo normativo completo diventerebbe un progetto enorme e fragile.

RumiAI accetta invece un modello empirico.

## 5.2 Reference installations

Per ogni Execution Platform Identifier nativo il progetto mantiene una o più **reference installations** fisicamente disponibili.

Una Package Instance è ammessa per quella piattaforma solo dopo aver superato i test fisici richiesti su tali installazioni.

Esempio concettuale:

```text
foo / linux-arm64
    physical validation:
        Ubuntu ARM64 reference host → PASS

foo / macos-arm64
    physical validation:
        macOS ARM64 reference host → PASS
```

Il dettaglio concreto della reference installation appartiene all'evidenza di validazione, non necessariamente all'identità logica del package.

## 5.3 Limite dichiarato

Il risultato della validazione garantisce soltanto ciò che è stato realmente dimostrato.

Per esempio:

```text
foo/linux-arm64 validato su Ubuntu ARM64 reference host
```

NON significa automaticamente:

```text
foo funziona su Alpine, Arch, Debian, Fedora e ogni altra Linux ARM64
```

Il package può risultare funzionante anche altrove, ma il progetto non lo considera dimostrato finché non esiste evidenza fisica appropriata.

Questa limitazione è accettata nel v0 in cambio di un modello semplice e verificabile.

## 5.4 Dipendenze native dell'host

RumiAI non tenta nel v0 di rappresentare singolarmente:

```text
libc
dynamic loader
system frameworks
system DLL
kernel ABI
altre facility native
```

come nodi del dependency graph del package manager.

La loro adeguatezza è assorbita dalla physical validation della Package Instance sulla reference installation.

Resta invece vietato richiedere che RumiAI installi componenti host aggiuntivi tramite:

```text
apt
dnf
brew
Chocolatey
MSI
installer vendor globali
```

per rendere eseguibile il package.

---

# 6. Execution Dependency

## 6.1 Definizione

Una **Execution Dependency** è un requisito runtime che RumiAI deve soddisfare tramite un'altra Package Instance gestita dal `rumiai-store`.

Nel v0 il dependency graph del package manager contiene quindi esclusivamente dipendenze fra Package Instance RumiAI.

Le facility native dell'host NON sono modellate come Execution Dependency: sono coperte dalla Physical Platform Validation.

Non esiste una categoria implicita del tipo:

```text
"installalo sul computer e poi dovrebbe funzionare"
```

Se una dipendenza runtime esterna deve essere procurata o versionata da RumiAI, deve diventare una Package Instance RumiAI.

## 6.2 Dependency constraint

Una Execution Dependency identifica almeno:

```text
package richiesto
version constraint
```

Esempio:

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
resolved execution dependency
```

Il modello dei version range e il resolver non vengono ancora specificati.

## 6.3 Dipendenze nascoste gestibili da RumiAI vietate

Un package v0 non può affidarsi implicitamente a un altro software che RumiAI dovrebbe invece gestire.

Esempi:

```text
JAR che presume `java` dal PATH host
script che presume python/node dal PATH host
package che presume PostgreSQL già installato
plugin che richiede un altro runtime non dichiarato
```

Questi requisiti devono diventare Execution Dependency esplicite.

Le dipendenze native dell'OS sono una categoria diversa e vengono validate empiricamente attraverso la reference installation.

## 6.4 Runtime come Execution Dependency

Runtime come Java sono normali Execution Dependency.

Questo preserva la semantica storicamente importante:

```text
package A → Java compatibile più recente
package B → Java 8
```

senza imporre una sola Java globale.

La futura integration può costruire context differenti e rendere disponibile la versione corretta per ogni package/context.

## 6.5 Build dependency fuori scope

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

Se invece uno di questi tool è richiesto anche durante l'esecuzione, allora deve essere gestito come Execution Dependency.

---

# 7. Package Admission v0

Un payload può diventare una Package Instance del `rumiai-store` per una specifica piattaforma solo se soddisfa TUTTI i requisiti seguenti.

## PA-01 — Execution platform determinabile

Deve essere possibile assegnare un Execution Platform Identifier corretto.

## PA-02 — Physical validation

La Package Instance deve superare la validazione fisica richiesta sulle reference installations della piattaforma dichiarata.

## PA-03 — Nessuna dipendenza dal package manager host

Non può richiedere `apt`, `dnf`, `brew`, Chocolatey, MSI install di runtime o equivalenti per completare il proprio ambiente runtime.

## PA-04 — Execution Dependency esplicite

Qualunque software/runtime che RumiAI deve procurare e gestire deve essere dichiarato come Execution Dependency.

## PA-05 — Nessuna installazione globale host obbligatoria

Il payload deve poter funzionare senza copiare componenti indispensabili nelle directory globali del sistema.

## PA-06 — Nessun privilegio amministrativo ordinario

Materializzazione, integrazione ordinaria, uso e rimozione non devono richiedere privilegi elevati.

## PA-07 — Relocatability

La Package Instance deve funzionare quando collocata in una directory arbitraria della root RumiAI.

## PA-08 — Immutabilità del payload

Il software ammesso deve poter essere trattato come immutabile.

## PA-09 — Stato separabile

Lo stato mutabile necessario deve poter vivere fuori dalla Package Instance in aree gestite da RumiAI.

## PA-10 — Nessun first-run installation

Il package non può completare il proprio ambiente obbligatorio scaricando o installando componenti al primo avvio.

## PA-11 — Offline-ready

Con le Execution Dependency RumiAI già presenti, il software deve poter raggiungere uno stato eseguibile senza accesso alla rete.

## PA-12 — No auto-update della Package Instance

Il package non può modificare autonomamente i propri binari/librerie/versione nello store.

## PA-13 — Coesistenza

La presenza di una versione/revision della stessa applicazione non deve richiedere la rimozione fisica di altre Package Instance dal `rumiai-store`.

## PA-14 — Integrazione esterna

PATH, environment, command aliases, launchers e altre forme di attivazione devono poter essere gestiti da RumiAI senza modificare il payload immutabile.

## PA-15 — Rimozione locale

La Package Instance deve poter essere rimossa senza un uninstaller vendor che modifichi lo stato globale dell'host.

## PA-16 — Contenuto verificabile

Deve essere possibile inventariare e verificare il contenuto concreto della Package Instance.

---

# 8. Ammissibilità per piattaforma

L'ammissibilità appartiene alla coppia:

```text
software/release × execution platform
```

ed è sostenuta da evidenza fisica sulle reference installations.

È perfettamente valido avere:

```text
pulsar / linux-arm64       ADMITTED
pulsar / macos-arm64       ADMITTED
pulsar / windows-x86_64    REJECTED
```

se la variante Windows richiede, per esempio, componenti installati globalmente mentre le altre varianti soddisfano il contratto RumiAI sulle rispettive reference installations.

Il package manager non deve abbassare i requisiti comuni per ottenere artificialmente parità fra piattaforme.

---

# 9. Esempi JVM

## Caso A — JAR puro

```text
artifact: application.jar
contiene: bytecode + resources
native code: none
requires: Java >=17
```

Proposta:

```text
platform = jvm
execution dependency = java-runtime >=17
```

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

senza dipendenza Java dichiarata:

```text
REJECTED
```

La Java deve essere una Execution Dependency RumiAI.

## Caso D — JAR che usa un comando host

Se il JAR invoca `/usr/bin/foo` e `foo` è semplicemente una facility presente sulla reference installation, il package può essere ammesso solo se il comportamento completo viene fisicamente validato su quella piattaforma.

Se invece `foo` è software che RumiAI deve procurare/versionare/gestire, deve essere una Execution Dependency RumiAI.

Questa distinzione viene decisa dal contratto del package, non dalla semplice esistenza del pathname.

## Caso E — stesso JAR con native library per più OS

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

Queste tecnologie possono chiudere o modificare l'ambiente di esecuzione, ma introducono a loro volta un backend con requisiti specifici della piattaforma.

Per ora si distinguono concettualmente:

```text
native/managed Package Instance

vs

encapsulated execution package
```

La seconda categoria verrà studiata separatamente.

In particolare il fatto che Docker su macOS utilizzi normalmente un ambiente Linux virtualizzato mostra che il backend di esecuzione non può essere nascosto dentro un generico identificatore `portable`.

---

# 11. Conseguenze per `integrate` / `deintegrate`

Il v0 conserva esplicitamente la semantica storica:

```text
presenza nel pkg/store
    !=
attivazione nell'ambiente
```

Una Package Instance può esistere nello store senza essere integrata.

`integrate` dovrà poter costruire un **Integration Context** che soddisfi le Execution Dependency risolte e renda il package utilizzabile senza modificarne il contenuto immutabile.

Esempi storici da preservare come requisito concettuale:

```text
Java più recente come default generale
Java 8 per un package che la richiede
comando `java8` esplicito
shell/context in cui `java` risolve a Java 8
```

`deintegrate` deve rimuovere un'attivazione/context senza necessariamente rimuovere la Package Instance dallo store.

---

# 12. Definizione condensata v0

> **Una Package Instance RumiAI è una rappresentazione concreta, immutabile, relocatable e verificabile di software già prodotto, ammessa per uno specifico Execution Platform Identifier sulla base di validazione fisica sulle reference installations del progetto. Deve poter essere materializzata, integrata, eseguita e rimossa senza richiedere installazioni globali dell'host o package manager host, e senza privilegi amministrativi ordinari. Qualunque software/runtime che RumiAI deve procurare o versionare deve essere una Execution Dependency esplicita verso un'altra Package Instance RumiAI. Le facility native dell'host non vengono enumerate in una Platform Baseline: la loro adeguatezza è parte dell'evidenza fisica di compatibilità della Package Instance. Stato mutabile e integrazione devono poter essere gestiti esternamente da RumiAI.**

---

# 13. Concetti v0 fissati

Per il seguito del design assumiamo:

```text
Package Instance
Execution Platform Identifier
Execution Dependency
Physical Platform Validation
Reference Installation
RumiAI Execution Closure
```

Il concetto di **Platform Baseline formale viene esplicitamente respinto nel v0**.

---

# 14. Questioni aperte successive

Questo draft NON decide ancora:

- layout fisico di `pkg/`;
- sintassi canonica della Package Instance identity;
- grammatica version/range;
- solver delle dipendenze;
- struttura del metadata/manifest;
- modello preciso `integrate` / `deintegrate`;
- Integration Context e relativo scope;
- selezione/default/override delle versioni;
- integrazione di comandi, environment, librerie e altri elementi;
- stato/receipt dell'integrazione;
- matrice concreta delle reference installations;
- profondità dei test fisici richiesti per l'admission;
- verifica automatica/assistita della compatibilità (`ldd`, `otool`, PE/JAR inspection, ecc.);
- package encapsulati tramite AppImage/container/VM;
- produzione/acquisizione dei binari e relazione futura con `src/` e build system.

Il passo successivo è definire il modello di **Integration Context** sopra le primitive appena fissate.
