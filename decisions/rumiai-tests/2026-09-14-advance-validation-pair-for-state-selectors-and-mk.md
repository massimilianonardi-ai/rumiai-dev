# Decisione — Avanzamento della coppia di validation per state selector e `mk`

Date: 2026-09-14  
Status: **Accepted / Active — physical validation complete**

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

resta corretto come fotografia del work unit precedente; la sua azione di physical validation è assorbita e completata dalla coppia più recente qui definita.

## 7. Physical validation completata

La coppia revision-specific:

```text
rumiai-os    e9adfd55afdfe1111884a2ee42a8e5a955438119
rumiai-tests d0617fdb3f7d7960e92cfdabef818a626eb22004
selection    rumiai-os
```

è stata esercitata fisicamente il 2026-09-14 sui due reference host ARM64 richiesti.

### Ubuntu 26.04 ARM64

Evidence ref:

```text
validation/20260914T203239+0200-360494
```

Sessione registrata:

```text
os              Linux
os-version      Ubuntu 26.04.1 LTS
architecture    aarch64
selection       rumiai-os
runner status   0
```

Risultato:

```text
PASS   78
FAIL   0
SKIP   2
ERROR  0
TOTAL  80
```

Gli unici SKIP sono i test zsh non applicabili all'host della sessione; non rappresentano failure e il runner ha terminato con status `0`.

### macOS ARM64

Evidence ref:

```text
validation/20260914T203304+0200-24421
```

Sessione registrata:

```text
os              Darwin
os-version      26.6.2
architecture    arm64
selection       rumiai-os
runner status   0
```

Risultato:

```text
PASS   80
FAIL   0
SKIP   0
ERROR  0
TOTAL  80
```

Entrambi i ref di evidence hanno come parent l'esatto commit della suite:

```text
d0617fdb3f7d7960e92cfdabef818a626eb22004
```

La relativa configurazione versionata fissa il target prodotto a:

```text
e9adfd55afdfe1111884a2ee42a8e5a955438119
```

quindi l'evidence resta revision-specific per la coppia dichiarata e non viene estesa a revisioni successive.

## 8. Chiusura del work unit

La physical validation richiesta per la correzione dei semantic state selector/global user binding e per la baseline iniziale `mk materialize` è completata sui reference host correnti.

Non resta alcuna azione di validation pendente per questa coppia.

Il checkpoint e le evidence `2.0.0` restano immutabili e continuano a descrivere esclusivamente il checkpoint storico congelato.

Ogni modifica successiva a `rumiai-os`, ai permanent test interessati o alla configurazione di validation richiede una nuova coppia/evidence revision-specific secondo il contratto ordinario.

## 9. Invarianti

```text
VALPAIR-01  la coppia validata è rumiai-os@e9adfd55afdfe1111884a2ee42a8e5a955438119 con rumiai-tests@d0617fdb3f7d7960e92cfdabef818a626eb22004
VALPAIR-02  la selection validata è rumiai-os
VALPAIR-03  la stessa coppia è stata esercitata sui reference host Ubuntu 26.04 ARM64 e macOS ARM64
VALPAIR-04  evidence precedente resta revision-specific e non viene reinterpretata
VALPAIR-05  un mismatch preliminare del launcher non è physical validation
VALPAIR-06  il freeze e le evidence 2.0.0 restano immutabili
VALPAIR-07  Git resta forward-only
VALPAIR-08  validation/20260914T203239+0200-360494 è l'evidence Ubuntu della coppia validata
VALPAIR-09  validation/20260914T203304+0200-24421 è l'evidence macOS della coppia validata
VALPAIR-10  revisioni successive non sono coperte retroattivamente da questa evidence
```
