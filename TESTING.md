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

## 2. Repository e separazione tra prodotto, PoC e test

I quattro repository canonici coinvolti nel ciclo iniziale di sviluppo e validazione sono:

```text
rumiai-dev       regole, specifiche, decisioni, architettura e memoria dello sviluppo
rumiai-os        prodotto/runtime stabile
rumiai-dev-PoCs  laboratorio sperimentale e proof-of-concept
rumiai-tests     suite permanente di test e validazione
```

I test permanenti non appartengono al repository del prodotto `rumiai-os` e non appartengono al repository sperimentale `rumiai-dev-PoCs`.

`rumiai-dev-PoCs` contiene esperimenti, domande ancora aperte e prototipi che possono essere modificati, sostituiti o eliminati.

`rumiai-tests` contiene verifiche ripetibili che devono continuare a proteggere nel tempo proprietà consolidate di RumiAI e delle dipendenze esterne effettivamente usate.

Un PoC riuscito può diventare origine di uno o più test permanenti, ma PoC e test restano concettualmente e fisicamente distinti.

## 3. Workspace locale di sviluppo

`rumiai-os` deve poter ospitare un workspace locale di sviluppo sotto:

```text
$RumiAI_ROOT/.dev/
```

Il contenuto operativo di `.dev/` non appartiene al prodotto e deve essere ignorato dal repository `rumiai-os`.

La configurazione canonica iniziale è:

```text
$RumiAI_ROOT/.dev/rumiai-tests/
```

come clone locale del repository `rumiai-tests`.

Quando serve attività sperimentale può essere presente anche:

```text
$RumiAI_ROOT/.dev/rumiai-dev-PoCs/
```

I repository sotto `.dev/` restano repository Git autonomi. Non devono essere incorporati in `rumiai-os` come submodule e non devono diventare dipendenze necessarie all'esecuzione del prodotto.

La collocazione sotto `.dev/` è una convenienza del workspace locale, non un requisito per poter eseguire la suite contro un target fornito esplicitamente.

## 4. Struttura iniziale di `rumiai-tests`

La struttura iniziale deve restare minima:

```text
rumiai-tests/
├── README.md
├── rumiai-test
├── lib/
│   └── test.lib
├── tests/
│   ├── rumiai-os/
│   │   ├── bootstrap/
│   │   ├── command/
│   │   ├── i18n/
│   │   ├── log/
│   │   └── shell/
│   └── external/
└── sessions/
```

Directory ulteriori devono essere introdotte solo quando emerge una necessità concreta.

## 5. Nome del runner

Il runner pubblico della suite si chiama:

```text
rumiai-test
```

Il nome `test` non deve essere usato perché collide semanticamente e operativamente con l'utility `test` definita da POSIX.

Il nome `rumiai-test` è namespaced, identifica chiaramente la suite RumiAI e non dipende dal linguaggio con cui il runner è implementato.

## 6. Organizzazione gerarchica dei test

I test permanenti devono essere organizzati principalmente per oggetto o capability verificata, non per tecnologia di implementazione.

Ogni directory normale sotto `tests/` rappresenta un gruppo di test. I gruppi possono contenere test e sottogruppi e possono quindi essere nidificati quanto necessario dalla struttura logica della suite.

Esempio:

```text
tests/
├── rumiai-os/
│   ├── bootstrap/
│   │   ├── path/
│   │   └── status/
│   ├── command/
│   ├── i18n/
│   ├── log/
│   └── shell/
└── external/
```

Un singolo test può essere selezionato ed eseguito individualmente.

La selezione di un gruppo significa eseguire ricorsivamente tutti i test appartenenti a quel gruppo e ai suoi sottogruppi.

La directory `tests/` è il gruppo radice e rappresenta l'intera suite. L'esecuzione del gruppo radice equivale quindi all'esecuzione dell'intera suite applicabile.

Il pathname relativo a `tests/` costituisce l'identificatore gerarchico naturale di un test o di un gruppo ed è il riferimento da usare per selezione, output, diagnostica e registrazione delle sessioni.

Classificazioni come `unit`, `integration`, `system` o `e2e` possono essere aggiunte solo quando producono un vantaggio concreto e non devono sostituire l'identificazione dell'oggetto verificato.

## 7. Discovery dei test e materiale interno

Il riconoscimento dei test deve dipendere da regole semplici e deterministiche del filesystem.

Un file regolare il cui nome termina in:

```text
.test
```

identifica un test permanente.

