# Decisione — Catalogo package Apache Maven 4

Date: 2026-09-15  
Status: **Accepted — catalog definition authorized; runtime support pending explicit authorization**

## 1. Scopo

Questa decisione definisce il package `maven` nel catalogo RumiAI usando il package model Model 2.0 corrente.

L'utente ha indicato esplicitamente come sorgente degli artifact Maven 4 la forma:

```text
https://dlcdn.apache.org/maven/maven-4/${VERSION}/binaries/apache-maven-${VERSION}-bin.tar.gz
```

`${VERSION}` è soltanto notazione usata per descrivere la URL nel dialogo: non viene introdotta come sintassi, template language o primitive del catalogo. L'adapter costruisce invece la URL a partire dalla versione concreta già risolta.

Questa unità autorizza la definizione concreta in `pkg-catalog`. Le modifiche necessarie a `rumiai-os` per rendere operativo il nuovo repository type e SHA-512 restano pending finché l'utente non autorizza esplicitamente quella fase di implementazione.

## 2. Preflight corrente

HEAD remoti verificati prima della scrittura:

```text
rumiai-dev    d576ab591c3a18ac2bab2fa6251ade663edd8a1c
rumiai-os     908a9d5e86d56c217c59e9b77cd818fa0a086d98
rumiai-tests  369d8d15f5ba81cf4570fa18457f2b0a7d75f51c
pkg-catalog   1f87600a331cbef412e6e022e65ae2ee406e3a9e
```

Sono stati riletti almeno:

```text
RULES.md
CONSISTENCY-GATE.md
decisions/rumiai-tests/2026-09-15-task-scoped-validation-and-test-maintainability.md
decisions/rumiai-os/2026-09-07-package-repository-descriptor-and-adapter-types.md
decisions/rumiai-os/2026-09-07-package-facility-dependency-and-provider-index.md
decisions/rumiai-os/2026-09-09-package-download-contract.md
decisions/rumiai-os/2026-09-11-package-facility-dependency-serialization-and-resolution-policy.md
decisions/rumiai-os/2026-09-11-package-env-materialization-and-binding-consumption.md
decisions/rumiai-os/2026-09-15-google-chrome-package-integration.md
decisions/rumiai-os/2026-09-15-chromium-package-catalog.md
decisions/rumiai-os/2026-09-15-chromium-runtime-support.md
```

Sono stati inoltre verificati il package Keycloak corrente come precedente concreto per `dependency java` + package `env`, le implementazioni correnti del package manager/digest e i test permanenti `dependency.test` ed `env.test` pertinenti.

Le fonti upstream Apache Maven correnti indicano Maven `4.0.0-rc-6` come release 4.x preview pubblicata sotto `maven-4`, con requisito runtime JDK 17 o superiore e checksum SHA-512 ufficiale.

## 3. Package identity e command

Il package canonico è:

```text
maven
```

Il command iniziale esposto dalla concrete package version è:

```text
mvn
```

Non vengono aggiunti inizialmente command ausiliari come:

```text
mvnDebug
mvnenc
```

perché non sono necessari al caso d'uso minimo richiesto. Potranno essere aggiunti in un range successivo quando esiste un requisito concreto.

`pkg install maven` rende disponibile una concrete version ma non seleziona automaticamente il default e non crea binding pubblici fuori dal lifecycle `pkg default` corrente.

## 4. Repository type

Il repository type product-specific è:

```text
apache-maven
```

che, quando verrà autorizzato il relativo supporto runtime, selezionerà:

```text
lib/sys/sh/pkg-repository-apache-maven.lib.sh
```

Il nome usa l'identità canonica upstream **Apache Maven** e resta distinto dal repository type comune `maven` già previsto dal modello per repository dell'ecosistema Maven. Questa decisione non ridefinisce né occupa semanticamente quel type comune.

Il descriptor contiene soltanto:

```text
repository/type  apache-maven
```

La root upstream Maven 4 e il naming degli artifact appartengono al contratto monoproduct dell'adapter e non diventano configurazione generica del catalogo.

Non vengono introdotti:

```text
repository/type = custom
base_url
artifact_url_template
version_template
mirror selector
archive fallback
```

## 5. Autorità delle versioni

L'autorità runtime iniziale per le versioni Maven 4 correntemente pubblicate è:

```text
https://dlcdn.apache.org/maven/maven-4/
```

La versione iniziale osservata e supportata è:

```text
4.0.0-rc-6
```

Una versione esplicita è installabile soltanto se la relativa directory e l'artifact atteso sono ancora pubblicati dall'upstream corrente.

