# Decisione — Riconciliazione della coppia di validation per resource model e `srv`

Date: 2026-09-15  
Status: **Accepted / Active — physical validation pending**

## 1. Scopo

Questa decisione riconcilia esplicitamente la coppia revision-specific usata da `rumiai-validate` dopo due work unit concorrenti già presenti sui branch correnti:

```text
resource model
srv portable lifecycle + hardening della serializzazione concorrente
```

La riconciliazione è necessaria perché la precedente configurazione full-suite puntava a una revisione prodotto precedente all'ultimo hardening `srv`, mentre la suite corrente contiene già il relativo permanent test.

Non viene modificato alcun contratto del launcher, del runner, del resource model o di `srv`.

## 2. Revisioni riconciliate

La revisione prodotto corrente è:

```text
rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7
```

Questa revisione discende dal baseline resource:

```text
rumiai-os@cd0e914615d79d3944dafa0456c9b6220f9b550e
```

e aggiunge esclusivamente il successivo hardening `srv` già consolidato nel repository.

La suite corrente è stata riallineata in:

```text
rumiai-tests@16f3926a224dd32d7d226a39234c779fa4ce1353
```

La configurazione versionata è quindi:

```text
rumiai-os-commit<TAB>a5442e527f6bc7a70022f09330ba27770c0b5fb7
selection<TAB>rumiai-os
```

## 3. Selection

La selection resta:

```text
rumiai-os
```

perché la coppia deve esercitare insieme il prodotto corrente e i permanent test correnti che coprono almeno:

```text
resource root e language resource layout
bootstrap e semantic roots aggiornati
lang / lang-set sul resource model corrente
srv lifecycle
serializzazione di start concorrenti e cleanup lock
repository adapter Node.js e relativi test sintetici sotto rumiai-os
```

Il test live:

```text
external/nodejs/install-live.test
```

non appartiene a questa selection. La physical validation live del package Node.js resta un gate revision-specific separato da eseguire dopo la chiusura della coppia full-suite corrente; non viene assorbita implicitamente in questa evidence.

## 4. Relazione con le coppie precedenti

Questa decisione supersede esclusivamente la coppia revision-specific descritta come corrente da:

```text
decisions/rumiai-tests/2026-09-14-advance-validation-pair-for-srv-lifecycle.md
```

ed esplicita la riconciliazione richiesta da:

```text
handoff/2026-09-14-resource-model-implementation-handoff.md
```

I contratti architetturali e di testing richiamati da quei documenti restano invariati.

Le evidence precedenti restano valide soltanto per le revisioni registrate nelle rispettive sessioni e non vengono reinterpretate.

## 5. Tentativi di launcher con mismatch

I tentativi eseguiti dopo il self-update dei checkout ma prima di questa riconciliazione hanno correttamente terminato prima del runner perché:

```text
rumiai-os HEAD = a5442e527f6bc7a70022f09330ba27770c0b5fb7
configured     = cd0e914615d79d3944dafa0456c9b6220f9b550e
```

Tali tentativi non costituiscono validation session e non producono evidence per la coppia corrente.

## 6. Physical validation richiesta

La coppia esatta:

```text
rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests 16f3926a224dd32d7d226a39234c779fa4ce1353
selection    rumiai-os
```

deve essere esercitata sui reference host applicabili, almeno:

```text
Ubuntu 26.04 ARM64
macOS ARM64
```

tramite:

```text
./rumiai-validate
```

Finché entrambi i run non sono completati e pubblicati secondo il contratto ordinario, lo stato resta **physical validation pending**.

## 7. Invarianti

```text
VAL-RECON-01  la coppia corrente è rumiai-os@a5442e527f6bc7a70022f09330ba27770c0b5fb7 con rumiai-tests@16f3926a224dd32d7d226a39234c779fa4ce1353
VAL-RECON-02  la selection corrente è rumiai-os
VAL-RECON-03  la coppia riconcilia esplicitamente resource model e successivo hardening srv già presenti sui branch correnti
VAL-RECON-04  i tentativi terminati per mismatch prima del runner non sono evidence
VAL-RECON-05  evidence precedente resta revision-specific e non viene reinterpretata
VAL-RECON-06  external/nodejs/install-live.test richiede un gate separato e non è coperto dalla selection rumiai-os
VAL-RECON-07  nessun contratto di prodotto o testing viene modificato da questa decisione
VAL-RECON-08  Git resta forward-only
```
