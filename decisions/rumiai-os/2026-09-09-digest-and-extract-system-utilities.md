# Decisione — Utility di sistema `digest` ed `extract`

Date: 2026-09-09  
Updated: 2026-09-10  
Status: **Accepted**

## Contesto

Durante l'implementazione di `pkg_download` e `pkg_extract` sono emerse due capability non fornite in modo uniforme dal baseline POSIX e già implementate tramite selezione di utility host:

```text
calcolo di digest crittografici
estrazione/decompressione di artifact
```

L'utente ha approvato di promuovere tali responsabilità a utility di sistema RumiAI general-purpose, analogamente al ruolo già svolto da `http-fetch` per HTTP/HTTPS.

L'obiettivo è confinare in un solo punto le dipendenze da utility host non uniformi, senza rendere `pkg` proprietario dei dettagli dei backend e senza creare un framework più generale di quanto richiesto dai consumer correnti.

Questa decisione corregge inoltre la precedente scelta di mantenere la capability SHA-256 privata dentro `pkg_download`: da questa revisione la capability pubblica canonica è `digest`.

L'aggiornamento del 2026-09-10 modifica esclusivamente la selezione del backend per il formato `dmg`, sulla base del PoC fisico riuscito sul reference macOS ARM64 con il DMG reale DBeaver 26.2.0. Il resto del contratto `digest`/`extract` rimane invariato.

---

## 1. Collocazione e command model

I comandi canonici sono:

```text
bin/sys/digest
bin/sys/extract
```

Sono command entrypoint RumiAI direttamente eseguibili e quindi usano:

```text
#!/usr/bin/env rumiai-os
```

Entrambi sono utility di sistema riusabili e non appartengono semanticamente al package manager.

---

## 2. `digest`

La CLI iniziale è:

```text
digest -a sha256
digest -a sha256 -- <file>
```

Semantica:

```text
senza pathname       legge i byte da stdin
con pathname         legge il regular file indicato
output               64 cifre esadecimali lowercase + LF
algoritmo baseline   sha256
```

Il pathname file è un operando dato e viene preceduto dal delimitatore `--`.

Il comando non verifica un digest atteso e non conosce descriptor package, repository o staging. Calcola esclusivamente il digest dei byte ricevuti.

### 2.1 Backend SHA-256

Ordine iniziale di selezione:

```text
1  cksum -a sha256, soltanto se la capability è realmente supportata
2  sha256sum
3  shasum -a 256
4  openssl dgst -sha256
```

Il fallback riguarda la disponibilità/capability iniziale. Un errore del backend selezionato è un errore operativo e non provoca retry con un backend successivo.

I backend leggono i byte da stdin quando possibile, evitando dipendenze dalla grammatica pathname specifica dei singoli tool.

L'output del backend viene validato: il risultato accettato deve essere esattamente un digest SHA-256 di 64 cifre esadecimali, poi normalizzato lowercase.

### 2.2 Exit status `digest`

```text
0  digest calcolato correttamente
1  input/backend/capability failure
2  invocazione invalida o algoritmo non supportato
```

Se nessun backend SHA-256 è disponibile, la diagnostica usa `execution.command-not-found` con `operation=digest` e capability `sha256`.

---

## 3. `extract`

La CLI iniziale è:

```text
extract <format> <artifact> <destination>
```

Input:

```text
format        token esplicito
artifact      regular file locale leggibile
destination   directory reale già esistente, non symlink
```

`extract` non deduce semanticamente il formato dal filename o dal repository type.

La destination **non** deve essere necessariamente vuota a livello della utility generale. Il requisito di staging vuoto resta responsabilità del consumer che ne ha bisogno, incluso `pkg_extract`.

---

## 4. Formati e backend di `extract`

Formati tar:

```text
tar
tar.gz  tgz
tar.bz2 tar.bzip2 tbz tbz2
tar.xz  txz
tar.zst tzst
```

Mapping:

```text
tar                         -> tar
tar.gz, tgz                 -> gzip + tar
tar.bz2, tar.bzip2,
tbz, tbz2                   -> bzip2 + tar
tar.xz, txz                 -> xz + tar
tar.zst, tzst               -> zstd + tar
```

