# Decisione — Integrazione package Google Chrome

Date: 2026-09-15  
Status: **Accepted**

## 1. Scopo

Questa decisione introduce il package `chrome` nel catalogo RumiAI usando il package model Model 2.0 corrente e la repository APT Stable ufficiale di Google come autorità runtime.

L'indice autorevole iniziale è:

```text
https://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages
```

Questa unità integra il normale Google Chrome Stable distribuito da Google. Non sostituisce il prodotto con Chrome for Testing, Chromium o un redistributore terzo.

## 2. Package identity, target e command set

Il package RumiAI si chiama:

```text
chrome
```

Il command entry della concrete package version è:

```text
chrome
```

La baseline supportata è soltanto:

```text
linux-x86_64
```

perché l'upstream scelto pubblica il package Stable ufficiale nella repository APT `binary-amd64`.

Non vengono inventati stream ARM64, macOS o Windows usando fonti differenti.

`pkg install chrome` installa soltanto una concrete version. Non seleziona automaticamente il default e non crea binding pubblici fuori dal lifecycle `pkg default` già esistente.

## 3. Repository type e descriptor

Il repository type product-specific è:

```text
chrome
```

che seleziona:

```text
lib/sys/sh/pkg-repository-chrome.lib.sh
```

L'adapter è deliberatamente monoproduct. Il descriptor contiene soltanto:

```text
repository/type  chrome
```

La URL della repository ufficiale e l'identità upstream `google-chrome-stable` appartengono al contratto dell'adapter e non diventano configurazione generica del catalogo.

Non vengono introdotti:

```text
repository/type = custom
base_url
artifact_url_template
repo_path
mirror
archive fallback
```

I campi del descriptor restano file scalari dichiarativi e non vengono source/eval/eseguiti.

## 4. Autorità corrente delle versioni

Discovery, latest, exact resolution e verifica di installabilità usano esclusivamente la stanza corrente:

```text
Package: google-chrome-stable
Architecture: amd64
```

dell'indice APT Stable ufficiale.

Sono installabili soltanto versioni ancora pubblicate dal vendor nell'indice corrente.

Una release rimossa da Google non è supportata da RumiAI anche se:

- era stata installabile in passato;
- compare ancora nella cronologia Git del catalogo;
- esiste ancora una concrete package version già materializzata localmente;
- la sua versione compare come anchor in una revisione non ancora ripulita del catalogo.

RumiAI non mantiene un archivio storico sostitutivo e non tenta mirror o fallback per rendere nuovamente installabile una release rimossa dal vendor.

Quando una versione richiesta o un range anchor non è più presente nell'indice upstream corrente, l'operazione fallisce chiusa a runtime con una diagnostica esplicita che identifica almeno:

```text
repository=chrome
reason=upstream-version-unavailable
version=<versione>
```

La manutenzione/revisione del `pkg-catalog` rimuove o avanza range e anchor non più pubblicati. Il runtime non modifica autonomamente il catalogo.

## 5. Version identity e ordering

La `Version` APT completa è l'identità package RumiAI, inclusa la Debian revision. La forma iniziale accettata è:

```text
<major>.<minor>.<build>.<patch>-<revision>
```

con esattamente cinque componenti decimali canonici, senza zeri iniziali salvo il valore `0`.

Esempio:

```text
153.0.8010.36-1
```

Il core `pkg` continua a trattare la versione come identificatore opaco.

L'adapter Chrome implementa il proprio ordering confrontando numericamente, nell'ordine:

```text
major
minor
build
patch
revision
```

senza usare `sort -V`, `dpkg --compare-versions`, SemVer o ordinamento lessicografico globale.

Prima di confrontare due versioni, `pkg_repository_compare_versions` deve verificare che entrambe siano ancora installabili nell'indice upstream corrente. Una versione rimossa rende il confronto fallito; non viene confrontata offline soltanto perché la stringa è sintatticamente valida.

`pkg_repository_list_versions` restituisce le versioni attualmente pubblicate ordinate `oldest -> latest` secondo lo stesso comparator product-specific.

La resolution senza versione restituisce la maggiore versione installabile corrente secondo lo stesso ordine.

## 6. Autorità degli artifact

Per la versione selezionata, name, URL relativo, size e SHA-256 derivano dalla stessa stanza APT ufficiale attraverso:

```text
Version
Filename
Size
SHA256
```

La stanza deve descrivere esattamente:

```text
Package: google-chrome-stable
Architecture: amd64
Filename: pool/main/g/google-chrome-stable/google-chrome-stable_<Version>_amd64.deb
```

L'URL finale è:

```text
https://dl.google.com/linux/chrome/deb/<Filename>
```

Il descriptor emesso verso `pkg_download` resta esattamente:

```text
name=<basename di Filename>
url=<URL ufficiale>
size=<Size in byte decimali>
digest=sha256:<SHA256 normalizzato lowercase>
```

`digest_type=sha256` è obbligatorio nel range Chrome. `digest_regex` non viene introdotto.

L'adapter non scarica direttamente l'artifact finale. Il download e la verifica restano esclusivamente responsabilità di `pkg_download`/`http-fetch`.

## 7. Extract, command e sandbox

L'artifact ufficiale è:

```text
format=deb
```

La pipeline resta invariata:

```text
repository resolution
-> pkg_download
-> pkg_extract
-> pkg_integrate
```

