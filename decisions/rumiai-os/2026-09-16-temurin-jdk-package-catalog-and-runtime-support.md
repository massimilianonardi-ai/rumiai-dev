# Decisione — Catalogo e supporto runtime Eclipse Temurin JDK 25

Date: 2026-09-16  
Status: **Accepted — catalog definition and runtime support authorized**

## 1. Scopo e autorità

Questa decisione definisce il primo provider Java concreto del package manager RumiAI e ne autorizza il supporto runtime necessario.

L'utente ha approvato esplicitamente Eclipse Temurin come distribuzione JDK iniziale il 2026-09-16 e ha autorizzato la prosecuzione dell'implementazione.

Restano autorevoli e invariati il modello corrente di package identity, facility/dependency/provider index, resolved binding, target eligibility e normale launch.

## 2. Preflight corrente

HEAD remoti verificati immediatamente prima della scrittura:

```text
rumiai-dev    640db3c47f7bd537688b4098696b0aac8b9ef263
rumiai-os     ea0a06f04b5f7429d31a22bebcf165496825ae5c
rumiai-tests  8a6d1ee345ede7885c76c1db473b49d01ca0bf54
pkg-catalog   af4332445d8f6ad678ff7ec2a14e482358a43182
```

Sono stati riletti almeno:

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
decisions/rumiai-os/2026-09-07-package-repository-descriptor-and-adapter-types.md
decisions/rumiai-os/2026-09-07-package-facility-dependency-and-provider-index.md
decisions/rumiai-os/2026-09-11-package-facility-dependency-serialization-and-resolution-policy.md
decisions/rumiai-os/2026-09-15-maven-package-catalog.md
```

Sono stati inoltre verificati il dispatcher repository corrente, gli adapter product-specific esistenti, `pkg_extract`, `pkg_download`, il parser JSON corrente e i test permanenti degli adapter repository.

## 3. Package identity e facility

Il package concreto canonico è:

```text
temurin
```

Il package offre la facility astratta già fissata:

```text
java
```

La prima compatibility pubblicata è:

```text
25
```

Ogni concrete version contiene quindi:

```text
facility:
    java 25
