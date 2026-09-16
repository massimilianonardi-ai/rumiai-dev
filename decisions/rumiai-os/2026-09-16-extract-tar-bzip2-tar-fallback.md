# Decisione — fallback `tar` per archive tar+bzip2 senza `bzip2`

Date: 2026-09-16  
Status: **Accepted**

## 1. Contesto e correzione

La physical validation del package `micromamba` su Ubuntu x64 ha osservato che il suo artifact corrente `tar.bz2` non e' materializzabile quando il comando host `bzip2` non e' disponibile.

L'utente fissa esplicitamente la remediation:

- il package `micromamba` continua a usare l'archive corrente `tar.bz2`;
- la correzione appartiene alla utility generale `extract`, non alla package definition;
- per i tar compressi bzip2, quando `bzip2` non e' presente nel sistema, `extract` tenta l'estrazione direttamente tramite `tar`.

Questa decisione modifica in modo mirato il contratto fissato da `2026-09-09-digest-and-extract-system-utilities.md` per i soli format:

```text
tar.bz2
tar.bzip2
tbz
tbz2
```

In particolare, `EXTRACT-06` resta valido per gli altri tar compressi ma viene specializzato per questa famiglia come descritto qui.

Le evidence Ubuntu x64 gia' registrate restano immutabili e continuano a descrivere correttamente la revisione precedentemente esercitata.

## 2. Backend selection per tar+bzip2

Per:

```text
tar.bz2
tar.bzip2
tbz
tbz2
```

la selezione diventa:

```text
bzip2 disponibile
    -> percorso corrente: bzip2 separato, verifica del suo esito, poi tar

bzip2 non disponibile
    -> tar diretto sull'artifact tar+bzip2
```

Il percorso preferito con `bzip2` disponibile non cambia. Continua quindi a verificare separatamente la decompressione prima dell'estrazione tar, senza dipendere da `pipefail`.

Il percorso `tar` diretto e' esclusivamente un fallback di **disponibilita' iniziale della capability `bzip2`**. Non viene scelto dopo che un `bzip2` disponibile ha iniziato l'operazione e ha fallito.

Analogamente, dopo che il percorso `tar` diretto e' stato selezionato per assenza di `bzip2`, un suo errore operativo termina l'estrazione con failure e non provoca ulteriori retry o cambio di backend.

Il fallback non costituisce autodetection del format: il caller continua a dichiarare esplicitamente un format della famiglia tar+bzip2 e `extract` sceglie soltanto come materializzarlo.

## 3. Confine con i formati bzip2 single-stream

La modifica non riguarda:

```text
bzip
bzip2
bz2
```

Questi format rappresentano una decompressione single-stream e continuano a richiedere la capability `bzip2` secondo il contratto corrente.

Il fatto che `tar` possa gestire un archive tar+bzip2 non lo rende un decompressor bzip2 generale e non modifica il naming/output dei formati single-stream.

## 4. Relazione con `pkg_extract` e `micromamba`

`pkg_extract` resta invariato:

```text
pkg_extract <artifact> <format> <staging-dir>
```

Per `tar.bz2` continua a delegare la raw materialization a `extract`, poi applica la structural useful-root normalization gia' fissata.

La package definition `micromamba` non cambia formato, artifact, repository, command mapping o range per questa remediation. In particolare non viene introdotto un artifact alternativo soltanto per evitare la dipendenza host da `bzip2`.

La correzione e' general-purpose: qualunque consumer che dichiara uno dei format tar+bzip2 beneficia dello stesso backend selection contract.

## 5. Portabilita' e physical validation

`tar` non appartiene a un unico comportamento implementation-specific per la decompressione bzip2. La disponibilita' del comando `tar` non basta quindi, da sola, a dichiarare fisicamente riuscito il fallback su ogni host.

I test permanenti proteggono deterministicamente la **selezione** del backend e le failure semantics. La physical validation deve inoltre esercitare un artifact tar+bzip2 reale su un host pertinente nel quale `bzip2` non sia disponibile al runtime osservato.

Per il work unit corrente, il gate `micromamba` Ubuntu x64 deve essere rieseguito sulla revisione prodotto che contiene questa correzione. Il package non diventa `VALIDATED` finche' non supera anche il normale release gate, incluso `pkg-analyze` e il launch del command RumiAI.

Se il `tar` effettivamente presente sull'host non riesce a materializzare il tar+bzip2 senza `bzip2`, la physical validation resta negativa: questa decisione non autorizza a dichiarare riuscito il fallback per analogia.

## 6. Testing

La copertura permanente deve proteggere almeno:

```text
tar+bzip2 con bzip2 disponibile -> bzip2 separato + tar
tar+bzip2 con bzip2 assente -> tar diretto
alias tar.bz2/tar.bzip2/tbz/tbz2 coerenti con lo stesso fallback
nessun retry verso tar diretto dopo un failure operativo di bzip2 disponibile
failure del tar diretto -> extraction failure, senza ulteriori retry
bzip/bzip2/bz2 single-stream continuano a richiedere bzip2
pkg_extract continua a delegare tar.bz2 a extract senza capability detection duplicata
```

La prova fisica `micromamba` resta distinta dai fake backend permanenti e costituisce l'evidence del comportamento dell'host reale.

## 7. Invarianti

```text
EXTRACT-BZ2-FALLBACK-01  micromamba conserva l'artifact/format tar.bz2 corrente
EXTRACT-BZ2-FALLBACK-02  la remediation appartiene a extract; pkg_extract non acquisisce backend detection
EXTRACT-BZ2-FALLBACK-03  con bzip2 disponibile resta il percorso bzip2 separato + tar
EXTRACT-BZ2-FALLBACK-04  solo quando bzip2 e' inizialmente indisponibile, tar+bzip2 usa tar direttamente sull'artifact
EXTRACT-BZ2-FALLBACK-05  il fallback non e' format autodetection e non cambia il format dichiarato
EXTRACT-BZ2-FALLBACK-06  failure del backend selezionato non provoca retry con un altro backend
EXTRACT-BZ2-FALLBACK-07  bzip/bzip2/bz2 single-stream continuano a richiedere bzip2
EXTRACT-BZ2-FALLBACK-08  pkg_extract API, useful-root normalization e staging contract restano invariati
EXTRACT-BZ2-FALLBACK-09  pkg-catalog non viene modificato da questa remediation
EXTRACT-BZ2-FALLBACK-10  physical validation reale e release gate micromamba restano obbligatori
EXTRACT-BZ2-FALLBACK-11  evidence storiche restano immutabili
EXTRACT-BZ2-FALLBACK-12  Git resta forward-only
```
