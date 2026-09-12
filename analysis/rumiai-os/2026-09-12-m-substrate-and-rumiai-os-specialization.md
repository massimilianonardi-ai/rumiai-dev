# Analisi esplorativa — scissione dell'attuale RumiAI OS in substrato general purpose e prodotto AI

Date: 2026-09-12  
Status: **EXPLORATORY / NON-NORMATIVE**

## 1. Scopo e chiarimento fondamentale

Questa nota esplora una possibile futura **scissione dell'attuale `rumiai-os` in due livelli distinti**.

L'ipotesi non consiste nel riprendere, modernizzare o riutilizzare il vecchio progetto/repository `massimilianonardi/m`.

Il punto di partenza è invece il **RumiAI OS corrente**:

```text
attuale rumiai-os
  bootstrap/runtime
  environment e semantic roots
  primitive e utility di sistema
  package manager e relativo runtime
  infrastruttura general purpose
  futura semantica/prodotto AI
```

L'ipotesi è separare progressivamente queste responsabilità in:

```text
nuovo substrato general purpose
(nome di lavoro possibile: m, ma nome non ancora deciso)
  <- estratto dall'attuale rumiai-os
  <- contiene il livello basso general purpose
  <- possiede il bootstrap/runtime generale
  <- non conosce RumiAI né l'AI

                    ↑
          contratti pubblici
                    ↑

RumiAI OS
  <- livello superiore costruito sul substrato
  <- prodotto/sistema/applicazione AI
  <- semantica, policy e capacità RumiAI
  <- possibile ruolo futuro di AI desktop/application environment
```

Quindi, se questa direzione venisse adottata:

```text
l'attuale bootstrap `rumiai-os`
  non resterebbe il bootstrap di RumiAI OS
  ma diventerebbe il bootstrap/runtime del nuovo substrato
  e verrebbe rinominato

l'attuale shebang
  #!/usr/bin/env rumiai-os
  verrebbe migrato verso l'identità del nuovo runtime

il nome `rumiai-os`
  non sarebbe più necessariamente il nome dell'interprete/runtime di basso livello
  e potrebbe identificare il prodotto AI di livello superiore
```

Il nome `m` è soltanto una possibilità di naming per il nuovo substrato. Il vecchio repository `massimilianonardi/m` resta materiale storico/di riferimento e **non è il codice da riprendere né il prodotto da continuare**.

## 2. Limite di autorità

Questa analisi è deliberatamente esplorativa.

Non:

- rinomina oggi `rumiai-os`;
- rinomina oggi il bootstrap;
- modifica oggi alcuno shebang;
- crea un nuovo repository;
- assegna definitivamente il nome `m` al substrato;
- modifica il namespace delle environment variables;
- sposta codice;
- modifica il package manager;
- introduce `bin/sys/ai` o altra nuova gerarchia;
- stabilisce come RumiAI OS debba essere installato o distribuito sopra il substrato;
- stabilisce che RumiAI OS debba essere un package;
- modifica test o physical evidence;
- modifica le specifiche o decisioni normative correnti.

Ogni eventuale adozione richiederebbe decisioni esplicite e un piano di migrazione forward-only delle specifiche, dell'implementazione e dei test interessati.

## 3. Preflight e stato corrente considerato

La chiarificazione è stata riesaminata contro gli HEAD remoti correnti:

```text
rumiai-dev    9d22f0abfcdda4d789cd79b08fdf27cfa37ed6dd
rumiai-os     bd31613f6e2de2ef8096d730916634ee40c4b967
rumiai-tests  4d04b9d6b27f5d99887ea2b18818ab2e00c3267a
```

Sono state considerate in particolare:

```text
RULES.md
CONSISTENCY-GATE.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
handoff/2026-08-29-rumiai-os-bootstrap-permanent-tests-handoff.md
decisions/rumiai-os/2026-09-03-runtime-library-layout.md
decisions/rumiai-os/2026-09-05-package-manager-current-and-run-model.md
decisions/rumiai-os/2026-09-12-package-launch-explicit-command-line.md
decisions/rumiai-os/2026-09-12-package-selection-and-electron-cross-platform-validation.md
```

