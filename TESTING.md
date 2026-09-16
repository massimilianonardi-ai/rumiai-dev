# RumiAI Testing Rules

Questo documento definisce le regole canoniche per la scrittura, l'esecuzione e la conservazione dei test di RumiAI.

Le regole sono normative per i test permanenti e per le validation run. I proof-of-concept restano attività sperimentali distinte.

## 1. Scopo dei test

I test proteggono proprietà consolidate e materialmente rilevanti di RumiAI e delle dipendenze esterne realmente usate.

Un test permanente deve esistere perché protegge un contratto, un invariante, un comportamento osservabile o una regressione concreta. La quantità di test non è un obiettivo.

Un test che non protegge più una proprietà corrente, duplica senza beneficio una proprietà già coperta, oppure costa più manutenzione del rischio che mitiga deve essere semplificato, fuso o eliminato.

## 2. Repository e ruoli

```text
rumiai-dev       regole, specifiche, decisioni, architettura e memoria dello sviluppo
rumiai-os        prodotto/runtime stabile
rumiai-dev-PoCs  esperimenti e proof-of-concept
rumiai-tests     test permanenti, runner, launcher ed evidenze di validation
```

I test permanenti non appartengono al prodotto. Un PoC può originare un test permanente, ma resta concettualmente distinto.

## 3. Organizzazione e discovery

I test sono organizzati principalmente per oggetto o capability verificata.

Sotto `tests/`:

1. un file regolare `*.test` è un test permanente;
2. una directory normale è un gruppo selezionabile ricorsivamente;
3. pathname nascosti il cui nome inizia con `.` sono materiale interno e non vengono scoperti;
4. ogni altro file viene ignorato dal runner.

Il pathname relativo a `tests/` è l'identificatore naturale del test o gruppo.

La root `tests/` rappresenta l'intera suite applicabile.

## 4. Indipendenza dei test

L'indipendenza è **indipendenza di esecuzione e di stato**, non duplicazione del codice di infrastruttura.

Ogni test deve poter essere eseguito singolarmente e deve produrre lo stesso risultato, a parità di target, configurazione dichiarata e condizioni rilevanti dell'host, indipendentemente dai test eseguiti prima o dopo.

Un test non può dipendere da:

- stato lasciato da un altro test;
- setup o cleanup di un altro test;
- risultati intermedi di un altro test;
- ordine di esecuzione;
- comunicazione tra test.

Un gruppo è un contenitore e un'unità di selezione, non un orchestratore. Non introduce `before`, `after`, setup condiviso necessario o ordine funzionale.

Questa indipendenza **non vieta** librerie comuni della stessa revisione di `rumiai-tests`. Helper di infrastruttura come target discovery, creazione di repliche isolate complete del target, path normalization, temporary-resource plumbing e driver interattivi devono essere condivisi quando la responsabilità è realmente comune.

La revisione Git esatta di `rumiai-tests` fa già parte dell'evidenza di validation e rende riproducibile la versione degli helper condivisi usata dalla sessione.

La copia inline di helper comuni non è il default. È ammessa soltanto quando il contenuto copiato è intenzionalmente parte della semantica specifica della prova o quando esiste una ragione documentata per congelarlo dentro quel test.

## 5. Responsabilità del singolo test

Ogni test deve verificare una proprietà chiaramente identificabile.

Il test possiede:

- precondizioni specifiche della prova;
- preparazione specifica dello scenario;
- input esterni e, soltanto quando espressamente ammesso, simulazioni o fixture semanticamente specifiche;
- esecuzione del target;
- risultato atteso;
- confronto tra atteso e osservato;
- diagnostica specifica;
- cleanup delle risorse create dalla prova.

Il runner non deve conoscere la semantica del target.

La logica infrastrutturale comune non deve essere replicata in ogni test se una libreria condivisa già copre la stessa responsabilità.

## 6. Contratto osservabile prima dell'implementazione

Un test deve preferire il comportamento osservabile e gli invarianti pubblici o architetturali ai dettagli incidentali dell'implementazione.

Un controllo white-box è appropriato soltanto quando la rappresentazione interna è essa stessa parte del contratto, per esempio file mode, assenza di shebang, layout fisico fissato o altra proprietà strutturale normativa.

Non devono essere usati come proxy del comportamento, salvo requisito esplicito:

