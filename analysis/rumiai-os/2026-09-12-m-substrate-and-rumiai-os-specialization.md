# Analisi esplorativa — scissione dell'attuale RumiAI OS in substrato general purpose e prodotto AI

Date: 2026-09-12  
Status: **EXPLORATORY / NON-NORMATIVE**

## 1. Scopo e premessa fondamentale

Questa nota esplora una possibile futura separazione fra:

```text
substrato general purpose
(nome di lavoro possibile: m, nome non ancora deciso)

        ↑ pochi contratti pubblici stabili

RumiAI
prodotto/sistema AI di livello superiore
```

La proposta **non** consiste nel riprendere, modernizzare o riutilizzare il vecchio progetto/repository `massimilianonardi/m`.

Il nuovo substrato deriverebbe invece direttamente dall'attuale `rumiai-os`.

La premessa esplicita di questa fase esplorativa è che `rumiai-os` è nato dall'esigenza di disporre di un runtime più evoluto, robusto e stabile rispetto a quello usato inizialmente per PoC, test e sviluppo orientato all'AI, ma **finora non contiene responsabilità funzionali AI-specifiche**.

Di conseguenza, ai fini di questa esplorazione, la baseline non è più:

```text
attuale rumiai-os
  -> parte general purpose
  -> parte AI già presente da separare
```

ma:

```text
attuale rumiai-os
  -> sostanzialmente tutto candidato al nuovo substrato

futuro RumiAI
  -> nuovo livello superiore costruito sopra il substrato
```

Questo rende la separazione soprattutto una decisione di **ownership, identità e boundary futuro**, non un esercizio immediato di smistamento di codice già mescolato.

## 2. Origine dell'ipotesi

L'attuale `rumiai-os` è stato sviluppato per fornire un ambiente di base più affidabile allo sviluppo del sistema AI:

```text
runtime/bootstrap stabile
POSIX portability
root e path semantici
shell integration
logging
lingua
command runtime
primitive general purpose
package infrastructure
```

Queste responsabilità sono utili a RumiAI, ma non sono intrinsecamente AI.

L'ipotesi è quindi rendere esplicito ciò che il prodotto corrente è già diventato di fatto: un substrato general purpose sul quale RumiAI possa essere costruito senza trascinare nel livello basso semantica, lifecycle e velocità di evoluzione propri dell'AI.

Il momento è potenzialmente favorevole proprio perché la separazione può essere definita **prima** che responsabilità AI-specifiche entrino nello stesso runtime e ne rendano più difficile l'estrazione successiva.

## 3. Limite di autorità

Questa analisi è deliberatamente esplorativa e non normativa.

Non:

- rinomina oggi `rumiai-os`;
- assegna definitivamente il nome `m` al substrato;
- riprende il vecchio repository `massimilianonardi/m`;
- modifica oggi il bootstrap;
- modifica oggi gli shebang;
- modifica namespace o environment variables;
- sposta codice;
- crea un nuovo repository;
- modifica il package manager;
- modifica il ruolo normativo di `pkg-catalog`;
- introduce un service manager o un protocollo daemon;
- stabilisce nuovi command, API, socket, bus o namespace;
- stabilisce che componenti first-party RumiAI debbano diventare package;
- modifica specifiche, decisioni Accepted, permanent test o physical evidence correnti.

Ogni eventuale adozione richiederebbe decisioni esplicite e una migrazione forward-only di documentazione, implementazione, test ed evidence interessati.

## 4. Preflight e fonti considerate

La presente revisione è stata riesaminata contro gli HEAD remoti correnti:

```text
rumiai-dev    c871b076f442bf3003942bcf560d5f6a7c498852
rumiai-os     bd31613f6e2de2ef8096d730916634ee40c4b967
rumiai-tests  4d04b9d6b27f5d99887ea2b18818ab2e00c3267a
pkg-catalog   69dcdab2b8cd5dd0c0b0f9d8e0fe9651939fbcaa
```

Sono state considerate in particolare:

```text
RULES.md
CONSISTENCY-GATE.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
decisions/rumiai-os/2026-09-05-interactive-shell-startup.md
decisions/rumiai-os/2026-09-05-package-manager-current-and-run-model.md
decisions/rumiai-os/2026-09-07-package-definition-catalog-and-version-ranges.md
decisions/rumiai-os/2026-09-07-package-catalog-repository.md
decisions/rumiai-os/2026-09-08-package-stream-repository-independence.md
```

Sono stati inoltre riesaminati i permanent test correnti relativi a bootstrap e command runtime, incluso il test della direct shebang execution.

