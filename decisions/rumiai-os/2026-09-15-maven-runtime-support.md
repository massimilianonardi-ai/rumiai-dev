# Decisione — Supporto runtime package Apache Maven 4

Date: 2026-09-15  
Status: **Accepted**

## 1. Scopo e autorizzazione

Questa decisione attiva la fase runtime lasciata pending da `2026-09-15-maven-package-catalog.md`.

L'utente ha autorizzato esplicitamente la modifica di `rumiai-os` per completare l'integrazione Maven.

Lo scope corrente è:

```text
lib/sys/sh/pkg-repository-apache-maven.lib.sh
test permanente del repository adapter Apache Maven
validation scope task-specifico
```

Non vengono modificati:

```text
pkg-catalog
package/stream model
dependency resolver K2
launcher
pkg_extract
digest
pkg_download
http-fetch
```

Le ultime tre primitive sono già state estese dal work unit NetBeans con il supporto generale necessario a Maven: SHA-512 in `digest`/`pkg_download` e `http-fetch -l`.

## 2. Preflight corrente

HEAD remoti verificati prima della scrittura:

```text
rumiai-dev    650b4721f542a1edec9da83cf8d2b535ae0fbc62
rumiai-os     08d85c10d7b6cf2a7e663c5e4df07dacc74858b6
rumiai-tests  1fd5e1c20fb2b4b51944dba34e3d0724955361fa
pkg-catalog   af4332445d8f6ad678ff7ec2a14e482358a43182
```

Sono stati riletti nella revisione corrente almeno `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, la decisione catalogo Maven, le decisioni correnti su repository descriptor e adapter, facility/dependency/binding/env e task-scoped validation, oltre a `pkg install`, all'adapter NetBeans e al relativo test contract correnti.

Le fonti upstream Maven correnti confermano `https://dlcdn.apache.org/maven/maven-4/` come authority corrente delle versioni Maven 4, `4.0.0-rc-6` come release corrente pubblicata in tale ramo, Java 17 come requisito Maven 4 e SHA-512 come checksum ufficiale.

## 3. Correzione della provenienza del checksum

La decisione catalogo aveva correttamente fissato l'artifact:

```text
https://dlcdn.apache.org/maven/maven-4/<version>/binaries/apache-maven-<version>-bin.tar.gz
```

ma rappresentava il sidecar SHA-512 sullo stesso host `dlcdn.apache.org`.

La pagina download ufficiale Maven corrente distingue invece:

```text
artifact:
https://dlcdn.apache.org/maven/maven-4/<version>/binaries/apache-maven-<version>-bin.tar.gz

checksum:
https://downloads.apache.org/maven/maven-4/<version>/binaries/apache-maven-<version>-bin.tar.gz.sha512
```

Questa decisione supersede esclusivamente il dettaglio host del checksum in `MAVEN-PKG-09`. Restano invariati URL artifact indicata dall'utente, artifact name, version path, SHA-512 obbligatorio, assenza di downgrade e assenza di archive fallback.

Il sidecar corrente contiene una singola riga con esattamente 128 cifre esadecimali; l'adapter normalizza il digest lowercase.

## 4. Repository adapter

Il repository type resta `apache-maven` e seleziona:

```text
lib/sys/sh/pkg-repository-apache-maven.lib.sh
```

L'adapter è product-specific e monoproduct. Non ridefinisce il repository type comune `maven`.

Il repository descriptor contiene esattamente:

```text
repository/type = apache-maven
```

Campi aggiuntivi, scalar non canonici, symlink o file executable sono failure. Non vengono introdotti `custom`, `base_url`, `artifact_url_template`, `version_template`, mirror selector o archive fallback.

## 5. Version authority, grammar e ordering

L'autorità corrente delle versioni è:

```text
https://dlcdn.apache.org/maven/maven-4/
```

L'adapter riconosce esclusivamente:

```text
<major>.<minor>.<patch>-rc-<positive-decimal>
<major>.<minor>.<patch>
```

Ogni componente numerico è canonico (`0` oppure `[1-9][0-9]*`); il numero RC è strettamente positivo e senza leading zero. Qualificatori differenti non vengono promossi implicitamente nel contratto corrente.

`pkg_repository_list_versions` legge il current index Apache, filtra la grammar supportata, verifica che artifact e checksum richiesti siano ancora pubblicati, rifiuta duplicati ambigui e produce le versioni installabili `oldest -> latest`.

Una exact version è valida solo se compare ancora nel current index e i metadata richiesti sono disponibili. `pkg_repository_compare_versions` valida entrambi gli operandi contro l'upstream corrente prima del confronto.

L'ordering è adapter-specific: major/minor/patch numerici, RC numerico, GA dopo tutti gli RC della stessa versione base. Il confronto dei componenti non dipende dalla precisione numerica host, ma da lunghezza della stringa decimale canonica e confronto lessicografico a parità di lunghezza.

