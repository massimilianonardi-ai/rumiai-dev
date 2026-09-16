# Decisione — Fallback 7-Zip per archivi TAR compressi bzip2

Date: 2026-09-16  
Status: **Accepted / Active**

## 1. Contesto

La release validation di `micromamba` su Ubuntu x86_64 ha mostrato che l'assenza del comando `bzip2` impedisce l'estrazione dell'artifact `tar.bz2`.

Una prima remediation ha tentato di delegare direttamente a `tar -xf <artifact>` quando `bzip2` non era disponibile. La prova fisica ha dimostrato che questa non e' una fallback valida: il `tar` dell'host puo' a sua volta cercare un decompressor bzip2 esterno (`lbzip2` nel caso osservato), lasciando invariata la dipendenza che si voleva rimuovere.

Per esplicita correzione dell'utente, il fallback diretto a `tar` e' quindi superseded.

## 2. Decisione

Per i formati:

```text
tar.bz2
tar.bzip2
tbz
tbz2
```

`extract` usa il seguente comportamento:

1. se `bzip2` e' disponibile, resta il backend preferito per decomprimere l'artifact;
2. se `bzip2` non e' disponibile, viene usato il backend 7-Zip gia' supportato da `extract`;
3. la risoluzione del backend 7-Zip riusa la primitive esistente e la sua precedenza corrente:

```text
7zz
7z
7za
```

4. il backend 7-Zip decomprime il layer bzip2; `tar` riceve quindi un TAR gia' decompresso e non deve essere invocato sull'artifact `.tar.bz2` affinche' ne autodetecti la compressione;
5. se `bzip2` esiste ma fallisce durante la decompressione, l'errore resta un errore di decompressione: non viene ritentato automaticamente con 7-Zip;
6. il comportamento dei formati bzip2 non-TAR resta invariato e continua a richiedere `bzip2`.

## 3. Primitive esistenti

Non viene introdotto un nuovo resolver, comando pubblico, alias o namespace.

L'implementazione deve riusare la risoluzione 7-Zip gia' presente in `bin/sys/extract` (`7zz`, `7z`, `7za`) e il normale percorso di estrazione TAR su stream/file TAR non compresso.

## 4. Failure model

Se manca `bzip2` e nessun backend 7-Zip supportato e' disponibile, l'estrazione fallisce come dipendenza mancante identificando il backend 7-Zip richiesto.

Un fallimento del backend 7-Zip durante la decompressione viene classificato come `decompression-failed`; un fallimento successivo di `tar` sul TAR gia' decompresso resta `extraction-failed`.

## 5. Validation

La proprieta' deve essere protetta da un test permanente che verifichi almeno:

- preferenza di `bzip2` quando disponibile;
- fallback a 7-Zip quando `bzip2` e' assente;
- passaggio a `tar` di un TAR gia' decompresso, non dell'artifact `.tar.bz2`;
- nessun fallback dopo un errore operativo di `bzip2` presente;
- errore coerente quando manca anche 7-Zip;
- comportamento bzip2 non-TAR invariato.

La remediation non chiude da sola il release gate di `micromamba`: la prova fisica `package-release-micromamba` deve essere rieseguita sulla revisione di `rumiai-os` che implementa questa decisione.

## 6. Invarianti

```text
EXTRACT-BZIP2-01  bzip2 resta il backend preferito per TAR compressi bzip2 quando disponibile
EXTRACT-BZIP2-02  assenza di bzip2 usa il backend 7-Zip esistente, non tar autodetection
EXTRACT-BZIP2-03  tar riceve soltanto il TAR gia' decompresso nel percorso di fallback
EXTRACT-BZIP2-04  errore operativo di bzip2 presente non viene mascherato da un fallback
EXTRACT-BZIP2-05  i formati bzip2 non-TAR non acquisiscono implicitamente il fallback 7-Zip
EXTRACT-BZIP2-06  non viene introdotta una nuova primitive quando la risoluzione 7-Zip esiste gia'
```

## 7. Nota storica

Il commit `rumiai-os@ea0a06f04b5f7429d31a22bebcf165496825ae5c` resta parte della storia Git, ma il suo fallback diretto a `tar` e' superseded da questa decisione. Le evidence storiche non vengono riscritte.