L'estensione `.test` ha significato semantico: identifica il ruolo del file nella suite e non il linguaggio con cui il test è implementato.

Una directory il cui nome inizia con `.` è materiale interno e non è un gruppo. Il runner non deve attraversarla durante la discovery ricorsiva.

Questa convenzione permette di collocare accanto ai test fixture, helper, dati o altro materiale di supporto, ad esempio:

```text
tests/rumiai-os/bootstrap/
├── absolute.test
├── relative.test
├── README.md
├── .fixtures/
│   └── source
└── .support/
    └── helper
```

Un pathname nascosto viene escluso dalla discovery prima di applicare la regola `.test`; di conseguenza un file nascosto che termina in `.test` non viene scoperto come test.

Ogni file che non termina in `.test` e che non ha un altro ruolo esplicitamente richiesto viene ignorato dal discovery del runner.

Le regole canoniche di discovery sono quindi:

1. `*.test` identifica esclusivamente un test;
2. ogni directory normale sotto `tests/` identifica un gruppo;
3. directory e pathname nascosti il cui nome inizia con `.` sono esclusi dalla discovery;
4. ogni altro file viene ignorato dal runner.

## 8. Indipendenza assoluta dei test

Ogni test è un'unità autonoma di validazione.

Ogni test deve poter essere eseguito singolarmente e deve produrre lo stesso risultato, a parità di target, configurazione dichiarata e condizioni rilevanti dell'host, indipendentemente dai test eseguiti prima o dopo.

Un test non può dipendere da:

- un altro test già eseguito;
- stato lasciato da un altro test;
- setup o cleanup appartenenti a un altro test;
- file, processi, servizi, configurazioni o risultati intermedi prodotti da un altro test;
- posizione del test nell'ordine di esecuzione della suite.

Qualunque test che passi soltanto perché un altro test è stato eseguito prima è, per definizione, un test invalido.

Se una proprietà richiede una sequenza coordinata di operazioni prima del cleanup, l'intera sequenza deve essere implementata all'interno di un singolo test indipendente. Dal punto di vista della suite quel test resta una sola unità, anche se internamente contiene più fasi o step.

L'indipendenza prevale sull'ottimizzazione. Non si deve introdurre stato condiviso tra test soltanto per evitare il costo di setup o cleanup ripetuti.

## 9. Gruppi senza orchestrazione

Un gruppo è esclusivamente un contenitore gerarchico e un'unità di selezione ricorsiva.

Un gruppo non può definire semantica di orchestrazione tra i test che contiene.

Non sono ammessi come proprietà del gruppo:

- dipendenze tra test;
- setup condiviso necessario al funzionamento dei test;
- teardown condiviso necessario alla correttezza dei test;
- comunicazione o passaggio di stato tra test;
- ordine personalizzato con significato funzionale;
- primitive `before`, `after` o equivalenti che rendano un test dipendente dal gruppo.

Se una validazione necessita di operazioni coordinate, tali operazioni appartengono a un singolo test indipendente e non al gruppo.

## 10. Ordine deterministico ma semanticamente irrilevante

Quando viene eseguito un gruppo, il runner deve attraversarne deterministicamente test e sottogruppi in ordine lessicografico dei rispettivi identificatori.

L'ordine lessicografico serve esclusivamente a rendere l'esecuzione prevedibile, riproducibile, leggibile e facilmente confrontabile tra host e sessioni.

L'ordine non ha alcun significato funzionale e nessun test può fare affidamento sul fatto di essere eseguito prima o dopo un altro test.

Il runner può in futuro adottare forme di esecuzione parallela soltanto se preservano il contratto osservabile della suite e l'indipendenza dei test. La correttezza di un test non deve dipendere dall'esecuzione seriale.

## 11. Responsabilità di un test

Ogni test deve verificare una proprietà chiaramente identificabile.

Un test non deve aggregare comportamenti indipendenti se il loro fallimento può essere diagnosticato meglio con test separati.

La presenza di più step interni è appropriata quando tali step sono necessari per verificare una singola proprietà o scenario autonomo e vengono interamente gestiti, verificati e ripuliti dalla stessa unità di test.

Il nome del test deve descrivere la proprietà verificata e non il linguaggio con cui il test è implementato.

## 12. Determinismo

A parità di:

- test;
- versione del target;
- configurazione dichiarata;
- condizioni dell'host rilevanti;

il risultato deve essere riproducibile.

Quando una dipendenza rende il comportamento intrinsecamente non deterministico, il test deve dichiararlo esplicitamente e deve verificare invarianti deterministiche quando possibile.

