# RumiAI Testing Rules

Questo documento definisce le regole canoniche per la scrittura, l'esecuzione e la conservazione dei test di RumiAI.

Le regole qui definite sono normative per i test permanenti e per le sessioni di validazione. I proof-of-concept restano attività sperimentali distinte e possono avere struttura e durata diverse.

## 1. Scopo dei test

I test servono a verificare e validare il comportamento osservabile di:

- componenti di RumiAI;
- runtime e comandi di RumiAI OS;
- librerie e moduli interni;
- integrazioni;
- tool, runtime, librerie, modelli, servizi, device o software esterni quando RumiAI dipende concretamente da una loro proprietà.

I test non devono cercare di validare genericamente un tool esterno. Devono verificare soltanto le proprietà esterne sulle quali RumiAI fa affidamento.

## 2. Separazione tra prodotto, PoC e test

I test permanenti non appartengono al repository del prodotto `rumiai-os`.

`rumiai-os` contiene il prodotto.

I PoC contengono esperimenti, domande ancora aperte e prototipi che possono essere modificati, sostituiti o eliminati.

I test permanenti contengono verifiche ripetibili che devono continuare a proteggere un comportamento consolidato nel tempo.

Un PoC riuscito può diventare origine di uno o più test permanenti, ma PoC e test restano concettualmente distinti.

## 3. Workspace locale di sviluppo

`rumiai-os` deve poter ospitare un workspace locale di sviluppo sotto:

```text
$RumiAI_ROOT/.dev/
```

Il contenuto di `.dev/` non appartiene al prodotto e deve essere ignorato dal repository `rumiai-os`.

Il repository dei test può essere clonato dentro `.dev/`, così che prodotto e test siano repository Git indipendenti ma disponibili nello stesso runtime locale.

Il repository dei test non deve essere incorporato in `rumiai-os` come submodule e non deve diventare una dipendenza necessaria all'esecuzione del prodotto.

## 4. Organizzazione dei test

I test permanenti devono essere organizzati principalmente per oggetto o capability verificata, non per tecnologia di implementazione.

Esempio concettuale:

```text
tests/
├── rumiai-os/
│   ├── bootstrap/
│   ├── command/
│   ├── i18n/
│   ├── log/
│   └── shell/
└── external/
```

Classificazioni come `unit`, `integration`, `system` o `e2e` possono essere aggiunte solo quando producono un vantaggio concreto e non devono sostituire l'identificazione dell'oggetto verificato.

## 5. Responsabilità di un test

Ogni test deve verificare una proprietà chiaramente identificabile.

Un test non deve aggregare comportamenti indipendenti se il loro fallimento può essere diagnosticato meglio con test separati.

Il nome del test deve descrivere la proprietà verificata e non il linguaggio con cui il test è implementato.

## 6. Determinismo

A parità di:

- test;
- versione del target;
- configurazione dichiarata;
- condizioni dell'host rilevanti;

il risultato deve essere riproducibile.

Quando una dipendenza rende il comportamento intrinsecamente non deterministico, il test deve dichiararlo esplicitamente e deve verificare invarianti deterministiche quando possibile.

## 7. Esito del test e stato del programma testato

Lo stato del test deve essere distinto dallo stato del programma o componente testato.

Il contratto iniziale degli exit status del test è:

```text
0 = PASS
1 = FAIL
2 = SKIP
3 = ERROR
```

Significato:

- `PASS`: il comportamento osservato corrisponde al comportamento atteso;
- `FAIL`: il test è stato eseguito correttamente ma il comportamento osservato non corrisponde a quello atteso;
- `SKIP`: il test non è applicabile o una precondizione dichiarata non è disponibile;
- `ERROR`: il test non ha potuto stabilire il risultato per un errore del test, del runner o dell'ambiente di esecuzione.

Esempio: se il comportamento atteso del target è terminare con status `143`, il test restituisce `0` quando osserva correttamente `143`.

## 8. Portabilità dei test

I test devono rispettare il contratto di piattaforma di RumiAI quando testano funzionalità portabili.

Non devono contenere path host-specifici hardcoded, nomi utente, home directory, path Homebrew, directory locali convenzionali o altre assunzioni non dichiarate.

I path del target devono essere derivati dal target stesso o forniti esplicitamente.

Le risorse temporanee devono essere create tramite meccanismi portabili appropriati e non devono assumere una specifica installazione locale.

Un test specifico di un host è ammesso quando verifica intenzionalmente una proprietà host-specifica; in quel caso tale requisito deve essere esplicito.