- grep di stringhe interne;
- nomi di funzioni private;
- ordine testuale di chiamate nel sorgente;
- numeri di riga;
- spelling accidentale di pathname equivalenti;
- dettagli di implementazione che possono cambiare senza cambiare il contratto.

### Autenticità del sistema sotto test

Un test di comportamento deve esercitare il sistema reale che dichiara di verificare. L'isolamento serve a rendere la prova ripetibile e scartabile; non autorizza a sostituire il sistema sotto test con una ricostruzione artificiale.

Quando il target deve essere protetto dagli effetti della prova, il test deve usare una replica isolata completa e semanticamente indistinguibile del sistema reale per la proprietà verificata. La replica deve usare la revisione reale del target, i suoi eseguibili reali, le sue librerie reali, i suoi adapter reali, i suoi file reali e il normale percorso di esecuzione. Stato, `HOME`, directory temporanee e altre risorse mutabili possono e devono essere isolati quando necessario, purché l'isolamento non sostituisca la logica del target.

Per un comportamento esposto da un comando, la forma normale della prova consiste in pochi comandi reali che invocano l'eseguibile reale tramite la sua normale interfaccia e usano argomenti scelti per coprire le casistiche del contratto. Se si verifica `pkg install`, la prova deve eseguire realmente `pkg install` e attraversare la pipeline reale che quel comando utilizza.

Non costituiscono prova del comportamento reale del target:

- copiare singoli file o frammenti del target in una struttura costruita ad hoc;
- source-are una libreria interna al posto di invocare l'entrypoint reale quando il contratto da verificare è quello dell'entrypoint o del sistema composto;
- ridefinire, intercettare o sostituire funzioni del target;
- sostituire adapter, cataloghi, downloader, extractor, integrator o altri componenti appartenenti al percorso reale verificato con implementazioni finte;
- costruire un PATH artificiale contenente copie modificate degli eseguibili del target;
- dichiarare validato un comportamento composto quando una parte della composizione non è stata realmente eseguita.

Simulazioni, fixture, stub, pseudo-terminali o input sintetici sono eccezioni, non il modello predefinito. Sono ammessi quando servono a rappresentare un input esterno alla logica sotto test che non è ragionevolmente producibile in modo diretto, in particolare input utente o interattivo, oppure quando una specifica regola o decisione li autorizza esplicitamente. Non devono sostituire componenti del target che il test dichiara di validare.

Un test che usa una simulazione valida soltanto la proprietà effettivamente esercitata attraverso quella simulazione. Non può essere usato come evidenza della stessa proprietà attraverso il percorso reale che è stato sostituito o escluso.

## 7. Granularità e costo

Un test deve essere abbastanza piccolo da rendere diagnosticabile una violazione, ma la frammentazione non è un obiettivo.

Varianti dello stesso contratto possono essere casi di un unico test quando condividono setup, comportamento atteso e failure model e la separazione non migliora materialmente la diagnosi.

Prima di creare un nuovo test permanente deve essere verificato che la stessa proprietà non sia già protetta.

Durante l'audit della suite ogni test deve poter essere classificato come:

```text
keep        protegge una proprietà distinta con costo proporzionato
simplify    proprietà utile ma test sovra-specificato o infrastruttura eccessiva
merge       proprietà utile ma frammentazione non necessaria
remove      nessuna proprietà corrente distinta o valore insufficiente
```

## 8. Esecuzione diretta e librerie condivise

Un `.test` resta un programma direttamente eseguibile e deve poter localizzare la root della suite dalla propria posizione quando necessita di librerie comuni.

L'esecuzione diretta e quella tramite `rumiai-test` devono esercitare la stessa logica di verifica.

Le librerie sotto `rumiai-tests/lib/` possono essere dipendenze runtime deliberate dei test permanenti. Devono essere piccole, stabili, testabili e limitate a responsabilità infrastrutturali comuni.

Una modifica a una libreria condivisa richiede test proporzionati della libreria e dei consumer materialmente interessati, non la duplicazione della modifica in copie inline.

## 9. Self-discovery e pathname

I test non devono dipendere dal pathname assoluto di un checkout personale.

È corretto hardcodare nomi e relazioni logiche stabili appartenenti alla proprietà verificata; non è corretto hardcodare home personali, path Homebrew, directory locali dello sviluppatore o spelling host-specifici equivalenti.

Quando la proprietà riguarda pathname fisici/canonicalizzati, anche l'aspettativa del test deve essere canonicalizzata secondo il contratto pertinente.