```

Non vengono introdotti package o alias come:

```text
java-jdk
temurin-25
jdk
```

La versione upstream Temurin e la compatibility Java restano dimensioni separate.

## 4. Versione iniziale e target

La release iniziale osservata e supportata è:

```text
25.0.4+7
```

La concrete identity è target-specific:

```text
temurin@25.0.4+7!<osarch>
```

La tranche iniziale pubblica esclusivamente i target per cui Temurin JDK 25 dispone dell'artifact upstream corrispondente:

```text
linux-x86_64
linux-arm64
macos-x86_64
macos-arm64
windows-x86_64
```

Non viene pubblicato `catalog-windows-arm64` finché l'upstream Temurin JDK 25 non fornisce tale artifact.

## 5. Repository type Temurin

Il repository type product-specific è:

```text
temurin
```

che seleziona:

```text
lib/sys/sh/pkg-repository-temurin.lib.sh
```

Il dispatcher `pkg` corrente carica già dinamicamente `pkg-repository-<type>.lib.sh`; non viene introdotto un nuovo meccanismo di dispatch.

L'autorità dei metadata è l'API pubblica Adoptium v3. Il descriptor iniziale contiene esclusivamente:

```text
repository/type             temurin
repository/os               <adoptium-os>
repository/architecture     <adoptium-architecture>
repository/feature_version  25
```

`os`, `architecture` e `feature_version` sono parametri diretti dell'API Adoptium e restano confinati al contratto dell'adapter Temurin. Non diventano metadata generici del package manager.

Il mapping iniziale è:

```text
linux-x86_64   -> os=linux   architecture=x64
linux-arm64    -> os=linux   architecture=aarch64
macos-x86_64   -> os=mac     architecture=x64
macos-arm64    -> os=mac     architecture=aarch64
windows-x86_64 -> os=windows architecture=x64
```

Il `feature_version=25` rende intenzionalmente questa prima tranche limitata alla linea Java 25. L'estensione a ulteriori feature release verrà affrontata davanti al relativo caso d'uso senza anticipare un mini-linguaggio multi-major nel descriptor corrente.

## 6. Autorità delle versioni e mapping upstream

L'adapter interroga release GA Eclipse Temurin JDK/HotSpot per il target e la feature release dichiarati.

Adoptium identifica la release con un `release_name` del tipo:

```text
jdk-25.0.4+7
```

La concrete package version RumiAI è il corrispondente upstream JDK version senza il prefisso nominale `jdk-`:

```text
25.0.4+7
```

Il mapping `jdk-<version> <-> <version>` appartiene esclusivamente all'adapter Temurin e non modifica il generic GitHub adapter né introduce rewriting universale dei tag.

La lista e il confronto delle versioni restano responsabilità dell'adapter repository, non del core `pkg`.

## 7. Artifact, integrity e format

Per una versione concreta l'adapter usa gli endpoint Adoptium `binary/version` e `checksum/version` per la stessa release, target, image type `jdk`, JVM `hotspot`, heap `normal`, vendor `eclipse` e project `jdk`.

Il checksum richiesto dal range è:

```text
sha256
```

La size viene rilevata dall'upstream attraverso il normale `http-fetch -l` sullo stesso binary URL; il download finale resta responsabilità di `pkg_download`.

Gli artifact iniziali usano i formati upstream:

```text
Linux    tar.gz
macOS    tar.gz
Windows  zip
```

L'adapter costruisce e valida il naming Temurin JDK coerente con la release e il target; non viene introdotto un template generico configurabile nel catalogo.

## 8. Useful root e JAVA_HOME

Il provider deve materializzare sotto:

```text
<concrete-package>/root
```

la directory che costituisce direttamente `JAVA_HOME`, quindi almeno:

```text
root/bin/java
root/bin/javac
```

Il `pkg_extract` corrente normalizza ricorsivamente catene di singole wrapper directory. La tranche non aggiunge una primitive o una regola speciale `.jdk` finché il comportamento generico corrente normalizza correttamente anche il layout macOS Temurin fino a `Contents/Home`.

Una correzione dell'estrattore sarà ammessa soltanto davanti a evidenza riproducibile di fallimento.

## 9. Command, env e state

Il provider Temurin iniziale non dichiara:

```text
cmd/
link/
env
dependency
var/
default/
setuid_root
```

Il suo ruolo iniziale è fornire `java 25` a consumer che usano il resolved `binding/java` e impostano `JAVA_HOME`/`PATH` sul `root` del provider secondo il modello già fissato.

Non viene introdotto un default Java globale o un comando pubblico `java` svincolato dal normale lifecycle package/default.

## 10. Relazione con i consumer correnti

Alla revisione osservata:

```text
maven    -> dependency java >=17
netbeans -> dependency java =25
```

Temurin JDK 25 soddisfa entrambe le dependency per lo stesso target quando è l'unico provider eleggibile alla compatibility selezionata.

La policy di resolution resta invariata: se in futuro più provider concreti eleggibili offrono la stessa compatibility `java 25`, la resolution fallisce per ambiguità invece di applicare un ranking implicito dei vendor.

## 11. Testing e validation

L'implementazione deve aggiungere test permanenti proporzionati almeno per:

```text
validazione descriptor Temurin
version resolution/list/compare limitata a feature_version=25
mapping <version> <-> jdk-<version>
artifact URL/name/size/SHA-256
rifiuto metadata o checksum non canonici
catalog definition Temurin
physical package analysis/install sul target disponibile
verifica root/bin/java e root/bin/javac
```

La normalizzazione macOS deve essere verificata con artifact reale quando il target macOS è disponibile; non viene modificato preventivamente `pkg_extract` senza evidenza di fallimento.

Development run e validation run restano governati da `TESTING.md` e devono essere revision-specific e su working tree puliti quando richiesto dal validation workflow.

## 12. Invarianti

```text
TEMURIN-PKG-01  concrete package identity = temurin
TEMURIN-PKG-02  facility = java; initial compatibility = 25
TEMURIN-PKG-03  upstream version e facility compatibility restano separate
TEMURIN-PKG-04  initial version = 25.0.4+7
TEMURIN-PKG-05  concrete identities sono target-specific
TEMURIN-PKG-06  initial targets = linux x86_64/arm64, macOS x86_64/arm64, Windows x86_64
TEMURIN-PKG-07  Windows ARM64 non viene inventato senza artifact upstream JDK 25
TEMURIN-PKG-08  repository type product-specific = temurin; dispatcher generico invariato
TEMURIN-PKG-09  metadata authority = Adoptium API v3
TEMURIN-PKG-10  initial repository feature_version = 25; nessuna semantica multi-major anticipata
TEMURIN-PKG-11  adapter-local mapping jdk-<version> <-> <version>; nessun generic tag rewriting
TEMURIN-PKG-12  image type = jdk; JVM = hotspot; heap = normal; vendor = eclipse; project = jdk
TEMURIN-PKG-13  integrity = SHA-256 autorevole dello stesso artifact
TEMURIN-PKG-14  formats = tar.gz su Linux/macOS, zip su Windows
TEMURIN-PKG-15  provider root deve coincidere con JAVA_HOME utile
TEMURIN-PKG-16  nessuna regola .jdk speciale viene aggiunta senza failure evidence
TEMURIN-PKG-17  provider iniziale non introduce cmd/link/env/dependency/state/default/setuid
TEMURIN-PKG-18  nessun ranking implicito Temurin rispetto a futuri provider Java
TEMURIN-PKG-19  normale launch resta privo di resolution
TEMURIN-PKG-20  Git resta forward-only
```
