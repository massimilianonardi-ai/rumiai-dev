# Decisione — Riallineamento dei test permanenti command al contratto corrente

Date: 2026-09-09  
Status: **Accepted**

## Contesto

La physical validation Ubuntu ARM64 della coppia:

```text
rumiai-os@b02965a91efdeb8f9609b432d635430ac9dba209
rumiai-tests@17a02fe6638c6cd0407410f487094200456e3596
selection=rumiai-os
```

ha prodotto la sessione pubblicata:

```text
validation/20260909T193426+0200-4095
```

con risultato:

```text
PASS   57
FAIL   3
SKIP   2
ERROR  0
TOTAL  62
```

I tre FAIL sono:

```text
rumiai-os/command/invalid-directory-entry.test
rumiai-os/command/resolution-failure.test
rumiai-os/command/self-entry-rejection.test
```

Tutti gli altri test eseguiti, inclusi i layer package correnti `digest`, `extract`, `pkg-download`, `pkg-extract`, `pkg-analyze` e `pkg-repository-github`, hanno prodotto PASS sulla stessa sessione Ubuntu ARM64.

## 1. Analisi del drift

L'evidence dei tre FAIL mostra che il prodotto corrente rifiuta correttamente il source pathname invalido e termina con:

```text
status=1
severity=fatal
domain=filesystem
message-id=path-invalid
```

con structured fields:

```text
command-original
command-resolved
```

I test permanenti conservavano invece aspettative storiche:

```text
status=8 oppure status=9
bootstrap.command-entry-resolution-failed
bootstrap.invalid-command-entry
```

Queste aspettative non appartengono al contratto corrente.

La specifica normativa `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md` richiede che un failure di risoluzione/validazione impedisca il sourcing, ma lascia la consolidazione generale degli external numeric status a un contratto separato salvo specifiche puntuali. La baseline bootstrap corrente usa normalmente `exit 1` per questi failure.

Il prodotto `rumiai-os@b02965a...` non viene modificato per ripristinare codici/eventi storici non più normativi.

## 2. Riallineamento dei test

I tre test vengono riallineati per verificare il comportamento corrente:

```text
status=1
[fatal] [filesystem.path-invalid]
```

con i field coerenti col caso:

```text
invalid directory:
    command-original=<directory operand>
    command-resolved=<canonical directory>

resolution failure:
    command-original=<missing operand>
    command-resolved=""

self-entry rejection:
    command-original=<canonical rumiai-os>
    command-resolved=<canonical rumiai-os>
```

Resta invariata la proprietà funzionale protetta: nessuno dei tre input invalidi può essere sourced/eseguito come command body.

## 3. Stato della sessione Ubuntu fallita

La sessione:

```text
validation/20260909T193426+0200-4095
```

resta evidence immutabile della suite `17a02fe...` e non viene reinterpretata come validation riuscita della coppia complessiva.

Essa costituisce tuttavia evidence revision-specific che, su Ubuntu ARM64, i 57 test PASS hanno osservato correttamente la revisione prodotto `b02965a...`; in particolare i layer package che hanno prodotto PASS non vengono retroattivamente considerati falliti a causa del drift dei tre test command.

Dopo il riallineamento della suite è comunque necessaria una nuova validation completa con la stessa `selection=rumiai-os` prima di dichiarare chiuso il gate corrente.

## 4. Coppia candidata successiva

Il prodotto resta invariato:

```text
rumiai-os@b02965a91efdeb8f9609b432d635430ac9dba209
```

La suite riallineata è:

```text
rumiai-tests@7d6c1459343fb5a9c99267d6e2e33ca9b34dbe40
```

La configuration resta:

```text
selection=rumiai-os
```

La nuova coppia deve essere validata prima su Ubuntu ARM64 e poi, senza cambiare target/selection, su macOS ARM64.

Questa sezione supersede, per la coppia candidata corrente, la precedente indicazione `rumiai-tests@17a02fe...` ancora presente nella decisione generale `2026-09-08-validation-launcher.md`. Il contratto del launcher non cambia; cambia soltanto la revisione della suite da validare dopo il riallineamento dei tre test command.

## 5. Physical validation Ubuntu della suite riallineata

La nuova validation Ubuntu ARM64 è stata eseguita sulla coppia esatta:

```text
rumiai-os@b02965a91efdeb8f9609b432d635430ac9dba209
rumiai-tests@7d6c1459343fb5a9c99267d6e2e33ca9b34dbe40
selection=rumiai-os
```

Sessione pubblicata:

```text
validation/20260909T194807+0200-13517
```

Host osservato:

```text
Ubuntu 26.04.1 LTS
Linux/aarch64
```

Risultato:

```text
PASS   60
FAIL   0
SKIP   2
ERROR  0
TOTAL  62
runner-exit-status 0
```

I due SKIP sono esclusivamente:

```text
rumiai-os/shell/zsh-alias-preservation.test
rumiai-os/shell/zsh-zdotdir-preservation.test
```

perché non applicabili sull'host Ubuntu corrente. Tutti gli altri test della selection `rumiai-os`, inclusi i tre test command riallineati e tutti i layer package correnti, hanno prodotto PASS.

Questa sessione costituisce physical evidence revision-specific riuscita per Ubuntu ARM64 della coppia candidata.

Il gate cross-platform non è ancora chiuso: resta necessaria la validation macOS ARM64 della stessa identica coppia e della stessa `selection=rumiai-os`.

## 6. Invarianti

```text
COMMAND-TEST-REALIGN-01  i tre FAIL Ubuntu iniziali derivano da aspettative test storiche, non dal ripristino di un requisito prodotto corrente
COMMAND-TEST-REALIGN-02  rumiai-os non viene modificato per reintrodurre status 8/9 o eventi bootstrap.* superseded
COMMAND-TEST-REALIGN-03  resolution/validation failure continua a impedire il sourcing del command body
COMMAND-TEST-REALIGN-04  i tre test correnti verificano status 1 e filesystem.path-invalid con structured fields command-original/command-resolved
COMMAND-TEST-REALIGN-05  la sessione validation/20260909T193426+0200-4095 resta evidence immutabile della suite 17a02fe...
COMMAND-TEST-REALIGN-06  i PASS della sessione iniziale restano evidence per le proprietà effettivamente esercitate, ma il gate complessivo di quella coppia resta fallito
COMMAND-TEST-REALIGN-07  il gate successivo usa rumiai-os@b02965a..., rumiai-tests@7d6c145... e selection=rumiai-os su Ubuntu ARM64 e macOS ARM64
COMMAND-TEST-REALIGN-08  validation/20260909T194807+0200-13517 chiude con successo il lato Ubuntu ARM64 della coppia riallineata
COMMAND-TEST-REALIGN-09  il gate cross-platform resta aperto fino alla validation macOS ARM64 della stessa identica coppia
```