## 6. Artifact resolution

Per `<version>`:

```text
name = apache-maven-<version>-bin.tar.gz
url = https://dlcdn.apache.org/maven/maven-4/<version>/binaries/apache-maven-<version>-bin.tar.gz
checksum-url = https://downloads.apache.org/maven/maven-4/<version>/binaries/apache-maven-<version>-bin.tar.gz.sha512
```

Il range deve dichiarare `digest_type = sha512`, non deve contenere `digest_regex` e `archive_regex` deve selezionare il binary previsto.

La size viene ottenuta senza scaricare l'artifact tramite:

```text
http-fetch -l -- <artifact-url>
```

Il checksum viene letto tramite:

```text
http-fetch -- <checksum-url>
```

Il descriptor emesso verso `pkg_download` è:

```text
name=<artifact-name>
url=<artifact-url>
size=<decimal-bytes>
digest=sha512:<128-hex-lowercase>
```

L'adapter non scarica il binary finale e non sostituisce il checksum upstream con un digest hardcodato o calcolato localmente.

## 7. Primitive riusate e dependency Java

La revisione prodotto di preflight possiede già `digest -a sha512`, `pkg_download` con `digest=sha512:<128-hex>` e `http-fetch -l`. Il work unit Maven non duplica né modifica queste responsabilità.

Restano invariati:

```text
dependency = java >=17
binding/java risolto install-time da K2
env -> JAVA_HOME + PATH
nessuna resolution al launch
nessun auto-install Java
link/mvn = bin/mvn
HOME isolation del launcher per lo state Maven
```

## 8. Testing e validation scope

La nuova proprietà permanente distinta è:

```text
rumiai-os/pkg-repository-apache-maven/contract.test
```

Il test protegge descriptor e mode della libreria, current-index filtering, grammar, ordering RC/GA, exact/current installability, artifact URL `dlcdn.apache.org`, checksum URL `downloads.apache.org`, sidecar SHA-512, size via `http-fetch -l`, range integrity e assenza di archive fallback.

Poiché `digest`, `pkg_download` e `http-fetch -l` non vengono modificati, i loro test generici non vengono duplicati nello scope Maven.

Lo scope task viene fissato prima della validation con la selection dell'adapter Maven. Una live validation completa `pkg install maven` + `mvn --version` richiede un provider `java >=17` eleggibile già installato; K2 non può essere aggirato per rendere verde la prova.

La sola presenza del test deterministico non costituisce physical validation live.

## 9. Invarianti

```text
MAVEN-RUNTIME-01  autorizzazione rumiai-os attiva per questa unità
MAVEN-RUNTIME-02  adapter = lib/sys/sh/pkg-repository-apache-maven.lib.sh
MAVEN-RUNTIME-03  descriptor repository contiene soltanto type=apache-maven
MAVEN-RUNTIME-04  il type comune maven non viene ridefinito
MAVEN-RUNTIME-05  version authority = current index https://dlcdn.apache.org/maven/maven-4/
MAVEN-RUNTIME-06  version grammar corrente = canonical x.y.z-rc-n oppure x.y.z
MAVEN-RUNTIME-07  current listing contiene soltanto versioni installabili e viene ordinato oldest -> latest
MAVEN-RUNTIME-08  exact e compare richiedono versioni correntemente pubblicate/installabili
MAVEN-RUNTIME-09  ordering RC/GA è adapter-specific e non usa precisione numerica host per i componenti
MAVEN-RUNTIME-10  artifact URL resta esattamente sul dlcdn Apache indicato dall'utente
MAVEN-RUNTIME-11  checksum SHA-512 usa il sidecar ufficiale downloads.apache.org; questo supersede solo l'host checksum di MAVEN-PKG-09
MAVEN-RUNTIME-12  sidecar corrente = una sola entry 128-hex; digest normalizzato lowercase
MAVEN-RUNTIME-13  artifact size deriva da http-fetch -l senza download finale nell'adapter
MAVEN-RUNTIME-14  descriptor verso pkg_download = name/url/size/digest=sha512
MAVEN-RUNTIME-15  nessun downgrade digest, archive fallback, custom type o URL-template generico
MAVEN-RUNTIME-16  digest/pkg_download/http-fetch generici già esistenti vengono riusati e non duplicati
MAVEN-RUNTIME-17  dependency java >=17, binding/env e no-auto-install restano invariati
MAVEN-RUNTIME-18  task scope permanente = repository adapter Maven; live install richiede provider Java eleggibile
MAVEN-RUNTIME-19  pkg-catalog non viene modificato da questa unità
MAVEN-RUNTIME-20  Git resta forward-only
```
