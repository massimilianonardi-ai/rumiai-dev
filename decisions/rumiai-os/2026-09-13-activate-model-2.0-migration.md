# Decisione — Attivazione esecutiva della migrazione Model 2.0

Date: 2026-09-13  
Status: **Accepted / Active**

## 1. Scopo

Questa decisione registra il superamento del gate di attivazione della migrazione definita da:

```text
specifications/rumiai-os/MODEL-2.0-MIGRATION.md
```

La specifica sopra diventa da questo punto il contratto normativo esecutivo per la migrazione 1.0.0 -> 2.0.0.

## 2. Prerequisito 1.0.0 verificato

Il tag Git:

```text
1.0.0
```

esiste nel repository `rumiai-os` e punta esattamente a:

```text
96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
```

che è il checkpoint congelato fissato dalla specifica di migrazione.

Il tag non usa il prefisso `v`.

## 3. Approvazione utente

Dopo la creazione del tag `1.0.0`, l'utente ha approvato esplicitamente il passaggio di modello e ha autorizzato l'esecuzione autonoma della migrazione secondo quanto già concordato e consolidato.

Non è richiesta una nuova approvazione generale per ogni work unit della migrazione; restano invece obbligatori i gate previsti da `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md` e dalla specifica Model 2.0, incluso l'arresto prima di qualunque nuova decisione architetturale non già coperta.

## 4. Effetto normativo

Da questa decisione in avanti:

```text
MODEL-2.0-MIGRATION.md
    è Active

le parti incompatibili del modello 1.0
    vengono superseded forward-only man mano che la migrazione le sostituisce

le analisi future-model incompatibili
    non prevalgono sulla specifica normativa attiva
```

Non viene riscritta alcuna decisione, evidence o commit storico.

## 5. Ordine operativo

Resta fissato:

```text
1. rumiai-os
2. pkg-catalog
3. rumiai-tests
```

con `rumiai-dev` aggiornato prima di ogni eventuale correzione normativa necessaria.

## 6. Versioning

Durante la migrazione il prodotto non viene ancora denominato `2.0.0`.

`2.0.0` sarà assegnato soltanto al checkpoint completo dopo implementazione, test, validation applicabile e consistency check finale.

## 7. Invarianti

```text
MODEL2-ACT-01  il tag 1.0.0 identifica esattamente il checkpoint pre-migrazione
MODEL2-ACT-02  la specifica MODEL-2.0-MIGRATION.md è ora esecutiva
MODEL2-ACT-03  la migrazione procede forward-only
MODEL2-ACT-04  non si riaprono decisioni già fissate senza nuovo conflitto reale
MODEL2-ACT-05  rumiai-os viene migrato prima di pkg-catalog e rumiai-tests
MODEL2-ACT-06  2.0.0 viene assegnato solo al checkpoint completo
```
