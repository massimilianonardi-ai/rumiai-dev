# Decisione — Gate di attivazione delle riflessioni sul futuro substrato

Date: 2026-09-12  
Status: **Accepted**

## 1. Scopo

Le analisi e le direzioni progettuali sviluppate sul possibile futuro substrato general purpose devono poter essere consolidate, confrontate e raffinate senza diventare automaticamente il nuovo modello operativo di RumiAI.

Questa decisione fissa quindi un gate esplicito fra:

```text
riflessione/progettazione futura

        e

modello di sviluppo e architettura correnti
```

## 2. Regola fondamentale

Fino a una futura decisione complessiva ed esplicita di adozione:

> **tutte le riflessioni sul possibile substrato general purpose restano non operative, anche quando singole parti sono state approvate, consolidate o registrate come direzioni progettuali.**

L'accordo concettuale su una singola idea non autorizza a trattarla come nuovo contratto corrente, nuovo workflow, nuova ownership o nuova architettura attiva.

## 3. Autorità corrente invariata

Restano operative le fonti autorevoli correnti di RumiAI:

```text
RULES.md
CONSISTENCY-GATE.md
specifiche normative correnti
decisioni Accepted correnti non relative al futuro modello non ancora attivato
permanent test correnti
physical evidence revision-specific
```

Il possibile futuro substrato non modifica per implicazione:

```text
identità di rumiai-os
repository ownership
bootstrap/runtime corrente
shebang correnti
environment variables correnti
filesystem layout corrente
package model corrente
shell model corrente
testing workflow corrente
```

## 4. Documenti di esplorazione

I documenti sotto `analysis/` relativi alla separazione del substrato sono materiale progettuale non normativo.

Una direzione progettuale può essere considerata consolidata nel merito senza acquisire per questo forza operativa.

In particolare, il documento:

```text
decisions/rumiai-os/2026-09-12-substrate-contract-stratification.md
```

è registrato come:

```text
CONSOLIDATED DESIGN DIRECTION / NOT ACTIVE
```

non come decisione architetturale attiva.

## 5. Nessuna adozione parziale implicita

Non è ammesso adottare silenziosamente singoli frammenti del futuro modello durante normali modifiche al prodotto soltanto perché tali frammenti appaiono già ragionevoli o condivisi.

Se una necessità corrente coincide con una idea emersa nell'esplorazione, deve essere valutata contro il modello corrente e, se costituisce un cambiamento architetturale, approvata esplicitamente nel proprio contesto.

## 6. Condizione di attivazione

Il futuro modello potrà diventare operativo soltanto tramite una decisione esplicita che dichiari l'attivazione dopo aver definito in modo sufficientemente completo le questioni importanti emerse dall'esplorazione.

Fra queste rientrano almeno, senza pretesa di esaustività:

```text
identità e scope del substrato
ownership e repository
boundary con RumiAI
contratti stabili iniziali
superficie di sviluppo iniziale
servizi/daemon boundary
shell boundary
command boundary
package/catalog ownership
runtime/bootstrap identity
namespace e filesystem layout
versioning e compatibility policy
documentazione pubblicata nel prodotto
migrazione di specifiche e decisioni
migrazione dei permanent test
physical validation
piano Git forward-only
```

Il gate si considera superato soltanto quando l'utente approva esplicitamente l'adozione complessiva o una fase di migrazione definita come tale.

## 7. Git e storia

Le precedenti analisi e commit restano nella storia Git e non vengono riscritti.

Le correzioni successive devono chiarire lo stato corrente senza relabeling retroattivo delle evidence o force push.

## 8. Invarianti

```text
SUBSTRATE-GATE-01  consolidamento concettuale non equivale ad attivazione operativa
SUBSTRATE-GATE-02  il modello di sviluppo corrente resta invariato finché non viene esplicitamente sostituito
SUBSTRATE-GATE-03  nessuna analisi del futuro substrato modifica implicitamente specifiche, implementation o test correnti
SUBSTRATE-GATE-04  non è ammessa adozione parziale silenziosa di frammenti del futuro modello
SUBSTRATE-GATE-05  l'attivazione richiede una futura decisione complessiva o una fase di migrazione esplicitamente approvata
SUBSTRATE-GATE-06  Git resta forward-only e la storia precedente non viene riscritta
```