La scansione della documentazione autorevole corrente non ha individuato un contratto già consolidato per un sottosistema generale di servizi/daemon. La relativa boundary deve quindi essere considerata futura e non dedotta da primitive inesistenti.

## 5. Invarianti correnti: stato presente contro ipotesi futura

Oggi restano normativi, fra gli altri:

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

L'attuale shell startup, il package manager, il catalog model e i relativi test continuano a proteggere questi contratti finché una decisione esplicita non li modifica.

La presente ipotesi non tenta di aggirarli. Afferma invece che, se la separazione venisse adottata, una parte di quei contratti dovrebbe essere deliberatamente **trasferita e rinominata** perché la responsabilità passerebbe dal prodotto RumiAI al substrato.

## 6. Modello concettuale aggiornato

La forma più aderente alla chiarificazione corrente è:

```text
HOST / POSIX ENVIRONMENT
          │
          ▼
GENERAL-PURPOSE SUBSTRATE
  sostanzialmente l'attuale rumiai-os
          │
          │ pochi contratti pubblici stabili
          ▼
RUMIAI
  ├─ shell personalizzata
  ├─ servizi/daemon AI
  ├─ core e capability AI
  └─ desktop / GUI
```

Il nuovo substrato non è un livello aggiunto sotto il RumiAI OS corrente.

È l'attuale runtime general purpose che riceve una propria identità autonoma; il nome e il ruolo `rumiai-os` possono quindi essere riutilizzati per il prodotto AI superiore.

## 7. Conseguenza sul bootstrap e sugli shebang

Se l'ipotesi venisse adottata, l'attuale bootstrap:

```text
rumiai-os
```

sarebbe candidato a diventare il bootstrap/runtime del substrato e verrebbe rinominato coerentemente con la nuova identità.

Di conseguenza anche:

```text
#!/usr/bin/env rumiai-os
bin/sys/rumiai-os -> ../../rumiai-os
```

sarebbero contratti da migrare, non da conservare nominalmente a tutti i costi.

Il comportamento consolidato del runtime potrebbe restare in larga parte invariato mentre cambia la sua ownership di prodotto.

La migrazione reale dovrebbe riesaminare insieme almeno:

```text
bootstrap/runtime identity
runtime exposure
integrated-command shebang
root e command identity
environment ownership
semantic-root naming
test target discovery
fixture
repository ownership
physical validation
```

Questa nota non sceglie il nuovo nome concreto del runtime né il nuovo shebang.

## 8. Principio chiave: piccolo budget di API pubblica

Il punto più importante della nuova formulazione non è soltanto separare due repository.

È fare in modo che RumiAI dipenda da **pochi contratti stabili** del substrato.

Idealmente il livello superiore non dovrebbe conoscere ogni dettaglio interno del runtime, ogni directory o ogni environment variable soltanto perché oggi esistono nello stesso prodotto.

L'obiettivo architetturale esplorativo diventa:

```text
molte primitive interne al substrato
        ↓
pochi contratti pubblici stabili
        ↓
RumiAI
```

Questo riduce la superficie di compatibilità da mantenere e permette al substrato di essere rifattorizzato, ottimizzato e irrobustito senza richiedere modifiche coordinate al sistema AI.

Le tre superfici oggi più evidenti da esplorare sono:

```text
shell contract
service/daemon contract
command contract
```

Il package/catalog model attraversa principalmente la command/package surface e resta general purpose.

## 9. Shell: infrastruttura generale sotto, personalizzazione RumiAI sopra

La shell corrente è già soprattutto un'infrastruttura di integrazione con le shell dell'host:

```text
$SHELL con fallback sh
adapter bash/zsh/sh/dash/ash
rispetto dello startup nativo
caricamento del core
prompt/environment integration
hook uniforme di estensione
```

Questa responsabilità è candidata naturale al substrato.

Il futuro RumiAI avrebbe invece una **propria shell experience/personalizzazione** costruita sopra tale infrastruttura.

Concettualmente:

```text
substrato
  -> seleziona e integra la shell host
  -> fornisce il minimo ambiente/hook stabile necessario

RumiAI shell
  -> aggiunge prompt e comportamento RumiAI
  -> espone command e funzioni AI
  -> integra sessione/context/capability RumiAI quando previsto
```

L'attuale `m_SHELL_EXT` dimostra che esiste già un punto uniforme di estensione della shell, ma questa analisi **non** lo promuove automaticamente a futuro contratto RumiAI-substrato né ne fissa il nome o la semantica futura.

