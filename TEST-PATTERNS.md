# RumiAI Test Authoring Patterns

Questo documento raccoglie pattern e primitive riutilizzabili per `rumiai-tests`. `TESTING.md` resta il contratto normativo.

## 1. Principio

Quando più test hanno la stessa responsabilità infrastrutturale, la conoscenza non deve essere duplicata per ottenere una falsa indipendenza.

La priorità è:

```text
1. comportamento osservabile del target
2. indipendenza di stato/ordine tra test
3. riuso di infrastruttura comune stabile
4. minima quantità di codice di test necessaria
```

## 2. Livelli di riuso

Una tecnica riutilizzabile può vivere come:

```text
pattern documentale
libreria condivisa di rumiai-tests
tool generale di rumiai-os, solo se utile anche al prodotto
```

La promozione verso `rumiai-os` non è automatica.

## 3. Librerie condivise

Una libreria sotto `rumiai-tests/lib/` è appropriata per responsabilità comuni come:

- target discovery;
- creazione di fixture standard;
- path normalization;
- primitive temporanee;
- driver di programmi interattivi;
- altra infrastruttura non specifica della proprietà verificata.

I test possono source direttamente tali librerie. La revisione esatta di `rumiai-tests` registrata nella validation rende riproducibile la versione usata.

Una libreria condivisa deve essere piccola, con responsabilità chiara e test proporzionati.

### Copia inline

La copia inline non è più il default.

È ammessa solo quando:

1. la primitive copiata fa parte intenzionalmente della semantica specifica del test; oppure
2. congelare quella versione dentro il test è materialmente necessario e la motivazione è documentata nel file.

Non è una motivazione sufficiente il solo desiderio di evitare una dipendenza dalla stessa revisione della suite.

Le copie inline storiche esistenti devono essere migrate quando causano manutenzione duplicata o drift; non è necessario riscriverle tutte in una sola modifica se il rischio supera il beneficio, ma nessuna nuova copia deve essere introdotta senza giustificazione.

## 4. Testare il contratto, non lo spelling del codice

Quando possibile usare fixture e fake controllati per osservare:

- argomenti realmente passati;
- ordine realmente osservabile delle operazioni;
- output;
- exit status;
- file prodotti;
- mode/ownership;
- transizioni di stato.

Evitare grep del sorgente, nomi di funzioni private, numeri di riga e confronti di pathname non canonicalizzati quando tali dettagli non sono il contratto.

## 5. Pattern: target `rumiai-os`

La reference implementation corrente è:

```text
lib/rumiai-os-target.lib
```

I test `rumiai-os` che condividono il normale contratto di discovery devono source questa libreria invece di copiarne le funzioni.

Un test può usare una strategia diversa solo quando la discovery stessa è la proprietà verificata o quando esiste un requisito differente documentato.

## 6. Pattern: fixture runnable `rumiai-os`

La reference implementation corrente è:

```text
lib/rumiai-os-fixture.lib
```

I test che necessitano della normale copia isolata del runtime devono source questa libreria.

Una modifica al layout standard del prodotto deve quindi essere riallineata una volta nella fixture condivisa e nei test che verificano esplicitamente quel layout, non in numerose copie infrastrutturali.

## 7. Pattern: programmi interattivi via TTY

La reference implementation corrente è:

```text
lib/interactive.lib
```

Serve a pilotare in modo non interattivo programmi che leggono da TTY reale/pseudo-terminale.

Strategia host corrente validata:

```text
macOS / Darwin: expect(1), attesa esplicita del prompt
Linux:          script(1) util-linux con input preparato
```

Formato dialogo:

```text
<prompt esatto><TAB><risposta>
```

Failure mode già osservati e da non reintrodurre:

- BSD/macOS `script(1)` non è intercambiabile con util-linux per questo scenario;
- in Tcl/Expect `[y/N]` dentro doppi apici è sintassi, non testo letterale;
- prompt dinamici devono essere trattati come dati e confrontati esattamente;
- timeout ed EOF devono produrre diagnostica utile;
- il transcript deve restare osservabile quando la prova fallisce.

La versione storicamente validata `7eed87d7...` resta evidence del comportamento osservato; nuove versioni della libreria richiedono test proporzionati prima di essere considerate affidabili.

## 8. Regola per nuovi test

Prima di aggiungere codice infrastrutturale a un `.test`, verificare nell'ordine:

1. esiste già una libreria sotto `lib/` con la stessa responsabilità?
2. esiste un pattern documentato?
3. la logica è davvero specifica della proprietà testata?
4. il nuovo test protegge una proprietà distinta da quelle già coperte?
5. il costo futuro di manutenzione è proporzionato al rischio?

Se la risposta indica riuso o fusione, non creare una nuova copia o un nuovo test soltanto per isolamento formale.
