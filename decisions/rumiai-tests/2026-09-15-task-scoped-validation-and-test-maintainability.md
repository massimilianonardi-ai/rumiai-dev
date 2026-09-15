# Decisione — Task-scoped validation e semplificazione della suite permanente

Date: 2026-09-15  
Status: **Accepted / Active**

## 1. Contesto

L'esperienza accumulata con la suite permanente ha mostrato tre costi non più accettabili:

1. una full-suite non verde veniva trattata operativamente come mancata validazione di ogni work unit, anche quando tutti i test pertinenti a quel work unit erano PASS;
2. l'indipendenza dei test era stata spinta fino alla copia inline di target discovery e fixture comuni, moltiplicando drift e manutenzione;
3. diversi fallimenti di validation recenti erano difetti o aspettative superseded dei test, non regressioni del prodotto.

Il caso resource model ha reso il problema evidente: i test specifici del resource model erano PASS sui reference host, mentre la full selection `rumiai-os` falliva in larga parte perché molte copie inline di fixture conservavano il vecchio top-level `lang`. Correzioni analoghe erano già state necessarie per expectation command, pathname canonicali macOS e altri casi.

L'obiettivo di questa decisione non è ridurre la qualità della validation. È aumentare il rapporto segnale/rumore e permettere sviluppo realmente parallelo.

## 2. Distinzione normativa degli esiti

Sono distinti:

```text
test result
session result
task validation
```

Il test result resta PASS/FAIL/SKIP/ERROR.

Il session result resta l'aggregazione dei test realmente eseguiti e non viene reinterpretato.

La task validation riguarda invece esclusivamente i test dichiarati necessari al work unit.

Una sessione complessivamente FAIL o ERROR può quindi contenere evidence sufficiente a validare un work unit quando tutti i test richiesti dal relativo scope sono PASS e i fallimenti restanti sono dimostrati estranei al work unit.

## 3. Validation scope

Ogni work unit che richiede physical validation deve avere uno scope fissato prima del run.

Lo scope deriva da:

```text
contratto modificato
consumer diretti materialmente coinvolti
regressioni pertinenti
proprietà cross-platform coinvolte
```

Uno scope task deve essere minimo ma sufficiente.

Non è consentito rimuovere a posteriori un test dallo scope per trasformare un fallimento correlato in una validation positiva.

Se un fallimento apparentemente estraneo risulta causato dal work unit, quel test entra nello scope prima della chiusura.

## 4. Full suite

La full suite non è più il gate universale di ogni task.

È un `health` gate appropriato per:

```text
release
milestone
modifiche trasversali
controlli periodici di salute
indagini che richiedono realmente l'intero prodotto
```

Un health gate rosso segnala lavoro da fare, ma non annulla automaticamente validation task positive e indipendenti.

## 5. Parallelismo

Scope differenti devono poter coesistere nella suite e venire eseguiti separatamente.

Il launcher operativo resta un solo eseguibile:

```text
rumiai-validate
```

Non vengono creati molti eseguibili `rumiai-validate-<task>`.

La forma operativa corrente è:

```text
./rumiai-validate                 # self-update + selettore interattivo degli scope correnti
./rumiai-validate <scope-name>    # esecuzione diretta di uno scope nominato
```

Il comportamento no-arg è definito dalla decisione attiva `2026-09-15-interactive-validation-scope-selector.md`: il launcher determina la propria root, entra nella root di `rumiai-tests`, si autoaggiorna e soltanto dopo mostra l'elenco numerato degli scope materializzati.

Gli scope nominati sono configurazioni versionate sotto:

```text
validation/<scope-name>.conf
```

Uno scope può contenere più record `selection`; il launcher esegue una validation elementare per ciascuna selection e aggrega il risultato di scope.

`rumiai-test` resta a singola selection e non acquisisce semantica di task.

## 6. Semantica di scope task

Uno scope `task` è `VALIDATED` su un host solo quando tutti i test richiesti dalle sue selection hanno PASS.

Per uno scope task:

```text
PASS richiesti tutti presenti -> VALIDATED
FAIL                         -> NOT VALIDATED
ERROR                        -> TEST ERROR
SKIP richiesto               -> NOT VALIDATED
runner/infrastructure error  -> LAUNCHER/RUNNER ERROR
```

Uno SKIP non viene trasformato in FAIL: semplicemente non costituisce evidence positiva della proprietà richiesta.