La domanda da risolvere è quale sia il più piccolo contratto shell necessario a RumiAI, non quanta parte dell'implementazione shell corrente rendere pubblica.

## 10. Servizi/daemon: futuro boundary, non sottosistema già fissato

RumiAI è destinato ad avere componenti persistenti o di background: servizi/daemon che realizzano capacità AI, coordinamento o integrazioni necessarie al prodotto.

Questi servizi appartengono al livello RumiAI, non al substrato soltanto perché sono processi di background.

Il substrato potrebbe in futuro dover offrire pochi contratti general purpose utili a tali processi, ma la documentazione corrente non fissa ancora un modello canonico di service management o daemon infrastructure.

Perciò questa nota registra soltanto il requisito architetturale:

> RumiAI dovrebbe dipendere da una piccola superficie stabile per le esigenze general purpose dei propri servizi/daemon, senza costringere il substrato a conoscere la semantica dei servizi AI.

Restano aperti, e non vengono nominati né progettati qui, gli eventuali contratti necessari per lifecycle, discovery, communication, readiness, state o altre responsabilità che emergeranno da casi concreti.

Non viene introdotta alcuna nuova primitive anticipatoria.

## 11. Command: pochi contratti pubblici anziché l'intero runtime

Per il livello RumiAI potrebbe essere sufficiente consumare direttamente un numero piccolo di command general purpose stabili.

Esempi già esistenti e concettualmente plausibili sono:

```text
lang
log
pkg
```

oltre agli eventuali pochi altri command che un requisito reale dimostrerà necessari.

Il principio esplorativo è importante:

> un command del substrato non diventa automaticamente API pubblica di RumiAI soltanto perché è disponibile nel `PATH`.

Conviene distinguere fra:

```text
command interni/operativi del substrato
command pubblici su cui RumiAI costruisce un contratto di dipendenza
```

Più piccolo resta il secondo insieme, più indipendenti possono evolvere i due livelli.

## 12. `pkg` e `pkg-catalog`: dominio software, non dominio AI

Il package manager è un candidato forte al substrato perché le sue responsabilità sono general purpose:

```text
repository discovery
version resolution
artifact acquisition
integrity/provenance data
extraction/materialization
integration
launch
environment preparation
state mechanism
```

Analogamente, il catalogo delle package definition non ha bisogno di essere separato per dominio applicativo.

Il modello corrente è package-first:

```text
<pkg>/catalog/
<pkg>/catalog-<osarch>/
```

La package definition descrive come standardizzare software esterno rispetto al package model; non richiede una categoria distinta per software AI.

Nell'ipotesi esplorativa, lo stesso `pkg-catalog` può quindi contenere indifferentemente definition per:

```text
software general purpose
runtime grafici
runtime di linguaggio
strumenti di sviluppo
runtime/modelli/tool AI esterni
altro software esterno
```

purché ogni definition rispetti gli stessi contratti del package manager.

Questo evita di introdurre:

```text
un secondo catalogo AI
un secondo meccanismo di sync/versionamento
una seconda superficie di provenance
una seconda policy di update
una seconda implementazione di adapter/repository handling
```

La centralizzazione non significa che tutte le policy di sicurezza siano già risolte. I contratti correnti già separano definition dichiarative da codice arbitrario e identificano lo snapshot tramite Git; ulteriori trust, firma o provenance policy restano decisioni specifiche quando necessarie.

Il repository concreto corrente contiene già package general purpose come `dbeaver` ed `electron`, coerentemente con questa natura non legata all'AI.

## 13. Nessun conflitto necessario con il current `pkg` base-system contract

La decisione Accepted corrente stabilisce che `pkg` non gestisce i componenti che costituiscono il sistema base RumiAI e che il sistema base non è rimovibile tramite `pkg`.

La presenza nel catalogo di definition per **software AI esterno** non contraddice questa regola.

Per esempio, un runtime AI, un motore esterno o un tool usato da RumiAI può essere software aggiuntivo gestito da `pkg` esattamente come altro software esterno.

Resta invece aperta una domanda diversa:

```text
componenti first-party costitutivi del futuro RumiAI
  -> sono parte non-package del prodotto?
  -> oppure in futuro alcuni di essi saranno materializzati tramite pkg?
```

Questa nota non risponde e non modifica il contratto Accepted corrente.

La distinzione permette di accettare l'idea del catalogo universale senza inferire automaticamente un nuovo modello di packaging del core RumiAI.

## 14. Il catalogo come interfaccia universale verso software esterno