Sono stati inoltre riesaminati i permanent test correnti dei sottosistemi `bootstrap/` e `command/`, incluso il test della direct shebang execution, perché una eventuale estrazione/rinomina del runtime inciderebbe direttamente su tali contratti.

## 4. Invarianti correnti: descrivono l'oggi, non la futura scissione

La proposta non deve essere confusa con lo stato normativo corrente.

Oggi sono fissati, fra gli altri, i seguenti contratti:

```text
root bootstrap                    rumiai-os
runtime exposure                  bin/sys/rumiai-os -> ../../rumiai-os
bootstrap-integrated shebang      #!/usr/bin/env rumiai-os
runtime root                      m_ROOT
bootstrap identity                m_BOOTSTRAP_BIN
command identity                  m_COMMAND_BIN
system commands                   bin/sys/, bin/sys-<osarch>/
third-party bindings              bin/ext/, bin/ext-<osarch>/
```

Il permanent test `tests/rumiai-os/command/direct-shebang-execution.test` protegge concretamente la risoluzione di `#!/usr/bin/env rumiai-os` attraverso l'ambiente attivo.

Questi contratti restano normativi **finché non viene adottata una nuova architettura**.

La presente ipotesi non cerca di reinterpretarli mantenendoli nominalmente invariati. Al contrario, afferma che una futura scissione completa richiederebbe deliberatamente di migrare i contratti la cui identità appartiene oggi a RumiAI ma la cui responsabilità verrebbe trasferita al substrato.

## 5. Nuovo modello concettuale

La lettura più chiara dell'ipotesi è:

```text
HOST / POSIX ENVIRONMENT
          │
          ▼
GENERAL-PURPOSE SUBSTRATE
          │
          │ public contracts
          ▼
RUMIAI OS
          │
          ▼
AI EXPERIENCE / APPLICATIONS / INTERFACES
```

Il nuovo substrato non sarebbe un'aggiunta sotto l'attuale RumiAI OS: sarebbe **l'estrazione del suo attuale livello basso**.

RumiAI OS cambierebbe conseguentemente ruolo.

### Substrato

Il substrato avrebbe come obiettivo fornire primitive e contratti general purpose per costruire sistemi superiori.

Possibili responsabilità candidate, da verificare una per una:

```text
root discovery e canonicalizzazione
bootstrap/runtime environment
semantic roots
PATH composition
POSIX portability profile
command execution/runtime contract
shell integration generale
logging e language infrastructure generale
OS/architecture detection
primitive terminali general purpose
HTTP fetch
digest
archive extraction
package resolution/materialization/integration/launch
state/runtime infrastructure generalizzabile
```

### RumiAI OS

RumiAI OS diventerebbe un consumer del substrato e conterrebbe ciò che esprime specificamente il prodotto AI.

Possibili responsabilità:

```text
AI runtime selection e integrazione
modelli AI
core/orchestrazione/capability AI
computer use e device integration specifica
interfacce conversazionali
GUI e desktop experience
policy e default RumiAI
configurazioni di prodotto
command semanticamente RumiAI/AI
composizione del software richiesto dal prodotto
```

Questa classificazione è indicativa e non assegna ancora ownership definitiva ai singoli file correnti.

## 6. Conseguenza importante: il bootstrap attuale cambia proprietario concettuale

Nel precedente framing della nota il bootstrap `rumiai-os` era ancora trattato come runtime RumiAI sul quale costruire la specializzazione.

La chiarificazione dell'utente cambia questo punto.

Se il bootstrap attuale è effettivamente general purpose, allora il modello desiderato è più vicino a:

```text
oggi

rumiai-os
  -> bootstrap
  -> runtime
  -> interpreta command
  -> inizializza environment

futuro ipotetico

<runtime-del-substrato>
  -> bootstrap
  -> runtime
  -> interpreta command
  -> inizializza environment general purpose

rumiai-os
  -> applicazione/prodotto AI
  -> usa il substrato
```

Questo implica che la futura migrazione non riguarderebbe soltanto il pathname del file root.

