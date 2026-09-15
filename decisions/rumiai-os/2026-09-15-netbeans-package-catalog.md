# Decisione — Catalogo package Apache NetBeans

Date: 2026-09-15  
Status: **Accepted — catalog definition authorized; runtime support pending explicit authorization**

## 1. Scopo e correzione esplicita

Questa decisione definisce il package `netbeans` nel catalogo RumiAI usando il package model Model 2.0 corrente.

L'utente ha fissato esplicitamente per NetBeans lo stesso modello già adottato per Node.js:

```text
GitHub
    autorità per release, version discovery, latest, exact resolution e ordering

Apache download CDN
    autorità per il binary artifact ufficiale
```

La URL dell'artifact è stata fissata esplicitamente dall'utente nella forma:

```text
https://dlcdn.apache.org/netbeans/netbeans/${VERSION}/netbeans-${VERSION}-bin.zip
```

`${VERSION}` è soltanto notazione usata nel dialogo. Non viene introdotta come sintassi, template language, campo o primitive del catalogo. Il futuro adapter costruirà la URL dalla concrete version già risolta.

Questa unità autorizza la decisione e la package definition concreta in `pkg-catalog`. Non autorizza modifiche a `rumiai-os`; il supporto runtime necessario resta una fase separata.

## 2. Preflight corrente

HEAD remoti verificati prima della scrittura:

```text
rumiai-dev    9e27fa326e14da815c36cbb486847da59e090035
rumiai-os     908a9d5e86d56c217c59e9b77cd818fa0a086d98
rumiai-tests  369d8d15f5ba81cf4570fa18457f2b0a7d75f51c
pkg-catalog   1f87600a331cbef412e6e022e65ae2ee406e3a9e
```

Sono stati riletti almeno:

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/MODEL-2.0-MIGRATION.md
decisions/rumiai-os/2026-09-07-package-repository-descriptor-and-adapter-types.md
decisions/rumiai-os/2026-09-07-package-facility-dependency-and-provider-index.md
decisions/rumiai-os/2026-09-09-package-download-contract.md
decisions/rumiai-os/2026-09-11-package-facility-dependency-serialization-and-resolution-policy.md
decisions/rumiai-os/2026-09-11-package-env-materialization-and-binding-consumption.md
decisions/rumiai-os/2026-09-14-nodejs-package-integration.md
decisions/rumiai-os/2026-09-15-chromium-package-catalog.md
decisions/rumiai-os/2026-09-15-chromium-runtime-support.md
decisions/rumiai-os/2026-09-15-maven-package-catalog.md
```

Sono stati inoltre verificati il catalogo Keycloak corrente come precedente concreto per `dependency java` + package `env`, il GitHub repository `apache/netbeans`, la release corrente Apache NetBeans 31 e la pagina di download ASF corrente.

La release GitHub 31 è una full release (`draft=false`, `prerelease=false`) e non pubblica binary release asset GitHub. La distribuzione ASF corrente pubblica invece il binary platform-independent `netbeans-31-bin.zip` con SHA-512.

## 3. Package identity e command

Il package canonico è:

```text
netbeans
```

Il command iniziale esposto dalla concrete package version è:

```text
netbeans
```

Non vengono introdotti alias o command aggiuntivi.

`pkg install netbeans` rende disponibile una concrete version ma non seleziona automaticamente il default e non crea public command binding fuori dal lifecycle `pkg default` corrente.

## 4. Repository type e descriptor

Il repository type product-specific è:

```text
netbeans
```

che, quando il relativo supporto runtime verrà esplicitamente autorizzato, selezionerà:

```text
lib/sys/sh/pkg-repository-netbeans.lib.sh
```

Il descriptor usa le coordinate GitHub necessarie al caso concreto:

```text
repository/type        netbeans
repository/owner       apache
repository/repository  netbeans
```

L'adapter è deliberatamente monoproduct e deve validare esattamente queste coordinate.

Non vengono introdotti:

```text
repository/type = custom
base_url
artifact_url_template
version_template
mirror selector
archive fallback
```

I descriptor restano file scalari dichiarativi e non vengono source, eval o eseguiti.

## 5. Autorità delle release: GitHub

L'autorità per le release/versioni è il repository:

```text
apache/netbeans
```

Discovery, latest, exact resolution, enumeration e ordering usano le GitHub Release API secondo lo stesso modello già fissato per Node.js:

```text
GET /repos/apache/netbeans/releases
GET /repos/apache/netbeans/releases/latest
GET /repos/apache/netbeans/releases/tags/<version>
```

Sono installabili soltanto full release con:

```text
draft=false
prerelease=false
```

Le API repository restano quelle correnti:

```text
pkg_repository_list_versions
pkg_repository_resolve_version
pkg_repository_compare_versions
pkg_repository_resolve_artifact
```

`pkg_repository_list_versions` produce le release installabili:

```text
oldest -> latest
```

usando lo stesso ordine GitHub corrente:

```text
created_at
-> published_at come disambiguazione deterministica
```

`pkg_repository_compare_versions` usa la stessa successione e non interpreta i tag NetBeans come numeri, SemVer o altri componenti semanticamente confrontabili nel core `pkg`.

La resolution senza versione usa la GitHub full release `latest`.

Gli `assets[]` GitHub non sono la sorgente del binary artifact NetBeans.

## 6. Autorità dell'artifact: Apache download CDN

Dopo aver verificato che la concrete version corrisponda a una full release GitHub installabile, il futuro adapter risolve il binary ufficiale ASF.

Per una concrete version `<version>`:

```text
name
    netbeans-<version>-bin.zip

