# Decisione — Catalogo package Chromium

Date: 2026-09-15  
Status: **Accepted — catalog definition authorized; runtime support pending explicit authorization**

## 1. Scopo

Questa decisione definisce il package `chromium` nel catalogo RumiAI usando il package model corrente.

La sorgente upstream è il bucket ufficiale Google Cloud Storage:

```text
chromium-browser-snapshots
```

Non viene introdotto un repository type generico `custom`, un URL template generico o un secondo package model.

Questa unità autorizza la definizione concreta in `pkg-catalog`. Le modifiche necessarie a `rumiai-os` per rendere operativo il nuovo repository type e il digest scelto restano pending finché l'utente non autorizza esplicitamente quella fase di implementazione.

## 2. Preflight corrente

HEAD remoti verificati prima della scrittura:

```text
rumiai-dev    1d34e8966d61ec5134f6790e2dae1cd5dc64b4e2
rumiai-os     a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests  7ea82348a8bb9fa03da54ed4bd0525d04a979895
pkg-catalog   3823048b38de539e37fdb1ea92cf5679bc5fd5f9
```

Fonti correnti riesaminate:

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/MODEL-2.0-MIGRATION.md
decisions/rumiai-os/2026-09-07-package-catalog-streams-and-ordered-ranges.md
decisions/rumiai-os/2026-09-08-package-github-descriptor-and-range-artifact-integrity.md
decisions/rumiai-os/2026-09-14-nodejs-package-integration.md
rumiai-tests/tests/rumiai-os/pkg/install.test
```

Sono stati inoltre verificati i mapping ufficiali Chromium presenti nelle configurazioni `infra/archive_config` upstream e gli endpoint Google Storage indicati dall'utente.

## 3. Correzione digest applicabile al package model

L'utente ha fissato esplicitamente la seguente regola:

> sono accettabili anche digest diversi da SHA-256; quando l'upstream espone più digest, deve essere scelto quello più sicuro tra quelli disponibili.

Questa correzione supersede la precedente limitazione secondo cui il primo `digest_type` concreto `sha256` fosse anche l'unico digest ammissibile in assoluto.

La regola resta fail-closed:

```text
il digest deve provenire dall'upstream autorevole
non viene calcolato e hardcodato nel catalogo
il descriptor di download deve dichiarare esplicitamente l'algoritmo
pkg_download deve verificare lo stesso algoritmo sull'artifact scaricato
```

Quando un range dichiara un algoritmo specifico, la sua assenza nell'upstream rende quel range non applicabile; non viene effettuato un downgrade implicito a un digest più debole. Se una futura regione upstream richiede un digest differente, viene aperto un nuovo range.

## 4. Package identity e command

Il package canonico è:

```text
chromium
```

Il command entry pubblico della concrete package version è:

```text
chromium
```

Non vengono introdotti alias `chrome`, `google-chrome` o `chromium-browser`.

`pkg install chromium` rende disponibile una concrete version ma non seleziona automaticamente il default e non crea binding pubblici fuori dal lifecycle `pkg default` corrente.

## 5. Repository type Chromium

Il repository type product-specific è:

```text
chromium
```

Il descriptor contiene esattamente:

```text
repository/type      chromium
repository/platform  <platform-upstream>
```

`platform` identifica uno dei path ufficiali del bucket Chromium:

```text
Linux_x64
Mac
Mac_Arm
Win_x64
Win_Arm64
```

Il bucket `chromium-browser-snapshots` è parte del contratto monoproduct dell'adapter e non viene duplicato come campo configurabile del catalogo.

Non vengono introdotti:

```text
repository/type = custom
base_url
artifact_url_template
bucket configurabile
mirror configurabile
```

## 6. Versioni Chromium

Le versioni del package RumiAI sono le commit-position snapshot upstream, rappresentate come stringhe decimali positive, per esempio:

```text
1697793
```

Non vengono convertite in versioni browser `major.minor.build.patch`.

Per ciascuna piattaforma, `latest` è ottenuto dal file ufficiale:

```text
<platform>/LAST_CHANGE
```

tramite l'endpoint media Google Storage.

Una versione esplicita è valida soltanto se esiste l'artifact Chromium previsto sotto:

```text
<platform>/<version>/<archive>
```

`pkg_repository_compare_versions` ordina le commit-position numericamente senza introdurre SemVer nel core `pkg`.

`pkg_repository_list_versions`, quando implementato, enumera le snapshot che possiedono l'artifact Chromium previsto per lo stream e le produce in ordine oldest -> latest. Il core continua a trattare le versioni come identificatori opachi.

## 7. Stream target-specific e mapping upstream

Il catalogo definisce esclusivamente gli stream ufficialmente disponibili per i target RumiAI correnti:

```text
catalog-linux-x86_64
    platform = Linux_x64
    archive  = chrome-linux.zip