Andrebbero riesaminati insieme:

```text
nome del bootstrap/runtime
symlink di esposizione in bin/sys/
shebang dei command integrati
root identity
command identity
environment-variable ownership
nomi dei semantic roots
linguaggio della documentazione
nome dei test e target discovery
fixture di test
repository ownership
physical evidence future
```

Il comportamento del runtime potrebbe rimanere in larga parte quello già consolidato anche se la sua identità di prodotto cambia.

## 7. `rumiai-os` come possibile desktop/application AI

Una conseguenza interessante della scissione è che il nome `rumiai-os` non deve più svolgere due ruoli contemporaneamente:

```text
runtime/interprete infrastrutturale
prodotto AI visibile all'utente
```

Una volta rinominato il runtime basso, `rumiai-os` potrebbe diventare il nome di un vero entrypoint applicativo del livello superiore.

Una possibile evoluzione concettuale, puramente esplorativa, è:

```text
rumiai-os
  AI desktop / application shell
  interfaccia principale del sistema RumiAI
  avvia o coordina servizi/capability AI
  espone UI, sessione, workspace o esperienza utente
  usa il substrato per filesystem/runtime/package/infrastruttura
```

Questo non implica che debba necessariamente essere una singola GUI monolitica.

"Desktop AI" può indicare il ruolo di prodotto e user experience, mentre l'implementazione concreta potrebbe restare modulare e composta da più processi, package, servizi o interfacce.

## 8. Dipendenza unidirezionale

Il valore della separazione dipende fortemente da questa proprietà:

```text
RumiAI OS -> substrato
substrato -/-> RumiAI OS
```

Il substrato non dovrebbe conoscere:

```text
RumiAI
AI models
orchestrator RumiAI
RumiAI package set
RumiAI UI
RumiAI default
RumiAI product policy
```

RumiAI OS può invece dipendere esplicitamente dai contratti pubblici del substrato.

Questa asimmetria è il punto che permette sviluppo, hardening e testing indipendenti del livello basso.

## 9. Perché la separazione può essere utile

Il vantaggio atteso appare concreto:

- il bootstrap/runtime può essere migliorato senza dipendere dall'evoluzione AI;
- portability, path, shell, terminal, logging e package infrastructure possono essere testati come prodotto autonomo;
- i bug del substrato possono essere isolati dai bug del prodotto AI;
- i contratti pubblici diventano più evidenti perché sono attraversati da un vero boundary di prodotto;
- RumiAI OS può evolvere molto più rapidamente sul piano AI senza destabilizzare continuamente il livello basso;
- il substrato potrebbe in futuro essere usato da sistemi diversi da RumiAI;
- RumiAI OS potrebbe essere sviluppato come vera applicazione di livello superiore invece di coincidere con il proprio bootstrap infrastrutturale.

Il beneficio esiste però solo se i due livelli non richiedono modifiche coordinate per quasi ogni cambiamento.

## 10. Criterio pratico per decidere cosa estrarre

Per ogni responsabilità dell'attuale `rumiai-os` si possono applicare almeno quattro domande.

### 10.1 Esistenza autonoma

> Questa responsabilità ha senso completo anche se RumiAI e l'AI non esistono?

Se no, tende al livello RumiAI.

### 10.2 Consumer indipendente

> Un altro sistema potrebbe usarla senza conoscere terminologia, configurazioni o policy RumiAI?

Se sì, è candidata al substrato.

### 10.3 Meccanismo contro policy

```text
meccanismo
  come si risolve una root
  come si inizializza PATH
  come si individua osarch
  come si esegue un command integrato
  come si scarica/verifica/estrae un artifact
  come si materializza o lancia un package

policy/prodotto
  quali componenti compongono RumiAI
  quali modelli usare
  quali AI capability sono disponibili
  quali default adottare
  quale esperienza utente offrire
```

### 10.4 Stabilità del boundary

> Una modifica interna a questa responsabilità può avvenire senza costringere normalmente il consumer RumiAI a cambiare?

Se no, il contratto potrebbe non essere ancora sufficientemente maturo per l'estrazione.