url
    https://dlcdn.apache.org/netbeans/netbeans/<version>/netbeans-<version>-bin.zip
```

Questa URL è il mapping product-specific fissato dall'utente. Non viene serializzata nel catalogo come template configurabile.

Il range seleziona l'artifact attraverso il corrente `archive_regex`.

## 7. Integrity e size

La distribuzione ASF pubblica per il binary release il checksum SHA-512 ufficiale. Il range dichiara quindi:

```text
digest_type = sha512
```

Il checksum concreto non viene hardcodato nel catalogo. Il futuro adapter deve ottenere il SHA-512 autorevole del medesimo artifact durante la resolution, usando il sidecar ASF corrispondente:

```text
netbeans-<version>-bin.zip.sha512
```

Il descriptor verso `pkg_download` deve mantenere il contratto corrente:

```text
name=netbeans-<version>-bin.zip
url=https://dlcdn.apache.org/netbeans/netbeans/<version>/netbeans-<version>-bin.zip
size=<decimal-bytes>
digest=sha512:<128-hex>
```

La size deve essere il numero di byte esatto ottenuto da una fonte upstream autorevole per lo stesso artifact.

La fase runtime dovrà chiudere il meccanismo esatto di acquisizione della size senza:

```text
scaricare direttamente l'artifact finale nell'adapter
bypassare pkg_download/http-fetch
rilassare il requisito size obbligatorio
hardcodare size o digest nel catalogo
```

Il `sha512` qui riusa il digest type già richiesto dalla corrente integrazione Apache Maven; non viene introdotta una seconda primitive SHA-512 NetBeans-specific.

## 8. Artifact selection e format

Il primo range usa:

```text
archive_regex = ^netbeans-[A-Za-z0-9][A-Za-z0-9._+~-]*-bin\.zip$
digest_type   = sha512
format        = zip
```

`pkg_extract` continua a normalizzare la useful root prima di `pkg_integrate`.

Non viene introdotto alcun extractor NetBeans-specific.

## 9. Dependency Java

Apache NetBeans 31 dichiara come runtime supportati:

```text
JDK 21
JDK 25
JDK 26
```

Il package model corrente non introduce OR fra compatibility constraint della stessa facility.

La prima package definition sceglie quindi deliberatamente il sottoinsieme minimo:

```text
dependency:
    java =25
