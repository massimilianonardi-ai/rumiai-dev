# Decisione — Avanzamento della coppia di validation per `srv`

Date: 2026-09-14  
Status: **Accepted — superseded as current validation pair**

La coppia revision-specific descritta da questa decisione resta una fotografia valida del relativo work unit, ma non è più la coppia corrente. È superseded esclusivamente come coppia di validation da:

```text
decisions/rumiai-tests/2026-09-15-reconcile-resource-srv-validation-pair.md
```

I contratti `srv` e di testing richiamati qui restano invariati.

## 1. Scopo

Questa decisione avanza la coppia revision-specific usata dal launcher `rumiai-validate` dopo l'introduzione del lifecycle portabile `srv` e del relativo permanent test.

Restano invariati il contratto del launcher e la policy di validation definiti dalle decisioni correnti di `rumiai-tests`.

## 2. Modifiche coperte

Il prodotto introduce:

```text
bin/sys/srv
```

secondo:

```text
decisions/rumiai-os/2026-09-14-srv-portable-service-lifecycle.md
```

La suite permanente introduce e consolida:

```text
tests/rumiai-os/srv/lifecycle.test
```

Il test copre almeno:

```text
start locale
start idempotente
canonicalizzazione del service target
log del processo
stop owner-aware
stop forzato esplicito
stale-state recovery
fail-closed su metadata incompleti con PID ancora vivo
startup failure immediata
target assente
nome service invalido
```

## 3. Coppia fissata da questo work unit

La configurazione di validation fissata da questo work unit era:

```text
rumiai-os-commit<TAB>eacf95a81b38043882ebcea88b951c8ba22c601d
selection<TAB>rumiai-os
```

La revisione della suite che conteneva sia il permanent test finale sia questa configurazione era:

```text
rumiai-tests@a4d1588f8966689e20465e6943e446e78a5fb3f0
```

La revisione prodotto era:

```text
rumiai-os@eacf95a81b38043882ebcea88b951c8ba22c601d
```

La selection era l'intero gruppo `rumiai-os`.

## 4. Resource model concorrente

Durante il work unit è stata attivata la decisione post-2.0 del resource model.

Il lifecycle `srv` non dipende dal resource layout: usa `state-path` per `run` e `log` e non introduce resource manager o daemon di risorse.

Il permanent test `srv` è stato riallineato rimuovendo una dipendenza non necessaria dal precedente pathname top-level `lang`, così non conserva terminologia/layout superseded e resta focalizzato sulla capability verificata.

Questa decisione non modifica né implementa il resource model.

## 5. Evidence precedente

Ogni evidence già pubblicata resta valida esclusivamente per la coppia registrata nella relativa sessione.

In particolare la validation completata per:

```text
rumiai-os@e9adfd55afdfe1111884a2ee42a8e5a955438119
rumiai-tests@d0617fdb3f7d7960e92cfdabef818a626eb22004
```

non costituisce evidence per la coppia fissata da questo work unit.

## 6. Physical validation richiesta dal work unit

La coppia fissata da questo work unit richiedeva validation sui reference host applicabili, almeno:

```text
Ubuntu 26.04 ARM64
macOS ARM64
```

tramite il normale launcher:

```text
./rumiai-validate
```

La coppia corrente e il relativo stato di physical validation sono ora definiti dalla decisione di riconciliazione del 2026-09-15.

## 7. Invarianti storici del work unit

```text
VALSRV-01  la coppia fissata da questo work unit era rumiai-os@eacf95a81b38043882ebcea88b951c8ba22c601d con rumiai-tests@a4d1588f8966689e20465e6943e446e78a5fb3f0
VALSRV-02  la selection era rumiai-os
VALSRV-03  evidence precedente non viene reinterpretata
VALSRV-04  la coppia richiedeva validation sui reference host applicabili
VALSRV-05  il resource model concorrente non viene modificato da questo work unit
VALSRV-06  Git resta forward-only
```
