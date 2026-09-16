# Decisione — Catalogo e supporto runtime GraalVM Community JDK 25

Date: 2026-09-16
Status: **Accepted — package preparation authorized**

## 1. Scopo e autorità

Questa decisione definisce `graalvm` come secondo provider Java concreto del package manager RumiAI e autorizza il supporto runtime necessario alla sua preparazione.

La distribuzione iniziale è **GraalVM Community Edition**, pubblicata dal progetto GraalVM nel repository upstream `graalvm/graalvm-ce-builds`. La scelta mantiene il package nel perimetro open source del progetto e non introduce Oracle GraalVM come distribuzione alternativa implicita.

Restano autorevoli e invariati il modello corrente di package identity, facility/dependency/provider index, resolved binding, target eligibility e normal launch. La precedente decisione Temurin resta valida e GraalVM non acquisisce alcuna priorità rispetto a Temurin.

## 2. Preflight corrente

HEAD remoti verificati prima della preparazione:

```text
rumiai-dev    54eed1add4c08476c153c8f2c280eb64175ab362
rumiai-os     8b261fd505c7004179ab213dde3f04c56116f446
rumiai-tests  ed52295651fd4410648a01b3890fa7d3ac8ac3ce
pkg-catalog   af4332445d8f6ad678ff7ec2a14e482358a43182
```

Sono stati riletti almeno:

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
decisions/rumiai-os/2026-09-07-package-repository-descriptor-and-adapter-types.md
decisions/rumiai-os/2026-09-07-package-facility-dependency-and-provider-index.md
decisions/rumiai-os/2026-09-11-package-facility-dependency-serialization-and-resolution-policy.md
decisions/rumiai-os/2026-09-16-temurin-jdk-package-catalog-and-runtime-support.md
decisions/rumiai-tests/2026-09-15-package-release-runtime-analysis-gate.md
```

Sono stati inoltre verificati il generic GitHub adapter, gli adapter product-specific esistenti, il contract Temurin corrente e il layout corrente di `pkg-catalog`.

## 3. Package identity e facility

Il package concreto canonico è:

```text
graalvm
```

Il package offre la facility astratta già fissata:

```text
java
```

La compatibility iniziale pubblicata è:

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
graalvm-ce
graalvm-community
jdk
native-image
```

`native-image` resta un binario utile della distribuzione GraalVM, ma non viene promosso a nuova facility finché non esiste un consumer RumiAI che richieda tale astrazione.

La versione GraalVM, la versione OpenJDK sottostante e la compatibility della facility Java restano dimensioni distinte.

## 4. Versione iniziale e target

La release iniziale osservata e supportata è:

```text
GraalVM Community 25.3.4.1
OpenJDK           25.0.4.1
```

La concrete package version RumiAI è la versione GraalVM:

```text
25.3.4.1
```

La concrete identity è target-specific:

```text
graalvm@25.3.4.1!<osarch>
```

La tranche iniziale pubblica esclusivamente i target per cui la release upstream dispone dell'artifact JDK corrispondente:

```text
linux-x86_64
linux-arm64
macos-arm64
windows-x86_64
```

Non vengono pubblicati:

```text
macos-x86_64
windows-arm64
```

senza un artifact upstream GraalVM Community JDK 25 corrispondente. In particolare, il supporto macOS x64 è stato rimosso dalla linea GraalVM Community 25 dopo la release 25.0.1.

## 5. Repository type GraalVM

Il repository type product-specific è:

```text
graalvm
```

che seleziona:

```text
lib/sys/sh/pkg-repository-graalvm.lib.sh
```

Il dispatcher `pkg` corrente carica già dinamicamente `pkg-repository-<type>.lib.sh`; non viene introdotto un nuovo meccanismo di dispatch.

L'autorità dei metadata è la GitHub Releases API del repository ufficiale:

```text
graalvm/graalvm-ce-builds
```

Il descriptor iniziale contiene esclusivamente:

```text
repository/type        graalvm
repository/owner       graalvm
repository/repository  graalvm-ce-builds
```

La limitazione iniziale alla linea GraalVM 25 appartiene all'adapter product-specific. Non viene introdotta una chiave generica `feature_version`, `graal_major`, `jdk_feature` o equivalente.

## 6. Autorità delle versioni e mapping upstream

Le release GA upstream correnti usano tag del tipo:

```text
graal-25.3.4.1
```

La concrete package version RumiAI corrispondente è:

```text
25.3.4.1
```

Il mapping:

```text
graal-<version> <-> <version>
```

appartiene esclusivamente all'adapter GraalVM. Il generic GitHub adapter non viene modificato e non acquisisce una regola universale di tag rewriting.

L'adapter considera soltanto release non-draft e non-prerelease della linea `graal-25.*`. Le altre release/tag del repository non diventano versioni del package corrente.

Lista, latest, exact resolution e compare restano responsabilità dell'adapter repository. L'ordinamento segue l'ordine autorevole delle release GitHub usando i timestamp `created_at` e `published_at`, senza introdurre un nuovo parser/version comparator generico.

## 7. Artifact, integrity e format