Gli scope `health` conservano la normale semantica aggregata del runner, inclusa la possibilità di status 0 con SKIP applicabili secondo il contratto corrente.

## 7. Revisione target e checkout dell'operatore

Uno scope resta revision-specific tramite `rumiai-os-commit`.

Il launcher può usare un Git worktree temporaneo detached dell'esatta revisione configurata quando il checkout principale dell'operatore è già avanzato. In questo modo scope di work unit differenti possono essere validati senza checkout distruttivi, reset o riscrittura di storia.

Il worktree temporaneo è infrastruttura della validation e deve essere rimosso al termine.

## 8. Indipendenza dei test

L'indipendenza normativa significa assenza di dipendenza da stato, ordine, setup/cleanup o risultati di altri test.

Non significa duplicare codice infrastrutturale.

Le librerie condivise della stessa revisione `rumiai-tests` sono ammesse e preferite per responsabilità realmente comuni. La revisione della suite registrata dalla validation rende riproducibile la versione delle librerie usata.

La precedente preferenza generale per copie inline di reference implementation è superseded.

Le copie inline restano ammesse soltanto quando il congelamento locale è semanticamente necessario e documentato.

## 9. Qualità del test

Un test permanente deve preferire il contratto osservabile ai dettagli incidentali dell'implementazione.

White-box e structural checks restano corretti quando la struttura è essa stessa normativa.

Sono da evitare come default:

```text
grep di stringhe interne
nomi di funzioni private
ordine testuale/numero di riga
spelling host-specifico di pathname equivalenti
duplicazione di fixture comuni
```

Quando possibile, fake/fixture controllati devono osservare invocazioni, argomenti, effetti e transizioni reali.

## 10. Audit della suite esistente

La suite corrente deve essere progressivamente classificata:

```text
keep
simplify
merge
remove
```

Priorità iniziale:

```text
bootstrap
command
shell
pkg
```

perché sono le aree dove il costo di fixture/expectation drift è già stato osservato fisicamente.

Non è richiesto eliminare test per raggiungere un numero arbitrario. Ogni rimozione o fusione deve preservare la proprietà realmente utile.

## 11. Relazione con decisioni precedenti

Questa decisione modifica esclusivamente la politica di testing/validation.

Supersede dove in conflitto:

- la richiesta operativa di full-suite positiva come condizione universale di chiusura di un work unit;
- la preferenza generale di `AUTHORING.md` / `TEST-PATTERNS.md` per copie inline di helper comuni;
- la configurazione launcher limitata a una sola selection e a un solo scope globale.

Non modifica:

- PASS/FAIL/SKIP/ERROR del singolo test;
- immutabilità delle evidence storiche;
- exact revision recording;
- host contract;
- indipendenza di stato e ordine;
- Git forward-only;
- contratti di `rumiai-os`.

La precedente decisione `2026-09-15-advance-validation-pair-after-resource-srv-remediation.md` resta evidence dello stato precedente, ma il suo requisito di ottenere una full-suite positiva prima di considerare chiuso il resource-model work unit è superseded. Il full run può ancora essere eseguito come health gate.

## 12. Invarianti

```text
TEST-SCOPE-01  test result, session result e task validation sono distinti
TEST-SCOPE-02  un task è validato dai soli test fissati nel proprio scope
TEST-SCOPE-03  tutti i test richiesti da uno scope task devono PASS; SKIP non basta
TEST-SCOPE-04  fallimenti estranei restano evidence ma non invalidano il task
TEST-SCOPE-05  uno scope non può essere ristretto a posteriori per escludere un fallimento correlato
TEST-SCOPE-06  la full suite è health/release/milestone gate, non gate universale
TEST-SCOPE-07  rumiai-test resta semantically-agnostic e a singola selection
TEST-SCOPE-08  rumiai-validate può applicare scope nominati con più selection
TEST-SCOPE-09  helper infrastrutturali comuni possono essere librerie condivise della stessa suite revision
TEST-SCOPE-10  indipendenza significa stato/ordine, non duplicazione del codice
TEST-SCOPE-11  i test preferiscono comportamento osservabile; white-box solo quando la struttura è contratto
TEST-SCOPE-12  la suite esistente viene auditata keep/simplify/merge/remove
TEST-SCOPE-13  evidence storiche non vengono riscritte o reinterpretate
TEST-SCOPE-14  Git resta forward-only
TEST-SCOPE-15  nessuna modifica a rumiai-os è introdotta da questa decisione
```