## 13. Esito del test e stato del programma testato

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
- `SKIP`: il test non è applicabile o una precondizione dichiarata necessaria all'esecuzione non è disponibile;
- `ERROR`: il test non ha potuto stabilire il risultato per un errore del test, del runner o dell'ambiente di esecuzione.

Una incompatibilità reale dell'host rispetto alla proprietà richiesta non deve essere convertita artificialmente in `PASS` o `SKIP`: deve produrre `FAIL`.

`SKIP` non significa "incompatibilità nota e accettata". Una incompatibilità nota rimane evidenza di `FAIL`; la decisione di accettarla appartiene alla valutazione della sessione e alla politica di compatibilità, non al test.

Esempio: se il comportamento atteso del target è terminare con status `143`, il test restituisce `0` quando osserva correttamente `143`.

## 14. Universalità rispetto agli host

La proprietà verificata da un test deve essere espressa in modo universale rispetto agli host sui quali quel test è applicabile.

La suite non deve duplicare normalmente lo stesso test in alberi separati per macOS, Ubuntu, Windows o architetture differenti. Lo stesso test deve essere eseguito sui diversi host e produrre l'esito corrispondente al comportamento realmente osservato.

Un test non deve contenere eccezioni host-specifiche introdotte allo scopo di trasformare una incompatibilità reale in `PASS` o `SKIP`.

Quando un comportamento è intenzionalmente e intrinsecamente specifico di una piattaforma, tale specificità può essere parte della proprietà testata; ciò non modifica il principio generale secondo cui una proprietà comune deve avere un unico test.

La suite descrive quindi **cosa deve essere verificato**; la sessione descrive **dove e in quali condizioni è stato verificato**.

## 15. Host di riferimento e host periodici

Gli host stabili di riferimento correnti sono:

```text
macOS
Ubuntu 26.04 ARM64
```

Host aggiuntivi usati periodicamente includono:

```text
Ubuntu 26.04 x64
Windows 10 x64
Windows 11 x64
```

La classificazione degli host può evolvere senza richiedere modifiche ai test.

Un `PASS` su un host non sostituisce l'evidenza richiesta su un altro host di riferimento.

Quando un test fallisce, il fallimento deve essere valutato insieme alle caratteristiche dell'host registrate nella sessione. Il progetto può decidere, quando l'incompatibilità non è abbastanza importante da giustificare una modifica al prodotto, di accettarla esplicitamente e lasciarla nota.

L'accettazione di una incompatibilità non modifica retroattivamente l'esito del test: il risultato della sessione resta `FAIL` per quell'host.

## 16. Portabilità dei test

I test devono rispettare il contratto di piattaforma di RumiAI quando testano funzionalità portabili.

Non devono contenere path host-specifici hardcoded, nomi utente, home directory, path Homebrew, directory locali convenzionali o altre assunzioni non dichiarate.

I path del target devono essere derivati dal target stesso o forniti esplicitamente.

Le risorse temporanee devono essere create tramite meccanismi portabili appropriati e non devono assumere una specifica installazione locale.

## 17. Isolamento

Un test non deve modificare il target reale quando la stessa verifica può essere eseguita senza modificarlo.

Quando sono necessarie modifiche a configurazioni, file, symlink, permessi o layout, il test deve preferire una sandbox o copia temporanea isolata del materiale necessario.

La working tree dello sviluppatore non deve essere usata come area temporanea di test salvo che ciò sia esattamente la proprietà che il test deve verificare.

Ogni test deve possedere e gestire autonomamente le proprie risorse temporanee. Le risorse create da un test non devono diventare precondizioni per altri test.

## 18. Cleanup

Ogni test deve lasciare l'ambiente nello stato precedente all'esecuzione, per quanto sotto il suo controllo.

Il cleanup deve essere tentato anche dopo un `FAIL` o `ERROR`.

Al termine di un test non devono rimanere inutilmente modifiche al target, file temporanei, configurazioni temporanee, processi o servizi avviati dal test, mount, socket, lock o altre risorse create dal test.

Un test che lascia stato residuo non dichiarato è difettoso.

Il cleanup appartiene al test che ha creato la risorsa e non può essere delegato a un test successivo o a un gruppo.

## 19. Diagnostica dei fallimenti

Un `FAIL` o `ERROR` deve fornire informazioni sufficienti a comprendere almeno:

- quale proprietà è fallita;
- risultato atteso;
- risultato osservato.