Per una concrete version l'adapter risolve la release GitHub `graal-<version>` e seleziona esattamente un asset `uploaded` che soddisfa `archive_regex` del range.

L'adapter usa i metadata autorevoli dell'asset GitHub:

```text
name
size
digest
browser_download_url
```

Il checksum richiesto dal range è:

```text
sha256
```

La release iniziale `25.3.4.1` espone gli artifact JDK:

```text
graalvm-community-jdk-25i3-25.0.4.1_linux-x64_bin.tar.gz
graalvm-community-jdk-25i3-25.0.4.1_linux-aarch64_bin.tar.gz
graalvm-community-jdk-25i3-25.0.4.1_macos-aarch64_bin.tar.gz
graalvm-community-jdk-25i3-25.0.4.1_windows-x64_bin.zip
```

I formati iniziali sono:

```text
Linux    tar.gz
macOS    tar.gz
Windows  zip
```

Gli asset sidecar `.sha256` non sono artifact installabili e devono essere esclusi dal range regex.

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

La presenza di `native-image` nella distribuzione non modifica questo contratto.

La tranche non aggiunge regole di estrazione GraalVM o `.jdk` speciali finché il generic `pkg_extract` non mostra un failure riproducibile su un artifact reale. La normalizzazione macOS deve essere verificata fisicamente sul target disponibile prima di qualsiasi correzione dell'estrattore.

## 9. Command, env e state

Il provider GraalVM iniziale non dichiara:

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

Non viene introdotto un default Java globale né un comando pubblico `java` o `native-image` svincolato dal normale lifecycle package/default.

## 10. Relazione con Temurin e consumer Java

Temurin e GraalVM sono provider concreti indipendenti della stessa facility:

```text
temurin -> java 25
graalvm -> java 25
```

La policy di resolution resta invariata. Se entrambi sono installati ed eleggibili per la stessa dependency/target alla compatibility selezionata `java 25`, la resolution deve fallire per ambiguità.

Non viene introdotto alcun ranking implicito, preferenza vendor, default provider, ordine di installazione o tie-break basato sulla concrete package version.

## 11. Testing e validation

L'implementazione deve aggiungere test permanenti proporzionati almeno per:

```text
validazione descriptor GraalVM
lista/version resolution/compare limitati alla linea graal-25.*
mapping <version> <-> graal-<version>
rifiuto draft/prerelease/tag estranei
artifact URL/name/size/SHA-256 da metadata GitHub
rifiuto asset non uploaded, digest non canonico o match ambiguo
catalog definition GraalVM
physical package analysis/install sul target disponibile
verifica root/bin/java e root/bin/javac
assenza di default/public binding impliciti
```

La normalizzazione macOS deve essere verificata con artifact reale quando un target macOS ARM64 è disponibile. Non viene modificato preventivamente `pkg_extract` senza evidenza di fallimento.

Development run e validation run restano governati da `TESTING.md` e devono essere revision-specific e su working tree puliti quando richiesto dal validation workflow.

## 12. Invarianti

```text
GRAALVM-PKG-01  concrete package identity = graalvm
GRAALVM-PKG-02  upstream distribution = GraalVM Community Edition
GRAALVM-PKG-03  facility = java; initial compatibility = 25
GRAALVM-PKG-04  GraalVM version, OpenJDK version e facility compatibility restano separate
GRAALVM-PKG-05  initial concrete version = 25.3.4.1
GRAALVM-PKG-06  concrete identities sono target-specific
GRAALVM-PKG-07  initial targets = linux x86_64/arm64, macOS arm64, Windows x86_64
GRAALVM-PKG-08  macOS x86_64 e Windows ARM64 non vengono inventati senza artifact upstream corrente
GRAALVM-PKG-09  repository type product-specific = graalvm; dispatcher generico invariato
GRAALVM-PKG-10  metadata authority = GitHub Releases API di graalvm/graalvm-ce-builds
GRAALVM-PKG-11  descriptor = type/owner/repository; nessun metadata generico multi-major anticipato
GRAALVM-PKG-12  adapter-local mapping graal-<version> <-> <version>; generic GitHub adapter invariato
GRAALVM-PKG-13  sono eleggibili solo release GA non-draft/non-prerelease della linea graal-25.*
GRAALVM-PKG-14  integrity = SHA-256 autorevole del medesimo GitHub release asset
GRAALVM-PKG-15  formats = tar.gz su Linux/macOS, zip su Windows
GRAALVM-PKG-16  provider root deve coincidere con JAVA_HOME utile
GRAALVM-PKG-17  nessuna regola di estrazione speciale viene aggiunta senza failure evidence
GRAALVM-PKG-18  provider iniziale non introduce cmd/link/env/dependency/state/default/setuid
GRAALVM-PKG-19  native-image non diventa una nuova facility senza un consumer/requisito esplicito
GRAALVM-PKG-20  Temurin e GraalVM java 25 restano peer provider; nessun ranking implicito
GRAALVM-PKG-21  normale launch resta privo di resolution
GRAALVM-PKG-22  Git resta forward-only
```