## 11. Il namespace `m_*`: coincidenza interessante, non decisione

L'ambiente corrente usa già:

```text
m_ROOT
m_BOOTSTRAP_BIN
m_COMMAND_BIN
m_BIN_DIR
m_LIB_DIR
...
```

Se il futuro substrato si chiamasse davvero `m`, questa situazione potrebbe apparire sorprendentemente naturale.

Ma il significato normativo corrente è diverso: `m_*` è oggi definito come namespace delle environment variables RumiAI-owned.

Quindi non si deve inferire automaticamente:

```text
nuovo substrato = m
        quindi
m_* è già il suo namespace definitivo
```

L'eventuale adozione dovrebbe decidere esplicitamente se:

```text
A. il substrato si chiama m e acquisisce semanticamente m_*
B. il substrato ha altro nome ma conserva m_* per compatibilità
C. il substrato usa un nuovo namespace e viene effettuata una migrazione
D. una parte delle variabili resta RumiAI-specifica e una parte viene separata
```

La scelta del nome del substrato e quella del namespace sono correlate ma non devono essere confuse.

## 12. Package manager: candidato forte al substrato, ma con un conflitto corrente da non ignorare

Dal punto di vista delle responsabilità, gran parte di `pkg` appare candidata naturale al substrato:

```text
repository/provider handling
resolution
artifact acquisition
verification
extraction
materialization
integration
launch
environment preparation
state mechanism
```

Queste responsabilità non sono intrinsecamente AI.

Esiste però un vincolo normativo corrente importante.

La decisione Accepted `2026-09-05-package-manager-current-and-run-model.md` stabilisce oggi che:

```text
pkg non è il gestore dei componenti che costituiscono il sistema base RumiAI
il sistema base è non rimovibile tramite pkg
pkg espande il sistema tramite package aggiuntivi
```

La scissione proposta rende questa regola degna di futura rivalutazione, perché il concetto di "sistema base" potrebbe diventare il **substrato** anziché l'intero prodotto RumiAI.

Ma questa nota non cambia la decisione corrente.

Restano quindi aperti almeno tre modelli futuri:

```text
MODELLO A
substrato = base non rimovibile
pkg appartiene al substrato
RumiAI OS è software superiore gestibile/componibile sopra di esso

MODELLO B
substrato = base non rimovibile
RumiAI OS è parte della distribuzione ma non è gestito da pkg
pkg gestisce soltanto software aggiuntivo

MODELLO C
substrato + profilo/distribuzione RumiAI definiscono una composizione obbligatoria
pkg partecipa alla materializzazione ma non implica libera removibilità dei componenti di prodotto
```

Questi modelli richiedono una decisione successiva. Nessuno viene scelto qui.

## 13. `bin/sys/ai` non sembra risolvere il problema principale

Con la nuova chiarificazione, l'ipotesi:

```text
bin/sys/ai/
```

sembra ancora meno centrale.

Se `bin/sys/` appartiene al substrato, collocare sotto di esso una gerarchia AI rischierebbe di reintrodurre proprio il coupling che la separazione vuole eliminare.

Se invece il path appartiene a RumiAI OS, resta da capire perché la directory debba essere la primitive di composizione anziché una conseguenza del modello applicativo/package scelto.

La domanda corretta sembra quindi essere prima:

> come viene composto e installato un consumer di livello superiore sopra il substrato?

Solo dopo ha senso decidere dove materializzare i suoi command pubblici.

## 14. Possibili forme fisiche della scissione

La separazione concettuale non determina automaticamente il modello Git/repository.

### 14.1 Nuovo repository del substrato derivato dall'attuale RumiAI OS

Una possibilità è creare un nuovo repository per il substrato partendo dalla linea di sviluppo corrente di `rumiai-os`, quindi far divergere i due prodotti al momento del cutover:

```text
current rumiai-os history
          │
          ├──> substrate repository
          │      mantiene/evolve il livello basso
          │
          └──> rumiai-os repository
                 rimuove progressivamente il livello estratto
                 sviluppa il prodotto AI sopra il substrato
```