catalog-macos-x86_64
    platform = Mac
    archive  = chrome-mac.zip

catalog-macos-arm64
    platform = Mac_Arm
    archive  = chrome-mac.zip

catalog-windows-x86_64
    platform = Win_x64
    archive  = chrome-win.zip

catalog-windows-arm64
    platform = Win_Arm64
    archive  = chrome-win.zip
```

Non viene creato `catalog-linux-arm64`: il bucket ufficiale Chromium snapshot non pubblica un equivalente desktop Linux ARM64 nel modello verificato per questa unità.

Non esiste fallback tra stream target-specific.

## 8. Anchor iniziali

Gli anchor iniziali sono le snapshot correnti osservate durante questa unità:

```text
linux-x86_64     n0001=1697793
macos-x86_64     n0001=1697801
macos-arm64      n0001=1697808
windows-x86_64   n0001=1697030
windows-arm64    n0001=1697025
```

Ogni anchor dichiara la prima snapshot supportata dalla package definition corrente per quello stream. Snapshot precedenti non vengono dichiarate compatibili senza verifica retroattiva.

Le snapshot successive restano automaticamente nello stesso ultimo range finché il contratto di artifact/integration non cambia.

## 9. Artifact resolution e URL

Il range seleziona esattamente:

```text
Linux_x64  -> ^chrome-linux\.zip$
Mac        -> ^chrome-mac\.zip$
Mac_Arm    -> ^chrome-mac\.zip$
Win_x64    -> ^chrome-win\.zip$
Win_Arm64  -> ^chrome-win\.zip$
```

Il download finale usa l'endpoint ufficiale indicato dall'utente:

```text
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/<url-encoded-object>?alt=media
```

La metadata resolution usa la Google Cloud Storage JSON API per lo stesso oggetto e ottiene almeno:

```text
name
size
md5Hash
crc32c
```

`size` è il numero di byte esatto dichiarato dall'upstream.

## 10. Integrity

Google Cloud Storage espone CRC32C per tutti gli oggetti e MD5 per gli oggetti non compositi che soddisfano il relativo contratto GCS.

Per gli archive Chromium correnti verificati, il range dichiara:

```text
digest_type = md5
```

perché, tra MD5 e CRC32C, MD5 è il controllo di integrità più forte disponibile dall'upstream per questo caso concreto.

L'adapter deve convertire il valore base64 di `md5Hash` nella rappresentazione esadecimale usata dal descriptor di download, senza sostituirlo con un digest calcolato localmente e salvato nel catalogo.

Se `md5Hash` non è disponibile per una futura snapshot, la resolution del range corrente fallisce. Un eventuale passaggio a CRC32C richiede un nuovo range dal primo artifact che non espone più MD5, invece di un downgrade silenzioso dentro lo stesso range.

Il descriptor verso `pkg_download` deve mantenere il contratto:

```text
name=<archive>
url=<media-url>
size=<decimal-bytes>
digest=md5:<hex-digest>
```

## 11. Extract e integrazione

Tutti gli artifact correnti sono ZIP:

```text
format = zip
```

`pkg_extract` continua a normalizzare la useful root prima di `pkg_integrate`.

I direct link sono:

```text
linux-x86_64
    chromium -> chrome

macos-x86_64
macos-arm64
    chromium -> Chromium.app/Contents/MacOS/Chromium

windows-x86_64
windows-arm64
    chromium -> chrome.exe