Il runner non individua il target per conto del test. Una libreria comune di `rumiai-tests` può farlo per i test che condividono lo stesso target-discovery contract.

## 10. Determinismo, portabilità e host

A parità di test, target, configurazione dichiarata e condizioni host rilevanti, il risultato deve essere riproducibile.

La stessa proprietà comune deve normalmente usare lo stesso test sui diversi host. Non si creano copie macOS/Linux/Windows soltanto per adattare le aspettative.

Gli host stabili di riferimento correnti sono:

```text
macOS
Ubuntu 26.04 ARM64
```

Host periodici possono includere Ubuntu x64 e ambienti Windows POSIX-compatible quando pertinenti.

Un PASS su un host non sostituisce l'evidenza richiesta su un altro host applicabile.

## 11. Esito del singolo test

Gli exit status del test restano:

```text
0 = PASS
1 = FAIL
2 = SKIP
3 = ERROR
```

- `PASS`: comportamento osservato conforme all'atteso;
- `FAIL`: prova eseguita correttamente, comportamento non conforme;
- `SKIP`: prova non applicabile o precondizione dichiarata assente;
- `ERROR`: il test non ha potuto stabilire l'esito per errore della prova, dell'ambiente o dell'infrastruttura.

Un'incompatibilità reale dell'host con una proprietà richiesta è `FAIL`, non `SKIP`.

Gli esiti storici non vengono mai reinterpretati retroattivamente.

## 12. Isolamento e cleanup

Un test che può modificare stato o produrre effetti persistenti non deve per questo essere trasformato in una simulazione del target. Quando è necessario proteggere il checkout o l'installazione reale dell'operatore, il test deve creare o usare una replica completa e scartabile del sistema reale, oppure isolare esclusivamente lo stato mutabile mantenendo invariato il percorso di esecuzione reale.

Una replica del target usata per il test deve provenire dalla revisione reale sottoposta a prova e non da una raccolta di file selezionati, riscritti o ricostruiti ad hoc. Il principio "non modificare il target reale" significa non alterare l'istanza originale dell'operatore; non significa sostituire il target con fixture che ne imitano singole parti.

Ogni test possiede e ripulisce le risorse specifiche create dalla prova. Il cleanup deve essere tentato anche dopo `FAIL` o `ERROR`.

Il runner non implementa implicitamente sandbox, setup, teardown o workspace specifici del target.

## 13. Logging e diagnostica

Il runner cattura stdout e stderr del test in un unico stream ordinato equivalente a:

```sh
1>logfile 2>&1
```

Un `FAIL` o `ERROR` deve rendere comprensibili almeno proprietà fallita, atteso e osservato quando applicabili.

La diagnostica deve essere concisa e orientata alla causa, non a grandi dump non necessari.

## 14. Tool esterni

Un tool esterno viene testato soltanto per le proprietà da cui RumiAI dipende concretamente.

Non si valida genericamente un'intera utility, runtime o servizio esterno.

## 15. Development run

Una development run supporta il ciclo rapido:

```text
sviluppo -> test mirati -> correzione -> test mirati
```

Target e suite possono essere dirty e la run non costituisce evidenza formale di un commit.

## 16. Validation run, session result e task validation

Una validation run produce evidenza associata a revisioni precise.

Devono essere distinti tre livelli:

```text
test result       esito della singola proprietà
session result    aggregazione dei test eseguiti nella sessione
task validation   valutazione dei soli test richiesti dal work unit
```

Il risultato globale di una sessione non invalida automaticamente un work unit.

Se una sessione contiene test appartenenti a più contesti, un work unit è validato quando **tutti i test dichiarati necessari al suo validation scope hanno PASS** sugli host applicabili. FAIL, ERROR o SKIP di test estranei allo scope restano evidenza reale, ma non invalidano quel work unit.

Un test richiesto dallo scope che produce `SKIP` non è un PASS: il work unit resta non validato su quell'host finché la proprietà richiesta non è stata effettivamente esercitata o finché lo scope/host applicabile non viene corretto da una decisione autorevole.

La selezione dei test richiesti deve essere fissata **prima della validation**, in base a:

- contratto modificato;
- consumer diretti materialmente interessati;
- regressioni note pertinenti;
- proprietà cross-platform realmente coinvolte.

Lo scope non può essere ristretto dopo un fallimento per escludere un test che ha dimostrato di essere materialmente dipendente dal cambiamento.

