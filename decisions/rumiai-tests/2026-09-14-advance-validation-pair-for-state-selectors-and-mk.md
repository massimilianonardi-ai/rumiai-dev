# Decisione — Avanzamento della coppia di validation per state selector e `mk`

Date: 2026-09-14  
Status: **Accepted / Active**

## 1. Scopo

Questa decisione aggiorna esclusivamente la coppia revision-specific usata dal launcher `rumiai-validate` dopo l'attivazione e l'implementazione della baseline `mk` di source materialization.

Restano invariati il contratto del launcher e la policy delle validation definiti da:

```text
decisions/rumiai-tests/2026-09-08-validation-launcher.md
```

## 2. Motivazione

La precedente configurazione di validation puntava a:

```text
rumiai-os@9d7b6d23e540abfbb5542d77282df23e51796192
selection=rumiai-os
```

Successivamente `main` di `rumiai-os` è avanzato forward-only a:

```text
e9adfd55afdfe1111884a2ee42a8e5a955438119
```

con l'implementazione della baseline `mk` attivata da:

```text
decisions/rumiai-os/2026-09-14-activate-mk-source-materialization-baseline.md
specifications/rumiai-os/MK-SOURCE-MATERIALIZATION.md
```

La suite permanente è avanzata a:

```text
88d226eede6cbf84ebd80b3f582daf74d7c1877c
```

aggiungendo:

```text
tests/rumiai-os/mk/materialize.test
```

Il launcher correttamente rifiuta quindi di validare un checkout `rumiai-os` il cui HEAD non coincide con il commit configurato.

## 3. Coppia corrente

La configurazione corrente è fissata a:

```text
rumiai-os-commit<TAB>e9adfd55afdfe1111884a2ee42a8e5a955438119
selection<TAB>rumiai-os
```

La revisione della suite che introduce questa configurazione è:

```text
rumiai-tests@d0617fdb3f7d7960e92cfdabef818a626eb22004
```

La selection resta l'intero gruppo `rumiai-os` perché il gate corrente deve coprire sia la correzione post-2.0.0 dei semantic state selector sia la nuova baseline `mk` e i relativi permanent test.

## 4. Evidence precedente

Le validation session già pubblicate restano evidence esclusivamente per le revisioni registrate nelle rispettive sessioni.

Nessuna evidence precedente viene rinominata, reinterpretata o promossa retroattivamente alla coppia corrente.

I tentativi di launcher terminati prima del runner con mismatch fra HEAD target e commit configurato non costituiscono validation session della coppia corrente.

## 5. Reference host

La stessa coppia esatta deve essere eseguita sui reference host applicabili, almeno:

```text
macOS ARM64
Ubuntu 26.04 ARM64
```

Il comando operativo resta:

```text
./rumiai-validate
```

La configurazione non deve cambiare fra i run dei reference host salvo una correzione reale emersa dalla validation.

## 6. Supersession

Questa decisione supersede esclusivamente la coppia revision-specific descritta come corrente dagli invarianti `VALIDATE-21` e `VALIDATE-22` di:

```text
decisions/rumiai-tests/2026-09-08-validation-launcher.md
```

Il resto del contratto di quel documento resta invariato.

Il precedente handoff:

```text
handoff/2026-09-14-rumiai-os-state-selector-correction-validation-handoff.md
```

resta corretto come fotografia del work unit precedente; la sua azione di physical validation è ora assorbita dalla coppia più recente qui definita.

## 7. Invarianti

```text
VALPAIR-01  la coppia corrente è rumiai-os@e9adfd55afdfe1111884a2ee42a8e5a955438119 con rumiai-tests@d0617fdb3f7d7960e92cfdabef818a626eb22004
VALPAIR-02  la selection corrente resta rumiai-os
VALPAIR-03  la stessa coppia deve essere usata sui reference host applicabili
VALPAIR-04  evidence precedente resta revision-specific e non viene reinterpretata
VALPAIR-05  un mismatch preliminare del launcher non è physical validation
VALPAIR-06  il freeze e le evidence 2.0.0 restano immutabili
VALPAIR-07  Git resta forward-only
```