RumiAI non introduce un fallback automatico verso `archive.apache.org` per preservare release rimosse dal CDN corrente. Se un anchor non è più pubblicato, il catalogo deve essere aggiornato; il runtime non riscrive autonomamente le package definition.

Il futuro adapter deve mantenere il confronto delle versioni Apache Maven fuori dal core `pkg`. Per il range iniziale deve supportare almeno versioni canoniche:

```text
<major>.<minor>.<patch>-rc-<positive-decimal>
<major>.<minor>.<patch>
```

ordinando numericamente `major`, `minor`, `patch`, poi gli RC numericamente prima della corrispondente GA. Qualificatori differenti non vengono accettati implicitamente dal range corrente.

Questa regola non introduce un comparatore Maven universale nel core RumiAI.

## 6. Artifact e integrity

Per una versione concreta `<version>`, l'artifact binario è esattamente:

```text
apache-maven-<version>-bin.tar.gz
```

con URL:

```text
https://dlcdn.apache.org/maven/maven-4/<version>/binaries/apache-maven-<version>-bin.tar.gz
```

Il checksum autorevole è il sidecar:

```text
https://dlcdn.apache.org/maven/maven-4/<version>/binaries/apache-maven-<version>-bin.tar.gz.sha512
```

Il range dichiara quindi:

```text
digest_type = sha512
```

Non viene degradato a SHA-256 o MD5 quando SHA-512 è pubblicato dall'upstream.

Il descriptor prodotto dal futuro adapter verso `pkg_download` deve conservare il contratto corrente:

```text
name=<artifact-name>
url=<artifact-url>
size=<decimal-bytes>
digest=sha512:<128-hex>
```

La size deve provenire dall'upstream autorevole per lo stesso artifact. La fase runtime dovrà chiudere il meccanismo esatto di acquisizione della size senza far scaricare l'artifact finale all'adapter e senza bypassare `pkg_download`/`http-fetch`.

## 7. Format, useful root e direct link

Il package usa:

```text
format = tar.gz
```

L'archive Maven contiene il normale wrapper directory `apache-maven-<version>/`; la normalizzazione della useful root resta responsabilità di `pkg_extract`.

Il direct link del command è:

```text
mvn -> bin/mvn
```

Il catalog command source è:

```sh
#!/usr/bin/env m

. "$m_LIB_DIR/sys/sh/pkg-launch.lib.sh"

launcher "maven" "$@"
```

Non viene introdotta una nuova primitive di launch.

## 8. Dependency Java e package env

Maven 4 richiede JDK 17 o superiore per l'esecuzione. Il range dichiara quindi:

```text
dependency:
    java >=17
```

La dependency resta astratta e viene risolta dal normale provider index K2; non viene installato automaticamente un JDK e non viene hardcodato un package Java concreto.

Il package `env` usa il resolved binding secondo il precedente già consolidato di Keycloak:

```sh
maven_cmd_dir="${m_COMMAND_BIN%/*}"
[ "$maven_cmd_dir" != "$m_COMMAND_BIN" ] || return 1
maven_concrete_dir="${maven_cmd_dir%/*}"
[ "$maven_concrete_dir" != "$maven_cmd_dir" ] || return 1

maven_java_provider=
IFS= read -r maven_java_provider < "$maven_concrete_dir/binding/java" || return 1
[ -n "$maven_java_provider" ] || return 1

JAVA_HOME="$m_PKG_DIR/$maven_java_provider/root"
[ -d "$JAVA_HOME" ] && [ ! -L "$JAVA_HOME" ] || return 1
[ -x "$JAVA_HOME/bin/java" ] || return 1
PATH="$JAVA_HOME/bin:$PATH"
export JAVA_HOME PATH

unset maven_cmd_dir maven_concrete_dir maven_java_provider
```

Il normale launch non effettua dependency resolution.

## 9. Target streams

La distribuzione binaria scelta è architecture-independent, ma il consumer Maven viene materializzato target-specific perché un consumer non qualificato non può essere legato a un provider Java target-specific.

La definizione iniziale viene quindi pubblicata per:

```text
catalog-linux-x86_64
catalog-linux-arm64
catalog-macos-x86_64
catalog-macos-arm64
catalog-windows-x86_64
catalog-windows-arm64
```

Tutti gli stream usano lo stesso artifact tar.gz e lo stesso command `bin/mvn` nell'ambiente POSIX-compatible RumiAI. Non viene introdotta una launch line Win32 `mvn.cmd` package-specific.

L'identità target-specific garantisce che K2 possa selezionare un provider `java` qualificato esclusivamente per lo stesso `osarch`, oppure un provider non qualificato, secondo le regole già fissate.