## 9. Isolamento

Un test non deve modificare il target reale quando la stessa verifica può essere eseguita senza modificarlo.

Quando sono necessarie modifiche a configurazioni, file, symlink, permessi o layout, il test deve preferire una sandbox o copia temporanea isolata del materiale necessario.

La working tree dello sviluppatore non deve essere usata come area temporanea di test salvo che ciò sia esattamente la proprietà che il test deve verificare.

## 10. Cleanup

Ogni test deve lasciare l'ambiente nello stato precedente all'esecuzione, per quanto sotto il suo controllo.

Il cleanup deve essere tentato anche dopo un FAIL o ERROR.

Al termine di un test non devono rimanere inutilmente:

- modifiche al target;
- file temporanei;
- configurazioni temporanee;
- processi o servizi avviati dal test;
- mount, socket, lock o altre risorse create dal test.

Un test che lascia stato residuo non dichiarato è difettoso.

## 11. Diagnostica dei fallimenti

Un FAIL o ERROR deve fornire informazioni sufficienti a comprendere almeno:

- quale proprietà è fallita;
- risultato atteso;
- risultato osservato.

La diagnostica deve essere concisa e utile. Non deve dipendere dalla lettura di log voluminosi quando il confronto essenziale può essere mostrato direttamente.

## 12. Test di tool esterni

Un tool esterno viene testato soltanto rispetto alle capability o proprietà necessarie a RumiAI.

Esempio: se RumiAI richiede la canonicalizzazione di un pathname, il test deve verificare la semantica necessaria della canonicalizzazione, non tentare di validare l'intero programma `realpath`.

La disponibilità di opzioni o comportamenti non usati da RumiAI non costituisce di per sé materia di test.

## 13. Development run

Una development run serve al ciclo rapido:

```text
sviluppo -> test -> correzione -> test
```

Durante una development run:

- il target può avere modifiche non committed;
- il repository dei test può avere modifiche non committed;
- la sessione non costituisce evidenza formale di validazione di un commit.

Il runner deve comunque evitare di danneggiare o sporcare il target.

## 14. Validation run

Una validation run produce evidenza riproducibile associata a revisioni precise.

Prima di una validation run, salvo eccezioni esplicitamente documentate:

- il target deve essere committed;
- il repository dei test deve essere committed;
- le working tree coinvolte devono essere pulite.

Una validation run deve registrare almeno:

- identificatore/versione o commit del target;
- commit della suite di test;
- sistema operativo e informazioni host rilevanti;
- architettura;
- data della sessione;
- test eseguiti;
- risultati `PASS`, `FAIL`, `SKIP`, `ERROR`;
- eventuali condizioni o eccezioni rilevanti.

Le sessioni significative devono essere conservate nel repository dei test come evidenza sperimentale riproducibile.

## 15. Ripetibilità della procedura

La stessa suite deve poter essere eseguita su host diversi senza modificare manualmente i test per adattarli al pathname locale del checkout.

Il target deve essere identificato dal runner tramite una regola esplicita e verificabile.

La collocazione del repository dei test sotto `$RumiAI_ROOT/.dev/` è una convenienza del workspace locale e non deve essere l'unico modo possibile per indicare il target.

## 16. Runner

Il runner deve essere mantenuto semplice.

Le sue responsabilità iniziali sono:

- individuare o ricevere esplicitamente il target;
- selezionare i test richiesti;
- eseguire ogni test in modo isolato quanto necessario;
- raccogliere gli exit status `PASS/FAIL/SKIP/ERROR`;
- produrre un riepilogo leggibile;
- per le validation run, registrare i metadati necessari alla riproducibilità.

Il runner non deve incorporare logica specifica dei singoli componenti quando tale logica può restare nel relativo test.

## 17. Regola di promozione

Quando un PoC o una validazione manuale scopre una proprietà che deve restare vera nel tempo, tale proprietà deve essere trasformata in un test permanente quando il costo è ragionevole.

Un bug corretto dovrebbe produrre un test di regressione quando esiste un modo deterministico e sostenibile per riprodurlo.

## 18. Fonte di verità

`rumiai-dev` definisce le regole e il comportamento atteso.

Il repository dei test conserva l'implementazione eseguibile dei test e le evidenze delle validation run.

`rumiai-os` contiene il prodotto e non diventa fonte normativa delle regole di testing.

In caso di conflitto tra questo documento e una suite di test, prevalgono le regole e le specifiche canoniche di `rumiai-dev`.
