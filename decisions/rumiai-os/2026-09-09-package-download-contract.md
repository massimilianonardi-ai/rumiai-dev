# Decisione — Contratto di `pkg_download`

Date: 2026-09-09  
Status: **Accepted**

## Contesto

La pipeline package corrente ha già fissato:

```text
lib/sh/pkg-download.lib.sh
pkg_download
```

come layer repository-neutral fra artifact resolution ed extract.

Il repository adapter GitHub corrente produce un descriptor artifact dichiarativo con:

```text
name=<artifact-name>
url=<artifact-url>
size=<decimal-bytes>
digest=sha256:<hex-digest>   # quando richiesto
```

`http-fetch` è la primitive RumiAI per il trasferimento HTTP/HTTPS.

La decisione `2026-09-09-digest-and-extract-system-utilities.md` ha inoltre promosso il calcolo SHA-256 alla utility di sistema general-purpose:

```text
digest
```

Questa revisione supersede la precedente capability detection SHA-256 interna a `pkg_download`: il package manager conserva la policy di verifica, mentre la scelta del backend host appartiene esclusivamente a `digest`.

---

## 1. File e API canonici

La libreria canonica è:

```text
lib/sh/pkg-download.lib.sh
```

È una libreria shell sourced:

```text
regular file
non executable
nessuno shebang
POSIX sh
```

L'API pubblica è:

```text
pkg_download <staging-dir>
```

Il descriptor artifact viene letto da stdin.

Su successo `pkg_download`:

1. scarica l'artifact come `<staging-dir>/<name>`;
2. verifica size e digest quando presente;
3. emette su stdout il pathname locale dell'artifact terminato da LF;
4. ritorna `0`.

Lo staging directory deve già esistere ed essere una directory reale. Il layer non decide il lifecycle dello staging complessivo.

---

## 2. Descriptor accettato

I campi obbligatori sono esattamente:

```text
name
url
size
```

Il campo opzionale corrente è:

```text
digest
```

Regole:

```text
ogni campo compare al massimo una volta
campi sconosciuti sono errore
ogni record è key=value terminato da LF
value non vuoto
TAB e CR nei value sono rifiutati
name è un singolo basename e non può essere . oppure ..
url usa inizialmente http:// oppure https://, coerentemente con http-fetch
size è un intero decimale canonico non negativo
```

`name` è dato, non viene source/eval/espanso, e non può contenere `/`; quindi non può uscire dallo staging directory.

L'ordine dei record non è significativo.

---

## 3. Target e overwrite

Il target è:

```text
<staging-dir>/<name>
```

Se quel pathname esiste già come qualsiasi oggetto filesystem, `pkg_download` fallisce.

Il layer non sovrascrive artifact preesistenti e non interpreta un file esistente come cache valida.

---

## 4. Trasferimento

Il trasferimento usa esclusivamente:

```text
http-fetch -o <target> -- <url>
```

`pkg_download` non conosce GitHub, SourceForge, Maven o altri repository type.

Se il trasferimento fallisce, l'eventuale file target parziale creato dalla stessa invocazione viene rimosso e la funzione fallisce.

---

## 5. Verifica size

Dopo il download la dimensione reale in byte deve coincidere esattamente con `size`.

Mismatch o impossibilità di determinare la size:

```text
rimozione del target prodotto
errore operativo
nessun pathname emesso su stdout
```

La size viene verificata prima del digest.

---

## 6. Verifica SHA-256

Il solo algoritmo digest ammesso dal descriptor corrente è:

```text
sha256
```

Il valore atteso è composto da esattamente 64 cifre esadecimali e viene normalizzato lowercase.

Quando il descriptor contiene `digest=sha256:<hex>`, `pkg_download` calcola il valore reale esclusivamente tramite:

```text
digest -a sha256 -- <target>
```

`pkg_download` non esegue più capability detection di `cksum`, `sha256sum`, `shasum` o `openssl` e non conosce i backend usati dalla utility.

Failure di `digest`:

```text
rimozione del target prodotto
errore operativo
nessun pathname emesso su stdout
```

Digest mismatch:

```text
rimozione del target prodotto
diagnostica con expected-digest e actual-digest
nessun pathname emesso su stdout
```

Il confronto avviene dopo la verifica size.

---

## 7. Exit status

```text
0  download e verifiche riusciti
1  descriptor invalido, staging invalido, transfer/size/digest failure
2  numero di argomenti invalido
```

I failure prodotti dal descriptor sono considerati errori operativi del pipeline input, non errori di sintassi della CLI pubblica `pkg`.

---

## 8. Confini di responsabilità

`pkg_download` non:

```text
consulta pkg-catalog
seleziona stream/range
interroga repository upstream per discovery
estrae artifact
interpreta format
sceglie backend HTTP
sceglie backend digest
modifica $m_ROOT/pkg
crea selector current
crea binding pubblici
modifica state package
```

Il suo unico effetto persistente nella chiamata è il file di staging validato.

---

## 9. Testing

I test permanenti devono proteggere almeno:

```text
validazione del descriptor e campi obbligatori
rifiuto duplicate/unknown field
confinamento di name a un basename
uso di http-fetch e preservazione del name
nessun overwrite del target
verifica size prima del digest
delega SHA-256 a digest -a sha256 -- <target>
cleanup del target dopo transfer/size/digest failure
digest mismatch
```

La selezione/fallback dei backend SHA-256 appartiene ai test permanenti di `digest`, non viene duplicata nei test di `pkg_download`.

La physical validation del transport/digest reale resta revision-specific e separata.

---

## 10. Invarianti fissati

```text
PKG-DOWNLOAD-01  file canonico lib/sh/pkg-download.lib.sh; libreria non eseguibile e senza shebang
PKG-DOWNLOAD-02  API = pkg_download <staging-dir>, descriptor letto da stdin
PKG-DOWNLOAD-03  successo crea <staging-dir>/<name> e ne emette il pathname su stdout
PKG-DOWNLOAD-04  descriptor obbligatorio name/url/size, digest opzionale; unknown/duplicate field sono errore
PKG-DOWNLOAD-05  name è confinato a un basename e non può uscire dallo staging
PKG-DOWNLOAD-06  target preesistente non viene sovrascritto
PKG-DOWNLOAD-07  trasferimento esclusivamente tramite http-fetch
PKG-DOWNLOAD-08  size viene sempre verificata prima del digest
PKG-DOWNLOAD-09  digest descriptor corrente supportato = sha256 e, quando richiesto, viene sempre verificato
PKG-DOWNLOAD-10  SHA-256 viene calcolato esclusivamente tramite la utility di sistema digest; pkg_download non seleziona backend digest host
PKG-DOWNLOAD-11  transfer/size/digest failure rimuove il target prodotto dalla stessa invocazione
PKG-DOWNLOAD-12  pkg_download resta repository-neutral e non modifica package state RumiAI
```