```

Questa scelta non afferma che JDK 25 sia l'unico runtime supportato upstream. Evita invece di serializzare un range continuo che includerebbe versioni JDK non dichiarate supportate e non introduce una nuova primitive di dependency soltanto per NetBeans.

La dependency resta astratta; K2 non installa automaticamente un provider Java.

## 10. Package env e resolved Java binding

Il package `env` riusa il modello già consolidato per i consumer Java:

```sh
netbeans_cmd_dir="${m_COMMAND_BIN%/*}"
[ "$netbeans_cmd_dir" != "$m_COMMAND_BIN" ] || return 1
netbeans_concrete_dir="${netbeans_cmd_dir%/*}"
[ "$netbeans_concrete_dir" != "$netbeans_cmd_dir" ] || return 1

netbeans_java_provider=
IFS= read -r netbeans_java_provider < "$netbeans_concrete_dir/binding/java" || return 1
[ -n "$netbeans_java_provider" ] || return 1

JAVA_HOME="$m_PKG_DIR/$netbeans_java_provider/root"
[ -d "$JAVA_HOME" ] && [ ! -L "$JAVA_HOME" ] || return 1
[ -x "$JAVA_HOME/bin/java" ] || return 1
PATH="$JAVA_HOME/bin:$PATH"
export JAVA_HOME PATH

unset netbeans_cmd_dir netbeans_concrete_dir netbeans_java_provider
```

Il normale launch non effettua dependency resolution.

## 11. Target streams

Il binary ZIP ASF è platform-independent, ma il consumer viene materializzato target-specific perché un consumer non qualificato non può essere legato a un provider Java target-specific.

La prima definition pubblica:

```text
catalog-linux-arm64
catalog-linux-x86_64
catalog-macos-arm64
catalog-macos-x86_64
catalog-windows-x86_64
```

Non viene pubblicato inizialmente:

```text
catalog-windows-arm64
```

perché l'upstream corrente dichiara Windows/ARM non pienamente supportato. La sua eventuale aggiunta richiede una successiva evidenza/decisione e non viene dedotta dalla sola platform-independence dello ZIP.

Tutti i cinque stream usano lo stesso artifact ZIP, la stessa dependency Java e lo stesso package `env`.

## 12. Direct link e command source

Per Linux e macOS:

```text
netbeans -> bin/netbeans
```

Per Windows x86_64:

```text
netbeans -> bin/netbeans.exe
```

Il catalog command source è identico per tutti gli stream:

```sh
#!/usr/bin/env m

. "$m_LIB_DIR/sys/sh/pkg-launch.lib.sh"