Il supporto `deb` già esistente viene riutilizzato; non viene introdotto un extractor Chrome-specifico.

Dopo l'estrazione, il direct link del command `chrome` è:

```text
opt/google/chrome/google-chrome
```

Il package command usa il launcher corrente:

```text
#!/usr/bin/env m

. "$m_LIB_DIR/sys/sh/pkg-launch.lib.sh"

launcher "chrome" "$@"
```

La normale HOME isolation del launcher resta il meccanismo di isolamento dello stato utente del browser. Non viene introdotto un secondo launcher né un `--user-data-dir` RumiAI-specifico.

Google Chrome richiede il setuid sandbox Linux distribuito nel package. Il range dichiara:

```text
setuid_root=opt/google/chrome/chrome-sandbox
```

La materializzazione riusa integralmente il meccanismo `setuid_root` corrente e la sua autorizzazione privilegiata. Non viene usato `--no-sandbox` e non viene introdotta logica di privilege escalation Chrome-specifica.

## 8. Initial range

La prima range definition è:

```text
n0001=153.0.8010.36-1
```

L'anchor identifica la prima versione dichiarata compatibile con questa package definition e deve restare installabile upstream per partecipare alla range resolution corrente.

Quando Google la rimuove dall'indice, l'installazione deve fallire chiaramente finché la revisione del catalogo non elimina o sostituisce il range obsoleto. Questo comportamento è intenzionale e applica la policy generale secondo cui RumiAI non supporta release rimosse dal vendor.

## 9. Scope escluso

Questa unità non introduce:

```text
Chrome for Testing
Chromium come alias di chrome
canali beta/dev/canary
repository APT generica
parser Debian package universale
supporto storico di release rimosse
mirror o archive repository
nuova primitive di download
nuova primitive di extract
nuova primitive di launch
nuova primitive setuid
nuova environment variable RumiAI
nuovo dependency solver per dipendenze Debian
```

Qualsiasi estensione futura richiede un requisito concreto e una decisione separata quando modifica il contratto fissato qui.

## 10. Testing

La copertura permanente deve proteggere almeno:

```text
repository descriptor monoproduct type=chrome
rifiuto di campi repository sconosciuti
parsing fail-closed dell'indice APT
selezione esclusiva di google-chrome-stable + amd64
version grammar canonica a.b.c.d-r
list_versions oldest -> latest secondo ordering Chrome
latest coerente con lo stesso ordering
exact resolution soltanto per versioni ancora pubblicate
clear runtime failure per versione rimossa
compare_versions valida entrambi gli operandi contro l'upstream corrente
compare_versions numerico sui cinque componenti e non lessicografico
artifact Filename/Size/SHA256 dalla stessa stanza della versione
rifiuto di Filename non canonico o metadata incompleti/duplicati
SHA-256 obbligatorio
URL finale sotto https://dl.google.com/linux/chrome/deb/
descriptor conforme a pkg_download
catalogo soltanto linux-x86_64
format=deb
direct link opt/google/chrome/google-chrome
setuid_root opt/google/chrome/chrome-sandbox
pkg install non seleziona automaticamente il default
```

La live validation di download/install/launch reale resta revision-specific. La sola presenza della definition e dei test fixture non costituisce evidenza di physical validation su Linux x86_64.

## 11. Invarianti

```text
CHROME-PKG-01  package identity = chrome; command set = chrome
CHROME-PKG-02  baseline target = linux-x86_64 soltanto
CHROME-PKG-03  repository type product-specific = chrome
CHROME-PKG-04  descriptor repository contiene soltanto type=chrome
CHROME-PKG-05  autorità corrente = indice APT Stable Google binary-amd64
CHROME-PKG-06  package upstream = google-chrome-stable, architecture = amd64
CHROME-PKG-07  versione RumiAI = Version APT completa a.b.c.d-r
CHROME-PKG-08  core pkg mantiene le versioni opache; ordering product-specific nell'adapter
CHROME-PKG-09  compare_versions valida entrambi gli operandi contro l'upstream corrente prima del confronto
CHROME-PKG-10  una versione rimossa dal vendor è unsupported e produce failure chiuso con diagnostica upstream-version-unavailable
CHROME-PKG-11  nessun archivio, mirror o fallback preserva installabilità di release rimosse
CHROME-PKG-12  la revisione del pkg-catalog ripulisce range/anchor non più pubblicati; il runtime non riscrive il catalogo
CHROME-PKG-13  Filename/Size/SHA256 provengono dalla stessa stanza APT della versione selezionata
CHROME-PKG-14  artifact URL = https://dl.google.com/linux/chrome/deb/<Filename>
CHROME-PKG-15  descriptor artifact conserva name/url/size/digest=sha256
CHROME-PKG-16  nessun bypass di http-fetch/pkg_download/pkg_extract/pkg_integrate
CHROME-PKG-17  format = deb e riusa l'extractor corrente
CHROME-PKG-18  direct link chrome = opt/google/chrome/google-chrome
CHROME-PKG-19  setuid_root = opt/google/chrome/chrome-sandbox e riusa il meccanismo privilegiato corrente
CHROME-PKG-20  initial range anchor = 153.0.8010.36-1
CHROME-PKG-21  pkg install non seleziona automaticamente default o binding pubblici
CHROME-PKG-22  nessun repository APT generico, URL template generico o nuova primitive di launch/download/setuid viene introdotto
CHROME-PKG-23  Git resta forward-only
```
