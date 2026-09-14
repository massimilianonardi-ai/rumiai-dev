# Decisione — Integrazione package Node.js

Date: 2026-09-14  
Status: **Accepted**

## 1. Scopo

Questa decisione introduce il package `nodejs` nel catalogo RumiAI usando esclusivamente il package model Model 2.0 corrente.

La peculiarità dell'upstream Node.js è che le release/versioni autorevoli sono pubblicate nel repository GitHub:

```text
nodejs/node
```

mentre i binary artifact ufficiali multipiattaforma sono pubblicati sotto:

```text
https://nodejs.org/dist/<version>/
```

La decisione mantiene questa separazione senza modificare il core `pkg`, senza generalizzare un nuovo URL-template model e senza introdurre un repository type `custom`.

## 2. Package identity e command set

Il package RumiAI si chiama:

```text
nodejs
```

I command entry della concrete package version sono:

```text
node
npm
npx
```

Non viene introdotto un command artificiale `nodejs`.

`pkg install nodejs` continua a installare soltanto una concrete version. Non seleziona automaticamente il default e non crea binding pubblici fuori dal lifecycle `pkg default` già esistente.

## 3. Repository type e descriptor

Il repository type product-specific è:

```text
nodejs
```

che seleziona:

```text
lib/sys/sh/pkg-repository-nodejs.lib.sh
```

Il descriptor del type `nodejs` usa gli stessi campi di coordinate GitHub necessari al caso concreto:

```text
repository/type        nodejs
repository/owner       nodejs
repository/repository  node
```

L'adapter è deliberatamente monoproduct e valida esattamente queste coordinate.

Non vengono introdotti:

```text
repository/type = custom
base_url
artifact_url_template
repo_path
```

I campi restano file scalari dichiarativi e non vengono source/eval/eseguiti.

## 4. Autorità delle release: GitHub API

Discovery, latest, exact resolution, enumeration e ordering delle versioni usano esclusivamente le GitHub Release API del repository `nodejs/node`, secondo la stessa semantica già fissata per il repository type GitHub:

```text
GET /repos/nodejs/node/releases
GET /repos/nodejs/node/releases/latest
GET /repos/nodejs/node/releases/tags/<version>
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

`pkg_repository_list_versions` produce la successione installabile:

```text
oldest -> latest
```

secondo l'ordine GitHub già fissato:

```text
created_at
-> published_at come disambiguazione deterministica
```

`pkg_repository_compare_versions` usa la stessa successione e non interpreta il tag come SemVer.

Il core `pkg` continua quindi a trattare le versioni Node.js come identificatori opachi. Non vengono introdotti nel core né nell'adapter Node.js:

```text
parsing major/minor/patch
confronto numerico dei componenti
confronto SemVer
ordinamento lessicografico dei tag
```

La resolution senza versione usa la GitHub release `latest`. Non viene introdotta una selezione implicita LTS.

Il file Node.js `dist/index.tab` non partecipa alla resolution o all'ordering del package RumiAI.

## 5. Autorità degli artifact: nodejs.org/dist

Le GitHub release Node.js non sono usate come repository dei binary artifact. L'adapter verifica prima che la versione richiesta corrisponda a una full release GitHub installabile e poi risolve il prebuilt ufficiale attraverso `nodejs.org/dist`.

Il range package seleziona il filename tramite il corrente:

```text
archive_regex
```

L'adapter ricava quindi:

```text
name + sha256
    -> https://nodejs.org/dist/<version>/SHASUMS256.txt

size in byte esatti
    -> https://nodejs.org/dist/<version>/

url
    -> https://nodejs.org/dist/<version>/<name>