```

Per Linux l'archive ufficiale contiene il sandbox helper:

```text
chrome_sandbox
```

Il range usa quindi la primitive già esistente:

```text
setuid_root
```

con valore:

```text
chrome_sandbox
```

Non viene introdotto un nuovo meccanismo di privilege setup.

La normale HOME isolation del launcher package resta il meccanismo per lo user state di Chromium; questa unità non introduce path di stato custom.

## 12. Runtime support pending

Alla revisione `rumiai-os` osservata nel preflight:

```text
lib/sys/sh/pkg-repository-chromium.lib.sh
```

non esiste.

Inoltre il comando `digest` e `pkg_download` correnti implementano soltanto `sha256`.

Per rendere operativo il catalogo saranno quindi necessari, in una fase separata esplicitamente autorizzata dall'utente:

```text
repository adapter chromium
supporto digest md5 nella primitive digest
supporto digest=md5:<hex> in pkg_download
permanent test proporzionati
live validation revision-specific del download/install/launch
```

Questa decisione non autorizza da sola tali scritture in `rumiai-os`.

## 13. Testing richiesto alla fase runtime

La copertura permanente dovrà proteggere almeno:

```text
repository descriptor type=chromium + platform esatto
rifiuto di platform sconosciute e campi repository sconosciuti
latest tramite <platform>/LAST_CHANGE
versioni commit-position decimali e ordering numerico adapter-specific
exact resolution soltanto quando l'artifact esiste
artifact mapping corretto per i cinque stream
metadata GCS name/size/md5Hash coerenti con lo stesso oggetto
MD5 preferito a CRC32C quando entrambi disponibili
assenza di downgrade implicito quando md5Hash manca nel range md5
conversione base64 MD5 -> hex corretta
descriptor name/url/size/digest=md5 conforme a pkg_download
nessun Linux ARM64 ufficiale inventato
link chromium corretti per Linux/macOS/Windows
setuid_root=chrome_sandbox soltanto su Linux
pkg install non seleziona automaticamente default
```

La physical validation resta revision-specific e non è soddisfatta dalla sola presenza del catalogo.

## 14. Invarianti

```text
CHROMIUM-PKG-01  package identity e command pubblico = chromium
CHROMIUM-PKG-02  upstream autorevole = Google Cloud Storage bucket chromium-browser-snapshots
CHROMIUM-PKG-03  repository type product-specific = chromium
CHROMIUM-PKG-04  repository descriptor = type + platform; il bucket è fisso nell'adapter
CHROMIUM-PKG-05  version identity = commit-position snapshot decimale upstream
CHROMIUM-PKG-06  latest deriva esclusivamente da <platform>/LAST_CHANGE
CHROMIUM-PKG-07  exact version richiede l'esistenza dell'artifact previsto
CHROMIUM-PKG-08  ordering delle versioni è numerico nell'adapter; nessun SemVer nel core
CHROMIUM-PKG-09  stream = Linux_x64, Mac, Mac_Arm, Win_x64, Win_Arm64 mappati alle cinque osarch dichiarate
CHROMIUM-PKG-10  nessun catalog-linux-arm64 viene inventato
CHROMIUM-PKG-11  artifact = chrome-linux.zip / chrome-mac.zip / chrome-win.zip secondo stream
CHROMIUM-PKG-12  artifact size e digest provengono dinamicamente dai metadata GCS dello stesso oggetto
CHROMIUM-PKG-13  digest corrente = md5 perché più forte di CRC32C tra quelli esposti dal caso concreto
CHROMIUM-PKG-14  digest più debole non sostituisce implicitamente quello dichiarato dal range
CHROMIUM-PKG-15  digest concreti non vengono hardcodati nel catalogo
CHROMIUM-PKG-16  format = zip per tutti gli stream correnti
CHROMIUM-PKG-17  Linux link=chrome e setuid_root=chrome_sandbox
CHROMIUM-PKG-18  macOS link=Chromium.app/Contents/MacOS/Chromium
CHROMIUM-PKG-19  Windows link=chrome.exe
CHROMIUM-PKG-20  nessun custom repository type, URL template generico, mirror selector o nuova state primitive
CHROMIUM-PKG-21  runtime adapter/digest support resta pending finché non autorizzato esplicitamente
CHROMIUM-PKG-22  Git resta forward-only
```
