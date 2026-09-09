# Decisione — Utility di sistema `digest` ed `extract`

Date: 2026-09-09  
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

7-Zip family e DMG:

```text
7z 7zip dmg -> primo disponibile fra 7zz, 7z, 7za
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
extract: ZIP/JAR/WAR, 7z/7zip/dmg e deb
extract: appimage non supportato dalla utility generale
extract: almeno un tar.gz reale quando tar+gzip sono disponibili
pkg_extract: AppImage opaco non viene eseguito
```

I backend fake deterministici sono appropriati per dispatch e fallback. Le capability host reali restano soggette a physical validation revision-specific quando promosse nel flusso operativo.

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
```