Una formulazione utile dell'idea è:

> `pkg-catalog` standardizza l'integrazione di software esterno rispetto al substrato, indipendentemente dal motivo per cui un consumer lo utilizza.

Il package non deve sapere se verrà usato:

```text
da RumiAI
per AI
per sviluppo
per desktop
per database
per un altro consumer futuro del substrato
```

Questa separazione è coerente con l'obiettivo di mantenere `m`/substrato general purpose e di impedire che il package manager accumuli categorie product-specific.

RumiAI esprime la propria policy scegliendo **quali** package richiede o supporta; `pkg` e `pkg-catalog` esprimono **come** quel software esterno viene risolto, verificato, materializzato e integrato secondo contratti generali.

## 15. RumiAI come layer superiore composto da tre forme operative

La chiarificazione corrente suggerisce una struttura di alto livello particolarmente semplice:

```text
RumiAI
│
├── shell RumiAI
│     consumer della shell infrastructure del substrato
│
├── servizi/daemon RumiAI
│     processi persistenti/background del sistema AI
│     consumer di pochi futuri contratti general purpose
│
└── desktop RumiAI
      interazioni GUI
      consumer dei servizi AI e dei contratti necessari del substrato
```

Il core cognitivo, le capability e le integrazioni AI possono essere distribuiti fra questi elementi secondo l'architettura RumiAI già o successivamente fissata; questa nota non ridefinisce tali sottosistemi.

Il valore di questa forma è che nessuno dei tre richiede che il substrato conosca l'AI.

## 16. `rumiai-os` come possibile desktop/application product

Una volta che il runtime generale non usa più necessariamente il nome `rumiai-os`, tale nome può identificare il livello di prodotto visibile all'utente.

Una possibilità esplorativa è che `rumiai-os` diventi il principale desktop/application environment RumiAI, eventualmente coordinato con shell e servizi/daemon.

Ciò non implica una GUI monolitica né una singola process architecture.

Il punto è separare le identità:

```text
runtime general purpose
  !=
prodotto AI visibile all'utente
```

Questa libertà permette al prodotto AI di evolvere senza essere vincolato all'identità del proprio interprete POSIX di basso livello.

## 17. Boundary desiderato

La dipendenza dovrebbe restare unidirezionale:

```text
RumiAI -> substrato
substrato -/-> RumiAI
```

Inoltre il numero di dipendenze attraversanti il boundary dovrebbe essere piccolo.

Un segnale di buona separazione sarebbe:

```text
refactor interno del substrato
  -> nessuna modifica RumiAI finché shell/service/command contracts restano compatibili

nuova capability AI
  -> normalmente nessuna modifica del substrato

nuovo software AI esterno
  -> nuova/aggiornata package definition nel catalogo
     senza nuova categoria AI nel package manager
```

Se quasi ogni evoluzione AI richiedesse una nuova primitive nel substrato, il boundary sarebbe troppo permeabile.

## 18. Implicazione importante: non serve più una classificazione simmetrica del codice corrente

La precedente sequenza esplorativa assumeva di dover dividere l'attuale codebase fra:

```text
substrate candidate
RumiAI/product candidate
boundary/uncertain
```

La nuova premessa la semplifica.

La baseline di lavoro diventa:

```text
tutto l'attuale rumiai-os
  -> candidato substrato
```

La verifica necessaria è quindi inversa:

> esiste oggi qualcosa nel prodotto corrente che, nonostante l'apparenza general purpose, contiene già semantica o policy AI/RumiAI tale da non dover appartenere al substrato?

Se la risposta resta no, la migrazione iniziale può concentrarsi su identity/ownership/contracts anziché sulla separazione fisica di due insiemi di codice già intrecciati.

## 19. Conseguenza sulla strategia di migrazione futura

Se questa lettura viene confermata, una futura adozione potrebbe risultare concettualmente più semplice:

```text
1. stabilire il nome e l'identità del substrato
2. trasferire all'identità del substrato l'attuale runtime/codebase general purpose
3. riallineare bootstrap, shebang, env ownership, documentazione e permanent test
4. fissare soltanto i piccoli contratti pubblici necessari al consumer RumiAI
5. costruire il nuovo RumiAI sopra tali contratti
6. mantenere pkg-catalog come catalogo general purpose del software esterno
```

Questo non è ancora un piano operativo approvato e non autorizza alcuna modifica di prodotto.

## 20. Rischi da controllare

### 20.1 API surface creep

La separazione perde valore se RumiAI viene autorizzato a dipendere da ogni dettaglio interno del substrato.

