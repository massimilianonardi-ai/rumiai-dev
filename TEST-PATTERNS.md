# RumiAI Test Authoring Patterns

Questo documento raccoglie pattern e primitive riutilizzabili per `rumiai-tests`. `TESTING.md` resta il contratto normativo.

## 1. Principio

Quando più test hanno la stessa responsabilità infrastrutturale, la conoscenza non deve essere duplicata per ottenere una falsa indipendenza.

La priorità è:

```text
1. comportamento osservabile del target reale
2. autenticità del percorso di esecuzione verificato
3. indipendenza di stato/ordine tra test
4. riuso di infrastruttura comune stabile
5. minima quantità di codice di test necessaria
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
- creazione di repliche isolate complete e scartabili del target;
- preparazione di input esterni o fixture alle sole frontiere ammesse da `TESTING.md`;
- path normalization;
- primitive temporanee;
- driver di programmi interattivi;
- altra infrastruttura non specifica della proprietà verificata.

I test possono source direttamente tali librerie. La revisione esatta di `rumiai-tests` registrata nella validation rende riproducibile la versione usata.

Una libreria condivisa deve essere piccola, con responsabilità chiara e test proporzionati. Una libreria di test non deve diventare un'implementazione alternativa del comportamento del target.

### Copia inline

La copia inline non è più il default.

È ammessa solo quando:

1. la primitive copiata fa parte intenzionalmente della semantica specifica del test; oppure
2. congelare quella versione dentro il test è materialmente necessario e la motivazione è documentata nel file.

Non è una motivazione sufficiente il solo desiderio di evitare una dipendenza dalla stessa revisione della suite.

Le copie inline storiche esistenti devono essere migrate quando causano manutenzione duplicata o drift; non è necessario riscriverle tutte in una sola modifica se il rischio supera il beneficio, ma nessuna nuova copia deve essere introdotta senza giustificazione.

La copia di file o frammenti appartenenti al sistema sotto test non deve essere usata per ricostruirne artificialmente il comportamento. Quando serve isolamento, si usa la replica completa prevista da `TESTING.md`.

## 4. Testare il contratto attraverso il target reale

Per verificare un comportamento usare, quando il contratto lo consente, l'entrypoint pubblico reale e osservare direttamente:

- argomenti e input effettivamente accettati;
- output;
- exit status;
- file prodotti;
- mode/ownership;
- transizioni di stato;
- altri effetti osservabili appartenenti al contratto.

Fixture, fake, stub o input sintetici possono essere usati soltanto per rappresentare una frontiera esterna espressamente ammessa da `TESTING.md`. Non devono sostituire funzioni, eseguibili, adapter, cataloghi, downloader, extractor, integrator o altri componenti del target quando il test dichiara di verificare il comportamento reale composto che li attraversa.

Evitare grep del sorgente, nomi di funzioni private, numeri di riga e confronti di pathname non canonicalizzati quando tali dettagli non sono il contratto.

## 5. Pattern: target `rumiai-os`

La reference implementation corrente è:

```text
lib/rumiai-os-target.lib
```

I test `rumiai-os` che condividono il normale contratto di discovery devono source questa libreria invece di copiarne le funzioni.

Un test può usare una strategia diversa solo quando la discovery stessa è la proprietà verificata o quando esiste un requisito differente documentato.

## 6. Pattern: replica runnable isolata `rumiai-os`

La reference implementation corrente mantiene il nome storico:

```text
lib/rumiai-os-fixture.lib
```

Il suo contratto corretto non è costruire un fake di `rumiai-os`, ma creare una replica isolata del runtime/prodotto reale e separare soltanto lo stato mutabile necessario alla prova.

I test che necessitano della normale replica isolata del runtime devono source questa libreria quando il suo contratto corrisponde alla proprietà da verificare. La replica deve provenire dalla revisione reale sottoposta a test e deve contenere gli entrypoint e i componenti reali necessari al normale percorso di esecuzione; se il layout del prodotto evolve, la libreria condivisa deve essere riallineata in modo che la replica resti semanticamente completa per le proprietà che la usano.

Il nome storico `fixture` della libreria non autorizza test a sostituire parti del target con implementazioni artificiali. Se una prova richiede il comportamento reale di una parte non presente nella replica, la replica è insufficiente e deve essere corretta oppure la prova deve usare direttamente il target reale appropriato.

Una modifica al layout standard del prodotto deve quindi essere riallineata una volta nella libreria condivisa e nei test che verificano esplicitamente quel layout, non in numerose copie infrastrutturali.

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

## 8. Pattern: GUI headless

Una GUI può essere esercitata headless quando la proprietà verificata non dipende dal desktop fisico completo.

Il pattern corretto è avviare l'applicazione reale con il suo vero toolkit e i servizi reali necessari e fornire soltanto l'infrastruttura di esecuzione non fisica, per esempio:

```text
display virtuale
session bus
accessibility stack
applicazione reale
input/driver del test
```

Tecnologie come Xvfb, D-Bus e AT-SPI possono essere usate quando appropriate all'applicazione e all'host. Non costituiscono di per sé simulazione del target: sono infrastruttura di esecuzione finché il codice applicativo, GTK e gli altri componenti appartenenti alla proprietà restano reali.

Il test deve limitare la propria conclusione alle proprietà realmente esercitate. Un ambiente headless privo di GNOME Shell, Mutter/Wayland, portal, keyring, accelerazione grafica o altra integrazione desktop non può validare il comportamento dipendente da quei componenti.

## 9. Regola per nuovi test

Prima di aggiungere codice infrastrutturale a un `.test`, verificare nell'ordine:

1. il comportamento può essere esercitato attraverso l'entrypoint reale previsto dal contratto?
2. se serve isolamento, la replica usata è completa e proviene dalla revisione reale del target?
3. eventuali fixture/fake rappresentano soltanto input o frontiere esterne ammesse e non sostituiscono il comportamento dichiarato come verificato?
4. esiste già una libreria sotto `lib/` con la stessa responsabilità?
5. esiste un pattern documentato?
6. la logica aggiuntiva è davvero specifica della proprietà testata?
7. il nuovo test protegge una proprietà distinta da quelle già coperte?
8. il costo futuro di manutenzione è proporzionato al rischio?

Se la risposta indica riuso o fusione, non creare una nuova copia o un nuovo test soltanto per isolamento formale.

Quando una proprietà è comune a più host, preferire lo stesso `.test` reale sui diversi ambienti anziché creare versioni separate specifiche per host. Le differenze necessarie devono restare nell'infrastruttura o nelle astrazioni già previste dal contratto, non duplicare la semantica della prova.