Se durante una sessione un test inizialmente considerato estraneo fallisce e l'analisi dimostra che il fallimento deriva dal work unit, quel test entra nello scope necessario prima della chiusura.

## 17. Validation scope

Un **validation scope** è l'insieme versionato delle selection necessarie a validare un work unit o un health gate.

Uno scope può contenere uno o più test o gruppi già esistenti. Non richiede duplicare i test in una nuova gerarchia.

Sono distinti almeno due usi:

```text
task    scope minimo e sufficiente per chiudere un work unit
health  controllo ampio della salute/integrità del sistema
```

La full suite è normalmente un `health` gate. È appropriata per release, milestone, modifiche trasversali o controlli periodici, ma **non è il prerequisito universale per chiudere ogni task**.

Scope task differenti devono poter coesistere e venire eseguiti indipendentemente, così sviluppi non correlati non si bloccano a vicenda per fallimenti estranei.

## 18. Requisiti di una validation formale

Salvo eccezioni documentate:

- target e `rumiai-tests` devono essere committed;
- le working tree usate per la prova devono essere clean;
- devono essere registrati commit/revisioni, host, architettura, data/ora, selection eseguite, risultati e log;
- l'evidenza deve restare immutabile e revision-specific.

Una task validation cross-host è chiusa solo quando tutti i test richiesti dallo scope hanno PASS su tutti gli host applicabili richiesti.

Sessioni precedenti restano valide per le proprietà che hanno effettivamente esercitato; una sessione complessivamente FAIL non trasforma i suoi test PASS in FAIL.

Una validation non può attribuire a un PASS una proprietà che il test non ha realmente esercitato. In particolare, un test che sostituisce parti del target non può chiudere uno scope che richiede il comportamento reale composto di quelle parti.

## 19. `rumiai-test` e `rumiai-validate`

`rumiai-test` resta il runner semplice e semantically-agnostic. Discovery, esecuzione, logging, persistenza ed exit status del runner sono definiti in `RUNNER.md`.

`rumiai-validate` è il launcher operativo. Può applicare uno scope versionato composto da più selection e aggregare la loro evidenza senza spostare logica semantica del target nel runner.

Il launcher può usare un checkout/worktree Git temporaneo dell'esatta revisione target quando necessario per validare scope differenti senza modificare il checkout principale dell'operatore. Tale checkout/worktree è una replica reale del target: i test devono continuare a usare gli entrypoint e i componenti reali della revisione, non copie ad hoc o sostituzioni della pipeline verificata.

## 20. Promozione e rimozione dei test

Un bug corretto dovrebbe produrre un test di regressione quando la riproduzione è deterministica, sostenibile e protegge una proprietà che deve restare vera.

Non ogni bug del test deve generare un altro test del test. Correzioni infrastrutturali comuni devono preferibilmente essere concentrate nella libreria condivisa appropriata e protette al livello più basso utile.

Un test permanente può e deve essere rimosso quando la proprietà è superseded, duplicata o non più materialmente utile. L'evidenza storica resta immutabile nei commit/sessioni precedenti.

## 21. Fonte di verità

`rumiai-dev` definisce regole e comportamento atteso.

`rumiai-tests` contiene l'implementazione eseguibile dei test e le evidence di validation.

`rumiai-dev-PoCs` contiene esperimenti e PoC.

`rumiai-os` contiene il prodotto e non diventa fonte normativa delle regole di testing.

In caso di conflitto tra una suite di test e i contratti correnti di `rumiai-dev`, prevalgono i contratti correnti e il test deve essere riallineato o rimosso.

### Riallineamento corrente della suite

La chiarificazione del 2026-09-16 sull'autenticità del sistema sotto test rende esplicitamente non conforme, come prova del comportamento reale composto, qualunque test che sostituisca parti del target e poi attribuisca il PASS al sistema reale.

Alla revisione `298931c1dca03d44755893d64b9b3a7c0058b7ea` di `rumiai-tests`, `tests/rumiai-os/pkg/install.test` è **pending realignment**: il test corrente crea copie e componenti artificiali e sostituisce parti della pipeline di installazione. Fino al riallineamento, i suoi PASS storici o correnti non costituiscono validazione del comportamento reale di `pkg install`; valgono soltanto per le proprietà limitate effettivamente esercitate dalla prova costruita.

La suite deve essere auditata con lo stesso criterio e ogni altro test che sostituisce il proprio target comportamentale deve essere riallineato, riclassificato rispetto alla proprietà realmente verificata oppure rimosso.