La diagnostica deve essere concisa e utile. Non deve dipendere dalla lettura di log voluminosi quando il confronto essenziale può essere mostrato direttamente.

## 20. Test di tool esterni

Un tool esterno viene testato soltanto rispetto alle capability o proprietà necessarie a RumiAI.

Esempio: se RumiAI richiede la canonicalizzazione di un pathname, il test deve verificare la semantica necessaria della canonicalizzazione, non tentare di validare l'intero programma `realpath`.

La disponibilità di opzioni o comportamenti non usati da RumiAI non costituisce di per sé materia di test.

Un test di una proprietà esterna deve restare unico anche quando implementazioni host differenti del tool producono risultati differenti: tali differenze emergono attraverso le sessioni e gli esiti del test.

## 21. Development run

Una development run serve al ciclo rapido:

```text
sviluppo -> test -> correzione -> test
```

Durante una development run:

- il target può avere modifiche non committed;
- `rumiai-tests` può avere modifiche non committed;
- la sessione non costituisce evidenza formale di validazione di un commit.

Il runner deve comunque evitare di danneggiare o sporcare il target.

## 22. Validation run

Una validation run produce evidenza riproducibile associata a revisioni precise.

Prima di una validation run, salvo eccezioni esplicitamente documentate:

- il target deve essere committed;
- `rumiai-tests` deve essere committed;
- le working tree coinvolte devono essere pulite.

Una validation run deve registrare almeno:

- identificatore/versione o commit del target;
- commit di `rumiai-tests`;
- sistema operativo;
- versione del sistema operativo;
- architettura;
- shell o ambiente POSIX rilevante quando materialmente significativo;
- altre caratteristiche host necessarie a interpretare i risultati;
- data della sessione;
- test eseguiti;
- risultati `PASS`, `FAIL`, `SKIP`, `ERROR`;
- eventuali condizioni o eccezioni rilevanti.

Le sessioni di validazione permanente devono essere conservate sotto:

```text
rumiai-tests/sessions/
```

Le sessioni sperimentali dei PoC restano invece nel relativo materiale sotto `rumiai-dev-PoCs`.

## 23. Ripetibilità della procedura

La stessa suite deve poter essere eseguita su host diversi senza modificare manualmente i test per adattarli al pathname locale del checkout.

Il target deve essere identificato dal runner tramite una regola esplicita e verificabile.

La collocazione di `rumiai-tests` sotto `$RumiAI_ROOT/.dev/` non deve essere l'unico modo possibile per indicare il target.

## 24. Runner `rumiai-test`

Il runner deve essere mantenuto semplice.

Le sue responsabilità iniziali sono:

- individuare o ricevere esplicitamente il target;
- selezionare un singolo test o un gruppo;
- trattare `tests/` come gruppo radice dell'intera suite;
- attraversare ricorsivamente i gruppi selezionati;
- applicare le regole canoniche di discovery;
- eseguire ogni test come unità indipendente;
- mantenere un ordine lessicografico deterministico quando l'esecuzione è seriale;
- raccogliere gli exit status `PASS/FAIL/SKIP/ERROR`;
- produrre un riepilogo leggibile;
- per le validation run, registrare i metadati necessari alla riproducibilità e all'interpretazione host-specifica dei risultati.

Il runner non deve incorporare logica specifica dei singoli componenti quando tale logica può restare nel relativo test.

La sua CLI precisa deve essere definita e validata prima dell'implementazione stabile; non va introdotta complessità preventiva.

## 25. Regola di promozione

Quando un PoC o una validazione manuale scopre una proprietà che deve restare vera nel tempo, tale proprietà deve essere trasformata in un test permanente quando il costo è ragionevole.

Un bug corretto dovrebbe produrre un test di regressione quando esiste un modo deterministico e sostenibile per riprodurlo.

Il flusso concettuale è:

```text
esperimento
    -> rumiai-dev-PoCs
    -> risultato consolidato in rumiai-dev
    -> implementazione
    -> rumiai-tests
    -> evidenza permanente
```

## 26. Fonte di verità

`rumiai-dev` definisce le regole e il comportamento atteso.

`rumiai-tests` conserva l'implementazione eseguibile dei test permanenti e le evidenze delle validation run.

`rumiai-dev-PoCs` conserva l'evidenza sperimentale e i proof-of-concept.

`rumiai-os` contiene il prodotto e non diventa fonte normativa delle regole di testing.

In caso di conflitto tra questo documento e una suite di test, prevalgono le regole e le specifiche canoniche di `rumiai-dev`.