Questo rappresenterebbe bene il fatto che il nuovo substrato **proviene dall'attuale RumiAI OS** e non dal vecchio `m`.

La strategia Git concreta andrebbe valutata rispettando la regola forward-only e senza riscrivere la storia esistente.

### 14.2 Mantenere temporaneamente entrambi i livelli nello stesso repository

Un'altra possibilità è costruire prima il boundary logico nel repository corrente e dividere fisicamente solo dopo aver verificato le dipendenze.

Vantaggio:

```text
minor costo di coordinamento durante la scoperta del boundary
```

Svantaggio:

```text
l'indipendenza di lifecycle rimane incompleta finché la separazione è soltanto interna
```

### 14.3 Copia manuale senza lineage comune

Sarebbe la soluzione meno desiderabile perché aumenterebbe il rischio di duplicazione, drift e due fonti di verità.

### 14.4 Submodule/subtree/vendor

Sono meccanismi di collegamento, non una risposta alla domanda architetturale. Dovrebbero essere valutati solo dopo aver deciso ownership, release e compatibility model.

## 15. Il runtime del substrato come API fondamentale

La futura identità del bootstrap non è un dettaglio di naming.

Oggi:

```text
#!/usr/bin/env rumiai-os
```

significa contemporaneamente:

```text
seleziona il runtime attivo
inizializza l'ambiente RumiAI
source del command body
espone m_ROOT/m_COMMAND_BIN e altre facility
```

Dopo la scissione il significato desiderato diventerebbe più simile a:

```text
#!/usr/bin/env <runtime-substrato>

seleziona il runtime del substrato attivo
inizializza l'ambiente general purpose
source/interpreta il command body
espone i contratti pubblici del substrato
```

I command RumiAI di livello superiore potrebbero a loro volta usare quel runtime quando appropriato, esattamente come qualsiasi altro consumer.

Questo è uno dei segnali più forti che il substrato sarebbe un prodotto reale e non soltanto una directory interna di RumiAI OS.

## 16. `rumiai-os` non deve necessariamente restare uno shell runtime

Nell'architettura ipotizzata, `rumiai-os` potrebbe smettere completamente di avere semantica di interprete.

Potrebbe essere, per esempio:

```text
un executable applicativo
un launcher del desktop AI
un processo principale
un frontend grafico
un application shell
un coordinatore di servizi RumiAI
```

oppure una composizione di più elementi con `rumiai-os` come entrypoint principale.

Questa libertà architetturale è un vantaggio della separazione: il prodotto AI non è più costretto a condividere identità e lifecycle con il runtime POSIX che lo supporta.

## 17. Compatibilità e versionamento fra substrato e RumiAI OS

Per ottenere vera indipendenza di sviluppo serve un contratto di compatibilità osservabile:

```text
substrato cambia internamente
  -> RumiAI OS non cambia se i contratti pubblici restano compatibili

substrato cambia API/contratto pubblico
  -> RumiAI OS deve essere verificato contro la nuova revisione

RumiAI OS cambia comportamento AI/UI
  -> il substrato non cambia salvo nuovo requisito general purpose reale
```

Una futura distribuzione dovrebbe poter identificare almeno:

```text
revisione/versione del substrato
revisione/versione di RumiAI OS
compatibilità verificata fra le due
```

Questa nota non fissa il formato di tale relazione.

## 18. Rischi principali

### 18.1 Generalizzazione prematura

Non tutto ciò che oggi appare generico deve essere automaticamente estratto. Un contratto instabile può diventare più difficile da evolvere una volta pubblicato fra repository/prodotti indipendenti.

### 18.2 Boundary troppo permeabile

Se quasi ogni feature RumiAI richiede una modifica contemporanea al substrato, la separazione non sta funzionando.

### 18.3 Duplicazione

Il nuovo substrato deve **ricevere ownership** delle primitive estratte, non crearne copie parallele lasciando quelle originali attive in RumiAI OS.

### 18.4 RumiAI leakage

Nomi, policy o casi speciali RumiAI non devono risalire nel substrato per comodità.

### 18.5 Substrate creep

