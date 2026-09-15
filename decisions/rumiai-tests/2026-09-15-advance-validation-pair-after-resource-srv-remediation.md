# Decisione — Avanzamento della coppia di validation dopo remediation resource / `srv`

Date: 2026-09-15  
Status: **Accepted / Active — physical validation pending**

## 1. Scopo

Questa decisione fissa la nuova coppia revision-specific da usare per ripetere la full-suite validation dopo la remediation dei permanent test che avevano prodotto evidence negativa nella coppia precedente.

La remediation è esclusivamente test-side. La revisione prodotto resta invariata e nessun contratto del resource model, di `srv`, del package subsystem, del launcher o del runner viene modificato.

## 2. Coppia corrente

La coppia corrente è:

```text
rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
selection    rumiai-os
```

`rumiai-validate.conf` continua correttamente a contenere:

```text
rumiai-os-commit<TAB>a5442e527f6bc7a70022f09330ba27770c0b5fb7
selection<TAB>rumiai-os
```

La revisione esatta della suite viene registrata dalla validation session; non è necessario introdurre una seconda chiave di configurazione per duplicare l'HEAD di `rumiai-tests`.

## 3. Remediation incorporata nella nuova suite

Rispetto a:

```text
rumiai-tests@16f3926a224dd32d7d226a39234c779fa4ce1353
```

il tree corrente riallinea i permanent test che dipendevano ancora dal superseded top-level:

```text
$m_ROOT/lang
```

al resource model corrente:

```text
$m_ROOT/res
$m_ROOT/res/sys/lang
```

In particolare la remediation copre:

```text
bootstrap fixture interessate
command fixture inline
osarch/update fixture
shell fixture inline
state-path fixture
pkg/setuid language resource paths
pkg-repository-nodejs artifact SHA-256 expectation
srv lifecycle canonical-path expectation e diagnostica
```

Le copie inline della fixture `rumiai-os` che richiedono il resource tree fanno riferimento alla revisione immutabile:

```text
rumiai-tests@216e4ffdd9ae31e625fd2c47e27573bdae9c4538:lib/rumiai-os-fixture.lib
```

che copia `res` invece del superseded top-level `lang`.

Il test Node.js usa ora un digest SHA-256 atteso di 64 cifre esadecimali.

Il test `pkg/setuid.test` risolve i cataloghi tecnici sotto:

```text
res/sys/lang/<locale>/...
```

Il test `srv/lifecycle.test` continua a richiedere canonicalizzazione stretta del target. L'aspettativa viene canonicalizzata con `realpath` prima del confronto, così la differenza di rappresentazione `/tmp` → `/private/tmp` su macOS non viene scambiata per una violazione di `SRV-05`.

## 4. Prodotto invariato

La remediation non richiede modifiche a:

```text
rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7
```

L'evidence raccolta ha mostrato che il fallimento macOS di `srv/lifecycle.test` derivava dall'aspettativa pathname del test, mentre il prodotto canonicalizzava il service target come richiesto dal contratto.

Non viene quindi introdotto alcun workaround host-specific nel prodotto e non viene allentato `SRV-05`.

## 5. Relazione con la coppia fallita

Questa decisione supersede esclusivamente come **coppia corrente**:

```text
decisions/rumiai-tests/2026-09-15-reconcile-resource-srv-validation-pair.md
```

Le sessioni:

```text
20260915T145047+0200-376171
20260915T145126+0200-42022
```

restano evidence immutabile di validation fallita per:

```text
rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests@16f3926a224dd32d7d226a39234c779fa4ce1353
```

e non vengono reinterpretate come evidence della nuova suite.

## 6. Storia Git della remediation

Git resta forward-only.

Durante la remediation sono stati creati e poi rimossi alcuni file temporanei vuoti tramite commit successivi. Tali coppie di commit non hanno effetto netto sul tree corrente e non vengono rimosse o riscritte.

Il confronto tra la suite fallita e il tree corrente mostra come delta netto soltanto i permanent test interessati dalla remediation. Nessun file temporaneo resta nel tree corrente.

Questa storia operativa non modifica la semantica della coppia revision-specific: la revisione da validare è esattamente `rumiai-tests@df36a9d359901fa16daa1c7b763a3d8ec85ca2a2`.

## 7. Physical validation richiesta

La nuova coppia deve essere esercitata tramite:

```text
./rumiai-validate
```

sui reference host applicabili almeno:

```text
Ubuntu 26.04 ARM64
macOS ARM64
```

Un esito positivo richiede sessioni pubblicate per la coppia esatta e nessuna reinterpretazione delle evidence precedenti.

Fino a tali run lo stato resta **physical validation pending**.

## 8. Gate Node.js successivo

Il test:

```text
external/nodejs/install-live.test
```

non appartiene a questa full-suite selection e resta un gate revision-specific separato.

Deve essere eseguito soltanto dopo la chiusura positiva della coppia full-suite corrente.

## 9. Invarianti

```text
VAL-REM-01  la coppia corrente è rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7 con rumiai-tests@df36a9d359901fa16daa1c7b763a3d8ec85ca2a2
VAL-REM-02  la selection corrente resta rumiai-os
VAL-REM-03  rumiai-os resta invariato dalla remediation
VAL-REM-04  il top-level $m_ROOT/lang non viene ripristinato
VAL-REM-05  i permanent test usano il resource model corrente res / res/sys/lang
VAL-REM-06  SRV-05 resta invariato e richiede canonicalizzazione del service target
VAL-REM-07  le evidence della coppia 16f3926 restano failure evidence immutabile
VAL-REM-08  external/nodejs/install-live.test resta un gate separato successivo
VAL-REM-09  Git resta forward-only; la storia non viene riscritta per rimuovere commit net-zero
VAL-REM-10  physical validation positiva sui reference host è ancora richiesta prima della chiusura
```
