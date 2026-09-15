# Decisione — Supporto runtime package Chromium

Date: 2026-09-15  
Status: **Accepted**

## 1. Scopo e autorizzazione

Questa decisione attiva la fase runtime lasciata pending da `2026-09-15-chromium-package-catalog.md`. L'utente ha autorizzato esplicitamente la modifica di `rumiai-os` per rendere operativo il package Chromium.

Scope:

```text
lib/sys/sh/pkg-repository-chromium.lib.sh
supporto MD5 in bin/sys/digest
supporto digest=md5:<hex> in pkg_download
test permanenti proporzionati in rumiai-tests
```

Non modifica `pkg-catalog`, package/stream model, lifecycle default/binding o primitive di integrazione.

## 2. Preflight

HEAD remoti verificati prima della scrittura:

```text
rumiai-dev    ad26848e92aad722b6a35359f243f69aad6a7d58
rumiai-os     a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests  7ea82348a8bb9fa03da54ed4bd0525d04a979895
pkg-catalog   b2804edca0f4e20168ef39da88ac1c4c1832c181
```

Riletti `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, Model 2.0 e le decisioni correnti su repository descriptor, digest/extract, `pkg_download`, repository version comparison, Node.js, Chromium e la nuova decisione separata Google Chrome (`chrome`). Rilette inoltre le implementazioni correnti di `digest`, `pkg_download`, `pkg_install`, `json.lib.sh`, gli adapter GitHub/Node.js e i test pertinenti.

La condizione pending `CHROMIUM-PKG-21` è soddisfatta dalla presente autorizzazione; gli altri invarianti Chromium restano invariati.

## 3. `digest` supporta MD5

La utility general-purpose accetta ora:

```text
digest -a md5
digest -a md5 -- <file>
```

Output MD5: esattamente 32 cifre esadecimali lowercase + LF. `digest` continua a calcolare soltanto il digest dei byte e non verifica expected value o metadata package.

Ordine backend MD5:

```text
1  cksum -a md5, solo se la capability è realmente supportata
2  md5sum
3  md5 -q
4  openssl dgst -md5
```

Il fallback riguarda disponibilità/capability iniziale; dopo la selezione, un errore operativo del backend non provoca retry. Exit status e comportamento SHA-256 restano invariati.

## 4. `pkg_download` supporta MD5

Il campo `digest` accetta ora esattamente:

```text
sha256:<64-hex>
md5:<32-hex>
```

Il valore viene normalizzato lowercase e verificato tramite:

```text
digest -a <algorithm> -- <target>
```

Restano invariati size-before-digest, cleanup su failure, repository-neutrality e divieto di backend host dentro `pkg_download`. CRC32C non viene aggiunto: il range Chromium corrente richiede MD5 e non autorizza downgrade impliciti.

## 5. Adapter Chromium

Adapter canonico:

```text
lib/sys/sh/pkg-repository-chromium.lib.sh
```

È una libreria POSIX shell sourced, regular file non eseguibile e senza shebang. Il repository descriptor contiene esattamente i file scalari `type` e `platform`, con:

```text
type = chromium
platform = Linux_x64 | Mac | Mac_Arm | Win_x64 | Win_Arm64
```

Campi sconosciuti, scalar non canonici, symlink o platform differenti sono failure.

Una versione Chromium è una commit-position decimale positiva canonica senza leading zero. `latest` usa esclusivamente:

```text
https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/<platform>%2FLAST_CHANGE?alt=media
```

Latest ed exact sono accettate soltanto se esiste l'artifact atteso per la platform.

`pkg_repository_compare_versions` valida entrambe le snapshot come installabili e confronta numericamente le rappresentazioni decimali senza convertirle in interi host a precisione limitata. L'ordinamento resta adapter-specific e non entra nel core `pkg`.

## 6. Artifact, metadata e integrity

Mapping invariato:

```text
Linux_x64             chrome-linux.zip
Mac, Mac_Arm          chrome-mac.zip
Win_x64, Win_Arm64    chrome-win.zip
```

`archive_regex` deve selezionare l'archive atteso. Per `<platform>/<version>/<archive>` l'adapter legge dalla GCS JSON API metadata dello stesso oggetto:

```text
name
size
md5Hash
crc32c
```

`name` deve coincidere esattamente con l'oggetto, `size` deve essere decimale canonico e nel range corrente `md5Hash` deve essere presente. Il descriptor emesso è:

```text
name=<archive>
url=https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/<encoded-object>?alt=media
size=<decimal-bytes>
digest=md5:<32-hex>
```

Google Storage serializza `md5Hash` in base64. La conversione dei 16 byte MD5 a 32 hex resta privata dell'adapter Chromium: non viene introdotta una nuova primitive globale `base64`/`hex`. Input incompatibile fallisce; non si sostituisce il metadata upstream con un digest hardcodato o ricalcolato.

Il range corrente richiede `digest_type=md5`, rifiuta `digest_regex` e non degrada a CRC32C se `md5Hash` manca.

## 7. `pkg_repository_list_versions`

Questa unità non simula `pkg_repository_list_versions` per Chromium. La decisione del catalogo lo aveva lasciato esplicitamente sotto la clausola “quando implementato” e il percorso corrente `pkg install` usa `resolve_version` + `compare_versions`, non l'enumerazione completa.

Una futura implementazione dovrà enumerare soltanto snapshot che possiedono realmente l'artifact atteso, oldest -> latest. Non si assume che tutte le commit-position intermedie esistano. La semantica generale dell'API resta invariata.

## 8. Testing

I test permanenti aggiunti proteggono almeno:

```text
MD5 CLI stdin/file e lowercase 32-hex
backend MD5 cksum -> md5sum -> md5 -> openssl e capability failure
pkg_download MD5, delega, validazione e cleanup
repository Chromium type+platform esatto e rifiuto unknown/Linux ARM64
latest via LAST_CHANGE ed exact solo con artifact esistente
compare numerico senza overflow e solo fra snapshot installabili
mapping dei cinque archive
coerenza metadata name/size/md5Hash con lo stesso oggetto
conversione base64 MD5 -> hex
assenza di downgrade senza md5Hash
digest_type=md5 e assenza digest_regex
```

La physical validation live download/install/launch resta revision-specific e separata dai test deterministici permanenti.

## 9. Invarianti

```text
CHROMIUM-RUNTIME-01  autorizzazione runtime attiva per questa unità
CHROMIUM-RUNTIME-02  adapter = lib/sys/sh/pkg-repository-chromium.lib.sh
CHROMIUM-RUNTIME-03  repository descriptor = type + platform esatti
CHROMIUM-RUNTIME-04  platform = Linux_x64, Mac, Mac_Arm, Win_x64, Win_Arm64
CHROMIUM-RUNTIME-05  version = commit-position decimale positiva canonica upstream
CHROMIUM-RUNTIME-06  latest usa LAST_CHANGE e richiede artifact installabile
CHROMIUM-RUNTIME-07  exact/compare richiedono snapshot con artifact esistente
CHROMIUM-RUNTIME-08  ordering numerico è solo dell'adapter Chromium
CHROMIUM-RUNTIME-09  metadata e media URL identificano lo stesso oggetto GCS
CHROMIUM-RUNTIME-10  md5Hash upstream viene convertito base64 -> 32 hex nell'adapter
CHROMIUM-RUNTIME-11  nessuna nuova primitive globale base64/hex
CHROMIUM-RUNTIME-12  digest supporta sha256 e md5; SHA-256 resta invariato
CHROMIUM-RUNTIME-13  backend MD5 = cksum capability -> md5sum -> md5 -q -> openssl
CHROMIUM-RUNTIME-14  pkg_download verifica sha256/md5 e resta repository-neutral
CHROMIUM-RUNTIME-15  range Chromium corrente richiede md5 senza downgrade a CRC32C
CHROMIUM-RUNTIME-16  nessun Linux ARM64, custom type, URL template generico o alias command
CHROMIUM-RUNTIME-17  list_versions Chromium non viene simulato
CHROMIUM-RUNTIME-18  live validation resta evidence revision-specific separata
CHROMIUM-RUNTIME-19  Git resta forward-only
```