### 20.2 RumiAI leakage

Policy, nomi o eccezioni AI non devono risalire nel substrato per comodità.

### 20.3 Generalizzazione prematura dei servizi

Poiché il service/daemon boundary non è ancora definito, non bisogna inventare anticipatamente bus, protocollo, supervisor, registry o namespace senza un caso concreto.

### 20.4 Duplicazione dei cataloghi

Un catalogo AI separato rischierebbe di duplicare meccanismi e policy senza che esista oggi una differenza semantica nel package model che lo richieda.

### 20.5 Confusione fra software esterno e core RumiAI

L'uso del catalogo per software AI esterno non deve essere trasformato implicitamente in una decisione di packaging dei componenti first-party del sistema RumiAI.

### 20.6 Evidence e lineage

I test e le physical evidence correnti restano evidence delle revisioni RumiAI OS realmente esercitate. Una futura rinomina/scissione richiede riallineamento e nuova evidence revision-specific; non è lecito reinterpretare retroattivamente i risultati correnti.

## 21. Sequenza esplorativa aggiornata

Alla luce della nuova premessa, la sequenza più utile sembra essere:

```text
E0  verificare l'assunto:
    nessuna responsabilità AI-specifica è oggi dentro rumiai-os

E1  inventariare le dipendenze che un futuro RumiAI avrebbe realmente dal substrato

E2  ridurre tali dipendenze a pochi candidate contracts:
    shell
    servizi/daemon
    command

E3  per i command, distinguere:
    public contract consumato da RumiAI
    implementation/operational command del substrato

E4  verificare il package boundary:
    software esterno AI e non-AI usa lo stesso pkg/pkg-catalog
    nessuna categoria AI nel package model senza requisito concreto

E5  progettare il service/daemon boundary solo dai primi casi reali
    senza primitive anticipate

E6  definire candidate identity/naming migration:
    repository
    bootstrap/runtime
    shebang
    env ownership
    test ownership

E7  verificare che RumiAI possa essere descritto come consumer
    senza conoscere implementation detail del substrato

E8  soltanto dopo, eventuale decisione normativa
    e piano di migrazione forward-only
```

## 22. Domanda architetturale centrale

La domanda guida non è più principalmente:

> quale parte dell'attuale RumiAI OS dobbiamo estrarre?

Diventa:

> **qual è il più piccolo insieme di contratti stabili che il futuro RumiAI deve ricevere dall'attuale runtime general purpose affinché tutto il resto possa evolvere indipendentemente?**

Una risposta buona dovrebbe lasciare il substrato libero di cambiare internamente e RumiAI libero di evolvere sul piano AI, GUI e servizi senza commit coordinati salvo veri cambi di contratto.

## 23. Direzione esplorativa risultante

La forma che appare ora più coerente con le premesse è:

```text
NUOVO SUBSTRATO
  = sostanzialmente l'attuale rumiai-os
  = runtime general purpose
  = shell infrastructure general purpose
  = primitive e command general purpose
  = pkg infrastructure
  = nessuna conoscenza AI/RumiAI

PKG-CATALOG
  = catalogo unico general purpose
  = package definition di software esterno
  = AI e non-AI trattati con lo stesso modello

RUMIAI
  = nuovo consumer superiore
  = shell personalizzata
  = servizi/daemon AI
  = core/capability AI
  = desktop/GUI
  = dipendenza da pochi contratti stabili del substrato
```

Il vantaggio principale non sarebbe soltanto il riuso del substrato, ma la possibilità di **stabilizzare molto poco e lasciare evolvere liberamente molto**.

## 24. Non-decisioni registrate

Restano deliberatamente aperti:

```text
nome definitivo del substrato
uso o meno del nome m
repository concreto del substrato
strategia Git della scissione
nome del bootstrap/runtime del substrato
nuovo shebang concreto
namespace environment futuro
quali environment variables siano davvero public contract
forma esatta del shell contract RumiAI-substrato
forma esatta del service/daemon contract
eventuale service manager/supervisor e relativo ownership
insieme finale dei command pubblici consumati da RumiAI
ownership finale e naming di pkg dopo la scissione
packaging dei componenti first-party RumiAI
ruolo esatto dell'eseguibile rumiai-os
forma concreta del desktop/application AI
versionamento e compatibility contract
piano di migrazione dell'implementazione
piano di migrazione dei permanent test
nuove physical validation richieste
```

Nessuno di questi punti deve essere inferito come approvato dalla presente analisi.