Per i tar compressi il decompressor viene eseguito separatamente e il suo esito viene verificato prima dell'estrazione tar. Non si dipende da `pipefail` né dalle opzioni compression implementation-specific di `tar`.

Compressioni single-stream:

```text
gzip gz
bzip bzip2 bz2
xz
zstd zst
```

Backend:

```text
gzip/gz          -> gzip
bzip/bzip2/bz2   -> bzip2
xz                -> xz
zstd/zst          -> zstd
```

Il filename di output è derivato dal basename dell'artifact rimuovendo un suffisso coerente con il formato dichiarato. Un output parziale viene rimosso in caso di decompression failure.

ZIP family:

```text
zip jar war -> unzip
```

7-Zip family:

```text
7z 7zip -> primo disponibile fra 7zz, 7z, 7za
```

DMG usa una selezione per capability distinta:

```text
1  hdiutil + ditto, soltanto quando entrambe le capability sono disponibili
2  7zz
3  7z
4  7za
```

La coppia `hdiutil` + `ditto` costituisce un singolo backend composto. La sola presenza di uno dei due comandi non rende disponibile il backend nativo e provoca quindi la normale selezione del backend successivo.

La selezione non dipende da `uname` o da un nome di piattaforma: il backend nativo viene scelto quando le due capability necessarie sono disponibili. In pratica costituisce il percorso predefinito sul reference macOS corrente; 7-Zip resta il fallback cross-platform scelto da RumiAI quando tale backend non è disponibile.

Il fallback riguarda esclusivamente la disponibilità iniziale della capability. Dopo che un backend è stato selezionato, un errore operativo di attach, copia, detach o estrazione termina l'operazione con failure e **non** provoca retry con un backend successivo.

Il backend DMG nativo esegue semanticamente:

```text
hdiutil attach -readonly -nobrowse -mountpoint <temporary-mount> <artifact>
ditto <temporary-mount> <destination>
hdiutil detach <temporary-mount>
```

Il mountpoint temporaneo appartiene a `$m_TMP_DIR`. L'artifact viene montato read-only e non-browsable, il contenuto del volume viene copiato nella destination già esistente e il backend gestisce detach e cleanup sia nel percorso normale sia nei percorsi di errore/segnale. Un detach che non riesce resta un errore operativo; non autorizza il fallback a 7-Zip.

Poiché `hdiutil` e `ditto` non appartengono al contratto POSIX di RumiAI e la loro grammatica non viene assunta globalmente, tale dipendenza resta confinata esclusivamente nel backend `dmg` di `extract`.

Evidence sperimentale che ha giustificato questa modifica:

```text
rumiai-dev-PoCs/pocs/006-macos-dmg-extraction/
rumiai-dev-PoCs@a48039e8e7f2b7333439f22eb6cd0ee5e7a1658d
```

Debian package:

```text
deb -> dpkg-deb -x
```

Utility necessaria assente produce failure esplicito; non viene effettuato fallback semantico verso un formato diverso.

---

## 5. AppImage resta fuori da `extract`

`extract` non supporta il token:

```text
appimage
```

Un AppImage può tecnicamente offrire `--appimage-extract`, ma usare tale meccanismo richiede di eseguire l'artifact scaricato. Un file ostile potrebbe inoltre non rispettare semanticamente l'opzione attesa.

L'installazione non deve acquisire esecuzione implicita di codice upstream soltanto per materializzare un artifact. La futura esecuzione del software installato è un trust boundary distinto.

Per il package manager il comportamento corrente resta quindi:

```text
pkg_extract appimage -> copia opaca del file, senza esecuzione e senza mount
```

Questa responsabilità resta package-specific e non viene inserita nella utility generale `extract`.

---

## 6. Confine di sicurezza di `extract`

`extract` confina **architetturalmente** le dipendenze da extractor/decompressor host, ma non è definito come sandbox.

In particolare questa decisione non dichiara risolti genericamente:

```text
archive path traversal
symlink/hardlink escape
special filesystem objects
resource exhaustion
comportamenti specifici o vulnerabilità dei backend esterni
```

Un eventuale hardening universale o isolamento dell'estrazione richiede un contratto esplicito separato e testabile. Non deve essere inferito dalla sola centralizzazione dei backend.

Il mount read-only del backend DMG nativo riduce esclusivamente la possibilità di modifica del volume montato durante questa operazione; non promuove `extract` a sandbox e non modifica questo confine di sicurezza.

---

## 7. Confini di responsabilità

`digest` non:

```text
verifica expected digest
interpreta descriptor package
scarica artifact
modifica package state
```

`extract` non:

```text
scarica artifact
verifica size/digest
impone staging vuoto
esegue AppImage
consulta pkg-catalog
modifica package state o selector
```

I consumer mantengono le proprie policy specifiche e delegano soltanto la capability host portabile.

---

## 8. Testing

I test permanenti devono proteggere almeno:

```text
digest: CLI stdin/file e output lowercase canonico
digest: ordine/fallback cksum -> sha256sum -> shasum -> openssl
digest: failure quando la capability SHA-256 è assente
digest: rifiuto algoritmo/invocazione non supportati
extract: mapping format -> backend e alias
extract: decompressor separato da tar
extract: single-stream naming e cleanup
extract: ZIP/JAR/WAR, 7z/7zip e deb
extract dmg: hdiutil+ditto preferiti quando entrambi disponibili
extract dmg: fallback 7zz -> 7z -> 7za quando il backend nativo è indisponibile
extract dmg: nessun fallback dopo un errore operativo del backend selezionato
extract dmg: detach/cleanup del mountpoint anche sul failure path successivo ad attach
extract: appimage non supportato dalla utility generale
extract: almeno un tar.gz reale quando tar+gzip sono disponibili
pkg_extract: AppImage opaco non viene eseguito
```

I backend fake deterministici sono appropriati per dispatch, selezione, fallback e failure semantics. Le capability host reali restano soggette a physical validation revision-specific quando promosse nel flusso operativo.

Per il backend DMG nativo, il PoC macOS con artifact DBeaver reale costituisce evidence sperimentale preliminare; dopo il riallineamento prodotto il gate live DBeaver deve validare revision-specific l'uso effettivo del backend nel percorso `pkg install`.

---

## 9. Invarianti fissati

```text
DIGEST-01   comando canonico bin/sys/digest
DIGEST-02   CLI baseline = digest -a sha256 [-- <file>]; senza file legge stdin
DIGEST-03   output SHA-256 = 64 hex lowercase + LF
DIGEST-04   backend order = cksum capability, sha256sum, shasum, openssl
DIGEST-05   backend failure non provoca retry con backend successivo
DIGEST-06   digest calcola byte digest e non conosce expected value o package metadata
EXTRACT-01  comando canonico bin/sys/extract
EXTRACT-02  CLI baseline = extract <format> <artifact> <destination>
EXTRACT-03  format è esplicito; nessuna autodetection semantica
EXTRACT-04  destination deve esistere ed essere reale ma non è obbligatoriamente vuota
EXTRACT-05  backend archive/compression sono confinati in extract e non nei consumer package
EXTRACT-06  tar compressi verificano il decompressor prima dell'estrazione tar
EXTRACT-07  appimage non appartiene alla utility extract e non viene eseguito durante pkg_extract
EXTRACT-08  extract non è una sandbox; hardening archive è un contratto separato
EXTRACT-09  dmg seleziona hdiutil+ditto come backend composto preferito quando entrambi disponibili, poi 7zz, 7z, 7za
EXTRACT-10  fallback dmg avviene soltanto per indisponibilità iniziale della capability; errore del backend selezionato non provoca retry
EXTRACT-11  backend dmg nativo usa mount read-only/non-browsable, copia nella destination e detach/cleanup del mountpoint temporaneo sotto m_TMP_DIR
EXTRACT-12  7z e 7zip restano separati dal ramo dmg e continuano a usare esclusivamente 7zz, 7z, 7za
```