```

Gli eventuali `assets[]` presenti o assenti nella release GitHub non sono la fonte dell'artifact Node.js.

Il descriptor emesso verso `pkg_download` resta esattamente nel contratto corrente:

```text
name=<artifact-name>
url=<artifact-url>
size=<decimal-bytes>
digest=sha256:<hex-digest>
```

Per il package Node.js corrente `digest_type=sha256` è obbligatorio. `digest_regex` non viene introdotto da questa unità.

Il download resta esclusivamente responsabilità di `pkg_download`/`http-fetch`; l'adapter non scarica direttamente l'artifact finale e non rilassa la verifica obbligatoria della size.

## 6. Target RumiAI e mapping artifact

La baseline copre tutte le `osarch` correnti supportate dal package model:

```text
linux-arm64
linux-x86_64
macos-arm64
macos-x86_64
windows-arm64
windows-x86_64
```

Mapping ufficiale:

```text
linux-arm64     -> node-<version>-linux-arm64.tar.xz
linux-x86_64    -> node-<version>-linux-x64.tar.xz
macos-arm64     -> node-<version>-darwin-arm64.tar.gz
macos-x86_64    -> node-<version>-darwin-x64.tar.gz
windows-arm64   -> node-<version>-win-arm64.zip
windows-x86_64  -> node-<version>-win-x64.zip
```

La prima range definition parte da:

```text
n0001=v26.8.2
```

L'anchor indica la prima versione dichiarata compatibile con questa package definition; non definisce una policy LTS.

## 7. Extract, direct link e runtime environment

La pipeline resta invariata:

```text
repository resolution
-> pkg_download
-> pkg_extract
-> pkg_integrate
```

`pkg_extract` continua a consegnare a `pkg_integrate` la useful root normalizzata.

Per Linux e macOS i direct link sono:

```text
node -> bin/node
npm  -> bin/npm
npx  -> bin/npx
```

Il package `env` prepende al `PATH` del launch context:

```text
<concrete>/root/bin
```

così gli upstream wrapper `npm`/`npx` risolvono il `node` appartenente alla stessa concrete package version.

Per Windows i direct link sono:

```text
node -> node.exe
npm  -> npm
npx  -> npx
```

Il binary ZIP ufficiale materializza sia gli entry Windows `.cmd` sia gli script `npm`/`npx`; questi ultimi sono gli upstream wrapper destinati anche a Cygwin/MINGW e sono quindi i target coerenti con il `exec` POSIX del launcher RumiAI. Il package `env` prepende:

```text
<concrete>/root
```

al `PATH` del launch context.

Non viene introdotto un secondo launcher né viene modificato il contratto `launcher` corrente. In particolare questa unità non aggiunge `chmod` post-extract o altre correzioni di permission specifiche per ZIP: la validazione fisica Windows deve confermare che i target estratti soddisfino il corrente requisito `-x` del launcher nell'ambiente POSIX-compatible di riferimento. Un eventuale failure richiede una decisione separata e non autorizza workaround impliciti nel package Node.js.

## 8. Scope escluso

Questa unità non introduce:

```text
selettore LTS
stream LTS separato
gestione dei package npm da parte di pkg
npm prefix globale RumiAI
cache npm condivisa
nuova facility/dependency
nuovo launcher
nuova environment variable RumiAI
URL template generico per repository adapter
SemVer nel core package
```

Questi temi restano separati e richiedono una necessità concreta prima di qualsiasi decisione.

## 9. Testing

La copertura permanente deve proteggere almeno:

```text
repository descriptor type=nodejs, owner=nodejs, repository=node
rifiuto di campi repository sconosciuti o coordinate diverse
latest ed exact version resolution tramite GitHub Release API
full release only: draft/prerelease esclusi
successione oldest -> latest secondo created_at/published_at
compare_versions coerente con lo stesso ordine GitHub
nessuna interpretazione SemVer/numerica del tag
nessun uso di dist/index.tab per version discovery/order
verifica della exact GitHub release prima dell'artifact
artifact selection univoca da SHASUMS256.txt
SHA-256 obbligatorio
size in byte esatti dall'indice ufficiale della release Node.js
URL finale https://nodejs.org/dist/<version>/<name>
descriptor conforme a pkg_download
catalogo per tutte le sei osarch correnti
node/npm/npx ed env coerenti per POSIX e Windows
pkg install non seleziona automaticamente il default
```

La live validation del download/install/launch reale resta revision-specific e deve essere eseguita su revisioni committed secondo `TESTING.md` prima di considerare fisicamente validata questa unità.

La presenza della package definition Windows non costituisce da sola evidenza di physical validation su un host Windows POSIX-compatible.

## 10. Invarianti

```text
NODEJS-PKG-01  package identity = nodejs; command set = node, npm, npx
NODEJS-PKG-02  repository type product-specific = nodejs
NODEJS-PKG-03  repository coordinates = GitHub nodejs/node
NODEJS-PKG-04  GitHub Release API è autorità per discovery/latest/exact/list/order delle release
NODEJS-PKG-05  full release installabile = draft=false e prerelease=false
NODEJS-PKG-06  ordering Node.js segue created_at -> published_at come il repository model GitHub corrente
NODEJS-PKG-07  il core pkg e l'adapter Node.js non interpretano SemVer/major/minor/patch
NODEJS-PKG-08  dist/index.tab non viene usato per version discovery o ordering
NODEJS-PKG-09  binary artifact source = https://nodejs.org/dist/<version>/
NODEJS-PKG-10  artifact name+SHA256 provengono da SHASUMS256.txt; size dall'indice ufficiale della release
NODEJS-PKG-11  artifact URL = https://nodejs.org/dist/<version>/<name>
NODEJS-PKG-12  descriptor artifact conserva name/url/size/digest=sha256
NODEJS-PKG-13  nessun bypass di http-fetch/pkg_download/pkg_extract/pkg_integrate
NODEJS-PKG-14  archive_regex e digest_type restano range-level
NODEJS-PKG-15  initial range anchor = v26.8.2
NODEJS-PKG-16  target = linux/macos/windows x arm64/x86_64 secondo le osarch correnti
NODEJS-PKG-17  POSIX direct link = bin/node, bin/npm, bin/npx; PATH prepende concrete root/bin
NODEJS-PKG-18  Windows direct link = node.exe, npm, npx; PATH prepende concrete root; gli script npm/npx sono gli upstream wrapper Cygwin/MINGW
NODEJS-PKG-19  pkg install non seleziona automaticamente default o binding pubblici
NODEJS-PKG-20  nessun LTS selector, generic URL template o nuova primitive di launch viene introdotto
NODEJS-PKG-21  Git resta forward-only
```