Il substrato non deve diventare un contenitore di qualunque funzione riusabile. Deve restare il minimo livello general purpose necessario a costruire consumer superiori.

### 18.6 Migrazione dei test/evidence

Le physical evidence correnti descrivono revisioni di RumiAI OS e non possono essere reinterpretate retroattivamente come validazione del futuro substrato.

Una scissione reale richiederà nuova ownership dei test e nuove validation revision-specific.

## 19. Sequenza esplorativa proposta

Prima di qualsiasi migrazione fisica appare prudente procedere così:

```text
E0  inventario completo dell'attuale rumiai-os

E1  classificazione di ogni responsabilità/file:
    substrate candidate
    RumiAI/product candidate
    boundary/uncertain

E2  dependency graph reale
    soprattutto dipendenze dal livello basso verso semantica RumiAI

E3  candidate public contract del substrato
    bootstrap/runtime
    environment
    command model
    filesystem/layout
    package interface

E4  identificazione delle identità da rinominare
    rumiai-os bootstrap
    shebang
    runtime symlink
    eventuali environment names
    test target names

E5  analisi package/base-system model
    senza assumere che RumiAI OS sia o non sia un package

E6  prova logica del boundary
    il substrato deve poter essere descritto, testato e usato senza RumiAI

E7  confronto dei modelli repository/release/composition

E8  soltanto dopo, eventuale decisione normativa e piano di migrazione forward-only
```

## 20. Direzione che appare più coerente dopo la chiarificazione

La forma concettuale più interessante da esplorare è ora:

```text
NUOVO SUBSTRATO
  derivato dall'attuale livello basso di rumiai-os
  general purpose
  POSIX-oriented
  relocatable
  runtime/bootstrap proprio
  contratti pubblici stabili
  infrastruttura package generale candidata
  nessuna semantica AI/RumiAI

RUMIAI OS
  nuovo livello superiore
  consumer del substrato
  prodotto AI
  capability e policy RumiAI
  possibile desktop/application environment
  evoluzione indipendente dal runtime generale
```

Questo è significativamente diverso da considerare l'attuale `rumiai-os` come substrato sul quale aggiungere semplicemente componenti AI.

L'operazione concettuale è:

```text
non:
  aggiungere un livello sotto rumiai-os

ma:
  dividere rumiai-os corrente
  assegnare il livello basso a un nuovo prodotto
  ridefinire rumiai-os come livello alto
```

## 21. Domande guida per la prossima fase

Le domande più utili da affrontare sembrano essere:

```text
1. quale parte esatta dell'attuale rumiai-os può esistere senza RumiAI?
2. qual è il minimo contratto pubblico che quella parte deve offrire?
3. quali elementi attuali sono davvero substrate e quali sono già policy RumiAI?
4. pkg appartiene integralmente al substrato o contiene responsabilità da separare?
5. qual è il nuovo significato di "base system" dopo la scissione?
6. come deve essere composto/installato RumiAI OS sopra il substrato?
7. quale identità deve avere il nuovo bootstrap/runtime?
8. il namespace m_* viene acquisito dal substrato, migrato o separato?
9. come preservare la storia e la provenance del codice estratto senza duplicazione?
10. quale deve essere il contratto di compatibilità fra release del substrato e RumiAI OS?
```

## 22. Non-decisioni registrate

Restano deliberatamente aperti:

```text
nome definitivo del substrato
uso o meno del nome m
repository concreto del substrato
strategia Git della scissione
nome del bootstrap/runtime del substrato
nuovo shebang concreto
namespace environment futuro
layout fisico finale del substrato
layout fisico del nuovo RumiAI OS
ownership finale di pkg
nuovo significato del sistema base
modalità di composizione/installazione di RumiAI OS
uso di pkg per componenti first-party RumiAI
ruolo esatto dell'eseguibile rumiai-os
forma concreta del desktop/application AI
versionamento e compatibility contract
piano di migrazione dell'implementazione
piano di migrazione dei permanent test
nuove physical validation richieste
```

Nessuno di questi punti deve essere inferito come approvato dalla presente analisi.