## 10. State

Il range iniziale non dichiara:

```text
var/
default/
```

Maven usa normalmente state sotto HOME, incluso `.m2`; il normale HOME isolation del launcher RumiAI resta il meccanismo baseline. Non viene introdotto un override `MAVEN_USER_HOME` senza un requisito ulteriore.

Il package-local `env` esiste esclusivamente per applicare il resolved binding Java.

## 11. Initial range

Per tutti gli stream l'anchor iniziale è:

```text
n0001=4.0.0-rc-6
```

Il range contiene:

```text
archive_regex = ^apache-maven-[A-Za-z0-9][A-Za-z0-9._+~-]*-bin\.tar\.gz$
digest_type   = sha512
format        = tar.gz
dependency    = java >=17
env           = consumo binding/java
cmd/mvn       = launcher maven
link/mvn      = bin/mvn
```

Non vengono dichiarate Maven 3.x perché l'upstream scelto esplicitamente dall'utente è `maven-4`.

## 12. Runtime support pending

Alla revisione `rumiai-os` osservata nel preflight non esiste:

```text
lib/sys/sh/pkg-repository-apache-maven.lib.sh
```

Inoltre `digest` e `pkg_download` correnti supportano `sha256` e `md5`, non `sha512`.

Per rendere installabile il catalogo saranno quindi necessari, in una fase separata esplicitamente autorizzata dall'utente:

```text
repository adapter apache-maven
supporto sha512 nella primitive digest
supporto digest=sha512:<hex> in pkg_download
permanent test proporzionati
live validation revision-specific di download/install/mvn --version
```

La presente decisione non autorizza da sola scritture in `rumiai-os`.

Resta inoltre necessario che un provider `java >=17` eleggibile sia già installato: K2 non effettua auto-install delle dependency.

## 13. Testing di questa unità

Questa unità modifica soltanto decisione e catalog definition e non cambia il prodotto o la suite permanente.

Il consistency check deve verificare almeno:

```text
sei stream target-specific e nessun catalog generic
repository descriptor con solo type=apache-maven
stesso anchor 4.0.0-rc-6 sui sei stream
archive_regex e format coerenti con la URL upstream
SHA-512 dichiarato senza digest hardcodato nel catalogo
dependency java >=17 canonica
env POSIX non executable e coerente con binding/java
cmd/mvn con shebang m e launcher corrente
link/mvn = bin/mvn
assenza di var/default/facility/setuid_root/digest_regex
assenza di URL template o ${VERSION} nei file del catalogo
```

I test runtime e la physical validation appartengono alla successiva fase autorizzata e revision-specific.

## 14. Invarianti

```text
MAVEN-PKG-01  package identity = maven; command iniziale = mvn
MAVEN-PKG-02  upstream artifact segue la URL Apache Maven 4 indicata esplicitamente dall'utente
MAVEN-PKG-03  ${VERSION} del dialogo non diventa una sintassi/template del catalogo
MAVEN-PKG-04  repository type product-specific = apache-maven; il type comune maven non viene ridefinito
MAVEN-PKG-05  descriptor repository contiene soltanto type=apache-maven
MAVEN-PKG-06  version authority iniziale = https://dlcdn.apache.org/maven/maven-4/
MAVEN-PKG-07  initial anchor = 4.0.0-rc-6
MAVEN-PKG-08  artifact = apache-maven-<version>-bin.tar.gz sotto binaries/
MAVEN-PKG-09  checksum autorevole = sidecar .sha512 dello stesso artifact
MAVEN-PKG-10  digest_type corrente = sha512; nessun downgrade implicito
MAVEN-PKG-11  format = tar.gz; pkg_extract normalizza il wrapper upstream
MAVEN-PKG-12  direct link mvn = bin/mvn
MAVEN-PKG-13  dependency = java >=17
MAVEN-PKG-14  package env consuma binding/java e imposta JAVA_HOME/PATH senza resolution al launch
MAVEN-PKG-15  i sei stream sono target-specific per preservare target eligibility della dependency Java
MAVEN-PKG-16  launcher HOME isolation resta il meccanismo baseline per lo state Maven; nessun nuovo state mapping
MAVEN-PKG-17  nessun auto-install del provider Java
MAVEN-PKG-18  nessun custom type, URL template generico, nuova primitive di launch o comparatore universale viene introdotto
MAVEN-PKG-19  runtime adapter apache-maven e SHA-512 restano pending fino ad autorizzazione esplicita su rumiai-os
MAVEN-PKG-20  Git resta forward-only
```