launcher "netbeans" "$@"
```

Non viene introdotta una seconda primitive di launch.

La presenza della definition Windows non costituisce physical validation del bit executable o del comportamento del launcher nell'ambiente POSIX-compatible di riferimento. Non viene aggiunto un workaround `chmod` package-specific senza evidenza concreta.

## 13. State

Il range iniziale non dichiara:

```text
var/
default/
```

Il normale HOME isolation del launcher resta il meccanismo baseline per lo user state del package.

Non vengono introdotti path NetBeans-specific o override di userdir/cache senza una necessità concreta verificata.

## 14. Initial range

Per tutti gli stream l'anchor iniziale è:

```text
n0001=31
```

La release 31 è la prima concrete version verificata per questa definition.

Release precedenti non vengono dichiarate compatibili retroattivamente senza verifica.

Le future full release GitHub appartengono all'ultimo range finché artifact naming, runtime requirement e integration contract restano compatibili; quando uno di tali contratti cambia viene aggiunto un nuovo range secondo il package model corrente.

## 15. Runtime support pending

Alla revisione `rumiai-os` osservata nel preflight non esiste:

```text
lib/sys/sh/pkg-repository-netbeans.lib.sh
```

Inoltre il runtime corrente supporta `sha256` e `md5` nella primitive `digest`/`pkg_download`, non ancora `sha512`.

Per rendere installabile il catalogo saranno quindi necessari, in una fase separata esplicitamente autorizzata dall'utente:

```text
repository adapter netbeans
riuso del supporto sha512 general-purpose in digest/pkg_download quando disponibile, oppure sua implementazione una sola volta
acquisizione autorevole della exact artifact size
permanent test proporzionati
live validation revision-specific di download/install/launch
```

La presente decisione non autorizza da sola scritture in `rumiai-os`.

Resta inoltre necessario che un provider `java =25` eleggibile sia già installato: K2 non effettua auto-install delle dependency.

## 16. Testing di questa unità

Questa unità modifica soltanto decisione e catalog definition e non modifica il prodotto o la suite permanente.

Il consistency check deve verificare almeno:

```text
cinque stream target-specific e nessun catalog generic
assenza di catalog-windows-arm64
repository/type=netbeans, owner=apache, repository=netbeans
stesso anchor 31 sui cinque stream
archive_regex coerente col binary ASF
digest_type=sha512 senza digest hardcodato
format=zip
dependency "java =25" canonica
env POSIX non executable e coerente con binding/java
cmd/netbeans non executable nel catalogo, con shebang m e launcher corrente
link/netbeans = bin/netbeans su Linux/macOS
link/netbeans = bin/netbeans.exe su Windows x86_64
assenza di var/default/facility/setuid_root/digest_regex
assenza di URL template o ${VERSION} nei file del catalogo
pkg install non seleziona automaticamente default
```

I test runtime e la physical validation appartengono alla successiva fase autorizzata e revision-specific.

## 17. Invarianti

```text
NETBEANS-PKG-01  package identity e command iniziale = netbeans
NETBEANS-PKG-02  release/version authority = GitHub apache/netbeans
NETBEANS-PKG-03  full release installabile = draft=false e prerelease=false
NETBEANS-PKG-04  latest/exact/list/order usano GitHub Release API come Node.js
NETBEANS-PKG-05  version strings restano opache al core pkg
NETBEANS-PKG-06  repository type product-specific = netbeans
NETBEANS-PKG-07  descriptor = type netbeans + owner apache + repository netbeans
NETBEANS-PKG-08  binary artifact authority = Apache download CDN
NETBEANS-PKG-09  artifact URL = https://dlcdn.apache.org/netbeans/netbeans/<version>/netbeans-<version>-bin.zip
NETBEANS-PKG-10  ${VERSION} del dialogo non diventa template/catalog syntax
NETBEANS-PKG-11  artifact = netbeans-<version>-bin.zip; format = zip
NETBEANS-PKG-12  digest_type = sha512 e il digest concreto proviene dinamicamente dall'upstream autorevole
NETBEANS-PKG-13  exact size resta obbligatoria e deve provenire dall'upstream dello stesso artifact
NETBEANS-PKG-14  nessun bypass di http-fetch/pkg_download/pkg_extract/pkg_integrate
NETBEANS-PKG-15  initial anchor = 31
NETBEANS-PKG-16  dependency iniziale = java =25 usando la facility esistente
NETBEANS-PKG-17  env consuma esclusivamente il resolved binding/java; nessuna resolution al launch
NETBEANS-PKG-18  stream iniziali = linux/macos arm64+x86_64 e windows-x86_64
NETBEANS-PKG-19  windows-arm64 non viene dichiarato finché upstream non è pienamente supportato/validato
NETBEANS-PKG-20  POSIX link = bin/netbeans; Windows x86_64 link = bin/netbeans.exe
NETBEANS-PKG-21  nessun custom type, URL template generico, nuova dependency primitive o nuovo launcher
NETBEANS-PKG-22  runtime adapter/SHA-512/size support resta pending autorizzazione esplicita
NETBEANS-PKG-23  pkg install non seleziona automaticamente default
NETBEANS-PKG-24  Git resta forward-only
```
